Tenhs::Core::Engine.routes.draw do
  post "images" => "images#create"
  post "captcha" => "captcha#create"
end
