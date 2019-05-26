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

  def insert_cassette(cassette)
    return cassette.open {} if cassette.exist?

    create_cassette(cassette)
  end

  def modify_cassette(cassette)
    cassette.write(TEMPLATE % SecureRandom.base64)
    FileUtils.touch(cassette, mtime: Time.now)
  end

  def create_cassette(cassette)
    raise "#{cassette} already exists" if cassette.exist?

    cassette.dirname.mkpath
    modify_cassette(cassette)
  end
end

RSpec.configure { |config| config.include(SupportVcr) }
