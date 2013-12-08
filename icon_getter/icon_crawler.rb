require "open-uri"

File.open("./url_list.txt").each do |u|
  url = u.sub("_normal", "_mini")
  filename = url.split('/').last.strip

  next if File.exist?("icons/#{filename}")

  begin
    open(url) do |img|
      File.open("icons/#{filename}", "wb"){ |f| f.puts img.read }
    end
    puts "I got #{filename}"
  rescue
    next
  end
  sleep 5
end
