terraform {
  required_providers {
  yandex = {
      source  = "yandex-cloud/yandex"
    }
  #required_version = ">= 0.13"

  aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
###-------- Variables
variable "cloud_id"                 {type=string}
variable "folder_id"                {type=string}
variable "aws_access_key"           {type=string}
variable "aws_secret_key"           {type=string}
variable "aws_region"	       	    {type=string}
variable "path_file_public_key"     {type=string}
variable "zone_name"                {type=string}
variable "image_id"                 {type=string}
variable "availibility_zone_yandex" {type=string}
variable "email"                    {type=string}
variable "remote-user"              {type=string}
variable "devs"                     {type=map}

data "yandex_vpc_subnet" "subnet-1"   {name="default-ru-central1-a"}

provider "aws" {
    access_key  = var.aws_access_key
    secret_key  = var.aws_secret_key
    region      = var.aws_region
}

provider "yandex" {
  service_account_key_file  = file("key.json")
  cloud_id                  = var.cloud_id
  folder_id                 = var.folder_id
  zone                      = var.availibility_zone_yandex
}

###----------- create instance
resource "yandex_compute_instance" "vm-1" {
  for_each    = var.devs
  hostname    = "${each.key}.${var.zone_name}"
  platform_id = "standard-v1"
  zone        = var.availibility_zone_yandex

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id  = var.image_id
      size      = 100
    }
  }

  network_interface {
    subnet_id = data.yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys  = "${var.remote-user}:${file(var.path_file_public_key)}"
  }
  
  labels = {
    user_email= var.email
    task      = "vps"
  }
}


###------take id_zone from var.zone_name
data "aws_route53_zone" "selected" {
  name  = "${var.zone_name}."
}

###------create A-record for each vps
resource "aws_route53_record" "web_dns"{
  for_each  = var.devs
  zone_id   = data.aws_route53_zone.selected.zone_id
  name      = (yandex_compute_instance.vm-1)[each.key].fqdn
  type      = "A"
  ttl       = "300"
  records   = [yandex_compute_instance.vm-1[each.key].network_interface.0.nat_ip_address]
}

output "external_ip_address_vm_1" {
  value = [for name in yandex_compute_instance.vm-1: "${name.fqdn} is  ${name.network_interface.0.nat_ip_address }"]
}
