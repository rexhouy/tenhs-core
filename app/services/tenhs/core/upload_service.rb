# encoding: utf-8
class Tenhs::Core::UploadService
  def self.file(uploaded_io)
    ext = File.extname(uploaded_io.original_filename)
    f_path = Rails.root.join("public", "uploads", "#{SecureRandom.hex}#{ext}")
    File.open(f_path, "wb") { |file| file.write(uploaded_io.read) }
    [f_path, uploaded_io.original_filename]
  end

  ## 临时文件，保存在本地
  def self.tmp_file(uploaded_io)
    name = SecureRandom.uuid
    f_path = Rails.root.join("tmp", "uploads", name)
    File.open(f_path, "wb") { |file| file.write(uploaded_io.read) }
    name
  end

  ## 测试用，保存在本地
  def self.image(uploaded_io)
    name = "#{SecureRandom.random_number(10 ** 3)}#{uploaded_io.original_filename}"
    f_path = Rails.root.join("public", "uploads", name)
    File.open(f_path, "wb") { |file| file.write(uploaded_io.read) }
    "/uploads/#{name}"
  end
end
