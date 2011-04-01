require 'spec_helper'

describe Glitr::Base do

  context "==" do
    it "retuns true if their attributes are equal" do
      model_a = Glitr::Base.new 1, :foo => 'bar'
      model_b = Glitr::Base.new 1, :foo => 'bar'

      model_a.should == model_b
    end

    it "returns false if their attributes are NOT equal" do
      model_a = Glitr::Base.new 1, :foo => 'bar'
      model_b = Glitr::Base.new 1, :foo => 'baz'

      model_a.should_not == model_b
    end
  end

end
