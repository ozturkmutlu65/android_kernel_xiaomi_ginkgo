#! /bin/bash

#
# Script for building Android arm64 Kernel
#
# Copyright (c) 2024 Edwiin Kusuma Jaya <kutemeikito0905@gmail.com>
# Based on Panchajanya1999 & Fiqri19102002 script.
#

# Set environment for directory
KERNEL_DIR=$PWD
IMG_DIR="$KERNEL_DIR"/out/arch/arm64/boot

# Get defconfig file
DEFCONFIG=vendor/ginkgo-perf_defconfig

# Set common environment
export KBUILD_BUILD_USER="Ryuzenn"
export KBUILD_BUILD_HOST="RastaMod69||CircleCI"

#
# Set if do you use GCC or clang compiler
# Default is clang compiler
#
COMPILER=clang

# Get distro name
DISTRO=$(source /etc/os-release && echo ${NAME})

#Get all cores of CPU
PROCS=$(nproc --all)
export PROCS

# Get total RAM
RAM_INFO=$(free -m)
TOTAL_RAM=$(echo "$RAM_INFO" | awk '/^Mem:/{print $2}')
TOTAL_RAM_GB=$(awk "BEGIN {printf \"%.0f\", $TOTAL_RAM/1024}")
export TOTAL_RAM_GB

# Set date and time
DATE=$(TZ=Asia/Jakarta date)

# Set date and time for zip name
ZIP_DATE=$(TZ=Asia/Jakarta date +"%Y%m%d-%H%M")

# Get branch name
BRANCH=$(git rev-parse --abbrev-ref HEAD)
export BRANCH

# Check kernel version
KERVER=$(make kernelversion)

# Get last commit
COMMIT_HEAD=$(git log --oneline -1)

# Check directory path
if [ -d "/root/project" ]; then
	echo -e "Detected Continuous Integration dir"
	export LOCALBUILD=0
	export KBUILD_BUILD_VERSION="1"
	# Clone telegram script first
	git clone --depth=1 https://github.com/fabianonline/telegram.sh.git telegram
	# Set environment for telegram
	export TELEGRAM_DIR="$KERNEL_DIR/telegram/telegram"
	export TELEGRAM_CHAT="-1004223842746"
	# Get CPU name
	export CPU_NAME="$(lscpu | sed -nr '/Model name/ s/.*:\s*(.*) */\1/p')"
else
	echo -e "Detected local dir"
	export LOCALBUILD=1
fi

# Cleanup KernelSU first on local build
if [[ -d "$KERNEL_DIR"/KernelSU && $LOCALBUILD == "1" ]]; then
	rm -rf KernelSU drivers/kernelsu
fi

# Set function for telegram
tg_post_msg() {
	"${TELEGRAM_DIR}" -H -D \
        "$(
            for POST in "${@}"; do
                echo "${POST}"
            done
        )"
}

tg_post_build() {
	"${TELEGRAM_DIR}" -H \
        -f "$1" \
        "$2"
}

# Set function for setup KernelSU
setup_ksu() {
	curl -kLSs "https://raw.githubusercontent.com/kutemeikito/KernelSU/main/kernel/setup.sh" | bash -s main
	if [ -d "$KERNEL_DIR"/KernelSU ]; then
		git apply KernelSU-hook.patch
	else
		echo -e "Setup KernelSU failed, stopped build now..."
		exit 1
	fi
}

# Set function for cloning repository
clone() {
	# Clone AnyKernel3
	git clone --depth=1 https://github.com/kutemeikito/AnyKernel3.git -b master

	if [ $COMPILER == "clang" ]; then
		# Clone Google clang
		git clone --depth=1 https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86 linux-x86
		# Set environment for clang
		TC_DIR=$KERNEL_DIR/linux-x86/clang-r498229b
		# Clone GCC ARM64 and ARM32
		git clone https://github.com/arter97/arm64-gcc.git --depth=1 gcc64
		git clone https://github.com/arter97/arm32-gcc.git --depth=1 gcc32
		# Set environment for GCC ARM64 and ARM32
		GCC64_DIR=$KERNEL_DIR/gcc64
		GCC32_DIR=$KERNEL_DIR/gcc32
        PATH=$TC_DIR/bin/:$PATH
	fi

	export PATH
}

# Set function for naming zip file
set_naming() {
	if [ -d "$KERNEL_DIR"/KernelSU ]; then
		KERNEL_NAME="RyzenKernel-AOSP-Ginkgo-KSU-$ZIP_DATE"
		export ZIP_NAME="$KERNEL_NAME.zip"
	else
		KERNEL_NAME="RyzenKernel-AOSP-Ginkgo-$ZIP_DATE"
		export ZIP_NAME="$KERNEL_NAME.zip"
	fi
}

