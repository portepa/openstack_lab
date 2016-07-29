#!/bin/sh

# Deploy prestashop
# $1: Network ip (only class C)
# $2: Stack name (default:psstack)

cd $(dirname $0)

echo $1 | grep -qP "^\d+\.\d+\.\d+\.0$"

if [ "$?" = "0" ]
then
	net="$1"
else
	echo "Please provide a network ip ex: 10.0.1.0"
	exit 1
fi

if [ -z "$2" ]
then
	stackname="psstack"
else
	stackname="$2"
fi

if [ ${#stackname} -gt 10 ]
then
	echo "Stackname should not exceed 10 chars"
	exit 1
fi


invok=$(basename $0)
fkey=""

if [ "$invok" = "prestashop_v4_sup.sh" ]
then
	ansible-playbook -vvvv prestashop_infra_v4_sup.yaml -e network=$net -e stackname=$stackname
        if [ $? -ne 0 ]
	then
		echo "Scale up failed"
		exit 1
	fi
fkey="-e force_host_keys=yes"
fi

if [ "$invok" = "prestashop_v4_sdn.sh" ]
then
	ansible-playbook -vvvv prestashop_infra_v4_sdn.yaml -e network=$net -e stackname=$stackname
        if [ $? -ne 0 ]
	then
		echo "Scale down failed"
		exit 1
	fi
fi

ansible-playbook -vvvv prestashop_infra_v4.yaml -e network=$net -e stackname=$stackname $fkey
ansible-playbook -vvvv prestashop_app_v4.yaml -e stackname=$stackname
