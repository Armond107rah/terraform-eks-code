# AWS EKS Platform Engineering Lab — Terraform, Kubernetes & CI

**Infrastructure as Code · Amazon EKS · AWS Networking · IAM · Kubernetes · NGINX · GitHub Actions**

> **Repository location:** This README belongs in `primer/README.md`. The hands-on Terraform configuration and Kubernetes manifests are in [`tflab1/`](./tflab1/). This project was developed on the `devops-eks-learning` branch. Check the branch's actual files and GitHub Actions results for the latest deployment evidence.

## Overview

This project builds a small, cloud-native application platform on AWS using Terraform rather than manually provisioning services through the AWS Console. The environment consists of an isolated VPC, public and private subnets, controlled internet egress, IAM roles, an Amazon EKS control plane, managed EC2 worker nodes, and a two-replica NGINX application deployed with Kubernetes manifests.

The lab follows a practical DevOps lifecycle: **design → configure → validate → provision → test → document → destroy**. Terraform describes the cloud infrastructure; Kubernetes describes the desired application state; GitHub Actions provides automated configuration checks. Provisioning and Kubernetes deployment are **manual** in this version of the project, not automated continuous deployment.

## Why Kubernetes? Why does it matter to a business?

A business needs applications that can remain available, handle change, and recover from routine failures without requiring an engineer to manually restart every service. Running one container on one server is straightforward, but maintaining a growing group of applications across multiple machines is harder.

**Kubernetes is a container orchestration platform.** It lets engineers declare *what should be running*—for example, two healthy copies of a web application—and continuously works toward that desired state.

| Business challenge | Kubernetes capability | Business value |
|---|---|---|
| An application container crashes | Restarts or replaces unhealthy containers | Faster recovery from common application failures |
| One instance isn't sufficient for demand | Runs multiple replicas; can scale with additional configuration | Capacity to serve more users |
| Software updates interrupt users | Supports controlled rolling updates and rollbacks | Safer releases and reduced disruption |
| Containers receive changing IP addresses | Services provide stable in-cluster endpoints | More reliable application-to-application communication |
| Different teams deploy applications differently | Declarative manifests standardize deployment | Repeatability, reviewability, and easier collaboration |
| Operations teams need to understand failures | Health probes, events, status, and logs | Faster troubleshooting |

**Important distinction:** Kubernetes does not automatically guarantee uptime, security, autoscaling, or zero downtime. Those outcomes depend on workload design, node capacity, network architecture, probes, permissions, and operational practices. In this lab, the NGINX Deployment requests two replicas and uses readiness and liveness probes; it does not configure a Horizontal Pod Autoscaler.

**Why Amazon EKS?** EKS provides a managed Kubernetes control plane, reducing the operational burden of running the control-plane components. The team still owns cluster access, worker-node configuration, Kubernetes workloads, networking decisions, security controls, and cost management.

## Architecture

```text
                         Developer / Cursor
                                |
                     Terraform + GitHub Actions
                                |
                         AWS Account / Region
                                |
                 Amazon EKS control plane (managed)
                                |
                     VPC: 10.50.0.0/16
               +----------------+----------------+
               |                                 |
       Availability Zone A               Availability Zone B
               |                                 |
       Public 10.50.1.0/24              Public 10.50.2.0/24
       NAT gateway (optional)           Public routing via IGW
               |                                 |
       Private 10.50.11.0/24            Private 10.50.12.0/24
               |                                 |
       EKS managed EC2 nodes across the private subnets
                                |
                 Kubernetes Deployment: NGINX
                      2 desired replicas
                                |
                   ClusterIP Service: port 80
                                |
                 kubectl port-forward to Mac
                      http://localhost:8080
```

The training environment uses **one NAT gateway when enabled**, which is economical for a short lab but creates an Availability Zone dependency. A high-availability production architecture would assess per-AZ NAT gateways and/or VPC endpoints. The private subnets do not gain outbound internet access unless an egress path is configured. The optional public NLB manifest is **not a completed public deployment**; it requires AWS Load Balancer Controller, IAM permissions, and appropriate network configuration.

### Network addressing

| Network | CIDR | Purpose |
|---|---|---|
| VPC | `10.50.0.0/16` | Isolated AWS network |
| Public A | `10.50.1.0/24` | Public routing; optional NAT placement |
| Public B | `10.50.2.0/24` | Public routing; potential load balancer placement |
| Private A | `10.50.11.0/24` | Private EKS node networking |
| Private B | `10.50.12.0/24` | Private EKS node networking |

The public route table directs default IPv4 traffic to an Internet Gateway. Private route tables use local routes and, when NAT is enabled, default routes through the NAT gateway.

## Technologies and responsibilities

