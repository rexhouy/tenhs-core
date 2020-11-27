# encoding: utf-8
module Tenhs
  module Core
    module Wechat
      ## 1.重定向到微信授权页面 -> 2.微信授权后回调（http://wechat.tenqsd.com/user） -> 3.再次重定向回original_url
      def wechat_auth(scope = nil)
        session[:openid] = "123" if Rails.env.development? # 测试用

        # 第3步， 请求来自于wechat.tenqsd.com
        if params[:_state].present?
          state = JSON.parse Base64.decode64(params[:_state])
          if state["openid"].blank?
            Rails.logger.error "获取openid失败。#{state.inspect}"
            return redirect_to "/500.html"
          end
          session[:openid] = state["openid"]
          session[:access_token] = state["access_token"]
        end

        # 第1步，重定向到微信授权页面
        if session[:openid].blank?
          redirect_to Tenhs::Core::WechatService.auth_url(request.original_url, scope)
        end
      end

      ## 使用sns_userinfo时获取用户数据
      def wechat_userinfo(config)
        Tenhs::Core::WechatService.get_user_info(session[:openid], session[:access_token])
      end

      def wechat?
        return false if Rails.env.development?
        !(/micromessenger/ =~ request.user_agent.downcase).nil?
      end
    end
  end
end
