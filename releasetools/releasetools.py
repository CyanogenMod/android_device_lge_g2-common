# Copyright (C) 2012 The Android Open Source Project
# Copyright (C) 2013-2015 The CyanogenMod Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#
# Detect panel and swap as necessary 
# lcd_maker_id is determined by get_panel_maker_id on the hardware and is always accurate
# This searches directly in the boot.img and has no other requirements
#

"""Custom OTA commands for LG devices with older bootloaders"""

def FullOTA_InstallEnd(info):
  info.script.script = [cmd for cmd in info.script.script if not "boot.img" in cmd]
  info.script.script = [cmd for cmd in info.script.script if not "show_progress(0.100000, 0);" in cmd]
  info.script.AppendExtra('package_extract_file("boot.img", "/tmp/boot.img");')
  info.script.Mount("/system")
  info.script.AppendExtra('assert(run_program("/system/bin/panel.sh") == 0);')
  info.script.AppendExtra('delete("/system/bin/panel.sh");')
  info.script.Unmount("/system")
