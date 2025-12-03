# frozen_string_literal: true

require 'forwardable'

class HealthcheckController
  extend Forwardable

  def self.call(env)
    new(env).response
  end

  def initialize(env)
    @env = env
  end

  def response
    [200, headers, [body]]
  end

  private

  attr_reader :env

  def_delegators :checklist, :results, :overall_health

  def headers
    if json_desired?
      { 'Content-Type' => 'application/json; charset=utf-8' }
    else
      {}
    end
  end

  def body
    json_desired? ? json_body : html_body
  end

  def json_body
    { results:, status: overall_health }.to_json
  end

  # rubocop:disable Metrics/MethodLength
  def html_body
    template = <<~END_TEMPLATE
      <html>
        <body>
          <table>
            <tr>
              <td scope="col">Service</td>
              <td scope="col">Status</td>
              <td scope="col">Message</td>
            </tr>
            <% results.each do |result| %>
              <tr>
                <td><%= result[:name] %></td>
                <td><%= result[:status] %></td>
                <td><%= result[:message] %></td>
              </tr>
            <% end %>
          </table>
        </body>
      </html>
    END_TEMPLATE
    ERB.new(template).result_with_hash(results:)
  end
  # rubocop:enable Metrics/MethodLength

  def json_desired?
    env['PATH_INFO'].end_with?('.json') || env['CONTENT_TYPE'] == 'application/json'
  end

  def checklist
    @checklist ||= CheckList.new(env)
  end
end
