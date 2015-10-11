## Quick Start

1. [Install terraform](https://www.terraform.io/downloads.html)
1. Clone this repo `git clone https://github.com/ross/consul-terraform.git`
1. Create an ec2 key-pair (if you don't already have one) and put it in the directory along side this file
1. Create an IAM user with sufficient access (admin if you're lazy) or you can use an existing set of creds
1. Create a terraform.tfvars file with the filled out content below
1. `terraform plan` will show you what it's about to do
1. `terraform apply` will do it
1. Point your browser at one of the public ip addresses in the output section

```
access_key = "<your-access-key>"
secret_key = "<your-secret-key>"
key_name = "<your-key-pair-name>"
ssh_key = "<your-pem-filename>"
# Optionally specify a region, us-east-1 is the default and us-west-2 will
# work, us-west-1 won't because there are only two AZ's
region = "<us-west-2>
```
