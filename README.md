# Lab 4

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
