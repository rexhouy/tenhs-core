# Tenhs::Core

## Usage

routes.rb:

```ruby
mount Xzqh::Engine => "/"
```

引入 js 控件

```erb
<%= javascript_include_tag 'tenhs/core' %>
<%= javascript_include_tag 'tenhs/vendor' %>
```

Controller 引入

```ruby
include Tenhs::Core::Wechat
include Tenhs::Core::Common
```

Helper 引入

```ruby
include Tenhs::Core::ApplicationHelper
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
