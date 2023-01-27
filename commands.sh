kubectl run tmp-pod --rm -i --tty --image nicolaka/netshoot -- /bin/bash  # Под для проверки сети


eksctl # Для создания кластера


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
kubectl get events --watch # Просмотр событий, генерируемых контроллерами
kubectl get pods --watch # Просмотр создаваемого и удаляемого модуля в реальном времени
kubectl get pods -o wide #Показывает информацию о сетевых и днс именах
kubectl edit pod app-kuber-1 # Редактировать под, можно поменять nginx 1.10 , например на 1.12
kubectl run app-kuber-1 --image=httpd:latest --port=80 # Создание pods (скачивает контейнер из Docker Hub)
kubectl get pods # Посмотреть статус pods
kubectl delete pods app-kuber-1  #Удалить pods
kubectl describe pods app-kuber-1 # Посмотреть информацию pods
kubectl exec -it app-kuber-1 -- /bin/bash # Войти внутрь контейнера
kubectl exec -it app-kuber-1 --container app-kuber-1 -- /bin/bash # Войти внутрь контейнера, если в одном Pod несколько контейнера
kubectl logs app-kuber-1 # Логи Pod
kubectl get pod app-kuber-1 -o yaml # Посмотреть параметры в виде yaml
kubectl port-forward app-kuber-1 11111:80 # Проброс портов 11111-локальный 8000-Pod (т.е. пример, с Амазона пробрасывается на ПК домашний 127.0.0.1:11111 - откроется сайт)


##############Создание и Управление - DEPLOYMENTS - Это одни и теже Поды на разных Нодах (Автоскелинг)
kubectl create deployment denis-deployment --image adv4000/k8sphp:latest #Создать deployment
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
									type: # Занчения для type при создании с помощью манифеста
											RollingUpdate # Yдаляет старые модули и одновременно добавляет новые
											Recreate # Yдаляет все старые модули перед созданием новых
#####################Создание и Управление - SERVICES - Это интерфейс к DEPLOYMENTS (ClusterIP, NodePort, LoadBalance? ExternalName(или DNS))
kubectl create deployment denis-deployment --image adv4000/k8sphp:latest	#Создать Deployment из Docker Image adv4000/k8sphp:latest
kubectl get deployment	#Показать все Depoyments
kubectl scale deployment denis-deployment --replicas 4										#Создать ReplicaSets
kubectl expose deployment denis-deployment --type=ClusterIP --port 80			#Создать Service типа ClusterIP для Deployment, можно достучаться только из внутри кластера пример  cutl 10.1.1.9
kubectl expose deployment denis-deployment --type=NodePort --port 3123		#Создать Service типа NodePort для Deployment (kubectl describe nodes | grep ExternalIP - поиск используемых внешних ip, потом curl 123.124.13.12:3123 )
kubectl expose deployment denis-deployment --type=LoadBalancer --port 80	#Создать Service типа LoadBalancer  для Deployment, только делается в Клоуде.
kubectl apply -f service-3-loadbalancer-autoscaling.yaml																						#Удалит
																											#Показать все Services
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
kubectl delete ns projectcontour	#Стереть полностью Ingress Controller Contour


############## Helm Charts ################
helm version	#Пока версию Helm
helm list	#Показать все задеплоенные Helm Releases
helm template . # Перейти в папку и запустить, после чего подставит значении и выводит на экран без деплоя
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

############ kubectl config ############
kubectl config get-contexts # посмотреть какие есть кластеры
kubectl config get-users # посмотреть какие есть пользоватли
kubectl config set-credentials temp --username=temp --password=superroot # создать пользователя
kubectl config use-context k8s-cluster-1 # переключить кластер
kubectl config delete-context k8s-cluster-1 # удалить кластер


#### Запуск Dashboard UI ################
kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"
kubectl proxy
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/.

