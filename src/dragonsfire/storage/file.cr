require "./store"

require "http/client"
require "http/params"
require "random"
require "uri"

require "awscr-s3"

module Dragonsfire

  class FileStore < Store
    def pre_write(file_name : String)
      file_path = self.get_path(file_name)
      if !Dir.exists? @config[:root_path]
        puts "Creating dir #{@config[:root_path]}"
        Dir.mkdir_p @config[:root_path]
      end
      puts "Saving to #{file_path}..."
      file_path
    end

    def save(data, file_name : String)
    end

    #def save(content : IO, file_name : String)
    #  new_name = self.pre_write file_name
    #  File.write(new_name, content)
    #  Object.new file_name, new_name
    #end

    def get_path(uid)
      "#{@config[:root_path]}#{File::SEPARATOR}#{uid}"
    end

    def url_for(uid)
      "/#{@config[:server_root]}/#{uid}"
    end

    def write(content : Content)
      file_path = self.pre_write content.name
      out_file = File.new file_path, "w"
      out_file.puts content.data
      out_file.close
      content.path = file_path
      file_path
    end

    def read(uid)
      #file_path = self.get_path(uid)
      data = File.read uid #file_path
      meta = File.lstat uid #file_path
      return nil if data.nil? || meta.nil?
      [data, meta]
    end

    def destroy(uid)
      file_path = self.get_path(uid)
      p "Deleting #{file_path}..."
      # TODO delete
    end
  end

end
