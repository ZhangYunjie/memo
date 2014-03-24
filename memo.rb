rails new myapp -d postgresql --skip-bundle

# .gitignore 修正

git init
git add -A
git commit -m "some commetn"

# config/database.yml 修正
https://github.com/AchillesSatan/setty

heroku create myapp
git push heroku master
heroku run rake db:migrate
heroku run console

# mem_cache 
  brew install memcached
  /usr/local/opt/memcached/bin/memcached
  #Gemfile
    # gem 'memcachier'
    gem 'rack-cache'
    gem 'dalli'
    # gem 'kgio'

  # application.rb
    config.cache_store = :dalli_store
    config.cache_store = :dalli_store, 'cache-1.example.com', 'cache-2.example.com', { :namespace => NAME_OF_RAILS_APP, :expires_in => 1.day, :compress => true }

    config.time_zone = 'Tokyo'

    config.i18n.default_locale = :ja

    config.i18n.load_path += Dir[Rails.root.join('config/locales', '*', '*.yml').to_s]

  # 创建 config/locales/ja.yml

  # session_store.rb //memcachier的情况下不要
    params = {
      key: "_myapp_session",
      cookie_only: false,
      timeout: 1.5,
      memcache_server: Setty.base.session_memcache_server,
      expire_after: 1.hour
      namespace: "myapp-#{Rails.env}"
    }
    MyApp::Application.config.session_store ActionDispatch::Session::CacheStore
    MyApp::Application.config.session_options = params

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# 调整自动加载路径
  config.autoload_paths += Dir["#{config.root}/lib/autoloads/**/"]
  config.autoload_paths += Dir["#config.root}/lib/workers/**/"]

# routes路径
  config.paths["config/routes.rb"].concat(Dir[Rails.root.join("config/routes/*.rb")])

# 数据库注释生成工具
  gem 'annotate'
  $ bundle exec annotate -i -p before -e tests,fixtures

# 使用redis
  # Gemfile
    gem 'redis'
    gem 'redis-objects'
  heroku addons:add redistogo
  # config/environments/development.rb
  ENV["REDISTOGO_URL"] = 'redis://username:password@my.host:6389'
  # config/initializers/redis.rb
    uri = URI.parse(ENV("REDISTOGO_URL"))
    REDIS = Redis.new(:url => ENV['REDISTOGO_URL'])
  # test in the console
    rails console
    >> REDIS.set("foo", "bar")
    "OK"
    >> REDIS.get("foo")
    "bar"

