#
# Copyright (c) 2020, The Linux Foundation. All rights reserved.
#
# Copyright (c) 2022-2024, Qualcomm Innovation Center, Inc. All rights reserved.
#
# Permission to use, copy, modify, and/or distribute this software for any
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
#

. /lib/functions.sh
. /lib/upgrade/common.sh
. /usr/share/libubox/jshn.sh

RAMFS_COPY_DATA="/etc/fw_env.config /var/lock/fw_printenv.lock /etc/board.json /usr/share/libubox/jshn.sh /tmp/firm_list.txt"
RAMFS_COPY_BIN="/usr/bin/dumpimage /usr/sbin/ubiattach /usr/sbin/ubidetach
	/usr/sbin/ubiformat /usr/sbin/ubiupdatevol /bin/rm /usr/bin/find
	/usr/sbin/mkfs.ext4 /usr/sbin/fw_printenv /sbin/lsmod /usr/bin/jshn"

get_board_details() {
	local JSON_FILE="/etc/board.json"
	local info_value

	json_load_file "$JSON_FILE"

	case $1 in
		"model_name")
			json_select model
			json_get_var info_value name
			info_value=${info_value##*/}
			;;
		*)
			json_get_var info_value $1
			;;
	esac
	echo $info_value
}

image_contains() {
	local img=$1
	local sec=$2
	dumpimage -l ${img} | grep -q "^ Image.*(${sec}.*)" || return 1
}

image_has_mandatory_section() {
	local img=$1
	local mandatory_sections=$2

	for sec in ${mandatory_sections}; do
		image_contains $img ${sec} || {\
			return 1
		}
	done
}

parse_scr() {
	local input_file=$1
	local output_file=$2

	if [ -e $output_file ]; then
		echo " Output file exists removing it.... " > /dev/console
		rm $output_file
	fi

	while IFS= read -r line; do
		if echo "$line" | grep -q 'xtract_n_flash'; then
			value=$(echo "$line" | awk '{print $3}')
			label=$(echo "$line" | awk '{print $4}')

			echo "$value $label" >> "$output_file"
		fi
	done < "$input_file"
}

extract_scr_file() {
	local img=$1
	local file_name=$2
	local position=$3
	local version=$(dumpimage -V 2>&1 | awk '{split($3, a, "."); print a[1]}')

	if [ "$version" == "2016" ]; then
		dumpimage -i ${img} -o ${file_name} -T flat_dt -p $position ${file_name} >/dev/null
	else
		dumpimage -o ${file_name} -T flat_dt -p $position ${img} >/dev/null
	fi
}

extract_images() {
	local img=$1
	local output_file=$2
	local version=$(dumpimage -V 2>&1 | awk '{split($3, a, "."); print a[1]}')

	echo "Extracted Firmwares are ..."
	while IFS= read -r line; do
		image_name=$(echo $line | cut -d ' ' -f1)
		echo $image_name
		position=$(dumpimage -l ${img} |grep $image_name |cut -d ' ' -f3)
		if [ "$version" == "2016" ]; then
			dumpimage -i ${img} -o /tmp/${image_name}.bin -T flat_dt -p $position ${image_name} >/dev/null
		else
			dumpimage -o /tmp/${image_name}.bin -T flat_dt -p $position ${img} >/dev/null
		fi
	done < $output_file
}

image_demux() {
	local img=$1
	local machid=$(fw_printenv | grep machid | cut -d'=' -f2)
	local script_file="script_${machid}"
	local input_scr=/tmp/${script_file}.scr
	local output_list=/tmp/firm_list.txt
	local position=$(dumpimage -l ${img} |grep $script_file |cut -d ' ' -f3)

	extract_scr_file $img $input_scr $position
	parse_scr $input_scr $output_list
	extract_images $img $output_list

	return 0
}

