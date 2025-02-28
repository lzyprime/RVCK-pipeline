#!/bin/bash
set -e
set -x

# init env
if [ "$REPO" = "" ] || [ "$ISSUE_ID" = "" ] || [ "$FETCH_REF" = "" ]; then
	echo "REPO ISSUE_ID FETCH_REF is required"
	exit 1
fi

repo_name="$(echo "${REPO##h*/}" | awk -F'.' '{print $1}')"
kernel_result_dir="${repo_name}_pr_${ISSUE_ID}"
download_server=10.213.6.54
rootfs_download_url=https://repo.tarsier-infra.isrc.ac.cn/openEuler-RISC-V/RVCK/openEuler24.03-LTS-SP1/openeuler-rootfs.img
kernel_download_url="http://${download_server}/kernel-build-results/${kernel_result_dir}/Image"

# yum install 
sudo yum makecache
sudo yum install -y git make flex bison bc gcc elfutils-libelf-devel openssl-devel dwarves



# git clone -b "${BASE_REF}" --progress --depth=1 "${REPO}" work
# if [ "$PATCH_URL" != "" ]; then
# 	curl -L "$PATCH_URL" | git am -3 --empty=drop
# fi
git init work
pushd work
git config user.email rvci@isrc.iscas.ac.cn
git config user.name rvci
git remote add origin "${REPO}"

max_retry_times=10
for((retry=0; retry < max_retry_times; retry++)); do
	if git fetch origin "$FETCH_REF":base --progress --depth=1; then
		break
	fi
	sleep 3
done

git checkout base

# build 
make openeuler_defconfig
#make th1520_defconfig
make -j"$(nproc)"

# cp Image
mkdir "${kernel_result_dir}"
cp -v arch/riscv/boot/Image "${kernel_result_dir}"


if [ -f "${kernel_result_dir}/Image" ];then
	cp -vr "${kernel_result_dir}" /mnt/kernel-build-results/
else
	echo "Kernel not found!"
	exit 1
fi
popd

# pass download url
echo "${kernel_download_url}" > kernel_download_url
echo "${rootfs_download_url}" > rootfs_download_url