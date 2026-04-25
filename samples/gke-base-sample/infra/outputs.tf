output "cluster_name" {
  description = "The name of the GKE cluster"
  value       = module.gke.name
}

output "cluster_endpoint" {
  description = "The IP address of the cluster master (private)"
  value       = module.gke.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "The public certificate of the cluster (base64 encoded)"
  value       = module.gke.ca_certificate
  sensitive   = true
}

output "cluster_location" {
  description = "The region of the cluster"
  value       = module.gke.location
}

output "service_account" {
  description = "The email of the GKE node service account"
  value       = module.gke.service_account
}

output "master_authorized_networks_config" {
  description = "The master authorized networks configuration"
  value       = module.gke.master_authorized_networks_config
}

output "kubectl_connect" {
  description = "Shell script to configure kubectl and deploy nginx"
  value       = <<-SCRIPT
    #!/bin/bash
    set -euo pipefail

    echo "🔐 Configuring kubectl credentials..."
    gcloud container clusters get-credentials ${module.gke.name} \
      --region ${module.gke.location} \
      --project ${var.project_id}

    echo ""
    echo "✅ kubectl configured. Test with:"
    echo "   kubectl get nodes"
    echo ""
    echo "🚀 To deploy the internal nginx service:"
    echo "   kubectl apply -f ../k8s/"
    echo ""
    echo "🔍 To verify nginx is running:"
    echo "   kubectl get pods -n nginx-internal"
    echo "   kubectl get svc -n nginx-internal"
    echo ""
    echo "🌐 To test nginx from within the cluster:"
    echo "   kubectl run curl-test --rm -it --restart=Never --image=curlimages/curl -n nginx-internal -- curl -s http://nginx-internal.nginx-internal.svc.cluster.local"
    echo ""
    echo "🔒 To access nginx via port-forward (secure local access):"
    echo "   kubectl port-forward -n nginx-internal svc/nginx-internal 8080:80"
    echo "   curl http://localhost:8080"
  SCRIPT
}
