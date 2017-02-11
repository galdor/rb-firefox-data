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

require 'json'

module Firefox
  class InvalidProfile < StandardError
  end

  class Profile
    attr_reader :name, :path, :logins

    def initialize(name, path)
      @name = name
      @path = path
      @logins = nil
    end

    def to_s()
      "#<Firefox::Profile #{@name}>"
    end

    def inspect()
      to_s()
    end

    def load_logins(decrypt: false)
      path = @path.join('logins.json')
      data = JSON.parse(File.read(path))
      unless data.key? 'logins'
        raise InvalidProfile, "missing 'logins' entry in #{path}"
      end

      logins = []
      data['logins'].each do |login_data|
        login =  Login.from_json(login_data)
        login.decrypt() if decrypt
        logins << login
      end
      @logins = logins
    end
  end
end
