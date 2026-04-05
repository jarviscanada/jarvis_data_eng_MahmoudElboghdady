sudo docker run hello-world
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf -y install docker-ce docker-ce-cli containerd.io
sudo dnf -y install docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable docker
sudo docker run hello-world
sudo groupadd docker
sudo usermod  -aG docker rocky
exit
groups
sudo systemctl start docker
sudo systemctl enable docker
docker run hello-world
sudo reboot
sudo su rocky
cd ~/Downloads
ls *.tar.gz
tar xzf idea-2026.1.tar.gz
mkdir -p ~/apps
mv idea-2026-* ~/apps/
mv idea-2026.1.tar.gz ~/apps/
ls ~/apps/
cd ~/apps/idea-2026.1.tar.gz/./bin/idea.sh
ls 
cd idea-IU-261.22158.277/
ls
cd bin
ls
./idea.sh
git config --global user.name "Mahmoud Elboghdady"
git config --global user.email mahmoud.elboghdady@jrvs.ca
git config --global push.default simple
git config --global alias.co checkout
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.br branch
git config --global alias.lg "log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short"
echo 'export PS1="\t \[\033[36m\]\u\[\033[m\]:\[\033[32m\]\[\033[33;1m\]\W\[\033[m\] [\$(git branch 2>/dev/null | grep "^*" | colrm 1 2)] \$ "' > ~/.bashrc
source ~/.bashrc      #if installing locally, some devices might use ~/.bash_profile instead
cat ~/.gitconfig
q
ezit
exit
exit
sudo su rocky
ls ssh
ssh
ssh-keygen
cd ~/.ssh/
ll
cat id_rsa.pub
sudo su rocky
name_suffix="MahmoudElboghdady"
mkdir -p /home/rocky/dev/jarvis_data_eng_${name_suffix} 
cd /home/rocky/dev/jarvis_data_eng_${name_suffix}
mkdir linux_sql core_java python_data_analytics springboot javascript cloud_devops
for dir in $(ls); do touch $dir/README.md;done 
tree -a
cat > README.md << _EOF
# Jarvis Data Engineering Training
1. [Linux Cluster Monitoring Agent (Linux and SQL)](./linux_sql) In-progress
2. [Core Java Apps](./core_java) In-progress
3. [Python Data Analytics](./python_data_analytics) In-progress
4. [Spring Boot Trading REST API](./springboot) In-progress
5. [Javascript Front End](./javascript) In-progress
6. [Cloud/DevOps](./cloud_devops) In-progress

_EOF

cat README.MD
cat README.md
exit
exiy
exit
