#!/usr/local/bin/ruby
require 'webrick'
include WEBrick
require './captcha.rb'
include Captcha
require 'digest/md5'
require 'rubygems'
gem 'memcache-client'
require 'memcache'

s = HTTPServer.new( :Port => (ARGV[0] || 9400), :Logger => Log.new(nil, BasicLog::WARN), :AccessLog => [] )

@captchas = MemCache.new 'localhost:11211', :namespace => 'captchator'

s.mount_proc("/captcha/check_answer"){|req, res|
  dummy, session, answer = req.path_info.split(/\//)

  if @captchas[session] and @captchas[session] == answer
    correct = 1
    @captchas.delete(session)
  else
    correct = 0
  end

  res.body = correct.to_s
  res['Content-Type'] = "text/plain"
}

s.mount_proc("/captcha/image"){|req, res|
  session = req.path_info[1,100]

  answer = generate_answer
  @captchas.set(session, answer, 60*30) # captcha is valid for 30 minutes

  filename = "imagecache/#{answer}.png"
  if File.exist?(filename)
    image = File.read(filename)
  else
    image = generate_image(answer)
    File.open(filename, 'w+').write(image)
  end

  res.body = image
  res['Content-Type'] = 'image/gif'
  res['Expires'] = 'Mon, 26 Jul 1997 05:00:00 GMT'
  res['Cache-Control'] = 'no-store, no-cache, must-revalidate, post-check=0, pre-check=0'
  res['Pragma'] = 'no-cache'
}

trap("INT"){ s.shutdown }
s.start
