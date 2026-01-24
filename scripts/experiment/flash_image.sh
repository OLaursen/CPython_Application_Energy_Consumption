#!/bin/bash

os_urls=("https://dl-cdn.alpinelinux.org/alpine/v3.23/releases/aarch64/alpine-rpi-3.23.2-aarch64.tar.gz" "https://download.freebsd.org/releases/arm64/aarch64/ISO-IMAGES/14.3/FreeBSD-14.3-RELEASE-arm64-aarch64-RPI.img.xz" "https://github.com/manjaro-arm/generic-images/releases/download/23.02/Manjaro-ARM-minimal-generic-23.02.img.xz" "https://nycdn.netbsd.org/pub/NetBSD-daily/netbsd-10/latest/evbarm-aarch64/binary/gzimg/arm64.img.gz" "https://cdimage.ubuntu.com/releases/22.04/release/ubuntu-22.04.5-preinstalled-server-arm64+raspi.img.xz")

get_url(){
    os="$1"
    case "$os" in
        "alpine") echo "${os_urls[0]}" ;;
        "freebsd") echo "${os_urls[1]}" ;;
        "manjaro") echo "${os_urls[2]}" ;;
        "netbsd") echo "${os_urls[3]}" ;;
        "ubuntu") echo "${os_urls[5]}" ;;
        *) echo "Unknown OS: $os" ; exit 1 ;;
    esac
}

flash_start(){
    os="$1"
    dest="${2:-.}" # Currently dont support other than cwd
    disk_name="${3:-/dev/disk4}"
    url=$(get_url $os)

    # @TODO Maybe check if the parameters are empty/valid
    # @TODO Check if destination folder exists, create if not
    # @TODO Check if path is occupied, if yes then jump straight to unpacking

    base_url="$(basename $url)"
    base_lenth="${#base_url}-3"
    
    if test -f ./${base_url::base_length}; then
        echo "Disk image already exists in the destination folder."
        Echo "Proceeding to writing to disk"
        write_to_disk "./${base_url::base_length}" "$disk_name"

    elif test -f ./$(basename $url); then
        echo "Zipped Disk image already exists in the destination folder."
        Echo "Proceeding to unpacking"
        unpack_file "./$(basename $url)" "$disk_name"

    fi

    if which wget >/dev/null; then
        echo "Downloading $os from $url to $dest"
        date
        wget -q "$url" -P "$dest"
    elif which curl >/dev/null; then
        echo "Downloading $os from $url to $dest"
        date
        curl -sL "$url" -o "$dest"
    else
        echo "wget not found. Please install wget to download files."
        exit 1
    fi
    echo "Finished downloading disk image"
    date
    unpack_file "$dest/$(basename $url)" "$disk_name"
}

unpack_file(){
    file_path="$1"
    if [[ "$file_path" == *.xz ]]; then
        echo "Unpacking xz file: $file_path"
        unxz $(basename $file_path)
    elif [[ "$file_path" == *.gz ]]; then
        echo "Unpacking gz file: $file_path"
        gunzip $(basename $file_path)
    else
        echo "File format not supported: $file_path"
        exit 1
    fi
    write_to_disk "${file_path%.*}" $2 
    }


write_to_disk(){
    image_file=$1
    disk_name=$2
    sudo diskutil unmountDisk "$disk_name"
    read -p "About to write $image_file to $disk_name. Are you sure? [y/N]: " confirm
    [[ $confirm == [yY] ]] || { echo "Aborted."; exit 1; }

    dd if="$image_file" of="$disk_name" bs=4M status=progress conv=fsync
    dd if="https://dl-cdn.alpinelinux.org/alpine/v3.23/releases/aarch64/alpine-rpi-3.23.2-aarch64.tar.gz" of="/dev/disk4" bs=4M status=progress conv=fsync

    diskutil eject "/dev/disk4"
    echo "Flashing complete. You can now remove the SD card."
    
}

flash_start "$1" "$2" "$3"
