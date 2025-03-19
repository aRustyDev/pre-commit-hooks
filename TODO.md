# TODO

1. Terraform_test : Runs `terraform test`
2. Changelog-tfupdates : Updates Changelog automatically adds bullet under `unreleased` if any of (terraform.lock, or provider.version) change
3. Changelog-terraform-docs : Updates Changelog automatically adds bullet under `unreleased` if any READMEs change
4. Changelog-terraform-tests : Updates Changelog automatically adds bullet under `unreleased` if any changes occur under `./tests`
5. Pluralith local : Runs Pluralith locally
6. Ensure links exist in footer for each version
7. Ensure links in footer that aren't `unreleased` or `0.1.0` describe show compare links
8. Ensure CHANGELOG includes links to TAGs/Releases
9. Auto update CHANGELOG.md using commit messages (following conventional commit)
    - Fixed: (fix)
    - Added: (feat)
    - Changed: (refactor)
    - Uncategorized: (docs,style,perf,test,build,ci,chore)
10. Add `codecov` run
11. Check repo links (find dead links)
12. `.proto` : syntax validation, variable name linting, file name linting
13. Run cosign
14. `.go`
15. `.py`
16. `.nix` : syntax validation, variable name linting, file name linting, run tests, sbom signing
17. `in-toto/witness` : generate attestations
    - PR(in-toto/witness): Modify releases to be `go get/install` compatible
    - PR(in-toto/witness): Make config file more intuitive
    - PR(in-toto/witness): Add additional Examples
    - PR(in-toto/witness): Add `.pre-commit-hooks.yaml` & `/hooks/witness.sh`

## Cargo hooks

- sort `mod.rs` files contents
- check for code doc coverage
- create issues out of `**/TODO.md` contents via the `gh` cli or `octocrate`
