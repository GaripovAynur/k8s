username: docker
password: tcuser

eksctl # Для создания кластера
kubectl # Для управления класетором
minikube # Для локального использования

###################Поднятие Кластера в AWS Elastic Kubernetes Service - EKS####################
https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version
export AWS_ACCESS_KEY_ID=AKI
export AWS_SECRET_ACCESS_KEY=+
export AWS_DEFAULT_REGION=us-east-2


eksctl create cluster --name denis-k8s # Создать кластер AWS
eksctl create cluster -f mycluster.yaml #Создать кластер из YAML

################# Как использовать kubectl с несколькими Kubernetes кластерами ##############

cat ~/.kube/config 		# Конфигурационный файл
kubectl config get-context 	# Посмотреть какие кластры были созданы
kubectl use-context k8s-2 	# Переключить управление кластера на k8s-2


########### Создание и управление pods
kubectl get nodes  #посмотреть ноды
kubectl run app-kuber-1 --image=httpd:latest --port=80 # Создание pods (скачивает контейнер из Docker Hub)
kubectl get pods # Посмотреть статус pods
kubectl delete pods app-kuber-1  #Удалить pods
kubectl describe pods app-kuber-1 # Посмотреть информацию pods
kubectl exec -it app-kuber-1 -- /bin/bash # Войти внутрь контейнера
kubectl exec -it app-kuber-1 --container app-kuber-1 -- /bin/bash # Войти внутрь контейнера, если в одном Pod несколько контейнера
kubectl logs app-kuber-1 # Логи Pod
kubectl get pod app-kuber-1 -o yaml # Посмотреть параметры в виде yaml
kubectl port-forward app-kuber-1 11111:80 # Проброс портов 11111-локальный 8000-Pod (т.е. пример, с Амазона пробрасывается на ПК домашний 127.0.0.1:11111 - откроется сайт)
kubectl apply -f pod-myweb-ver1.yaml # Создание Pod из дескриптора YAML
kubectl delete -f pod-mywev-ver1.yaml  #Удалить pods

##############Создание и Управление - DEPLOYMENTS - Это одни и теже Поды на разных Нодах (Автоскелинг)
kubectl create deployment denis-deployment --image adv4000/k8sphp:latest #Создать deployment
kubectl get deploy
kubectl describe deployments denis-deployment # Можно посмотреть полную информацию о deployments (названия контейнера, image и т.д.  ).
kubectl scale deployment denis-deployment --replicas 4 # Масштабировать deployment denis-deployment на 4 nodes (последующим если удалить, автоматический будет поддерживаться 4 Pods)
kubectl autoscale deployment denis-deployment --min=4 --max=6 --cpu-percent=80 # (horizontalpodautoscaler - hpa) Всегда будет поддерживать от 4 до 6 Pods, в зависимости от загруженность ЦП
kubectl get hpa # Посотреть какие параметры для автомасштабирования  (horizontalpodautoscaler - hpa)
kubectl rollout history deployment/denis-deployment # Показывает историю  deployment
kubectl rollout status deployment/denis-deployment # Показывает статус deployment
kubectl set image deployment/denis-deployment k8sphp=adv4000/k8sphp:version1 --record # Устанавливаем новый image на нашем существующем deployment. k8sphp - названия контейнера.
kubectl set image deployment/denis-deployment k8sphp=adv4000/k8sphp:version2 --record # Новый deployment
kubectl rollout undo deployment/denis-deployment --to-revision=3 # Возвращает на шаг назад из adv4000/k8sphp:version2 на adv4000/k8sphp:version1
kubectl rollout restart deployment/denis-deployment # Пересоздается новый deployment/denis-deployment
kubectl apply -f deployment-1-simple.yaml # 1 - реплика
kubectl apply -f deployment-2-replicas.yaml # 3 - реплика
kubectl apply -f deployment-3-autoscaling.yaml # Автомасштабирование
kubectl delete deployment --all # Удалить все deployment

#####################Создание и Управление - SERVICES - Это интерфейс к DEPLOYMENTS (ClusterIP, NodePort, LoadBalance? ExternalName(или DNS))
kubectl create deployment denis-deployment --image adv4000/k8sphp:latest	#Создать Deployment из Docker Image adv4000/k8sphp:latest
kubectl get deployment	#Показать все Depoyments
kubectl scale deployment denis-deployment --replicas 4										#Создать ReplicaSets
kubectl expose deployment denis-deployment --type=ClusterIP --port 80			#Создать Service типа ClusterIP для Deployment, можно достучаться только из внутри кластера пример  cutl 10.1.1.9
kubectl expose deployment denis-deployment --type=NodePort --port 3123		#Создать Service типа NodePort для Deployment (kubectl describe nodes | grep ExternalIP - поиск используемых внешних ip, потом curl 123.124.13.12:3123 )
kubectl expose deployment denis-deployment --type=LoadBalancer --port 80	#Создать Service типа LoadBalancer  для Deployment, только делается в Клоуде.
kubectl apply -f service-3-loadbalancer-autoscaling.yaml
kubectl get services																											#Показать все Services
kubectl get svc																														#Показать все Services
kubectl describe nodes | grep ExternalIP																	#Показать External IP со всех Worker Nodes

