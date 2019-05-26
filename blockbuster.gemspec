lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'blockbuster/version'

Gem::Specification.new do |spec|
  spec.name          = 'blockbuster'
  spec.version       = Blockbuster::VERSION
  spec.authors       = ['Lukas Eklund', 'Alexander Bergman', 'Hassan Shahid', 'Joshua Lane']
  spec.email         = ['leklund@fastly.com', 'alexander@fastly.com', 'hassan@fastly.com', 'me@joshualane.com']

  spec.summary       = 'Packaging VCR cassettes for git since 2016'
  spec.homepage      = 'https://github.com/fastly/blockbuster'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'bundler-audit'
  spec.add_development_dependency 'pry-nav'
  spec.add_development_dependency 'rspec', '~> 3.8'
  spec.add_development_dependency 'rubocop-airbnb', '~> 2.0'
  spec.add_development_dependency 'timecop', '~> 0.9'
end
