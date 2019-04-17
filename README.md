# Learn Istio By Examples

Follow the examples here as you read the book.

## Install Istio

There are various methods to use and install Istio.

### Using Public Cloud 

Use Istio as a Managed Service from Cloud Providers

#### IBM Cloud

#### Google Cloud

### Using On-premises or Private Cloud

If using private cloud behind firewall of your enterprise

#### Use Istio Helm Chart by a provider

##### Using IBM Cloud Private

##### Using RedHat OpenShift

#### Use Istio from istio.io

We will use this as an example in this book.

Find out latest version of Istio

```
ISTIO_VERSION=$(curl -L -s https://api.github.com/repos/istio/istio/releases/latest | grep tag_name | sed "s/ *\"tag_name\": *\"\\(.*\\)\",*/\\1/")

# echo $ISTIO_VERSION
1.1.2
```

Find out previous releases if you do not want to use the latest release

```
# curl -L -s https://api.github.com/repos/istio/istio/releases | grep tag_name
```

##### Using Helm

Use a helm chart provided through istio.io

We will work on using istio by manually downloading it.

#### Download Istio

Go to https://istio.io

As writing of this, version 1.1.2 is the latest version.

Download using `curl` command.

```
curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.1.2 sh -

Downloaded into istio-1.1.2:
bin  install  istio.VERSION  LICENSE  README.md  samples  tools
Add /root/bin/servicemesh/istio-1.1.2/bin to your path; e.g copy paste in your shell and/or ~/.profile:
export PATH="$PATH:/root/bin/servicemesh/istio-1.1.2/bin"
```

Add istio to your path. Edit `.bashrc` and add PATH. Hint: export PATH is shown above.

Your path may be different depending upon the folder in which you downloaded the Istio

```
ISTIO_VERSION=1.1.2
if [ -d ~/istio-${ISTIO_VERSION}/bin ] ; then
  export PATH="$PATH:~/istio-${ISTIO_VERSION}/bin"
fi
```

Source `.bashrc`

```
source ~/.bashrc
```

Check `istioctl version`

```
# istioctl version

version.BuildInfo{Version:"1.1.2", GitRevision:"2b1331886076df103179e3da5dc9077fed59c989", User:"root", Host:"35adf5bb-5570-11e9-b00d-0a580a2c0205", GolangVersion:"go1.10.4", DockerHub:"docker.io/istio", BuildStatus:"Clean", GitTag:"1.1.1"}
```

#### Install Istio without using mTLS

Makes sure that `ISTIO_VERSION` is set in your `.bashrc`

```
cd ~/istio-${ISTIO_VERSION}/install/kubernetes
kubectl apply -f istio-demo.yaml   

<< Output ommitted>>
service/istio-galley created
service/istio-egressgateway created
service/istio-ingressgateway created
service/grafana created
service/kiali created
service/istio-policy created
service/istio-telemetry created
service/istio-pilot created
service/prometheus created
service/istio-citadel created
service/istio-sidecar-injector created
deployment.extensions/istio-galley created
deployment.extensions/istio-egressgateway created
deployment.extensions/istio-ingressgateway created
deployment.extensions/grafana created
deployment.extensions/kiali created
deployment.extensions/istio-policy created
deployment.extensions/istio-telemetry created
deployment.extensions/istio-pilot created
deployment.extensions/prometheus created
deployment.extensions/istio-citadel created
deployment.extensions/istio-sidecar-injector created
deployment.extensions/istio-tracing created
<< Output ommitted>>

```

Check pod status

```
# kubectl -n istio-system get pods
NAME                                      READY   STATUS      RESTARTS   AGE
grafana-5c45779547-9jxsb                  1/1     Running     0          3m15s
istio-citadel-5bbc997554-8nn4t            1/1     Running     0          3m8s
istio-cleanup-secrets-1.1.2-wc8tw         0/1     Completed   0          3m19s
istio-egressgateway-79df47bcfb-gwzgl      1/1     Running     0          3m17s
istio-galley-5ff6d64c5f-ddpwd             1/1     Running     0          3m18s
istio-grafana-post-install-1.1.2-qxbrl    0/1     Completed   0          3m19s
istio-ingressgateway-5c6bcff97c-wtg9x     1/1     Running     0          3m16s
istio-pilot-69d7cc7c97-84zcd              2/2     Running     0          3m10s
istio-policy-574f8cf96b-x5tml             2/2     Running     5          3m13s
istio-security-post-install-1.1.2-cmtm2   0/1     Completed   0          3m19s
istio-sidecar-injector-549585c8d9-rj9r6   1/1     Running     0          3m7s
istio-telemetry-6c9df8f48b-k4ltv          2/2     Running     5          3m11s
istio-tracing-5fbc94c494-jpdgz            1/1     Running     0          3m7s
kiali-56d95cf466-q8vqt                    1/1     Running     0          3m15s
prometheus-8647cf4bc7-p8b4v               1/1     Running     0          3m9s
```

#### Label istio-lab with istio-injection=enabled

```
kubectl create ns istio-lab
kubectl label namespace istio-lab istio-injection=enabled
```

#### Simulate Load Balancer

