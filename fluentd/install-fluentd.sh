set -x
WORKING_DIR=$(dirname "$0")
pull_secret=$WORKING_DIR/../common/pull-secret.yaml

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm template \
--set aggregator.configMap="elasticsearch-output" \
--set aggregator.extraEnv[0].name=ELASTICSEARCH_HOST
--set aggregator.extraEnv[0].value="elasticsearch-elasticsearch-data.elasticsearch.svc.cluster.local"
--set aggregator.extraEnv[1].name=ELASTICSEARCH_PORT
--set aggregator.extraEnv[1].value="9200"
--include-crds bitnami/fluentd \
-n fluentd \
--name-template fluentd  > $WORKING_DIR/chart.yaml

ytt  -f $1 -f $WORKING_DIR/chart.yaml -f $pull_secret --file-mark 'chart.yaml:type=yaml-plain' | kapp deploy -a fluentd -n fluentd -f- --diff-changes --yes