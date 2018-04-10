require "./store"

require "json"

require "awscr-s3"

module Dragonsfire

  class S3Store < Store
    def initialize(config : Hash(Symbol, String))
      @config = config
      self.init
    end

    def init
      if !@config.key? :url_host || !@config[:url_host].empty?
        @config[:url_host] = "#{@config[:bucket_name]}.s3.amazonaws.com"
      end
      if !@config.key? :url_scheme || !@config[:url_scheme].empty?
        @config[:url_scheme] = "http"
      end
      endpoint = @config[:endpoint]
      endpoint = nil if endpoint.empty?
      @client = Awscr::S3::Client.new(@config[:region], @config[:access_key_id], @config[:secret_access_key], endpoint)
      p @client
      # TODO conditional
      self.create_bucket
    end

    def create_bucket
      begin
        p "Creating bucket #{@config[:bucket_name]}..."
        resp = @client.not_nil!.put_bucket @config[:bucket_name]
        p resp
        true
      rescue 
        false
      end
    end

    # TODO semantics wrong, name vs uid
    def url_for(uid)
      "#{@config[:url_scheme]}://#{@config[:bucket_name]}.#{@config[:url_host]}/#{uid}"
    end

    def write(content : Content)
      resp = @client.not_nil!.put_object(@config[:bucket_name], content.name, content.data)
      p resp
      p resp.etag
      rv = JSON.parse(resp.etag).as_s
      p rv
      rv
    end

    def read(uid)
      begin
        p "Reading: #{@config[:bucket_name]}/#{uid}"
        resp = @client.not_nil!.get_object(@config[:bucket_name], uid)
        p resp
        [resp.body, {} of String => String]
      rescue
        nil
      end
    end

    def destroy(uid)
      resp = @client.not_nil!.delete_object(@config[:bucket_name], uid)
      p resp
      resp
    end
  end

end
