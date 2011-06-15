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

  context "set_entity_type" do
    it "allows setting the entity type in the inherited class body" do
      class Model < Glitr::Base
        set_entity_type "MyModel"
      end
      Model.entity_type.should == "MyModel"
    end
  end

  context "set_namespace" do
    it "allows setting the namespace in the inherited class body" do
      class Model < Glitr::Base
        set_namespace "http://example.com/example"
      end
      Model.namespace.should == "http://example.com/example"
    end
  end

end
