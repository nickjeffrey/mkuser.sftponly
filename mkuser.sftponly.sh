#!/bin/sh

# script to create an SFTP-only user with OpenSSH 4.9 or later


# confirm a parameter was provided
if [ -z "$1" ] ; then
   echo Usage: $0 SomeUserName
   exit
fi


# add a group for SFTP-only users
grep sftponly /etc/group || ( echo Creating sftponly group ; /usr/sbin/addgroup sftponly )



# confirm the sshd_config file contains the required stanza
grep "Match group sftponly" /etc/ssh/sshd_config || (
   echo Updating /etc/ssh/sshd_config with the following stanza:
   echo 'Match group sftponly'          
   echo '   ChrootDirectory %h'         
   echo '   PermitTunnel no'           
   echo '   X11Forwarding no'           
   echo '   AllowTcpForwarding no'      
   echo '   ForceCommand internal-sftp'
   #
   echo ' '                             >> /etc/ssh/sshd_config
   echo 'Match group sftponly'          >> /etc/ssh/sshd_config
   echo '   ChrootDirectory %h'         >> /etc/ssh/sshd_config
   echo '   PermitTunnel no'            >> /etc/ssh/sshd_config
   echo '   X11Forwarding no'           >> /etc/ssh/sshd_config
   echo '   AllowTcpForwarding no'      >> /etc/ssh/sshd_config
   echo '   ForceCommand internal-sftp' >> /etc/ssh/sshd_config
   #
   echo Restarting sshd
   systemctl restart sshd
)



# create user
echo Creating sftp-only user $1
/usr/sbin/useradd --home-dir /home/$1 --create-home $1

echo Putting the user in the sftponly group
/usr/sbin/usermod -G sftponly $1

# the user home directory must be read-only in order for chroot to work
test -d /home/$1 || mkdir /home/$1
chown -R root:root /home/$1
chmod 755 /home/$1

# create a folder that the user has write access to
test -d /home/$1/uploads || mkdir /home/$1/uploads
chown -R $1 /home/$1/uploads

# set a password
passwd $1


# to delete a user
# userdel --remove janedoe
# rm -rf /home/janedoe

# change password of an existing user
# passwd janedoe




