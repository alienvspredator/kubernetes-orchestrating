# Lab 4-5

This is a Vagrant's pre-configured VM with a completed exercise for the fourth lab.
This example shows how to create a Kubernetes cluster.

## Start-up instructions

1. To create a VM, simply run the `vagrant up` command from the root directory of the repository.
2. Connect via ssh using the command `vagrant ssh`.
3. Navigate to the data directory with the following command: `cd data`.
4. Run the `minikube`

    ```sh
    $ minikube start
    😄  minikube v1.13.0 on Ubuntu 20.04 (vbox/amd64)
    ✨  Using the docker driver based on existing profile
    👍  Starting control plane node minikube in cluster minikube
    🔄  Restarting existing docker container for "minikube" ...
    🐳  Preparing Kubernetes v1.19.0 on Docker 19.03.8 ...
    🔎  Verifying Kubernetes components...
    🌟  Enabled addons: default-storageclass, storage-provisioner
    🏄  Done! kubectl is now configured to use "minikube" by default
    ```

5. List the nodes with the following command:

    ```sh
    $ kubectl get nodes
    NAME       STATUS   ROLES    AGE   VERSION
    minikube   Ready    master   51m   v1.19.0
    ```

6. Create and expose a deployment:

    ```sh
    $ kubectl create deployment hello-minikube --image=k8s.gcr.io/echoserver:1.10
    deployment.apps/hello-minikube created

    $ kubectl expose deployment hello-minikube --type NodePort --port 8080
    service/hello-minikube exposed
    ```

7. List the deployments:

    ```sh
    $ kubectl get deployments.apps
    NAME             READY   UP-TO-DATE   AVAILABLE   AGE
    hello-minikube   1/1     1            1           8m34s
    ```

8. List the pods:

    ```sh
    $ kubectl get pod
    NAME                              READY   STATUS    RESTARTS   AGE
    hello-minikube-5d9b964bfb-wnbzk   1/1     Running   0          44s
    ```

9. List the minikube services:

    ```sh
    $ minikube service list
    |----------------------|---------------------------|--------------|-------------------------|
    |      NAMESPACE       |           NAME            | TARGET PORT  |           URL           |
    |----------------------|---------------------------|--------------|-------------------------|
    | default              | hello-minikube            |         8080 | http://172.17.0.2:32442 |
    | default              | kubernetes                | No node port |
    | kube-system          | kube-dns                  | No node port |
    |----------------------|---------------------------|--------------|-------------------------|
    ```

10. Send an http request to the `hello-minikube` service:

    ```sh
    $ curl -L $(minikube service hello-minikube --url)
    Hostname: hello-minikube-5d9b964bfb-wnbzk

    Pod Information:
        -no pod information available-

    Server values:
        server_version=nginx: 1.13.3 - lua: 10008

    Request Information:
        client_address=172.18.0.1
        method=GET
        real path=/
        query=
        request_version=1.1
        request_scheme=http
        request_uri=http://172.17.0.2:8080/

    Request Headers:
        accept=*/*
        host=172.17.0.2:32442
        user-agent=curl/7.68.0

    Request Body:
        -no body in request-
    ```

11. View application logs

    ```sh
    $ kubectl logs hello-minikube-5d9b964bfb-wnbzk
    Generating self-signed cert
    Generating a 2048 bit RSA private key
    ............................................................................................+++
    ...........................................+++
    writing new private key to '/certs/privateKey.key'
    -----
    Starting nginx
    ```

12. Describe the service

    ```sh
    $ kubectl describe services/hello-minikube
    Name:                     hello-minikube
    Namespace:                default
    Labels:                   app=hello-minikube
    Annotations:              <none>
    Selector:                 app=hello-minikube
    Type:                     NodePort
    IP:                       10.105.210.58
    Port:                     <unset>  8080/TCP
    TargetPort:               8080/TCP
    NodePort:                 <unset>  32442/TCP
    Endpoints:                172.18.0.3:8080
    Session Affinity:         None
    External Traffic Policy:  Cluster
    Events:                   <none>
    ```

