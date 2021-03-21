<p align="center"><img src="https://github.com/charlesdotfish/dotnet-cdk-action/raw/v1/media/logo.png" alt="Charles Dot Fish" width="400"></p>

# .NET CDK GitHub Action

[![GitHub Issues](https://img.shields.io/github/issues/charlesdotfish/smtp-credentials-cdk-construct.svg)](https://github.com/charlesdotfish/smtp-credentials-cdk-construct/issues/)
[![GitHub Pull Requests](https://img.shields.io/github/issues-pr/charlesdotfish/smtp-credentials-cdk-construct.svg)](https://github.com/charlesdotfish/smtp-credentials-cdk-construct/pulls/)

This GitHub action executes a command using the CDK CLI, from within a .NET SDK Docker container, and provides the output of the command as an action output. A subset of the AWS CLI supported environment variables may be used to configure the credentials used by the CDK CLI (those being `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` and `AWS_DEFAULT_REGION`).

## Example Usage

### Inputs

* `dotnet-version`: The version of the .NET SDK that should be used. Note that the value provided here will be used to select the Alpine .NET SDK image that will be used to execute the CDK command (e.g. if a version of `3.1` is provided, the .NET SDK image with the tag `3.1-alpine` will be used). At the time of writing, supported versions include: `2.1`, `3.1`, `5.0`, `6.0`. Default: `5.0`
* `cdk-version`: The version of the AWS CDK that should be installed. The version provided must be available on `npm`. Default: `1.94.1`
* `cdk-args`: The arguments that should be passed to `cdk` (e.g. `synth`).

### Outputs

* `cdk-command-output`: A log of the output from the CDK command that was executed. Note that this will be formatted using Markdown syntax, ready to be used as a Pull Request comment, Slack message, or otherwise.

### Workflow Example

```yaml
name: Pull Request

on:
  pull_request:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v2

      - name: Build cloud artifact
        uses: charlesdotfish/dotnet-cdk-action@v1
        with:
          cdk-args: synth

      - name: Upload cloud artifact
        uses: actions/upload-artifact@v1
        with:
          name: cdk.out
          path: cdk.out

  diff:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Download cloud artifact
        uses: actions/download-artifact@v1
        with:
          name: cdk.out

      - name: Perform diff
        id: perform-diff
        uses: charlesdotfish/dotnet-cdk-action@v1
        with:
          cdk-args: diff --app cdk.out
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_DEFAULT_REGION: us-west-2

      - name: Comment on Pull Request
        env:
          URL: ${{ github.event.pull_request.comments_url }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          echo '${{ steps.perform-diff.outputs.cdk-command-output }}' > cdk.log
          jq --raw-input --slurp '{body: .}' cdk.log > cdk.json
          curl \
            -H 'Content-Type: application/json' \
            -H "Authorization: token $GITHUB_TOKEN" \
            -d @cdk.json \
            -X POST \
            $URL
```