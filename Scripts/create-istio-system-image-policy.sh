echo Create image policy to download docker images from docker.io/*
kubectl -n istio-system create -f - << EOF
apiVersion: securityenforcement.admission.cloud.ibm.com/v1beta1
kind: ClusterImagePolicy
metadata:
 name: istio-system-image-policy
spec:
 repositories:
 - name: docker.io/*
   policy:
    va:
     enabled: false
 - name: quay.io/*
   policy:
    va:
     enabled: false
EOF