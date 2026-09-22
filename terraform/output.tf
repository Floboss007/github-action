output "vm_IP" {
  value = aws_instance.flo-machine.public_ip
}

output "vm_id" {
  value = aws_instance.flo-machine.id
}

output "vm_private_ip" {
  value = aws_instance.flo-machine.private_ip
}

output "key_name" {
  value = aws_key_pair.flo_key.key_name
}

