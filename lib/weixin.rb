require 'digest/sha1'

class Weixin

    def initialize(app, app_token)
        @app = app
        @app_token = app_token
    end

    def call(env)
        @req = Rack::Request.new(env)
        return invalid_request! unless request_is_valid?
        return [
            200, 
            { 'Content-type' => 'text/html', 'Content-length' => @req.params['echostr'].length.to_s }, 
            [ @req.params['echostr'] ]
        ] if @req.get?
        status, headers, body = @app.call(env)
        [status, headers, body]
    end

    def invalid_request!
        [401, { 'Content-type' => 'text/html', 'Content-Length' => '0'}, []]
    end

    def request_is_valid?
        begin
            param_array = [@app_token, @req.params['timestamp'], @req.params['nonce']]
            sign = Digest::SHA1.hexdigest( param_array.sort.join )
            sign == @req.params['signature'] ? true : false
        rescue
            false
        end
    end

end
