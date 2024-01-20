# KineticCafe/actions/dependabot-automerge

A simple composite action to simplify the enabling of auto-merge of Dependabot
PRs.

## Example Usage

```yaml
name: Dependabot Automerge

on:
  pull_request:

jobs:
  dependabot-automerge:
    runs-on: ubuntu-latest

    permissions:
      contents: write
      pull-request: write

    steps:
      - uses: KineticCafe/actions/dependabot-automerge@v1.1
        with:
          update-type: minor
          merge-type: rebase
```

## Inputs

- `repo-token`: The GitHub token for use with this action. It must have
  sufficient permissions to write pull request details (`pull-request: write`).

  Default: `${{ github.token }}`

- `update-type`: The highest level of update that can be automatically merged.
  The default value is `patch`; supported values are `major`, `minor`, and
  `patch`. Automatic merge for `major` is not recommended.

- `merge-type`: The type of merge to be applied. Defaults to `merge`; supported
  values are `merge`, `rebase`, and `squash`.
