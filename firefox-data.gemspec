
require 'rake'

Gem::Specification.new do |s|
  s.name = 'firefox-data'
  s.version = '1.0.0'
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
end
