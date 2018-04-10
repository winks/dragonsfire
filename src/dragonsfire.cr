require "./dragonsfire/*"
require "./dragonsfire/storage/*"

require "http/client"
require "http/params"
require "random"
require "uri"

require "awscr-s3"

module Dragonsfire

  class Dragonsfire
    @datastore_type = :file
    @ds_config = {
      :file => {
        :root_path   => "./files",
        :server_root => "files",
      },
      :s3 => {
        :bucket_name       => "",
        :region            => "",
        :endpoint          => "",
        :access_key_id     => "",
        :secret_access_key => "",
      }
    }
    getter datastore

    def initialize(datastore = :file)
      if datastore == :s3
        @datastore_type = :s3
        @datastore = S3Store.new @ds_config[:s3]
      elsif datastore == :file
        @datastore_type = :file
        @datastore = FileStore.new @ds_config[:file]
      else
        raise Exception.new "Invalid datastore"
      end
    end

    # @TODO FIXME
    def configure(what, k, v)
      @ds_config[what][k] = v
    end

    def store(content : Content)
      @datastore.write content
    end

    def fetch(uid)
      @datastore.read uid
    end

    def fetch_url(url : String)
      file_name = self.uri_file_name url
      if file_name.empty?
        file_name = self.random_name
      end
      p "Fetching #{url} -> #{file_name}"
      rv = nil
      HTTP::Client.get(url) do |response|
        obj = Content.new file_name
        obj.set response.body_io.not_nil!.gets_to_end
        p obj.data.size
        fp = self.store obj
        obj.path = fp
        rv = obj
      end
      rv
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
      "Dragonsfire: store: #{@datastore_type}"
    end
  end

  class Content
    @path = ""
    @meta = {} of String => String
    @data = ""

    def initialize(name : String = "", meta = nil)
      @name = name
      @path = path
      @meta = meta if !meta.nil?
    end

    getter name
    setter name

    getter path
    setter path

    getter meta
    setter meta

    getter data

    def set(data : String)
      @data = data
    end

    def to_s
      "Content{name=#{@name}, path=#{@path}, meta=#{@meta}, data=#{@data.size}}"
    end
  end

end
