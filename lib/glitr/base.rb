module Glitr

  class Base
    include Comparable

    attr_accessor :id, :attributes

    def initialize(id, attributes)
      self.id, self.attributes = id, attributes
    end

    def self.entity_type
      @entity_type ||= name.split("::").last
    end

    def self.entity_type=(type)
      @entity_type = type
    end

    def self.namespace
      @namespace
    end

    def self.namespace=(ns)
      @namespace = ns
    end

    def self.count(conditions = {})
      query = <<-QUERY
        PREFIX :   <http://metrumrg.com/metamodl/>
        PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
        PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

        SELECT (count(distinct ?uuid) as ?count)
        WHERE {

          ?#{entity_type} rdf:type :#{entity_type};
                  :uuid ?uuid .
          #{ build_filters entity_type, conditions }
        }
      QUERY

      result = connection.fetch(query)
      result.first && result.first['count'].to_i
    end

    # Query Builder Methods
    class << self
      %w(select where limit all first).each do |query_builder_method|
        define_method query_builder_method do |*args|
          QueryBuilder.new(self).send query_builder_method, *args
        end
      end

      def execute_query(query_builder)
        query = query_builder.to_sparql

        if query_builder.subjectify?
          build_all fetch_subjects(query)
        else
          fetch query
        end
      end
    end

    def [](attr)
      attributes[namespaced_key(attr)]
    end

    def method_missing(method, *params)
      key = namespaced_key(method)

      if attributes.has_key?(key)
        return attributes[key] 
      else
        super
      end
    end

    def <=>(other)
      self.attributes <=> other.attributes
    end

    private

    def self.connection
      @connection ||= Glitr::Connection.new(:service => "metamodl_#{Rails.env}")
    end

    def self.build_all(entities)
      entities.map {|id, attrs| new(id, attrs) }
    end

    def namespaced_key(key)
      "#{self.class.namespace}/#{key}"
    end

  end

end
