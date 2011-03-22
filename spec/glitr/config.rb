require 'spec_helper'

describe Glitr::Config do

  context "#configure" do
    it "saves config values" do
      Gliture.configure do |config|
        config.cache_store = 'Foo'
      end

      Glitr.config.cache_store.should == 'Foo'
    end
  end

end
