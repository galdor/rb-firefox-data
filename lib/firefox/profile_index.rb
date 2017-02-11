# Copyright (c) 2017 Nicolas Martyanoff <khaelin@gmail.com>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

module Firefox
  class ProfileIndex
    DEFAULT_PATH = ROOT_PATH.join('profiles.ini')

    attr_reader :path, :profiles

    def initialize(path: DEFAULT_PATH)
      @path = path
      @profiles = {}
    end

    def load()
      sections = []
      section = nil

      File.open(@path).each do |line|
        if line.match(/^\[([^\]]+)\]/)
          title = $1
          next if title == 'General'

          section = {}
          sections << section
        elsif !section.nil? && line.match(/^([^=]+)\s*=\s*(.*)/)
          key = $1
          value = $2

          section[key] = value
        end
      end

      profiles = {}
      sections.each do |section|
        name = section['Name']
        path = Pathname.new(section['Path'])
        is_relative = section['IsRelative']

        if is_relative == '1'
          path = ROOT_PATH.join(path)
        end

        profile = Profile.new(name, path)
        profiles[name] = profile
      end
      @profiles = profiles
    end

    def profile?(name)
      return @profiles.key? name
    end
  end
end
