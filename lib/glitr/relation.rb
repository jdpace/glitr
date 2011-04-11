module Glitr

  class Relation

    attr_accessor :target, :form

    def initialize(target)
      self.target = target
      self.form   = :select

      @selects    = []
      @bindings   = []
      @optionals  = []
      @conditions = {}
      @filters    = []
      @group      = []
      @order      = []
      @limit      = nil
      @offset     = nil
    end

    def select(*predicates)
      @selects += predicates.flatten
      self.bind predicates
      self
    end

    def bind(*predicates)
      @bindings += predicates.flatten
      self
    end

    def optional(*predicates)
      @optionals += predicates.flatten
      self
    end

    def where(conditions)
      conditions.each do |predicate, object|
        if object.is_a?(Array)
          self.bind predicate
          self.filter "?#{predicate} in (#{object.map{|o| "\"#{o}\"" }.join(',')})"
        else
          @conditions[predicate] = object
        end
      end

      self
    end

    def filter(filter_string)
      @filters << filter_string
      self
    end

    def limit(max)
      @limit = max
      self
    end

    def offset(start)
      @offset = start
      self
    end

    def group(*group_by)
      @group += group_by.flatten
      self
    end

    def order(*order_by)
      @order += order_by.flatten
      self
    end

    def exists?
      self.form = :ask
      target.query self
    end

    def find(*primary_keys)
      if primary_keys.many?
        where(target.primary_key => primary_keys).all
      else
        where(target.primary_key => primary_keys.first).first
      end
    end

    def all
      target.query self
    end

    def first
      target.query(self).first
    end

    def count(counter = nil)
      if counter.nil?
        bindings << target.primary_key
        counter = "?#{target.primary_key}"
      end

      select("count(#{counter} as count)").first['count'].to_i
    end

    def to_sparql
      sparql = SPARQL::Client::Query.new form

      sparql.prefix ": <#{target.prefix}>"
      sparql.prefix "rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#>"
      sparql.prefix "rdfs: <http://www.w3.org/2000/01/rdf-schema#>"

      if @selects.any?
        sparql.select *@selects
      else
        sparql.select :_subject, :_predicate, :_object
        sparql.where  [:_subject, :_predicate, :_object]
      end

      sparql.where [:_subject, RDF.type, target.prefix[target.entity_type]]
      sparql.where *@conditions.map         {|(p,o)|  [:_subject, target.prefix[p], o] } if @conditions.any?
      sparql.where *@bindings.uniq.map      {|p|      [:_subject, target.prefix[p], p] } if @bindings.any?
      @optionals.uniq.each {|p| sparql.optional [:_subject, target.prefix[p], p] } if @optionals.any?

      @filters.each {|filter| sparql.filter filter}

      sparql.order *@order if @order.any?
      sparql.slice @offset, @limit

      sparql.to_s
    end

  end
end
