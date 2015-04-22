#! /bin/bash

. ./config.sh

C1=10.2.3.78
C2=10.2.3.34
NAME=seetwo.weave.local

start_suite "Resolve names across hosts"

for host in $HOST1 $HOST2; do
    weave_on $host stop || true
    weave_on $host stop-dns || true
    docker_on $host rm -f c1 c2 || true
done

weave_on $HOST1 launch
weave_on $HOST2 launch $HOST1

weave_on $HOST1 launch-dns 10.2.254.1/24 -debug
weave_on $HOST2 launch-dns 10.2.254.2/24 -debug

weave_on $HOST2 run $C2/24 -t --name=c2 -h $NAME ubuntu
weave_on $HOST1 run --with-dns $C1/24 --name=c1 -t aanand/docker-dnsutils /bin/sh

assert_dns_record $HOST1 c1 $NAME $C2

ok=$(exec_on $HOST1 c1 getent hosts 8.8.8.8)
assert_raises "echo $ok | grep google"

end_suite
