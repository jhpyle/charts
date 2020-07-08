# Helm Charts

This is the [Helm] chart library for [github.com/jhpyle].  Currently
this library is hosting a single chart, which installs
[**docassemble**] in a [Kubernetes] cluster.

## Installing **docassemble** with helm

The [**docassemble**] chart is available as `jhpyle/docassemble` from
the [Helm] repository `http://charts.docassemble.org:8080`.

### Prerequisites

* You have a [Kubernetes] cluster with at least three nodes (or four
  or more if you are running other applications like [MinIO],
  [PostgreSQL], or [Redis] inside the cluster) with 8GB of RAM each.
* You have installed [Helm] in the cluster.
* You have made a final decision about what hostname to use to access
  the server.
* If you want to use HTTPS (which you should), you have a web server
  or load balancer that can provide SSL termination.  The [Helm] chart
  only creates a server that operates over HTTP on port 80.  [Let's
  Encrypt] is not supported the way that [**docassemble**] supports
  [Let's Encrypt] on a single [Docker] container.

### Installation steps

At a minimum, you need to pass a hostname to the `helm install`
command.  In this example, the site will be accessed at
`https://docassemble.example.com`.

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
  servers to run.  The backend server and each application server need
  to run on separate nodes, so if you have `n` nodes, you should set
  this to `n`-1.  The default is appropriate if your cluster has three
  or four nodes.
* `usingSslTermination`: default is `true`.  If you are not going to
  access the site over HTTPS (which is not recommended except for
  temporary testing purposes), set this to `false`.
* `redirectHttp`: default is `true`.  If `usingSslTermination` is
  `true`, and `redirectHttp` is `true`, then there will be a service
  at `<release-name>-docassemble-redirect-service` on port 8081 that
  will redirect HTTP to HTTPS.  If your service that provides SSL
  termination already redirects incoming HTTP to HTTPS, then you can
  set this to `false`.  Otherwise, configure the SSL termination
  service to send incoming HTTP traffic to port 8081 on the external
  IP address of `<release-name>-docassemble-redirect-service`.
* `daImage`: default is `jhpyle/docassemble:latest`.  This is the
  image of **docassemble** that you want to use.
* `inClusterNGINX`: default is `true`.  By default, the chart runs
  NGINX inside the cluster in order to provide sticky session support
  for websockets communication.  The Live Help features use
  websockets.  If you aren't using the Live Help features, you don't
  need websockets support.  If you set `inClusterNGINX` to `false`,
  then the IP address of the application can be found under `<release
  name>-docassemble-service`.
* `createInClusterNGINX`: default is `true`.  The default setup deploys
  the ingress controller along side this container. If you have already
  deployed an ingress controller which is shared by all namespaces, set
  this to `false`.
* `inClusterNGINXClusterIssuer`: default is `null`.  If you have an
  SSL certificate manager deployed in your cluster, set this to the
  cluster issuer name.
* `inClusterMinio`: default is `true`.  By default, the chart runs
  [MinIO] in order to provide object storage.  If you would rather use
  [S3] or an [S3]-compatible object storage service, set
  `inClusterMinio` to `false` and set `s3.enable` to `true`.  If you
  would rather use [Azure blob storage], set `inClusterMinio` to
  `false` and set `azure.enable` to `true`.  If `inClusterMinio` is
  `false`, you need to use either `s3.enable:true` or `azure.enable`
  to `true`.
* `s3.enable`: set this to `true` if you want to use [S3] or an
  [S3]-compatible object storage service, and you don't want to use an
  in-cluster [MinIO] service.  You must set `inClusterMinio` to
  `false` for this to be effective.
* `s3.bucket`: set this to the name of your [S3] bucket.
* `s3.accessKey`: set this to access key for your [S3] bucket.
* `s3.secretKey`: set this to secret access key for your [S3] bucket.
* `s3.region`: set this to the region you want to use.  This is
  required for [S3] but may not be required for [S3]-compatible
  services.
* `s3.endpointURL`: if you are using an [S3]-compatible service other
  than [S3] itself, set this to the endpoint URL for the API of the
  [S3]-compatible service.
* `azure.enable`: set this to `true` if you want to use [Azure blob
  storage] and you don't want to use an in-cluster [MinIO] service.
  You must set `inClusterMinio` to `false` for this to be effective.
* `azure.accountName`: set this to the account name associated with
  your [Azure blob storage] container.
* `azure.accountKey`: set this to the account key associated with your
  [Azure blob storage] container.
* `azure.container`: set this to the name of your [Azure blob storage]
  container.
* `inClusterPostgres`: default is `true`.  By default, the chart runs
  a [PostgreSQL] server inside the cluster.  If you are using [RDS] or
  another external SQL server, set this to `false` and set `db.host`
  to the hostname of the SQL server.
* `db.host`: set this to the hostname of your external SQL server.
  This is only effective if you have set `inClusterPostgres` to
  `false`.  If you leave `db.host` unset while setting
  `inClusterPostgres` to `false`, then the **docassemble** backend
  server will run [PostgreSQL].
* `db.name`: default is `docassemble`.  Set this to the name of the
  database on your SQL server that you want to use.  This is used
  whether `inClusterPostgres` is `true` or `false`.
* `db.user`: default is `docassemble`.  Set this to the name of the
  user of the database on your SQL server that you want to use.  This
  is used whether `inClusterPostgres` is `true` or `false`.
* `db.prefix`: if you are not using [PostgreSQL], set this to the
  [SQLAlchemy] URL prefix for the type of SQL database you are using.
  For [MySQL], use `mysql://`.
* `db.port`: if your SQL server runs on a non-standard port, you can
  explicitly set the port with `db.port`.
* `db.tablePrefix`: if your SQL database is shared among multiple
  implementations, you can use a table name prefix by setting
  `db.tablePrefix`.
* `db.backup`: default is `false`.  If you want the backend server to
  make a daily backup of your remote [PostgreSQL] server, set this to
  `true`.
* `db.exposeInternal`: default is `false`.  Set this to `true` if you
  want to be able to expose the internal [PostgreSQL] database to the
  network outside the kubernetes cluster.  (If `false`, the service
  will use `ClusterIP`; if `true`, the service will use `NodePort`.)
* `inClusterRedis`: default is `true`.  By default, the chart runs a
  [Redis] server on the cluster.  If you are using [Amazon ElastiCache
  for Redis] or another external [Redis] service, set `inClusterRedis`
  to `false` and set `redisURL`.
* `redisURL`: if you set `inClusterRedis` to `false` because you are
  using [Amazon ElastiCache for Redis] or another external [Redis]
  service, set `redisURL` to a URL like
  `redis://myredisserver.local` where your [Redis] server is on the
  hostname `myredisserver.local`.  This is only effective if
  you set `inClusterRedis` to `false`.  If you leave `redusURL`
  unset while setting `inClusterRedis` to `false`, then the
  **docassemble** backend server will run [Redis].
* `inClusterRabbitMQ`: default is `true`.  By default, the chart runs
  a [RabbitMQ] server in the cluster, using the official chart for
  [RabbitMQ].  If you do not want to use this [RabbitMQ] server, set
  `inClusterRabbitMQ` to `false`.
* `amqpURL`: if you are running an external [RabbitMQ] server, set
  this to the URL for your [RabbitMQ] server, such as
  `pyamqp://guest@rabbitmqserver.local//` if your [RabbitMQ] server is
  at the hostname `rabbitmqserver.local`.  This is only effective if
  you set `inClusterRabbitMQ` to `false`.  If you leave `amqpURL`
  unset while setting `inClusterRabbitMQ` to `false`, then the
  **docassemble** backend server will run [RabbitMQ].
* `adminEmail` and `adminPassword`: by default, when a **docassemble**
  system is first started, the user with administrative privileges is
  called `admin@admin.com` and has the password `password`, which must
  be changed after the first login.  If you want to initialize the
  administrative user with another e-mail address and password, you
  can set `adminEmail` to the e-mail address for the account and set
  `adminPassword` to the password.
* `exposeWebSockets`: default is `true`.  If `false`, then websockets
  connections will be accepted through port 80 on the application
  servers.  If `true`, then websockets connects will be accepted
  through port 5000.
* `useAlb`: default is `false`.  If you are deploying on Amazon Web
  Services and `inClusterNGINX` is `true`, then you can set `useAlb`
  to `true` and an Application Load Balancer will be created that will
  forward traffic to the NGINX Ingress Controller.  If using the
  Application Load Balancer, you also need to set:
    * `certificateArn` - set this to the ARN of the SSL certificate
      you are using for your site.
    * `clusterName` - set this to the name of your cluster.
    * `awsAccessKey` - set this to the access key with privileges to
      set up the application load balancer
    * `awsSecretKey` - set this to the secret key that corresponds
      with the `awsAccessKey`.
* `nginx-ingress.controller.service.type`: default is `LoadBalancer`.
  By default, the NGINX Ingress Controller will have an external IP
  address.  If you are putting a load balancer or proxy in front of
  the NGINX Ingress Controller, and you don't want the NGINX Ingress
  Controller to have an external IP address, you can set
  `nginx-ingress.controller.service.type` to `NodePort`.
* `daAllowUpdates`: default is `true`.  If you do not want your
  **docassemble** system to install software updates, set this to
  `false`.
* `daStableVersion`: default is `false`.  If you want your
  **docassemble** system to only upgrade within the "stable" branch
  (bug fixes and security fixes only), set this to `true`.
* `maxBodySize`: default is `16m`.  The NGINX Ingress Controller
  will reject POST requests with a body size larger than this amount.
* `multiNodeDeployment`: default is `true`.  Set this to `false` if
   you are deploying to a single node cluster.  Note that if you
   deploy **docassemble** on a single node cluster, you are
   eliminating a lot of the benefit to deploying on Kubernetes, so
   only set `multiNodeDeployment` to `true` if you know what you are
   doing.  The backend server and each application server require at
   least 4GB of RAM, so if you do deploy on a single node, make sure
   your node has plenty of resources.
* `webAppServiceType`: default is `LoadBalancer`.  This will be the
  service `type` for the web application.  If your infrastructure does
  not support this services `type`, you can set this to `NodePort`.
* `useSqlPing`: default is `false`.  If your connection to the SQL
  database will continually be terminated, set this to `true`.  There
  is a cost in overhead, but it will prevent errors.

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
* [RabbitMQ] for supporting the [Celery]-based background task system.
* An [API] for monitoring the cluster.

The chart also installs a single backend **docassemble** server, which
has a `CONTAINERROLE` of `log:cron:mail`, and a number of application
servers (the number of which is given by the `replicas` value), which
have a `CONTAINERROLE` of `web:celery`.

If successful, the installation of the [**docassemble**] Helm chart
will create [Kubernetes] resources similar to the following:

```
jpyle@server:~$ kubectl get all
NAME                                                                  READY   STATUS    RESTARTS   AGE
pod/exegetical-panther-docassemble-685bc5f64c-ps6wg                   1/1     Running   0          4h19m
pod/exegetical-panther-docassemble-685bc5f64c-vnzn6                   1/1     Running   0          4h19m
pod/exegetical-panther-docassemble-backend-85f769dd5d-hh5ck           1/1     Running   0          4h19m
pod/exegetical-panther-docassemble-monitor-59b8fd84df-fq8sg           1/1     Running   0          3h19m
pod/exegetical-panther-minio-0                                        1/1     Running   0          4h19m
pod/exegetical-panther-minio-1                                        1/1     Running   0          4h19m
pod/exegetical-panther-minio-2                                        1/1     Running   0          4h19m
pod/exegetical-panther-minio-3                                        1/1     Running   0          4h19m
pod/exegetical-panther-nginx-ingress-controller-7b97d89b4b-5bnwc      1/1     Running   0          4h19m
pod/exegetical-panther-nginx-ingress-controller-7b97d89b4b-dq979      1/1     Running   0          4h19m
pod/exegetical-panther-nginx-ingress-default-backend-54445f7f66gzg6   1/1     Running   0          4h19m
pod/exegetical-panther-postgres-7ddf86c6ff-d72rp                      1/1     Running   0          4h19m
pod/exegetical-panther-rabbitmq-0                                     1/1     Running   0          4h19m
pod/exegetical-panther-redis-6d69f57886-whtqn                         1/1     Running   0          4h19m

NAME                                                       TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)                                 AGE
service/exegetical-panther-docassemble-backend-service     ClusterIP      10.0.238.13    <none>        8082/TCP,514/TCP,25/TCP                 4h19m
service/exegetical-panther-docassemble-monitor-service     ClusterIP      10.0.167.96    <none>        80/TCP                                  4h19m
service/exegetical-panther-docassemble-service             ClusterIP      10.0.78.150    <none>        80/TCP,5000/TCP                         4h19m
service/exegetical-panther-minio                           ClusterIP      10.0.221.93    <none>        9000/TCP                                4h19m
service/exegetical-panther-minio-svc                       ClusterIP      None           <none>        9000/TCP                                4h19m
service/exegetical-panther-nginx-ingress-controller        LoadBalancer   10.0.61.122    25.22.82.89   80:31395/TCP,443:32431/TCP              4h19m
service/exegetical-panther-nginx-ingress-default-backend   ClusterIP      10.0.211.214   <none>        80/TCP                                  4h19m
service/exegetical-panther-postgres-service                NodePort       10.0.176.202   <none>        5432:31654/TCP                          4h19m
service/exegetical-panther-rabbitmq                        ClusterIP      10.0.200.120   <none>        4369/TCP,5672/TCP,25672/TCP,15672/TCP   4h19m
service/exegetical-panther-rabbitmq-headless               ClusterIP      None           <none>        4369/TCP,5672/TCP,25672/TCP,15672/TCP   4h19m
service/exegetical-panther-redis-service                   ClusterIP      10.0.76.85     <none>        6379/TCP                                4h19m
service/kubernetes                                         ClusterIP      10.0.0.1       <none>        443/TCP                                 13h

NAME                                                               READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/exegetical-panther-docassemble                     2/2     2            2           4h19m
deployment.apps/exegetical-panther-docassemble-backend             1/1     1            1           4h19m
deployment.apps/exegetical-panther-docassemble-monitor             1/1     1            1           4h19m
deployment.apps/exegetical-panther-nginx-ingress-controller        2/2     2            2           4h19m
deployment.apps/exegetical-panther-nginx-ingress-default-backend   1/1     1            1           4h19m
deployment.apps/exegetical-panther-postgres                        1/1     1            1           4h19m
deployment.apps/exegetical-panther-redis                           1/1     1            1           4h19m

NAME                                                                          DESIRED   CURRENT   READY   AGE
replicaset.apps/exegetical-panther-docassemble-685bc5f64c                     2         2         2       4h19m
replicaset.apps/exegetical-panther-docassemble-backend-85f769dd5d             1         1         1       4h19m
replicaset.apps/exegetical-panther-docassemble-monitor-59b8fd84df             1         1         1       3h19m
replicaset.apps/exegetical-panther-nginx-ingress-controller-7b97d89b4b        2         2         2       4h19m
replicaset.apps/exegetical-panther-nginx-ingress-default-backend-54445f7f66   1         1         1       4h19m
replicaset.apps/exegetical-panther-postgres-7ddf86c6ff                        1         1         1       4h19m
replicaset.apps/exegetical-panther-redis-6d69f57886                           1         1         1       4h19m

NAME                                           READY   AGE
statefulset.apps/exegetical-panther-minio      4/4     4h19m
statefulset.apps/exegetical-panther-rabbitmq   1/1     4h19m
jpyle@server:~$ kubectl get persistentvolumeclaims
NAME                                   STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
data-exegetical-panther-rabbitmq-0     Bound    pvc-e50d1a69-02fa-11ea-ae53-8203794352ed   8Gi        RWO            default     4h20m
exegetical-panther-postgres-pv-claim   Bound    pvc-e2f43129-02fa-11ea-ae53-8203794352ed   5Gi        RWO            default     4h20m
exegetical-panther-redis-pv-claim      Bound    pvc-e2f6d170-02fa-11ea-ae53-8203794352ed   5Gi        RWO            default     4h20m
export-exegetical-panther-minio-0      Bound    pvc-e4a1f26a-02fa-11ea-ae53-8203794352ed   10Gi       RWO            default     4h20m
export-exegetical-panther-minio-1      Bound    pvc-e4b70265-02fa-11ea-ae53-8203794352ed   10Gi       RWO            default     4h20m
export-exegetical-panther-minio-2      Bound    pvc-e4cd50a0-02fa-11ea-ae53-8203794352ed   10Gi       RWO            default     4h20m
export-exegetical-panther-minio-3      Bound    pvc-e4dc5d8c-02fa-11ea-ae53-8203794352ed   10Gi       RWO            default     4h20m
jpyle@server:~$ kubectl get persistentvolumes
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                          STORAGECLASS   REASON   AGE
pvc-e2f43129-02fa-11ea-ae53-8203794352ed   5Gi        RWO            Retain           Bound    default/exegetical-panther-postgres-pv-claim   default              4h20m
pvc-e2f6d170-02fa-11ea-ae53-8203794352ed   5Gi        RWO            Retain           Bound    default/exegetical-panther-redis-pv-claim      default              4h20m
pvc-e4a1f26a-02fa-11ea-ae53-8203794352ed   10Gi       RWO            Retain           Bound    default/export-exegetical-panther-minio-0      default              4h20m
pvc-e4b70265-02fa-11ea-ae53-8203794352ed   10Gi       RWO            Retain           Bound    default/export-exegetical-panther-minio-1      default              4h20m
pvc-e4cd50a0-02fa-11ea-ae53-8203794352ed   10Gi       RWO            Retain           Bound    default/export-exegetical-panther-minio-2      default              4h19m
pvc-e4dc5d8c-02fa-11ea-ae53-8203794352ed   10Gi       RWO            Retain           Bound    default/export-exegetical-panther-minio-3      default              4h19m
pvc-e50d1a69-02fa-11ea-ae53-8203794352ed   8Gi        RWO            Retain           Bound    default/data-exegetical-panther-rabbitmq-0     default              4h19m
```

The IP address of the **docassemble** application is the external IP
address of the `<release-name>-nginx-ingress-controller` service, which in this
example is `25.22.82.89`.  This particular example output comes from
[Azure Kubernetes Service]; other implementations of [Kubernetes] will
give different output.

The IP address of the [monitoring API] is the cluster IP address of
the `<release-name>-docassemble-monitor-service`, which in this
example is `10.0.167.96`.  This is not exposed to an external IP
address and should not be, because the API does not use
authentication.

### Cleaning up

When you run `helm delete`, not all of the resources will be deleted.
The `PersistentVolumeClaims` and `PersistentVolumes` will continue to
exist (they contain application data).  To delete these resources, run
`kubectl get persistentvolumeclaims` and then `kubectl delete
persistentvolumeclaim <claim id>` on each persistent volume claim.
Then run `kubectl get persistentvolumes` and then `kubectl delete
persistentvolume <persistent volume id>` on each persistent volume.

# Should you use [Kubernetes]?

Running **docassemble** in the cloud with [Kubernetes] is several
times more expensive than [running a single server] in the cloud with
[Docker].  However, [Kubernetes] is a scalable and modern approach to
software installation, and [Helm] helps to manage a lot of the
complexity of [Kubernetes] deployment.

Before putting anything into production with [Kubernetes], make sure
you understand how data is being stored.

# Recommendations for getting started with Kubernetes

How to deploy [Kubernetes] is beyond the scope of this README, so this
section only provides very basic information.

## Microsoft Azure

If you use [Microsoft Azure], you can deploy [Kubernetes] by
installing the `az` and `kubectl` command line utilities.  In [Azure
Portal], you can go to "Kubernetes services" and add a new Kubernetes
service.  Then from your local machine, you can do:

```
az aks get-credentials --resource-group <name of resource group> --name docassemble <name of kubernetes service>
```

This will write credentials to `~/.kube/config` so that you can
interact with your cluster using `kubectl`.  You can install [Helm]
and run the `helm` command to install the **docassemble** chart.

## Amazon Web Services

If you use [Amazon Web Services], the easiest way to get started with
[Kubernetes] is to install the `aws` command and link it to your
Amazon account.  Then install the `eksctl` and `kubectl` command line
utilities.  The easiest way to start a cluster is with the `eksctl
create cluster` command.  You can then install [Helm] and install the
**docassemble** chart.

[Helm]: https://helm.sh/
[Kubernetes]: https://kubernetes.io/
[github.com/jhpyle]: https://github.com/jhpyle
[**docassemble**]: https://docassemble.org
[MinIO]: https://min.io/
[NGINX Ingress Controller]: https://kubernetes.github.io/ingress-nginx/
[PostgreSQL]: https://www.postgresql.org/
[Redis]: http://redis.io/
[RabbitMQ]: https://www.rabbitmq.com/
[Celery]: http://www.celeryproject.org/
[Microsoft Azure]: https://azure.microsoft.com/
[Azure Kubernetes Service]: https://azure.microsoft.com/en-us/services/kubernetes-service
[Azure Portal]: https://portal.azure.com/
[Amazon Web Services]: https://aws.amazon.com
[Docker]: https://www.docker.com/
[running a single server]: https://docassemble.org/docs/docker.html
[S3]: https://aws.amazon.com/s3/
[Azure blob storage]: https://azure.microsoft.com/en-us/services/storage/blobs/
[RDS]: https://aws.amazon.com/rds/
[SQLAlchemy]: http://www.sqlalchemy.org/
[Amazon ElastiCache for Redis]: https://aws.amazon.com/redis/
[Let's Encrypt]: https://letsencrypt.org/
[API]: https://github.com/jhpyle/docassemble-mon
[monitoring API]: https://github.com/jhpyle/docassemble-monitor
[MySQL]: https://en.wikipedia.org/wiki/MySQL
