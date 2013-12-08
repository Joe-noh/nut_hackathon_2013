require "RMagick"
require "mysql2-cs-bind"
require "twitter"
require "open-uri"

class Mosaic
  def initialize(screen_name, output_file)
    @screen_name = screen_name
    @output_file = output_file

    @mysql = Mysql2::Client.new(host: "localhost", username: "takenoko", database: "takenoko")
    @twitter = Twitter::REST::Client.new do |conf|
      conf.consumer_key        = "xxxxxxxxxxxxxxxxxxxxx"
      conf.consumer_secret     = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      conf.access_token        = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      conf.access_token_secret = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    end

    fetch_profile_image
  end

  def create
    img = Magick::ImageList.new("./tmp_image")
    b = Magick::ImageList.new
    page = Magick::Rectangle.new(0,0,0,0)

    old = 0
    puts "<html>"
    puts "<body>"
    puts "<table border=\"\">"
    puts "<tr>"
    img.each_pixel do |pxl, r, c|
      file = "/icons/"+fetch_nearest_image(pxl.red, pxl.green, pxl.blue)
      puts "<td><img src=\"#{file}\" width=\"24\" height=\"24\"></td>"
      if old != c
        old = c
        puts "</tr>"
        puts "<tr>"
      end
    end
    puts "</tr>"
    puts "</table>"
    puts "</body>"
    puts "</html>"
  end

  private

  def fetch_profile_image
    profile_url = @twitter.user(@screen_name).profile_image_url
    if profile_url.is_a?(Twitter::NullObject)
      raise
    else
      profile_url = @twitter.user(@screen_name).profile_image_url.to_s#.sub("_normal", "_mini")
      open(profile_url) do |src|
        File.open("./tmp_image", "wb"){ |dst| dst.puts src.read }
      end
    end
  end

  def fetch_nearest_image(red, green, blue)
    distances = []
    @mysql.query("SELECT * FROM colors").each do |record|
      rr = record["red"]
      gg = record["green"]
      bb = record["blue"]
      filename = record["filename"]

      distances << [(rr-red)**2 + (gg-green)**2 + (bb-blue)**2, filename]
    end

    distances.sort_by{|row| row[0]}.first(20).sample[1]
  end
end

if __FILE__ == $0
  screen_name, output_file = ARGV[0..1]

  mosaic = Mosaic.new(screen_name, output_file)
  mosaic.create
end