13. Describe the deployments

    ```sh
    $ kubectl describe deployments.apps
    Name:                   hello-minikube
    Namespace:              default
    CreationTimestamp:      Mon, 21 Sep 2020 14:22:35 +0000
    Labels:                 app=hello-minikube
    Annotations:            deployment.kubernetes.io/revision: 1
    Selector:               app=hello-minikube
    Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
    StrategyType:           RollingUpdate
    MinReadySeconds:        0
    RollingUpdateStrategy:  25% max unavailable, 25% max surge
    Pod Template:
      Labels:  app=hello-minikube
      Containers:
       echoserver:
        Image:        k8s.gcr.io/echoserver:1.10
        Port:         <none>
        Host Port:    <none>
        Environment:  <none>
        Mounts:       <none>
      Volumes:        <none>
    Conditions:
      Type           Status  Reason
      ----           ------  ------
      Progressing    True    NewReplicaSetAvailable
      Available      True    MinimumReplicasAvailable
    OldReplicaSets:  <none>
    NewReplicaSet:   hello-minikube-5d9b964bfb (1/1 replicas created)
    Events:          <none>
    ```

    It's running with label app=hello-minikube

14. Apply filters to the pods and the services

    ```sh
    $ kubectl get pods -l app=hello-minikube
    NAME                              READY   STATUS    RESTARTS   AGE
    hello-minikube-5d9b964bfb-wnbzk   1/1     Running   1          5d2h
    ```

    ```sh
    $ kubectl get service -l app=hello-minikube
    NAME             TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
    hello-minikube   NodePort   10.105.210.58   <none>        8080:32442/TCP   5d3h
    ```

15. Lable the pod

    ```sh
    $ kubectl label pod hello-minikube-5d9b964bfb-wnbzk version=v1
    pod/hello-minikube-5d9b964bfb-wnbzk labeled
    ```

16. Delete the service

    ```sh
    $ kubectl delete service -l app=hello-minikube
    service "hello-minikube" deleted
    ```

## Application scaling

1. Scale up the deployment to 4 replicas

    ```sh
    $ kubectl scale deployment --replicas 4 hello-minikube
    deployment.apps/hello-minikube scaled
    $ kubectl get deployments.apps
    NAME             READY   UP-TO-DATE   AVAILABLE   AGE
    hello-minikube   4/4     4            4           5d3h
    ```

2. Check the number of pods changed

    ```sh
    $ kubectl get pods -o wide
    NAME                              READY   STATUS    RESTARTS   AGE    IP           NODE       NOMINATED NODE   READINESS GATES
    hello-minikube-5d9b964bfb-dslvk   1/1     Running   0          69s    172.18.0.6   minikube   <none>           <none>
    hello-minikube-5d9b964bfb-gltrc   1/1     Running   0          69s    172.18.0.7   minikube   <none>           <none>
    hello-minikube-5d9b964bfb-wnbzk   1/1     Running   1          5d3h   172.18.0.3   minikube   <none>           <none>
    hello-minikube-5d9b964bfb-xwfdb   1/1     Running   0          69s    172.18.0.8   minikube   <none>           <none>
    ```

3. Check that the service is load-balancing the traffic

    Make multiple http request to the service

    ```sh
    $ curl -L $(minikube service hello-minikube --url)
    Hostname: hello-minikube-5d9b964bfb-xwfdb
    ...
    $ curl -L $(minikube service hello-minikube --url)
    Hostname: hello-minikube-5d9b964bfb-wnbzk
    ...
    ```

## Update a container version

1. Verify the application version

    ```sh
    $ kubectl describe pods
    Name:         hello-minikube-5d9b964bfb-dslvk
    ...
    Labels:       app=hello-minikube
    ...
    Containers:
    echoserver:
        ...
        Image:          k8s.gcr.io/echoserver:1.10
    ```

