Verify release available on Chocolatey

This repository now contains a single active CI workflow that runs when a GitHub release is published. The workflow verifies that the released version (as published in this repo's Scoop manifest) is available on Chocolatey and is installable end-to-end.

Files changed

- `.github/workflows/verify-release.yml` — new workflow that triggers on `release: published` and performs Chocolatey verification.
- `.github/workflows/verify-chocolatey.yml` — replaced with a disabled placeholder (no triggers).
- `.github/workflows/verify-manifest.yml` — replaced with a disabled placeholder (no triggers).
- `.github/workflows/upstream-poller.yml` — replaced with a disabled placeholder (no triggers).

How the `verify-release` workflow works

- Trigger: runs only when a GitHub release is published in this repo (`on: release: types: [published]`).
- Normalization: strips leading `v` or `V` from the release tag before matching (e.g. `v1.2.3` -> `1.2.3`).
- Manifest discovery: scans the `bucket/` directory and repository root for JSON Scoop manifests. For each manifest it reads the `version` field and normalizes it (also strips a leading `v`), then looks for manifests whose normalized `version` equals the normalized release tag.
- Chocolatey package id mapping: if a manifest contains a `chocoId` field, that value is used as the Chocolatey package id; otherwise the workflow prefers the `name` field in the manifest, and falls back to the manifest filename (without extension).
- Verification steps for each matching manifest:
  - Ensures `choco` CLI is available on the Windows runner (installs Chocolatey if missing).
  - Runs `choco list <id> --exact --all-versions` and confirms the expected version appears in the output.
  - Attempts `choco install <id> --version <version>`, verifies the installed package version is reported locally, then uninstalls it.

Notes and edge cases

- Pre-release handling: the workflow matches manifest `version` to the normalized release tag exactly. If you use pre-release tags with suffixes (for example `1.2.3-beta.1`), ensure the manifest `version` contains the same suffix. The workflow does not currently special-case pre-release vs release beyond normalization of a leading `v`.
- If multiple manifests in the repo have the same version, the workflow will verify each one (useful if there are multiple packages released with the same version).
- If no manifest matches the release version the workflow fails early.

Testing the workflow (recommended)

1. Push these changes to a branch or directly to `main` (your choice). Example (from repo root):

```bash
# create a topic branch (optional)
git checkout -b ci/verify-release
# stage changes
git add .github/workflows/verify-release.yml .github/workflows/verify-chocolatey.yml \
  .github/workflows/verify-manifest.yml .github/workflows/upstream-poller.yml docs/verify-release.md
git commit -m "ci: add verify-release workflow; disable other workflows"
git push --set-upstream origin ci/verify-release
```

2. Create a GitHub release whose tag (after optional leading `v`) matches a manifest `version` in this repo. You can create a release via the GitHub web UI or with the GitHub CLI:

```bash
# using gh (creates tag if missing)
gh release create v1.2.3 --title "v1.2.3" --notes "test release" --repo gautampachnanda101/scoop-bucket
```

3. Watch the Actions page for the `Verify release available on Chocolatey` run. Open the job log on the `windows-latest` runner and inspect these steps:
- "Determine and normalize tag"
- "Find matching Scoop manifest(s)"
- "Verify each package on Chocolatey and attempt install"

4. If the workflow fails because Chocolatey does not list the expected version, investigate the manifest `version` and the Chocolatey package id (check `chocoId` if present) and verify the package was pushed to Chocolatey.

Rollback

If you change your mind, you can restore previous workflow files from Git history or remove the `verify-release.yml` file and re-enable older workflows.

Next steps / improvements

- Add optional filtering to ignore pre-releases unless the manifest explicitly contains the pre-release suffix.
- Add retries with backoff when querying Chocolatey in case of transient network issues.
- Add a `workflow_dispatch` trigger for manual verification runs (currently the workflow triggers only on published releases).

If you'd like, I can also create a PR with these changes and open it against `main` in this repo, or push directly and create the release to exercise the workflow — tell me how you'd like to proceed.
