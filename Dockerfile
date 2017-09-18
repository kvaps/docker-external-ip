FROM debian:jessie-backports
ADD start.sh /bin/start.sh
CMD /bin/start.sh
