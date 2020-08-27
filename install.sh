# criar cluster
export PROJECT_ID=gcloud config get-value project && \
  export M_TYPE=n1-standard-2 && \
  export ZONE=us-west2-a && \
  export CLUSTER_NAME=${PROJECT_ID}-${RANDOM} && \
  gcloud services enable container.googleapis.com && \
  gcloud container clusters create $CLUSTER_NAME \
  --cluster-version latest \
  --machine-type=$M_TYPE \
  --num-nodes 3 \
  --zone $ZONE \
  --project $PROJECT_ID

# Habilitar firewall
gcloud compute firewall-rules list --filter="name~gke-${CLUSTER_NAME}-[0-9a-z]*-master"

gcloud compute firewall-rules update <firewall-rule-name> --allow tcp:10250,tcp:443,tcp:15017

#Entrar dentro do k8s
gcloud container clusters get-credentials $CLUSTER_NAME \
    --zone $ZONE \
    --project $PROJECT_ID
    

kubectl create clusterrolebinding cluster-admin-binding \
    --clusterrole=cluster-admin \
    --user=$(gcloud config get-value core/account)

###install istio

istioctl install --set profile=default

kubectl label namespace default istio-injection=enabled

istioctl analyze

###install prometheus
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.7/samples/addons/prometheus.yaml

istioctl dashboard prometheus

####Install grafana
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.7/samples/addons/grafana.yaml

istioctl dashboard grafana

###Install Kiali

kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.7/samples/addons/kiali.yaml