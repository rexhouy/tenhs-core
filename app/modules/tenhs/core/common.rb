# encoding: utf-8
module Tenhs
  module Core
    module Common
      ## 禁用缓存
      def disable_cache
        response.headers["Cache-Control"] = "no-cache, no-store"
        response.headers["Pragma"] = "no-cache"
        response.headers["Expires"] = "Mon, 01 Jan 1990 00:00:00 GMT"
      end

      def render_404
        raise ActionController::RoutingError.new("Not Found")
      end

      def new_instance_variables(names)
        names.each do |n|
          eval "@#{n} = params[:#{n}]"
        end
      end

      def download_file(file_path, name)
        send_file file_path, disposition: %(attachment; filename="#{URI.escape(name)}"; filename*=utf-8''#{URI.escape(name)})
      end

      def set_download_header(name)
        response.headers["Content-disposition"] = %(attachment; filename="#{URI.escape(name)}"; filename*=utf-8''#{URI.escape(name)})
        response.headers["Pragma"] = "no-cache"
        response.headers["Content-Type"] = "application/vnd.ms-excel; charset=UTF-8"
      end

      def store_location(excepts = [])
        return if excepts.include?(controller_name) # 从新窗口弹出的页面不记录
        session[:back_path] = request.fullpath if request.format.html? && ["index", "show"].include?(action_name)
      end
    end
  end
end