| Technology | Role in this project |
|---|---|
| Terraform | Declares and manages AWS resources and tracks their lifecycle |
| Amazon VPC, subnets, route tables, Internet Gateway | Segments and routes cloud network traffic |
| NAT Gateway and Elastic IP | Optional outbound IPv4 internet access for private nodes |
| AWS IAM | Separate EKS service and EC2 node permissions |
| Amazon EKS | Managed Kubernetes control plane |
| EC2 managed node group | Runs Kubernetes workload Pods; targets two `t3.medium` nodes in the lab configuration |
| Kubernetes Deployment | Maintains two desired NGINX Pod replicas with resource requests and health probes |
| Kubernetes ClusterIP Service | Provides stable internal access to NGINX |
| `kubectl` | Checks nodes, Pods, events, logs, and application connectivity |
| GitHub Actions | Checks Terraform formatting/validation and Kubernetes YAML; no automatic AWS deployment |

## Repository layout

```text
primer/
├── README.md                        # This project overview
└── tflab1/
    ├── aws.tf                       # Terraform and AWS provider settings
    ├── vpc.tf                       # VPC
    ├── subnets.tf                   # Public/private subnets
    ├── internet-gateway.tf          # Internet Gateway
    ├── route-tables.tf              # Public/private route tables and NAT routes
    ├── nat-gateway.tf               # Optional NAT gateway + Elastic IP
    ├── variables.tf                 # Deployment toggles and other inputs
    ├── eks-iam.tf                   # Cluster and node IAM roles/policies
    ├── eks-security-groups.tf       # Preparatory internal security group
    ├── eks-cluster.tf               # EKS control plane
    ├── eks-node-group.tf            # Managed EC2 worker nodes
    ├── outputs.tf                   # Resource IDs/ARNs
    ├── k8s/
    │   ├── namespace.yaml          # devops-demo namespace
    │   ├── deployment.yaml         # Two-replica NGINX Deployment
    │   ├── service.yaml            # Internal ClusterIP Service
    │   └── service-public.yaml     # Optional public NLB request; not deployed by default
    └── screenshots/
        ├── 01-eks-cluster-active.png
        ├── 02-kubernetes-nodes-pods.png
        └── 03-github-actions-success.png
```

CI workflow: [`.github/workflows/eks-ci.yml`](../.github/workflows/eks-ci.yml), relative to the repository root. Screenshot links below work when the named image files are added to the repository.

> The original upstream workshop contains separate directories such as `tf-setup/`. This lab uses `primer/tflab1/` as **one Terraform root module**. The individual `.tf` files are not separate reusable child modules.

## How to reproduce the lab

### Prerequisites

- An AWS account with permissions to provision VPC, IAM, EKS, EC2, networking, and related resources.
- AWS CLI authenticated to your intended profile; Terraform CLI and `kubectl` installed.
- A supported AWS provider and EKS Kubernetes version for the chosen AWS Region.
- Awareness that EKS, EC2 nodes, EBS storage, NAT gateway, public IPv4, and data transfer can incur charges.
- Confirm the Terraform configuration is complete **and** that no important resources are already managed in its state.

### 1. Validate the Terraform configuration

From the **repository root**:

```bash
cd primer/tflab1
terraform init -backend=false
terraform fmt -check
terraform validate
terraform state list
```

Check the account/region before any deployment:

```bash
aws sts get-caller-identity --profile default
```

The workshop originally defaulted to `eu-west-1`; use the actual region configured in `aws.tf` for the commands below. Do not rely on the region example without checking.

### 2. Review and apply the infrastructure plan

For a short-lived cluster with worker nodes and NAT enabled, obtain the public IP from which you will use `kubectl`:

```bash
ADMIN_IP="$(curl -4 -fsS https://checkip.amazonaws.com | tr -d '\r\n')"
ADMIN_CIDR="${ADMIN_IP}/32"
```

Create and inspect a **saved plan**:

```bash
terraform plan \
  -var="enable_nat_gateway=true" \
  -var="enable_eks_cluster=true" \
  -var="enable_eks_nodes=true" \
  -var="admin_public_cidr=$ADMIN_CIDR" \
  -out=final-eks.tfplan

terraform show final-eks.tfplan
```

Only after reviewing **every change**, the target AWS account/region, and the ongoing charges:

```bash
terraform apply final-eks.tfplan
```

Applying a saved plan does **not** prompt again for confirmation. Never commit the plan file or Terraform state to GitHub.

### 3. Connect to EKS and verify the nodes

Set `AWS_REGION` to the region used in `aws.tf` (for example, `eu-west-1`):

```bash
export AWS_REGION=eu-west-1
aws eks describe-cluster --name terraform-eks-learning --region "$AWS_REGION" --profile default
aws eks describe-nodegroup --cluster-name terraform-eks-learning --nodegroup-name eks-learning-workers --region "$AWS_REGION" --profile default

aws eks update-kubeconfig --name terraform-eks-learning --region "$AWS_REGION" --profile default
kubectl get nodes -o wide
kubectl get pods -n kube-system
```

Check that the EKS control plane and node group are `ACTIVE`, worker nodes are `Ready`, and required system Pods are healthy. If any checks fail, investigate IAM, API access, route tables, NAT/ECR connectivity, and the node group's reported health issues before deploying the app.

### 4. Deploy and test NGINX

From `primer/tflab1/`:

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

