require 'cgi'
require 'bamfcsv'
require 'typhoeus'

module Glitr

  class Connection

    class MalformedResponseError < StandardError
      attr_reader :response

      def initialize(response)
        @response = response
        super "Couldn't parse response: #{@response.body}"
      end
    end

    attr_accessor :options

    def initialize(opts)
      self.options = default_options.merge(opts)
    end

    def fetch(query)
      response = get(query)
      csv_from(response)
    end

    def fetch_subjects(query)
      csv = fetch(query)
      subjectify(csv)
    end

    def get(query)
      uri = query_uri(query)
      response = Typhoeus::Request.get(uri, :timeout => 60_000)
      force_encoding_on(response)
      response
    end

    def csv_from(response)
      BAMFCSV.parse(response.body, :headers => true)
    rescue BAMFCSV::MalformedCSVError => e
      raise MalformedResponseError.new(response)
    end

    def query_uri(query)
      escaped_query = CGI.escape(query.gsub(/\s+/, ' ').strip)
      uri  = "#{options[:protocol]}://"
      uri << "#{options[:host]}:#{options[:port]}/#{options[:service]}"
      uri << "?output=csv&query=#{escaped_query}"
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

    private

    def default_options
      {
        :host     => 'localhost',
        :port     => 2020,
        :protocol => 'http'
      }
    end

    def force_encoding_on(response)
      response.body.force_encoding('UTF-8')
    end

  end

end
