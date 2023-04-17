# http-echo
This is a simple http server that echoes request data as JSON, useful for debugging.

## Running locally
A) Native server proccess: (requires [nodejs](https://nodejs.org/en) 6+)
```sh
PORT=8080 make run
```
B) As docker container: (requires **docker**)
```sh
make docker-run
# terminal will follow container logs, ctrl-c to release it
make docker-stop
```
> Please use GNU Make 4+ (MacOS comes with 3.81, pull most recent version with `brew install make` and `alias make=gmake`)

## Sample output
```
$ curl localhost:8080/hello
{
  "path": "/hello",
  "headers": {
    "host": "localhost:8080",
    "user-agent": "curl/7.87.0",
    "accept": "*/*"
  },
  "method": "GET",
  "body": "",
  "fresh": false,
  "hostname": "localhost",
  "ip": "::ffff:127.0.0.1",
  "ips": [],
  "protocol": "http",
  "query": {},
  "subdomains": [],
  "xhr": false,
  "os": {
    "hostname": "192.168.1.251"
  }
}
```

## Provisioning infrastructure
An AWS environment set up with CI/CD by this repo using **Github Actions**.  
One EKS cluster is provisioned in my personal account that has a running deployment with the latest version of this image.

It's possible to provision all the resources on your own account. You'll need to have aws-cli configured with Admin access to your account.
There's a suggested `make infra-seed-ci-user`, which creates an user called **github** with _PowerUserAccess_ and prints it's `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.
Those can be stored as secrets in Github Action's pipeline so it can operate in the provided AWS account.  
Override the backend state bucket during `terraform init -backend-config='bucket=<yourAccountId>-tfstate'`.
