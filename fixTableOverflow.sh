# echo kern.maxfiles=65536 | sudo tee -a /etc/sysctl.conf
# echo kern.maxfilesperproc=65536 | sudo tee -a /etc/sysctl.conf
# sudo sysctl -w kern.maxfiles=65536
# sudo sysctl -w kern.maxfilesperproc=65536
# sudo ulimit -n 65536 

limit=${1:-10240}
echo `launchctl limit maxfiles`
sudo launchctl limit maxfiles $limit unlimited
echo `launchctl limit maxfiles`
