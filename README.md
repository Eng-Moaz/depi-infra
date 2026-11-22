# depi-infra

Infrastructure for the kubeadm lab: Terraform builds the AWS network and nodes, Ansible installs Kubernetes.

```text
terraform/   VPC, 2 subnets, bastion, control plane, 2 workers (state in S3)
ansible/     playbook.yml installs kubeadm v1.35 on the nodes
.github/     deploy.yml (terraform + ansible), destroy.yml (manual)
```

## Run locally

```bash
cd terraform
terraform init
terraform apply
```

Set `ssh_allowed_cidr` in `terraform/terraform.tfvars` to your current public IP (`curl -4 -s https://checkip.amazonaws.com`) plus `/32`.

## Pipeline secrets

Repo secrets `AWS_ROLE_ARN` and `SSH_PRIVATE_KEY`. The AWS role must trust this repository.

Related repos: `depi-helm` (chart), `depi-auth`, `depi-catalog`, `depi-frontend` (images).
