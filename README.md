# consul_backup
A repository that creates a docker image that auto discovers consul nodes and backs the configuration to s3.
It will search AWS (using aws-cli) for nodes the same way consul search other nodes using tags which should be provided as env variables.

## Requirements
- A running docker installation.
- Environment variables: CONSUL_CLUSTER_TAG, CONSUL_CLUSTER_VALUE, CONSUL_DC, S3_BACKUP_BUCKET.
- Optional Environment variables are: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY and are only used for local testing.

## TODO
- [ ] Create only one backup. Randomization might assign the same leader ip on 2 dockers and they will both create a backup. This needs to be fixed.
