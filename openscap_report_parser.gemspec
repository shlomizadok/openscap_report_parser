require File.expand_path('../lib/openscap_report_parser/version', __FILE__)

GEMSPEC = Gem::Specification.new do |gem|
  gem.name = 'openscap_report_parser'
  gem.version = OpenscapReportParser::VERSION
  gem.date = '2015-09-01'
  gem.platform = Gem::Platform::RUBY

  gem.author = 'Shlomi Zadok'
  gem.email = 'szadok@redhat.com'
  gem.homepage = 'https://github.com/shlomizadok/openscap_report_parser'
  gem.license = 'GPL-3.0'

  gem.summary = 'Parse ARF reports to json'
  gem.description = 'This gem gets XML ARF reports and parses it to json output'

  gem.add_runtime_dependency 'openscap', '>= 0.4.2'
  gem.add_development_dependency 'bundler', '~> 1.10'
  gem.add_development_dependency 'rake', '~> 10.0'
  gem.add_development_dependency 'rspec'
  gem.extra_rdoc_files = ['README.md', 'LICENSE']
  gem.files = Dir['{lib,test}/**/*'] + gem.extra_rdoc_files
  gem.require_path = 'lib'
end
