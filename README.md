# halostatue/dependabot-automerge

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
      - uses: halostatue/dependabot-automerge@v1
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

- `merge-type`: The type of merge to be applied. Supported values are `auto`,
  `merge`, `rebase`, and `squash`. If `auto` is specified, this action will
  check the current repo whether merge commits, squash commits, and/or rebase
  commits are permitted (in that order). The first one enabled will be selected.

[KineticCafe]: https://github.com/KineticCafe
[KineticCommerce]: https://github.com/KineticCommerce
[dco]: https://developercertificate.org
[code of conduct]: https://github.com/KineticCafe/code-of-conduct
