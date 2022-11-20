#### What

* Set up vps yandex_cloud using "for_each" approach
* Set up aws_route53 linked with ip vps


##### Copy and edit terraform.tfvars
```
cp terraform.tfvars.example terraform.tfvars
```
##### You can add or delete records from devs
```
devs={
  "lbx2"={type="lb"}
  "wbx3"={type="web"}
   ...
   ...
  "wbx4"={type="web"}      
}


```


##### Usage

```
terraform init
terraform plan
terraform apply
```

###### Example output 
```
external_ip_address_vm_1 = [
  "lbx1.srwx.net is  <nat_ip_address1>",
  "wbx1.srwx.net is  <nat_ip_address2>",
  "wbx2.srwx.net is  <nat_ip_address3>",
]
```

