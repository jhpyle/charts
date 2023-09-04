# Charts

This is the [Helm] chart library for [github.com/jhpyle]. Currently
this library is hosting a single chart, which installs
[**docassemble**] in a [Kubernetes] cluster.

## Installing **docassemble** with helm

The [**docassemble**] chart is available as `jhpyle/docassemble` from
the [Helm] repository `http://charts.docassemble.org:8080`.

### Prerequisites

* You have a [Kubernetes] cluster running version 1.19.0 or later with
  at least three nodes (or four or more if you are running other
  applications like [MinIO], [PostgreSQL], or [Redis] inside the
  cluster) with 4GB of RAM each.
* You have installed [Helm].
* If you want to use HTTPS (which you should), you have a web server
  or load balancer that can provide SSL termination. The [Helm] chart
  only creates a server that operates over HTTP on port 80. [Let's
  Encrypt] is not supported the way that [**docassemble**] supports
  [Let's Encrypt] on a single [Docker] container. You will need to
  make a final decision about what hostname to use to access the
  server.

### Installation steps

In this example, the site will be accessed at
`https://docassemble.example.com`.

The first time you install **docassemble**, you need to add the chart
repository:

```
helm repo add jhpyle http://charts.docassemble.org:8080
```

Then, to install, run:

```
helm install mydocassemble jhpyle/docassemble \
    --set daHostname=docassemble.example.com
```

You can set the following values:

* `daHostname`: default is `localhost`. Always set this when you run
  `helm install`, unless you are running locally with [minikube].
  Knowing the hostname in advance is necessary for the Live Help
  features to work; the hostname is used in the configuration of the
  [Ingress NGINX Controller].
* `global.storageClass`. Set this to whatever automatically
  provisioning `StorageClass` you are using in your cluster, if any.
* `timeZone`: default is `America/New_York`. This will be the time
  zone on the Linux machines running **docassemble**.
* `replicas`: default is 2. This indicates the number of application
  servers to run. The backend server and each application server need
  to run on separate nodes, so if you have `n` nodes, you should set
  this to `n`-1. The default is appropriate if your cluster has three
  or four nodes.
* `usingSslTermination`: default is `true`. If you are not going to
  access the site over HTTPS (which is not recommended except for
  temporary testing purposes), set this to `false`.
* `redirectHttp`: default is `true`. If `usingSslTermination` is
  `true`, and `redirectHttp` is `true`, then there will be a service
  at `<release-name>-docassemble-redirect-service` on port 8081 that
  will redirect HTTP to HTTPS. If your service that provides SSL
  termination already redirects incoming HTTP to HTTPS, then you can
  set this to `false`. Otherwise, configure the SSL termination
  service to send incoming HTTP traffic to port 8081 on the external
  IP address of `<release-name>-docassemble-redirect-service`.
* `daImage`: a dictionary specifying the components of the image to
  use. The components of the dictionary are `registry`, `repository`,
  `tag`, and `pullPolicy`. The default values are `registry:
  docker.io`, `repository: jhpyle/docassemble`, `tag: latest`, and
  `pullPolicy: Always`.
* `readOnlyFileSystem`: default is `false`. If set to `true`, then the
  file system on the **docassemble** pods will be mounted
  read-only. As a consequence, the Configuration, Playground, and
  Package Management systems are not available in the web application.
  All changes to the system's software or configuration must be made
  by modifying the image referred to by `daImage` or by editing Helm
  chart values such as `daConfiguration`.
* `daConfiguration`: undefined by default. If `readOnlyFileSystem` is
  `True`, the `config.yml` file is a read-only file, the contents of
  which are determined by Helm. To add Configuration directives that
  are not pre-populated by Helm, you can define values under
  `daConfiguration`. The directives that are defined outside of
  `daConfiguration`, which you should not attempt to set inside of
  `daConfiguration`, are `supervisor`, `enable playground`, `allow log
  viewing`, `update on start`, `allow updates`, `allow configuration
  editing`, `root owned`, `db`, `secretkey`, `os locale`, `timezone`,
  `redis`, `rabbitmq`, `s3`, `azure`, `collect statistics`,
  `kubernetes`, `log server`, `use minio`, `behind https load
  balancer`, `external hostname`, `expose websockets`, `websockets
  ip`, `websockets port`, `root`, `allow non-idempotent questions`,
  `restrict input variables`, `web server`, `new markdown to docx`,
  `new template markdown behavior`, `sql ping`, `default icons`, and
  `enable unoconv`. If `inClusterGotenberg` is `true`, the `gotenberg
  url` is set automatically and `enable unoconv` is set to `false`.
* `inClusterNGINX`: default is `true`. By default, the chart runs
  NGINX inside the cluster in order to provide sticky session support
  for websockets communication. The Live Help features use
  websockets. If you aren't using the Live Help features, you don't
  need websockets support. If you set `inClusterNGINX` to `false`,
  then the IP address of the application can be found under `<release
  name>-docassemble-service`.
* `inClusterNGINXClusterIssuer`: default is `null`. If you have an
  SSL certificate manager deployed in your cluster, set this to the
  cluster issuer name.
* `inClusterMinio`: default is `true`. By default, the chart runs
  [MinIO] in order to provide object storage. If you would rather use
  [S3] or an [S3]-compatible object storage service, set
  `inClusterMinio` to `false` and set `s3.enable` to `true`. If you
  would rather use [Azure blob storage], set `inClusterMinio` to
  `false` and set `azure.enable` to `true`. If `inClusterMinio` is
  `false`, you need to use either `s3.enable: true` or `azure.enable:
  true`.
* `s3.enable`: set this to `true` if you want to use [S3] or an
  [S3]-compatible object storage service, and you don't want to use an
  in-cluster [MinIO] service. You must set `inClusterMinio` to
  `false` for this to be effective.
* `s3.bucket`: set this to the name of your [S3] bucket (only set this
  if `s3.enable` is true).
* `s3.accessKey`: set this to access key for your [S3] bucket (only
  set this if `s3.enable` is true).
* `s3.secretKey`: set this to secret access key for your [S3] bucket
  (only set this if `s3.enable` is true).
* `s3.region`: set this to the region you want to use. This is
  required for [S3] but may not be required for [S3]-compatible
  services (only set this if `s3.enable` is true).
* `s3.endpointURL`: if you are using an [S3]-compatible service other
  than [S3] itself, set this to the endpoint URL for the API of the
  [S3]-compatible service (only set this if `s3.enable` is true).
* `azure.enable`: set this to `true` if you want to use [Azure blob
  storage] and you don't want to use an in-cluster [MinIO] service.
  You must set `inClusterMinio` to `false` for this to be effective.
* `azure.accountName`: set this to the account name associated with
  your [Azure blob storage] container.
* `azure.accountKey`: set this to the account key associated with your
  [Azure blob storage] container.
* `azure.container`: set this to the name of your [Azure blob storage]
  container.
* `inClusterPostgres`: default is `true`. By default, the chart runs
  a [PostgreSQL] server inside the cluster. If you are using [RDS] or
  another external SQL server, set this to `false` and set `db.host`
  to the hostname of the SQL server.
* `inClusterGotenberg`: default is `true`. By default, the chart runs
  a [Gotenberg] server inside the cluster for DOCX to PDF conversion
  instead of using [unoconv]. Set this to `false` if you do not want
  the [Gotenberg] server to be started.
* `db.prefix`: if you are not using [PostgreSQL], set this to the
  [SQLAlchemy] URL prefix for the type of SQL database you are using.
  For [MySQL], use `mysql://`. Also set `inClusterPostgres: false`.
* `db.host`: set this to the hostname of your external SQL server.
  This is only effective if you have set `inClusterPostgres` to
  `false`. If you leave `db.host` unset while setting
  `inClusterPostgres` to `false`, then the **docassemble** backend
  server will run [PostgreSQL].
* `db.name`: default is `docassemble`. Set this to the name of the
  database on your SQL server that you want to use. This is used
  only if `inClusterPostgres` is `false`.
* `db.user`: default is `docassemble`. Set this to the name of the
  user of the database on your SQL server that you want to use. This
  is used only if `inClusterPostgres` is `false`.
* `db.port`: if your SQL server runs on a non-standard port, you can
  explicitly set the port with `db.port`. This is used only if
  `inClusterPostgres` is `false`.
* `db.tablePrefix`: if your SQL database is shared among multiple
  implementations, you can use a table name prefix by setting
  `db.tablePrefix`.
* `db.backup`: default is `false`. If you want the backend server to
  make a daily backup of your remote [PostgreSQL] server, set this to
  `true`.
* `inClusterRedis`: default is `true`. By default, the chart runs a
  [Redis] server on the cluster. If you are using [Amazon ElastiCache
  for Redis], [Amazon MemoryDB for Redis], or another external [Redis]
  service, set `inClusterRedis` to `false` and set `redisURL`.
* `redisURL`: if you set `inClusterRedis` to `false` because you are
  using [Amazon ElastiCache for Redis], [Amazon MemoryDB for Redis],
  or another external [Redis] service, set `redisURL` to a URL like
  `redis://myredisserver.local` where your [Redis] server is on the
  hostname `myredisserver.local`. This is only effective if you set
  `inClusterRedis` to `false`. If you leave `redisURL` unset while
  setting `inClusterRedis` to `false`, then the **docassemble**
  backend server will run [Redis].
* `inClusterRabbitMQ`: default is `true`. By default, the chart runs
  a [RabbitMQ] server in the cluster. If you do not want to use this
  [RabbitMQ] server, set `inClusterRabbitMQ` to `false`.
* `amqpURL`: if you are running an external [RabbitMQ] server, set
  this to the URL for your [RabbitMQ] server, such as
  `pyamqp://guest@rabbitmqserver.local//` if your [RabbitMQ] server is
  at the hostname `rabbitmqserver.local`. This is only effective if
  you set `inClusterRabbitMQ` to `false`. If you leave `amqpURL`
  unset while setting `inClusterRabbitMQ` to `false`, then the
  **docassemble** backend server will run [RabbitMQ].
* `adminEmail`, `adminPassword`, and `adminApiKey`: by default, when a
  **docassemble** system is first started, the user with
  administrative privileges is called `admin@admin.com` and has the
  password `password`, which must be changed after the first login.
  If you want to initialize the administrative user with another
  e-mail address and password, you can set `adminEmail` to the e-mail
  address for the account and set `adminPassword` to the
  password. Optionally, you can also include `adminApiKey`. If you set
  an `adminApiKey`, then during initial startup, an API key owned by
  the administrative user will be created, with no constraints on its
  use.
* `exposeWebSockets`: default is `true`. If `false`, then websockets
  connections will be accepted through port 80 on the application
  servers. If `true`, then websockets connects will be accepted
  through port 5000.
* `useAlb`: default is `false`. If you are deploying on Amazon Web
  Services and `inClusterNGINX` is `true`, then you can set `useAlb`
  to `true` and an Application Load Balancer will be created that will
  forward traffic to the [Ingress NGINX Controller]. If using the
  Application Load Balancer, you also need to set:
    * `certificateArn` - set this to the ARN of the SSL certificate
      you are using for your site.
    * `clusterName` - set this to the name of your cluster.
    * `awsAccessKey` - set this to the access key with privileges to
      set up the application load balancer
    * `awsSecretKey` - set this to the secret key that corresponds
      with the `awsAccessKey`.
* `ingress-nginx.controller.service.type`: default is `LoadBalancer`.
  By default, the [Ingress NGINX Controller] will have an external IP
  address. If you are putting a load balancer or proxy in front of
  the [Ingress NGINX Controller], and you don't want the NGINX Ingress
  Controller to have an external IP address, you can set
  `ingress-nginx.controller.service.type` to `NodePort`.
* `daAllowUpdates`: default is `true`. If you do not want your
  **docassemble** system to install software updates, set this to
  `false`.
* `maxBodySize`: default is `16m`. The [Ingress NGINX Controller]
  will reject POST requests with a body size larger than this amount.
* `multiNodeDeployment`: default is `true`. Set this to `false` if
   you are deploying to a single node cluster. The effect of
   `multiNodeDeployment` being `true` is that `podAntiAffinity` is set
   up so that the **docassemble** backend server and each web server
   must be on separate nodes. (This has been found to be necessary for
   applications to work correctly, but your results may vary.) Note
   that if you deploy **docassemble** on a single node cluster, you
   are eliminating a lot of the benefit to deploying on Kubernetes, so
   only set `multiNodeDeployment` to `true` if you know what you are
   doing. The backend server and each application server require at
   least 4GB of RAM, so if you do deploy on a single node, make sure
   your node has plenty of resources.
* `webAppServiceType`: default is `LoadBalancer`. This will be the
  Service `type` for the web application. If your infrastructure does
  not support this Service `type`, you can set this to `NodePort`. If
  you set `inClusterNGINX` is `true`, you may wish to set
  `webAppServiceType` to `ClusterIP` because NGINX will take care of
  load balancing and will be able to find your service internally.
* `useSqlPing`: default is `false`. If your connection to the SQL
  database will continually be terminated, set this to `true`. There
  is a cost in overhead, but it will prevent errors.
* `pythonVersion`: default is `3.10`. The value of this depends on the
  version of the **docassemble** Docker image you are using. For
  version 1.4.x, use `3.10`. For version 1.2.x or 1.3.x, use `3.8`.
* `texliveVersion`: default is `2021`. The value of this depends on the
  version of the **docassemble** Docker image you are using. For
  version 1.4.x, use `2021`. For version 1.2.x or 1.3.x, use `2020`.
* `syslogNgVersion`: default is `3.35`. The value of this depends on the
  version of the **docassemble** Docker image you are using. For
  version 1.4.x, use `3.35`. For version 1.2.x or 1.3.x, use `3.28`.

The following values can be changed from their defaults in order to
increase security.

* `secretKey`: this is used as part of the encryption system in the
  docassemble application. It is also used for encrypting passwords
  for user accounts. Only change this when you are initializing a
  system, because if you change it later, your passwords will not work
  and interview answers will be inaccessible. Do not lose this key
  because if you ever need to recreate your system from persistent
  data storage, you will need this.
* `minio.auth.rootUser`: the [MinIO] system uses a username and
  password. This is the username.
* `minio.auth.rootPassword`: the [MinIO] system uses a username and
  password. This is the password.
* `supervisor.username`: the **docassemble** web application pods and
  the backend pod use [supervisord] to launch and restart component
  services. The pods need to be able to communicate with each other
  over port 9001 in order to trigger software installations and
  restarts. For security, interprocess communication uses a username
  and password. `supervisor.username` specifies the username.
* `supervisor.password`: the password associated with
  `supervisor.username`.
* `rabbitmq.auth.password`: in order to launch a background task,
  **docassemble** code needs to communicate with the pod running the
  [RabbitMQ] task queue. `rabbitmq.auth.password` specifies the
  password that [RabbitMQ] will accept.
* `rabbitmq.auth.erlangCookie`: [RabbitMQ] nodes use a cookie to
  authenticate with each other. `rabbitmq.auth.erlangCookie` specifies
  the cookie.
* `redis.auth.password`: the pods that run **docassemble** code need
  to be able to access the [Redis] service. For security, access to
  [Redis] requires a password. `redis.auth.password` specifies that
  password.
* `postgresql.auth.username`: when a [PostgreSQL] server is deployed
  inside of the cluster, the pods that run **docassemble** code need
  to be able to access the [PostgreSQL] database. For security, access
  to the [PostgreSQL] requires a username
  password. `postgresql.auth.username` specifies the username.
* `postgresql.auth.password`: this is the password associated with
  `postgresql.auth.username`.

For more information about configuration options, see the
[`values.yaml`] file in `jhpyle/charts` and the `values.yaml` files
inside of the [dependencies].

If you want to install a new version, first update your repository
cache by running:

```
helm repo update
```

### Structure

The [Helm] chart installs the following backend services (unless
disabled using configuration values):

* [MinIO] for object storage (S3-compatible).
* [Ingress NGINX Controller] to provide sticky sessions for websockets
  traffic. It also acts as an Ingress for regular web traffic.
* [PostgreSQL] for the backend SQL storage system.
* [Redis] for the backend in-memory storage system.
* [RabbitMQ] for supporting the [Celery]-based background task system.
* [Gotenberg] for DOCX to PDF conversion.
* An [API] for monitoring the cluster.

The chart also installs a single backend **docassemble** server, which
has a `CONTAINERROLE` of `log:cron:mail`, and a number of application
servers (the number of which is given by the `replicas` value), which
have a `CONTAINERROLE` of `web:celery`.

If successful, the installation of the [**docassemble**] Helm chart
will create [Kubernetes] resources similar to the following:

```
jsmith@mycomputer:~$ kubectl get all
NAME                                                          READY   STATUS    RESTARTS   AGE
pod/mydocassemble-daredis-master-0                            1/1     Running   0          23m
pod/mydocassemble-docassemble-796ff45967-mkd5b                1/1     Running   0          23m
pod/mydocassemble-docassemble-796ff45967-njsnt                1/1     Running   0          23m
pod/mydocassemble-docassemble-backend-c6488ddc5-2rqtv         1/1     Running   0          23m
pod/mydocassemble-docassemble-monitor-6b4c87b6fd-rn49f        1/1     Running   0          23m
pod/mydocassemble-ingress-nginx-controller-6994cc5c9f-s4gj2   1/1     Running   0          23m
pod/mydocassemble-minio-6475c45468-btjx7                      1/1     Running   0          23m
pod/mydocassemble-postgresql-0                                1/1     Running   0          23m
pod/mydocassemble-rabbitmq-0                                  1/1     Running   0          23m

NAME                                                       TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)                                 AGE
service/kubernetes                                         ClusterIP      10.100.0.1       <none>                                                                    443/TCP                                 173m
service/mydocassemble-daredis-headless                     ClusterIP      None             <none>                                                                    6379/TCP                                23m
service/mydocassemble-daredis-master                       ClusterIP      10.100.98.130    <none>                                                                    6379/TCP                                23m
service/mydocassemble-docassemble-backend-service          ClusterIP      10.100.141.100   <none>                                                                    8082/TCP,514/TCP,25/TCP                 23m
service/mydocassemble-docassemble-monitor-service          ClusterIP      10.100.213.74    <none>                                                                    80/TCP                                  23m
service/mydocassemble-docassemble-service                  ClusterIP      10.100.36.4      <none>                                                                    80/TCP,5000/TCP                         23m
service/mydocassemble-ingress-nginx-controller             LoadBalancer   10.100.240.57    a98f23f3405f34ca68b31383d076a485-1827083835.us-west-2.elb.amazonaws.com   80:31917/TCP                            23m
service/mydocassemble-ingress-nginx-controller-admission   ClusterIP      10.100.246.167   <none>                                                                    443/TCP                                 23m
service/mydocassemble-minio                                ClusterIP      10.100.208.187   <none>                                                                    9000/TCP,9001/TCP                       23m
service/mydocassemble-postgresql                           ClusterIP      10.100.243.187   <none>                                                                    5432/TCP                                23m
service/mydocassemble-postgresql-hl                        ClusterIP      None             <none>                                                                    5432/TCP                                23m
service/mydocassemble-rabbitmq                             ClusterIP      10.100.147.207   <none>                                                                    5672/TCP,4369/TCP,25672/TCP,15672/TCP   23m
service/mydocassemble-rabbitmq-headless                    ClusterIP      None             <none>                                                                    4369/TCP,5672/TCP,25672/TCP,15672/TCP   23m

NAME                                                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/mydocassemble-docassemble                2/2     2            2           23m
deployment.apps/mydocassemble-docassemble-backend        1/1     1            1           23m
deployment.apps/mydocassemble-docassemble-monitor        1/1     1            1           23m
deployment.apps/mydocassemble-ingress-nginx-controller   1/1     1            1           23m
deployment.apps/mydocassemble-minio                      1/1     1            1           23m

NAME                                                                DESIRED   CURRENT   READY   AGE
replicaset.apps/mydocassemble-docassemble-796ff45967                2         2         2       23m
replicaset.apps/mydocassemble-docassemble-backend-c6488ddc5         1         1         1       23m
replicaset.apps/mydocassemble-docassemble-monitor-6b4c87b6fd        1         1         1       23m
replicaset.apps/mydocassemble-ingress-nginx-controller-6994cc5c9f   1         1         1       23m
replicaset.apps/mydocassemble-minio-6475c45468                      1         1         1       23m

NAME                                            READY   AGE
statefulset.apps/mydocassemble-daredis-master   1/1     23m
statefulset.apps/mydocassemble-postgresql       1/1     23m
statefulset.apps/mydocassemble-rabbitmq         1/1     23m
```

The IP address of the **docassemble** application is the external IP
address of the `<release-name>-ingress-nginx-controller` service,
which in this example is
`a98f23f3405f34ca68b31383d076a485-1827083835.us-west-2.elb.amazonaws.com`.
This particular example output comes from [EKS]; other implementations
of [Kubernetes] will give different output.

The IP address of the [monitoring API] is the cluster IP address of
the `<release-name>-docassemble-monitor-service`, which in this
example is `10.100.213.74`. This is not exposed to an external IP
address and should not be, because the API does not use
authentication.

### Cleaning up

To delete the system, run:

```
helm delete mydocassemble
```

Note that this does not delete all of the resources created by `helm
install`. The Persistent Volume Claims and Persistent Volumes will
continue to exist (they contain application data). In addition, a
Config Map resource and a Secret resource created by `ingress-nginx`
will still exist. If you wish to delete everything, run:

```
helm delete mydocassemble
kubectl get pvc | awk '{print $1}' | grep -v NAME | xargs kubectl delete pvc
kubectl get pv | awk '{print $1}' | grep -v NAME | xargs kubectl delete pv
kubectl delete configmap ingress-controller-leader
kubectl delete secret mydocassemble-ingress-nginx-admission
```

# Should you use [Kubernetes]?

Running **docassemble** in the cloud with [Kubernetes] is several
times more expensive (and complicated) than [running a single server]
in the cloud with [Docker]. However, [Kubernetes] is a scalable and
modern approach to software installation, and [Helm] helps to manage a
lot of the complexity of [Kubernetes] deployment.

Before putting anything into production with [Kubernetes], make sure
you understand how data is being stored. Kubernetes "Persistent
Volumes" are a way to store application data that survive software
upgrades, but it is not easy to gain access to the information on the
volumes.

If you deploy on [Kubernetes], it is recommended that you externalize
data storage. For example, if deploying on [Amazon Web Services], you
can externalize SQL using [RDS] for the SQL server, externalize
[Redis] using [Amazon ElastiCache for Redis] or [Amazon MemoryDB for
Redis], and externalize object storage using [S3]. In your
`values.yaml` file, you would then set `inClusterMinio`,
`inClusterPostgres`, and `inClusterRedis` to `false`.

Managed services will give you greater control over your application
data than if your application data are stored on persistent volumes on
your Kubernetes nodes. There is no guarantee that a persistent volume
created with one version of an application, like [Redis],
[PostgreSQL], or [MinIO], will continue to work if the pods running
those applications are stopped and restarted running under a new
version.

# Recommendations for getting started with Kubernetes

How to deploy [Kubernetes] is beyond the scope of this README, so this
section only provides very basic information.

## Microsoft Azure

If you use [Microsoft Azure], you can deploy [Kubernetes] by
installing the `az` and `kubectl` command line utilities. In [Azure
Portal], you can go to "Kubernetes services" and add a new Kubernetes
service. Then from your local machine, you can do:

```
az aks get-credentials --resource-group <name of resource group> --name docassemble <name of kubernetes service>
```

This will write credentials to `~/.kube/config` so that you can
interact with your cluster using `kubectl`. You can install [Helm] and
run the `helm` command to install the **docassemble** chart.

## Amazon Web Services

If you use [Amazon Web Services], the easiest way to get started with
[Kubernetes] is to install the `aws` command and link it to your
Amazon account. Then install the `eksctl` and `kubectl` command line
utilities.

The easiest way to start a cluster is with a command like `eksctl
create cluster --nodes 3 --node-type t3.medium --version 1.22`. You
can then install [Helm] and install the **docassemble** chart with
`helm install` as described above.

## minikube

The Helm chart works on [minikube]. To run a server locally (without
HTTPS) you can create a file `values.yaml` containing something like:

```
usingSslTermination: false
adminEmail: you@yourserver.com
adminPassword: xxxsecretxxx
```

Then start [minikube] and install the [Helm] chart:

```
minikube start --nodes 3
helm install -f values.yaml mydocassemble jhpyle/docassemble
```

To access the web interface, you will probably need to use
[`kubectl port-forward`].

## Known issues

Depending on the Kubernetes version and the platform, you may have an
issue where ingress-nginx gets stuck running the
`ingress-nginx-admission-patch` job. Helm may fail with:

```
Error: INSTALLATION FAILED: failed post-install: timed out waiting for the condition
```

The way around this is to add the following to a `values.yaml` file:

```
ingress-nginx:
  controller:
    admissionWebhooks:
      enabled: false
```

Then install with:

```
helm install -f values.yaml mydocassemble jhpyle/docassemble
```

[Helm]: https://helm.sh/
[Kubernetes]: https://kubernetes.io/
[github.com/jhpyle]: https://github.com/jhpyle
[**docassemble**]: https://docassemble.org
[MinIO]: https://min.io/
[Ingress NGINX Controller]: https://kubernetes.github.io/ingress-nginx/
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
[Let's Encrypt]: https://letsencrypt.org/
[API]: https://github.com/jhpyle/docassemble-mon
[monitoring API]: https://github.com/jhpyle/docassemble-monitor
[MySQL]: https://en.wikipedia.org/wiki/MySQL
[EKS]: https://aws.amazon.com/eks/
[Amazon MemoryDB for Redis]: https://aws.amazon.com/memorydb/
[Amazon ElastiCache for Redis]: https://aws.amazon.com/elasticache/redis/
[minikube]: https://minikube.sigs.k8s.io/docs/
[`kubectl port-forward`]: https://phoenixnap.com/kb/kubectl-port-forward
[`values.yaml`]: https://github.com/jhpyle/charts/blob/master/docassemble/values.yaml
[dependencies]: https://github.com/jhpyle/charts/tree/master/docassemble/charts
[supervisord]: http://supervisord.org/
[Gotenberg]: https://gotenberg.dev/
[unoconv]: https://github.com/unoconv/unoconv
