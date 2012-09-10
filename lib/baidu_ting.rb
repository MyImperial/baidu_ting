require 'nokogiri'
require 'open-uri'

class BaiduTing
  BASE_URL   = "http://ting.baidu.com"
  TITLE_PATH = '//h2[@class="album-name"]'
  SONGS_PATH = '//span[@class="song-title"]/a'
  attr_accessor :download_status

  def song_url(href)
    url = "#{BASE_URL}#{href}/download"
    page_content = Nokogiri::HTML(get_page(url))
    BASE_URL + page_content.xpath('//a[@id="download"]')[0]["href"]
  end

  def song_list(url)
    page_content = Nokogiri::HTML(get_page(url))
    #get title
    title = page_content.xpath(TITLE_PATH)[0].text.strip

    songs = page_content.xpath(SONGS_PATH)
    @download_status = {}
    songs.each {|song| @download_status[song.text.strip] = 0}
    {title: title,
     songs: Hash[songs.collect {|n| [n.text.strip, song_url(n["href"])]}]}
  end

  def download_song(name, url)
    get_page(url, name) 
  end

  def get_page(url, update_key = nil)
    if update_key
      total_len = 0
      open(url,
           :content_length_proc => lambda do |len|
             if len && 0 < len
               total_len = len
             end
           end,
           :progress_proc => lambda { |s| @download_status[update_key] = s * 100 / total_len })
    else
      open(url)
    end
  end
end
