/*
 * Copyright (C) 2011 The CyanogenMod Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

/* Read plain address retrieved by RIL and set the Wifi MAC 
 * address accordingly */

int main() {
	int fd1, fd2;
	char macbyte;
	char macbuf[3];
	int i;

	fd1 = open("/dev/block/platform/msm_sdcc.1/by-name/misc",O_RDONLY);
	fd2 = open("/data/misc/wifi/config",O_WRONLY|O_CREAT|O_TRUNC,S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH);

	write(fd2,"btc_mode=1\n",11);
	write(fd2,"mpc=1\n",6);
	write(fd2,"roam_off=0\n",11);
	write(fd2,"roam_scan_period=10\n",20);
	write(fd2,"roam_delta=20\n",14);
	write(fd2,"roam_trigger=-80\n",17);
	write(fd2,"PM=2\n",5);
	write(fd2,"cur_etheraddr=",14);


	for (i = 0; i<6; i++) {
		lseek(fd1,0x3000+i,SEEK_SET);
		lseek(fd2,0,SEEK_END);
		read(fd1,&macbyte,1);
		sprintf(macbuf,"%02x",macbyte);
		write(fd2,&macbuf,2);
		if (i!=5) write(fd2,":",1);
	}

	write(fd2,"\n",1);
	close(fd2);

	fd2 = open("/data/misc/bdaddr",O_WRONLY|O_CREAT|O_TRUNC,S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH);
	for (i = 0; i<6; i++) {
		lseek(fd1,0x4000+i,SEEK_SET);
		lseek(fd2,0,SEEK_END);
		read(fd1,&macbyte,1);
		sprintf(macbuf,"%02x",macbyte);
		write(fd2,&macbuf,2);
		if (i!=5) write(fd2,":",1);
	}
	close(fd2);

	close(fd1);
	return 0;
}
