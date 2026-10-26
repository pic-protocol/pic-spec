---
title: "PIC Revocation"
abbrev: "PIC Revocation"
docname: pic-revocation-02
category: info
ipr: none
submissiontype: independent
stand_alone: yes
smart_quotes: false
pi: [toc, sortrefs, symrefs]
date: 2026-07-18

author:
  - ins: N. Gallo
    name: Nicola Gallo
    org: Nitro Agility S.r.l.
    email: nicola.gallo@nitroagility.com

normative: {}
informative: {}
---

--- note_Document_Status

**Project:** PIC Protocol
**Project Website:** [www.pic-protocol.org](https://www.pic-protocol.org/)
**Document:** pic-revocation-02
**Version:** 0.2 (Draft)
**Document Status:** Public Draft
**Intended Use:** Informational and Experimental
**Published:** 2026-07-18
**Editor(s):** Nicola Gallo (Nitro Agility S.r.l.)
**Steward:** Nitro Agility S.r.l.
**Source:** [github.com/pic-protocol/pic-spec/draft/0.2/pic-revocation-spec.md](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-revocation-spec.md)

--- note_About_This_Document

> **Public Draft — Not a Standard**
>
> This document is an independently developed specification published as part of the PIC Protocol and maintained by Nitro Agility
> S.r.l. in its role as Specification Steward.
>
> It has not been adopted, endorsed, approved, or published by the IETF, IRTF, IAB, RFC Editor, ISO, IEC, W3C, CNCF, OpenID
> Foundation, or any other standards-development organization, unless a later version explicitly states otherwise.
>
> It is not an RFC, an Internet Standard, or an official work item of any working group or standards body.
>
> This document is published for public review, research, experimentation, implementation feedback, and possible future
> standardization work. It may be revised, replaced, or withdrawn at any time.
>
> Implementers use this draft at their own risk. Any implementation, interoperability statement, or conformance claim applies only
> to the exact document version identified above.
>
> Publication of this draft does not constitute certification, endorsement, security approval, interoperability assurance,
> regulatory approval, or standards-body recognition.
>
> Current project information and published specifications are available at `https://www.pic-protocol.org/`.

--- to_be_removed_note_Work_In_Progress

**Work in Progress — Experimental Design**

The revocation model described in this document is under active development.

This model may change substantially before a later stable revision.

Implementers MUST NOT assume wire compatibility, semantic compatibility, or backward compatibility with future revisions.

Future drafts may introduce breaking changes to terminology, data structures, processing rules, profile bindings, and
interoperability requirements.

The current text is published for design review, experimentation, and implementation feedback.

--- note_Editors

- **Nicola Gallo** (Nitro Agility S.r.l.) Lead Editor
- *Add your name via pull request (individual or organization) — listing is subject to editor approval (see [Contributors](#contributors)).*

--- note_Contributors

- *Add your name via pull request (individual or organization) — listing is subject to editor approval (see [Contributors](#contributors)).*

--- abstract

This document is the **PIC Revocation Specification**, a subordinate specification of the
[PIC Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-spec.md). It defines how authority is revoked within
the Provenance Identity Continuity (PIC) Model.

Expiry bounds how long a continuity state may be accepted; revocation withdraws validity before that bound. PIC revocation preserves the
core model invariants: exactly one predecessor per non-root advancement, Proof of Relationship, authority non-expansion, and no authority
import from unrelated continuities.

For a linear revocation profile, a stable authenticated lineage/PCA identifier plus a continuity **position** can name a causal suffix. In a
fan-out profile, the same pair names a lineage and path depth but does not uniquely name an occurrence or its causal descendants: sibling
states may share the same position. Branch-selective or occurrence-selective revocation therefore requires an additional authenticated
occurrence, checkpoint, branch, or ancestry coordinate. This document calls the stable lineage identifier **PCA ID**. Additional
authenticated selectors, such as grant, issuer, key, delegate, attestation, or policy selectors, may be used by a profile but do not replace
the required causal coordinates when descendants, rather than a whole lineage-depth range, must be invalidated.

--- middle

# Introduction

This section is non-normative. It introduces the revocation model used by this document.

PIC continuity starts from a trusted root PIC Context of Authority, or PCA, and advances through non-root continuity advancements. A
revocation that must affect an entire lineage or depth range needs a stable way to name the root authority context and the path position at
which validity stops. A revocation that must affect only descendants of one occurrence in a fan-out graph additionally needs authenticated
occurrence identity and ancestry.

In PIC Profile 0.2, a trusted settlement authority issues settled PIC Token JWTs carrying settled PIC Continuity COSE artifacts. A workload
may propose exactly one advancement in a workload-signed candidate PIC Token JWT whose candidate PIC Continuity COSE carries exactly one PIC
Continuity Transition COSE. The settlement authority validates that candidate and, if it accepts the advancement, issues the next settled PIC
Token JWT. Settled Profile 0.2 Continuity COSE artifacts have `transitions = null` and do not carry a replayable transition history.

Revocation state remains external and dynamic. Revoking a PCA, position, key, delegate, attestation, grant, issuer, or policy does not
rewrite signed PIC PCA COSE checkpoints and does not rebuild historical transitions. Verifiers and settlement services evaluate authenticated
revocation state against the presented continuity state.

The current PIC-X 0.2.3 binding requires a signed PCA `lineage_id`, preserves it across advancement, and mirrors it into PIC Token JWT
`jti`; it also preserves a signed PCA `position`. These are useful authenticated revocation coordinates. PIC-X 0.2.3 nevertheless configures
the PIC revocation hook as a no-op and implements no PIC revocation state. Absolute `expires_at` and settlement-key retention bound
acceptance but are not early revocation [[4]](#references).

## Requirements Notation

The normative sections of this document are Sections 2, 3, 4, and 5. Sections 1 and 6 are non-normative.

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and
"OPTIONAL" are to be interpreted as described in BCP 14 [[2]](#references) [[3]](#references) when, and only when, they appear in all capitals
within normative text.

# Revocation Coordinates

This section is normative.

## PCA ID

A revocation profile that supports causal lineage or suffix revocation MUST define a stable authenticated **PCA ID** or equivalent
lineage/PCA identifier. The PCA ID identifies the trusted continuity origin and revocation domain. It is stable across successor checkpoints;
a changing checkpoint hash identifies one occurrence and is not the lineage identifier unless a profile explicitly defines a separate
checkpoint-scoped revocation domain.

The PCA ID MUST be bound to the relevant trusted PCA checkpoint artifact or to authenticated metadata covered by the selected revocation
profile. It MUST NOT be a freely chosen unauthenticated value. The selected revocation profile MUST define its representation,
authentication, issuer or authority, lookup and validation procedure, freshness, rollback protection, and unavailable-state behavior.

This document does not define one universal wire claim or field carrying the PCA ID. It also does not define JWT `jti` as the PCA ID for
every profile. A profile MAY map a concrete claim, field, artifact hash, or authenticated metadata item to the PCA ID only when that mapping
is explicitly defined and authenticated by that profile.

Current Profile 0.2 settled PIC Continuity COSE carries the exact signed current PIC PCA COSE checkpoint bytes at:

~~~text
root.pca
~~~

The corresponding signed-artifact hash is carried at:

~~~text
root.pca_hash
~~~

Those fields identify the current trusted checkpoint artifact for Profile 0.2 validation. In the current PIC-X binding, the signed PCA
`lineage_id` is the stable lineage/PCA identifier and the PIC Token JWT `jti` MUST equal it. The base Profile 0.2 artifact schema leaves
`lineage_id` optional, while PIC-X requires it. `root.pca_hash` identifies one checkpoint and MUST NOT be substituted for the stable
`lineage_id` when the intended revocation scope is the whole lineage.

## Position

A revocation profile that supports causal suffix revocation MUST expose or authenticate a continuity `position`.

The position identifies causal order along one path within the continuity rooted at the PCA ID. The root position and the progression from
each predecessor to each successor MUST be unambiguous. A non-root advancement MUST have the position required by the selected continuity
profile.

Position is not a global event identifier. In a fan-out profile, two incomparable sibling states MAY have the same PCA ID and position. A
profile MUST NOT infer that equal positions identify one occurrence, or that numeric ordering alone proves ancestry across branches.

The profile MUST reject missing, negative, fractional, non-canonical, overflowing, wrapping, or otherwise invalid positions. A profile MUST
NOT introduce a second mandatory counter solely for revocation when the continuity profile already defines positions.

For current Profile 0.2, `position` is carried by PIC PCA COSE checkpoints and PIC Continuity Transition COSE artifacts. PIC Continuity COSE
itself does not carry a `position` field.

## Linear and Branching Coordinates

For a profile that guarantees one accepted state at each position, the linear causal coordinate for suffix revocation is:

~~~text
(PCA ID, position)
~~~

A causal suffix cutoff is:

~~~text
(PCA ID, fromPosition)
~~~

It matches a presented continuity state when:

~~~text
state.PCA_ID == target.PCA_ID
AND state.position >= target.fromPosition
~~~

In a profile that permits fan-out, this predicate defines a **lineage-depth cutoff**: it applies across every branch sharing the PCA ID at or
beyond the selected depth. It does not mean “descendants of one selected occurrence.” A profile that claims occurrence-selective or
branch-selective causal revocation MUST additionally authenticate an occurrence or checkpoint identifier and the ancestry relation by which
the presented state descends from it.

Whole-continuity revocation is the root-position case and is unaffected by fan-out. The selected profile MUST define the root position used
for that comparison.

Knowledge of the PCA ID, the position, or both MUST NOT authorize revocation. Targeting and revocation authorization are separate.

# Revocation Semantics

This section is normative where BCP 14 language is used.

## Attenuation Is Not Revocation

Attenuation of a selected continuity advancement changes only the materialized authority of the accepted successor lineage. It MUST NOT be
interpreted as revocation of the predecessor checkpoint, invalidation of that predecessor, or invalidation of another otherwise-valid sibling
continuation from the same predecessor. Invalidating those states requires authenticated revocation state under the selected revocation profile.

## Linear Suffix and Lineage-Depth Cutoff

In a linear profile, a suffix cutoff invalidates the selected position and its causal future:

~~~text
(PCA ID, fromPosition)
~~~

A Verifier or settlement service MUST reject a matching state when the authenticated revocation state contains an authorized suffix cutoff and:

~~~text
state.PCA_ID == target.PCA_ID
AND state.position >= target.fromPosition
~~~

In a fan-out profile, the same comparison invalidates all matching branches at the selected position or greater and is therefore a
lineage-depth cutoff, not a branch-selective causal suffix. The profile MUST name that broader scope explicitly. If only descendants of one
occurrence are to be invalidated, the profile MUST use the additional occurrence/ancestry coordinate required by Section 2.3.

The exact wire representation and any concrete revocation-profile naming for these operations are profile-defined.

## Whole PCA

Whole-PCA revocation invalidates all continuity states rooted in the selected PCA ID. It is equivalent to a suffix revocation from the root
position:

~~~text
(PCA ID, rootPosition)
~~~

## Optional Selectors

A revocation profile MAY define additional authenticated selectors, including:

- grant binding;
- origin issuer;
- key or verification method;
- executor or delegate;
- attestation;
- policy;
- resource, tenant, or security-domain selector;
- another explicitly profile-defined authenticated selector.

These selectors are administrative or evidentiary criteria. They do not replace the causal coordinates required by the selected scope. In
a linear profile those coordinates may be `(PCA ID, position)`; in a branch-selective profile they additionally identify the selected
occurrence and authenticate ancestry.

Possession or knowledge of a selector value MUST NOT authorize revocation. For example, knowledge of a grant identifier, PCA ID, key
identifier, issuer identifier, or position is not a revocation credential.

## Historical Selector Resolution

When a selector refers to historical evidence that is not present in every descendant continuity state, a profile that wants causal
retroactive effect MUST resolve that selector to an authenticated affected position:

~~~text
KEY / DELEGATE / ATTESTATION / ISSUER / other selector
        |
        v
authenticated affected position
        |
        v
(PCA ID, fromPosition)
~~~

The resolver MUST authenticate the selector occurrence, the PCA ID, the position, the integrity of the evidence used for resolution, and the
authority to materialize the resulting cutoff.

When fan-out is possible, resolving only to `(PCA ID, fromPosition)` intentionally creates a lineage-depth cutoff across sibling branches. A
resolver that intends branch-selective effect MUST also authenticate the selected occurrence and descendant relation. It MUST NOT infer
ancestry from numeric position alone.

A bare assertion that a selector occurred at a position MUST NOT be sufficient. A valid position witness MAY be an authenticated settled
continuity artifact, an authenticated transition extract, an authenticated historical-index record, a checkpoint, a Merkle inclusion proof, a
succinct proof, or another profile-defined authenticated witness.

For a compromised-key revocation, a position witness authenticated only by the compromised key MUST NOT be sufficient evidence that the
position was accepted into the continuity. The revocation authority MUST require corroboration independent of the revoked key, such as an
authenticated index, a trusted validator record, a checkpoint, or another profile-defined proof.

## Dynamic Restrictions

A profile MAY define dynamic authority or execution-contract restrictions. Such restrictions are evaluated as external authenticated state
against the presented PCA ID, position, and optional selectors.

Dynamic restrictions MUST be monotonic: they may only make effective authority or execution conformance equally or more restrictive. They
MUST NOT rewrite signed PCA checkpoint artifacts, mutate historical transitions, alter predecessor uniqueness, replace Proof of Relationship,
or expand authority.

This monotonic external state is compatible with treating revocation as an additional ordered security-state coordinate: ordinary state
updates may only restrict acceptance. Any relaxation is a separate re-origination or explicitly authorized relaxation event, not an ordinary
continuation [[5]](#references).

The profile MUST define restriction scope, composition, conflict resolution, freshness, rollback protection, and unavailable-state behavior.

# Revocation Authorization

This section is normative.

Every accepted revocation or dynamic restriction MUST be authenticated by an authorized revocation authority. A matching target coordinate is
necessary for targeting but never sufficient for authorization.

A profile MUST define how each revocation authority is proven. Possible authorities include:

| Revoker | Scope | Required proof |
| --- | --- | --- |
| Root authority or PCA issuer | the PCA ID it is authorized to administer | profile-defined issuer authorization and revocation proof |
| Grant authority | continuities bound to that grant | authenticated grant binding and grant-authority proof |
| Origin issuer | continuities whose profile authenticates that issuer binding | issuer revocation authority proof |
| Executor at position `k` | its own future, as permitted by policy | authenticated position proof and policy authority |
| Evidence authority | uses of a key, delegate, attestation, or issuer selector | selector proof plus authority to materialize a causal cutoff |
| Policy authority | dynamic policy or restriction state | authenticated policy authority proof |

An executor at position `k` MUST NOT revoke a position upstream of itself unless it separately holds root, grant, issuer, or other
profile-defined revocation authority. A policy MAY allow an executor to revoke its own future from `k+1`, or from `k` when the current
position itself must be invalidated.

Grant revocation MUST be accepted only when the Verifier can establish that the revocation issuer is authorized for the grant. Possession or
knowledge of a grant identifier alone MUST NOT authorize revocation.

# Revocation State

This section is normative.

Revocation state is external, authenticated, and append-only. A profile MUST specify:

- how revocation state is authenticated;
- how freshness is determined;
- how rollback is detected;
- who defines the minimum acceptable revocation-state version;
- how that minimum is authenticated;
- what happens when required revocation state is unavailable.

Unavailable-state behavior MUST be explicit. Examples include fail closed, accept only a fresh stapled proof, accept within a bounded offline
window, or another profile-defined behavior.

Security revocations and restrictions applied to a PCA ID, position, grant, selector, or policy scope MUST be append-only and MUST become
only equally or more restrictive over time:

~~~text
effectiveRevocationState(t + 1) is at least as restrictive as effectiveRevocationState(t)
~~~

A relaxation MUST require a new grant, a new trusted root authority context, a new PCA ID, or another profile-defined re-origination
mechanism. It MUST NOT be implemented by deleting an existing revocation, replaying an older revocation view, replacing active state with
less restrictive state, or silently un-revoking an existing cutoff.

# Future Branch-Capable Profiles

This section is non-normative.

PIC can support branch-capable revocation in a future or separate profile, but branch-domain machinery is not part of the current
centralized Profile 0.2 base coordinate. PIC-X currently permits sibling fan-out from one checkpoint; its `lineage_id` plus `position`
therefore supports whole-lineage and lineage-depth targeting, not unique branch or occurrence targeting. This document does not define
branch-domain fields, branch-suffix strategies, branch-creation evidence, parent branch ancestry, or branch-domain escape rules for Profile
0.2.

A future branch-capable profile would need to define bounded authenticated branch coordinates, branch-creation authorization, anti-escape
validation order, branch-selective cutoff authorization, historical resolution rules, and privacy properties. Those details are intentionally
out of scope for this revision.

# Position Capacity

This appendix is non-normative. If a profile represents continuity position with a finite integer domain, exhausting that domain requires
completing that many causal advancements on one path:

~~~text
secondsToOverflow = (2^64 - 1 - currentPosition) / R
    where R = maximum accepted advancements per second on one continuity path
~~~

Each path is causally sequential; fan-out permits several paths but does not parallelize one path. A concrete `R` depends on hardware,
network, and application logic and is not fixed here. Under any realistic per-path rate a `uint64` position is practically inexhaustible,
though a profile that wants the mathematically unbounded case may use an unbounded integer encoding. The normative point is only that
overflow and wraparound are rejected when the selected representation can overflow.

# Security Considerations

Revocation security depends on authenticated, fresh, rollback-protected revocation state and explicit behavior when that state is unavailable.
Stale or rolled-back state can cause a Verifier or settlement service to accept continuity that should have been cut off. A selector value, PCA
ID, position, key identifier, grant identifier, or policy label is only a target coordinate; knowledge or possession of it is not revocation
authority.

In a fan-out profile, `(PCA ID, position)` is not a unique causal-event coordinate. Treating it as one can either over-revoke independent
siblings or falsely claim branch-selective semantics. A branch-selective profile needs authenticated occurrence identity and ancestry.

Selector-to-position resolution needs authenticated evidence that the selector occurred at the affected continuity position. For compromised
key revocation, evidence authenticated only by the compromised key is not sufficient where this document requires independent corroboration.
Dynamic restrictions need to remain monotonic: they can make effective authority or execution-contract conformance more restrictive, but cannot
rewrite signed checkpoints, mutate history, replace Proof of Relationship, or expand authority.

# Contributors {#contributors}

The editors and contributors of this document are listed in the **document header** above. Listing is governed by Appendix B.7 of the
[PIC Legal Appendices](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-legal.md).

# Acknowledgement

The **Provenance Identity Continuity (PIC) Model** — the theoretical framework this specification expresses in normative form — was created
by **Nicola Gallo**. It first appeared on Zenodo on 1 December 2025 and is developed in full in the Proof-of-Continuity paper:

- Gallo, N. (2025). *PIC Model — Provenance Identity Continuity for Distributed Execution Systems*. Zenodo.
  [zenodo.org/records/17777421](https://zenodo.org/records/17777421) (DOI: 10.5281/zenodo.17777421).
- Gallo, N. (2026). *Proof-of-Continuity: A Temporal Model for Authority Propagation in Distributed Systems and AI Agents*. Zenodo.
  [zenodo.org/records/21285112](https://zenodo.org/records/21285112) (DOI: 10.5281/zenodo.21285112).

Authorship of the PIC Model remains with Nicola Gallo; the PIC specifications are published and maintained by **Nitro Agility S.r.l.** as
Specification Steward. Any work that references, implements, or claims conformance with PIC must preserve this attribution, distinguishing the
**PIC Model** (author: Nicola Gallo) from the **PIC Specifications** (steward: Nitro Agility S.r.l.), as required by the
**[PIC Legal Appendices](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-legal.md)** (Appendix B, Attribution; Appendix D,
Acknowledgements), which are incorporated into this specification by reference.

# Legal Notices

The appendices governing:

- **A.** Use of Automated Language Assistance,
- **B.** Authorship, Stewardship, Attribution, and Derivative Works,
- **C.** Disclaimer and Limitation of Liability,
- **D.** Acknowledgements,

are maintained in a single canonical document, the
**[PIC Legal Appendices](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-legal.md)** (`draft/0.2/pic-legal.md`), and are
**incorporated into this specification by reference** as if fully set forth herein.

In case of conflict between this document and the PIC Legal Appendices, the PIC Legal Appendices prevail for legal, governance, licensing,
and attribution matters.

This specification is subordinate to the
[PIC Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-spec.md), which defines the normative semantics of the
PIC Model and is the entry point of the specification set. This document does not introduce new conceptual authority, invariants, or
authorship claims beyond those defined in the PIC Legal Appendices.

# References {#references}

- [1] Gallo, N. (2026). *Proof-of-Continuity: A Temporal Model for Authority Propagation in Distributed Systems and AI Agents*. arXiv:2607.08906 [cs.CR]. [arxiv.org/abs/2607.08906](https://arxiv.org/abs/2607.08906)
- [2] Bradner, S. (1997). *Key words for use in RFCs to Indicate Requirement Levels*. BCP 14, RFC 2119. [rfc-editor.org/rfc/rfc2119](https://www.rfc-editor.org/rfc/rfc2119)
- [3] Leiba, B. (2017). *Ambiguity of Uppercase vs Lowercase in RFC 2119 Key Words*. BCP 14, RFC 8174. [rfc-editor.org/rfc/rfc8174](https://www.rfc-editor.org/rfc/rfc8174)
- [4] Gallo, N. (2026). *Beyond Proof of Possession: A Relational Theory of Authority*.
- [5] Gallo, N. (2026). *Full Provenance on the COSS Causal Axis: An Event-Level Closure of Causal Attribution and Confused-Deputy Exclusion*.