image_is_FIT() {
	if ! dumpimage -l $1 > /dev/null 2>&1; then
		echo "$1 is not a valid FIT image"
		return 1
	fi
	return 0
}

do_flash_mtd() {
	local bin=$1
	local mtdname=$2
	local append=""
	local mtdname_rootfs="rootfs"
	local boot_layout=`find / -name boot_layout`
	local flash_type=`fw_printenv | grep flash_type=11`

	local mtdpart=$(grep "\"${mtdname}\"" /proc/mtd | awk -F: '{print $1}')
	if [ ! -n "$mtdpart" ]; then
		echo "$mtdname is not available" && return
	fi

	local pgsz=$(cat /sys/class/mtd/${mtdpart}/writesize)

	local mtdpart_rootfs=$(grep "\"${mtdname_rootfs}\"" /proc/mtd | awk -F: '{print $1}')

	[ -f "$UPGRADE_BACKUP" -a "$2" == "rootfs" ] && append="-j $UPGRADE_BACKUP"
	dd if=/tmp/${bin}.bin bs=${pgsz} conv=sync | mtd $append -e "/dev/${mtdpart}" write - "/dev/${mtdpart}"
}

do_flash_emmc() {
	local bin=$1
	local emmcblock=$2

	dd if=/dev/zero of=${emmcblock} &> /dev/null
	dd if=/tmp/${bin}.bin of=${emmcblock}
}

do_flash_partition() {
	local bin=$1
	local mtdname=$2
	local emmcblock="$(find_mmc_part "$mtdname")"

	if [ -e "$emmcblock" ]; then
		do_flash_emmc $bin $emmcblock
	else
		do_flash_mtd $bin $mtdname
	fi
}

do_flash_bootconfig() {
	local mtdname=$1
	local bin=bootconfig

	#flash bootconfig with updated boot-info
	if [ -f /tmp/bootconfig.bin ]; then
		do_flash_partition $bin $mtdname
	else
		echo " Bootconfig binary is missing.... "
	fi
}

get_upgrade_bank() {
	local mtdname=$1
	local boot_set=$(grep "Boot-set" /tmp/bootconfig_members.txt | awk -F: '{print $2}')
	local image_status_A=$(grep "Image-set-status-A" /tmp/bootconfig_members.txt | awk -F: '{print $2}')
	local image_status_B=$(grep "Image-set-status-B" /tmp/bootconfig_members.txt | awk -F: '{print $2}')

	if [ "$boot_set" -eq 0 ] && [ "$image_status_A" -eq 0 ]; then
		mtdname="${mtdname}_1"
	elif [ "$boot_set" -eq 1 ] && [ "$image_status_B" -ne 0 ]; then
		mtdname="${mtdname}_1"
	fi

	echo $mtdname
}

do_flash_failsafe_partition() {
	local bin=$1
	local mtdname=$2
	local emmcblock

	#Failsafe upgrade
	mtdname=$(get_upgrade_bank $mtdname)
	emmcblock="$(find_mmc_part "$mtdname")"

	if [ -e "$emmcblock" ]; then
		do_flash_emmc $bin $emmcblock
	else
		do_flash_mtd $bin $mtdname
	fi
}

do_flash_ubi() {
	local bin=$1
	local mtdname=$2
	local alive=$(cat /tmp/.alive_upgrade)
	local mtdpart

	mtdpart=$(grep "\"${mtdname}\"" /proc/mtd | awk -F: '{print $1}')

	if [ $alive -eq 0 ]; then
		ubidetach -f -p /dev/${mtdpart}
	fi

	# Fail safe upgrade
	mtdname=$(get_upgrade_bank $mtdname)

	mtdpart=$(grep "\"${mtdname}\"" /proc/mtd | awk -F: '{print $1}')
	ubiformat /dev/${mtdpart} -y -f /tmp/${bin}.bin
}

