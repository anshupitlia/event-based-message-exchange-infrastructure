#!/bin/bash

avn service create product-information-system-demo             \
  --service-type kafka                    \
  --cloud google-asia-east1             \
  --plan business-4                       \
  -c kafka_connect=true                   \
  --disk-space-gib 600

avn service create product-promotion-system-demo             \
  --service-type kafka                    \
  --cloud azure-south-africa-north             \
  --plan business-4                       \
  -c kafka_connect=true                   \
  --disk-space-gib 600

avn service integration-create \
  -s kafka-target              \
  -d kafka-mm                  \
  -t kafka_mirrormaker         \
  -c cluster_alias=kafka-target-alias

avn mirrormaker replication-flow create mirrormaker-product-information-system \
  --source-cluster product-information-system-cluster-alias \
  --target-cluster product-promotion-system-cluster-alias \
  '
    {
        "emit_heartbeats_enabled": true,
        "enabled": true,
        "replication_policy_class": "org.apache.kafka.connect.mirror.DefaultReplicationPolicy",
        "source_cluster": "kafka-source-alias",
        "sync_group_offsets_enabled": true,
        "sync_group_offsets_interval_seconds": 60,
        "target_cluster": "kafka-target-alias",
        "topics": [
            "US-product-price-updates.*"
        ],
    }
  '
