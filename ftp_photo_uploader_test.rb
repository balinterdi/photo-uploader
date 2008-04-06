require 'ftp_photo_uploader'
require 'test/unit'

class FtpPhotoUploaderTest < Test::Unit::TestCase

  def setup
    @photo_sorter = PhotoSorter.new
    @photo_sorter.photo_data = {"petrababa"=>[{"files"=>["23?2", "56?4", 89, 90], "with"=>"dsc543"}], "newyork"=>[{"files"=>["02?3", "03", "07", "13?2"], "with"=>"dsc024"}, {"files"=>[78, "84?2"], "with"=>"dsc037"}, {"files"=>["dsc84934", "dsc746673?3"]}]}
  end

  def test_expands_photo_names_well
    photo_names = @photo_sorter.expand_photo_names
    assert(photo_names.key?('1'))
    assert(photo_names.key?('2'))
    assert(photo_names.key?('3'))
    assert(photo_names.key?('4'))
    assert(!photo_names.key?('5'))
  end

end
