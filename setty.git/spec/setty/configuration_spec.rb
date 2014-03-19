require 'spec_helper'

describe Setty::Configuration do
  shared_examples_for "config_hash_access_readable" do
    context 'when existing key' do
      it 'should not be nil' do
        subject[:example][:foo].should_not be_nil
      end

      it 'should eq yaml[Rails.env][key]' do
        subject[:example][:foo].should eq example_yml[Rails.env][:foo]
      end
    end

    context 'when not existing key' do
      it 'should be nil' do
        subject[:example][:not_existed].should be_nil
      end
    end

    context 'when not existing config file' do
      it 'should be nil' do
        subject[:not_existing_example].should be_nil
      end
    end
  end

  shared_examples_for "config_method_readable" do
    context 'when existing key' do
      it 'should not be nil' do
        subject.example.foo.should_not be_nil
      end

      it 'should eq yaml[Rails.env][key]' do
        subject.example.foo.should eq example_yml[Rails.env][:foo]
      end
    end

    context 'when not existing key' do
      it "should be nil" do
        subject.example.not_existed.should be_nil
      end
    end

    context 'when not existing config file' do
      it 'should raises error' do
        -> { subject.not_existing_example }.should raise_error(NoMethodError)
      end
    end

  end

  describe ".[]" do
    subject { Setty::Configuration }
    it_should_behave_like "config_hash_access_readable"
  end

  describe "#[]" do
    subject { Setty::Configuration.instance }
    it_should_behave_like "config_hash_access_readable"
  end

  describe "method access to configuration class" do
    subject { Setty::Configuration }
    it_should_behave_like "config_method_readable"
  end

  describe "method access to configuration instance" do
    subject { Setty::Configuration.instance }
    it_should_behave_like "config_method_readable"
  end

  describe "#config_path" do
    subject { configuration.config_path }
    it 'should eq "#{Rails.root}/config/setty/"' do
      should eq "#{Rails.root}/config/setty/"
    end
  end

  describe "#load!" do
    context "config yaml is broken" do
      it 'should raise error' do
        YAML.stub(:load).and_raise(StandardError)
        expect { Setty::Configuration.instance.load! }.to raise_error(Setty::Configuration::LoadError)
      end
    end
  end
end
