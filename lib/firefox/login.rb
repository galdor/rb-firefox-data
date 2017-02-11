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

require 'date'

require 'json-schema'

require 'nss'

module Firefox
  class InvalidLogin < StandardError
  end

  class Login
    JSON_SCHEMA = {
      'type' => 'object',
      'required' => ['id', 'hostname',
                     'encryptedUsername', 'encryptedPassword'],
      'properties' => {
        'id' => {'type': 'integer'},
        'hostname' => {'type': 'string'},
        'httpRealm' => {'type': ['string', 'null']},
        'formSubmitURL' => {'type': ['string', 'null']},
        'usernameField' => {'type': ['string', 'null']},
        'passwordField' => {'type': ['string', 'null']},
        'encryptedUsername' => {'type': 'string'},
        'encryptedPassword' => {'type': 'string'},
        'guid' => {'type': ['string', 'null']},
        'encType' => {'type': 'integer'},
        'timeCreated' => {'type': 'integer'},
        'timeLastUsed' => {'type': 'integer'},
        'timePasswordChanged' => {'type': 'integer'},
        'timesUsed' => {'type': 'integer'},
      },
    }

    attr_accessor :id, :hostname, :http_realm, :form_submit_url,
                  :username_field, :password_field,
                  :encrypted_username, :encrypted_password, :enc_type,
                  :username, :password,
                  :guid,
                  :time_created, :time_last_used, :time_password_changed,
                  :times_used

    def initialize()
    end

    def to_s()
      "#<Firefox::Login #{@hostname}>"
    end

    def inspect()
      to_s()
    end

    def self.from_json(data)
      # In firefox (checked in the mercurial repository on 2017-02-11),
      # logins.json is updated in
      # toolkit/components/passwordmgr/storage-json.js

      begin
        JSON::Validator.validate!(JSON_SCHEMA, data)
      rescue JSON::Schema::ValidationError => err
        raise InvalidLogin, "invalid login data: #{err.message}"
      end

      login = Login.new()

      to_date = lambda do |timestamp|
        seconds = timestamp / 1000
        milliseconds = timestamp % 1000
        Time.at(seconds, milliseconds).utc()
      end

      login.id = data['id']
      login.hostname = data['hostname']
      login.http_realm = data['httpRealm']
      login.form_submit_url = data['formSubmitURL']
      login.username_field = data['usernameField']
      login.password_field = data['passwordField']
      login.encrypted_username = data['encryptedUsername']
      login.encrypted_password = data['encryptedPassword']
      login.enc_type = data['encType']
      login.guid = data['guid']
      login.time_created = to_date.(data['timeCreated'])
      login.time_last_used = to_date.(data['timeLastUsed'])
      login.time_password_changed = to_date.(data['timePasswordChanged'])
      login.times_used = data['timesUsed']

      login
    end

    def decrypt()
      @username = NSS.decrypt(@encrypted_username)
      @password = NSS.decrypt(@encrypted_password)
    end
  end
end
