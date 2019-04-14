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

```console
echo Use subnet mask 29 to reserve 6 hosts in 192.168.142.248/29 Class C network.
echo keepalivedCloudProvider.serviceIPRange="192.168.142.248/29"

cd keepalived

helm install . --name keepalived --namespace istio-system \
 --set keepalivedCloudProvider.serviceIPRange="192.168.142.248/29" --tls

```


