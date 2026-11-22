# Kubeadm Lab - Two Public Subnets and Bastion (Modular Terraform)

Exact instructor diagram, region **us-east-1**:

- VPC `10.0.0.0/16`.
- **Public subnet A `10.0.1.0/24`** in AZ A: **bastion (t3.micro)**, **control plane (t3.small)**, **worker-1 (t3.small)**.
- **Public subnet B `10.0.2.0/24`** in AZ B: **worker-2 (t3.small)**.
- **One IGW and one shared public route table**, with `0.0.0.0/0` pointing to the IGW, associated with *both* subnets.
- Every instance has a public IPv4 for outbound internet access. This is required for direct public-package downloads through an IGW; the existence of an IGW and subnet route alone would not suffice.
- **Only bastion allows inbound SSH from the admin's specified public IPv4 `/32`.** All three nodes allow TCP/22 **only from the bastion security group**; nodes are allowed to communicate with each other privately. Bastion cannot be used as a proxy to connect to nodes via their public IP; use their **private** addresses.
- EC2 AMI: latest Amazon Linux 2023 from AWS public SSM parameter; uses existing AWS EC2 key pair `depi-tasks`.
- Creates infrastructure only; does not install Kubernetes. Kubernetes version v1.35 is the instructor's requested follow-on.

## Layout

```text
main.tf
variables.tf
outputs.tf
terraform.tfvars.example
modules/
  vpc/{main.tf,variables.tf,outputs.tf}
  subnet/{main.tf,variables.tf,outputs.tf}
  ec2/{main.tf,variables.tf,outputs.tf}
  security/{main.tf,variables.tf,outputs.tf}
```

## Deploy

1. Make sure EC2 key pair `depi-tasks` exists in `us-east-1`.
2. Run `curl -4 -s https://checkip.amazonaws.com` and copy `terraform.tfvars.example` to `terraform.tfvars`. Replace `203.0.113.10/32` with the resulting IPv4 plus `/32`.
3. Run:

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
terraform output
```

**If you already deployed the earlier version:** copy the configuration into the **original Terraform root** and keep its state/backend config. The module names for the VPC, two subnets, Kubernetes nodes, and security groups are preserved. If you already applied the previous *bastion subnet* version, the separate `10.0.3.0/24` subnet will be removed and the bastion will move into subnet A (which requires instance replacement). Giving the existing nodes a public IP may also force instance replacement. Review `terraform plan` carefully before approval; **do not create a second independent Terraform state against the same deployed resources**.

## SSH (on your laptop)

```bash
chmod 400 ~/Downloads/depi-tasks.pem
ssh -i ~/Downloads/depi-tasks.pem ec2-user@BASTION_PUBLIC_IP
```

To reach the control plane without copying your private key to the bastion, run this **from your laptop**:

```bash
ssh -i ~/Downloads/depi-tasks.pem \
    -o 'ProxyCommand=ssh -i ~/Downloads/depi-tasks.pem -W %h:%p ec2-user@BASTION_PUBLIC_IP' \
    ec2-user@CONTROL_PLANE_PRIVATE_IP
```

Or use `ProxyJump` via `~/.ssh/config`. Repeat using each worker's private IP.

## Internet access and costs

- An IGW with public routing and **public IPv4** gives instances direct outbound access to Kubernetes package repos, system updates and container registries. SG outbound is permitted; SG inbound to nodes is restricted.
- Public subnets alone do **not** make an EC2 reachable by SSH: its inbound security group must permit the connection too.
- AWS charges for public IPv4 addresses. Four instances with public IPv4 means four billable public IPv4 addresses; EC2 compute and data transfer may also cost money.
- The lab's control-plane size is `t3.small` (2 vCPU, 2GiB RAM), meeting the commonly cited minimum resources for kubeadm; additional storage and runtime setup may be needed to run Kubernetes.
- When finished with the lab, run `terraform destroy` to avoid charges.
