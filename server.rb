require 'sinatra'
require 'exifr'

def find_center(points)
  min_x = points[0][0]
  min_y = points[0][1]
  max_x = points[0][0]
  max_y = points[0][1]

  points.each do |point|
    max_x = point[0] if point[0] > max_x
    min_x = point[0] if point[0] < min_x
    max_y = point[1] if point[1] > max_y
    min_y = point[1] if point[1] < min_y
  end

  avg_x = ( max_x + min_x ) / 2
  avg_y = ( max_y + min_y ) / 2

  result = [ avg_x, avg_y ]
end

def convert_dms(coord, ref)
  ["W","S"].include?(ref) ? multiplier = -1.0 : multiplier = 1.0
  output = multiplier * ( coord[0].to_f + ( coord[1].to_f / 60 ) + ( coord[2].to_f / 3600 ) )
end

def load_photos(directory)
  coords_to_map = []

  i = 1
  Dir.foreach(directory) do |f|
    if f[-3..-1] == 'jpg'
      metadata = EXIFR::JPEG.new(directory+"/"+f).exif
      if ( metadata[:gps_latitude] != nil ) && ( metadata[:gps_longitude] != nil )
        lat = convert_dms(metadata[:gps_latitude],metadata[:gps_latitude_ref])
        long = convert_dms(metadata[:gps_longitude],metadata[:gps_longitude_ref])
        elevation = metadata[:gps_altitude].to_f

        coords_to_map << [lat,long,"/"+f]
        i+=1
      end
    end
  end
  coords_to_map
end

get "/" do
  params[:slider_value] == nil ? @selected = 0 : @selected = params[:slider_value].to_i
  @points = load_photos('public/images')
  erb :main
end
