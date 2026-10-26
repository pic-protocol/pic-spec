---
title: "COSS Temporal Evidence"
abbrev: "COSS Temporal Evidence"
docname: coss-temporal-evidence-02
category: info
ipr: none
submissiontype: independent
stand_alone: yes
smart_quotes: false
pi: [toc, sortrefs, symrefs]
date: 2026-10-26

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
**Document:** coss-temporal-evidence-02
**Version:** 0.2 (Draft)
**Document Status:** Public Draft
**Intended Use:** Informational and Experimental
**First Published:** 2026-10-26
**Last Updated:** 2026-10-26
**Editor(s):** Nicola Gallo (Nitro Agility S.r.l.)
**Steward:** Nitro Agility S.r.l.
**Source:** [github.com/pic-protocol/pic-spec/draft/0.2/coss-evidences.md](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/coss-evidences.md)

--- note_About_This_Document

> **Public Draft — Not a Standard**
>
> This document is an independently developed specification published as part of the PIC Protocol and maintained by Nitro Agility
> S.r.l. in its role as Specification Steward.
>
> It has not been adopted, endorsed, approved, or published by a standards-development organization. It is published for public review,
> research, experimentation, implementation feedback, and possible future standardization work. It may be revised, replaced, or withdrawn
> at any time.
>
> Implementers use this draft at their own risk. Any implementation, interoperability statement, or conformance claim applies only
> to the exact document version identified above.
>
> Publication does not constitute certification, endorsement, security approval, interoperability assurance, or regulatory approval.
>
> Current project information and published specifications are available at `https://www.pic-protocol.org/`.

--- note_Feedback_and_Issue_Tracking

