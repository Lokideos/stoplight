# frozen_string_literal: true

require "spec_helper"

RSpec.describe Stoplight::Notifier do
  it "is a module" do
    expect(described_class).to be_a(Module)
  end
end
