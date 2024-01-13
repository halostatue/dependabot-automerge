# KineticCafe/actions/resolve-ref

A simple composite action to resolve an input reference to a Git SHA in the
running repository. This would most often be used for manually triggered deploy
actions to deploy test branches, commits, or pull requests.

## Example Usage

This example will prepare a repository for deploying automatically (on pull
request merge to `next`) or manually from an open pull request (or the `HEAD`
commit of the default branch). If the workflow is manually dispatched and
`inputs.ref` is not entered by the user, the deploy will be resolved using the
`next` branch.

```yaml
name: Manual Deploy

on:
  pull_request:
    branches: [next]
    types: [closed]

  workflow_dispatch:
    inputs:
      deploy:
        description: Type 'DEPLOY' to manually deploy.
      ref:
        type: string
        required: false
        description: >
          If specified, must be an open pull request. If unspecified, the
          deploy will happen from the HEAD commit on the repository default
          branch.

jobs:
  deploy:
    if: github.event.pull_request.merged == true || github.event_name == 'workflow_dispatch'
    name: Deploy
    runs-on: ubuntu-latest

    steps:
      - if: github.event_name == 'workflow_dispatch' && github.event.inputs.deploy !== 'DEPLOY'
        run: |
          echo "::error ::Only the input value 'DEPLOY' will trigger manual deploy."
          exit 1
      - if: github.event_name == 'workflow_dispatch'
        id: resolve
        uses: KineticCafe/actions/resolve-ref@v1.1
        with:
          ref: ${{ github.event.inputs.ref }}
          default-branch: next
          allowed: pr

      - if: github.event_name != 'workflow_dispatch'
        id: auto-resolve
        run: |
          {
            echo "ref=${GITHUB_SHA}"
            echo "name=${GITHUB_SHA}"
            echo "type=deploy-on-merge"
          } >>"$GITHUB_OUTPUT"

      - uses: actions/checkout@v4
        with:
          ref: ${{ steps.resolve.outputs.ref || steps.auto-resolve.outputs.ref }}

      # From this point, the target ref, name, and type can be accessed using
      # the form: ${{ steps.resolve.outputs.X || steps.auto-resolve.outputs.X }}
      #
      # For workflow dispatch, `inputs.ref` will be resolved. If not provided,
      # it defaults to the `next` branch.
```

## Inputs

- `token`: The GitHub token for use with this action.
  Default: `${{ github.token }}`

- `ref`: The branch name, open pull request number, tag, or commit reference to
  resolve.

  Pull request numbers must begin with `#` to distinguish them from commits that
  are all decimal digits. Closed or merged pull requests are ignored.

  If `inputs.ref` is omitted or empty, `inputs.default-branch` will be used for
  resolution.

- `default-branch`: The branch name to use for resolution if `inputs.ref` is
  omitted or empty.

  If `inputs.default-branch` is omitted or empty, this action will look up the
  name of the default branch and use that.

- `allowed`: The list of ref types that can be resolved. Typically, this will be
  used to restrict `inputs.ref` to open pull requests (with `pr`). This is
  a string containing a comma separated list of ref types. The default is
  `pr,branch,tag,commit`.

## Outputs

- `sha`: The resolved SHA
- `name`: The name used to resolve the SHA.
- `type`: The type of ref used to resolve the SHA. Will be one of
  `repo-default-branch` (no `ref` or `default-branch` values present),
  `default-branch` (no `ref`, but `default-branch` resolves), `pr` (an open PR
  matched), `branch` (a branch matched), `tag` (a tag matched), or `commit` (an
  explicit commit matched).
