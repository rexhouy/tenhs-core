# encoding: utf-8
require "securerandom"

class Tenhs::Core::CaptchaController < ActionController::Base
  protect_from_forgery with: :exception

  def create
    captcha = Captcha.find_by_mobile(params[:mobile])
    captcha ||= Captcha.new
    captcha.mobile = params[:mobile]
    captcha.token = SecureRandom.random_number(10 ** 6).to_s.rjust(6, "0")
    captcha.sent_at = DateTime.current + 10.minutes

    Tenhs::Core::SmsService.send_captcha(captcha.token, captcha.mobile, Rails.application.config.sms)

    captcha.save
    render json: { status: "ok" }
  end
end
