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

