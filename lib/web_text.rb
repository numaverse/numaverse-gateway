module WebText
  class << self
    def format(string)
      string = string.gsub(/@(\w+)/) { username_link Regexp.last_match[1] }
      string = string.gsub(/([\$|#][a-zA-Z]+)/) { hashtag_link Regexp.last_match[1] }
      string = string.gsub(URI::regexp(%w(http https ipfs))) { url_link Regexp.last_match }
      string
    end

    def username_link(username)
      "<a href='/u/#{username}' class='web-text__username'>@#{username}</a>"
    end

    def hashtag_link(hashtag)
      "<a href='/all?query=#{URI.encode(hashtag)}' class='web-text__hashtag'>#{hashtag}</a>"
    end

    def url_link(matches)
      url = matches[0]
      "<a href='#{url}' target='_blank' class='web-text__url'>#{url.truncate(30)}</a>"
    end

    def mentions(string)
      string.scan(/@(\w+)/).flatten.collect(&:downcase)
    end
  end
end