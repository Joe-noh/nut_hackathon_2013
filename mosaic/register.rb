require "RMagick"
require "mysql2-cs-bind"

client = Mysql2::Client.new(host: "localhost", username: "takenoko", database: "takenoko")

Dir.glob("../icon_getter/icons/*") do |file|
  filename = file.to_s.split("/").last
  next unless client.xquery("SELECT * FROM colors where filename = ?", filename).to_a.empty?

  img = Magick::ImageList.new(file) rescue next

  red, gre, blu = 0, 0, 0
  pixels = 0
  img.each_pixel do |pxl, r, c|
    red += pxl.red
    gre += pxl.green
    blu += pxl.blue
    pixels += 1
  end

  red, gre, blu = [red, gre, blu].map{|c| (c/pixels.to_f).to_i }
  client.xquery("INSERT INTO colors (red, blue, green, filename) VALUES (?, ?, ?, ?)",
                red, gre, blu, filename)
end
