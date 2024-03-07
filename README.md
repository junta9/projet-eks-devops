# Learn Terraform - Provision an EKS Cluster

This repo is a companion repo to the [Provision an EKS Cluster tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks), containing
Terraform configuration files to provision an EKS cluster on AWS.

terraform init -upgrade

terraform plan -out terraform.plan

terraform apply terraform.plan

aws eks --region eu-west-3 update-kubeconfig --name projet-eks

kubectl apply -f metrics-components.yaml


### install argocd

helm repo add argo https://argoproj.github.io/argo-helm

<!-- kubectl apply -k "https://github.com/argoproj/argo-cd/manifests/crds?ref=<appVersion>" -->

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# add prometheus Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# add grafana Helm repo
helm repo add grafana https://grafana.github.io/helm-charts


*****************************************

kubectl create namespace prometheus

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm install prometheus prometheus-community/prometheus \
    --namespace prometheus \
    --set alertmanager.persistentVolume.storageClass="gp2" \
    --set server.persistentVolume.storageClass="gp2"

*********************************************

The Prometheus server can be accessed via port 80 on the following DNS name from within your cluster:
prometheus-server.prometheus.svc.cluster.local

kubectl get all -n prometheus

**********************************************

kubectl port-forward -n prometheus deploy/prometheus-server 8181:9090

*********************************************

We are now going to install Grafana. For this example, we are primarily using the Grafana defaults, but we are overriding several parameters. As with Prometheus, we are setting the storage class to gp2, admin password, configuring the datasource to point to Prometheus and creating an external load balancer for the service.

Create YAML file called grafana.yaml with following commands:

mkdir ${HOME}/environment/grafana

cat << EoF > grafana.yaml
datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
    - name: Prometheus
      type: prometheus
      url: http://prometheus-server.prometheus.svc.cluster.local
      access: proxy
      isDefault: true
EoF

kubectl create namespace grafana

helm install grafana grafana/grafana \
    --namespace grafana \
    --set persistence.storageClassName="gp2" \
    --set persistence.enabled=true \
    --set adminPassword='EKS!sAWSome' \
    --values grafana/grafana.yaml \
    --set service.type=LoadBalancer

**************************************************

*Run the following command to check if Grafana is deployed properly:

kubectl get all -n grafana

**************************************************

*You can get Grafana ELB URL using this command. Copy & Paste the value into browser to access Grafana web UI.

export ELB=$(kubectl get svc -n grafana grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}') \
&& \
echo "http://$ELB"


*When logging in, use the username admin and get the password hash by running the following:

kubectl get secret --namespace grafana grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

grafana dashboard ID: 17119

****************************************


Métriques à surveiller sur votre infrastructure :
Les métriques à surveiller sur votre infrastructure dépendent des objectifs de votre projet et des services que vous proposez. Cependant, voici quelques catégories de métriques génériques que vous devriez généralement surveiller :

Performances:

Utilisation du CPU: Pourcentage de temps CPU utilisé par les processus.
Utilisation de la mémoire: Quantité de mémoire utilisée par les processus.
Latence: Temps de réponse des services.
Taux de transfert: Débit des données entrant et sortant.
Disponibilité:

Taux d'erreur: Pourcentage de requêtes qui échouent.
Temps de disponibilité: Pourcentage de temps pendant lequel le service est disponible.
Nombre de redémarrages: Nombre de fois que les services ont été redémarrés.
Ressources:

Utilisation du disque: Espace disque utilisé par les fichiers et les données.
Utilisation du réseau: Quantité de trafic réseau entrant et sortant.
Nombre de connexions: Nombre de connexions simultanées aux services.
Sécurité:

Nombre de tentatives de connexion infructueuses: Nombre de tentatives de connexion à votre infrastructure qui ont échoué.
Nombre d'attaques: Nombre d'attaques détectées sur votre infrastructure.
Volume de données compromises: Quantité de données qui ont été compromises en cas d'incident de sécurité.
En plus de ces catégories génériques, il est important de surveiller les métriques spécifiques à vos services et applications. Par exemple, si vous utilisez une base de données, vous devez surveiller des métriques comme le nombre de requêtes par seconde, le temps de réponse des requêtes et la taille de la base de données.

Notre équipe a eu le privilège d'être sollicitée par une grande Marque de luxe en pleine expansion. Face à l'essor de ses activités et à l'élargissement de son marché, l'entreprise reconnaît la nécessité impérative de migrer sa plateforme vers le cloud. Cette initiative vise à augmenter la scalabilité, renforcer la résilience de ses services et garantir la sécurité des transactions et des données des clients.

Scalabilité : Concevoir une infrastructure cloud capable de s'adapter rapidement à l'évolution des besoins de l'entreprise, assurant une expérience utilisateur fluide même en périodes de fortes demandes.
Résilience : Accroître la résilience du service en utilisant les fonctionnalités avancées du cloud pour garantir une disponibilité maximale et une gestion efficace des erreurs.
Automatisation : Mettre en place des mécanismes d'automatisation pour la création, le déploiement et la gestion de l'infrastructure, minimisant ainsi les interventions manuelles et les risques d'erreurs.
Sécurité : Prioriser la sécurité des transactions et des données des clients en mettant en œuvre les meilleures pratiques de sécurité, y compris le chiffrement des données, la gestion des accès et la surveillance proactive des menaces.