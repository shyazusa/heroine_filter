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
    image_path = "./public/images/#{params[:photo][:filename]}"
    File.open(image_path, 'wb') do |f|
      p params[:photo][:tempfile]
      f.write params[:photo][:tempfile].read
    end
    addwindow image_path
    enchar image_path, params[:message].to_s, params[:pointsize].to_i
    @mes = 'アップロード成功'
  else
    @mes = 'アップロード失敗'
  end
  redirect 'images'
end

get '/images' do
  @title = 'local images'
  images_name = Dir.glob('./public/images/*')
  @images_path = []
  images_name.each do |image|
    image_path = image.gsub('public/', './')
    @images_path << image_path
  end
  slim :images
end

helpers do
  def resize(image_path, height, width)
    image_file_name = File.basename(image_path)
    img = Magick::ImageList.new(image_path)
    new_img = img.scale(height, width)
    new_img.write("public/images/resize_#{image_file_name}")
    new_img.destroy!
  end

  def addwindow(image_path)
    image_file_name = File.basename(image_path)
    img = Magick::ImageList.new(image_path)
    start = img.rows
    height = (img.rows / 3) * 2
    width = img.columns

    draw = Magick::Draw.new
    draw.fill('#428b0960')
    draw.rectangle(0, start, width, height)
    draw.draw(img)
    img.write("public/images/#{image_file_name}")
    img.destroy!
  end

  def enchar(image_path, char, pointsize)
    image_file_name = File.basename(image_path)
    img = Magick::ImageList.new(image_path)
    start = img.rows
    height = (img.rows / 3) * 2
    width = img.columns
    fill = '#A6126A'

    font = 'public/fonts/851tegaki_zatsu_normal_0883.ttf'
    draw = Magick::Draw.new
    draw.annotate(img, 0, 0, 5, height, char) do
      self.font = font
      self.fill = fill
      self.pointsize = pointsize
      self.stroke = 'white'
      self.stroke_width = 4
      self.gravity = Magick::NorthWestGravity
    end

    draw.annotate(img, 0, 0, 5, height, char) do
      self.font = font
      self.fill = fill
      self.pointsize = pointsize
      self.stroke = 'transparent'
      self.gravity = Magick::NorthWestGravity
    end

    img.write("public/images/#{image_file_name}")
    img.destroy!
  end
end
