### Execute os comandos:
cd eks

terraform init

terraform workspace new dev

terraform workspace select dev

terraform apply

cd ../kubernetes

terraform init && terraform apply