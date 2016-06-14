#!/bin/bash

out=kitchen-dockerfile

echo "FROM anapsix/alpine-java:jdk8" > $out
if [ -n $http_proxy ]; then echo "ENV http_proxy $http_proxy" >> $out; fi
if [ -n $https_proxy ]; then echo "ENV https_proxy $https_proxy" >> $out; fi

mkdir -p .kitchen
ssh-keygen -t rsa -N "" -f .kitchen/docker_id_rsa
if [ -f .kitchen/docker_id_rsa.pub ]; then
   ssh_key=`cat .kitchen/docker_id_rsa.pub`
fi

cat << EOF >> $out
RUN apk update && \\
 apk add ansible alpine-sdk sudo openssh openssh-client curl ruby ruby-dev && \\
 ssh-keygen -A && \\
 adduser -D -h /home/kitchen -s /bin/bash kitchen && \\
 echo kitchen:kitchen | chpasswd && \\
 echo 'kitchen ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \\
 mkdir -p /etc/sudoers.d && \\
 echo 'kitchen ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/kitchen && \\
 chmod 0440 /etc/sudoers.d/kitchen && \\
 mkdir -p /home/kitchen/.ssh && \\
 chown -R kitchen /usr/lib/ruby/gems/2.3.0 && \\
 chown -R kitchen /opt && \\
  sudo -u kitchen -E mkdir -p /tmp/verifier/bin /opt/chef/embedded/bin/  /tmp/verifier/vendor/bats/bin && \\
  ln -s /usr/bin/ruby /opt/chef/embedded/bin/ruby && \\
  ln -s /usr/bin/gem /opt/chef/embedded/bin/gem &&\\
  ln -s /tmp/verifier/gems/gems/busser-bats-0.3.0/vendor/bats/bin/bats /tmp/verifier/vendor/bats/bin/bats && \\
BUSSER_ROOT="/tmp/verifier" GEM_HOME="/tmp/verifier/gems" GEM_PATH="/tmp/verifier/gems" GEM_CACHE="/tmp/verifier/gems/cache" HOME=/home/kitchen sudo -u kitchen -E gem install --no-rdoc --no-ri --no-format-executable -n /tmp/verifier/bin --no-user-install  busser busser-bats io-console && \\
for each in \`ls /tmp/verifier/gems/gems/busser-bats-0.3.0/vendor/bats/libexec/\`; do ln -s /tmp/verifier/gems/gems/busser-bats-0.3.0/vendor/bats/libexec/\$each /bin/\$each; done && \\
echo "$ssh_key" >> /home/kitchen/.ssh/authorized_keys ;
EOF
