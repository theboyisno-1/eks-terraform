# eks-terraform

Deployment with autoscaling in EKS (on aws managed k8s) using terraform

## Overview

We will provision ECR and then EKS cluster in order to test nodejs app in k8s with HorizontalPodAutoscaler. Once app is deployed in k8s we will generate load to test the hpa.

## Repo folder structure explaination

- **aws-ecrc**: Creates ECR with provided name
- **aws-eks**: Creates EKS cluster
- **demo-nodejs-app**: nodejs test app source code
- **k8s-manifest**: Deploys service / application in k8s
  - **helm-chart**: Using helm chart
  - **terraform**: Using terraform

## Pre-requisite

- [aws cli setup](https://docs.aws.amazon.com/polly/latest/dg/setup-aws-cli.html) with valid credentails
- [terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)
- [helm](https://helm.sh/docs/helm/helm_install/) - Optional!
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [docker](https://docs.docker.com/get-docker/)

## Steps/Process

1. Provision Elastic Container Registry (ECR), if you dont have already. Executes following commands:
   - `cd aws-ecr`
   - Initialize -> `terraform init`
   - Check the plan -> `terraform plan`
   - If everything looks good then apply -> `terraform apply`
   - When it prompt for registry name then enter `nodejs-test`

2. Provision Elastic Kubernetes Service (EKS), if you dont have already. Executes following commands:
   - `cd aws-eks`
   - Initialize -> `terraform init`
   - Check the plan -> `terraform plan`
   - If everything looks good then apply -> `terraform apply`
   - Configure your kubectl for eks -> `aws eks --region <EKS-REGION> update-kubeconfig --name <CLUSTER-NAME>`
   - If required, create `ConfigMap` named `aws-auth` from `terraform output` command

3. Build and push docker image of nodejs-test application:
   - `cd demo-nodejs-app`
   - Build image -> `docker build -t nodejs-test:latest .`
   - Tag image to pus it in ECR registry -> `docker tag nodejs-test:latest <ECR-URI-FROM-STEP-1>:latest`
   - Do docker login for ECR -> `aws ecr get-login-password --region <ECR-REGION> | docker login --username AWS --password-stdin <ECR-URI-FROM-STEP-1>`
   - Push image to ECR -> `docker push <ECR-URI-FROM-STEP-1>:latest`
   - Check your ECR if image is there

4. Deploy the application using either helm or terraform:
   - **Helm**
       1. `cd k8s-manifests`
       2. `helm upgrade --install nodejs-test ./helm-chart`

   - **Terraform**
       1. `cd k8s-manifests/terraform`
       2. Initialize -> `terraform init`
       3. Check the plan -> `terraform plan`
       4. If everything looks good then apply -> `terraform apply`
       5. Get loadbalancer `hostname` or `ip` from output variable

5. Test the application deployment:
   - Check if application has working loadbalancer `hostname` or `ip` -> `curl <HOSTNAME|IP>:<PORT>`
   - Open new window in terminal and watch HPA -> `kubectl get hpa -n release -w`
   - Open 2/3 terminal window and execute `while true; do curl -s < <HOSTNAME|IP>:<PORT>; done` in both of them to increase the load on service
   - In few seconds you will notice that replicas has increased for the nodejs-test deployment because of HPA


## Result/Output

Test results are as follows:

Before load test:

```bash
kubectl get hpa -n release

NAME          REFERENCE                TARGETS           MINPODS   MAXPODS   REPLICAS   AGE
nodejs-test   Deployment/nodejs-test   54%/60%, 3%/50%   7         10        7          3m52s
```

During load test:

```bash
kubectl get hpa -n release -w

NAME          REFERENCE                TARGETS           MINPODS   MAXPODS   REPLICAS   AGE
nodejs-test   Deployment/nodejs-test   54%/60%, 3%/50%   7         10        7          5m45s
nodejs-test   Deployment/nodejs-test   54%/60%, 32%/50%   7         10        7          5m46s
nodejs-test   Deployment/nodejs-test   54%/60%, 77%/50%   7         10        7          6m46s
nodejs-test   Deployment/nodejs-test   54%/60%, 77%/50%   7         10        10         7m1s
nodejs-test   Deployment/nodejs-test   56%/60%, 58%/50%   7         10        10         7m46s
nodejs-test   Deployment/nodejs-test   56%/60%, 58%/50%   7         10        10         8m28s
nodejs-test   Deployment/nodejs-test   56%/60%, 68%/50%   7         10        10         8m46s
nodejs-test   Deployment/nodejs-test   55%/60%, 54%/50%   7         10        10         9m46s
nodejs-test   Deployment/nodejs-test   55%/60%, 37%/50%   7         10        10         10m

```

After load test:

```bash
kubectl get hpa -n release

NAME          REFERENCE                TARGETS           MINPODS   MAXPODS   REPLICAS   AGE
nodejs-test   Deployment/nodejs-test   56%/60%, 3%/50%    7         10        7         19m
```


## Extras

- You can set priority of pods with [PriorityClass](https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/)
- If EKS is not able to pull image from ECR then check the [policy](https://docs.aws.amazon.com/AmazonECR/latest/userguide/ECR_on_EKS.html)
- If HPA is not working properly or showin something like `<unknown>/50%` then check if `metrics-server` is deployed in `kube-system` else deploy it using `kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.6/components.yaml`
- If still facing issue with HPA then make sure `metrics-server` deployment has following containers args:

```YAML
...
...
    spec:
      containers:
      - args:
        - /metrics-server
        - --cert-dir=/tmp
        - --secure-port=4443
        - --kubelet-preferred-address-types=InternalIP
        image: k8s.gcr.io/metrics-server-amd64:v0.3.6
...
...
```
