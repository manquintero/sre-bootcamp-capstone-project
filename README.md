# Welcome to your Bootcamp SRE Capstone Project!

Remember that you can find the complete instructions for this project **[here](https://classroom.google.com/w/MzgwNTc4MDgwMjAw/t/all)**.

If you have any questions, feel free to contact your mentor or one of us: Juan Barbosa, Laura Mata, or Francisco Bueno. We are here to support you.

## Status 
| Metric | devel                                                                                                                       | main                                                                                                          |
|--------|-----------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------|
| CI/CD  | ![ devel](https://github.com/manquintero/sre-bootcamp-capstone-project/actions/workflows/ci-build.yml/badge.svg?branch=devel) | ![ main](https://github.com/manquintero/sre-bootcamp-capstone-project/actions/workflows/ci-build.yml/badge.svg) |

### Implemented features
- CI workflow
  - Pylint  (Code rated 10.0)
  - Pytest  (100% Pass rate)
  - Coverage  (100% Branch Coverage + 100% Line Coverage)
  - Docker build && Deploy (on-pull-request)
- Docker Compose
  - Application (Health Check)
  - Database (mysql)

## Docker image
````sh
docker pull manquintero/academy-sre-bootcamp-manuel-quintero
docker run -d -p 8000:8000 manquintero/academy-sre-bootcamp-manuel-quintero
````

## Development environment

In order to bring the development area execute:
```sh
docker-compose up --build
```
This will bring the application container along with its database with sample data

## Cloud Deployment
This app is being manually deployed to CGP: https://academy-sre-bootcamp-manuel-quintero-zaoakzmfea-uc.a.run.app/

## Executing tests

### Get Token
```bash
curl -s -d "username=antonio&password=cotorro" http://127.0.0.1:8000/login
```

### Query for cidr-to-mask
```bash
TOKEN="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoidmlld2VyIn0._k6kmfmdOoKWWMT4qk9nFTz-7k-X_0UdS8tByaCaye8"
curl -s -H 'Accept: application/json' -H "Authorization: Bearer ${TOKEN}" localhost:8000/cidr-to-mask?value=18
{"function":"cidrToMask","input":"18","output":"255.255.192.0"}
```

### Query for mask-to-cidr
```bash
TOKEN="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoidmlld2VyIn0._k6kmfmdOoKWWMT4qk9nFTz-7k-X_0UdS8tByaCaye8"
curl -s -H 'Accept: application/json' -H "Authorization: Bearer ${TOKEN}" localhost:8000/mask-to-cidr?value=255.128.0.0
{"function":"maskToCidr","input":"255.128.0.0","output":"9"}
```

# Architecture
![Deliverable2](https://sre-bootcamp-capstone-project-static.s3.us-east-2.amazonaws.com/Deliverable2+-+Proposed+Arch.drawio.png)
