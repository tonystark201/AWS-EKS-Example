# AWS EKS  Example

## EKS



## Terraform 

__*All the code of build infrastructure, you can check and review them in the folder of `IaC`*__

### Steps

It`s very easy to contribute the infrastructure by Terraform. You can use the commands as below to initialize terraform and bulid the AWS infrastructure.

+ Initialize terraform and install provider and module

  ```shell
  terraform init
  ```

+ Validate the script you have been wrote done.

  ```shell
  terraform validate
  ```

+ Show your build plan

  ```shell
  terraform plan
  ```

+ Apply the code to build infrastructure.

  ```shell
  terraform apply
  ```

+ Destroy the infrastructure you have been built.

  ```shell
  terraform destroy
  ```


### Resource

The resources we need are listed below.

+ EKS

  We need EKS cluster and EKS worker nodes.

+ ECR

  We need ECR Repo to host images.

+ IAM Role

  We need a Role for EKS cluster and worker nodes.

### Tips

+ Apply the infrastructure

You must provide your AWS key and secret, and give the value in the `terraform.tfvars` as below:

```shell
# provider
aws_region = "us-east-1"
aws_access_key = "xxxxxx"
aws_secret_key = "xxxxxx"
```
When the infrastructure build successfully, you will see the output as below.

```shell
Apply complete! Resources: 33 added, 0 changed, 0 destroyed.

Outputs:

ecr_repository_url = "xxxxxx.dkr.ecr.us-east-1.amazonaws.com/demotsz-repo"
eks_cluster_name = "DemoTSZ201-cluster"
```

## Kubernetes

EKS has been built, after that we need to initialize our `Deployment` and `Service`. Here we use the Nginx container to initialize the Kubernetes resources we need. __*See `deployment.yaml` and `service.yaml ` documentation for details.*__

Note: We created a namespace called `development`. The name of deployment is `demo-deployment`, the name of service is `demo-svc`, and the name of container is `demo`.

+ Update kubeconfig

Execute the command below.

```shell
aws eks --region us-east-1 update-kubeconfig --name DemoTSZ201-cluster
```

You will see the kubeconfig updated.

```
Added new context arn:aws:eks:us-east-1:xxxxxx:cluster/DemoTSZ201-cluster to C:\Users\<username>\.kube\config
```

+ Check the Pods

Execute the command below.

```
kubectl get nodes
```

The result as below.

```
NAME                         STATUS   ROLES    AGE   VERSION
ip-172-11-2-9.ec2.internal   Ready    <none>   10m   v1.22.9-eks-810597c
```

+ Create namespace

```
kubectl get namespace
kubectl create namespace development
```

+ Create development

```
kubectl apply -f deployment.yaml --namespace development
```

+ Check development

```
~>kubectl get deployment -n development
NAME              READY   UP-TO-DATE   AVAILABLE   AGE
demo-deployment   1/1     1            1           2m23s
```

+ Check the RS

```
~>kubectl get rs -n development
NAME                         DESIRED   CURRENT   READY   AGE
demo-deployment-6bd4587dc8   1         1         1       3m15s
```

+ Check the Pods

```
~>kubectl get pods -n development
NAME                               READY   STATUS    RESTARTS   AGE
demo-deployment-6bd4587dc8-8md67   1/1     Running   0          3m50s
```

+ Create service

```
~>kubectl apply -f service.yaml -n development
service/demo-svc created
```

+ Check service

```
~>kubectl get svc -n development
NAME       TYPE           CLUSTER-IP      EXTERNAL-IP                                                               PORT(S)        AGE
demo-svc   LoadBalancer   10.100.129.27   aea8a33da14e44c12a685aa95def090e-1078050742.us-east-1.elb.amazonaws.com   80:32094/TCP   2m30s
```

+ visit the balancer ingress hostname

```
aea8a33da14e44c12a685aa95def090e-1078050742.us-east-1.elb.amazonaws.com
```

__*When you can see the nginx index page, it means your service is ok now.*__

## Github Action

We use the github action workflow to automate the deployment of code to the cloud. __*You can check and view the github action configuration in the folder of ".github" in this Repo*__

### Workflow

The workflow as below:

+ CI
  + Checkout the Code to the github runner
  + Lint the code, you can run flake8 or other tools to check the code format.
  + Run the unittest, you can use tox, pytets, unittest or some tools to implement the unit test of the code.
+ CD
  + Cancel Previous Runs    
  + Checkout the Code to the github runner
  + Configure AWS credentials
  + Login to Amazon ECR
  + Build, tag, and push image to Amazon ECR
  + Deploy to Kubernetes cluster 
  + Verify Kubernetes deployment  

__When the workflow execute successfully, visit the Kubernetes balancer ingress hosting name agian.__

### Tips

1. You need to add your secret key in the Repo.(Click settings of the Repo you will find the place to add secret key)

2. You must update the `env` parameters in the `.github.yml` file.

3. You must take care of the name for deployment and container when you set image.

4. A base64-encoded kubeconfig file with credentials for Kubernetes to access the cluster. 

   ```
   cat $HOME/.kube/config | base64
   ```

## Summary

This demo project mainly uses Terraform to build an EKS cluster and uses ECR to store container images. At the same time, use Github Action for automated deployment to replace the latest container image in the Pods. After building an EKS cluster, you need to manually create the Deployment and Service of the smallest unit that can be used in order to open up the channel for external access to the service.

__*Welcome to fork and star. Thank you for your reading.*__

## Reference

+ [Amazon EC2 Instances Types](https://aws.amazon.com/cn/ec2/instance-types/)

+ [eks cli](https://docs.aws.amazon.com/cli/latest/reference/eks/index.html)
+ [Docker and Github Action for Kubernetes CLI](https://github.com/kodermax/kubectl-aws-eks)
+ [Command line tool (kubectl)](https://kubernetes.io/docs/reference/kubectl/)
+ [Kubernetes Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
+ [Kubernetes Service](https://kubernetes.io/docs/concepts/services-networking/service/)
+ [Kubernetes Deployment Tutorial with Example YAML](https://matthewpalmer.net/kubernetes-app-developer/articles/kubernetes-deployment-tutorial-example-yaml.html)

