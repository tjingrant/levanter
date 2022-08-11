set -x
# broadly based on https://github.com/ayaka14732/tpu-starter

# tcmalloc interferes with intellij remote ide
sudo patch -f -b /etc/environment << EOF
2c2
< LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libtcmalloc.so.4"
---
> #LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libtcmalloc.so.4"
EOF

# don't complain if already applied
retCode=$?
[[ $retCode -le 1 ]] || exit $retCode

#sudo apt update
#sudo apt upgrade -y

# install python 3.10 and nfs
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt install -y python3.10-full python3.10-dev nfs-common


# set up nfs
NFS_SERVER=10.5.220.250
MOUNT_POINT="/files"
sudo mkdir -p ${MOUNT_POINT}
CURRENT_NFS_ENTRY=$(grep ${NFS_SERVER} /etc/fstab)
DESIRED_NFS_ENTRY="${NFS_SERVER}:/propulsion ${MOUNT_POINT} nfs defaults 0 0"
# if different, fix
if [ "$CURRENT_NFS_ENTRY" != "$DESIRED_NFS_ENTRY" ]; then
  set -e
  echo "Setting up nfs"
  grep -v "${NFS_SERVER}" /etc/fstab > /tmp/fstab.new
  echo "${DESIRED_NFS_ENTRY}" >> /tmp/fstab.new
  # then move the new fstab back into place
  sudo cp /etc/fstab /etc/fstab.orig
  sudo mv /tmp/fstab.new /etc/fstab
fi
sudo mount -a


# default to loading the venv
sudo bash -c "echo \"source ${MOUNT_POINT}/venv310/bin/activate\" > /etc/profile.d/activate_shared_venv.sh"
