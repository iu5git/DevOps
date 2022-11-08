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