Use `keepalived` Helm chart from : [https://github.com/servicemeshistio/keepalived](https://github.com/servicemeshistio/keepalived)

Download Helm Chart

```console
git clone https://github.com/servicemeshistio/keepalived.git
```

Install Helm Chart

Prerequisites:

`ipvs` module is needed by the vip manager.

Make sure that the ip_vs module is loaded.

```
lsmod| grep ^ip_vs
```

If no `ip_vs` module is loaded, install `ipvsadm` 

```console
yum -y install ipvsadm

# ipvsadm -ln
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn

# lsmod | grep ^ip_vs
ip_vs                 145497  0
```

Add the module to `/etc/modules-load.d/ipvs.conf` to load the module in case of a reboot.

```console
echo "ip_vs" > /etc/modules-load.d/ipvs.conf
```

```console
echo Use subnet mask 29 to reserve 6 hosts in 192.168.142.248/29 Class C network.
echo keepalivedCloudProvider.serviceIPRange="192.168.142.248/29"

cd keepalived

helm install . --name keepalived --namespace istio-system \
 --set keepalivedCloudProvider.serviceIPRange="192.168.142.201/32" --tls

```

#### Check load balancer

```console
# kubectl -n istio-system get svc
Name                     TYPE           CLUSTER-IP   EXTERNAL-IP       PORT(S)                                                                                                                                      AGE
grafana                  ClusterIP      10.0.0.65    <none>            3000/TCP                                                                                                                                     86m
istio-citadel            ClusterIP      10.0.0.75    <none>            8060/TCP,15014/TCP                                                                                                                           86m
istio-egressgateway      ClusterIP      10.0.0.244   <none>            80/TCP,443/TCP,15443/TCP                                                                                                                     86m
istio-galley             ClusterIP      10.0.0.90    <none>            443/TCP,15014/TCP,9901/TCP                                                                                                                   86m
istio-ingressgateway     LoadBalancer   10.0.0.229   192.168.142.249   80:31380/TCP,443:31390/TCP,31400:31400/TCP,15029:31730/TCP,15030:31651/TCP,15031:30465/TCP,15032:32041/TCP,15443:31112/TCP,15020:30638/TCP   86m
istio-pilot              ClusterIP      10.0.0.63    <none>            15010/TCP,15011/TCP,8080/TCP,15014/TCP                                                                                                       86m
istio-policy             ClusterIP      10.0.0.88    <none>            9091/TCP,15004/TCP,15014/TCP                                                                                                                 86m
istio-sidecar-injector   ClusterIP      10.0.0.120   <none>            443/TCP                                                                                                                                      86m
istio-telemetry          ClusterIP      10.0.0.45    <none>            9091/TCP,15004/TCP,15014/TCP,42422/TCP                                                                                                       86m
jaeger-agent             ClusterIP      None         <none>            5775/UDP,6831/UDP,6832/UDP                                                                                                                   86m
jaeger-collector         ClusterIP      10.0.0.54    <none>            14267/TCP,14268/TCP                                                                                                                          86m
jaeger-query             ClusterIP      10.0.0.14    <none>            16686/TCP                                                                                                                                    86m
kiali                    ClusterIP      10.0.0.92    <none>            20001/TCP                                                                                                                                    86m
prometheus               ClusterIP      10.0.0.218   <none>            9090/TCP                                                                                                                                     86m
tracing                  ClusterIP      10.0.0.135   <none>            80/TCP                                                                                                                                       86m
zipkin                   ClusterIP      10.0.0.158   <none>            9411/TCP                                                                                                                                     86m

```

#### Run bookinfo with proxy

How to enable Istio for an existing application.

Method 1: Use istioctl to generate the modified yaml that will include proxy cars.

How to enable Istio for new application application.

Let's delete the earlier `istio-lab` name space. 

```console
kubectl delete ns istio-lab
```

Create name space and label for the web hooks to create proxy sidecar

```console
kubectl create ns istio-lab

kubectl label namespace istio-lab istio-injection=enabled
```

Deploy application

```console
kubectl -n istio-lab apply -f bookinfo.yaml 

service/details created
deployment.extensions/details-v1 created
service/ratings created
deployment.extensions/ratings-v1 created
service/reviews created
deployment.extensions/reviews-v1 created
deployment.extensions/reviews-v2 created
deployment.extensions/reviews-v3 created
service/productpage created
deployment.extensions/productpage-v1 created

```

Check pods

```console
# kubectl -n istio-lab get pods
NAME                              READY   STATUS    RESTARTS   AGE
details-v1-bc557b7fc-5vn22        2/2     Running   0          42s
productpage-v1-6597cb5df9-pqx8s   2/2     Running   0          40s
ratings-v1-5c46fc6f85-5tw4n       2/2     Running   0          42s
reviews-v1-69dcdb544-nglxq        2/2     Running   0          42s
reviews-v2-65fbdc9f88-lttjs       2/2     Running   0          41s
reviews-v3-bd8855bdd-85flj        2/2     Running   0          40s
```

### Run application

Multiple cases:

* Run using pod's internal IP address

  Find Pod's IP address for `productpage`  

  ```console
  # kubectl -n istio-lab get pods -o wide
  NAME                              READY   STATUS    RESTARTS   AGE   IP             NODE              NOMINATED NODE
  details-v1-bc557b7fc-99d4b        2/2     Running   0          21s   10.1.230.230   192.168.142.101   <none>
  productpage-v1-6597cb5df9-jqhcq   2/2     Running   0          18s   10.1.230.246   192.168.142.101   <none>
  ratings-v1-5c46fc6f85-pvh9l       2/2     Running   0          21s   10.1.230.231   192.168.142.101   <none>
  reviews-v1-69dcdb544-6dbpz        2/2     Running   0          21s   10.1.230.214   192.168.142.101   <none>
  reviews-v2-65fbdc9f88-4bpl5       2/2     Running   0          20s   10.1.230.247   192.168.142.101   <none>
  reviews-v3-bd8855bdd-zb5zk        2/2     Running   0          19s   10.1.230.201   192.168.142.101   <none>
  ```

  In above case, it is `10.1.230.246`. This IP address will be different for you.

  Test the service:

  ```console
  curl -s http://10.1.230.246:9080 | grep title
  <title>Simple Bookstore App</title>
  ```

* Run using internal service name's IP address - requires server access using local service name

  ```console
  # kubectl -n istio-lab get svc
  NAME          TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
  details       ClusterIP   10.0.0.181   <none>        9080/TCP   102s
  productpage   ClusterIP   10.0.0.20    <none>        9080/TCP   100s
  ratings       ClusterIP   10.0.0.66    <none>        9080/TCP   102s
  reviews       ClusterIP   10.0.0.45    <none>        9080/TCP   102s
  ```
  The productpage service address is `10.0.0.20`. This IP address will be different for you.

  Test the service

  ```console
  # curl -s http://10.0.0.20:9080 | grep title
    <title>Simple Bookstore App</title>
  ```

  The service IP address does not change for the life time of service. However, the pod address may change depending upon the node on which it gets scheduled.

  The connection between pod's IP address and service IP address is through the endpoints.

  ```console
  # kubectl -n istio-lab get ep
  NAME          ENDPOINTS                                               AGE
  details       10.1.230.230:9080                                       2m48s
  productpage   10.1.230.246:9080                                       2m46s
  ratings       10.1.230.231:9080                                       2m48s
  reviews       10.1.230.201:9080,10.1.230.214:9080,10.1.230.247:9080   2m48s
  ```
  Notice that the productpage service endpoint is `10.1.230.246` which is the pod's IP address.

  The service name can also be used provided Kubernetes internal DNS server is on the search list.

  Check the IP address of the internal service name.

  ```console
  # dig +short productpage.istio-lab.svc.cluster.local @10.0.0.10
  10.0.0.20
  ```

  This IP address `10.0.0.20` is the IP address of the FQDN of the service name.

  Open a browser from inside the VM and try `http://10.0.0.20:9080/` and `http://10.0.0.20:9080/` and you should be able to see the product page.

* Run using a node port - requires server IP address - Run from outside the cluster but requires IP address for the cluster

  You can also view the service web page from outside VM but within the firewall of an enterprise by using the server's IP address. This would require changing the service from `ClusterIP` to the `NodePort`.

  ```console
  kubectl -n istio-lab edit svc productpage
  ```

  And change the type from `ClusterIP` to `NodePort` 

  From:

  ```console
    selector:
    app: productpage
  sessionAffinity: None
  type: ClusterIP

  ```

  To:
  ```console
    selector:
    app: productpage
  sessionAffinity: None
  type: NodePort
  ```

  And save the file and again check the services.

  ```console
  # kubectl -n istio-lab get svc
  NAME          TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)          AGE
  details       ClusterIP   10.0.0.181   <none>        9080/TCP         10m
  productpage   NodePort    10.0.0.20    <none>        9080:30306/TCP   10m
  ratings       ClusterIP   10.0.0.66    <none>        9080/TCP         10m
  reviews       ClusterIP   10.0.0.45    <none>        9080/TCP         10m
  ```

  Notice the `NodePort` for the`productpage` service is `30306`. This port number will be different in your case.

  Now, you can open a browser from outside the VM (or cluster in reality) and access the `productpage`. 

  Find out the IP address of the VM or master node of the ICP (or Kubernetes) cluster.

  ```console
  # kubectl get nodes
  NAME              STATUS   ROLES                                 AGE   VERSION
  192.168.142.101   Ready    etcd,management,master,proxy,worker   29d   v1.12.4+icp
  ```

  The IP address of the node is `192.168.142.101` and the node port is `30306`.

  If you open the browser to http://192.168.142.101:30306 from outside the VM, you should be able to access the service.

* Run using a load balancer IP address from outside the cluster

  It may so happen that the ICP or Kubernetes cluster is behind the firewall and not accessible to the outside world. In that case, we may have an external load balancer that we can use to route the traffic from internal service to the outside.

  We are simulating an external load balancer using `keepalived` but using IP address on the same subnet range of the VM. In reality, you will get an external IP addresses against the `istio-ingress-gatewaey` if an external load balancer is configured.

  In our case, find out the external IP address.

  ```console
  # kubectl -n istio-system get svc | grep ingressgateway
  istio-ingressgateway     LoadBalancer   10.0.0.223   192.168.142.250   80:31380/TCP,443:31390/TCP,31400:31400/TCP,15029:32030/TCP,15030:30237/TCP,15031:30824/TCP,15032:30965/TCP,15443:31507/TCP,15020:31796/TCP   172m
  ```

  Notice that the external IP address assigned to `istio-ingressgateway` is `192.168.142.250`. We can access the service web page by using `http://192.168.142.250`.

  Try accessing the web page and you will notice that the page did not work.

  Now, we now to create a gateway and virtual services so that the request can be routed properly when it comes to the 

  Create Istio Gateway and Virtual Service `istio-ingressgateway`

  ### Istio Gateway and Virtual Service Definition

  Run YAML 01-create-gateway-virtual-service has definition for a gateway and virtual service.

  ```yaml
  apiVersion: networking.istio.io/v1alpha3
  kind: Gateway
  metadata:
    name: bookinfo-gateway
  spec:
    selector:
      istio: ingressgateway # use istio default controller
    servers:
    - port:
        number: 80
        name: http
        protocol: HTTP
      hosts:
      - "*"
  ---
  apiVersion: networking.istio.io/v1alpha3
  kind: VirtualService
  metadata:
    name: bookinfo
  spec:
    hosts:
    - "*"
    gateways:
    - bookinfo-gateway
    http:
    - match:
      - uri:
          exact: /productpage
      - uri:
          prefix: /static      
      - uri:
          exact: /login
      - uri:
          exact: /logout
      - uri:
          prefix: /api/v1/products
      route:
      - destination:
          host: productpage
          port:
            number: 9080
  EOF
  ```

  ### Create Gateway and Virtual Service

  ```console
  kubectl -n istio-lab apply -f 01-create-gateway-virtual-service.yaml 

  gateway.networking.istio.io/bookinfo-gateway created
  virtualservice.networking.istio.io/bookinfo created
  ```

  Define gateway - how it is working

  Define Virtual Service - how it is working

  Check Gateway and Virtual Service

  ```console
  # kubectl -n istio-lab get gateway
  NAME               AGE
  bookinfo-gateway   2m

  # kubectl -n istio-lab get virtualservice
  NAME       GATEWAYS             HOSTS   AGE
  bookinfo   [bookinfo-gateway]   [*]     3m
  ```

  We are redirecting url path `/productpage` to internal service `productpage` at port `9080`.

  Try accessing the url: [http://192.168.142.250/productpage](http://192.168.142.250/productpage)

  If the IP address is defined in the DNS server, the internal service can be accessed using a domain name. 

## Destination rules

DestinationRule is defining subsets for every service within BookInfo. Subset is using pod labels through which routing rules can be defined.

Run script `kubectl -n istio-lab apply -f 02-create-destination-rules.yaml`

Contents of 02-create-destination-rules.yaml

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: productpage
spec:
  host: productpage
  subsets:
  - name: v1
    labels:
      version: v1
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: reviews
spec:
  host: reviews
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
  - name: v3
    labels:
      version: v3
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: ratings
spec:
  host: ratings
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
  - name: v2-mysql
    labels:
      version: v2-mysql
  - name: v2-mysql-vm
    labels:
      version: v2-mysql-vm
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: details
spec:
  host: details
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
---
```
## Virtual Service using subsets

What is a virtual service and what different things can be accomplished?

Run script `kubectl -n istio-lab apply -f 03-create-reviews-virtual-service.yaml`

Contents of 03-create-reviews-virtual-service.yaml

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: productpage
spec:
  hosts:
  - productpage
  http:
  - route:
    - destination:
        host: productpage
        subset: v1
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
  - reviews
  http:
  - route:
    - destination:
        host: reviews
        subset: v2
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ratings
spec:
  hosts:
  - ratings
  http:
  - route:
    - destination:
        host: ratings
        subset: v1
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: details
spec:
  hosts:
  - details
  http:
  - route:
    - destination:
        host: details
        subset: v1
---
```
## Identity Based Traffic Routing

Change route configuration so all traffic from a specific user "Jason" will be routed to reviews-v2

Run script `kubectl -n istio-lab apply -f 04-create-reviews-user-virtual-service.yaml`


## Traffic Shifting

Gradually migrate traffic from one microservice to another based on weight. For instance, send 50% of traffic from reviews-v1 to reviews-v3. 

Validate Bookinfo virtual service for productpage, ratings, reviews and details is up by running `kubectl get virtualservice` OR `k get vs`

```console
[root@osc01 (istio-lab)istio-scripts]# k get vs
NAME          GATEWAYS             HOSTS           AGE
bookinfo      [bookinfo-gateway]   [*]             1h
details                            [details]       1h
productpage                        [productpage]   1h
ratings                            [ratings]       1h
reviews                            [reviews]       1h
```
Apply the following YAML to transfer 50% traffic from reviews-1 to reviews-3.

```console
[root@osc01 (istio-lab)istio-scripts]# kubectl -n istio-lab apply -f 05-apply-weight-based-routing.yaml
virtualservice.networking.istio.io/reviews configured
```

Confirm the rule was replaced for reviews microservice by running `kubectl get virtualservice reviews -o yaml` OR `k get vs reviews -o yaml`

```console
[root@osc01 (istio-lab)istio-scripts]# k get vs reviews -o yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"networking.istio.io/v1alpha3","kind":"VirtualService","metadata":{"annotations":{},"name":"reviews","namespace":"istio-lab"},"spec":{"hosts":["reviews"],"http":[{"route":[{"destination":{"host":"reviews","subset":"v1"},"weight":50},{"destination":{"host":"reviews","subset":"v3"},"weight":50}]}]}}
  creationTimestamp: 2019-04-16T02:05:31Z
  generation: 1
  name: reviews
  namespace: istio-lab
  resourceVersion: "50804"
  selfLink: /apis/networking.istio.io/v1alpha3/namespaces/istio-lab/virtualservices/reviews
  uid: 1cfbe884-5fec-11e9-9989-00505632f6a0
spec:
  hosts:
  - reviews
  http:
  - route:
    - destination:
        host: reviews
        subset: v1
      weight: 50
    - destination:
        host: reviews
        subset: v3
      weight: 50
```
Submit 100% of the traffic to reviews-3 microservice.

```Console
[root@osc01 (istio-lab)istio-scripts]# kubectl -n istio-lab apply -f 06-apply-total-weight-based-routing.yaml
virtualservice.networking.istio.io/reviews configured
```


## Fault Injection

Test microservice resiliency by injecting faults

### Injecting HTTP delay fault

Inject a 7 second delay between reviews-v2 and ratings microservice for user "Jason". This is an intentional because the there are hardcode timeouts in the microservice. 

Run script 
```console
[root@osc01 (istio-lab)istio-scripts]# kubectl -n istio-lab apply -f 07-inject-fault-user-trafficdelay.yaml
virtualservice.networking.istio.io/ratings configured
```

After 7 seconds, the reviews section will display an error message:
```
Error fetching product reviews!
Sorry, product reviews are currently unavailable for this book.
```
There are hardcoded timeouts between `productpage` and `reviews` page at 6 seconds.
There are hardcoded tiemouts between `reviews` and `ratings` page at 10 seconds. 

Introducing the new 7 second delay, the `productpage` times out premarturely. Fault injection helps identify such anomalies without impacting end users. 

If you logout of "Jason" user, the error will go away. 

### Inject HTTP abort fault

To test microservice resiliency, introduce HTTP abort fault. 

Run script
```console
[root@osc01 (istio-lab)istio-scripts]# kubectl -n istio-lab apply -f 08-inject-fault-user-aborttest.yaml
virtualservice.networking.istio.io/ratings configured
```

Validate the `ratings` virtual service has applied the changes by running `k get vs ratings -o yaml`

The HTTP abort to the ratings microservice for user "Jason" will load "Ratings service is not available". 

If you logout of "Jason" user, the error will go away. 

## TCP Traffic Shifting 

Migrate TCP traffice from one version of a microservice to another. To accomplish this goal, configure a sequence of rules that route percentage of TCp traffic from one service to another. 

In this task, we will deploy the tcp-echo-v1 microserive. Send 100% to this new service and route 20% of the TCP traffic to tcp-echo-v2

Deploy the `tcp-echo` microservice:

```console
[root@osc01 (istio-lab)istio-scripts]# kubectl -n istio-lab apply -f 09-create-tcpecho-service.yaml
service/tcp-echo created
deployment.extensions/tcp-echo-v1 created
deployment.extensions/tcp-echo-v2 created
```

Next, enable all TCP traffic to tcp-echo-v1 microservice:

Run script:
```console
[root@osc01 (istio-lab)istio-scripts]# kubectl -n istio-lab apply -f 10-apply-tcpecho-v1-routealltraffic.yaml
gateway.networking.istio.io/tcp-echo-gateway created
destinationrule.networking.istio.io/tcp-echo-destination created
virtualservice.networking.istio.io/tcp-echo created
```

```
Validate the `tcp-echo` microservices are running:

```console
[root@osc01 (istio-lab)istio-scripts]# kgp
NAME                              READY   STATUS    RESTARTS   AGE
details-v1-8548c7db94-6bg57       2/2     Running   6          45h
productpage-v1-84cc5ff8d4-5f2m5   2/2     Running   6          45h
ratings-v1-bb7c878-ncpjh          2/2     Running   6          45h
reviews-v1-7d56484db5-nb4vj       2/2     Running   6          45h
reviews-v2-65f775cff6-45wx6       2/2     Running   6          45h
reviews-v3-75594d8d75-gpq4s       2/2     Running   6          45h
tcp-echo-v1-8694f878bf-xbt5h      2/2     Running   0          7m3s
tcp-echo-v2-777dfc4954-dzfrv      2/2     Running   0          7m3s
```

Next, obtain the INGRESS_HOST value so traffic can be sent to the microservice.

Run the following command to get the `Ingress Host` variable:

```console
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="tcp")].port}')
```
Find out the value:
```console
[root@osc01 (istio-system)istio-scripts]# echo $INGRESS_PORT
31400
```
Validate the Ingress host, port are available:

```console
[root@osc01 (istio-lab)istio-scripts]# export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
[root@osc01 (istio-lab)istio-scripts]# export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="tcp")].port}')
[root@osc01 (istio-lab)istio-scripts]# echo $INGRESS_HOST
192.168.142.250
[root@osc01 (istio-lab)istio-scripts]# echo $INGRESS_PORT
31400
```

Send some TCP traffic to the tcp-echo microservice:

```console
[root@osc01 (istio-lab)istio-scripts]# for i in {1..10}; do \
> docker run -e INGRESS_HOST=$INGRESS_HOST -e INGRESS_PORT=$INGRESS_PORT -it --rm busybox sh -c "(date; sleep 1) | nc $INGRESS_HOST $INGRESS_PORT"; \
> done
one Wed Apr 17 02:52:06 UTC 2019
one Wed Apr 17 02:52:08 UTC 2019
one Wed Apr 17 02:52:10 UTC 2019
one Wed Apr 17 02:52:12 UTC 2019
one Wed Apr 17 02:52:13 UTC 2019
one Wed Apr 17 02:52:15 UTC 2019
one Wed Apr 17 02:52:17 UTC 2019
one Wed Apr 17 02:52:19 UTC 2019
one Wed Apr 17 02:52:20 UTC 2019
one Wed Apr 17 02:52:22 UTC 2019
```
The prefix of `one` signifies that all traffic was routed to the v1 of tcp-echo microservice.

Next, setup environment to send 20% of the traffic from tcp-echo-v1 to tcp-echo-v2.

Run script:
```console
[root@osc01 (istio-lab)istio-scripts]# kubectl -n istio-lab apply -f 11-apply-tcpecho-v1-route20traffic.yaml
virtualservice.networking.istio.io/tcp-echo configured
```

Send 20% TCP traffic:

```console
[root@osc01 (istio-lab)istio-scripts]# for i in {1..10}; do \
> docker run -e INGRESS_HOST=$INGRESS_HOST -e INGRESS_PORT=$INGRESS_PORT -it --rm busybox sh -c "(date; sleep 1) | nc $INGRESS_HOST $INGRESS_PORT"; \
> done
two Wed Apr 17 02:59:42 UTC 2019
one Wed Apr 17 02:59:44 UTC 2019
one Wed Apr 17 02:59:45 UTC 2019
one Wed Apr 17 02:59:47 UTC 2019
two Wed Apr 17 02:59:49 UTC 2019
one Wed Apr 17 02:59:50 UTC 2019
one Wed Apr 17 02:59:52 UTC 2019
one Wed Apr 17 02:59:54 UTC 2019
one Wed Apr 17 02:59:56 UTC 2019
one Wed Apr 17 02:59:57 UTC 2019
```

2 out of the 10 timestamps have a `two`, meaning that 80% of all TCP traffic was routed to v1, whereas 20% was routed to v2.

## Request Timeouts

HTTP request timeouts can be specified using the timeout filed within a route rule within YAML. In default, this is set at 15 seconds. In this exercise, the timeout will be 1 second. 

To see this occur, 2 second artificial delay in any calls to the `ratings ` service will be introduced. 

Route requests to reviews-v2
```console
[root@osc01 (istio-lab)istio-scripts]# kubectl -n istio-lab apply -f 12-create-reviews-route-requests.yaml
virtualservice.networking.istio.io/reviews configured
```

Next, add a 2 second delay to calls to rating service
```console
[root@osc01 (istio-lab)istio-scripts]# kubectl -n istio-lab apply -f 13-apply-ratings-2secdelay.yaml
virtualservice.networking.istio.io/ratings configured
```
Go to BookInfo web console and refresh the page, make sure to logout from any users. 

The application will be working normally, but there is a 2 second delay with every refresh. To validate the time, go to `developers tools` in Chrome/Firefox browser and validate the time under the `network` tab.

Next, add a half a second request timeout for calls to reviews service.

```console
[root@osc01 (istio-lab)istio-scripts]# kubectl -n istio-lab apply -f 14-apply-reviews-0.5sectimeout.yaml
virtualservice.networking.istio.io/reviews configured
```
With this update, the returns are in 1 second instead of 2 (leverage Browser - Developer tools to validate) and the reviews are unavailable.

Reason why the responses take 1 second, even though a 0.5 second timeout is configured, is because there is a hard coded re-try within the productpage microservice so its saying the reviews service is timing out twice before returning. 

## Circuit Breaker

In this exercise, this shows you how to configure circuit breaking for connections, requests and outlier detection and intentionally `tripping` the circuit breaker.

Circuit breaking creates resilient microservices and allows application writes that limit failures, latency spikes and other network pecularities.

Before getting started, deploy the `HTTPbin` microservice:

```console
[root@osc01 (istio-lab)istio-scripts]# kubectl -n istio-lab apply -f 15-create-httpbin-service.yamlservice/httpbin created
deployment.extensions/httpbin created
```

Validate the service pods for `HTTPbin` are available:

```console
[root@osc01 (istio-lab)istio-scripts]# kgp
NAME                              READY   STATUS    RESTARTS   AGE
details-v1-8548c7db94-6bg57       2/2     Running   6          46h
httpbin-5fc7cf895d-84nl4          2/2     Running   0          10m
productpage-v1-84cc5ff8d4-5f2m5   2/2     Running   6          46h
ratings-v1-bb7c878-ncpjh          2/2     Running   6          46h
reviews-v1-7d56484db5-nb4vj       2/2     Running   6          46h
reviews-v2-65f775cff6-45wx6       2/2     Running   6          46h
reviews-v3-75594d8d75-gpq4s       2/2     Running   6          46h
tcp-echo-v1-8694f878bf-xbt5h      2/2     Running   0          81m
tcp-echo-v2-777dfc4954-dzfrv      2/2     Running   0          81m
```

Create an `HTTPbin` destination rule.

Note: if the existing istio install has `mTLS` authentication enabled,define a `TLS mode: MUTUAL` to the `HTTPbin` destination rule YAML.

```console
[root@osc01 (istio-lab)istio-scripts]# kubectl -n istio-lab apply -f 16-create-httpbin-destination-rule.ymal
destinationrule.networking.istio.io/httpbin created
```

Validate the destination rule was created:

```console
[root@osc01 (istio-lab)istio-scripts]# k get dr httpbin
NAME      HOST      AGE
httpbin   httpbin   2m
```

Next, create a client called `fortio` with sidecar proxy that will send traffic to `HTTPbin` service. This is primiarily to load test the connections, concurrency and delays for all HTTP calls. 

`fortio` will also trip the circuit breaker policies that are defined in the `HTTPbin` destination rule.

```console
[root@osc01 (istio-lab)istio-scripts]# kubectl apply -f <(istioctl kube-inject -f 17-create-client-fortio.yaml)
service/fortio created
deployment.apps/fortio-deploy created
```

Once deployed, login to the fortio client pod:

```console
[root@osc01 (istio-lab)istio-scripts]# FORTIO_POD=$(kubectl get pod | grep fortio | awk '{ print $1 }')
```

Use `fortio` to call `HTTPbin` service through `-curl` to indicate that you want to make 1 call:

```console
[root@osc01 (istio-lab)istio-scripts]# kubectl exec -it $FORTIO_POD  -c fortio /usr/bin/fortio -- load -curl  http://httpbin:8000/get
HTTP/1.1 200 OK
server: envoy
date: Wed, 17 Apr 2019 03:55:20 GMT
content-type: application/json
content-length: 371
access-control-allow-origin: *
access-control-allow-credentials: true
x-envoy-upstream-service-time: 2

