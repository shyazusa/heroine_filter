require 'sinatra'
require 'sinatra/reloader'
require 'slim'

get '/' do
  @title = 'heroine_filter'
  slim :index
end

post '/upload' do
  @title = 'upload'
  if params[:photo]
    save_path = "./public/images/#{params[:photo][:filename]}"
    File.open(save_path, 'wb') do |f|
      p params[:photo][:tempfile]
      f.write params[:photo][:tempfile].read
      @mes = 'アップロード成功'
    end
  else
    @mes = 'アップロード失敗'
  end
  slim :upload
  redirect 'images'
end

get '/images' do
  images_name = Dir.glob("./public/images/*")
  @images_path = []
  images_name.each do |image|
    @images_path << image.gsub("public/", "./")
  end
  slim :images
end