2. Update the version

    ```sh
    $ kubectl set image deployments hello-minikube echoserver=k8s.gcr.io/echoserver:1.9
    deployment.apps/hello-minikube image updated
    ```

3. List the pods

    ```sh
    $ kubectl get pods
    NAME                              READY   STATUS        RESTARTS   AGE
    hello-minikube-5d9b964bfb-dslvk   1/1     Terminating   0          18m
    hello-minikube-5d9b964bfb-gltrc   1/1     Terminating   0          18m
    hello-minikube-5d9b964bfb-wnbzk   1/1     Terminating   1          5d3h
    hello-minikube-5d9b964bfb-xwfdb   1/1     Terminating   0          18m
    hello-minikube-6b75f66798-9tnsc   1/1     Running       0          25s
    hello-minikube-6b75f66798-jqx6c   1/1     Running       0          21s
    hello-minikube-6b75f66798-q6gbb   1/1     Running       0          26s
    hello-minikube-6b75f66798-wvcpn   1/1     Running       0          22s
    ```

4. Rollout an update

    ```sh
    $ kubectl rollout status deployment hello-minikube
    deployment "hello-minikube" successfully rolled out
    ```

## Log in to dashboard

1. List the secrets:

    ```sh
    $ kubectl -n kube-system get secret
    NAME                                             TYPE                                  DATA   AGE
    ...
    deployment-controller-token-pqlc8                kubernetes.io/service-account-token   3      65m
    ...
    ```

    Find with the name `deployment-controller-token-...`

2. Get and copy the token:

    ```sh
    $ kubectl -n kube-system describe secret deployment-controller-token-pqlc8
    Name:         deployment-controller-token-pqlc8
    Namespace:    kube-system
    Labels:       <none>
    Annotations:  kubernetes.io/service-account.name: deployment-controller
                  kubernetes.io/service-account.uid: 5bb025e1-ae2e-4d2a-92e3-dcd1fd39353d

    Type:  kubernetes.io/service-account-token

    Data
    ====
    token:      eyJhbGciOiJSUzI1NiIsImtpZCI6InNpSXBVX0dIWXJQOHktSVN3UjNhai1pVHVRT1QtcklwZ29oUDVCanhGaFEifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJkZXBsb3ltZW50LWNvbnRyb2xsZXItdG9rZW4tcHFsYzgiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiZGVwbG95bWVudC1jb250cm9sbGVyIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiNWJiMDI1ZTEtYWUyZS00ZDJhLTkyZTMtZGNkMWZkMzkzNTNkIiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50Omt1YmUtc3lzdGVtOmRlcGxveW1lbnQtY29udHJvbGxlciJ9.qg4i7lMg0vo2TFHKRIMAlt6QszuDn5KwkOfEnviPxKbfhAk9TUhR78NxB_3gHrffkNrc8dCooGkS3GjJi5F9Lqyd_pde6fO9AgWxpC9BRkddnFkjZG5HrYtD1sMzPR7MTm6XJhYMl1sYguXav7D984Hlo7Iya0w4v1K0Sts6w_fUzSN7oA0OBO03RL7_7hB3hQi2bJGQOvthwyAJ9KhctN2l7hA6H_EppjJhiWryYy2KAj4iJ0HHMOUzvj83uKdbASnhOfHoleWnjsQ_9qprfjaUSWLRumhN8qx1FyO5hJykvEfmOkCFzyNXl6Rtcd6bvqBrp4d4ocvk0yul6x-oRQ
    ca.crt:     1066 bytes
    namespace:  11 bytes
    ```

3. Create a proxy server to the Kubernetes API Server:

    ```sh
    $ kubectl proxy --address 0.0.0.0 --disable-filter --port 8001
    W0921 14:38:50.787729   36867 proxy.go:167] Request filter disabled, your proxy is vulnerable to XSRF attacks, please be cautious
    Starting to serve on [::]:8001
    ```

4. [Open](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/) `http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/` with your browser.
5. Sign in using the token obtained in the previous step.
