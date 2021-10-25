# SRE Capstone Project

The goal for this repository is to show the knowledge acquired during the execution of the SRE Bootcamp in particular with this major areas
1. Demonstrate the CI/CD, testing and clean code knowledge you acquired from the Bootcamp first modules.
2. Demonstrate the adaptability to learning new technologies.
3. Demonstrate the knowledge of infrastructure and code you acquired from the Bootcamp last modules. 

## Project Status
| Metric | development                                                                                                                               | staging                                                                                                           | main (Production)                                                                                                          |
|--------|-------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------|
| CI/CD  | ![development](https://github.com/manquintero/sre-bootcamp-capstone-project/actions/workflows/ci-build.yml/badge.svg?branch=development)  | ![staging](https://github.com/manquintero/sre-bootcamp-capstone-project/actions/workflows/ci-build.yml/badge.svg) | ![main](https://github.com/manquintero/sre-bootcamp-capstone-project/actions/workflows/ci-build.yml/badge.svg) |


### Endpoints Implemented

 | Endpoint      | Description                    |
 |---------------|--------------------------------|
 | /             | Homepage |
 | /version      | Reports the Container SHA |
 | /_health      | Application health |
 | /login        | Returns a [JSON Web Token (JWT)](https://es.wikipedia.org/wiki/JSON_Web_Token) |
 | /cidr-to-mask | Converts from [CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) notation to [Sub-Network Mask](https://en.wikipedia.org/wiki/Subnetwork)|
 | /mask-to-cidr | Converts form [Sub-Network Mask](https://en.wikipedia.org/wiki/Subnetwork) notation to [CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing)|

### Practices Implemented
+ Software Engineering and Testing Best Practices
  + SDLC implemented via TDD
+ Computing AWS
  + EC2
  + ECS
+ AWS Data Storage
  + S3 
  + DynamoDB
  + RDS (mysql)
+ Cloud Security Best Practices
  + Single entry to the application via ELB
  + Bastion Hosts to reach the VPC
  + Application and DB allocated in private networks.
+ DevOps & CI/CD Fundamentals
  + Docker + DockerCompose Workflow
    + 2 Services enabled
      1. Flask Application
      2. DataStore (mysql) with Test Data
  + Single CI/CD pipeline with 4 gates
    1. Static Code Verification (pylint)
    2. Unit Test (pytest)
    3. Code Coverage up to 100%
+ Infrastructure as Code (IaC)
  + State file stored via S3
  + Lock system implemented via DynamoDB
  + Three environments defined
    1. Development
    2. Staging
    3. Production

## Docker image(s)
### DockerHub
````shell
docker pull manquintero/academy-sre-bootcamp-manuel-quintero
docker run -d -p 8000:8000 manquintero/academy-sre-bootcamp-manuel-quintero
````

### Elastic Container Registry
``` shell
docker pull 664624836310.dkr.ecr.us-east-2.amazonaws.com/academy-sre-bootcamp-manuel-quintero
docker run -d -p 8000:8000 664624836310.dkr.ecr.us-east-2.amazonaws.com/academy-sre-bootcamp-manuel-quintero
```

### Container Registry
``` shell
docker pull gcr.io/academy-sre-bootcamp/academy-sre-bootcamp-manuel-quintero
docker run -d -p 8000:8000 gcr.io/academy-sre-bootcamp/academy-sre-bootcamp-manuel-quintero
```

## Development environment

In order to bring the development area execute:
```sh
docker-compose up --build
```
This will bring the application container along with its database with sample data

### Evaluating Static Code

```shell
pip install pylint
[[ -f "./python/requirements.txt" ]] && pip install -r "./python/requirements.txt"
pylint python/
```

### Running Unit Test & Coverage

```shell
pip install pytest pytest-cov mock
[[ -f "./python/requirements.txt" ]] && pip install -r "./python/requirements.txt"
pytest python
pytest --cov-config=python/.coveragerc --cov python > pytest-coverage.txt
```

*Although described as UT these runs rely on an external DB provided by the original project*

## Endpoints

### Homepage
```bash
$ curl -s localhost:8000
OK
```

### Healthcheck
```bash
$ curl -s localhost:8000/_health
HEALTHY
```

### Version
```bash
$ curl -s localhost:8000/version
HEAD
```

### Login
```bash
$ curl -s -d "username=antonio&password=cotorro" http://127.0.0.1:8000/login
{"data":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoidmlld2VyIn0._k6kmfmdOoKWWMT4qk9nFTz-7k-X_0UdS8tByaCaye8"}
```
### cidr-to-mask
```bash
$ TOKEN="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoidmlld2VyIn0._k6kmfmdOoKWWMT4qk9nFTz-7k-X_0UdS8tByaCaye8"
$ curl -s -H 'Accept: application/json' -H "Authorization: Bearer ${TOKEN}" localhost:8000/cidr-to-mask?value=18
{"function":"cidrToMask","input":"18","output":"255.255.192.0"}
```

### mask-to-cidr
```bash
$ TOKEN="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoidmlld2VyIn0._k6kmfmdOoKWWMT4qk9nFTz-7k-X_0UdS8tByaCaye8"
$ curl -s -H 'Accept: application/json' -H "Authorization: Bearer ${TOKEN}" localhost:8000/mask-to-cidr?value=255.128.0.0
{"function":"maskToCidr","input":"255.128.0.0","output":"9"}
```

# Architecture

![Architecture](https://sre-bootcamp-capstone-project-static.s3.us-east-2.amazonaws.com/Architecture.drawio.png)

# Branching Strategy

A simple branch strategy based on the [mythical GitGlow](https://datasift.github.io/gitflow/IntroducingGitFlow.html) with a few tailoring to fit this application lifecycle. These are the key points:
1. The branches mimic the target environments:
2. Any number of commits to the __development__ branch can happen.
3. Changes from __development__ shall be promoted to a __staging__ via GitHub pull requests merge.
4. Any number of commits to the __staging__ branch can happen.
5. Only pull request merges are allowed on __Production__
6. So far, __no hot fixes__ are allowed in __Production__

![BranchingStrategy](https://sre-bootcamp-capstone-project-static.s3.us-east-2.amazonaws.com/Git.drawio.png)

# CI/CD

The CI/CD process has been merged into a single pipeline for convenience. A few adaptations depends on the type of trigger. 
1. Build
   1. Checks for SCCD in Python. __[merge && pull_request]__
2. Test
   1. Checks for Unit Testing via pytest. __[merge && pull_request]__
   2. Checks for Code Coverage. __[merge && pull_request]__
3. Container
   1. Builds the containers. __[merge && pull_request]__
   2. Tags and Pushes to three different Cloud Registries. __[merge]__
4. Terraform
   1. Initialize the workspace. __[merge && pull_request]__
   2. Checks for formatting. __[merge && pull_request]__
   3. Plan the provisioning. __[merge]__
   4. Apply the provisioning plan. __[merge]__

*Systems with a lock mechanism in place, such as Terraform, are protected via GitHub environment concurrency*

![Action](https://sre-bootcamp-capstone-project-static.s3.us-east-2.amazonaws.com/GithubAction.png)

# Deployment Strategy

Three Environments have been designated based on the Branching Strategy:

| Environment      | URL                                                                  |
|------------------|----------------------------------------------------------------------|
|Development       | http://sre-bootcamp-development-198286806.us-east-2.elb.amazonaws.com|
|Staging           | http://sre-bootcamp-staging-283469283.us-east-2.elb.amazonaws.com    |
|Production        | http://sre-bootcamp-production-990790453.us-east-2.elb.amazonaws.com |

The strategy is layered in two stages:

1. EC2 with an AutoScaling Group following a rolling-update process where *min_elb_capacity* is defined.
2. ECS with a *deployment_circuit_breaker* configured with *rollback*.
   1. Every Service/Task feeds from the same ECR but different task definition with the SHA embedded into it.

## IaC
Modules were defined for the next functionalities:

![IaC](https://sre-bootcamp-capstone-project-static.s3.us-east-2.amazonaws.com/IaC.png)