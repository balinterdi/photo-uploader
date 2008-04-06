require 'yaml'

class PhotoSorter

  attr_accessor :photo_data

  def initialize
    @photo_data = nil
    @extension = 'jpg'
  end

  def get_photo_data(yaml_file)
    @yaml_file = yaml_file
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
    @photo_data.each do |dir_name, photo_data_set|
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
    return expanded_photo_names
  end

end

# given a list of files (with full path), the PhotoUploader
# uploads these files through an FTP connection
class PhotoUploader

end
