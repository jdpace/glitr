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

    def self.primary_key
      @primary_key ||= :uuid
    end

    def self.primary_key=(key)
      @primary_key = key
    end

    def self.prefix
      @prefix
    end

    def self.prefix=(pre)
      @prefix = RDF::Vocabulary.new(pre)
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
      %w(select where limit offset order bind optional filter find columns all first).each do |relation_method|
        define_method relation_method do |*args|
          Relation.new(self).send relation_method, *args
        end
      end

      def query(relation)
        query = relation.to_sparql
        results = connection.fetch query

        should_objectify?(results) ? objectify(results) : results
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
      @connection ||= Glitr::Connection.new(:service => "metamodl_development")
    end

    def self.should_objectify?(results)
      results.headers == %w(_subject _predicate _object)
    end

    def self.objectify(results)
      build_all subjectify(results)
    end

    def self.subjectify(results)
      by_subject = results.group_by {|row| row['_subject'] }
      by_subject.each do |subject, rows|
        by_subject[subject] = rows.reduce({}) do |attrs, row|
          predicate, object = row['_predicate'], row['_object']

          if attrs.has_key?(predicate)
            attrs[predicate]  = *attrs[predicate] unless attrs[predicate].is_a?(Array)
            attrs[predicate] << object
          else
            attrs[predicate] = object
          end

          attrs
        end
      end

      by_subject
    end

    def self.build_all(entities)
      entities.map {|id, attrs| new(id, attrs) }
    end

    def namespaced_key(key)
      "#{self.class.prefix}#{key}"
    end

  end

end
