require 'spec_helper'

describe Setty do
  describe ".config" do
    subject { Setty.config }
    it { should be_an_instance_of(Setty::Configuration)}
  end

  describe "direct method access to configuration" do
    subject { Setty }
    context "when existing conf" do
      it "#example returns example_yml[Rails.env][:example]" do
        subject.example.should eq example_yml[Rails.env]
      end
    end

    context "when not existing conf" do
      it "#non_existing_example raises NoMethodError" do
        -> { subject.non_existing_example }.should raise_error(NoMethodError)
      end
    end
  end
end
