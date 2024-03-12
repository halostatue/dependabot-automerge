# KineticCafe/actions Changelog

## 1.3 / 2024-03-13

- Enhanced `KineticCafe/actions/resolve-ref` to output better errors when
  resolution fails, and add a `debug` input to turn on `set -x` for the
  resolution phase of the script.

There are no changes to `KineticCafe/actions/dependabot-automerge`. It can be
accessed via `@v1.2` or `@v1.3`.

## 1.2 / 2024-01-22

- Enhance `KineticCafe/actions/dependabot-automerge` to allow specification
  of the type of merge to run. Found because we have repositories configured not
  to allow merge commits.

- Fix an issue with `KineticCafe/actions/resolve-ref` for non-PR resolution
  where the output on error was being captured as the `TARGET_SHA`.

## 1.1 / 2024-01-13

- Initial release of `KineticCafe/actions/resolve-ref`. This is the extraction
  of a complex reused script used in multiple repositories in
  [KineticCommerce][].

There are no changes to `KineticCafe/actions/dependabot-automerge`. It can be
accessed via `@v1.0` or `@v1.1`.

## 1.0 / 2023-07-27

- Initial release of `KineticCafe/actions/dependabot-automerge`. This is the
  extraction of a common workflow used across repositories in both
  [KineticCafe][] and [KineticCommerce][].

[KineticCafe]: https://github.com/KineticCafe
[KineticCommerce]: https://github.com/KineticCommerce
