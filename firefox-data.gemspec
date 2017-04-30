
require 'rake'

Gem::Specification.new do |s|
  s.name = 'firefox-data'
  s.version = '1.0.1'
  s.date = '2017-02-11'
  s.summary = 'A library to extract data from firefox profiles.'
  s.description = 'The firefox-data library extracts various types of ' + \
    'data from firefox profiles.'
  s.homepage = 'https://github.com/galdor/rb-firefox-data'
  s.license = 'ISC'
  s.author = 'Nicolas Martyanoff'
  s.email = 'khaelin@gmail.com'

  s.required_ruby_version = '>= 2.4.0'

  s.files = FileList['firefox-data.gemspec', 'LICENSE',
                     'bin/*.rb', 'lib/**/*.rb']
  s.executables = ['firefox-data']

  s.add_runtime_dependency 'ffi', '~> 1.9', '>= 1.9.17'
  s.add_runtime_dependency 'json-schema', '~> 2.8', '>= 2.8.0'
  s.add_runtime_dependency 'ruby-termios', '~> 1.0', '>= 1.0.2'
  s.add_runtime_dependency 'thor', '~> 0.19', '>= 0.19.4'
end
