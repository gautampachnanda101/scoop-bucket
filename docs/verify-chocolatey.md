Verify Chocolatey workflow

What this workflow does

- When the manifest file (e.g. `k3d-local.json`) is updated on `main` this workflow runs and reads the manifest version.
- It then checks Chocolatey for the same package name (derived from the manifest filename) and verifies the expected version exists there.
- It also supports being triggered via `repository_dispatch` with an `event_type` of `upstream_release` and an optional JSON payload `{ "version": "<version>" }` to override the manifest's version.

Triggers

- push: when `k3d-local.json` (or other listed manifests) is changed on `main`.
- repository_dispatch: `upstream_release` — the upstream repository (or a webhook) can call GitHub's repository dispatch API to notify this repo of a new release.
- workflow_dispatch: manual run from the Actions tab.

Example repository_dispatch curl (run from a safe place using a PAT with `repo` scope):

```bash
curl -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: token <PERSONAL_ACCESS_TOKEN>" \
  https://api.github.com/repos/gautampachnanda101/scoop-bucket/dispatches \
  -d '{"event_type":"upstream_release","client_payload":{"version":"1.0.0-rc.1"}}'
```

Notes and recommendations

- If upstream (https://github.com/gautampachnanda101/local-cluster-k3d) publishes releases, the ideal integration is to add a small workflow there that calls this repository's dispatch endpoint (using a PAT stored in that upstream repo's secrets) on `release` events. That keeps this repo reactive to upstream releases.

- Alternatively, if you prefer not to add upstream automation, this repo can include a scheduled job (cron) that polls the upstream releases API and triggers this verify step when it sees a new tag/version. I didn't add polling to avoid unnecessary API calls, but I can add it if you'd like.

- The workflow currently derives the package name from the manifest filename. If you have multiple manifests or different naming rules, we should make the parsing more robust (read a `name` field if present).

- The Chocolatey check runs on `windows-latest` and installs Chocolatey if missing. This should be reliable for GitHub-hosted Windows runners.

