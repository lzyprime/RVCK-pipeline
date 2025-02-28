#!/bin/bash
set -e
set -x

pr_patch=${pr_id_url}.patch
repo_name=$(echo ${REPO##h*/} | awk -F'.' '{print $1}')
kernel_result_dir=${repo_name}_pr_${pr_id}
download_server=10.211.102.58
rootfs_download_url=http://${download_server}/openEuler24.03-LTS-SP1/openeuler-rootfs.img

# init evnironment
if [ -f evnironment.temp ];then
	rm -f evnironment.temp
fi
touch evnironment.temp

# yum install 
sudo yum makecache
sudo yum install -y git make flex bison bc gcc elfutils-libelf-devel openssl-devel dwarves

# git clone
git clone -b ${dst_pr} --progress --depth=1 ${REPO} work && pushd work
git config user.email rvci@isrc.iscas.ac.cn
git config user.name rvci

# git am patch
curl -L ${pr_patch} | git am -3 --empty=drop 2>&1

# build 
make openeuler_defconfig
#make th1520_defconfig
make -j$(nproc)

# cp Image
mkdir ${kernel_result_dir}
cp -v arch/riscv/boot/Image ${kernel_result_dir}


if [ -f "${kernel_result_dir}/Image" ];then
	cp -vr ${kernel_result_dir} /mnt/kernel-build-results/
    kernel_download_url=http://${download_server}/kernel-build-results/${kernel_result_dir}/Image
else
	echo "Kernel not found!"
	exit 1
fi
popd

# pass download url
cat <<EOF | tee evnironment.temp
kernel_download_url=${kernel_download_url}
rootfs_download_url=${rootfs_download_url}
EOF
