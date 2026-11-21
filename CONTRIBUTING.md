# Contributing to ProfoundData

Contributions to ProfoundData are welcome! This document describes how to contribute effectively and what to expect from the process. Tasks of the ProfoundData team (maintainers and collaborators with write access to this repository), such as preparing a CRAN release, are described in [Maintaining ProfoundData](MAINTAINING.md).

## What this repository contains

- `ProfoundData/`: the R package that downloads and explores the PROFOUND database.
- `PROFOUND database/`: the scripts that were used to build, test and export the database (see the [readme](PROFOUND%20database/readme.md) there). The database itself is hosted by the Potsdam Institute for Climate Impact Research ([doi:10.5880/PIK.2019.008](https://doi.org/10.5880/PIK.2019.008)).

Please say in your issue whether the problem concerns the **package** (functions, documentation, installation) or the **database contents** (e.g., a wrong value, a missing site or variable). Both are reported in the same issue tracker; for database problems, name the dataset, table, site and variable, and the database version.

## Ways to contribute

### Asking for help and reporting issues

ProfoundData is open-source software, and in the spirit of open source, questions and answers should be public, so that other people can profit from them as well. Please ask questions, report problems and suggest features on the [issue tracker](https://github.com/TheoreticalEcology/ProfoundData/issues), after searching the existing issues. If you have concerns posting to a public forum, you can also write to the maintainer by e-mail (run `maintainer("ProfoundData")` in R to get the address).

For package problems and errors, please include a minimal reproducible example: code that runs as is in a fresh R session and shows the problem, together with the output of `sessionInfo()` and the version of the database you use. See [How to make a great R reproducible example](https://stackoverflow.com/questions/5963269/how-to-make-a-great-r-reproducible-example) and the [reprex](https://cran.r-project.org/package=reprex) package. Problem reports without a reproducible example may be closed.

Please write issues so that they are understandable without earlier discussions. If you have already diagnosed the problem or have ideas for a fix, including that analysis is very helpful.

### Submitting pull requests

Please open or comment on an issue before you start working on a pull request, so that the approach can be discussed before you invest time in an implementation. Only trivial fixes (e.g., typos or a factual error in the documentation) can go directly to a pull request. Other pull requests from contributors outside the ProfoundData team may be closed without detailed review if they were not discussed in an issue first, or if reviewing them would take more effort than they are likely to add, whether or not AI was used. See [Pull request workflow](#pull-request-workflow) below.

Corrections to the database contents are made in the scripts in `PROFOUND database/` and published as a new database version; please discuss them in an issue first.

## Policy on AI-generated contributions

This policy applies to contributors outside the ProfoundData team; only the disclosure of AI use (last paragraph) applies to everyone.

**Issues, pull requests and comments created autonomously by AI agents or automated tools will not be accepted.** They will be closed or deleted without review.

The maintainer must be able to understand, evaluate, and take long-term responsibility for every change integrated into ProfoundData. AI-generated code frequently appears correct but introduces subtle errors that are difficult to detect without deep familiarity with the codebase, and the burden of reviewing such contributions falls disproportionately on the maintainer. For a scientific package and database where correctness is critical, this risk is not acceptable.

This policy covers issues, pull requests and comments submitted autonomously by AI agents, as well as contributions where the submitter does not have a full, independent understanding of the proposed changes. Having a tool post a contribution at your explicit request, after you have checked its content, does not count as autonomous.

Using AI tools as a personal aid during development is a matter of individual choice. However, any contribution must be authored and understood by a human who can explain, defend, and iterate on the proposed changes.

If you are unsure whether your contribution complies with this policy, ask yourself: can you explain every line of your proposed change and its consequences for the rest of the codebase? If not, please do not submit it as a pull request — an issue describing the problem or idea is a better starting point.

For everyone, including the ProfoundData team: if AI tools wrote substantial parts of your code or text, you must say so briefly in your issue, pull request, comment or commit (one sentence is enough, e.g., "Code drafted with an AI assistant, checked and tested by me."; in commits, use a trailer such as `Assisted-by: <tool> (<model>)`). Instructions for AI coding agents, including those used by the ProfoundData team, are in [AGENTS.md](AGENTS.md).

## Pull request workflow

`master` is the development branch; CRAN releases are tagged on `master` (e.g., `v0.3.0`). There are no separate development or release branches, except a short-lived branch `v<version>-cranSubmission` for each CRAN submission.

- Members of the ProfoundData team create branches in this repository; other contributors work in a fork, where the branch name is up to them.
- Every branch in this repository addresses at least one issue (except trivial fixes, see [Submitting pull requests](#submitting-pull-requests)). Create it from `master` and name it as follows, with `-` as separator and `<shortName>` in lowerCamelCase:
  - one issue: `i<issue number>-<shortName>`, e.g., `i45-fixPlotData`.
  - several closely related issues for the same release: `v<release>-<shortName>`, e.g., `v0.3.1-docFixes`.
  - trivial fixes without an issue: `<shortName>`, e.g., `fixTypoVignette`.
  - Do not name a branch exactly like a release tag (e.g., `v0.3.1`).
- Keep each pull request focused on one issue, or on several closely related issues for the same release, and open it against `master`. Do not split one issue across several pull requests; follow-up work gets a new issue.
- Keep the diff small: no unrelated reformatting or refactoring, and reuse existing helper functions instead of duplicating logic.
- Once the approach is agreed in the issue, open the pull request early, as a draft if the work is not finished yet. If the work is abandoned, close the pull request with a short explanation.
- A pull request or commit that resolves an issue should contain `Fixes #45` or `Closes #45` (with your issue number) in its description or commit message, so that GitHub closes the issue automatically when it is merged into `master`. For several issues, repeat the keyword for each.
- Fill in the sections of the pull request template and go through the checklist in its comment before submitting. Pull requests from contributors outside the ProfoundData team are reviewed before they are merged.
- Titles of issues and commit subject lines are short plain text (ideally under 70 characters, no backticks) naming the function or area and the problem or change, so that a list of titles is understandable without opening them; avoid vague titles such as "Small fixes". In commit messages, separate the body (if any) from the subject line by an empty line.
- Pull request titles are short plain text stating the general idea, without issue numbers, e.g., "Fixes to CRAN notes". Keep pull request descriptions short; details belong in the issues.
- After the merge, branches in this repository are deleted automatically.

## Code and documentation standards

- The R package is in the subfolder `ProfoundData/`. Please follow the existing code style and conventions.
- New or changed functions should include roxygen2 documentation. The help files in `ProfoundData/man/` are generated from it; do not edit them by hand, but run `devtools::document("ProfoundData")` from the repository root.
- Code that addresses a specific problem described in an issue and is not self-explanatory gets a short comment with the issue number and, if it fits in a few words, the problem it solves. Use such comments sparingly.
- If your contribution changes or adds functionality, please include or update tests in `ProfoundData/tests/testthat/`. Tests that expect an error or warning should check its message; tests that use random numbers should call `set.seed()` at the start of each `test_that()` block. Many tests need a local copy of the database: set the environment variable `PROFOUND_DB` to the path of `ProfoundData.sqlite` (e.g., in `~/.Renviron`); otherwise these tests are skipped.
- Add a short (ideally one-line) entry to `ProfoundData/NEWS.md` in the fitting section under the topmost version heading for every user-visible change, ending with the issue or pull request number(s).
- `R CMD check` runs on pull requests to `master` (GitHub Actions; for first-time contributors after approval by the ProfoundData team) and must pass. Locally, it is usually sufficient to run the tests related to your change, e.g., `testthat::test_file()` on the matching file in `ProfoundData/tests/testthat/` after `devtools::load_all("ProfoundData")`.

## Attribution and authorship

Contributors who make substantial contributions to ProfoundData will be acknowledged by name in the README and/or the NEWS.md file. Minor corrections such as fixing typos or small formatting adjustments do not typically result in named acknowledgement, as is standard in open-source scientific software. If you are uncertain whether a planned contribution would qualify, you are welcome to ask in the relevant issue.