{
  "args": {},
  "headers": {
    "Content-Length": "0",
    "Host": "httpbin:8000",
    "User-Agent": "fortio.org/fortio-1.3.1",
    "X-B3-Parentspanid": "616a055736063b89",
    "X-B3-Sampled": "1",
    "X-B3-Spanid": "8b1ef9801f095f37",
    "X-B3-Traceid": "1e9f662f0206c78d616a055736063b89"
  },
  "origin": "127.0.0.1",
  "url": "http://httpbin:8000/get"
}
```

Now that the `fortio` client pod can make successful calls to the `HTTPbin` service, let's trip the circuit breaker.

Within the `HTTPbin` destination rule: 
For TCP, there is 1 `maxConnections`
For HTTP, there is 1 `http1MaxPendingRequests`

What this means is if you exceed 1 connection and request concurrently, the istio-proxy will show failures when the circuit is opened for more-than-1 connections and requests.

Call the `HTTPbin` service with 2 (not 1) conncurent connections and send 20 (not 1) requests.

```console
[root@osc01 (istio-lab)istio-scripts]# kubectl exec -it $FORTIO_POD  -c fortio /usr/bin/fortio -- load -c 2 -qps 0 -n 20 -loglevel Warning http://httpbin:8000/get
04:03:46 I logger.go:97> Log level is now 3 Warning (was 2 Info)
Fortio 1.3.1 running at 0 queries per second, 8->8 procs, for 20 calls: http://httpbin:8000/get
Starting at max qps with 2 thread(s) [gomax 8] for exactly 20 calls (10 per thread + 0)
04:03:46 W http_client.go:679> Parsed non ok code 503 (HTTP/1.1 503)
04:03:46 W http_client.go:679> Parsed non ok code 503 (HTTP/1.1 503)
Ended after 77.394694ms : 20 calls. qps=258.42
Aggregated Function Time : count 20 avg 0.00760278 +/- 0.006768 min 0.001263203 max 0.027271238 sum 0.152055601
# range, mid point, percentile, count
>= 0.0012632 <= 0.002 , 0.0016316 , 5.00, 1
> 0.002 <= 0.003 , 0.0025 , 10.00, 1
> 0.003 <= 0.004 , 0.0035 , 25.00, 3
> 0.004 <= 0.005 , 0.0045 , 30.00, 1
> 0.005 <= 0.006 , 0.0055 , 55.00, 5
> 0.006 <= 0.007 , 0.0065 , 70.00, 3
> 0.007 <= 0.008 , 0.0075 , 75.00, 1
> 0.008 <= 0.009 , 0.0085 , 90.00, 3
> 0.025 <= 0.0272712 , 0.0261356 , 100.00, 2
# target 50% 0.0058
# target 75% 0.008
# target 90% 0.009
# target 99% 0.0270441
# target 99.9% 0.0272485
Sockets used: 4 (for perfect keepalive, would be 2)
Code 200 : 18 (90.0 %)
Code 503 : 2 (10.0 %)
Response Header Sizes : count 20 avg 207.1 +/- 69.03 min 0 max 231 sum 4142
Response Body/Total Sizes : count 20 avg 564.4 +/- 110.3 min 217 max 602 sum 11288
All done 20 calls (plus 0 warmup) 7.603 ms avg, 258.4 qps
```

Overall, almost all requests made it through where the istio-proxy has some leniency:

```console
Code 200 : 18 (90.0 %)
Code 503 : 2 (10.0 %)
```

Call the `HTTPbin` service with 3 (not 2) conncurent connections and send 30 (not 20) requests.

```console
[root@osc01 (istio-lab)istio-scripts]# kubectl exec -it $FORTIO_POD  -c fortio /usr/bin/fortio -- load -c 3 -qps 0 -n 30 -loglevel Warning http://httpbin:8000/get
04:06:58 I logger.go:97> Log level is now 3 Warning (was 2 Info)
Fortio 1.3.1 running at 0 queries per second, 8->8 procs, for 30 calls: http://httpbin:8000/get
Starting at max qps with 3 thread(s) [gomax 8] for exactly 30 calls (10 per thread + 0)
04:06:58 W http_client.go:679> Parsed non ok code 503 (HTTP/1.1 503)
04:06:58 W http_client.go:679> Parsed non ok code 503 (HTTP/1.1 503)
04:06:58 W http_client.go:679> Parsed non ok code 503 (HTTP/1.1 503)
04:06:58 W http_client.go:679> Parsed non ok code 503 (HTTP/1.1 503)
04:06:58 W http_client.go:679> Parsed non ok code 503 (HTTP/1.1 503)
04:06:58 W http_client.go:679> Parsed non ok code 503 (HTTP/1.1 503)
04:06:58 W http_client.go:679> Parsed non ok code 503 (HTTP/1.1 503)
04:06:58 W http_client.go:679> Parsed non ok code 503 (HTTP/1.1 503)
04:06:58 W http_client.go:679> Parsed non ok code 503 (HTTP/1.1 503)
04:06:58 W http_client.go:679> Parsed non ok code 503 (HTTP/1.1 503)
04:06:58 W http_client.go:679> Parsed non ok code 503 (HTTP/1.1 503)
04:06:58 W http_client.go:679> Parsed non ok code 503 (HTTP/1.1 503)
Ended after 57.799732ms : 30 calls. qps=519.03
Aggregated Function Time : count 30 avg 0.0038989608 +/- 0.003022 min 0.000331027 max 0.01162842 sum 0.116968824
# range, mid point, percentile, count
>= 0.000331027 <= 0.001 , 0.000665514 , 30.00, 9
> 0.001 <= 0.002 , 0.0015 , 36.67, 2
> 0.002 <= 0.003 , 0.0025 , 43.33, 2
> 0.003 <= 0.004 , 0.0035 , 60.00, 5
> 0.004 <= 0.005 , 0.0045 , 66.67, 2
> 0.005 <= 0.006 , 0.0055 , 70.00, 1
> 0.006 <= 0.007 , 0.0065 , 76.67, 2
> 0.007 <= 0.008 , 0.0075 , 93.33, 5
> 0.008 <= 0.009 , 0.0085 , 96.67, 1
> 0.011 <= 0.0116284 , 0.0113142 , 100.00, 1
# target 50% 0.0034
# target 75% 0.00675
# target 90% 0.0078
# target 99% 0.0114399
# target 99.9% 0.0116096
Sockets used: 13 (for perfect keepalive, would be 3)
Code 200 : 18 (60.0 %)
Code 503 : 12 (40.0 %)
Response Header Sizes : count 30 avg 138 +/- 112.7 min 0 max 230 sum 4140
Response Body/Total Sizes : count 30 avg 449.66667 +/- 185.5 min 217 max 601 sum 13490
All done 30 calls (plus 0 warmup) 3.899 ms avg, 519.0 qps
[root@osc01 (istio-lab)istio-scripts]#
```

As the number of connections and requests went up, the circuit breaker behavior is expected. Only 60% of the requests succeeded as the remaining 40% are trapped by the circuit breaker.

```console
Code 200 : 18 (60.0 %)
Code 503 : 12 (40.0 %)
```

Query the `istio-proxy` by logging into the `fortio` pod to see further stats on circuit breaker:

```console
[root@osc01 (istio-lab)istio-scripts]# kubectl exec -it fortio-deploy-75f598c8dd-mhjt8  -c istio-proxy  -- sh -c 'curl localhost:15000/stats' | grep httpbin | grep pending
cluster.outbound|8000||httpbin.istio-lab.svc.cluster.local.circuit_breakers.default.rq_pending_open: 0
cluster.outbound|8000||httpbin.istio-lab.svc.cluster.local.circuit_breakers.high.rq_pending_open: 0
cluster.outbound|8000||httpbin.istio-lab.svc.cluster.local.upstream_rq_pending_active: 0
cluster.outbound|8000||httpbin.istio-lab.svc.cluster.local.upstream_rq_pending_failure_eject: 0
cluster.outbound|8000||httpbin.istio-lab.svc.cluster.local.upstream_rq_pending_overflow: 21
cluster.outbound|8000||httpbin.istio-lab.svc.cluster.local.upstream_rq_pending_total: 81
```



Through the `upstream_rq_pending_overflow` value, 21 calls have been flagged for circuit breaking for service `HTTPbin` by client `fortio`.

## Mirroring

This task demonstrates traffic mirroring, also called shadowing, capabilities. This allows teams to bring production changes with little risk because mirroring sends copy of live traffic to a mirrored service. 

In this exercise, force all `HTTPbin` service traffic to version 1. Then, apply a rule to mirror a portion of that traffic to version 2.

Deploy `HTTPbin` service, version 1

```console
[root@osc01 (istio-lab)istio-scripts]# kubectl -n istio-lab apply -f 18-deploy-httpbin-v1.yaml
deployment.extensions/httpbin-v1 created
```

Deploy `HTTPbin` service, version 2

```console
[root@osc01 (istio-lab)istio-scripts]# kubectl -n istio-lab apply -f 19-deploy-httpbin-v2.yaml
deployment.extensions/httpbin-v2 created
```

Validate the two version of `HTTPbin` are up and running

```console
[root@osc01 (istio-lab)istio-scripts]# kgp
NAME                              READY   STATUS    RESTARTS   AGE
details-v1-8548c7db94-6bg57       2/2     Running   6          47h
fortio-deploy-75f598c8dd-mhjt8    2/2     Running   0          50m
httpbin-5fc7cf895d-84nl4          2/2     Running   0          65m
httpbin-v1-6569dfb499-r7xhh       2/2     Running   0          4m29s
httpbin-v2-67c5fc7ffb-9qr7k       2/2     Running   0          57s
productpage-v1-84cc5ff8d4-5f2m5   2/2     Running   6          47h
ratings-v1-bb7c878-ncpjh          2/2     Running   6          47h
reviews-v1-7d56484db5-nb4vj       2/2     Running   6          47h
reviews-v2-65f775cff6-45wx6       2/2     Running   6          47h
reviews-v3-75594d8d75-gpq4s       2/2     Running   6          47h
tcp-echo-v1-8694f878bf-xbt5h      2/2     Running   0          136m
tcp-echo-v2-777dfc4954-dzfrv      2/2     Running   0          136m
```

Deploy and start the `HTTPbin` sleep service extension to leverage curl command for load

```console
[root@osc01 (istio-lab)istio-scripts]# kubectl -n istio-lab apply -f 20-deploy-httpbin-sleep.yaml
deployment.extensions/sleep created

