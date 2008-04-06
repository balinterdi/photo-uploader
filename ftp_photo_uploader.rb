require 'yaml'
require 'find'
require 'net/ftp'

Debug = true

class PhotoSorter

  attr_accessor :photo_data

  def initialize(yaml_file)
    @photo_data = nil
    @yaml_file = yaml_file
    @extension = 'jpg'
  end

  def get_photo_data
    photo_yaml_data = File.open(@yaml_file) { |f| f.read }
    @photo_data = YAML.load(photo_yaml_data)
  end

  def get_photo_rel_path(dir_name, prefix, file_name)
    dir_name = '.' if dir_name.empty?
    file_name = prefix + file_name unless prefix.nil?
    "#{dir_name}/#{file_name}.#{@extension}"
  end

  def expand_photo_names
    expanded_photo_names = {}
    photo_data ||= get_photo_data
    photo_data.each do |dir_name, photo_data_set|
      photo_data_set.each do |photos|
        # puts "XXX Photos: #{photos.inspect}"
        prefix = photos.fetch('with', nil)
        photos['files'].each do |photo_name|
          photo_fname_and_num_copies = photo_name.to_s.split('?')
          photo_fname = photo_fname_and_num_copies[0]
          num_copies = photo_fname_and_num_copies.length > 1 ? photo_fname_and_num_copies[1] : '1'
          expanded_photo_names[num_copies] = [] unless expanded_photo_names.key?(num_copies)
          expanded_photo_names[num_copies] << get_photo_rel_path(dir_name, prefix, photo_fname)
          # puts "XXX expanded_photo_names: #{expanded_photo_names.inspect}"
        end
      end
    end
    # puts "XXX Expanded photo names: #{expanded_photo_names.inspect}"
    return expanded_photo_names
  end

end

# given a list of files (with full path), the PhotoUploader
# uploads these files through an FTP connection
class PhotoUploader

  def initialize(config_file, photos_config_file)
    config_params = get_config_params(config_file)
    @server = config_params['server']
    @user = config_params['login']
    @password = config_params['password']
    @size = config_params['size']
    @mode = config_params['mode']
    @photosorter = PhotoSorter.new(photos_config_file)
  end

  def get_config_params(config_file)
    config_data = File.open(config_file) { |f| f.read }
    return YAML.load(config_data)
  end

  def connect
    puts "Connecting to FTP server..."
    ftp = Net::FTP.new(@server)
    puts "Logging in..."
    ftp.login(@user, @password)
    return ftp
  end

  def get_remote_dir(num_copies)
    "#{@size}-#{@mode}-#{num_copies}"
  end

  def make_remote_dir(ftp, num_copies)
    ftp.mkdir(get_remote_dir(num_copies))
  end

  def put_photo(ftp, file_name)
    ftp.putbinaryfile(file_name) do
      # puts "Transferring photo"
    end
  end

  def get_short_dir_listing(ftp)
    ftp.ls.collect { |f| f.split.last }
  end

  def basename(file_name)
    file_name.split('/').last
  end

  def put_photos(ftp)
    @photosorter.expand_photo_names.each do |num_copies, files|
      remote_dirs = ftp.ls
      dir_for_photos = get_remote_dir(num_copies)
      make_remote_dir(ftp, num_copies) unless get_short_dir_listing(ftp).include?(dir_for_photos)
      ftp.chdir(dir_for_photos)
      files.each do |file_name|
        if get_short_dir_listing(ftp).include?(basename(file_name))
          puts "Skipping existing #{file_name}"
        else
          puts "Starting to transfer #{file_name}"
          put_photo(ftp, file_name) unless Debug
        end
      end
      ftp.chdir('..')
    end
  end

  def transfer
    ftp = connect
    put_photos(ftp)
    puts "All files transferred, closing connection"
    ftp.close
  end

end

if __FILE__ == $0
  photo_uploader = PhotoUploader.new(ARGV[0], ARGV[1])
  photo_uploader.transfer
end
