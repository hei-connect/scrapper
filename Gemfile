source 'https://rubygems.org'

ruby '1.9.3', :engine => 'jruby', :engine_version => '1.7.3'

gem 'rails', '3.2.13'
gem 'rails-api'
gem 'api_smith'
gem 'rocket_pants'
gem 'jruby-openssl'
gem 'activerecord-jdbc-adapter'

group :development do
  gem 'activerecord-jdbcsqlite3-adapter'
end

group :production do
  gem 'activerecord-jdbcpostgresql-adapter'
end

gem 'mechanize'

gem 'puma'

gem 'newrelic_rpm'
gem 'rocket_pants-rpm'
gem 'attr_encrypted'
gem 'airbrake_user_attributes'