module ActivityPub
  class Request
    include HTTParty

    attr_reader :response

    def initialize(url, from_account: nil, verb: :get, body: nil)
      @url = Addressable::URI.parse(url)
      @from_account = from_account
      @verb = verb
      @body = body.is_a?(String) ? body : body.to_json
      # ap signing_headers
      @options = @body ? { body: @body } : {}
      if @from_account
        sign!
      end
    end

    def perform
      @response = self.class.send(@verb, @url.to_s, @options)
    end

    def perform_json
      perform
      JSON.parse(@response.body)
    end

    def success?
      (199 < response.code) && (response.code < 300)
    end

    def sign!
      string_to_sign = signing_headers.collect do |key, value|
        "#{key.downcase}: #{value}"
      end.join("\n")
      # puts string_to_sign
      signed = Base64.strict_encode64(@from_account.key.sign(OpenSSL::Digest::SHA256.new, string_to_sign))
      # puts signed
      local_account = Account.find(@from_account.local_account_id)
      key_id = Rails.application.routes.url_helpers.ap_account_url(local_account.hash_address, anchor: 'main-key')
      header_keys = signing_headers.keys.join(' ').downcase

      signature = "keyId=\"#{key_id}\",algorithm=\"rsa-sha256\",headers=\"#{header_keys}\",signature=\"#{signed}\""

      @options[:headers] = signing_headers.except('(request-target)').merge('Signature' => signature)
    end

    def signing_headers
      headers = {
        "(request-target)" => "#{@verb} #{@url.path}",
        'Host' => @url.host,
        'Date' => DateTime.now.httpdate
      }.merge(self.class.headers)
      if @body
        headers['Digest'] = "SHA-256=#{Digest::SHA256.base64digest(@body)}"
      end
      headers
    end

    headers 'Content-Type' => 'application/activity+json'
    headers 'Accept' => 'application/activity+json'
  end
end