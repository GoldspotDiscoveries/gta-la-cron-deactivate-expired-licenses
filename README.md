# gsp-tf-la-cron-stripe

A Terraform file to manage a Lambda function that is triggered daily to check for upcoming renewals of Geotic subscriptions.

## Set up

[Steps to set up local Terraform environment](https://goldspot.atlassian.net/l/cp/d7rBYk3Z)

First you must create a `credentials` file (no extension) and add your AWS credentials. You must have the right permission to execute all that is needed in the proper resources. The file should look like this:

```
[default]
aws_access_key_id=<your access key id>
aws_secret_access_key=<your secret key>
aws_session_token=<your session token>
```

One you have this you must import the state that is hosted in S3 (just a JSON file we all share). The state should contain information such us the staging uri in which the API can be tested. Use `terraform init` to pull the state with your credentials in the command:

```
> terraform init -backend-config="access_key=<your access key id>" -backend-config="secret_key=<your secret key>" -backend-config="token=<your long session token>"
```

Note that Terraform [locks the state](https://www.terraform.io/language/state/locking) when somebody is applying changes.

Next use `terraform plan` to make sure the that all is up to date. It should show a message like:

```
No changes. Your infrastructure matches the configuration.
```

NOTE: Some changes may be needed if you compile a different ZIP file. Also changes are needed is there is a secret.

## Workspaces and Variables

The terraform workspace will be use to define reference `local.enviroment`. This way we can handle TEST and LIVE environment or others. `terraform workspace show` should return `default`, which is the TEST environment.

To shitch to LIVE (`prod``) enviroment do:

```
> terraform workspace select prod
```

WARNING: THIS SHOULD BE LEFT TO THE BE DONE TO DE CD/CI. The `prod` workspace must be created once.

## Apply changes

`terraform apply` will show you what changes are to be made, and if approuved, applied in thereal infrastructure.
Note that we use `default` workspace for test purposes. Make sure you are in the right worksapce (`terraform workspace show`)

## Observe the state

If you want to take a look at what the state is (which is hosted in S3 not locally), you can do the following:

```
> terraform show -json > state.json
```

NOTE: Each Workspace has it's own separated state file in S3 so you only pull the state of the current selected wrkspace. The defualt workspace is in the regular S3 folder but the environment is within a folder `:env/`

## NOTES

- `terraform apply` will push the changes to the resources (to the corresponding enviroment set by the workspace).