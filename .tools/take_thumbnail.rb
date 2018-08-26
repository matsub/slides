#!/usr/bin/env ruby
# coding: utf-8

require "webshot"
require "pathname"

dir = Pathname.new("assets/images/thumbnails")
unless dir.exist?
    dir.mkdir()
end

thumbnails = {
    "LT-worst-login.png" => "http://localhost:4000/slides/2018/08/18/LT-worst-login/#/1",
}

ws = Webshot::Screenshot.instance
thumbnails.each{|fname, url|
    thumbnail = File.join(dir, fname)
    unless File.exist?(thumbnail)
        ws.capture url, thumbnail, width: 640, height: 480
    end
}
