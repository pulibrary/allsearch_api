# frozen_string_literal: true

# This class is responsible for querying the Summon API, aka "Articles+"
class Summon
  include ActiveModel::API
  include Parsed
  attr_reader :query_terms, :service, :service_response, :access_id, :secret_key, :api_host, :api_path

  def initialize(query_terms:)
    @query_terms = query_terms
    @service = 'summon'
    @config = Rails.application.config_for(:allsearch)[:summon]
    # The access_id is the 'client short name' from Summon
    # ex. the shortname / access_id for 'test.summon.serialssolutions.com' is 'test'
    @access_id = @config[:access_id]
    # Basically the Summon API key - in LastPass vault
    @secret_key = @config[:secret_key]
    @api_host = @config[:api_host]
    @api_path = @config[:api_path]
    @service_response = summon_service_response(query_terms:)
  end

  def summon_service_response(query_terms:); end

  def id_string
    "#{accept_header_value}\\n#{summon_date}\\n#{api_host}\\n#{api_path}\\n#{query_string_for_constructed_id}\\n"
  end

  def digest
    OpenSSL::HMAC.base64digest('SHA1', secret_key, id_string)
  end

  def digest_from_gem
    Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('SHA1'), secret_key, id_string)).chomp.tap do |digest|
      # @log.debug {"ID: #{id.inspect}"}
      # @log.debug {"DIGEST: #{digest}\n"}
    end
  end

  # Should be application/json for final implementation
  def accept_header_value
    'application/xml'
  end

  # concatenated list of query parameters, unencoded, sorted in alphabetical order, and separated by ‘&’
  # For fuller implementation see https://github.com/summon/summon.rb/blob/master/lib/summon/transport/qstring.rb#L8-L21
  def query_string_for_constructed_id
    'ff=ContentType,or,1,15&q=forest'
  end

  def summon_date
    Time.now.httpdate
  end
end
