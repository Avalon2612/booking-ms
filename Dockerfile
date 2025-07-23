FROM amazonlinux:2

# Update the system and install necessary packages
RUN yum update -y && \
    yum install -y git tar wget unzip python3 python3-pip && \
    amazon-linux-extras install java-openjdk11 -y && \
    yum clean all

# Set up Maven
RUN cd /opt && \
    wget https://dlcdn.apache.org/maven/maven-3/3.9.11/binaries/apache-maven-3.9.11-bin.tar.gz && \
    tar xvf apache-maven-3.9.11-bin.tar.gz  && \
    rm apache-maven-3.9.11-bin.tar.gz && \
    echo "export M2_HOME=/opt/apache-maven-3.9.11" >> /root/.bashrc && \
    echo "export M2=\$M2_HOME/bin" >> /root/.bashrc && \
    echo "export PATH=\$M2:\$PATH" >> /root/.bashrc

# Install Terraform
RUN cd /opt && \
   wget https://releases.hashicorp.com/terraform/1.0.7/terraform_1.0.7_linux_amd64.zip && \
    unzip terraform_1.0.7_linux_amd64.zip && \
    rm terraform_1.0.7_linux_amd64.zip && \
    mv terraform /usr/local/bin/

# Install kubectl
RUN cd /usr/local/bin && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl


# Set environment variables for the current shell session
ENV M2_HOME=/opt/apache-maven-3.9.11
ENV M2=$M2_HOME/bin
ENV PATH=$M2:/usr/local/bin:$PATH