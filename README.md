# PIC Official Repository

This repository hosts the **official materials for the Provenance Identity Continuity (PIC) framework**, including:

- the **PIC Model** — the conceptual and formal theoretical framework,
- the **PIC Specification (PIC Spec)** — the normative definition of execution semantics and invariants,
- and, when published, **PIC Protocol specifications** defining concrete protocol encodings and interoperability profiles.

Together, these documents define what it means for a system to be
**PIC-compliant**.

> **Attribution Notice**  
> This work is based on the **Provenance Identity Continuity (PIC) Model**,  
> a theoretical framework created by **Nicola Gallo**, including its foundational
> definitions, invariants, and the structural resolution of the *confused deputy*
> class of vulnerabilities.  
>  
> The **PIC Specification** and all related official documents are published,
> maintained, and governed by **Nitro Agility S.r.l.** as the Specification Steward.
>  
> Authorship of the PIC Model remains with its original author and is independent
> of repository ownership, governance, or publication activities.

---

## Scope and Authority

- This repository contains the **Official PIC Specification** and related official
  documents designated by the Specification Steward.
- PIC Protocol documents, when present, **implement** the PIC Model as defined by
  the PIC Spec and MUST NOT redefine its core invariants.
- Forks and derivative works may exist under the terms of the license, but **MUST
  NOT present themselves as canonical** unless explicitly designated by the
  Specification Steward.

---

## Building RFC documents

The specifications under `draft/0.2/` are authored in kramdown-rfc markdown and compile to RFC-style
XML (RFCXML v3), HTML, and plain text next to their sources, under `draft/<version>/rfc/`, which is
committed. The pipeline uses
[kramdown-rfc2629](https://github.com/cabo/kramdown-rfc) (Ruby) and [xml2rfc](https://github.com/ietf-tools/xml2rfc)
(Python), both installed locally under `.tools/` — nothing is installed system-wide and `sudo` is never used.

Prerequisites: [Task](https://taskfile.dev), `python3`, and a Ruby ≥ 3.0 (e.g. `brew install ruby`; the
setup script finds the Homebrew Ruby automatically and never uses the macOS system Ruby for gems).

```sh
task rfc:setup     # one-time (idempotent): kramdown-rfc into .tools/gems, xml2rfc into .tools/xml2rfc-venv
task rfc:check     # verify toolchain + validate all configured specs (no outputs written)
task rfc:build     # build draft/<version>/rfc/<name>.{xml,html,txt} for every spec in scripts/rfc/sources.txt
task rfc:clean     # remove generated outputs and logs
task rfc:rebuild   # clean + build
```

Builds are atomic per document: outputs land in the version's `rfc/` directory only if that document
converts and renders without errors; per-document logs are written to `.cache/rfc-logs/`. The list of
specs to build is `scripts/rfc/sources.txt` (`pic-legal.md` is intentionally excluded: it is a legal
appendix incorporated by reference, not a specification).

In the generated HTML, cross-references between the built specs are relative `.html` links, so the
set is navigable wherever it is served: a static host, a local checkout, or directly from GitHub via
[htmlpreview](https://htmlpreview.github.io/), e.g.
`https://htmlpreview.github.io/?https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/rfc/pic-spec.html`.
Each document's *Source* link and `pic-legal.md` keep pointing to the canonical markdown on GitHub. When a new draft version is created (e.g.
`draft/0.3/`), add its specs to `sources.txt` and keep the old versions listed: a single
`task rfc:build` then rebuilds every configured version — `draft/0.2/rfc/`, `draft/0.3/rfc/`, and so on.

---

## License

This project is licensed under the  
**Creative Commons Attribution 4.0 International (CC BY 4.0)** license.

See `LICENSE` for full terms.

---

## Governance and Contributions

Project process and responsibilities are defined by the following documents:

- **Governance:** `GOVERNANCE.md`
- **Contributing:** `CONTRIBUTING.md`
- **Code of Conduct:** `CODE_OF_CONDUCT.md`
- **Maintainers:** `MAINTAINERS.md`
- **Security Policy:** `SECURITY.md`

Authorship, attribution requirements, and the normative status of the
PIC Model, PIC Spec, and PIC Protocol documents are defined **exclusively**
in the PIC Specification (Appendix B).

In case of conflict, the applicable LICENSE files and the normative text of the
PIC Specification and any Official PIC Protocol specifications take precedence
over this README.
