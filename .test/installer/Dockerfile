FROM ubuntu

RUN apt update \
  && apt install -y sudo

VOLUME /szcdf_regi

# Create user and work from home
ARG user_pass=ahamiltonpass
RUN groupadd -g 1001 ahamilton \
  && useradd -u 1001 -g ahamilton -m -d /home/ahamilton -s /bin/bash ahamilton \
  && echo "ahamilton:$user_pass" | chpasswd \
  && usermod -aG sudo ahamilton
USER ahamilton
WORKDIR /home/ahamilton

COPY install.sh /home/ahamilton/install.sh
COPY reset.sh /home/ahamilton/reset.sh

# Run everything else as the user

# RUN echo $user_pass | sudo -S apt install -y \
#   git \
#   vim

# RUN /szcdf_regi/szcdf-core/bin/szcdfi.sh -I

# RUN szcdf install entry-bash --registry /szcdf_regi

