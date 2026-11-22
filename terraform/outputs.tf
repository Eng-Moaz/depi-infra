output "vpc_id" {
  value = module.vpc.id
}

output "bastion_public_ip" {
  value = module.bastion.public_ip
}

output "control_plane_private_ip" {
  value = module.control_plane.private_ip
}

output "worker_1_private_ip" {
  value = module.worker_1.private_ip
}

output "worker_2_private_ip" {
  value = module.worker_2.private_ip
}
