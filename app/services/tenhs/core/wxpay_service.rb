# coding: utf-8
### 1. JSAPI支付
### 2. 扫码支付
### 3. 付款码支付(POS机)
### 4. 交易结果查询
### 5. 订单退款
### 6. 后台通知校验
## config = {appid: "", mchid: "", api_secret: "", sub_mchid: "子商户号", sub_appid: "子商户公众号"}
class Tenhs::Core::WxpayService

  # 1. JSAPI支付
  # pay_param = {body: "", detail: "", out_trade_no: "", total_fee: "",spbill_create_ip: "", notify_url: ""}
  def self.pay(pay_param, openid)
    ret = get_prepay_id(pay_param, openid)
    jsapi_params = {
      appId: config[:appid],
      timeStamp: Time.current.to_i,
      nonceStr: Random::DEFAULT.rand(10 ** 16),
      package: "prepay_id=#{ret[:prepay_id]}",
      signType: "MD5",
    }
    jsapi_params[:paySign] = Tenhs::Core::SignService.sign(jsapi_params, config[:api_secret]).upcase
    Rails.logger.debug "JSAPI params: #{jsapi_params}"
    jsapi_params
  end

  # 2. 扫码支付
  # pay_param = {body: "", detail: "", out_trade_no: "", total_fee: "",spbill_create_ip: "", notify_url: ""}
  def self.scan(pay_param, openid)
    ret = get_prepay_id(pay_param, openid, "NATIVE")
    ret[:code_url]
  end

  # 3. 付款码支付(POS机)
  # pay_param = {body: "", detail: "", out_trade_no: "", total_fee: "",spbill_create_ip: ""}
  def self.micropay(pay_param, code)
    params = {
      appid: config[:appid],
      mch_id: config[:mchid],
      nonce_str: Random::DEFAULT.rand(10 ** 16).to_s,
      auth_code: code,
    }.merge(pay_param)
    params[:sub_mch_id] = config[:sub_mchid] if config[:sub_mchid].present? # 特约商户
    params[:sign] = Tenhs::Core::SignService.sign(params, config[:api_secret]).upcase
    xml_params = params.to_xml(root: "xml", dasherize: false)
    Rails.logger.debug "micropay request params: #{xml_params}"
    resp = Tenhs::Core::HttpService.post("api.mch.weixin.qq.com", "443", "/pay/micropay", xml_params)
    Rails.logger.debug "Get prepay id response: #{resp.body}"
    Hash.from_xml(resp.body.gsub("\n", ""))
  end

  # 4. 交易结果查询
  def self.query(out_trade_no)
    params = {
      appid: config[:appid],
      mch_id: config[:mchid],
      out_trade_no: out_trade_no,
      nonce_str: Random::DEFAULT.rand(10 ** 16).to_s,
    }
    params[:sub_mch_id] = config[:sub_mchid] if config[:sub_mchid].present? # 特约商户
    params[:sign] = Tenhs::Core::SignService.sign(params, config[:api_secret]).upcase
    xml_params = params.to_xml(root: "xml", dasherize: false)
    Rails.logger.debug "Prepay request params: #{xml_params}"
    resp = Tenhs::Core::HttpService.post("api.mch.weixin.qq.com", "443", "/pay/orderquery", xml_params)
    Hash.from_xml(resp.body.gsub("\n", ""))
  end

  # 5. 订单退款
  # refund_param = {transaction_id: "", out_refund_no: "", total_fee: "", refund_fee: "",notify_url: ""}
  def self.refund(refund_param)
    key = File.read(Rails.root.join("config", "wxpaykey.pem"))
    cert = File.read(Rails.root.join("config", "wxpaycert.pem"))

    params = {
      appid: config[:appid],
      mch_id: config[:mchid],
      nonce_str: Random::DEFAULT.rand(10 ** 16).to_s,
    }.merge(refund_param)
    params[:sign] = Tenhs::Core::SignService.sign(params, config[:api_secret]).upcase

    Rails.logger.debug "Refund request params: #{params}"
    xml_params = params.to_xml(root: "xml", dasherize: false)

    resp = Tenhs::Core::HttpService.secure_post_xml(cert, key, config[:mchid], "", xml_params)
    Hash.from_xml(resp.gsub("\n", ""))
  end

  # 6. 后台通知校验
  def self.verify(notify_params)
    Tenhs::Core::SignService.verify(notify_params, config[:api_secret])
  end

  # 7. 企业付款
  # t_params = {openid: "", amount: "", desc: "企业付款备注", partner_trade_no: "商户订单号"}
  def self.transfer(t_params)
    key = File.read(Rails.root.join("config", "wxpaykey.pem"))
    cert = File.read(Rails.root.join("config", "wxpaycert.pem"))
    params = {
      mch_appid: config[:appid].to_s, #公众账号appid
      mchid: config[:mchid].to_s, #商户号
      nonce_str: Random::DEFAULT.rand(10 ** 16).to_s, #随机字符串
      check_name: "NO_CHECK", #校验用户姓名选项
    }.merge(t_params)
    params[:sign] = Tenhs::Core::SignService.sign(params, config[:api_secret]).upcase
    Rails.logger.debug "Refund request params: #{params}"
    xml_params = params.to_xml(root: "xml", dasherize: false)
    resp = Tenhs::Core::HttpService.secure_post_xml(cert, key, config[:mchid], "https://api.mch.weixin.qq.com/mmpaymkttransfers/promotion/transfers", xml_params)
    Hash.from_xml(resp.gsub("\n", ""))
  end

  # 8. 发放红包
  # r_params = {re_openid: "", send_name: "商户名称", total_amount: "", wishing: "红包祝福语", act_name: "活动名称", mch_billno: "订单号"}
  def self.red_pack(r_params)
    key = File.read(Rails.root.join("config", "wxpaykey.pem"))
    cert = File.read(Rails.root.join("config", "wxpaycert.pem"))
    params = {
      wxappid: config[:appid].to_s, #公众账号appid
      mch_id: config[:mchid].to_s, #商户号
      nonce_str: Random::DEFAULT.rand(10 ** 16).to_s, #随机字符串
      total_num: "1", #红包数量
      client_ip: Rails.application.config.server_ip,
    }.merge(r_params)
    params[:sign] = Tenhs::Core::SignService.sign(params, config[:api_secret]).upcase
    Rails.logger.debug "Refund request params: #{params}"
    xml_params = params.to_xml(root: "xml", dasherize: false)
    resp = Tenhs::Core::HttpService.secure_post_xml(cert, key, config[:mchid], "https://api.mch.weixin.qq.com/mmpaymkttransfers/sendredpack", xml_params)
    Hash.from_xml(resp.gsub("\n", ""))
  end

  private

  def self.get_prepay_id(pay_param, open_id, trade_type = "JSAPI")
    params = prepay_param(pay_param, open_id, trade_type)
    resp = Tenhs::Core::HttpService.post("api.mch.weixin.qq.com", "443", "/pay/unifiedorder", params)
    Rails.logger.debug "Get prepay id response: #{resp.body}"
    resp_xml = Hash.from_xml(resp.body.gsub("\n", ""))
    if "SUCCESS".eql? resp_xml["xml"]["return_code"].upcase
      {
        prepay_id: resp_xml["xml"]["prepay_id"],
        code_url: resp_xml["xml"]["code_url"],
      }
    else
      nil
    end
  end

  def self.prepay_param(pay_param, open_id, trade_type)
    params = {
      appid: config[:appid],
      mch_id: config[:mchid],
      nonce_str: Random::DEFAULT.rand(10 ** 16).to_s,
      trade_type: trade_type,
    }.merge(pay_param)
    # 以下分为（特约商户 | 普通商户）两种，其中特约商户还分为有自己的公众号与没有个两种情况
    if config[:sub_mchid].present? # 特约商户
      params[:sub_mch_id] = config[:sub_mchid] # 特约商户自己的id
      if config[:sub_appid].present? # 特约商户有自己的公众号
        params[:sub_appid] = config[:sub_appid] # 特约商户公众号appid
        params[:sub_openid] = open_id # 特约商户公众号的openid
      else
        params[:openid] = open_id
      end
    else # 普通商户
      params[:openid] = open_id
    end
    params[:sign] = Tenhs::Core::SignService.sign(params, config[:api_secret]).upcase
    Rails.logger.debug "Prepay request params: #{params}"
    params.to_xml(root: "xml", dasherize: false)
  end

  private

  def self.config
    c = Rails.application.config.wechat
    return c.call if c.class.name == "Proc"
    c
  end
end