# Set function for override kernel name
override_name() {
	if [ -d "$KERNEL_DIR"/KernelSU ]; then
		LOCALVERSION="-RyzenKernel-KSU"
	else
		LOCALVERSION="-RyzenKernel"
	fi

	export LOCALVERSION
}

# Set function for send messages to Telegram
send_tg_msg() {
	tg_post_msg "<b>Docker OS: </b><code>$DISTRO</code>" \
	            "<b>Kernel Version : </b><code>$KERVER</code>" \
	            "<b>Date : </b><code>$DATE</code>" \
	            "<b>Device : </b><code>Redmi Note 8 (ginkgo)</code>" \
	            "<b>Pipeline Host : </b><code>$KBUILD_BUILD_HOST</code>" \
	            "<b>Host CPU Name : </b><code>$CPU_NAME</code>" \
	            "<b>Host Core Count : </b><code>$PROCS core(s)</code>" \
	            "<b>Host RAM Count : </b><code>$TOTAL_RAM_GB GB</code>" \
	            "<b>Compiler Used : </b><code>$KBUILD_BUILD_HOST</code>" \
	            "<b>Branch : </b><code>$BRANCH</code>" \
	            "<b>Last Commit : </b><code>$COMMIT_HEAD</code>"
}

# Set function for starting compile
compile() {
	echo -e "Kernel compilation starting"
	make O=out "$DEFCONFIG"
	BUILD_START=$(date +"%s")
	if [ $COMPILER == "clang" ]; then
			make -j"$PROCS" O=out \
					CLANG_TRIPLE=aarch64-linux-gnu- \
					CROSS_COMPILE=aarch64-linux-android- \
					CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
					CC=clang \
					AR=llvm-ar \
					NM=llvm-nm \
					LD=ld.lld \
                    AS=llvm-as \
					OBJDUMP=llvm-objdump \
                    OBJCOPY=llvm-objcopy \
					STRIP=llvm-strip
	fi
	BUILD_END=$(date +"%s")
	DIFF=$((BUILD_END - BUILD_START))
	if [ -f "$IMG_DIR"/Image.gz-dtb ]; then
		echo -e "Kernel successfully compiled"
		if [ $LOCALBUILD == "1" ]; then
			git restore arch/arm64/configs/vendor/ginkgo-perf_defconfig
			if [ -d "$KERNEL_DIR"/KernelSU ]; then
				git restore drivers/ fs/
			fi
		fi
	elif ! [ -f "$IMG_DIR"/Image.gz-dtb ]; then
		echo -e "Kernel compilation failed"
		if [ $LOCALBUILD == "0" ]; then
			tg_post_msg "<b>Build failed to compile after $((DIFF / 60)) minute(s) and $((DIFF % 60)) seconds</b>"
		fi
		if [ $LOCALBUILD == "1" ]; then
			git restore arch/arm64/configs/vendor/ginkgo-perf_defconfig
			if [ -d "$KERNEL_DIR"/KernelSU ]; then
				git restore drivers/ fs/
			fi
		fi
		exit 1
	fi
}

# Set function for zipping into a flashable zip
gen_zip() {
	if [[ $LOCALBUILD == "1" || -d "$KERNEL_DIR"/KernelSU ]]; then
		cd AnyKernel3 || exit
		rm -rf dtb.img dtbo.img Image.gz-dtb *.zip
		cd ..
	fi

	# Move kernel image to AnyKernel3
	mv "$IMG_DIR"/dtb.img AnyKernel3/dtb.img
	mv "$IMG_DIR"/dtbo.img AnyKernel3/dtbo.img
	mv "$IMG_DIR"/Image AnyKernel3/Image.gz-dtb
	cd AnyKernel3 || exit

	# Archive to flashable zip
	zip -r9 "$ZIP_NAME" * -x .git README.md *.zip

	# Prepare a final zip variable
	ZIP_FINAL="$ZIP_NAME"

	if [ $LOCALBUILD == "0" ]; then
		tg_post_build "$ZIP_FINAL" "<b>Build took : $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)</b>"
	fi

	if ! [[ -d "/home/ryuzenn" || -d "/root/project" ]]; then
		curl -i -T *.zip https://oshi.at
		curl bashupload.com -T *.zip
	fi
	cd ..
}

clone
compiler_opt
if [ $LOCALBUILD == "0" ]; then
	send_tg_msg
fi
override_name
compile
set_naming
gen_zip
setup_ksu
override_name
compile
set_naming
gen_zip
