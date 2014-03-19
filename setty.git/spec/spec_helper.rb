$:<< File.join(File.dirname(__FILE__), '..', 'lib')
$:<< File.dirname(__FILE__)

require 'rubygems'
require 'bundler/setup'

require 'setty'

SPEC_RAILS_ROOT = File.join(File.dirname(__FILE__))

# for Rails class object
require 'rspec/core/shared_context'

module Setty::RSpecContext
  extend RSpec::Core::SharedContext
  let(:fake_rails) { Class.new }
  let(:configuration) { Setty::Configuration.instance }
  let(:config_path) { "#{Rails.root}/config/setty" }
  let(:example_yml) { YAML.load(ERB.new(File.read("#{config_path}/example.yml")).result).with_indifferent_access }

  before do
    stub_const("Rails", fake_rails)
    Rails.stub(root: SPEC_RAILS_ROOT)
    Rails.stub(env: "development")
  end
end

RSpec.configure do |config|
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.include Setty::RSpecContext
end
