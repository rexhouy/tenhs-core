# encoding: utf-8
module Tenhs
  module Core
    module Wechat
      ## 1.重定向到微信授权页面 -> 2.微信授权后回调（http://wechat.tenqsd.com/user） -> 3.再次重定向回original_url
      def wechat_auth(scope = "snsapi_base")
        if Rails.env.development? # 测试用
          session[:openid] = "123"
          session[:openid_created_at] = Time.current.to_i
        end

        # 第3步， 请求来自于wechat.tenqsd.com
        if params[:_state].present?
          state = JSON.parse Base64.decode64(params[:_state])
          if state["openid"].blank?
            Rails.logger.error "获取openid失败。#{state.inspect}"
            return redirect_to "/500.html"
          end
          session[:openid] = state["openid"]
          session[:access_token] = state["access_token"]
          session[:openid_created_at] = Time.current.to_i
        end

        # 检查session是否过期
        expire_session_before = Rails.application.config.expire_session_before
        openid_created_at = session[:openid_created_at]
        timeout = openid_created_at.blank? || (expire_session_before.present? && (openid_created_at.to_i < expire_session_before.to_i))
        Rails.logger.info "Session timeout reset openid" if timeout

        # 第1步，重定向到微信授权页面
        if session[:openid].blank? || timeout
          redirect_to Tenhs::Core::WechatService.auth_url(request.original_url, scope)
        end
      end

      ## 使用sns_userinfo时获取用户数据
      def wechat_userinfo
        Tenhs::Core::WechatService.get_user_info(session[:openid], session[:access_token])
      end

      def wechat?
        return false if Rails.env.development?
        request.user_agent.downcase.include?("micromessenger")
      end
    end
  end
end
