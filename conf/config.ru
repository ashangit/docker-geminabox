require "rubygems"
require "geminabox"

Geminabox.allow_replace = !!ENV['ALLOW_REPLACE']
Geminabox.data = '/data/geminabox/data'
Geminabox.build_legacy = false
Geminabox.rubygems_proxy = ENV['RUBYGEMS_PROXY']
Geminabox.allow_remote_failure = ENV['ALLOW_REMOTE_FAILURE']

$username = ENV['USERNAME']
$password = ENV['PASSWORD']

if $username && $password
    Geminabox::Server.helpers do
      def protected!
        unless authorized?
          response['WWW-Authenticate'] = %(Basic realm="Geminabox")
          halt 401, "No pushing or deleting without auth.\n"
        end
      end

      def authorized?
        @auth ||=  Rack::Auth::Basic::Request.new(request.env)
        @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [$username, $password]
      end
    end

    Geminabox::Server.before '/upload' do
      protected!
    end

    Geminabox::Server.before do
      protected! if request.delete?
    end

    Geminabox::Server.before '/api/v1/gems' do
      unless env['HTTP_AUTHORIZATION'] == 'API_KEY'
        halt 401, "Access Denied. Api_key invalid or missing.\n"
      end
    end

end

run Geminabox::Server