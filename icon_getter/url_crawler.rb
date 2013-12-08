require "twitter"

client = Twitter::Streaming::Client.new do |conf|
  conf.consumer_key        = "xxxxxxxxxxxxxxxxxxxxx"
  conf.consumer_secret     = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  conf.access_token        = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  conf.access_token_secret = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
end

client.sample do |tweet|
  url = tweet.user.profile_image_url
  unless url.is_a?(Twitter::NullObject)
    File.open("./urls.text", "a"){ |f| f.puts url }
  end
end