do_flash_failsafe_ubi_volume() {
	local bin=$1
	local mtdname=$2
	local vol_name=$3
	local tmpfile="${bin}.bin"
	local mtdpart

	# Fail safe upgrade
	mtdname=$(get_upgrade_bank $mtdname)

	mtdpart=$(grep "\"${mtdname}\"" /proc/mtd | awk -F: '{print $1}')

	if [ ! -n "$mtdpart" ]; then
		echo "$mtdname is not available" && return
	fi

	ubiattach -p /dev/${mtdpart}

	volumes=$(ls /sys/class/ubi/*/ | grep ubi._.*)

	for vol in ${volumes}
	do
		[ -f /sys/class/ubi/${vol}/name ] && name=$(cat /sys/class/ubi/${vol}/name)
			[ ${name} == ${vol_name} ] && m_vol=${vol}
	done

	ubiupdatevol /dev/${m_vol} /tmp/${tmpfile}
}

to_lower ()
{
	echo $1 | awk '{print tolower($0)}'
}

to_upper ()
{
	echo $1 | awk '{print toupper($0)}'
}

flash_section() {
	local img=$1
	local output_list=/tmp/firm_list.txt

	while IFS= read -r line; do
		image_name=$(echo $line | cut -d ' ' -f1)
		partition=$(echo $line | cut -d ' ' -f2)
		case "${image_name}" in
			mibib*) echo " Section $image_name is ignored "; continue ;;
			bootconfig*) echo " Section $image_name is ignored "; continue ;;
			gpt*) echo " Section $image_name is ignored "; continue ;;
			gptbackup*) echo " Section $image_name is ignored "; continue ;;
			wifi_fw*) do_flash_failsafe_partition ${image_name} $partition; do_flash_failsafe_ubi_volume ${image_name} "rootfs" $partition ;;
			ubi*) do_flash_ubi ${image_name} $partition;;
			*) do_flash_failsafe_partition ${image_name} $partition;;
		esac
		echo "Flashed ${image_name}"
	done < $output_list
}

erase_emmc_config() {
	local mtdpart=$(cat /proc/mtd | grep rootfs)
	local emmcblock="$(find_mmc_part "rootfs_data")"
	if [ -z "$mtdpart" -a -e "$emmcblock" ]; then
		yes | mkfs.ext4 "$emmcblock"
	fi
}

platform_check_image() {
	local board=$(get_board_details "board_name")
	local board_model=$(to_lower $(get_board_details "model_name"))
	local mandatory_nor_emmc="hlos fs"
	local mandatory_nor="hlos"
	local mandatory_section_found=0
	local ddr_section="ddr"
	local optional="sb11 sbl2 u-boot lkboot ddr-${board_model} tz rpm"
	local ignored="mibib bootconfig"

	image_is_FIT $1 || return 1

	image_has_mandatory_section $1 ${mandatory_nand} && {\
		mandatory_section_found=1
	}

	image_has_mandatory_section $1 ${mandatory_nor_emmc} && {\
		mandatory_section_found=1
	}

	image_has_mandatory_section $1 ${mandatory_nor} && {\
		mandatory_section_found=1
	}

	if [ $mandatory_section_found -eq 0 ]; then
		echo "Error: mandatory section(s) missing from \"$1\". Abort..."
		return 1
	fi

	image_has_mandatory_section $1 $ddr_section && {\
		image_contains $1 ddr-$board_model || {\
			image_contains $1 ddr-$(to_upper $board_model) || {\
			return 1
			}
		}
	}
	for sec in ${optional}; do
		image_contains $1 ${sec} || {\
			echo "Warning: optional section \"${sec}\" missing from \"$1\". Continue..."
		}
	done

	for sec in ${ignored}; do
		image_contains $1 ${sec} && {\
			echo "Warning: section \"${sec}\" will be ignored from \"$1\". Continue..."
		}
	done

	echo 1711 > /proc/sys/vm/min_free_kbytes
	echo 3 > /proc/sys/vm/drop_caches

	image_demux $1 || {\
		echo "Error: \"$1\" couldn't be extracted. Abort..."
		return 1
	}

	[ -f /tmp/hlos_version ] && rm -f /tmp/*_version
	dumpimage -c $1
	if [[ "$?" == 0 ]];then
		return $?
	else
		echo "Rebooting the system"
		reboot
		return 1
	fi
}

do_upgrade() {
	v "Performing system upgrade..."
	if [ ! -e /proc/boot_info/bootconfig0/ ] && [ ! -e /proc/boot_info/bootconfig1/ ]; then
		echo " Bootconfig is not available. Aborting upgrade..... "
		exit 1
	fi

	if type 'platform_do_upgrade' >/dev/null 2>/dev/null; then
		platform_do_upgrade "$ARGV"
	else
		default_do_upgrade "$ARGV"
	fi

	if [ "$SAVE_CONFIG" -eq 1 ] && type 'platform_copy_config' >/dev/null 2>/dev/null; then
		platform_copy_config
	fi

	v "Upgrade completed"
}

extract_bootconfig() {
	local mtdname=$1
	local mtdpart=$(grep "\"${mtdname}\"" /proc/mtd | awk -F: '{print $1}')
	local emmcblock="$(find_mmc_part "$mtdname")"

	if [ -e "$emmcblock" ]; then
		dd if=${emmcblock} of=/tmp/bootconfig.bin
	else
		dd if=/dev/${mtdpart} of=/tmp/bootconfig.bin
	fi
}

platform_do_upgrade() {
	local upgrade_set=$(get_board_details "sysupgrade")
	local alive=$(cat /tmp/.alive_upgrade)
	local output_list=/tmp/firm_list.txt
	local image_set_default=5

	# verify some things exist before erasing
	if [ ! -e $1 ]; then
		echo "Error: Can't find $1 after switching to ramfs, aborting upgrade!"
		reboot
	fi

	while IFS= read -r line; do
		image_name=$(echo $line | cut -d ' ' -f1)
		if [ ! -e /tmp/${image_name}.bin ]; then
			echo "Error: Cant' find ${image_name} after switching to ramfs, aborting upgrade!"
			reboot
		fi
	done < $output_list

	# extract bootconfig binary from MTD
	extract_bootconfig "0:BOOTCONFIG"

	#passing default value to parse the bootconfig
	# as setting the bank invalid is being handled in driver
	dumpimage -b $image_set_default
	if [[ "$?" == 1 ]];then
		echo "bootconfig functionality failed, rebooting.."
		reboot
		return 1
	fi

	#flash the bootconfig once upgrade bank is set unusable
	do_flash_bootconfig "0:BOOTCONFIG"

	case "$upgrade_set" in
	true)
		flash_section $1

		#passing value '0' to parse the bootconfig and
		# setting ther bank back as valid is being handled in driver
		dumpimage -b 0
		if [[ "$?" == 1 ]];then
			echo "bootconfig functionality failed, rebooting.."
			reboot
			return 1
		fi
		do_flash_bootconfig "0:BOOTCONFIG"

		#setting Try bit for upgrade without config preserve
		if [ $alive -eq 0 ]; then
			if [ -e /proc/upgrade_info/trybit ]; then
				echo 1 > /proc/upgrade_info/trybit
			fi
		fi

		erase_emmc_config
		return 0;
		;;
	esac

	echo "Upgrade failed!"
	return 1;
}

# activate_bootconfig() - activates bootconfig0 or bootconfig1 for OMCI upgrade
# It sets trybit only if the upgraded bootconfig is having lower age
activate_bootconfig() {
	local boot_set

	dumpimage -b 4
	if [ -e /tmp/bootconfig_members.txt ]; then
		boot_set=$(grep "Boot-set" /tmp/bootconfig_members.txt | awk -F: '{print $2}')
	else
		echo " Boot info is not available "
	fi

	if [ "$boot_set" -eq "0" ]; then
		dumpimage -b boot_set 1
	else
		dumpimage -b boot_set 0
	fi
}

# commit_bootconfig() - commits bootconfig0 or bootconfig1 for OMCI upgrade
# It increaments age of the currently booted bootconfig and updates into
# flash after age increament.
commit_bootconfig() {
        local boot_set

	dumpimage -b 4
	if [ -e /tmp/bootconfig_members.txt ]; then
		boot_set=$(grep "Boot-set" /tmp/bootconfig_members.txt | awk -F: '{print $2}')
	else
		echo " Boot info is not available "
	fi

	if [ "$boot_set" -eq "0" ]; then
		dumpimage -b boot_set 1
	else
		dumpimage -b boot_set 0
	fi
	do_flash_bootconfig "0:BOOTCONFIG"
}

get_magic_long_at() {
        dd if="$1" skip=$(( 65536 / 4 * $2 )) bs=4 count=1 2>/dev/null | hexdump -v -n 4 -e '1/1 "%02x"'
}

# find rootfs_data start magic
platform_get_offset() {
        offsetcount=0
        magiclong="x"

        while magiclong=$( get_magic_long_at "$1" "$offsetcount" ) && [ -n "$magiclong" ]; do
                case "$magiclong" in
                        "deadc0de"|"19852003")
                                echo $(( $offsetcount * 65536 ))
                                return
                        ;;
                esac
                offsetcount=$(( $offsetcount + 1 ))
        done
	echo $(( $offsetcount * 65536 ))
}


platform_copy_config() {
	local nand_part="$(find_mtd_part "ubi_rootfs")"
	local emmcblock="$(find_mmc_part "rootfs")"
	local alive=$(cat /tmp/.alive_upgrade)
	local upgradepart="rootfs"
	mkdir -p /tmp/overlay

	#setting Try bit
	if [ $alive -eq 0 ]; then
		if [ -e /proc/upgrade_info/trybit ]; then
			echo 1 > /proc/upgrade_info/trybit
		fi
	fi

	upgradepart=$(get_upgrade_bank $upgradepart)
	if [ "$upgradepart" = "rootfs" ]; then
		upgradepart="rootfs_1"
	else
		upgradepart="rootfs"
	fi

	if [ -e "${nand_part%% *}" ]; then
		local mtdpart
		mtdpart=$(grep "\"${upgradepart}\"" /proc/mtd | awk -F: '{print $1}')
		ubiattach -p /dev/${mtdpart}
		volumes=$(ls /sys/class/ubi/*/ | grep ubi._.*)
		for vol in ${volumes}
		do
			[ -f /sys/class/ubi/${vol}/name ] && name=$(cat /sys/class/ubi/${vol}/name)
			if [[ ${vol} == *"/sys/class/"* ]]; then
				continue
			else
				[ ${name} == "rootfs_data" ] && m_vol=$(echo ${vol} | sed 's/_[^_]*//')
			fi
		done
		mount -t ubifs $m_vol:rootfs_data /tmp/overlay
	elif [ -e "$emmcblock" ]; then
		losetup --detach-all
		local data_blockoffset="$(platform_get_offset $(ls /tmp/rootfs-*))"
		local loopdev="$(losetup -f)"
		[ "$upgradepart" == "rootfs" ] && upgradepart="rootfs_1" || upgradepart="rootfs"
		emmcblock="$(find_mmc_part ${upgradepart})"
		losetup -o $data_blockoffset $loopdev $emmcblock || {
			echo "Failed to mount looped rootfs_data."
			reboot
		}
		echo y | mkfs.ext4 -F -L rootfs_data $loopdev
		mount -t ext4 "$loopdev" /tmp/overlay
	fi

	cp /tmp/sysupgrade.tgz /tmp/overlay/
	sync
	umount /tmp/overlay
}
