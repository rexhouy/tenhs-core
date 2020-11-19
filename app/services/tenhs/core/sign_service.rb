# coding: utf-8
## 微信方式签名
class Tenhs::Core::SignService
  def self.sign(params, partner_secret = nil)
    sign_param = params.keys.sort.reduce("") do |param_string, key|
      value = params[key]
      is_empty_field = (value.nil? or (value.is_a?(String) and value.strip.empty?))
      param_string << "#{key}=#{value}&" unless is_empty_field
      param_string
    end
    sign_param << "key=" << partner_secret if partner_secret.present?
    Rails.logger.debug "Sign param: #{sign_param}"
    value = md5(sign_param)
    Rails.logger.debug "Signature: #{value}"
    value
  end

  def self.verify(params, secret)
    sign = params["sign"]
    params.delete("sign")
    sign(params, secret).upcase.eql?(sign.upcase)
  end

  def self.ruan_yun_sign(params, key)
    sign_param = params.keys.sort.reduce("") do |param_string, k|
      value = params[k]
      is_array = value.kind_of?(Array)
      is_empty_field = (value.nil? or (value.is_a?(String) and value.strip.empty?))
      param_string << "#{k.downcase}=#{value}&" if (!is_array && !is_empty_field)
      param_string
    end
    sign_param << "key=" << key
    Rails.logger.debug "Sign param: #{sign_param}"
    value = md5(sign_param)
    Rails.logger.debug "Signature: #{value}"
    value.upcase
  end

  def self.sha1(params)
    s = Digest::SHA1.new
    sign_param = CGI.unescape(params.to_query)
    s.update sign_param
    Rails.logger.debug "Sign param: #{sign_param}"
    value = s.hexdigest
    Rails.logger.debug "Signature: #{value}"
    value
  end

  private

  def self.md5(value)
    Digest::MD5.new.update(value.encode("utf-8")).hexdigest
  end
end
