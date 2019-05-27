module SupportVcr
  TEMPLATE = <<~YAML.freeze
    ---
    - !ruby/struct:VCR::HTTPInteraction
      request: !ruby/struct:VCR::Request
        method: :get
        uri: http://example.org/
        body:
        headers:
      response: !ruby/struct:VCR::Response
        status: !ruby/struct:VCR::ResponseStatus
          code: 200
          message: OK
        headers:
          content-type:
          - text/html;charset=utf-8
          content-length:
          - "9"
        body: %s
        http_version: "1.1"
  YAML

  def insert_cassette(cassette, modify: false)
    cassette.dirname.mkpath

    if !modify && cassette.exist?
      cassette.read
      return
    end

    cassette.write(TEMPLATE % SecureRandom.base64)
    FileUtils.touch(cassette, mtime: Time.now)
  end
end

RSpec.configure { |config| config.include(SupportVcr) }
