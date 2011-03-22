module Glitr

  class QueryBuilder

    attr_accessor :model, :query_conditions, :query_select, :query_limit

    def initialize(model)
      self.model = model

      self.query_conditions = {}
      self.query_select     = []
      self.query_limit      = nil
    end

    def select(*predicates)
      self.query_select += predicates.flatten
      self
    end

    def where(conditions)
      self.query_conditions.merge!(conditions)
      self
    end

    def limit(max)
      self.query_limit = max
      self
    end

    def all
      model.execute_query(self)
    end

    def first
      self.limit(1)
      model.execute_query(self).first
    end

    def subjectify?
      query_select.empty?
    end

    def to_sparql
      sparql  = []
      sparql << build_namespaces
      sparql << build_select
      sparql << build_where
      sparql << build_limit

      sparql.compact.join("\n")
    end

    private

    def build_namespaces
      <<-EOS
        PREFIX :     <#{ model.namespace }>
        PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
        PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      EOS
    end

    def build_select
      select = query_select.any? ? query_select : subject_select
      bindings = select.map {|s| "?#{s}" }

      "SELECT #{bindings.join ' '}"
    end

    def build_where
      <<-EOS
        WHERE {
          ?#{model.entity_type} rdf:type :#{model.entity_type} .

          #{ build_bindings(model.entity_type, (query_select + query_conditions.keys)) }
          #{ build_filters model.entity_type, query_conditions }

          #{ capture_subject unless query_select.any? }
        }
      EOS
    end

    def build_limit
      return unless query_limit
      "LIMIT #{query_limit.to_i}"
    end

    def subject_select
      [:_subject, :_predicate, :_object]
    end

    def capture_subject
      <<-EOS
        LET ( ?_subject := ?#{model.entity_type} ) .
        ?_subject ?_predicate ?_object .
      EOS
    end

    def build_bindings(entity_type, bindings)
      bindings.map{|bind| "OPTIONAL { ?#{entity_type} :#{bind} ?#{bind} . }" }.join("\n")
    end

    def build_filters(entity_type, conditions)
      conditions.reject {|attr, value| value.blank?}.
        map{|attr, *values| "FILTER ( ?#{attr} in (#{values.flatten.map {|val| '"'+val+'"'}.join(',') }) ) ." }.
        join("\n")
    end

  end

end
