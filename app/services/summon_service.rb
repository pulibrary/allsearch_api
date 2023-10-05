# frozen_string_literal: true

# This class is responsible for communicating with
# the summon server
class SummonService
  def initialize(query_terms:)
    @config = Rails.application.config_for(:allsearch)[:summon]
    @query_terms = query_terms
  end

  def summon_service_response
    

    uri = URI::HTTPS.build(host: @config[:url], path: @config[:path], query: query_string)
    response = Net::HTTP.get(uri, headers_with_auth)
    byebug
    JSON.parse(response, symbolize_names: true)
  end

  def auth_token
    hash = OpenSSL::HMAC.base64digest('SHA1', @config[:key], data)
    "Summon #{@config[:app_id]};#{hash}"
  end

  def data
    params = []
    headers.each do |key, value|
      params.push("#{value}\n")
    end
    params.push("#{@config[:url]}\n")
    params.push("#{@config[:path]}\n")
    params.push("#{CGI.unescape(query_string)}\n")
    params.join
  end

  # query params must be in alphabetical order
  def query_string
    "s.dailyCatalog=t&s.fvf=ContentType%2CNewspaper+Article%2Ct&s.ho=t&s.normalized.subjects=f&s.ps=3&s.q=#{CGI.escape(@query_terms)}&s.rapido=f&s.role=authenticated&s.secure=t&s.shortenurl=f"
  end

  def date_time
    @date_time ||= Time.zone.now.strftime('%a, %d %b %Y %H:%M:%S %Z')
  end

  def headers
    {
      Accept: 'application/json',
      'x-summon-date': date_time,
    }
  end

  def headers_with_auth
    {
      Host: @config[:url],
      Accept: 'application/json',
      'x-summon-date': date_time,
      Authorization: auth_token
    }
  end
end
