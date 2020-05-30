# Terraform kuberntes module for logging all pods in cluster

## Filebeat + Elasticsearch + Kibana

### Elasticsearch can work with volumes type: NFS, AWS EBS, GCP PD.
### Kibana work with NFS only

### If you want to exclude some pods to avoid sent logs to elasticsearch by filebeat, add next label to your pod:
        filebeat_logs: "false"
        
#### Providers versions: 
        kubernetes = >=1.11.1
       