# 使用unicorn
  # Gemfile
    gem 'unicorn'

  # config/unicorn.rb
    # If you have a very small app you may be able to
    # increase this, but in general 3 workers seems to
    # work best
    worker_processes 3

    # Load your app into the master before forking
    # workers for super-fast worker spawn times
    preload_app true

    # Immediately restart any workers that
    # haven't responded within 30 seconds
    timeout 30

    before_fork do |server, worker|
      Signal.trap 'TERM' do
        puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
        Process.kill 'QUIT', Process.pid
      end

      defined?(ActiveRecord::Base) and
        ActiveRecord::Base.connection.disconnect!
    end

    after_fork do |server, worker|
      Signal.trap 'TERM' do
        puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
      end

      defined?(ActiveRecord::Base) and
        ActiveRecord::Base.establish_connection
    end

  # 加入Procfile
    bundle exec unicorn -p $PORT -c ./config/unicorn.rb

  # unicorn_rails -c config/unicorn.rb -p 3000 

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# 使用 New Relic
  heroku addons:add newrelic:stark

  # Gemfile
  gem 'newrelic_rpm'

  curl https://gist.githubusercontent.com/rwdaigle/2253296/raw/newrelic.yml > config/newrelic.yml

  heroku config:set NEW_RELIC_APP_NAME="YOUR APP NAME GOES HERE"

  configure :production do
    require 'newrelic_rpm'
  end

  heroku config:set RACK_ENV=production
  git commit -m "Added New Relic Plugin"
  git push heroku master

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# 使用asset_sync
  # Gemfile
    gem "asset_sync"

  bundle install
  # heroku 环境变量设定
  heroku config:add FOG_PROVIDER=AWS
  heroku config:add AWS_ACCESS_LEY_ID=xxx
  heroku config:add AWS_SECRET_ACCESS_KEY=yyy
  heroku config:add FOG_DIRECTORY=myappname-assets

  # config/environments/production.rb
  config.action_controller.asset_host = "https://#{ENV['FOG_DIRECTORY']}.s3.amazonaws.com"

  # asset_sync 设定变更
  rails g asset_sync:install --provider=AWS

  # /config/initializer/asset_sync.rb
  config.fog_region = 'ap-northeast-1'

  #eg
  if defined?(AssetSync)
    AssetSync.configure do |config|
      config.fog_provider = 'AWS'
      config.aws_access_key_id = ENV['AWS_ACCESS_KEY_ID']
      config.aws_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
      config.fog_directory = ENV['FOG_DIRECTORY']

      # Increase upload performance by configuring your region
      config.fog_region = 'ap-northeast-1'
      #
      # Don't delete files from the store
      # config.existing_remote_files = "keep" ?
      #
      # Automatically replace files with their equivalent gzip compressed version
      # config.gzip_compression = true ?
      #
      # Use the Rails generated 'manifest.yml' file to produce the list of files to 
      # upload instead of searching the assets directory.
      # config.manifest = true
      #
      # Fail silently.  Useful for environments such as Heroku
      # config.fail_silently = true
    end
  end

  # .zshenv 或者 .env
    export AWS_ACCESS_KEY_ID=xxx
    export AWS_SECRET_ACCESS_KEY=yyy
    export FOG_DIRECTORY=myappname-assets
  rake assets:precompile

  # .slugignore
    /spec
    /app/assets
    *.jpg
    *.png
    *.png
    *.mp3
    *.ogg

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# 高速自动化测试
  # Gemfile
  group :developemnt, :test do
    gem 'rspec'
    gem 'rspec-rails'
    gem 'spork', '1.0.0rc3'
    gem 'guard'
    gem 'guard-spork'
    gem 'guard-rspec'
    gem 'rb-fsevent'
    gem 'growl'
    gem 'factory_girl_rails'
  end

  bundle install
  spork --bootstrap
  # spec/spec_helper.rb

  spork
  # .rspec
    --colour
    --drb

  guard init spork
  guard init rspec

  # Guardfile
    # More info at https://github.com/guard/guard#readme
    guard 'spork' do
      watch('config/application.rb')
      watch('config/environment.rb')
      watch('config/environments/test.rb')
      watch(%r{^config/initializers/.+\.rb$})
      #watch('Gemfile')
      watch('Gemfile.lock')
      watch('spec/spec_helper.rb') { :spec }
      watch(%r{^spec/support/(.+)\.rb$})
      watch(%r{^spec/factories/(.+)\.rb$})
    end

    guard 'rspec', cli: '--drb' do
      watch(%r{^spec/.+_spec\.rb$})
      watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
      watch('spec/spec_helper.rb')  { "spec" }

      # Rails example
      watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
      watch(%r{^app/models/(.+)/(.+)\.rb$})               { |m| "spec/models/#{m[1]}_spec.rb" }
      watch(%r{^app/(.*)(\.erb|\.haml)$})                 { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
      watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/acceptance/#{m[1]}_spec.rb"] }
      #watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
      watch('app/controllers/application_controller.rb')  { "spec/controllers" }

      # Capybara features specs
      watch(%r{^app/views/(.+)/.*\.(erb|haml)$})          { |m| "spec/features/#{m[1]}_spec.rb" }

      # Turnip features and steps
      watch(%r{^spec/acceptance/(.+)\.feature$})
      watch(%r{^spec/acceptance/steps/(.+)_steps\.rb$})   { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'spec/acceptance' }
    end

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
＃ 在heroku上建立active_admin

# ? Install Heroku add-ons
  heroku addons:add custom_domains --remote prod
  heroku domains:add example.com --remote prod
  heroku addons:add pgbackups --remote prod
  heroku addons:upgrade pgbackups:auto-month --remote prod
  heroku addons:add sendgrid:starter --remote prod
  heroku run rake db:migrate -- remote prod

# active_admin
  # config/environments/developments.rb
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  # config/environments/production.rb
  config.action_mailer.default_url_options = { :host => 'domain.of.site.com' }

# config/initializers/mail.rb
  ActionMailer::Base.smtp_settings = {
    :address => 'smtp.sendgrid.net',
    :port => '587'
    :authentication => :plain,
    :user_name => ENV['SENDGRID_USERNAME'],
    :password => ENV['SEND_PASSWORD'],
    :domain => 'heroku.com'
  }
  ActionMailer::Base.delivery_method = :smtp

# 生成ActiveAdmin
  rails generate active_admin:resource AdminUser

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

gem 'devise', github: 'plataformatec/devise', branch: :rails4 
gem 'devise_ldap_authenticatable' # ?不用

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# ? 使用active_admin & devise
  # Gemfile
    gem 'activeadmin'
    gem 'sass-rails'
    gem 'meta_search', '>=1.1.0.pre'

    gem 'devise', '~>2.0.0'

  bundle install

  rails generate active_admin:install

  rails generate devise:install
  rails generate devise username
  rails generate migration AddSuperadminToUser
    # eg
      class AddSuperadminToUser < ActiveRecord::Migration
        def up
          add_column :users, :superadmin, :boolean, :null => false, :default => false

          User.create! do |r|
            r.email      = 'default@example.com'
            r.password   = 'password'
            r.superadmin = true
          end
        end

        def down
          remove_column :users, :superadmin
          User.find_by_email('default@example.com').try(:delete)
        end
      end

  # /app/models/user.rb
  class User < ActiveRecord::Base
    devise :database_authernticatable, :recoverable, :rememberable, :trackable, :validatable
    attr_accessible :email, :password, :password_confirmation, :remember_me
  end

  # config/initializers/active_admin.rb
    config.authentication_method = :authenticate_active_admin_user!
    config.current_user_method = :current_user
    config.logout_link_path = :destroy_user_session_path
    config.logout_link_method = :delete

  # ApplicationController
    def authenticate_active_admin_user!
      authenticate_user!
      unless current_user.superadmin?
        flash[:alert] = "Unauthorized Access"
          redirect_to root_path
        end
      end
    end

  # clean up the ActiveAdmin
  rails destroy model AdminUser
  rm ./db/migrate/*_devise_create_admin_users.rb

  # _create_admin_notes.rb
  # _move/admin_notes_to_comments.rb
  # replace :admin_user to :user

  # route.rb
  # delete: devise_for :admin_users, ActiveAdmin::Devise.config

  # app/admin/user.rb
    ActiveAdmin.register User do

      form do |f|
        f.inputs "User Details" do
          f.input :email
          f.input :password
          f.input :password_confirmation
          f.input :superadmin, :label => "Super Administrator"
        end
        f.buttons
      end

      create_or_edit = Proc.new {
        @user            = User.find_or_create_by_id(params[:id])
        @user.superadmin = params[:user][:superadmin]
        @user.attributes = params[:user].delete_if do |k, v|
          (k == "superadmin") ||
          (["password", "password_confirmation"].include?(k) && v.empty? && !@user.new_record?)
        end
        if @user.save
          redirect_to :action => :show, :id => @user.id
        else
          render active_admin_template((@user.new_record? ? 'new' : 'edit') + '.html.erb')
        end
      }
      member_action :create, :method => :post, &create_or_edit
      member_action :update, :method => :put, &create_or_edit

    end

  rake db:migrate

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# 将active_admin加入预编译
  # config/application.rb
    config.assets.enabled = true

    config.assets.initialize_on_precompile = false

    config.assets.precompile += %w(active_admin.css active_admin/print.css active_admin.js)

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# 使用slim
gem 'slim-rails'

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

gem 'sass-rails'
gem 'bootstrap-sass'

# application.js
  //= require bootstrap

# application.css
  *= require bootstrap
# application.css => application.css.scss
  @import "bootstrap"

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# 使用富文本编辑
  # kindeditor
  # mini_magick
  # carriewave

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# 生成表的关系图
# Gemfile 
  gem 'rails-erd'

rake rails-erd
open erd.pdf

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# 使用pry调试程序
# Gemfile
  gem 'pry'

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# view
= safe_render(inline: @info.content)

# Application spec_helper
  # renderするけど、エラーが出たら何も出力しない
  def safe_render(options = {}, locals = {}, &block)
    begin
      render options, locals, &block
    rescue => exception
      Raven.capture_exception(exception)
      logger.info exception.inspect
      logger.info exception.backtrace.grep(/^((?!\/gems\/).)*$/).join("\n")
      nil
    end
  end

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

http://tabelog.com/tokyo/A1316/A131601/13051024/
http://tabelog.com/tokyo/A1316/A131601/13029317/　藏居酒屋
http://tabelog.com/tokyo/A1316/A131601/13150748/dtlmap/?lid=tocoupon2

[2014/03/24 19:25:02] Yunjie Zhang: 皆様へ：
[2014/03/24 19:25:39] Yunjie Zhang: 今週の飲み会にかんして、何か嫌いなものがありませんか。
[2014/03/24 19:27:12] Tomofusa KAWAKAMI: 私はありません！
木元さんは、肉々しいものはNGですね。
[2014/03/24 19:27:35] ryogo yamasaki: 焼いたレバーが嫌いです。
[2014/03/24 19:27:45] M.Kimoto: あ、そうです、肉だけしか無いという事が無ければ大丈夫です
[2014/03/24 19:28:07] Yunjie Zhang: はい〜承知致しました。
[2014/03/24 19:28:12] Yunjie Zhang: ありがとうございました！
[2014/03/24 19:28:24] M.Kimoto: お手数をおかけします