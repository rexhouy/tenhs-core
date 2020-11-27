# coding: utf-8
require "net/http"
require "json"
require "base64"
require "digest/md5"

class Tenhs::Core::SmsService
  # config: {auth_token: "", account_id: "", app_id: "", template_id: ""}
  def self.send_captcha(captcha, tel)
    if Rails.env.development?
      Rails.logger.info "CAPTCHA [#{captcha}] not send to #{tel} in development enviroment."
      return
    end
    Rails.logger.info "Send CAPTCHA(#{captcha}) to #{tel}"
    time = DateTime.current.strftime("%Y%m%d%H%M%S")
    sig = Digest::MD5.hexdigest(config[:account_id] + config[:auth_token] + timestamp)
    path = "/2013-12-26/Accounts/8a48b5514e3e5862014e4d8dbcfd0e32/SMS/TemplateSMS?sig=#{sig}"
    http = Net::HTTP.new("sandboxapp.cloopen.com", 8883)
    http.use_ssl = true
    http.set_debug_output(Rails.logger)
    req = Net::HTTP::Post.new(path)
    req.body = {
      "to": tel,
      "appId": config[:app_id],
      "templateId": config[:template_id],
      "datas": [captcha],
    }.to_json
    req["Accept"] = "application/json"
    req["Content-Type"] = "application/json;charset=utf-8"
    req["Authorization"] = Base64.urlsafe_encode64(config[:account_id] + ":" + timestamp)
    resp = http.request(req)
    Rails.logger.info "Send CAPTCHA response #{resp.inspect}"
  end

  def self.config
    c = Rails.application.config.sms
    return c.call if c.class.name == "Proc"
    c
  end
end