##################Создание и Управление - INGRESS Controllers
kubectl apply -f https://projectcontour.io/quickstart/contour.yaml	#Создать Ingress Controller Contour
kubectl get services -n projectcontour envoy -o wide	#Показать Ingess Controller Load Balancer данные
kubectl create deployment main    --image=adv4000/k8sphp:latest 	#Создать Deployment
kubectl create deployment web1    --image=adv4000/k8sphp:version1	#Создать Deployment
kubectl create deployment web2    --image=adv4000/k8sphp:version2	#Создать Deployment
kubectl scale deployment main    --replicas 2	#Создать ReplicaSets
kubectl scale deployment web1    --replicas 2	#Создать ReplicaSets
kubectl scale deployment web2    --replicas 2	#Создать ReplicaSets
kubectl expose deployment main   --port 80   # --type=ClusterIP  DEFAULT	Создать Service, по умолчанию тип ClusterIP
kubectl expose deployment web1   --port 80	#Создать Service, по умолчанию тип ClusterIP
kubectl expose deployment web2   --port 80	#Создать Service, по умолчанию тип ClusterIP
kubectl expose deployment tomcat --port 8080	#Создать Service, по умолчанию тип ClusterIP
kubectl get services -o wide	#Показать данные всех Services
kubectl apply -f ingress-hosts.yaml	#Создать Ingress Rules из файла
kubectl apply -f ingress-paths.yaml	#Создать Ingress Rules из файла
kubectl get ingress	#Показать все созданные Ingress Rules
kubectl describe ingress	#Показать все созданные Ingress Rules подробно
kubectl delete ns projectcontour	#Стереть полностью Ingress Controller Contour


############## Helm Charts
helm version	#Пока версию Helm
helm list	#Показать все задеплоенные Helm Releases
helm search hub	#Показать Helm Chart с общего списка Hub
helm search repo	#Показать Helm Chart из добавленных Repos
helm install app1 Denis-Chart/	#Задеплоить Helm Chart app1 из директории Denis-Chart
helm upgrade app1 Denis-Chart/ --set container.image=adv4000/k8sphp:version2	#Обновить Деплоймент app1
helm create MyChart	#Сделать скелет Helm Chart в директории MyChart
helm package Denis-Chart/	#Запаковать Helm Chart в tgz архив
helm install app2 App-HelmChart-0.1.0.tgz	#Задеплоить Helm Chart app2 из архива
helm delete app1	#Удалить Деплоймент Helm Chart app1
helm uninstall app1	#Удалить Деплоймент Helm Chart app1
helm repo add bitnami https://charts.bitnami.com/bitnami	#Добавить Helm Chart Repo от bitnami
helm install my_website bitnami/apache -f my_values.yaml	#Задеплоить Helm Chart bitnami/apache с нашими переменными

minikube start --profile k8s-cluster-1 # создать кластер
/home/aynur/.kube # храняться конфигурационные файлы
kubectl config get-contexts # посмотреть какие есть кластеры
kubectl config get-users # посмотреть какие есть пользоватли
kubectl config set-credentials temp --username=temp --password=superroot # создать пользователя
kubectl config use-context k8s-cluster-1 # переключить кластер
kubectl get pods --all-namespaces # посмотреть все поды
kubectl get nodes  # посмотреть ноды
kubectl config delete-context k8s-cluster-1 # удалить кластер
kubectl apply -f sa-dash.yaml # Создание Pod из дескриптора YAML

#### Запуск Dashboard UI ################
kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"
kubectl proxy
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/.

##################### Lesson 7  Метки, аннотации и пространства имён в Kubernetes ########################
kubectl label po app-kuber-1 environment=dev #Добавить метку ключ-значение (environment=dev)
kubectl get po --show-labels # Показать все Pods и их метки
kubectl get po -L app, environment, run # Вывести колонку с метками app, environment, run
kubectl get po -L '!run' # Select по меткам где нет run
kubectl get po -l app=http-server # Выборка по конкретному ключу, можно также =!
kubectl apply -f kuber-pod.yaml # Создание Pod из дескриптора YAML
kubectl delete po -l run-app-kuber-manual #удалить Pod run-app-kuber-manual

/kubernets/k8s/BAKAVETS/lesson-07/kuber-pod.yaml # Создать метку для Pods с помощью манифестка yaml
/kubernets/k8s/BAKAVETS/lesson-07/kuber-pod-with-gpu.yaml # nodeSelector/Установить только на опеределенные Nods
kubectl label nodes -l {название Nods} gpu=true # Присвоить метку к Nodes gpu=true
kubectl get nodes -l gpu=true # Выборка Nods по метке

kubectl annotate pod app-kuber-2 company_name/creator_email="ku@gmail.com" # Аннотация, это просто комментацрий к объекту. Select нельзя сделать.
kubectl describe po app-kuber-2 # Посмотреть аннатацию

kubectl create namespace project1 # Создать namespace project1
kubectl get namespace # Просмотреть все пространства имен
kubectl get pods --all-namespaces #посмотреть все поды
kubectl apply -f pod.yaml --namespace=project1 # При создании Pod из YAML присваеваем namespace (также namespace можно указать в самом файлу YAML)
kubens # Показывает все namespace
kubens project1 # Переключает namespace на project1
