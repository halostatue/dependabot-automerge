# KineticCafe/actions/extract-changelog

A simple composite action to extract a version section from a Markdown
changelog file that is substantially similar to [keep a changelog][] without
being strict.

Version matching is performed eagerly, so extracting `1.0` will grab the first
section that matches `1.0`, even if it is `1.0.10`. The patterns are _not_
regular expressions, as they will be performed as exact string matches.

## Example Usage

This example will prepare a repository for deploying automatically (on pull
request merge to `next`) or manually from an open pull request (or the `HEAD`
commit of the default branch). If the workflow is manually dispatched and
`inputs.ref` is not entered by the user, the deploy will be resolved using the
`next` branch.

```yaml
name: Create Release

on:
  push:
    tags:
      - 'v*.*'

jobs:
  create-release:
    if: github.event.pull_request.merged == true
    name: Create Release
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4
      - name: version
        id: version
        run: echo "version=${GITHUB_REF#refs/tags/v}" >> "$GITHUB_OUTPUT"

      - uses: KineticCafe/actions/extract-changelog@1.4
        id: changelog
        with:
          changelog: ./Changelog.md
          version: ${{ steps.version.outputs.version }}

      - name: Create Release
        run: |
          gh release create \
            "${GITHUB_REF_NAME}" \
            --title "${GITHUB_REF_NAME}" \
            --notes "${{ steps.changelog.outputs.contents }}" \
            --verify-tag
```

## Inputs

- `version`: The version to extract from the changelog file. The version is
  treated as a plain string.

- `changelog`: The name of the changelog file to read. Assume that the name is
  case sensitive.

- `prefix`: The prefix string to use for distinct version detection within the
  changelog. Defaults to `##`, the markdown `h2` header.

- `version-pattern`: The version pattern to use. Must be `bare` (`%v`),
  `bracket` (`[%v]`), or a string with `%v` for the location of the version.
  Defaults to `bare`.

  If your changelog version lines have additional values, such as a build
  number (`[version - build]`), a partial pattern should be used (`[%v -`).

### Example Changelog Formats with Settings

#### Keep a Changelog

Example:

```changelog
# project

## [1.0.0] - YYYY-MM-DD

### Added

- Description
```

Settings:

```yaml
version-pattern: bracket
```

#### Simple

Example:

```changelog
# project

# 1.0.0 - YYYY-MM-DD

- Description
```

Settings:

```yaml
version-pattern: bare
```

#### Simple (with truncated major releases)

```changelog
# project

# 1.0 - YYYY-MM-DD

- Description
```

Settings:

```yaml
version-pattern: '%v '
```

#### Keep a Changelog (with Build Number)

Example:

```changelog
# project

## [1.0.0 - 75] - YYYY-MM-DD

### Added

- Description
```

Settings:

```yaml
version-pattern: '[%v -'
```

#### Ruby RDoc File

```changelog
= project

== 1.0.0 - YYYY-MM-DD

- Description
```

Settings:

```yaml
prefix: '=='
version-pattern: bare
```

## Outputs

- `contents`: The extracted changelog section.

[keep a changelog]: https://keepachangelog.com/
