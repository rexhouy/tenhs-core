# Tenhs::Core

## Usage

routes.rb:

```ruby
mount Tenhs::Core::Engine => "/core"
```

引入 css 控件

```erb
<%= stylesheet_link_tag 'tenhs/vendor' %>
```

includes:
[cropper,jquery-ui,jquery.datetimepicker,wangEditor]

引入 js 控件

```erb
<%= javascript_include_tag 'tenhs/core' %>
<%= javascript_include_tag 'tenhs/vendor' %>
```

includes:
core = [captcha, helper, impage_uploader, init, wangEditor, wysiwyg]
vendor = [cropper, jquery-ui, jquery.datetimepicker, mustache, popper]

wysiwyg 使用方法：

```html
<div class="form-group">
  <%=f.hidden_field :content%>
  <div class="wysiwyg" for="content"><%=@ad.content.html_safe if @ad.content.present? %></div>
</div>
```

图片上传使用方法：

```html
<img src="" id="preview" , onclick="image.open('#file_uploader_input')" />
<%=f.hidden_field :cover, class: "form-control", id: "cover"%>
<input type="file" id="file_uploader_input" style="visibility:hidden;" onchange="image.cropAndUpload('#cover', '#preview', '/core/images', width, height, radio)" />
<%=render "/tenhs/core/cropper" %>
```

```html
<img src="" id="preview" , onclick="image.open('#file_uploader_input')" />
<%=f.hidden_field :cover, class: "form-control", id: "cover"%>
<input type="file" id="file_uploader_input" style="visibility:hidden;" onchange="image.upload('#cover', '#preview', '/core/images', width, height)" />
```

验证码使用方法

```html
<button class="btn btn-default" type="button" onclick="window.captcha.cast(this, $('#admin_mobile').val())">获取验证码</button>
```

layouts 公用控件

```erb
<%=render "/tenhs/core/notice" %>
<%=render "/tenhs/core/ajax_modal" %>
```

Controller 引入

```ruby
include Tenhs::Core::Wechat
include Tenhs::Core::Common
```

wechat 提供的方法

```ruby
wechat_auth(config, scope = "snsapi_base")
wechat_userinfo(config) # 使用sns_userinfo时获取用户数据
wechat? # 客户端是否是wechat
```

common 提供的方法

```ruby
disable_cache ## 禁用缓存
render_404
new_instance_variables(names)
download_file(file_path, name)
set_download_header(name)
store_location(excepts = [])
```

Helper 引入

```ruby
include Tenhs::Core::ApplicationHelper
```

helper 提供的方法

```ruby
display_date(date)
display_date_short(date)
display_date_zh(date)
display_datetime_zh(date)
display_datetime(date)
display_time(date)
keep_secret(info)
page_info(obj)
search_field(name, value, text)
num_to_zh(num)
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tenhs-core'
```

And then execute:

```bash
$ bundle
```

Add migration

```bash
rake tenhs_core:install:migrations
```

Exec migration

```bash
rake db:migrate
```