kubectl rollout status deployment/nginx-app -n devops-demo --timeout=180s
kubectl get pods -n devops-demo -o wide
kubectl get services -n devops-demo
```

Keep this terminal session running:

```bash
kubectl port-forward -n devops-demo service/nginx-service 8080:80
```

In a **second terminal**:

```bash
curl -I http://localhost:8080
```

An HTTP `200 OK` indicates successful basic connectivity to the NGINX application through the internal Kubernetes Service. Open `http://localhost:8080` locally to view the welcome page. Stop port-forwarding with **Ctrl+C** when finished; this does not destroy the application or AWS resources.

**Do not apply `k8s/service-public.yaml` by default.** A public NLB requires the AWS Load Balancer Controller and appropriately scoped permissions; its configuration is a planned extension.

### 5. Review GitHub Actions CI

The workflow at [`.github/workflows/eks-ci.yml`](../.github/workflows/eks-ci.yml) is intended to run on repository pushes and pull requests. It checks Terraform configuration and Kubernetes schemas. Review the actual GitHub Actions run before reporting a pass.

This is **continuous integration validation**, not automated Terraform deployment or Kubernetes continuous delivery. The lab deploys infrastructure and NGINX manually.

## Verification and project evidence

Document only checks that actually succeeded in your AWS account and GitHub branch.

| Evidence | What it demonstrates |
|---|---|
| EKS Console — cluster `ACTIVE` | Control-plane deployment |
| `kubectl get nodes` and `kubectl get pods -n devops-demo` | Healthy nodes and application replicas |
| GitHub Actions successful run | Automated Terraform/Kubernetes configuration validation |
| `curl -I http://localhost:8080` returning `200 OK` | Working application connectivity through port-forward |

### Screenshots

**EKS cluster:**

![EKS control plane active](./tflab1/screenshots/01-eks-cluster-active.png)

**Kubernetes nodes and application Pods:**

![Kubernetes nodes and Pods](./tflab1/screenshots/02-kubernetes-nodes-pods.png)

**GitHub Actions validation:**

![GitHub Actions CI checks](./tflab1/screenshots/03-github-actions-success.png)

> Screenshot images must be captured from your actual environment, stored at these paths, and checked for sensitive account information before committing. If a screenshot is missing, remove or defer its link until the file is added.

## Security and operational decisions

- **Private worker nodes:** EC2 worker nodes are placed in private subnet ranges rather than directly exposed to the internet.
- **IAM role separation:** EKS control plane and worker nodes have separate IAM roles. For this learning version, the VPC CNI policy may be attached to the node role; a production improvement is to use dedicated Pod Identity or IRSA permissions.
- **API access:** The EKS public API endpoint is intended to be restricted to an administrator `/32` IPv4 CIDR, with private endpoint access also enabled. Review this against your actual Terraform state and current IP.
- **Network controls:** Internet Gateway, route tables, NAT, and security groups each address different networking needs; a named “private subnet” is not a security guarantee by itself.
- **CI/CD scope:** GitHub Actions performs configuration checks, not automatic deployment. Future CD should use short-lived AWS identity credentials via OIDC and guarded approvals.
- **Reproducibility:** Terraform configuration and `.terraform.lock.hcl` should be version controlled. Terraform state, saved plans, secrets, and private keys should not be.
- **Cost control:** Destroy test infrastructure after gathering evidence; verify cleanup in both Terraform state and AWS.

## Cleanup

Once all tests and screenshots are complete, return to `primer/tflab1` and review the destruction plan:

```bash
terraform plan -destroy \
  -var="enable_nat_gateway=true" \
  -var="enable_eks_cluster=true" \
  -var="enable_eks_nodes=true" \
  -var="admin_public_cidr=$ADMIN_CIDR"
```

Only if the plan contains **exclusively the temporary lab resources**:

```bash
terraform destroy \
  -var="enable_nat_gateway=true" \
  -var="enable_eks_cluster=true" \
  -var="enable_eks_nodes=true" \
  -var="admin_public_cidr=$ADMIN_CIDR"
```

Verify `terraform state list` is empty and check AWS for any remaining chargeable resources, especially EKS, EC2, NAT gateways, Elastic IPs, load balancers, and storage. Terraform cannot automatically remove resources created outside its state.

## Lessons learned and future improvements

The project demonstrates that a functional Kubernetes platform is more than a cluster creation command. The platform depends on well-defined networks, correct IAM permissions, private-node egress, reliable scheduling, application health checks, validation, and cost-aware teardown.

Logical next steps include reusable Terraform modules, a remote state backend with locking, private AWS VPC endpoints, per-AZ NAT resilience, dedicated VPC CNI identity, AWS Load Balancer Controller with HTTPS, stronger workload security, autoscaling, monitoring, and an approval-gated GitHub Actions deployment pipeline.

---

**Project category:** Cloud Engineering / Platform Engineering / DevOps / Kubernetes

**Repository:** [terraform-eks-code](https://github.com/Armond107rah/terraform-eks-code)  
**Learning branch:** `devops-eks-learning`  
**Project implementation:** `primer/tflab1/`
