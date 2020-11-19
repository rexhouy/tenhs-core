# encoding: utf-8
require "net/http"
require "json"
require "base64"
require "digest/md5"

class Tenhs::Core::HttpService
  def self.post(host, port, path, params, ssl = true)
    http = Net::HTTP.new(host, port)
    http.use_ssl = ssl
    http.set_debug_output(Rails.logger)
    req = Net::HTTP::Post.new(path)
    req.body = params
    resp = http.request(req)
    Rails.logger.debug "Query payment response: #{resp.body}"
    resp
  end

  def self.post_json(host, port, path, params, ssl = true)
    http = Net::HTTP.new(host, port)
    http.use_ssl = ssl
    http.set_debug_output(Rails.logger)
    req = Net::HTTP::Post.new(path, "Content-Type" => "application/json")
    req.body = params.to_json
    resp = http.request(req)
    Rails.logger.debug "Query payment response: #{resp.body}"
    resp
  end

  def self.get(host, port, path, params, ssl = true)
    http = Net::HTTP.new(host, port)
    http.use_ssl = ssl
    http.set_debug_output(Rails.logger)
    req = Net::HTTP::Get.new("#{path}?#{params.to_query}")
    resp = http.request(req)
    Rails.logger.debug "Http get response #{resp.body}"
    resp.body
  end
end
