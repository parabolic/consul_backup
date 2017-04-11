#!/usr/bin/env sh
set -e

EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"
DATE=`date +%Y%m%dT%H%M%S)`
CONSUL_SNAPSHOT=${CONSUL_DC}-${DATE}.tgz

function get_consul_ip {
aws --region ${EC2_REGION} ec2 describe-instances \
    --filters "Name=tag:$CONSUL_CLUSTER_TAG,Values=$CONSUL_CLUSTER_VALUE" \
    "Name=instance-state-name,Values=running" \
    --query  Reservations[*].Instances[*].{IP:PrivateIpAddress} |\
    awk -F\: '/"/{gsub(/\s/, "", $2); gsub(/\"/, "", $2); print $2}' |\
    shuf -n 1
}

CONSUL_IP=$(get_consul_ip)

function leader_only {
  CONSUL_LEADER=`curl -s http://${CONSUL_IP}:8500/v1/status/leader | awk -F\: '{gsub(/\"/, ""); print $1}'`
  if [ ${CONSUL_IP}=${CONSUL_LEADER} ];
  then
    echo "Making backup"
  else
    echo "Not a leader ip exiting."
    exit 0
  fi
}

function backup_consul {
  curl http://${CONSUL_IP}:8500/v1/snapshot?dc=${CONSUL_DC} -o ${CONSUL_SNAPSHOT}
}

function copy_backup_to_s3 {
  aws s3 cp ${CONSUL_SNAPSHOT} s3://${S3_BACKUP_BUCKET}/
}

leader_only
backup_consul
copy_backup_to_s3
