require 'ftp_photo_uploader'
require 'test/unit'

class FtpPhotoUploaderTest < Test::Unit::TestCase

  def setup
    @photo_sorter = PhotoSorter.new
    @photo_sorter.photo_data = {"petrababa"=>[{"files"=>["23?2", "56?4", 89, 90], "with"=>"dsc543"}], "newyork"=>[{"files"=>["02?3", "03", "07", "13?2"], "with"=>"dsc024"}, {"files"=>[78, "84?2"], "with"=>"dsc037"}, {"files"=>["dsc84934", "dsc746673?3"]}]}
    # @photo_uploader = PhotoUploader.new
  end

  def test_get_photo_rel_path
    assert_equal('newyork/dsc01245.jpg', @photo_sorter.get_photo_rel_path('newyork', 'dsc012', '45'))
    assert_equal('newyork/dsc034745.jpg', @photo_sorter.get_photo_rel_path('newyork', nil, 'dsc034745'))
    assert_equal('./dsc034745.jpg', @photo_sorter.get_photo_rel_path('', 'dsc034', '745'))
    assert_equal('./dsc034745.jpg', @photo_sorter.get_photo_rel_path('', nil, 'dsc034745'))
  end

  def test_expands_photo_names_well
    photo_names = @photo_sorter.expand_photo_names
    assert(photo_names.key?('1'))
    assert(photo_names.key?('2'))
    assert(photo_names.key?('3'))
    assert(photo_names.key?('4'))
    assert(!photo_names.key?('5'))
    one_copy = photo_names['1']
    assert(one_copy.include?('petrababa/dsc54389.jpg'))
    assert(one_copy.include?('petrababa/dsc54390.jpg'))
    assert(photo_names['2'].include?('petrababa/dsc54323.jpg'))
    assert(photo_names['4'].include?('petrababa/dsc54356.jpg'))
    assert(one_copy.include?('newyork/dsc02403.jpg'))
    assert(photo_names['2'].include?('newyork/dsc02413.jpg'))
    assert(photo_names['3'].include?('newyork/dsc02402.jpg'))
    assert(one_copy.include?('newyork/dsc03778.jpg'))
    assert(one_copy.include?('newyork/dsc84934.jpg'))
    assert(photo_names['3'].include?('newyork/dsc746673.jpg'))
  end

end
