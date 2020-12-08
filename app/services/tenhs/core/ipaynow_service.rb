# encoding: utf-8
## 现在支付公众号支付
class Tenhs::Core::IpaynowService

  ## 有两种方式:
  ## 1.未给定openid则使用返回的参数由前台POST到“https://pay.ipaynow.cn/”
  ## 2.给定openid则返回wxpay参数，由前台调用微信jsapi
  ## pay_param = {mhtOrderNo: "", mhtOrderName: "", mhtOrderAmt: "", mhtOrderDetail: "", notifyUrl: "", frontNotifyUrl: ""}
  def self.to_pay(pay_param, openid = nil)
    params = {
      appId: config[:web_id].to_s,
      funcode: "WP001",
      version: "1.0.0",
      mhtCurrencyType: "156",
      mhtOrderType: "01",
      mhtOrderStartTime: Time.current.strftime("%Y%m%d%H%M%S"),
      mhtCharset: "UTF-8",
      deviceType: "0600", # web支付
      outputType: "0",
      payChannelType: "13", # 12 支付宝  13 微信
      mhtSignType: "MD5",
      mhtLimitPay: "1",
    }.merge(pay_param)
    if openid.present?
      params[:mhtSubAppId] = config[:appid]
      params[:consumerId] = openid
      params[:outputType] = "1"
    end
    params[:mhtSignature] = sign(params)
    if openid.present?
      # {"funcode"=>"WP001", "signature"=>"29561bc041e6676356f4017f8160f190", "responseTime"=>"20201103181324", "mhtOrderNo"=>"2020110361310881", "appId"=>"160439410604744", "signType"=>"MD5", "nowPayOrderNo"=>"200414202011031813237944223", "tn"=>"timeStamp=1604398403&nonceStr=c779f67ec2d844e981f99f2223b6278a&prepay_id=wx03181323837665205bd8bc6efeb5490000&wxAppId=wx99d990c988de0249&paySign=dQTPXj3qxxPdvhl6EMnPTBPwHNRYmQmzCSGQUeHo+Ug6HhfemNGdvdDq0wXB7soOLrmY8W05+GQRhp8we9ljplq6f7VDn5FvrfgboX+NXHlRtB0couJV3GI1CIgyJ2jNzKEInGQopndBy4gxq5ykTUDQq7JokOH/YfN9/GACZ6aJBgCsjW/pHhIfBhsA04O7Ta0wr5y1SO628yImuRjt2MsXZvNKPJeU9jGByp3pJFqlgtwmQzGR4Tz6ltgg0xmERuI2KroOx2SSrrQlSbM0fYYpOBpL854aWkCwemVmkimJE1ETdrIgtl07/DWRXysdkutRKI9doMrLwu63pSy81A==&signType=RSA", "version"=>"1.0.0", "responseCode"=>"A001", "mhtSubMchId"=>"000000001573018", "responseMsg"=>"E000#成功[成功]"}
      ret = post(params) # 后台从现在支付获取微信参数后前台按照微信支付流程操作
      return Rack::Utils.parse_nested_query(ret["tn"])
    else
      return params # 由前台页面提交参数到现在支付
    end
  end

  ## 检查参数是否正确
  def self.verify(params)
    sig = params["signature"]
    params.delete("signature")
    sig.eql?(sign(params))
  end

  private

  def self.sign(params)
    sign_param = params.keys.sort.reduce("") do |param_string, key|
      value = params[key]
      is_empty_field = (value.nil? || value.strip.empty?)
      param_string << "#{key}=#{value}&" unless is_empty_field
      param_string
    end
    sign_param << md5(config[:web_key])
    Rails.logger.debug("待MD5签名字符串: #{sign_param}")
    ret = md5(sign_param)
    Rails.logger.debug("MD5签名结果: #{ret}")
    ret
  end

  def self.md5(value)
    Digest::MD5.new.update(value.encode("utf-8")).hexdigest
  end

  ## 发送请求，返回结果Hash
  def self.post(params)
    resp = Tenhs::Core::HttpService.post("pay.ipaynow.cn", "443", "/", URI.encode_www_form(params))
    ret = Rack::Utils.parse_nested_query(resp.body)
    Rails.logger.debug "接收到的参数： #{ret}"
    ret
  end

  private

  def self.config
    c = Rails.application.config.ipaynow
    return c.call if c.class.name == "Proc"
    c
  end
end
