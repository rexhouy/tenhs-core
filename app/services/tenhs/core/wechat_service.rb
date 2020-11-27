# encoding: utf-8
class Tenhs::Core::WechatService

  # 用户验证
  # 1. 重定向到验证页面
  def self.auth_url(request_url, scope = "snsapi_base")
    appid = get_appid(config)
    state = { redirect_url: request_url, appid: appid }.to_json
    params = {
      appid: appid,
      redirect_uri: "http://wechat.tenqsd.com/user",
      response_type: "code",
      scope: scope,
      state: Base64.encode64(state),
    }
    "https://open.weixin.qq.com/connect/oauth2/authorize?" << params.to_query << "#wechat_redirect"
  end

  # 用户验证
  # 获取用户信息(需scope为 snsapi_userinfo)
  def self.get_user_info(openid, access_token)
    http = Net::HTTP.new("wechat.tenqsd.com", 80)
    http.set_debug_output(Rails.logger)
    req = Net::HTTP::Get.new("/user/user_info?openid=#{openid}&access_token=#{access_token}&appid=#{get_appid(config)}")
    resp = http.request(req)
    Rails.logger.info "get user info response #{resp.body}"
    JSON.parse(resp.body)
  end

  # 发送模版消息
  # url消息链接， data消息模板数据
  def self.message(openid, template_id, url, data)
    http = Net::HTTP.new("wechat.tenqsd.com", 80)
    req = Net::HTTP::Post.new("/user/message")
    req.set_form_data ({
                        appid: get_appid(config),
                        openid: openid,
                        template_id: template_id,
                        url: url,
                        data: data.to_json,
                      })
    http.set_debug_output(Rails.logger)
    resp = http.request(req)
    Rails.logger.info "get user info response #{resp.body}"
    resp_json = JSON.parse(resp.body)
    [resp_json["errcode"].to_s.eql?("0"), resp_json]
  end

  ## 获取使用jsapi的token
  def self.jsapi(appid, url)
    ticket = Tenhs::Core::HttpService.get("wechat.tenqsd.com", 80, "/jsapi_ticket", {
      appid: appid,
    }, false)
    data = {
      noncestr: SecureRandom.hex(12),
      jsapi_ticket: ticket,
      timestamp: Time.current.to_i,
      url: url,
    }
    data[:signature] = Tenhs::Core::SignService.sha1(data)
    data[:appid] = appid
    data
  end

  private

  ## 如果是特约商户并且特约商户有自己的公众号，则使用特约商户的公众号信息
  def self.get_appid
    return config[:sub_appid] if config[:sub_appid].present?
    config[:appid]
  end

  def self.config
    c = Rails.application.config.wechat
    return c.call if c.class.name == "Proc"
    c
  end
end
