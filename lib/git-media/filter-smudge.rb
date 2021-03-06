module GitMedia
  module FilterSmudge

    def self.run!
      media_buffer = GitMedia.get_media_buffer
      can_download = true # TODO: read this from config and implement
     
      filename = "";
      if ARGV.length > 0 
        filename = ARGV[0]
      end
      
      # read checksum size
      sha = STDIN.readline(64).strip # read no more than 64 bytes
      if STDIN.eof? && sha.length == 40 && sha.match(/^[0-9a-fA-F]+$/) != nil
        # this is a media file
        media_file = File.join(media_buffer, sha.chomp)
        if File.exists?(media_file)
          self.recover_media(media_file,filename,sha)
        else
          # TODO: download file if not in the media buffer area
          if !can_download
            STDERR.puts('media missing, saving placeholder : ' + filename  + ", " + sha)
            puts sha
          else
            #download file to the media buffer area
            @pull = GitMedia.get_pull_transport
            cache_file = GitMedia.media_path(sha)
            if !File.exist?(cache_file)
              @pull.pull(media_file, sha) 
              if File.exists?(media_file)
                self.recover_media(media_file,filename,sha)
              else
                STDERR.puts('downloading media failed : ' + filename + ", " + cache_file)
                STDOUT.binmode 
                puts sha
              end              
            else
              STDERR.puts('media file not found : ' + filename + ", " + cache_file)
              STDOUT.binmode 
              puts sha             
            end          
          end
        end
      else
        # if it is not a 40 character long hash, just output
        STDERR.puts('Unknown git-media file format')
        STDOUT.binmode      
        print sha
        while data = STDIN.read(4096)
          print data
        end
      end
    end
    
    def self.recover_media(media_file,filename, sha)    
      STDERR.puts('recovering media : ' + filename + ", " + sha)
      STDOUT.binmode      
      File.open(media_file, 'rb') do |f|
        while data = f.read(4096) do
          print data
        end
      end
    end

  end
end