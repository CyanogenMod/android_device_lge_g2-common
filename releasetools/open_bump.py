#!/usr/bin/env python

#
# Copyright (C) 2014  Anthony King
# Copyright (C) 2014  CyboLabs
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

from __future__ import print_function

import binascii
import os
import struct
import sys

# Proof of Concept
POC = False

if POC:
    from Crypto.Cipher import AES
    import hashlib


usage = """\
Usage: open_bump.py [-ha] "<image_file>" "<output_image>"
  image_file        - <required> path to the image file to bump
  output_image      - <optional> path to output the bumped file to (defaults to <image_file>_bumped.img
  -a/--apend image_file  - <required> if in append mode, the <image_file> is appended rather than <output_file> being generated\
"""

lg_key = "b5e7fc2010c4a82d6d597ba040816da7832e0a5679c81475a0438447b711140f"
lg_iv = "$ecure-W@|lp@per"
lg_magic = "41a9e467744d1d1ba429f2ecea655279"
lg_dec_magic = "696e6877612e77651000000047116667"


def generate_signature(image_hash):
    # the iv and key were extracted from the lg g2 aboot.img. I can explain how to find it on request.
    iv = lg_iv
    key = binascii.unhexlify(lg_key)
    # this "magic" number was found after decrypting the bumped images
    # Without codefire, this would not have been possible as I can find no reference in
    # the images of the g2 or the g3
    magic = binascii.unhexlify(lg_magic)
    image_hash = binascii.unhexlify(image_hash)  # insert your hash here
    # the structure of the signature in bump starts with a magic number, then seemingly random
    # bytes. 2 zeros follow, then the hash of the image, then 6 zeros, then 512 bytes of random data again
    data = magic + os.urandom(16) + '\x00'*2 + image_hash + '\x00'*6 + os.urandom(512)
    # this is then padded to fill the needed 1024 bytes
    padded_data = data + '\x00'*(1024-len(data))
    # AES-256 is then used to encrypt the above data
    cipher = AES.new(key, AES.MODE_CBC, iv)
    return cipher.encrypt(padded_data)


def bumped(image_data):
    d = binascii.hexlify(image_data[-1024:])
    return d.endswith(lg_magic) or d.startswith(lg_magic)


def pair_reverse(s):
    n = len(s) / 2
    fmt = '%dh' % n
    return struct.pack(fmt, *reversed(struct.unpack(fmt, s)))


def get_page_size(image_name):
    with open(image_name, 'rb') as f_img:
        f_img.seek(36, 0)
        return int(pair_reverse(binascii.hexlify(f_img.read(4))), 16)


def get_size_from_kernel(f_image, page_size, seek_size):
    f_image.seek(seek_size, 0)
    return (int(pair_reverse(binascii.hexlify(f_image.read(4))), 16) / page_size) * page_size


def pad_image(image_name):
    page_size = get_page_size(image_name)
    image_size = os.path.getsize(image_name)
    num_pages = image_size / page_size

    f_image = open(image_name, 'a+b')

    paged_kernel_size = get_size_from_kernel(f_image, page_size, 8)
    paged_ramdisk_size = get_size_from_kernel(f_image, page_size, 16)
    paged_second_size = get_size_from_kernel(f_image, page_size, 24)
    if paged_second_size <= 0:
        paged_second_size = 0
    paged_dt_size = get_size_from_kernel(f_image, page_size, 40)
    if paged_dt_size <= 0:
        paged_dt_size = 0
    calculated_size = page_size + paged_kernel_size + paged_ramdisk_size + paged_second_size + paged_dt_size

    if calculated_size > image_size:
        print("Invalid image: %s: calculated size greater than actual size" % image_name)
        f_image.close()
        sys.exit(1)
    if image_size > calculated_size:
        difference = image_size - calculated_size
        if difference not in [page_size, page_size*2]:
            if difference not in [1024, page_size + 1024, 2 * page_size + 1024]:
                print("Image already padded. Attempting to remove padding...")
                print("Beware: this may invalidate your image.")
                i = num_pages - 1
                f_image.seek(0, 0)
                while i >= 0:
                    f_image.seek(page_size * i, 0)
                    data = f_image.read(page_size)
                    data = data.split('\x00')[0]
                    if not data:
                        f_image.truncate(page_size * i)
                        i -= 1
                    else:
                        break
            else:
                print("%s: Image already patched. Bailing out" % image_name)
                sys.exit(1)
    f_image.close()


def get_sha1(image_name):
    return hashlib.sha1(open(image_name, 'rb').read()).hexdigest()
    

def finish(out_image):
    print("bumped image: %s" % out_image)
    sys.exit(0)


def main(in_image, out_image):
    d_in_image = open(in_image, 'rb').read()
    open(out_image, 'wb').write(d_in_image)
    if bumped(d_in_image):
        print("Image already bumped")
        finish(out_image)
    pad_image(out_image)
    if POC:
        sha1sum = get_sha1(out_image)
        magic = generate_signature(sha1sum)
    else:
        magic = binascii.unhexlify(lg_magic)
    with open(out_image, 'a+b') as f_out_image:
        f_out_image.write(magic)
    finish(out_image)


def cli():
    if len(sys.argv) < 2:
        print(usage)
        sys.exit(1)
    if sys.argv[1] in ["-h", "--help"]:
        print(usage)
        sys.exit(0)
    if sys.argv[1] in ["-a", "--append"]:
        if len(sys.argv) < 3:
            print(usage)
            sys.exit(1)
        image_name = out_image = sys.argv[2]
    else:
        image_name = sys.argv[1]
        if len(sys.argv) >= 3:
            out_image = sys.argv[2]
        else:
            out_split = os.path.splitext(image_name)
            out_image = out_split[0] + "_bumped" + out_split[1]
    if not os.path.isfile(image_name):
        print("file not found: %s" % image_name)
        sys.exit(1)
    main(image_name, out_image)


if __name__ == '__main__':
    cli()
