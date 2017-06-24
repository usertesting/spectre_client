require "spectre_client/version"
require "rest_client"

module SpectreClient
  class Client
    def initialize(project_name, suite_name, url_base, run_id: nil)
      @url_base = url_base
      payload = {
        project: project_name,
        suite: suite_name
      }
      payload.merge!(id: run_id) if run_id

      request = RestClient::Request.execute(
        method: :post,
        url: "#{@url_base}/runs",
        timeout: 120,
        payload: payload
      )
      response = JSON.parse(request.to_str)
      @run_id = response['id']
    end

    def submit_test(options = {})
      source_url =  options[:source_url] || ''
      fuzz_level =  options[:fuzz_level] || ''
      highlight_colour = options[:highlight_colour] || ''

      request = RestClient::Request.execute(
        method: :post,
        url: "#{@url_base}/tests",
        timeout: 120,
        multipart: true,
        payload: {
          test: {
            run_id: @run_id,
            name: options[:name],
            browser: options[:browser],
            size: options[:size],
            screenshot: options[:screenshot],
            source_url: source_url,
            fuzz_level: fuzz_level,
            highlight_colour: highlight_colour
          }
        }
      )
      JSON.parse(request.to_str, symbolize_names: true)
    end
  end
end
