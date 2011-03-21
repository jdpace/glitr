require 'cgi'
require 'csv'
require 'typhoeus'

module Glitr

  class Connection

    class MalformedResponseError < StandardError
      def initialize(response)
        super "Couldn't parse response: #{response}"
      end
    end

    attr_accessor :options

    def initialize(opts)
      self.options = default_options.merge(opts)
    end

    def fetch(query)
      csv = get_response(query_uri query)
      CSV.parse(csv, :headers => true)
    rescue CSV::MalformedCSVError => e
      raise MalformedResponseError.new(csv)
    end

    def fetch_subjects(query)
      response = fetch(query)
      subjectify(response)
    end

    def query_uri(query)
      escaped_query = CGI.escape(query.gsub(/\s+/, ' ').strip)
      uri  = "#{options[:protocol]}://"
      uri << "#{options[:host]}/#{options[:service]}"
      uri << "?output=csv&query=#{escaped_query}"
    end

    private

    def default_options
      {
        :host     => 'localhost',
        :port     => 2020,
        :protocol => 'http'
      }
    end

    def get_response(uri)
      Typhoeus::Request.get(uri, :timeout => 60_000).body
    end

    def subjectify(result)
      by_subject = result.group_by {|row| row['_subject'] }
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

  end

end
