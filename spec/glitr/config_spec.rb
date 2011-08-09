require 'spec_helper'

describe Glitr::Config do

  context "#configure" do
    around do |ex|
      original_cache_store = Glitr.config.cache_store
      ex.run
      Glitr.config.cache_store = original_cache_store
    end

    it "saves config values" do
      Glitr.configure do |config|
        config.cache_store = 'Foo'
      end

      Glitr.config.cache_store.should == 'Foo'
    end
  end

end
