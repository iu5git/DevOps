# Terrafrom

## Подготовка к работе

- Работа в операционной системе семейства Linux
- Устанвленные Docker,Docker-compose
- Установленный пакет Python3

## Установка minikube
```
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo dpkg -i minikube_latest_amd64.deb
```
Стартуем
```
minikube start --vm-driver=docker --base-image='kicbase/stable:v0.0.32'
```
## Установка terraform
```
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

nano ~/.terraformrc

```
provider_installation {
  network_mirror {
    url = "https://terraform-mirror.yandexcloud.net/"
    include = ["registry.terraform.io/*/*"]
  }
  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
}
```

https://github.com/ultral/terraform-example/blob/master/terraform/main.tf

https://dev.to/chefgs/deploy-kubernetes-resources-in-minikube-cluster-using-terraform-1p8o

https://developer.hashicorp.com/terraform/tutorials/cli/init

https://medium.com/@naswani91/in-this-blog-we-will-discuss-what-is-terraform-kubernetes-provider-how-to-use-it-and-difference-f576158b1531