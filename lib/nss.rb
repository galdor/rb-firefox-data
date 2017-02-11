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

require 'ffi'

module NSSFFI
  extend FFI::Library

  class SecItemStr < FFI::Struct
    layout :type, :int,
           :data, :pointer,
           :len, :uint

    def string()
      self[:data].read_string(self[:len])
    end
  end

  ffi_lib 'nss3'

  enum :sec_status, [:wouldblock, -2,
                     :failure, -1,
                     :success, 0]

  typedef :int, :pr_bool
  typedef SecItemStr.ptr(), :sec_item
  typedef :int, :sec_item_type
  typedef :pointer, :pl_arena_pool
  typedef :pointer, :pk11_slot_info

  attach_function :nss_init, 'NSS_Init', [:string], :sec_status
  attach_function :nss_base64_decode_buffer, 'NSSBase64_DecodeBuffer',
    [:pl_arena_pool, :sec_item, :string, :uint], :sec_item

  attach_function :pk11_get_internal_key_slot, 'PK11_GetInternalKeySlot',
    [], :pk11_slot_info
  attach_function :pk11_free_slot, 'PK11_FreeSlot', [:pk11_slot_info], :void
  attach_function :pk11_check_user_password, 'PK11_CheckUserPassword',
    [:pk11_slot_info, :string], :sec_status
  attach_function :pk11sdr_decrypt, 'PK11SDR_Decrypt',
    [:sec_item, :sec_item, :pointer], :sec_status

  attach_function :secitem_alloc_item, 'SECITEM_AllocItem',
    [:pl_arena_pool, :sec_item, :uint], :sec_item
  attach_function :secitem_free_item, 'SECITEM_FreeItem',
    [:sec_item, :pr_bool], :void
end

module NSS
  class Error < StandardError
  end

  def self.init(profile_path)
    res = NSSFFI.nss_init(profile_path.to_s())
    raise NSS::Error, "cannot initialize nss" unless res == :success
  end

  def self.with_internal_key_slot(&block)
    slot = NSSFFI.pk11_get_internal_key_slot()
    raise NSS::Error, "cannot retrieve internal key slot" if slot.nil?

    begin
      yield slot
    ensure
      NSSFFI.pk11_free_slot(slot)
    end
  end

  def self.check_user_password(slot, password)
    res = NSSFFI.pk11_check_user_password(slot, password)
    raise NSS::Error, "authentication failed" unless res == :success
  end

  def self.authenticate(password)
    with_internal_key_slot do |slot|
      check_user_password(slot, password)
    end
  end

  def self.base64_decode(str, &block)
    str_item = NSSFFI.nss_base64_decode_buffer(nil, nil, str, str.bytesize())
    raise NSS::Error, "cannot decode base64 string" if str_item.nil?

    begin
      yield str_item
    ensure
      NSSFFI.secitem_free_item(str_item, 1)
    end
  end

  def self.decrypt(b64str)
    base64_decode(b64str) do |str_item|
      with_sec_item do |res_item|
        res = NSSFFI.pk11sdr_decrypt(str_item, res_item, nil)
        raise NSS::Error, "cannot decrypt string" unless res == :success

        res_item.string()
      end
    end
  end

  def self.with_sec_item(&block)
    item = NSSFFI.secitem_alloc_item(nil, nil, 0)
    raise NSS::Error, "cannot allocate sec item" if item.nil?

    begin
      yield item
    ensure
      NSSFFI.secitem_free_item(item, 1)
    end
  end
end
