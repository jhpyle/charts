# Helm Charts

This is the Helm chart library for [github.com/jhpyle].  Currently this
library is hosting a single chart, which installs [**docassemble**] in
a Kubernetes cluster.

## Installing **docassemble** with helm

The [**docassemble**] chart is available as `jhpyle/docassemble` from
the [Helm] repository `http://charts.docassemble.org:8080`.

### Prerequisites

* You have a [Kubernetes] cluster with three or more nodes.
* You have installed [Helm].
* You have made a final decision about what hostname to use to access
  the server.
* If you want to use HTTPS, you have a web server or load balancer
  that can provide SSL termination.  The [Helm] chart only creates a
  server that operates over HTTP on port 80.

### Installation steps

At a minimum, you need to pass a hostname to the `helm install`
command, as well as the name of the `StorageClass` you want to use.
In this example, the site will be accessed at
`https://docassemble.example.com` and there is a `StorageClass`
defined in the cluster called `my-storage`.

The first time you install **docassemble**, you need to add the chart
repository:

```
helm repo add jhpyle http://charts.docassemble.org:8080
```

Then, to install, run:

```
helm install jhpyle/docassemble \
    --set daHostname=docassemble.example.com
```

You can set the following values:

* `daHostname`: default is `localhost`.  Always set this when you run
  `helm install`.  Knowing the hostname in advance is necessary for
  the Live Help features to work; the hostname is used in the
  configuration of the NGINX Ingress Controller.
* `global.storageClass`.  Set this to whatever automatically
  provisioning `StorageClass` you are using in your cluster.
* `minio.persistence.storageClass`.  If you set `global.storageClass`,
  set this to the same value.
* `timeZone`: default is `America/New_York`.  This will be the time
  zone on the Linux machines running **docassemble**.
* `replicas`: default is 2.  This indicates the number of application
  servers to run.  If you have `n` nodes, you should set this to
  `n`-1.  The default is appropriate if your cluster has three nodes.
* `usingSslTermination`: default is `true`.  If you are not going to
  access the site over HTTPS (which is not recommended except for
  temporary testing purposes), set this to `false`.
* `daImage`: default is `jhpyle/docassemble:latest`.  This is the
  image of **docassemble** that you want to use.

If you want to install a new version, first update your repository
cache by running:

```
helm repo update
```

### Structure

The [Helm] chart installs the following backend services:

* [MinIO] for object storage (S3-compatible).
* [NGINX Ingress Controller] to provide sticky sessions for websockets
  traffic.
* [PostgreSQL] for the backend SQL storage system.
* [Redis] for the backend in-memory storage system.

The chart also installs a single backend **docassemble** server, which
has a `CONTAINERROLE` of `log:cron:mail`, and a number of
application servers (as determined by the `replicas` value), which
have a `CONTAINERROLE` of `web:celery`.

If successful, the installation of the [**docassemble**] Helm chart
will create [Kubernetes] resources similar to the following:

```
jpyle@cephalopod:~$ kubectl get all
NAME                                                                READY   STATUS    RESTARTS   AGE
pod/busted-narwhal-docassemble-7d5bbf67d6-bhzpq                     1/1     Running   0          19h
pod/busted-narwhal-docassemble-7d5bbf67d6-nkjmv                     1/1     Running   0          19h
pod/busted-narwhal-docassemble-backend-f8575db58-k7n7g              1/1     Running   0          19h
pod/busted-narwhal-minio-0                                          1/1     Running   0          19h
pod/busted-narwhal-minio-1                                          1/1     Running   0          19h
pod/busted-narwhal-minio-2                                          1/1     Running   0          19h
pod/busted-narwhal-minio-3                                          1/1     Running   0          19h
pod/busted-narwhal-nginx-ingress-controller-658cc46b8-74c9t         1/1     Running   0          19h
pod/busted-narwhal-nginx-ingress-controller-658cc46b8-xgx5f         1/1     Running   0          19h
pod/busted-narwhal-nginx-ingress-default-backend-5484748d57-fsl5s   1/1     Running   0          19h
pod/busted-narwhal-postgres-77dbf78969-q5lfw                        1/1     Running   0          19h
pod/busted-narwhal-redis-57d4cb8df8-46kx7                           1/1     Running   0          19h

NAME                                                   TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                      AGE
service/busted-narwhal-docassemble-backend-service     ClusterIP      10.0.106.112   <none>           8080/TCP                     19h
service/busted-narwhal-docassemble-service             ClusterIP      10.0.109.75    <none>           80/TCP,5000/TCP              19h
service/busted-narwhal-minio                           ClusterIP      10.0.105.79    <none>           9000/TCP                     19h
service/busted-narwhal-minio-svc                       ClusterIP      None           <none>           9000/TCP                     19h
service/busted-narwhal-nginx-ingress-controller        LoadBalancer   10.0.50.108    105.25.138.209   80:30323/TCP,443:31110/TCP   19h
service/busted-narwhal-nginx-ingress-default-backend   ClusterIP      10.0.255.228   <none>           80/TCP                       19h
service/busted-narwhal-postgres-service                NodePort       10.0.59.134    <none>           5432:32371/TCP               19h
service/busted-narwhal-redis-service                   ClusterIP      10.0.26.159    <none>           6379/TCP                     19h
service/kubernetes                                     ClusterIP      10.0.0.1       <none>           443/TCP                      2d

NAME                                                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/busted-narwhal-docassemble                     2/2     2            2           19h
deployment.apps/busted-narwhal-docassemble-backend             1/1     1            1           19h
deployment.apps/busted-narwhal-nginx-ingress-controller        2/2     2            2           19h
deployment.apps/busted-narwhal-nginx-ingress-default-backend   1/1     1            1           19h
deployment.apps/busted-narwhal-postgres                        1/1     1            1           19h
deployment.apps/busted-narwhal-redis                           1/1     1            1           19h

NAME                                                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/busted-narwhal-docassemble-7d5bbf67d6                     2         2         2       19h
replicaset.apps/busted-narwhal-docassemble-backend-f8575db58              1         1         1       19h
replicaset.apps/busted-narwhal-nginx-ingress-controller-658cc46b8         2         2         2       19h
replicaset.apps/busted-narwhal-nginx-ingress-default-backend-5484748d57   1         1         1       19h
replicaset.apps/busted-narwhal-postgres-77dbf78969                        1         1         1       19h
replicaset.apps/busted-narwhal-redis-57d4cb8df8                           1         1         1       19h

NAME                                    READY   AGE
statefulset.apps/busted-narwhal-minio   4/4     19h
```

The IP address of the **docassemble** application is the external IP
address of the `nginx-ingress-controller` service, which in this
example is `105.25.138.209`.

### Cleaning up

When you run `helm delete`, not all of the resources will be deleted.
The `PersistentVolumeClaims` and `PersistentVolumes` will continue to
exist (they contain application data).  To delete these resources, run
`kubectl get persistentvolumeclaims` and then `kubectl delete
persistentvolumeclaim <claim id>` on each persistent volume claim.
Then run `kubectl get persistentvolumes` and then `kubectl delete
persistentvolume <persistent volume id>` on each persistent volume.

[Helm]: https://helm.sh/
[Kubernetes]: https://kubernetes.io/
[github.com/jhpyle]: https://github.com/jhpyle
[**docassemble**]: https://docassemble.org
[MinIO]: https://min.io/
[NGINX Ingress Controller]: https://kubernetes.github.io/ingress-nginx/
[PostgreSQL]: https://www.postgresql.org/
[Redis]: http://redis.io/
