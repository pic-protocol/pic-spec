# Contributing to the PIC Project

Thank you for contributing to the Provenance Identity Continuity (PIC) project. This repository contains the PIC Model specification, its
subordinate technical specifications, and the tooling used to publish them.

## Scope

Contributions may include:

- editorial corrections and clearer terminology;
- formal or security analysis;
- examples and interoperability material;
- protocol encodings, profiles, and test vectors;
- implementation-status reports; and
- alignment fixes between the mathematical model, specifications, and implementations.

Substantive semantic changes should begin with an issue that explains the motivation, security implications, compatibility impact, and any
effect on the PIC invariants.

## Technical Integrity

A contribution to a PIC specification must identify whether it is editorial, normative, informative, or profile-specific. It must not
silently weaken the model invariants, present partial implementation coverage as full conformance, or mix authority from unrelated causal
histories as an ordinary continuation.

The dated origin and research history of the PIC Model are recorded in the PIC Specification. Contributors receive credit for their concrete
contributions; contribution does not rewrite that historical record or imply endorsement, stewardship, warranty, or operational responsibility.

## Contribution Process

1. Open or identify an issue for substantive work.
2. Create a focused branch and scoped commits.
3. Update affected cross-references, examples, and implementation-status statements.
4. Run the available validation and RFC-rendering checks.
5. Open a pull request describing the change and its security and compatibility impact.

Editors may request revision or decline changes that conflict with the project scope or the PIC invariants. Accepted changes become part of
the canonical specification only when included in a release designated by the Specification Steward.

## Licensing and Right to Contribute

Unless a file states otherwise, this repository is licensed under CC BY 4.0. By submitting a contribution, each contributor confirms that:

- they created the contribution or otherwise have the right to submit it;
- the contribution contains no confidential material and does not knowingly include third-party material without the required permission;
- the contribution may be edited, reorganized, published, and distributed under the repository license;
- they identify any pre-existing material, applicable license, or third-party rights; and
- if accepted into a document later submitted to a standards-development process, the contribution may be submitted and developed under the
  applicable contribution and publication rules of that process.

The final point preserves the ability to develop the specification in an open standards process. A contributor who cannot make these
confirmations should open an issue before submitting text.

Pull requests should include a Developer Certificate of Origin style sign-off in each commit:

~~~text
Signed-off-by: Full Name <email@example.com>
~~~

The sign-off states that the contributor has the right to submit the contribution under these terms. Existing contributions are not assigned
new rights merely by a later edit to this file; any additional permission needed for an external standards submission must be confirmed for
those contributions when applicable.

## Editors, Contributors, and Stewardship

Document editors maintain the text and respond to review. Contributors are credited for significant technical or editorial work. Nitro
Agility S.r.l. currently acts as Specification Steward and designates canonical project releases. These roles are distinct from the dated
scientific origin of the PIC Model.

Contributor and acknowledgment lists should describe concrete contributions and should not be used to allocate liability or imply
endorsement.

## Automated Language Assistance

Automated language assistance may be used for editing, formatting, or analysis. The human contributor remains responsible for accuracy,
originality, licensing, and the technical content submitted.

## Conduct and Discussion

All participants must follow the [Code of Conduct](CODE_OF_CONDUCT.md). Technical disagreement is welcome when it is specific, evidence-based,
and respectful. Questions about scope or contribution rights should be raised in the issue tracker before a pull request is submitted.
