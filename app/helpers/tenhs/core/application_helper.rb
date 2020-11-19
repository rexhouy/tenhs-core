# encoding: utf-8
module Tenhs
  module Core
    module ApplicationHelper
      def display_date(date)
        date.strftime("%Y-%m-%d") if date.present?
      end

      def display_date_short(date)
        date.strftime("%m-%d") if date.present?
      end

      def display_date_zh(date)
        date.strftime("%Y年%m月%d日") if date.present?
      end

      def display_datetime_zh(date)
        date.strftime("%Y年%m月%d日 %H:%M") if date.present?
      end

      def display_datetime(date)
        date.strftime("%Y-%m-%d %H:%M:%S") if date.present?
      end

      def display_time(date)
        date.strftime("%H:%M:%S") if date.present?
      end

      def keep_secret(info)
        return nil if info.nil?
        if info.size < 3 # 小于3位数不显示
          return "***"
        elsif info.size < 11 # 小于11位数只显示后3位
          return "****#{info[-3..-1]}"
        else # 显示前3位和后4位
          return info[0..2] + "*" * (info.size - 7) + info[-4..-1]
        end
      end

      def page_info(obj)
        total_pages = ((obj.total_entries - 1) / obj.per_page + 1).to_i
        %(<div class="page-info">当前第#{obj.current_page}页，总计#{total_pages}页，总记录数#{obj.total_entries}</div>).html_safe
      end

      def search_field(name, value, text)
        %( <label class="col-1 col-form-label">#{text}</label> <div class="col-3"><input type="text" name="#{name}" class="form-control" value="#{value}" autocomplete="off" id="search_#{name}"></div>).html_safe
      end

      def num_to_zh(num)
        ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十"][num]
      end
    end
  end
end
