variable "prefix" {}

variable "vmid" {}

variable "accid" {}

variable "sg" {}

variable "location" {
  default = "East US"
}

variable "private_ip_address_allocation" {
  type    = string
  default = "eastus"
}

variable "environmentTag" {
  default = "lab"
}

variable "sshSourceIP" {}

variable "jump_os_disk_size" {
  default = "150"
}

variable "nicprefix" {
  default = "nic"
}

variable "node_count" {
  default = "5"
}

variable "extra_node_count" {
   default = "1"
}

variable "node_os_disk_size" {
  default = "300"
}

variable "node_data_disk_size" {
  default = "1000"
}

variable "node_type" {
  default = "Standard_F16s_v2"
}

variable "network" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}


variable "admingroup" {
#  type    = string
  default = ["5e9922e4-6e46-4159-91c4-b41a89446cc8"]
}

variable "uuid" {
  default = "30fa872a-613d-4853-9525-5224b0fde9b1"
}
