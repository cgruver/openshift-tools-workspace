#!/usr/bin/env bash

# If the user's home dir does not exist, then create it.  this allows for configurable locations for user home.
if [ ! -d "${HOME}" ]
then
  mkdir -p "${HOME}"
fi

# Configure the container runtime to use an ephemeral graphroot, and to use fuse-overlay instead of vfs.
if [ ! -d "${HOME}/.config/containers" ]
then
  mkdir -p ${HOME}/.config/containers
  (echo '[storage]';echo 'driver = "overlay"';echo 'graphroot = "/tmp/graphroot"';echo '[storage.options.overlay]';echo 'mount_program = "/usr/bin/fuse-overlayfs"') > ${HOME}/.config/containers/storage.conf
fi

# Configure Z shell
if [ ! -f ${HOME}/.zshrc ]
then
  (echo "HISTFILE=${HOME}/.zsh_history"; echo "HISTSIZE=1000"; echo "SAVEHIST=1000") > ${HOME}/.zshrc
  (echo "if [ -f ${PROJECT_SOURCE}/workspace.rc ]"; echo "then"; echo "  . ${PROJECT_SOURCE}/workspace.rc"; echo "fi") >> ${HOME}/.zshrc
fi

# Configure Bash shell
if [ ! -f ${HOME}/.bashrc ]
then
  (echo "if [ -f ${PROJECT_SOURCE}/workspace.rc ]"; echo "then"; echo "  . ${PROJECT_SOURCE}/workspace.rc"; echo "fi") > ${HOME}/.bashrc
fi

# Login to the local image registry
podman login -u $(oc whoami) -p $(oc whoami -t)  image-registry.openshift-image-registry.svc:5000

exec "$@"