The source for this document and the issue tracker for technical discussion are maintained at
[github.com/pic-protocol/pic-spec](https://github.com/pic-protocol/pic-spec). Changes are accepted through the repository contribution
process. Published releases, tags, and immutable research references identify the version to which a review or conformance statement applies.

--- note_Copyright_and_License

This document is made available under the Creative Commons Attribution 4.0 International license. See the repository
[LICENSE](https://github.com/pic-protocol/pic-spec/blob/main/LICENSE) and [NOTICE](https://github.com/pic-protocol/pic-spec/blob/main/NOTICE.md).
This notice does not add restrictions to that license.

--- note_Editors

- **Nicola Gallo** (Nitro Agility S.r.l.) Lead Editor
- *Add your name via pull request (individual or organization) — listing is subject to editor approval (see [Contributors](#contributors)).*

--- note_Contributors

- *Add your name via pull request (individual or organization) — listing is subject to editor approval (see [Contributors](#contributors)).*

--- abstract

This document is a subordinate specification of the [PIC Specification 0.2](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-spec.md).
It defines **COSS Temporal Evidence**: a protocol-neutral way to bind evidence from several security coordinates to one causal execution
occurrence. A record may reference PIC authority-continuity evidence, information-flow evidence, runtime provenance, geographic evidence, or
other profile-defined evidence without absorbing the semantics of those systems.

The central rule is simple: **one occurrence, one causal history, several independently verified coordinates**. An authenticated digest
reference proves that a record committed to exact artifact bytes; it does not prove that the referenced claim is true. Each required artifact
remains subject to its own verifier, while the COSS record prevents valid evidence from unrelated executions from being mixed and presented
as evidence of one effect.

--- middle

# Introduction

An effect can be authorized in one dimension and forbidden in another. A mail service may receive both a valid permission to send and bytes
derived from confidential data. The permission answers what authority may continue. It does not answer where the bytes may flow.

COSS places those distinct security coordinates on the same causal execution [[4]](#references). This document specifies the evidence
boundary needed to carry that relationship between systems. It does not define the internal semantics or wire format of PIC, information-flow
control (IFC), runtime attestation, or any other coordinate.

## Requirements Notation

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and
"OPTIONAL" are to be interpreted as described in BCP 14 [[2]](#references) [[3]](#references) when, and only when, they appear in all capitals.

## Scope

This specification defines:

- the logical contents of a COSS Temporal Evidence Record;
- the binding of coordinate evidence to one execution occurrence and its causal predecessor set;
- the distinction between Proof of Possession (PoP), Proof of Relationship (PoR), and Proof of Continuity (PoC);
- ordered verification of ordinary continuations, joins, and explicit authorized relaxations; and
- the limits of digest references and external evidence.

This specification does **not** define a serialization, signature suite, transport, evidence-retention system, PIC representation, IFC model,
or product-specific mapping. Profiles define those choices. A mapping to an execution-evidence system is a profile of this specification, not
a redefinition of PIC or COSS semantics.

# One Effect, Several Questions

Alice authorizes reading her documents for a verification. Bob independently authorizes sending official email. Carol is an AI agent; in the
accepted variant below, Carol acts as a Data Loss Prevention (DLP) service. Trent stores Alice's documents. Dave is a mail service whose rule
forbids confidential data over email.

~~~
Alice -- read her documents, for verification --\
                                                 \
Bob   -- send official email --------------------> Carol -- send(bytes) --> Dave
                                                 /
Trent -- Alice's documents; classification HIGH /

Dave's rule: no confidential data by email
~~~

The two permissions can be individually valid while the proposed effect remains inadmissible. Dave receives a permission and bytes:

~~~
send request
  permission: send email
  bytes:      52 65 6c 61 7a 69 6f 6e 65 ...

authority question: may this occurrence send email?
flow question:      may these bytes flow to this destination?
causal question:    which earlier occurrences produced this request and these bytes?
~~~

Neither the bytes nor the send permission answers all three questions. A log entry with an actor and timestamp does not establish the causal
relationship. Evidence is sufficient for this effect only when the relevant answers are bound to the **same occurrence**.

## One Causal Axis

Let `e` be an execution occurrence and `Pred(e)` its represented immediate causal predecessors. Its represented history is the causal
down-set `Hist(e)`, not a wall-clock interval and not a second timeline per security mechanism [[4]](#references) [[7]](#references).

~~~
Alice intent ----> Trent release -----\
                                      > Carol send request ----> Dave effect
Bob intent --------------------------/
~~~

Common ancestry, equal timestamps, the same executor, or co-residence in one process MUST NOT be treated as proof that two branches are the
same continuation. A claimed predecessor edge requires profile-defined, causally sound evidence.

# COSS Security State

For a finite set of coordinate profiles `J`, the security state at occurrence `e` is:

~~~
Sigma(e) = (sigma_j(e)) for every j in J
~~~

Each profile `j` defines:

- its state space;
- its order `<=_j`, meaning "no more permissive than";
- the behaviors admitted by a state; and
- the evidence and verification procedure that establish its claims.

For an ordinary causal edge `p -> e`, COSS continuity requires:

~~~
PoR(p, e)  AND  sigma_j(e) <=_j sigma_j(p)  for every required j
~~~

PIC is the authority coordinate of this construction. For set-valued PIC authority `C`, the order is set inclusion:

~~~
PoR(p, e)  AND  C(e) subset-of C(p)
~~~

An IFC profile may provide a different state and order. COSS does not require distinct coordinates to use the same vocabulary, verifier, or
artifact format. It requires their results to constrain the same occurrence.

At an ordinary multi-parent join, the child MUST be no more permissive than every parent in every required coordinate. For PIC authority:

~~~
C(e) subset-of intersection of C(p), for every p in Pred(e)
~~~

A grant, authority composition, declassification, endorsement, or other non-conservative change MUST be represented as an explicit
authorized relaxation. It MUST NOT be presented as an ordinary continuation.

# PoP, PoR, and PoC in COSS Evidence

PoP, PoR, and PoC answer different questions:

| Primitive | Question | Evidence consequence |
| --- | --- | --- |
| **PoP** | Does the presenter control a key or artifact? | Authenticates possession. It does not identify the causal occurrence. |
| **PoR** | Does this occurrence validly continue this specific predecessor? | Establishes a profile-defined causal edge and binds the successor to the predecessor record. |
| **PoC** | Does the whole represented execution preserve valid continuation? | Composes accepted PoR edges and coordinate refinement across the causal history. |

PoP MAY protect a COSS record or a referenced artifact, but PoP alone MUST NOT be accepted as PoR or PoC. A digest chain establishes artifact
linkage only. It establishes COSS continuity only when the applicable profiles also validate the causal relationships and coordinate rules.

PIC PoC is the authority specialization. COSS product continuity applies the same causal composition to every required ordered coordinate.
There is one predecessor graph; there is not an unrelated "PIC chain" and "IFC chain" later correlated by time or actor name.

# COSS Temporal Evidence Record

A COSS Temporal Evidence Record `TE(e)` is an authenticated commitment with the following logical fields:

| Field | Meaning |
| --- | --- |
| `version` | The exact COSS evidence specification or profile version. |
| `occurrence` | A commitment to the concrete execution occurrence. |
| `policy` | An identifier or commitment for the trusted policy that selects required coordinates and verification rules. |
| `transition` | `root`, `ordinary`, or `authorized-relaxation`. |
| `predecessors` | Digest references to the exact authenticated predecessor records. |
| `behavior` | A commitment to the request, message, or protected effect being judged. |
| `evidence` | Typed references to occurrence, causal, or coordinate evidence. |
| `relaxation` | For an authorized relaxation, references to its separate authorization and affected coordinates. |

Every digest reference MUST identify the digest algorithm and the digest of the exact referenced bytes. The profile MUST define which bytes
are hashed. A locator MAY accompany a digest but MUST NOT be trusted for identity or integrity.

An evidence entry declares one or more roles:

- **occurrence evidence** describes what ran or which concrete request, message, or effect occurred;
- **causal evidence** supports one or more claimed predecessor relationships; and
- **coordinate evidence** supports a state, refinement, or admission result under a named coordinate profile.

One artifact MAY fulfill several roles. A runtime or provenance record is not automatically a security-state coordinate: it becomes
coordinate evidence only under a profile that defines its state, order, admitted behavior, and verifier.

A coordinate-evidence entry MUST identify its coordinate and exact profile version. It MUST also carry or commit to the coordinate state
established for the occurrence and reference the evidence from which that result is verified. The state MAY remain selectively disclosed if
the profile supplies a proof sufficient for refinement and admission.

A `root` record has no predecessors. An `ordinary` or `authorized-relaxation` record has one or more distinct predecessors. The resolved
predecessor relation MUST be acyclic. A profile MUST NOT infer a missing predecessor from physical time or list order.

## Same-Occurrence Binding

Every required evidence entry MUST be bound to the record's occurrence. A profile MAY establish this in either of two ways:

1. the evidence artifact directly commits to the same occurrence; or
2. a trusted handoff boundary authenticates one record that commits together to the occurrence, its predecessor records, and the exact
   evidence-artifact digests.

Association performed later from timestamps, actor identifiers, workflow labels, or separately valid artifacts is insufficient. The binding
MUST prevent an implementation from pairing valid PIC evidence from one execution with valid IFC or runtime evidence from another.

## References Are Not Validation

An authenticated digest reference proves that the signer committed to exact artifact bytes. It does **not** prove that:

- the referenced statement is true;
- its issuer is trusted for the claimed role;
- the artifact establishes PoR;
- its coordinate state is correctly ordered; or
- the behavior is admitted.

Each referenced artifact MUST therefore be resolved, integrity-checked, and independently validated by the verifier required by its declared
profile. An unavailable required artifact causes verification to fail unless the selected profile defines an equivalent self-contained proof.

## Illustrative Record

The following JSON is illustrative and is not a wire format or a registry of identifier strings:

~~~ json
{
  "version": "coss-temporal-evidence-0.2",
  "occurrence": {
    "profile": "mail-send-occurrence-v1",
    "digest": "sha-256:OCCURRENCE_DIGEST"
  },
  "policy": {
    "profile": "mail-boundary-policy-v1",
    "digest": "sha-256:POLICY_DIGEST"
  },
  "transition": "ordinary",
  "predecessors": [
    { "digest": "sha-256:PREDECESSOR_RECORD_DIGEST" }
  ],
  "behavior": {
    "profile": "mail-effect-v1",
    "digest": "sha-256:REQUEST_AND_BYTES_DIGEST"
  },
  "evidence": [
    {
      "roles": ["causal", "coordinate"],
      "coordinate": "pic-authority",
      "profile": "pic-continuity-profile",
      "state": { "digest": "sha-256:PIC_STATE_DIGEST" },
      "artifact": { "digest": "sha-256:PIC_EVIDENCE_DIGEST" }
    },
    {
      "roles": ["coordinate"],
      "coordinate": "information-flow",
      "profile": "ifc-provenance-profile",
      "state": { "digest": "sha-256:IFC_STATE_DIGEST" },
      "artifact": { "digest": "sha-256:IFC_EVIDENCE_DIGEST" }
    },
    {
      "roles": ["occurrence"],
      "profile": "runtime-evidence-profile",
      "artifact": { "digest": "sha-256:RUNTIME_EVIDENCE_DIGEST" }
    }
  ]
}
~~~

The record binds three external artifacts to one mail-send occurrence. It does not ask the runtime-evidence system to compute PIC attenuation,
and it does not ask PIC to decide IFC. Dave validates each required profile and then applies the joint admission rule.

## Minimal Integration Contract

An execution-evidence system can support COSS Temporal Evidence without implementing PIC or IFC internally. Its profile needs to provide:

1. an authenticated record for the concrete occurrence and behavior;
2. digest references that form the represented predecessor graph;
3. typed digest references to external coordinate evidence;
4. same-occurrence binding for those references; and
5. a way for the receiving verifier to invoke, or validate the result of, each required coordinate verifier.

The authority intersection remains a PIC operation. IFC admission remains an IFC operation. The execution-evidence system records and binds
the facts on which those independent decisions rely.

# Verification

A conformant verifier MUST perform the following checks in order:

1. **Record validation.** Parse the record under the selected profile; reject unsupported versions, malformed fields, duplicate coordinate
   identifiers not explicitly allowed by profile, and unsafe resource consumption.
2. **Record authenticity.** Validate the record's integrity, authenticating mechanism, trust anchor, algorithm policy, and profile-defined
   freshness or replay rules.
3. **Policy selection.** Resolve the policy under local trusted configuration and determine the required coordinates, evidence profiles, and
   verification rules. The producer MUST NOT be able to select a weaker policy for the effect.
4. **Occurrence and behavior binding.** Recompute or otherwise validate the commitments to the concrete request, message, or effect being
   judged.
5. **Reference integrity.** Resolve every required artifact and verify its digest over the profile-defined exact bytes.
6. **Evidence validity.** Apply the verifier and trust policy declared by every required evidence profile. A reference signature is not a
   substitute for this step.
7. **Causal validity.** Validate that predecessor references are distinct, the resolved graph is acyclic, the declared predecessor set is
   complete under the selected profile, and the required PoR evidence is valid. Root, ordinary linear, ordinary join, and
   authorized-relaxation records MUST NOT be confused.
8. **Coordinate continuity.** For an ordinary record, verify that every required coordinate is no more permissive than every applicable
   predecessor under that coordinate's declared order.
9. **Relaxation authorization.** For an authorized relaxation, verify its separate authorization, the coordinates it may change, and the new
   bound. Unaffected coordinates remain subject to ordinary continuity.
10. **Joint admission.** Before a protected effect, verify that every coordinate required by policy admits the committed behavior. Any required
   rejection rejects the effect.

An implementation MUST fail closed when a required coordinate, artifact, verifier, causal edge, or binding cannot be established. It MUST NOT
silently reduce a multi-coordinate decision to the coordinates it happens to understand.

# Worked Decision at Dave

## Rejected Ordinary Path

For Carol's proposed mail effect, assume the evidence establishes:

~~~
PIC authority:       send-email is present
IFC provenance:      the bytes depend on Alice's HIGH documents
destination policy:  external email is LOW
causal binding:      all results refer to this exact send occurrence
~~~

The authority coordinate admits `send-email`. The IFC coordinate rejects the `HIGH -> LOW` flow. Dave therefore rejects the effect. PIC does
not claim that Carol is physically unable to copy or transmit bytes through an unmediated path; it establishes that such an effect is not a
valid admitted continuation. The claimed protection requires the mail effect to pass through Dave or another complete mediation boundary.

## Accepted DLP Path

Suppose Carol does not initially hold `send-email`. Bob invokes Carol by combining the `read-for-verification` authority received from Alice
with Bob's own `send-email` authority. That union is not an ordinary join. It MUST be represented as an explicit authorized composition whose
COSS record has transition class `authorized-relaxation`.

Carol then evaluates the exact candidate output under the selected DLP or IFC profile. Two cases are distinct:

1. If the verified output state already admits flow to the destination, no IFC relaxation is needed.
2. If the output is derived from `HIGH` input and is released or sanitized for a `LOW` destination, the change MUST be an explicit authorized
   declassification. Its evidence MUST bind the input, exact output bytes, applicable policy, and declassification authorization.

The evidence graph makes both possible security boundaries visible:

~~~
Alice read ----\
                > [authorized composition: read + send] ---> Carol · DLP
Bob send  -----/                                             |
                                                             | verifies exact output
Trent data ------------------------------------------------->|
                                                             v
                                             [declassification, if required]
                                                             |
                                                             v
                                                     Dave mail effect
~~~

The record presented to Dave binds at least:

~~~
behavior:                 digest of destination, message, and exact output bytes
predecessor:              digest of the authenticated predecessor record
PIC coordinate evidence: digest of the authorized composition and authority state
IFC coordinate evidence: digest of the DLP/IFC result for the exact output
relaxation evidence:      digest of declassification authorization, when required
occurrence evidence:      digest of the execution evidence for this handoff
~~~

Dave accepts only if the composition is authorized, the PIC state admits `send-email`, the DLP or IFC result admits the exact output and
destination, any required declassification is authorized, and every item is bound to the same occurrence. Without the required composition
or declassification evidence, valid evidence in another coordinate does not repair the missing rule.

# Conformance

A **COSS Temporal Evidence Producer** conforms to this specification when it creates authenticated records that bind the occurrence,
policy, predecessors, behavior, evidence references, and transition class as required above.

A **COSS Temporal Evidence Verifier** conforms when it implements the ordered verification procedure, validates every required external
profile independently, and fails closed on missing or unsupported required evidence.

A **COSS Evidence Profile** conforms when it defines the concrete serialization, authenticating mechanism, exact-byte digest rules,
occurrence and behavior commitments, coordinate identifiers, coordinate orders, evidence verifiers, freshness rules, and required-coordinate
policy needed to realize this specification.

Conformance to this document does not imply conformance to PIC, an IFC system, or any referenced evidence system. Those claims require
independent conformance to the corresponding specifications.

# Origins, Authorship, and Historical Record

This section is informative.

The **Provenance Identity Continuity (PIC) Model** was originally developed by **Nicola Gallo** as a formal framework for reasoning about causal
authority propagation across distributed execution. Its development introduced Proof of Relationship (PoR), Proof of Continuity (PoC),
authority non-expansion, relational attenuation, and event-level causal provenance as connected parts of the framework. COSS generalizes the
carried security state from authority to a finite product of ordered security coordinates on the same causal occurrence. The PIC
Specifications translate those formal results into technical requirements and are published and maintained by **Nitro Agility S.r.l.** as
Specification Steward.

## Historical References

The publicly verifiable research record is:

- **1 December 2025 — initial public PIC Model working paper.** *PIC Model — Provenance Identity Continuity for Distributed Execution
  Systems*, Zenodo record 17777421 [[9]](#references). That archived draft is retained for historical reference and is not an implementation
  specification.
- **5 December 2025 — authority-propagation analysis.** *Authority Propagation Models: PoP vs PoC and the Confused Deputy Problem*,
  Zenodo record 17833000 [[8]](#references).
- **9 July 2026 — formal Proof-of-Continuity paper.** *Proof-of-Continuity: A Temporal Model for Authority Propagation in Distributed
  Systems and AI Agents*, arXiv:2607.08906 [[5]](#references).
- **25 September 2026 — relational authority theory.** *Beyond Proof of Possession: A Relational Theory of Authority*, Zenodo record
  23102206 [[6]](#references).
- **2 October 2026 — event-level causal closure and COSS product model.** *Full Provenance on the COSS Causal Axis: An Event-Level Closure of
  Causal Attribution and Confused-Deputy Exclusion*, Zenodo record 23102373 [[4]](#references).
- **10–13 November 2026 — IEEE NCA 2026 conference paper (forthcoming).** Gallo, N., Silvestri, S., and Radesca, A. *Authority Continuity for
  Verifiable Lineage in Distributed Systems and AI Agents*. Accepted for the 24th IEEE International Symposium on Network Computing and
  Applications (NCA 2026) [[10]](#references). The IEEE Xplore DOI will be added as soon as it becomes available.

The PIC Specification 0.2 family was first published on **15 July 2026**. This COSS Temporal Evidence subordinate specification was first
published on **26 October 2026**. Published tags and immutable records identify the exact text applicable to a review or conformance claim.
Researchers and implementers are encouraged to cite the primary publication that supports the formal property they discuss. Copyright
attribution for reuse of PIC specification materials is governed separately by the applicable CC BY 4.0 license.

# Security Considerations

The primary threat addressed by this document is **evidence mix-and-match**: combining valid evidence from different occurrences so that it
appears to justify one effect. Same-occurrence binding and exact predecessor references are REQUIRED to prevent that substitution.

A digest authenticates bytes only through a separately trusted signature or channel and says nothing by itself about semantic truth. Weak,
deprecated, ambiguous, or incorrectly canonicalized digest inputs can defeat the binding. Profiles MUST define exact-byte hashing and
algorithm-agility policy.

Omitting a coordinate can change a security verdict. Required coordinates MUST therefore be selected by trusted policy, not by the producer.
Unknown required coordinates and unavailable required evidence MUST fail closed.

Causal evidence can be incomplete or false. Claims that depend on complete causal ancestry additionally require sound causal evidence,
representation of every in-scope cause, and mediation of every protected effect. This specification cannot protect causes or effects omitted
from the modeled and mediated execution.

Replay, fan-out, freshness, revocation, trust-anchor compromise, and equivocation remain profile and deployment concerns. A valid historical
record is not automatically valid for a new occurrence.

# Privacy Considerations

Cross-coordinate evidence can expose principals, software identities, data classifications, locations, causal relationships, and stable
execution identifiers. Profiles SHOULD use commitments, selective disclosure, scoped identifiers, and minimum necessary retention while
preserving the evidence needed for the claimed security property. Digest references can still enable correlation when the same artifact is
reused across domains.

# Registry Considerations

This version defines no shared protocol registry and requests no external registry action. A future interoperability profile may define
registries for coordinate identifiers, evidence roles, media types, digest algorithms, transition classes, or error values.

# References {#references}

## Normative References

- [1] Gallo, N. (2026). *Provenance Identity Continuity (PIC) Model Specification*, version 0.2. [github.com/pic-protocol/pic-spec](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-spec.md)
- [2] Bradner, S. (1997). *Key words for use in RFCs to Indicate Requirement Levels*. BCP 14, RFC 2119. [rfc-editor.org/rfc/rfc2119](https://www.rfc-editor.org/rfc/rfc2119)
- [3] Leiba, B. (2017). *Ambiguity of Uppercase vs Lowercase in RFC 2119 Key Words*. BCP 14, RFC 8174. [rfc-editor.org/rfc/rfc8174](https://www.rfc-editor.org/rfc/rfc8174)

## Informative References

- [4] Gallo, N. (2 October 2026). *Full Provenance on the COSS Causal Axis: An Event-Level Closure of Causal Attribution and Confused-Deputy Exclusion*. Zenodo. DOI: [10.5281/zenodo.23102373](https://doi.org/10.5281/zenodo.23102373)
- [5] Gallo, N. (9 July 2026). *Proof-of-Continuity: A Temporal Model for Authority Propagation in Distributed Systems and AI Agents*. arXiv:2607.08906 [cs.CR]. [arxiv.org/abs/2607.08906](https://arxiv.org/abs/2607.08906)
- [6] Gallo, N. (25 September 2026). *Beyond Proof of Possession: A Relational Theory of Authority*. Zenodo. DOI: [10.5281/zenodo.23102206](https://doi.org/10.5281/zenodo.23102206)
- [7] Lamport, L. (1978). *Time, Clocks, and the Ordering of Events in a Distributed System*. Communications of the ACM, 21(7), 558–565. DOI: [10.1145/359545.359563](https://doi.org/10.1145/359545.359563)
- [8] Gallo, N. (5 December 2025). *Authority Propagation Models: PoP vs PoC and the Confused Deputy Problem*. Zenodo. DOI: [10.5281/zenodo.17833000](https://doi.org/10.5281/zenodo.17833000)
- [9] Gallo, N. (1 December 2025). *PIC Model — Provenance Identity Continuity for Distributed Execution Systems*. Archived working paper. Zenodo. DOI: [10.5281/zenodo.17777421](https://doi.org/10.5281/zenodo.17777421)
- [10] Gallo, N., Silvestri, S., & Radesca, A. (forthcoming 2026). *Authority Continuity for Verifiable Lineage in Distributed Systems and AI Agents*. Accepted paper, 24th IEEE International Symposium on Network Computing and Applications (NCA 2026), 10–13 November 2026, Ortigia–Syracuse, Italy. [nca-ieee.org/2026](https://www.nca-ieee.org/2026/). IEEE Xplore DOI forthcoming; this reference will be updated when it becomes available.

# Document History

This section is informative.

- **0.2 — 26 October 2026.** Initial public draft defining protocol-neutral, same-occurrence binding of PIC authority evidence, IFC evidence,
  runtime provenance, and other COSS security coordinates on one causal evidence graph.

# Acknowledgments

Acknowledgments recognize review, discussion, or editorial assistance and do not define authorship, conformance, endorsement, or technical
responsibility. Names are added only when a concrete contribution has been identified and the person agrees to be listed.

# Contributors {#contributors}

The editor and current contributors are identified in the document header and repository history. Contribution credit is distinct from the
historical origin of the PIC Model and from stewardship of the PIC Specifications.
