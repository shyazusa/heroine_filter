require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'RMagick'

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
    blur save_path
    resize save_path, 100, 100
    enchar save_path, '(Z>)90  (ENW)90t = 1', '#428b09'
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
    image_path = image.gsub("public/", "./")
    @images_path << image_path
  end
  slim :images
end

helpers do
  def blur image_path
    image_file_name = File.basename(image_path)
    img = Magick::ImageList.new(image_path)
    new_img = img.blur_image(20.0, 10.0)
    new_img.write("public/images/blur_#{image_file_name}")
    new_img.destroy!
  end

  def resize image_path, height, width
    image_file_name = File.basename(image_path)
    img = Magick::ImageList.new(image_path)
    new_img = img.scale(height, width)
    new_img.write("public/images/resize_#{image_file_name}")
    new_img.destroy!
  end

  def enchar image_path, char, fill
    image_file_name = File.basename(image_path)
    img = Magick::ImageList.new(image_path)
    # scaled_img = img.scale(300, 300)
    scaled_img = img

    font = "851tegaki_zatsu_normal_0883.ttf"
    draw = Magick::Draw.new

    draw.annotate(scaled_img, 0, 0, 5, 5, char) do
      self.font = font
      self.fill = fill
      self.stroke = 'white'
      self.stroke_width = 4
      self.pointsize = 30
      self.gravity = Magick::NorthWestGravity
    end

    draw.annotate(scaled_img, 0, 0, 5, 5, char) do
      self.font = font
      self.fill = fill
      self.stroke = 'transparent'
      self.pointsize = 30
      self.gravity = Magick::NorthWestGravity
    end

    scaled_img.write("public/images/enchar_#{image_file_name}")
    scaled_img.destroy!
  end
end
