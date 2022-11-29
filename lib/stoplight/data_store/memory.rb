# frozen_string_literal: true

require 'monitor'

module Stoplight
  module DataStore
    # @see Base
    class Memory < Base
      include MonitorMixin
      LOCK_TTL = 1
      LOCKED_STATUS = 1

      def initialize(_lock_ttl: LOCK_TTL)
        @failures = Hash.new { |h, k| h[k] = [] }
        @states = Hash.new { |h, k| h[k] = State::UNLOCKED }
        @notification_locks = {}
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

      def with_notification_lock(light)
        synchronize do
          return if @notification_locks[light.name] == LOCKED_STATUS

          @notification_locks[light.name] = LOCKED_STATUS
          yield
        end
      end

      def with_lock_cleanup(light)
        synchronize do
          @notification_locks.delete(light.name)
          yield
        end
      end
    end
  end
end
