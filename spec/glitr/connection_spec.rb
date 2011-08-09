require 'spec_helper.rb'

describe Glitr::Connection do

  let(:connection) { Glitr::Connection.new :service => 'foo' }

  context '#new' do
    it 'takes connection options' do
      connection.options[:service].should == 'foo'
    end

    it 'sets default connection options' do
      connection.options[:host].should == 'localhost'
      connection.options[:port].should == 2020
      connection.options[:protocol].should == 'http'
    end
  end

  context '#query_uri' do
    it 'consturcts a URI for a given query' do
      query = <<-QUERY
        SELECT ?foo
        WHERE {
          ?foo :bar "baz"
        }
      QUERY

      uri = connection.query_uri(query)
      uri.should == 'http://localhost:2020/foo?output=csv&query=SELECT+%3Ffoo+WHERE+%7B+%3Ffoo+%3Abar+%22baz%22+%7D'
    end
  end

  context '#fetch' do
    it 'parses a response from the server as CSV' do
      stub_response connection, :simple

      result = connection.fetch "DUMMY QUERY"

      # row 1
      result[0]['_subject'].should == 'entity1'
      result[0]['_predicate'].should == 'foo'
      result[0]['_object'].should == 'bar'
    end

  end

  context '#query_subjects' do
    it 'groups the results by subject' do
      stub_response connection, :simple

      subjects = connection.fetch_subjects "DUMMY QUERY"

      subjects.keys.should include('entity1', 'entity2')
      subjects['entity1'].should == {'foo' => 'bar', 'baz' => 'bam'}
    end
  end

end

def stub_response(connection, fixture_name)
  fixture = SpecRoot.join 'fixtures', 'responses', "#{fixture_name}.csv"
  connection.stubs(:get_response).returns fixture.read
end
