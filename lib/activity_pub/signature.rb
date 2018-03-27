module ActivityPub
  class Signature
    class << self
      def verify_request(request)
        # log_headers(request)
        signature = request.headers['Signature']

        signature_params = Hash[signature.split(',').collect do |section|
          section.gsub('"', '').split('=')[0..1]
        end]

        account = Federated::Account.from_remote_id(signature_params['keyId'].split('#').first)

        decoded = Base64.decode64(signature_params['signature'])
        expected = build_expected_string(request, signature_params['headers'])

        if account.key.public_key.verify(OpenSSL::Digest::SHA256.new, decoded, expected)
          account
        else
          false
        end
      end

      def build_expected_string(request, headers)
        headers.split(' ').collect do |header|
          if header == 'digest'
            "digest: SHA-256=#{Digest::SHA256.base64digest(request.raw_post)}"
          elsif header == '(request-target)'
            "(request-target): #{request.method.downcase} #{request.path}"
          else
            "#{header}: #{request.headers[header]}"
          end
        end.join("\n")
      end

      # used for local debugging
      def log_headers(request)
        headers = {}
        request.headers.each do |key, value|
          if key.start_with?('HTTP')
            headers[key.split("_").last.titleize] = value
          end
        end
        # ap headers
        puts headers.to_json
        puts request.body.read
      end
    end
  end
end