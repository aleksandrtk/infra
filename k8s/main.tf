provider "helm" {
  kubernetes {
    host                   = "https://kubernetes.default.svc"
    cluster_ca_certificate = file("/var/run/secrets/kubernetes.io/serviceaccount/ca.crt")
    token                  = file("/var/run/secrets/kubernetes.io/serviceaccount/token")
  }
}

# Проверка, существует ли релиз jenkins
data "helm_release" "jenkins_check" {
  name      = "jenkins"
  namespace = "jenkins"
  # Если релиз не существует, то вернется ошибка и count будет равен 1
  # Можно добавить depends_on для предотвращения взаимозависимостей
}

# Создание релиза Jenkins только если его нет
resource "helm_release" "jenkins" {
  count            = length(data.helm_release.jenkins_check.*.name) == 0 ? 1 : 0
  name             = "jenkins"
  chart            = "jenkins"
  repository       = "https://charts.jenkins.io"
  namespace        = "jenkins"
  create_namespace = true

  # Параметры для управления релизом
}

# Аналогично для argocd
data "helm_release" "argocd_check" {
  name      = "argocd"
  namespace = "argocd"
}

resource "helm_release" "argocd" {
  count            = length(data.helm_release.argocd_check.*.name) == 0 ? 1 : 0
  name             = "argocd"
  chart            = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  namespace        = "argocd"
  create_namespace = true

  # Параметры для управления релизом
}
