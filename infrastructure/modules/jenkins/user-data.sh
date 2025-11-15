#!/bin/bash
set -e

# Update system
yum update -y

# Install Java 17 (Jenkins requires Java 11+)
yum install java-17-amazon-corretto -y

# Add Jenkins repo and install
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
yum install jenkins -y

# Install Docker
amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user
usermod -aG docker jenkins

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
yum install unzip -y
unzip awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

# Install git
yum install git -y

# Start Jenkins
systemctl start jenkins
systemctl enable jenkins

# Wait for Jenkins to start and create initial password
sleep 30

# Make sure Jenkins directories have proper permissions
chown -R jenkins:jenkins /var/lib/jenkins

echo "Jenkins installation completed!"
echo "Jenkins running at: http://$(hostname -f):8080"
echo "Get initial admin password with: sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
