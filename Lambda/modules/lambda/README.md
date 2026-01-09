# Terraform AWS Lambda (Python) Module

This module creates an AWS Lambda function (Python), an execution role with basic logging, and packages your local Python source directory into a zip using the `archive_file` data source.

## Inputs
- `function_name` (string, required): Name of the Lambda function.
- `runtime` (string, default `python3.12`): Lambda runtime.
- `handler` (string, default `app.lambda_handler`): Entry point handler.
- `timeout` (number, default `10`): Execution timeout in seconds.
- `memory_size` (number, default `128`): Memory in MB.
- `environment` (map(string), default `{}`): Environment variables.
- `tags` (map(string), default `{}`): Tags for resources.
- `source_dir` (string, required): Absolute path to your Python source directory.
- `build_dir` (string, optional): Absolute path for zip output. Defaults to `${path.cwd}/build`.

## Outputs
- `function_name`: The Lambda function name.
- `function_arn`: The Lambda function ARN.
- `role_arn`: The execution role ARN.

## Example
See the `envs/dev` usage which packages `src/` into a zip and deploys the function.
