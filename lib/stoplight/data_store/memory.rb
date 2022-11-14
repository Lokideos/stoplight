# frozen_string_literal: true

require 'monitor'

module Stoplight
  module DataStore
    # @see Base
    class Memory < Base
      include MonitorMixin
      LOCK_TTL = 1
      LOCKED_STATUS = 1

      def initialize(lock_ttl: LOCK_TTL)
        @failures = Hash.new { |h, k| h[k] = [] }
        @states = Hash.new { |h, k| h[k] = State::UNLOCKED }
        @notification_locks = Hash.new { |h, k| h[k] = [] }
        @lock_ttl = lock_ttl
        super() # MonitorMixin
      end

      def names
        synchronize { @failures.keys | @states.keys }
      end

      def get_all(light)
        synchronize { [@failures[light.name], @states[light.name]] }
      end

      def get_failures(light)
        synchronize { @failures[light.name] }
      end

      def record_failure(light, failure)
        synchronize do
          n = light.threshold - 1
          @failures[light.name] = @failures[light.name].first(n)
          @failures[light.name].unshift(failure).size
        end
      end

      def clear_failures(light)
        synchronize { @failures.delete(light.name) }
      end

      def get_state(light)
        synchronize { @states[light.name] }
      end

      def set_state(light, state)
        synchronize { @states[light.name] = state }
      end

      def clear_state(light)
        synchronize { @states.delete(light.name) }
      end

      def notification_lock_exists?(light)
        synchronize do
          lock = get_setex(@notification_locks, light.name)
          setex(@notification_locks, light.name, LOCKED_STATUS, @lock_ttl)

          lock.nil? ? false : true
        end
      end

      private

      def get_setex(hash, key)
        synchronize do
          with_cleanup(hash, key) do |h, k|
            value_array = h[k]
            return if value_array.nil? || value_array.empty?

            value, time_diff, value_created_at = value_array
            value_created_at + time_diff > Time.now.to_i ? [value, false] : [nil, true]
          end
        end
      end

      def with_cleanup(hash, key)
        synchronize do
          block_call_result, garbage = yield(hash, key)
          hash.delete(key) if garbage

          block_call_result
        end
      end

      def setex(hash, key, value, expiration_time_diff)
        synchronize { hash[key] = [value, expiration_time_diff, Time.now.to_i] }
      end
    end
  end
end
