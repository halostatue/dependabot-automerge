# KineticCafe/actions

This repository holds shared public workflow actions, mostly composite actions,
used by Kinetic Commerce in its open source ([KineticCafe][]) and private
([KineticCommerce][]) repositories. Because it's shared, all tags are shared
across all workflow versions.

## Workflows

- [dependabot-automerge](tree/main/dependabot-automerge): A simple composite
  action to simplify the enabling of auto-merge of Dependabot PRs.

- [extract-changelog](tree/main/extract-changelog): A simple composite action to
  extract a version section from a changelog file.

- [resolve-ref](tree/main/resolve-ref): A simple composite action to resolve an
  input reference to a Git SHA in the running repository.

## Contributing

We value contributions to KineticCafe/actions—bug reports, discussions, feature
requests, and code contributions. Contributions to this repository are released
under the Apache License, version 2.0 and require Developer Certificate of
Origin sign-off.

KineticCafe/actions is governed under the Kinetic Commerce Open Source [Code of
Conduct][].

### Developer Certificate of Origin

All contributors **must** certify they are able and willing to provide their
contributions under the terms of this project's licenses with the certification
of the [Developer Certificate of Origin (Version 1.1)][dco].

Such certification is provided by ensuring that the following line must be
included as the last line of a commit message for every commit contributed:

    Signed-off-by: FirstName LastName <email@example.org>

The `Signed-off-by` line can be automatically added by git with the `-s` or
`--signoff` option on `git commit`:

```sh
git commit --signoff
```

[KineticCafe]: https://github.com/KineticCafe
[KineticCommerce]: https://github.com/KineticCommerce
[dco]: https://developercertificate.org
[code of conduct]: https://github.com/KineticCafe/code-of-conduct
