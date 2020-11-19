# encoding: utf-8
class Tenhs::Core::ImagesController < ActionController::Base
  protect_from_forgery with: :exception

  def create
    return render json: { filelink: Tenhs::Core::UploadService.image(params[:file]) } if Rails.env.development? # 测试保存在本地
    file = Tenhs::Core::OssService.upload(params[:file])
    render json: { filelink: "http://img.tenhs.com/#{file}" }
  end
end
