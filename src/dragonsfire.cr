require "./dragonsfire/*"

require "http/client"
require "http/params"
require "random"
require "uri"

require "awscr-s3"

# TODO: Write documentation for `Dragonsfire`
module Dragonsfire
  # TODO: Put your code here
  class Dragonsfire
    @datastore = :file
    @file_storage = "./files"
    @ds_config = {
      :s3 => {
        :bucket_name       => "";
        :region            => "us-east1",
        :access_key_id     => "",
        :secret_access_key => "",
      }
    }
    def initialize(name : String)
      @name = name
    end

    def pre_store(file_name : String)
      new_name = "#{@file_storage}#{File::SEPARATOR}#{file_name}"
      if !Dir.exists? @file_storage
        puts "Creating dir #{@file_storage}"
        Dir.mkdir_p @file_storage
      end
      puts "Saving to #{new_name}..."
      new_name
    end

    def store(content, file_name : String)
      new_name = pre_store file_name
      out_file = File.new new_name, "w"
      out_file.puts content
      out_file.close
      Object.new file_name, new_name
    end

    def store(content : IO, file_name : String)
      new_name = pre_store file_name
      File.write(new_name, content)
      Object.new file_name, new_name
    end

    def fetch_url(url : String)
      file_name = self.uri_file_name url
      if file_name.empty?
        file_name = self.random_name
      end
      HTTP::Client.get(url) do |response|
        obj = store(response.body_io, file_name)
        return obj
      end
    end

    def uri_file_name(url : String)
      uri = URI.parse(url)
      p uri
      path = uri.path
      return "" if path.nil?
      parts = path.split /\//
      if parts.size > 0
        return parts[parts.size-1]
      end
      ""
    end

    def random_name
      rnd = Random.new
      rnd.hex(16)
    end

    def to_s
      "Dragonsfire: store: #{@name}"
    end
  end

  class Object
    def initialize(name : String, path : String)
      @name = name
      @path = path
    end

   def name
     @name
   end

   def path
     @path
   end
  end

  abstract class Store
    abstract def write
    abstract def read
    abstract def destroy
  end

  class S3Store < Store
    def initialize(config : Hash)
      @config = config
      if !@config.key? :url_host || !@config[:url_host].empty?
        @config[:url_host] = "#{@config[:bucket_name]}.s3.amazonaws.com"
      end
      if !@config.key? :url_scheme || !@config[:url_scheme].empty?
        @config[:url_scheme] = "http"
      end
      @client = nil
    end

    def connect
      if @client.nil?
        @client = Client.new(@config[:region], @config[:access_key_id], @config[:secret_access_key])
        p @client
      fi
    end

    def write(content : Object)
      self.connect
      p @client
      resp = @client.put_object(@config[:bucket], content.name, content.content)
      p resp
      p resp.etag
      resp.etag
    end

    def read(uid)
      self.connect
      p @client
      resp = @client.put_object(@config[:bucket], uid)
      p resp
      resp.body
    end

    def destroy(uid)
      self.connect
      p @client
      resp = @client.delete_object(@config[:bucket], uid)
      p resp
      resp
    end

    def url_for(uid)
      "#{@config[:url_scheme]}://#{@config[:bucket_name]}.#{@config[:url_host]}/#{uid}"
    end
  end
end
