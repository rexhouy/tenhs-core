# encoding: utf-8
require "aliyun/oss"

class Tenhs::Core::OssService
  def self.upload(file)
    id = SecureRandom.uuid + extention(file.original_filename)
    return id if get_bucket.put_object(id, file: file.path)
  end

  def self.destroy(file)
    ret = get_bucket.delete_object(file)
  end

  private

  def self.get_bucket
    OSS.client.get_bucket("tenhs-image")
  end

  def self.extention(name)
    File.extname(name)
  end
end