```

By default, kubernetes will load balance both version of `HTTPbin` service. To change that behavior, all traffic will be routed to `HTTPbin` version 1 service.

Note: if the existing istio install has `mTLS` authentication enabled,define a `TLS mode: MUTUAL` to the `HTTPbin` destination rule YAML.

```console
[root@osc01 (istio-lab)istio-scripts]# kubectl -n istio-lab apply -f 21-route-httpbin-alltraffic-v1.yaml
virtualservice.networking.istio.io/httpbin created
destinationrule.networking.istio.io/httpbin configured
```

Send some traffic from `HTTPbin` version 1 to sleep pod

```console
[root@osc01 (istio-lab)istio-scripts]# export SLEEP_POD=$(kubectl get pod -l app=sleep -o jsonpath={.items..metadata.name})
[root@osc01 (istio-lab)istio-scripts]# kubectl exec -it $SLEEP_POD -c sleep -- sh -c 'curl  http://httpbin:8000/headers' | python -m json.tool
{
    "headers": {
        "Accept": "*/*",
        "Content-Length": "0",
        "Host": "httpbin:8000",
        "User-Agent": "curl/7.35.0",
        "X-B3-Parentspanid": "db31aa45c290a85f",
        "X-B3-Sampled": "1",
        "X-B3-Spanid": "7a433da7969422cd",
        "X-B3-Traceid": "df7ce1045ca39ebedb31aa45c290a85f"
    }
}
```
Check the logs within `HTTPbin` v1 and v2 pods to showcase log entries exist in v1 because all traffic was routed there, and nothing in v2. 





## Traffic Management

Traffic management is done through mixer. How to route requests dynamically to multiple versions of a microservice?

Access /productpage and refresh it few times. The book review output contains star ratings and sometime it shows and and other times it does not. This is due to the fact that Istio routes requests to all available versions in a round robin fashion.

Route all traffic (100%) to only one version of rating microservice.

1. Make a request routing rule that all traffic is sent only to v1 of the microservice. Show and explain.

2. Set a rule to route traffic to v2 of the rating service based upon a particular user identity

3. Explain Istio L7 routing features

4. Explain what traffic shifting - how to gradually migrate traffic from one version of a microservice to another. As an example : migrate from older version to a new version. Create sequence of rules that route a percentage of traffic to one service.



