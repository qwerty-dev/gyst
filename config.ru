# config.ru

require './app'
set :app_file, __FILE__

configure do
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET'] || 'A6d743'
end

run Sinatra::Application