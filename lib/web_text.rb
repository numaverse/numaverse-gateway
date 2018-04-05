module WebText
  class << self
    def uri_regex
      URI::regexp(%w(http https ipfs))
    end

    def format(string)
      string = string.gsub(/@([\w|_|\.]+@[\w|\-]+\.[\w|\-]+[\.[\w]+]+)/) { fediverse_link Regexp.last_match[1] }
      string = string.gsub(/(\s|^)@(\w+)([!\.\s\?,]|$)/) { username_link $~ }
      string = string.gsub(/([\$|#][a-zA-Z]+)/) { hashtag_link Regexp.last_match[1] }
      string = string.gsub(uri_regex) { url_link Regexp.last_match }
      string
    end

    def username_link(matches)
      # ap matches
      username = matches[2]
      "#{matches[1]}<a href='/u/#{username}' class='web-text__username'>@#{username}</a>#{matches[3]}"
    end

    def hashtag_link(hashtag)
      "<a href='/all?query=#{URI.encode(hashtag)}' class='web-text__hashtag'>#{hashtag}</a>"
    end

    def url_link(matches)
      url = matches[0]
      "<a href='#{url}' target='_blank' class='web-text__url'>#{url.truncate(80)}</a>"
    end

    def mentions(string)
      string.scan(/@(\w+)/).flatten.collect(&:downcase)
    end

    def fediverse_link(username)
      "<a href='/federated/accounts/search?handle=@#{URI.encode(username)}' class='web-text__username'>@#{username}</a>"
    end
  end
end