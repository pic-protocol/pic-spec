# PIC Revocation Specification

**Version:** 0.1 (Draft)  
**Status**: Draft – Not a Standard  
**Date:** 2026-07-15  
**Source:** [github.com/pic-protocol/pic-spec/draft/0.2/pic-revocation-spec.md](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-revocation-spec.md)  
**Editors:**

- **Nicola Gallo** (Nitro Agility S.r.l.) Lead Editor
- *Add your name via pull request (individual or organization) — listing is subject to editor approval (see [Section 7](#7-contributors)).*

**Contributors:**

- *Add your name via pull request (individual or organization) — listing is subject to editor approval (see [Section 7](#7-contributors)).*

## Abstract

This document is the **PIC Revocation Specification**, a subordinate specification of the [PIC Specification](./pic-spec.md). It prepares
the ground for **revoking authority** within the Provenance Identity Continuity (PIC) Model.

This revision normatively defines the **revocation coordinates**, their **origin binding**, and their **hop-by-hop continuity**
requirements. It also illustrates candidate revocation strategies and records the semantic constraints that a later normative
revocation-object specification must preserve.

Expiry bounds *how long* a PCA is valid; revocation withdraws validity *before* that bound. The profile covers grant-, key-, delegate-,
attestation-, issuer-, and policy-based revocation, and adds a property specific to PIC: **causal execution cutoffs** — revoking a lineage,
or its future from a given position. The ordinary verification path in the incremental profile stays **O(1)**.

The coordinates extend the PCA format of the [PIC Prover and Verifier Specification](./pic-prover-verifier-spec.md); they do not alter the
PIC Model invariants — non-expansion and Proof of Relationship are unchanged, and every PCA still continues exactly one predecessor. In case
of conflict, the **PIC Specification** is authoritative.

## Table of Contents

- [PIC Revocation Specification](#pic-revocation-specification)
  - [Abstract](#abstract)
  - [Table of Contents](#table-of-contents)
  - [1. Introduction](#1-introduction)
    - [1.1 What Is a Lineage](#11-what-is-a-lineage)
    - [1.2 Three Kinds of Revocation State](#12-three-kinds-of-revocation-state)
    - [1.3 Requirements Notation](#13-requirements-notation)
  - [2. Revocation Coordinates](#2-revocation-coordinates)
    - [2.1 Origin PCA (PCA0)](#21-origin-pca-pca0)
    - [2.2 Successor PCA](#22-successor-pca)
    - [2.3 Verifier Hop Validation](#23-verifier-hop-validation)
  - [3. Revocation Strategies](#3-revocation-strategies)
    - [3.1 Native Causal Revocations](#31-native-causal-revocations)
    - [3.2 Identity and Evidence Selectors](#32-identity-and-evidence-selectors)
    - [3.3 Dynamic Restrictions](#33-dynamic-restrictions)
    - [3.4 Retrospective Annotation](#34-retrospective-annotation)
    - [3.5 Summary](#35-summary)
  - [4. Making Selectors Causal](#4-making-selectors-causal)
    - [4.1 Known Positions and Materialization](#41-known-positions-and-materialization)
    - [4.2 Historical Position Index](#42-historical-position-index)
    - [4.3 Not Carrying Full History](#43-not-carrying-full-history)
  - [5. Revocation Model and Limitations](#5-revocation-model-and-limitations)
    - [5.1 Who May Revoke](#51-who-may-revoke)
    - [5.2 Revocation State](#52-revocation-state)
    - [5.3 Limitations](#53-limitations)
  - [6. Counter Capacity](#6-counter-capacity)
  - [7. Contributors](#7-contributors)
  - [8. Legal Notices](#8-legal-notices)
  - [References](#references)

## 1. Introduction

This section is non-normative. It explains the concepts revocation needs; the normative requirements are in Section 2.

### 1.1 What Is a Lineage

An **execution lineage** is simply the sequence of PCAs produced as one execution proceeds from hop to hop. It begins at the origin, the
**PCA0**, and each later PCA continues exactly one predecessor:

```text
PCA0  ->  PCA1  ->  PCA2  ->  …  ->  PCAn
```

When an executor hands off to more than one successor (fan-out), the lineage branches — but each branch still continues a single
predecessor:

```text
PCA100
 ├── PCA101-A
 └── PCA101-B
```

So a lineage is a sequence — or, with fan-out, a tree — of PCAs, each linked to its predecessor by `previousPcaHash`. Revocation operates on
this structure: to revoke, one must be able to *name* a lineage and a *position* within it.

### 1.2 Three Kinds of Revocation State

This is the one idea a reader coming from capability systems needs. Not everything a PCA touches can be revoked the same way, because not
everything survives to the next hop.

**Lineage-persistent state** is signed data propagated (or attenuated) along the lineage:

```text
profile
lineageId
grantId
lineageCounter
originIssuer   (when the profile requires it)
operations
executionContract
```

A revocation or restriction over these can be applied downstream, because the Verifier still holds the data.

**Hop-local evidence** is used to validate one transition and does not become a permanent property of every descendant:

```text
executor
signing key
executorAttestation
request binding
proofOfRelationship
```

Revoking hop-local evidence has direct effect only while that evidence is still *presented* to a Verifier.

**Derived causal revocation** is how the two are bridged. To invalidate the descendants of a historical key, delegate, attestation, or
issuer, the historical position is resolved into a native PIC cutoff:

```text
LINEAGE-SUFFIX(lineageId, fromCounter)
```

The downstream Verifier then applies the cutoff without ever seeing the historical key, identity, or attestation again. This is the ontological
shift: a revocation is expressed as a *position in an execution*, not only as a revoked credential.

### 1.3 Requirements Notation

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and
"OPTIONAL" in this document are to be interpreted as described in BCP 14 [[2]](#references) [[3]](#references) when, and only when, they appear
in all capitals, as shown here.

Examples in this document are illustrative and non-normative.

## 2. Revocation Coordinates

This section is normative. It defines the structural fields a **revocable** PCA carries and the continuity a Verifier checks. A profile that
does not support revocation MAY omit them; a revocable profile MUST include them. They extend the PCA format of the
[PIC Prover and Verifier Specification](./pic-prover-verifier-spec.md) and are covered by the same single PCA signature; they do not change
its non-expansion or Proof-of-Relationship rules.

### 2.1 Origin PCA (PCA0)

A revocable PCA0 carries `profile`, `originNonce`, `lineageId`, `lineageCounter`, `grantId` (when it derives from a separately revocable
grant), and `originIssuer` (when the profile supports direct `ISSUER` revocation). All are covered by the PCA0 signature.

**`lineageId` is derived from a non-self-referential origin core.** A PCA cannot hash *itself* to obtain its own identifier, so `lineageId`
is the hash of a canonical projection of PCA0 that excludes `lineageId` and `proof`:

```text
originCore = the profile's canonical projection of PCA0, excluding lineageId and proof
lineageId  = H( "PIC-Lineage-v0" || canonical(originCore) )
```

`originCore` MUST include at least `profile`, `issuer`, `originNonce`, the presence and value of `grantId`, the origin authority context,
`issuedAt`, and `expiresAt`. The profile MUST specify exactly which fields are included, which excluded, the canonical encoding, the hash
suite, and the domain-separation string.

**`originNonce`** MUST have sufficient entropy — SHOULD be at least 128 random bits, 256 RECOMMENDED. An issuer MUST generate a *fresh* nonce
for each intentionally distinct lineage and MUST NOT reuse one within the same origin-commitment namespace. Two PCA0 with the same origin
commitment (hence the same `lineageId`) are the *same* origin, not independent lineages.

The commitment binds `lineageId` to the declared issuer, nonce, profile, grant binding, and origin authority context. Copying those public
fields does not create a valid colliding lineage, because the resulting PCA0 must also satisfy the origin trust boundary
([PIC Prover and Verifier Specification](./pic-prover-verifier-spec.md), Section 6.2) and carry a valid signature (or equivalent origin
authorization) for the committed issuer. The nonce distinguishes intentionally separate origins by the same issuer; the signature prevents
another party from originating *as* that issuer.

**`grantId`** — present when the origin derives from a separately revocable grant. The binding between `grantId` and the PCA0 MUST be
verifiable at origin validation (the same trust boundary, Section 6.2): a PCA0 whose `grantId` is not attestable by the grant authority is
invalid. Possession of a `grantId` does not authorize its revocation (Section 5.1). It MUST NOT be interpreted as authorization on its own,
and MAY be shared by several PCA0.

**`originIssuer`** — when the profile supports direct `ISSUER` revocation, `PCA0.originIssuer == PCA0.issuer`, covered by the signature and
propagated unchanged (Section 2.2).

**`profile`** identifies the revocable profile in force. **`lineageCounter`** MUST be `0`.

```json
{
  "profile": "PIC-Revocable-v0",
  "issuer": "did:example:users:alice",
  "originIssuer": "did:example:users:alice",
  "originNonce": "base64url-random-256-bit-value",
  "grantId": "urn:uuid:11111111-1111-4111-8111-111111111111",
  "lineageId": "sha256:…",
  "lineageCounter": 0,
  "invariants": { "…": "operations and executionContract (Prover/Verifier spec)" },
  "continuation": { "…": "the emitted challenge" },
  "issuedAt": "2026-07-17T10:00:00Z",
  "expiresAt": "2026-07-18T10:00:00Z",
  "proof": { "…": "signature covering the complete PCA0" }
}
```

To validate PCA0, the Verifier MUST reconstruct `originCore`, recompute `lineageId`, compare it with `PCA0.lineageId`, verify the PCA0
signature, and verify the grant and origin bindings.

### 2.2 Successor PCA

Every non-origin PCA MUST propagate `profile`, `lineageId`, the presence and value of `grantId`, and `originIssuer` (when the profile
propagates it) **unchanged**, MUST set `lineageCounter` to the predecessor's value plus one, and MUST cover all of them under the PCA
signature. A Prover MUST NOT alter or drop these fields, introduce a `grantId` the predecessor lacks, or change the `profile`.

> A lineage created under a revocable profile remains revocable for its entire lifetime. A successor cannot downgrade it by omitting the
> profile or its revocation coordinates.

### 2.3 Verifier Hop Validation

In addition to the hop checks of the [PIC Prover and Verifier Specification](./pic-prover-verifier-spec.md) (Section 3.3), a
revocation-aware Verifier MUST, for each non-origin hop, reject the PCA unless all of the following hold against the already-validated
predecessor:

```text
current.previousPcaHash   == H(predecessor)
current.profile           == predecessor.profile
current.lineageId         == predecessor.lineageId
presence(current.grantId) == presence(predecessor.grantId)
if grantId is present:      current.grantId == predecessor.grantId
if profile propagates it:   current.originIssuer == predecessor.originIssuer
current.lineageCounter     == predecessor.lineageCounter + 1
```

The counter rule is exact. The Verifier MUST reject a `lineageCounter` that is missing, negative, fractional, non-canonical, less than or
equal to the predecessor's, greater than `predecessor + 1`, or that overflows or wraps around.

## 3. Revocation Strategies

This section is non-normative. It illustrates the revocation targets expressible with PIC coordinates; the normative revocation object and
verification procedure are defined in a later revision. All examples share one minimal format:

```json
{
  "type": "PIC-Revocation-v0",
  "strategy": "…",
  "target": { "…": "…" },
  "issuedAt": "2026-07-18T10:00:00Z",
  "issuer": "did:example:revocation-authority"
}
```

The `proof` field is omitted for brevity. A valid revocation MUST be signed by an authorized authority (Section 5.1); an object signed by an
unauthorized party has no effect.

### 3.1 Native Causal Revocations

These are enforceable directly from coordinates propagated in every PCA, so a Verifier needs nothing beyond the transition it holds. Whole-
lineage revocation is the degenerate suffix from the origin: `LINEAGE(lineageId) = LINEAGE-SUFFIX(lineageId, 0)`.

**`LINEAGE-SUFFIX`** — a position and everything causally after it.

```text
lineageId L,  fromCounter = 42

PCA0 … PCA41 -> PCA42 -> PCA43 -> …
 keep  keep     X        X
```

```json
{
  "type": "PIC-Revocation-v0",
  "strategy": "LINEAGE-SUFFIX",
  "target": { "lineageId": "L1", "fromCounter": 42 },
  "issuedAt": "2026-07-18T10:00:00Z",
  "issuer": "did:example:revocation-authority"
}
```

```text
reject if:
  PCA.lineageId == target.lineageId
  AND PCA.lineageCounter >= target.fromCounter
```

**`GRANT`** — every lineage created from one grant.

```json
{
  "type": "PIC-Revocation-v0",
  "strategy": "GRANT",
  "target": { "grantId": "G1" },
  "issuedAt": "2026-07-18T10:00:00Z",
  "issuer": "did:example:grant-authority"
}
```

```text
reject if:
  PCA.grantId == target.grantId
```

**`BRANCH-SUFFIX`** is a future extension: `branchId` is not defined by this revision. Until it is, `LINEAGE-SUFFIX` strikes *all* sibling
branches at or beyond `fromCounter` (Section 5.3).

### 3.2 Identity and Evidence Selectors

These target **hop-local evidence** — a key, a delegate, an attestation, an issuer. They have direct effect while the element is *presented*;
they are **not** automatically retroactive over descendants that no longer carry it. Reaching those descendants is the subject of Section 4.

- **`KEY`** — reject when the revoked `verificationMethod` appears in the current transition.
- **`DELEGATE`** — reject when the revoked delegate is the `executor` of the current transition (the field name may be `delegateId`,
  `executorId`, `subject`, or `workloadId`, per profile).
- **`ATTESTATION`** — reject when the revoked attestation is presented as conformance evidence.
- **`ISSUER`** — reject directly when `originIssuer`, or an equivalent authenticated origin binding, is available under the profile.

```json
{
  "type": "PIC-Revocation-v0",
  "strategy": "KEY",
  "target": { "verificationMethod": "did:example:workloads:eu:backup-service#key-1" },
  "effectiveAt": "2026-07-18T09:30:00Z",
  "issuedAt": "2026-07-18T10:00:00Z",
  "issuer": "did:example:key-authority"
}
```

**Why "presented only".** In the incremental profile a Verifier holds only the immediate transition — the predecessor and the current PCA:

```text
+----------------+      |      +----------------+      |      +----------------+
|  EXECUTOR n-1  |------|----->|   EXECUTOR n   |------|----->|  EXECUTOR n+1  |
+----------------+      |      +----------------+      |      +----------------+
      hop n-1                       hop n                        hop n+1
```

If Bob signs `PCA1`:

```text
PCA0 --Alice--> PCA1 --Bob--> PCA2 --Carol--> PCA3 --Dave-->

verifier at hop 2 sees [PCA0, PCA1] : Bob is current
verifier at hop 3 sees [PCA1, PCA2] : Bob is predecessor
verifier at hop 4 sees [PCA2, PCA3] : Bob is no longer visible
```

So a selector revocation has three reaches:

```text
PREVENTIVE          the revoked party can no longer produce a newly accepted hop
IN-TRANSIT          a transition carrying the revoked evidence (current or predecessor) is rejected
CAUSAL-RETROACTIVE  existing descendants are invalidated only after the historical position
                    is converted into a lineage cutoff (Section 4)
```

The visibility window is two verifications, not one.

### 3.3 Dynamic Restrictions

These restrict *effective* authority without rewriting the signed chain.

**`AUTHORITY`** removes operations:

```text
signed operations    = { READ, WRITE }
active restrictions  = { remove WRITE }
effective operations = { READ }

effectiveAuthority(PCA) = signedAuthority(PCA) − applicableRestrictions(PCA)
```

Non-expansion still compares the *signed* state — `signedAuthority(current) <= signedAuthority(predecessor)` — so a PCA signed before the
revocation does not spuriously fail. The concrete operation is checked against `effectiveAuthority(current)`; a PCA already attenuated to
`{READ}` continues normally. The filter belongs to the authorization rule (paper, Section 5.1), downstream of chain validation, never to the
non-expansion check.

**`EXECUTION-CONTRACT`** restricts *who or what* may continue:

```text
signed executionModel = { deterministic, agentic }
restriction removes   = { agentic }
effective model       = { deterministic }
```

Every new executor must conform to the *effective* contract.

**Restrictions are monotonic.** They are append-only and only ever more restrictive: `effectiveRestrictions(t+1) >= effectiveRestrictions(t)`
in the profile's order. Relaxing authority requires a *new* grant, PCA0, and lineage — never deleting a revocation, un-revoking a lineage, or
replacing the revocation view with an older one. A temporary operational suspension, if supported, belongs to a separate profile and MUST NOT
weaken the monotonicity of security revocations.

### 3.4 Retrospective Annotation

**`AUDIT-RANGE`** marks a historical interval as compromised, for audit or incident response. It is *not* a forward-validity rule:

```text
PCA0 -> PCA1 -> PCA2 -> PCA3 -> PCA4 -> PCA5
                 [ affected incident interval ]
```

By Lemma 1 of the paper a PCA's validity is the composition of Proofs of Relationship back to PCA0, so no valid suffix can stand above an
invalid segment. The forward consequence of flagging an interval from counter `k` is therefore `LINEAGE-SUFFIX(fromCounter = k)`.

### 3.5 Summary

| Category                   | Strategies                                        | Direct meaning                                                                        |
| -------------------------- | ------------------------------------------------- | ------------------------------------------------------------------------------------- |
| Native causal revocation   | `LINEAGE-SUFFIX`, `GRANT`, future `BRANCH-SUFFIX` | Directly enforceable from propagated execution coordinates                            |
| Identity/evidence selector | `KEY`, `DELEGATE`, `ATTESTATION`, `ISSUER`        | Blocks presented evidence; historical causal effects require resolution into suffixes |
| Dynamic restriction        | `AUTHORITY`, `EXECUTION-CONTRACT`                 | Restricts effective authority or conformance without rewriting the signed chain       |
| Retrospective annotation   | `AUDIT-RANGE`                                     | Marks an affected historical interval but does not preserve a valid suffix above it   |

## 4. Making Selectors Causal

This section is non-normative and may be skipped on a first reading. It is the machinery that turns an identity/evidence selector
(Section 3.2) into causal cutoffs that reach descendants no longer carrying the evidence — while keeping downstream verification **O(1)**:

```text
KEY / DELEGATE / ATTESTATION / ISSUER
        |  authenticated historical resolution
        v
   affected (lineageId, counter) pairs
        |
        v
   LINEAGE-SUFFIX records  ->  O(1) verification
```

### 4.1 Known Positions and Materialization

A selector MAY carry a bounded set of `knownPositions`; each one implies `LINEAGE-SUFFIX(lineageId, atCounter)`:

```json
{
  "type": "PIC-Revocation-v0",
  "strategy": "KEY",
  "target": { "verificationMethod": "did:example:bob#key-1" },
  "knownPositions": [
    { "lineageId": "L1", "atCounter": 7,  "positionWitness": { "…": "…" } },
    { "lineageId": "L7", "atCounter": 14, "positionWitness": { "…": "…" } }
  ],
  "issuedAt": "2026-07-18T10:00:00Z",
  "issuer": "did:example:key-authority"
}
```

`knownPositions` MUST be OPTIONAL, bounded by the profile, and used only for small sets. Large sets MUST be published as separate
`LINEAGE-SUFFIX` records or an authenticated, paginable batch — never a single unbounded object.

**Authorization and witness.** A `knownPositions` entry MUST NOT create an implied suffix merely because it sits inside an authorized `KEY`,
`DELEGATE`, `ATTESTATION`, or `ISSUER` revocation. For every implied suffix the implementation MUST establish both:

```text
1. position authenticity  — the selector actually appeared in the named lineage at the stated counter;
2. cutoff authorization   — the revocation issuer is authorized to invalidate the suffix rooted there.
```

The base profile SHOULD use a conservative chain:

```text
identity/evidence revocation
  -> authenticated historical resolution
  -> authorized lineage or grant authority
  -> materialized LINEAGE-SUFFIX
```

The controller of a revoked key is therefore *not* automatically authorized to revoke every lineage in which that key appeared. Position
authenticity is proven by a witness:

```json
{
  "lineageId": "L1",
  "atCounter": 7,
  "positionWitness": {
    "pcaHash": "sha256:…",
    "verificationMethod": "did:example:bob#key-1",
    "proof": "…"
  }
}
```

Witness verification MUST establish that the witness `lineageId` and `lineageCounter` equal the entry's, that the witness selector equals the
revoked selector, and that the witness integrity and signature are valid. A bare, unproven `(lineageId, atCounter)` assertion MUST NOT be
sufficient to invalidate a lineage.

### 4.2 Historical Position Index

Deployments that need retroactive causal revocation for `KEY`, `DELEGATE`, `ATTESTATION`, or `ISSUER` SHOULD keep a minimal *authenticated*
index mapping a selector to the positions where it occurred:

```text
bob#key-1
  -> (L1, 1)
  -> (L8, 27)
  -> (L9, 4)
```

which yields `LINEAGE-SUFFIX(L1, 1)`, `LINEAGE-SUFFIX(L8, 27)`, `LINEAGE-SUFFIX(L9, 4)`. A record MAY carry more context:

```json
{
  "lineageId": "L1",
  "lineageCounter": 42,
  "executorId": "did:example:bob",
  "verificationMethod": "did:example:bob#key-1",
  "attestationId": "A17",
  "originIssuer": "did:example:alice"
}
```

This is **not** the full-chain profile: the hot path stays O(1), it does not keep all PCA bytes, and it only resolves selectors to
coordinates. It MUST be authenticated — an unauthenticated log is not sufficient evidence — and its retention, privacy, and access control
are deployment concerns.

### 4.3 Not Carrying Full History

The base incremental profile does not require each PCA to carry the complete list of historical executors, keys, or attestations. Doing so
would cause unbounded growth, correlation, duplicate data, larger signatures and messages, and harder canonicalization. A future extension
MAY instead use a cryptographic accumulator, an authenticated index, a transparency log, a snapshot commitment, or a Merkle or succinct
proof to show that *"key K appears in the ancestry of PCA[n]"* without transporting a full array. This is future evolution only.

## 5. Revocation Model and Limitations

This section is non-normative. It records the constraints a later normative revocation revision must honor.

### 5.1 Who May Revoke

A revocation takes effect only if signed by an authorized issuer; an unauthorized object has no effect and is itself a denial of service.
Listing *who* may revoke is not enough — there MUST be a **verifiable binding** between the revoker and the target.

| Revoker | May revoke | Binding proven by |
| --- | --- | --- |
| The origin issuer | its own lineage | `revocation.issuer == lineage.originIssuer` |
| An executor at hop `k` | only its own causal future (`fromCounter >= k+1`) | its position in the validated chain |
| The grant authority | the grant, and its contract terms | `AuthorizedGrantRevoker(grantId, issuer)` |
| The key controller | that key | control of the verification method |
| The attestation issuer | that attestation | the attestation's issuer signature |

**Counter semantics.** `fromCounter = k` revokes hop `k` *and* its future; `fromCounter = k+1` keeps hop `k` valid and blocks every
continuation. An executor at counter `k` may revoke `fromCounter = k+1` (its own future); it may revoke `fromCounter = k` only if the policy
grants it; it MUST NOT revoke a position upstream of itself unless it separately holds the origin, grant, or revocation authority.

**Grant revocation.** A `GRANT` revocation MUST be accepted only when the Verifier can establish `AuthorizedGrantRevoker(target.grantId,
revocation.issuer)` — via a signed grant credential, a grant-authority field committed by PCA0, an authenticated grant registry, or a
profile-defined grant commitment. Possession of a `grantId` alone MUST NOT authorize its revocation.

### 5.2 Revocation State

- **Monotonic and irreversible.** Revocation state is append-only; there is no un-revoke. The view is identified by a monotonic version or
  commitment, and a Verifier MUST NOT accept a view older than the policy minimum — otherwise it could be replayed against an older, "clean"
  view to accept an already-revoked PCA.
- **Freshness and distribution.** Revocation state may be pulled by the Verifier or stapled by the Prover; the choice is left to a later
  revision. A short per-hop expiry
  ([PIC Prover and Verifier Specification](./pic-prover-verifier-spec.md), Section 6.3) *bounds*, but does not eliminate, the interval in
  which a newly issued revocation may not yet have reached a Verifier.
- **Trusted time.** `effectiveAt` generalizes to *every* strategy with a temporal cutoff. A self-declared timestamp by a compromised subject
  is not, by itself, reliable proof of when a signature was created. For a compromised key, *known* positions are converted into suffix
  revocations, while *newly forged* positions are blocked by the direct key-status check when the key is presented — not by previously
  enumerated suffixes. A future extension MAY use a trusted timestamp, transparency log, hardware monotonic time, or forward-secure
  signatures.

### 5.3 Limitations

- **Fan-out.** Until `branchId` exists (Section 3.1), `LINEAGE-SUFFIX` acts on shared depth and strikes *sibling* branches at or beyond
  `fromCounter`. The current profile is correct for "revoke the whole future", not for per-branch revocation.
- **Privacy — in context.** Every multi-hop authority-propagation system exposes correlators; the design question is *which* correlators, to
  *whom*, and whether they can be confined. Systems that present the full delegation history at verification time expose the identity of
  *every past delegator* to every verifier — rich, semantic, entity-level correlators, reusable across executions. In the incremental profile
  a Verifier sees only the identities of the current transition (executor and immediate predecessor) plus the *opaque* execution identifiers
  `lineageId`, `grantId`, and `originIssuer` (where propagated); historical identities do not travel, so the exposed correlator is
  execution-scoped — it links hops of the same execution but does not by itself identify the origin entity. `lineageId`, `grantId`, and
  `originIssuer` remain persistent correlators, and this residual per-lineage linkability is not an accident: any authorization decision that
  resolves the confused deputy must read some function of the lineage (the lineage-sensitivity result of the companion paper
  [[1]](#references)), so a minimal execution-scoped correlator is the theoretical *floor* of that requirement, not overhead above it. It can
  be confined without weakening the revocation predicate — pairwise or blinded per-segment lineage identifiers, reconcilable only by the
  revocation authority, are the natural unlinkability profile, and selective disclosure on executor attestations further reduces the identity
  surface of the current transition (consistent with the attestation-disclosure recommendation of the
  [PIC Prover and Verifier Specification](./pic-prover-verifier-spec.md)).
- **Incremental visibility.** Direct `KEY`, `DELEGATE`, and `ATTESTATION` see only the evidence in the received transition (Section 3.2);
  reaching the past requires Section 4.

## 6. Counter Capacity

This appendix is non-normative. Because `lineageCounter` is an integer and a lineage is sequential by definition, exhausting it requires
completing that many *causal* hops on one path — and, since each hop waits for its predecessor, the per-lineage rate is not parallelizable.

```text
secondsToOverflow = (2^64 − 1 − currentCounter) / R
    where R = maximum accepted hops per second on one lineage path
```

*Illustrative only* (not a benchmark; actual `R` depends on hardware, network, and application logic): at `R = 1000` hops/s a `uint64`
counter overflows after more than two hundred million years. A `uint64` counter is therefore practically inexhaustible under realistic
execution rates, though a profile that wants the mathematically unbounded case MAY use a CBOR bignum. The normative point is only the one
already stated in Section 2.3: **overflow and wraparound are rejected.**

The design note: the counter carries every native predicate (`LINEAGE`, `LINEAGE-SUFFIX`, `GRANT`) in the space of a small integer, with no
stored history on the hot path. A frontier accumulator remains an *optional* extension for membership proofs and cryptographic audit of the
prefix.

## 7. Contributors

The editors and contributors of this document are listed in the **document header** above. Listing is governed by Appendix B.7 of the
[PIC Legal Appendices](./pic-legal.md).

## 8. Legal Notices

The appendices governing:

- **A.** Use of Automated Language Assistance,
- **B.** Authorship, Stewardship, Attribution, and Derivative Works,
- **C.** Disclaimer and Limitation of Liability,
- **D.** Acknowledgements,

are maintained in a single canonical document, the **[PIC Legal Appendices](./pic-legal.md)** (`draft/0.2/pic-legal.md`), and are
**incorporated into this specification by reference** as if fully set forth herein.

In case of conflict between this document and the PIC Legal Appendices, the PIC Legal Appendices prevail for legal, governance, licensing,
and attribution matters.

This specification is subordinate to the [PIC Specification](./pic-spec.md), which defines the normative semantics of the PIC Model and is
the entry point of the specification set. This document does not introduce new conceptual authority, invariants, or authorship claims beyond
those defined in the PIC Legal Appendices.

## References

- [1] Gallo, N. (2026). *Proof-of-Continuity: A Temporal Model for Authority Propagation in Distributed Systems and AI Agents*. arXiv:2607.08906 [cs.CR]. [arxiv.org/abs/2607.08906](https://arxiv.org/abs/2607.08906)
- [2] Bradner, S. (1997). *Key words for use in RFCs to Indicate Requirement Levels*. BCP 14, RFC 2119. [rfc-editor.org/rfc/rfc2119](https://www.rfc-editor.org/rfc/rfc2119)
- [3] Leiba, B. (2017). *Ambiguity of Uppercase vs Lowercase in RFC 2119 Key Words*. BCP 14, RFC 8174. [rfc-editor.org/rfc/rfc8174](https://www.rfc-editor.org/rfc/rfc8174)
