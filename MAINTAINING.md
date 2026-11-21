# Maintaining ProfoundData

This page is for the ProfoundData team (maintainers and collaborators with write access to this repository). The [contributing guidelines](CONTRIBUTING.md) apply to the team as well; this page only adds the tasks that require write access.

## Issues and pull requests

- Set the target release as the milestone of the issue or pull request.
- Team members may merge their own pull requests. If in doubt, request a review from another team member first.
- Team members can mention `@claude` in a pull request comment or review to get a review or an answer from Claude Code (`.github/workflows/claude.yml`, secret `ANTHROPIC_API_KEY`). It can comment but not push; whoever asked checks its replies.
- As an exception to the pull request workflow, trivial changes and small changes outside the package folder `ProfoundData/` (e.g., in `PROFOUND database/`, README) can be committed directly to `master`; larger ones need a pull request.

## Branches

- Existing branches created before the [naming convention](CONTRIBUTING.md#pull-request-workflow) keep their names (e.g., `0.3.0`).
- A branch deleted after a merge can be restored with "Restore branch" on the pull request page.

## Preparing a CRAN release

- Work on a short-lived branch `v<version>-cranSubmission`: update `Version` in `ProfoundData/DESCRIPTION` and `ProfoundData/NEWS.md`, and make sure `R CMD check --as-cran` passes locally and in the GitHub Actions workflow.
- Record the submission and the CRAN correspondence in `CRAN.md`.
- After CRAN acceptance, merge into `master` and tag the release (e.g., `v0.3.0`). Delete stale branches.

## Database releases

The database is hosted at PIK ([doi:10.5880/PIK.2019.008](https://doi.org/10.5880/PIK.2019.008)) and built with the scripts in `PROFOUND database/`; release notes go into `PROFOUND database/readme.md`. A new database version also requires the package to point to it.