##################### Lesson 7  Метки, аннотации и пространства имён в Kubernetes ########################
kubectl label po app-kuber-1 environment=dev #Добавить метку ключ-значение (environment=dev)
kubectl get pods --show-labels # Показать все Pods и их метки
kubectl get po -L app, environment, run # Вывести колонку с метками app, environment, run
kubectl get po -L '!run' # Select по меткам где нет run
kubectl get po -l app=http-server # Выборка по конкретному ключу, можно также =!
kubectl apply -f kuber-pod.yaml # Создание Pod из дескриптора YAML
kubectl delete po -l run-app-kuber-manual #удалить Pod run-app-kuber-manual


/kubernets/k8s/BAKAVETS/lesson-07/kuber-pod.yaml # Создать метку для Pods с помощью манифестка yaml
/kubernets/k8s/BAKAVETS/lesson-07/kuber-pod-with-gpu.yaml # nodeSelector/Установить только на опеределенные Nods
kubectl label nodes {название Nods} gpu=true # Присвоить метку к Nodes gpu=true
kubectl get nodes -l gpu=true # Выборка Nods по метке

kubectl annotate pod app-kuber-2 company_name/creator_email="ku@gmail.com" # Аннотация, это просто комментацрий к объекту. Select нельзя сделать.


kubens # Показывает все namespace
kubens project1 # Переключает namespace на project1


####################_________Skillbox_______________########################
kubectl get serviceaccount # Показывает сервис аккаунты
/var/run/secrets/kubernetes.io/serviceaccount/ # Хранятся в контейнере сертификаты от ServiceAccount
kubectl get pod poder -o json	# Показывает полный манифест Pods
k get serviceaccount default -o json	#Вывести данные ServiceAccount
k get secret default-token-62nsr -o json #Вывести данные по токену ServiceAccount у default
curl -k https://192.168.49.2:8443 -H "Authorization:Bearer $(kubectl get secret default-token-62nsr -o jsonpath='{.data.token}' | base64 -d)"  # Проверить права у пользователя
kubectl get psp # Посмотреть PodSecurityPolicy
kubectl run nginx --image=nginx -n default --as system:serviceaccount:default:nginx-sa # Создайте утилитой kubectl pod с nginx'ом под сервис-аккаунтом nginx-sa.

###########################______QoS________########################################
QoS - классы:
	- Best Effort # Это когда НЕ задаются limit Request - в случае нехватки ресурса железо, убиваются первыми. 
	- Burstable	  #	Когда limit > Request - средний приоритет на удаления.
	- Guaranteed  # Когда limit == Request - высокий приоритет, удаляется в случае чего последними.
kubectl get pods -o=jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.qosClass}{"\n"}{end}'  # Проверить, что под получил нужный класс QoS

####################_____Metrics____####################
 minikube addons enable metrics-server   # Установите metrics-server в кластер. Для minikube это можно сделать командой
 kubectl top pods # Потребление ресурсов, работает только при наличии metrics-server
 kubectl top nodes # Потребление ресурсов, работает только при наличии metrics-server




###############Книга K8s в действии
kubectl create -f kubia-deployment-v1.yaml --record     # --record - позволит записать данную команду в истории ревизий,
kubectl rollout history deployment kubia                # истории ревизий
kubectl rollout status deployment kubia                 # для проверки статуса развертывания
kubectl rollout undo deployment kubia --to-revision=1   # Откат к определенной версии развертывания

	#### Доступ к серверу API ####
		kubectl proxy # Подключаемся к API на прямую, и будет держать сессию
		curl localhost:8001 # Сервер откликается списком путей и  Группа API (298 стр)	
		
kubectl get componentstatuses  # Проверка статуса компонентов плоскости управления
kubectl get po -o custom-columns=POD:metadata.name,NODE:spec.nodeName --sort-by spec.nodeName -n kube-system	# Компоненты Kubernetes, работающие как модули	

############kubeadm#############
kubeadm certs check-expiratio # посмотреть когда выходит действия сертификата
kubeadm certs renew	      # обновить сертификаты		

