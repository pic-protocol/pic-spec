# PIC Revocation Specification

**Version:** 0.2 (Draft)  
**Status**: Draft – Not a Standard  
**Date:** 2026-07-18  
**Source:** [github.com/pic-protocol/pic-spec/draft/0.2/pic-revocation-spec.md](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-revocation-spec.md)  
**Editors:**

- **Nicola Gallo** (Nitro Agility S.r.l.) Lead Editor
- *Add your name via pull request (individual or organization) — listing is subject to editor approval (see [Section 7](#7-contributors)).*

**Contributors:**

- *Add your name via pull request (individual or organization) — listing is subject to editor approval (see [Section 7](#7-contributors)).*

## Abstract

This document is the **PIC Revocation Specification**, a subordinate specification of the [PIC Specification](./pic-spec.md). It defines how
**authority is revoked** within the Provenance Identity Continuity (PIC) Model.

Expiry bounds *how long* a PCA is valid; revocation withdraws validity *before* that bound. The profile supports grant-, key-, delegate-,
attestation-, issuer-, and policy-based revocation, and adds a property specific to PIC: **causal execution cutoffs** — revoking a lineage,
a branch, or its future from a given position.

This revision normatively defines the **revocation coordinates** and their hop-by-hop continuity (Section 2), the requirements for turning a
historical selector into a causal cutoff (Section 4), and the revocation-authorization and revocation-state requirements (Section 5). It
illustrates candidate revocation strategies (Section 3, non-normative). The coordinates extend the PCA format of the
[PIC Prover and Verifier Specification](./pic-prover-verifier-spec.md); they do not alter the PIC Model invariants — non-expansion of the
signed state and Proof of Relationship are unchanged, and every PCA still continues exactly one predecessor. In case of conflict, the
**PIC Specification** is authoritative.

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
    - [2.4 Branch Identification](#24-branch-identification)
  - [3. Revocation Strategies](#3-revocation-strategies)
    - [3.1 Native Causal Revocations](#31-native-causal-revocations)
    - [3.2 Identity and Evidence Selectors](#32-identity-and-evidence-selectors)
    - [3.3 Dynamic Restrictions](#33-dynamic-restrictions)
    - [3.4 Retrospective Annotation](#34-retrospective-annotation)
    - [3.5 Summary](#35-summary)
  - [4. Making Selectors Causal](#4-making-selectors-causal)
    - [4.1 Position Witness](#41-position-witness)
    - [4.2 Cutoff Authorization](#42-cutoff-authorization)
    - [4.3 Known Positions](#43-known-positions)
    - [4.4 Historical Position Index](#44-historical-position-index)
    - [4.5 Not Carrying Full History](#45-not-carrying-full-history)
  - [5. Revocation Authorization and State](#5-revocation-authorization-and-state)
    - [5.1 Who May Revoke](#51-who-may-revoke)
    - [5.2 Dynamic Restriction Requirements](#52-dynamic-restriction-requirements)
    - [5.3 Monotonicity](#53-monotonicity)
    - [5.4 Revocation State and Availability](#54-revocation-state-and-availability)
    - [5.5 Trusted Time and Key Compromise](#55-trusted-time-and-key-compromise)
    - [5.6 Limitations](#56-limitations)
  - [6. Counter Capacity](#6-counter-capacity)
  - [7. Contributors](#7-contributors)
  - [8. Legal Notices](#8-legal-notices)
  - [References](#references)

## 1. Introduction

This section is non-normative. It explains the concepts revocation needs; the normative requirements are in Sections 2, 4, and 5.

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

Each individual lineage path is causally sequential; the lineage as a whole may form a tree under fan-out. Revocation operates on this
structure: to revoke, one must be able to *name* a lineage, a branch domain within it, and a *position*.

### 1.2 Three Kinds of Revocation State

This is the one distinction a reader coming from OAuth or capability systems needs. Not everything a PCA touches can be revoked the same way,
because not everything survives to the next hop.

**Lineage-persistent state** is signed data propagated (or attenuated) along the lineage:

```text
profile
lineageId
grantId
lineageCounter
originIssuer               (when propagated)
branchId                   (when the profile is branch-capable)
operations
executionContract
```

A revocation or restriction over these can be applied downstream, because the Verifier still holds the data.

**Hop-local evidence** validates one concrete transition and does not become a permanent property of every descendant:

```text
executor
signing key
executorAttestation
request binding
proofOfRelationship
branchCreationNonce        (present only in a branch-creation PCA)
```

Revoking hop-local evidence has direct effect only while that evidence is still *presented* to a Verifier.

**Derived causal revocation** bridges the two. A historical revocation of a `KEY`, `DELEGATE`, `ATTESTATION`, or `ISSUER` reaches descendants
only when the historical position is turned into a native cutoff:

```text
LINEAGE-SUFFIX(lineageId, fromCounter)
```

The key change is that historical evidence is converted into an *execution coordinate* that downstream Verifiers can still evaluate — a
revocation is expressed as a position in an execution, not only as a revoked credential. A Verifier at a later hop applies the cutoff without
seeing the historical key, identity, or attestation again.

### 1.3 Requirements Notation

The **normative** sections of this document are Sections 2, 4, and 5. Sections 1, 3, and 6 are **non-normative**.

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and
"OPTIONAL" are to be interpreted as described in BCP 14 [[2]](#references) [[3]](#references) when, and only when, they appear in all capitals,
and only within the normative sections. Examples are illustrative and non-normative.

## 2. Revocation Coordinates

This section is normative. It defines the structural fields a **revocable** PCA carries and the continuity a Verifier checks. A profile that
does not support revocation MAY omit them; a revocable profile MUST include them. They extend the PCA format of the
[PIC Prover and Verifier Specification](./pic-prover-verifier-spec.md) and are covered by the same single PCA signature; they do not change
its non-expansion or Proof-of-Relationship rules.

### 2.1 Origin PCA (PCA0)

A revocable PCA0 carries `profile`, `originNonce`, `lineageId`, `lineageCounter`, `grantId` (when it derives from a separately revocable
grant), and `originIssuer` (when the profile supports direct origin-issuer revocation). All are covered by the PCA0 signature, which itself
includes `lineageId`.

**`lineageId` is derived from a non-self-referential origin core.** A PCA cannot hash *itself* to obtain its own identifier, so `lineageId`
is the hash of a canonical projection of PCA0 that excludes `lineageId` and `proof`:

```text
originCore = the profile-defined canonical projection of PCA0, excluding lineageId and proof
lineageId  = H( "PIC-Lineage-v0" || canonical(originCore) )
```

`originCore` MUST include at least `profile`, `issuer`, `originNonce`, the presence and value of `grantId`, the origin authority context,
`issuedAt`, and `expiresAt`. The profile MUST define exactly the fields included, the fields excluded, the canonical encoding, the hash
suite, and the domain separator.

The origin commitment binds `lineageId` to the declared issuer, nonce, profile, grant binding, and origin authority context. Copying those
public fields does not create a valid colliding lineage, because the resulting PCA0 must also satisfy the origin trust boundary
([PIC Prover and Verifier Specification](./pic-prover-verifier-spec.md), Section 6.2) and carry a valid signature (or equivalent origin
authorization) for the committed issuer:

```text
originNonce                     distinguishes intentionally separate origins by the same issuer
issuer signature / origin authz  prevents another party from creating a valid origin as that issuer
```

**`originNonce`** SHOULD contain at least 128 random bits; 256 random bits are RECOMMENDED. An issuer MUST generate a fresh `originNonce` for
every intentionally distinct lineage and MUST NOT reuse one within the same origin-commitment namespace. Two PCA0 with the same origin
commitment (hence the same `lineageId`) MUST be treated as the *same* origin, not as independent lineages. Global reuse detection MAY require
an authenticated origin registry, a transparency log, or shared state, but the no-reuse rule remains a requirement of the origin issuer.

**`grantId`** — present when the origin derives from a separately revocable grant. The binding between `grantId`, its grant authority, and
the authority context MUST be verifiable during PCA0 validation. Possession or knowledge of a `grantId` does not authorize its revocation
(Section 5.1). It MUST NOT be interpreted as authorization on its own, and MAY be shared by several PCA0.

**`originIssuer`** — when the profile supports direct origin-issuer revocation, `PCA0.originIssuer == PCA0.issuer`, covered by the signature
and propagated unchanged (Section 2.2). `originIssuer` is a revocation-administration coordinate: it does not grant execution authority, does
not designate a successor, and does not replace Proof of Relationship or executor conformance.

**`profile`** identifies the revocable profile in force. **`lineageCounter`** MUST be `0`.

**Branch coordinate** — in a branch-capable profile (Section 2.4), PCA0 carries the root branch domain `branchId`, derived from `lineageId`
as `rootBranchId = H( "PIC-Root-Branch-v0" || lineageId )` and covered by the PCA0 signature. There is no root nonce and no absent-root case.

```json
{
  "profile": "PIC-Revocable-v0",
  "issuer": "did:example:users:alice",
  "originIssuer": "did:example:users:alice",
  "originNonce": "base64url-random-256-bit-value",
  "grantId": "urn:uuid:11111111-1111-4111-8111-111111111111",
  "lineageId": "sha256:…",
  "branchId": "sha256:… (rootBranchId, derived from lineageId; Section 2.4)",
  "lineageCounter": 0,
  "invariants": { "…": "operations and executionContract (Prover/Verifier spec)" },
  "continuation": { "…": "the emitted challenge" },
  "issuedAt": "2026-07-17T10:00:00Z",
  "expiresAt": "2026-07-18T10:00:00Z",
  "proof": { "…": "signature covering the complete PCA0, including lineageId and branchId" }
}
```

To validate PCA0, the Verifier MUST reconstruct `originCore`, recompute `lineageId`, compare it with `PCA0.lineageId`, recompute
`rootBranchId` from the recomputed `lineageId` and compare it with `PCA0.branchId` (in a branch-capable profile), verify the complete PCA0
signature, verify the origin authorization, and verify the grant binding when `grantId` is present.

### 2.2 Successor PCA

Every non-origin PCA MUST propagate `profile`, `lineageId`, the presence and value of `grantId`, and `originIssuer` (when the profile
propagates it) **unchanged**, MUST set `lineageCounter` to the predecessor's value plus one, and MUST cover all of them under the PCA
signature. A Prover MUST NOT alter or drop these fields, MUST NOT introduce a `grantId` the predecessor lacks, and MUST NOT change the
`profile`.

In a branch-capable profile (Section 2.4) the successor MUST propagate `branchId` **unchanged**, except when it is itself an authorized
branch-creation PCA, where it derives a fresh `branchId` and carries a fresh `branchCreationNonce` for that single transition. An ordinary
successor MUST NOT carry `branchCreationNonce`. A branch-capable profile MUST prevent downgrade by omission: a successor MUST NOT drop
`branchId`.

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
if originIssuer propagated:  current.originIssuer == predecessor.originIssuer
current.lineageCounter     == predecessor.lineageCounter + 1

if branch-capable, ordinary hop:      current.branchId == predecessor.branchId
                                      current MUST NOT carry branchCreationNonce
if branch-capable, branch creation:   current.branchId == H("PIC-Branch-v0" || current.previousPcaHash || current.branchCreationNonce)
                                      AND valid branch-creation authorization (Section 2.4)
```

The Verifier MUST reject when `profile` is missing or unknown, when `current.profile != predecessor.profile`, when required revocation
coordinates are omitted, or when a revocable lineage is presented under a non-revocable profile. The counter rule is exact: the Verifier
MUST reject a `lineageCounter` that is missing, negative, fractional, non-canonical, less than or equal to the predecessor's, greater than
`predecessor + 1`, or that overflows or wraps around.

In a branch-capable profile `branchId` is unconditionally present in every PCA. The Verifier MUST also reject when `branchId` is missing or
removed, when `branchId` changes without a valid, authorized branch-creation transition, when `branchId` does not recompute from
`current.previousPcaHash` and `current.branchCreationNonce` at a claimed branch-creation transition, when `branchCreationNonce` is present at
an ordinary hop or absent at a branch-creation hop, or when `branchId` or `branchCreationNonce` has a non-canonical representation or an
invalid size. At a branch-creation transition the Verifier MUST apply the validation order of Section 2.4, evaluating the revocations and
restrictions inherited from the predecessor's branch domain before accepting a new domain.

A valid signature is necessary but not sufficient: the Verifier validates the concrete transition `PCA[n-1] -> PCA[n]`, not merely the
signature of `PCA[n]`.

### 2.4 Branch Identification

Branch-capable profiles add one fixed-size persistent field (`branchId`) to every revocable PCA, plus one fixed-size nonce
(`branchCreationNonce`) that appears only in branch-creation transitions. They make `BRANCH-SUFFIX` (Section 3.1) a native strategy without
carrying branch ancestry:

```text
branchId             fixed-size branch-domain identifier, present in every PCA,
                     propagated unchanged within the branch domain
branchCreationNonce  fixed-size random value, present only in the PCA that creates a branch
                     domain, where it lets that transition's Verifier recompute the derivation;
                     never propagated to descendants
```

A PCA MUST NOT carry branch ancestry arrays, parent-branch lists, growing branch paths, full branch trees, or any unbounded branch metadata.
The model stays three flat coordinates:

```text
lineageId       identifies the overall execution lineage
lineageCounter  identifies causal depth on one path
branchId        identifies the current branch domain
```

**`branchId` is a derived commitment, not a free choice.** A freely chosen identifier would reintroduce, one level down, the
intentional-collision problem the origin commitment removes for `lineageId`: branch identifiers travel in the clear, so a malicious executor
at a different fan-out point of the same lineage could copy a victim branch's identifier and have a later `BRANCH-SUFFIX` strike the victim.
A non-root `branchId` is therefore bound to its creation transition:

```text
branchId = H( "PIC-Branch-v0" || current.previousPcaHash || current.branchCreationNonce )

current.previousPcaHash      the digest of the creation PCA's predecessor, already checked to equal
                             H(predecessor) in the same hop procedure (Section 2.3)
current.branchCreationNonce  fresh random value generated by the authorized successor creating the
                             branch domain, present only in that creation PCA
```

This gives three properties:

```text
Locally verifiable    a Verifier holding the creation transition recomputes branchId from
                      previousPcaHash and branchCreationNonce; no registry is needed for the
                      immediate transition
Creation-point-bound  reusing a branchId at a different fan-out point requires the same predecessor
                      digest or a hash collision; a branchId cannot be transplanted across creation
                      points
Verifiable binding    the construction makes the nonce-to-domain binding checkable; sibling
                      distinctness itself remains a Prover obligation — distinct nonces under one
                      predecessor give distinct domains, and an identical nonce gives the SAME
                      domain, not a collision between distinct domains
```

**Root branch.** PCA0 carries the root branch domain identifier, derived from `lineageId`:

```text
rootBranchId = H( "PIC-Root-Branch-v0" || lineageId )
```

- No circularity: `lineageId` is already derived from `originCore`, which excludes the identifier and proof fields (Section 2.1).
- No root nonce: the root domain is unique per lineage and has no siblings to distinguish.
- Always present: `branchId` is unconditionally required in every PCA of a branch-capable profile, so the "required but missing" check is
  unconditional and the root domain is directly targetable by `BRANCH-SUFFIX`.
- Uniform validation: PCA0 validation recomputes `rootBranchId` from the recomputed `lineageId`; every later hop uses the ordinary equality
  or creation-derivation check.

Anyone can *compute* the `rootBranchId` of a known lineage; this is consistent with the rule that knowledge of `lineageId`, `branchId`, or
`fromCounter` MUST NOT by itself authorize revocation (Section 5.1).

**Representation.** The persistent added state is one hash-sized field, `branchId` (e.g. 32 bytes). `branchCreationNonce` appears only in
creation transitions: it SHOULD contain at least 128 random bits, and 256 bits are RECOMMENDED (e.g. 16–32 bytes). The profile MUST define
the canonical binary representation of both; no textual UUID representation is required. `branchId` (always) and `branchCreationNonce` (in a
creation PCA) MUST be covered by the complete PCA signature.

**Fan-out.** At a fan-out point each new branch domain is created by an authorized successor, which generates its own fresh
`branchCreationNonce`, hence a fresh derived `branchId`:

```text
PCA100
 ├── PCA101-A  branchCreationNonce = nA  ->  branchId = H(dsep || H(PCA100) || nA)
 └── PCA101-B  branchCreationNonce = nB  ->  branchId = H(dsep || H(PCA100) || nB)
```

Each authorized successor creating a new branch domain MUST generate a fresh random `branchCreationNonce` and MUST NOT deliberately reuse
another sibling's nonce. Sibling distinctness is a **Prover obligation**: a per-hop Verifier sees only one sibling per envelope and cannot
compare siblings directly. In the open-continuation model the predecessor does not coordinate or mint its successors' PCAs; each continuing
executor generates its own nonce. Cross-sibling detection beyond this construction requires fan-out-point evidence or shared state and is not
a per-hop Verifier requirement.

**Branch-domain creation is a restricted operation.** This is the central rule of the branch profile. Without it, branch revocation is
evadable in one hop: an executor inside a revoked branch domain could mint a fresh branch domain and escape `BRANCH-SUFFIX` — and, since the
base profile carries no branch ancestry, no downstream Verifier could relate the new domain to the revoked one. Therefore creating a new
branch domain MUST be an authorized, authenticated operation. The base profile MUST restrict branch creation to parties authorized by the
execution contract, the origin, or the branch-domain creator's explicitly delegated authority. A nested continuation that is NOT authorized
to create a new branch domain MUST inherit the current `branchId` and MUST NOT carry a `branchCreationNonce`. Inheriting is the default;
minting is the exception.

The **branch-domain creator** is the executor that issues the valid branch-creation PCA establishing a new `branchId`. It is not necessarily
the predecessor executor, the origin issuer, or a coordinator aware of all sibling successors: in the open-continuation model each authorized
successor may independently create its own branch domain when the applicable execution contract or delegated authority permits it.

A branch-domain change is valid only at a transition that both recomputes as a correct derivation from the presented predecessor and carries
the profile-defined branch-creation authorization:

```text
branchId == H( "PIC-Branch-v0" || current.previousPcaHash || current.branchCreationNonce )
AND  profile-defined branch-creation evidence is present and valid
```

The profile MUST define that evidence — for example a branch-creation permission in the predecessor `executionContract`, or a signed grant
from the branch or origin authority.

**Anti-escape validation order.** A branch-creation transition is itself part of the causal future of the predecessor's branch domain. The
Verifier MUST therefore evaluate inherited revocations and restrictions against the predecessor's domain, at the current counter, BEFORE
accepting the creation:

```text
1. validate the predecessor and the transition linkage
   (previousPcaHash, profile, lineageId, grantId, originIssuer, lineageCounter);
2. apply the revocations and restrictions inherited from the predecessor — evaluated against the
   predecessor's branchId and the current lineageCounter — including LINEAGE-SUFFIX, BRANCH-SUFFIX,
   GRANT, and applicable dynamic restrictions and effective execution-contract requirements;
3. only if step 2 permits continuation, determine whether this transition claims branch creation;
4. validate the branch-creation authorization;
5. validate the branchId derivation and accept the new branch domain.
```

A `BRANCH-SUFFIX(lineageId, A, fromCounter)` therefore blocks any continuation from domain A at or beyond `fromCounter`, including a
continuation that attempts to create a new branch domain: the creation transition is evaluated in the predecessor's domain before the new
`branchId` exists for matching purposes. Branch creation cannot be used to exit a revoked domain.

**Backstop (defense in depth).** Beyond the validation order above, `LINEAGE-SUFFIX` remains the escape-resistant cutoff: it strikes every
branch of the lineage from the selected counter onward, regardless of `branchId`. `BRANCH-SUFFIX` is as strong as the branch-domain creation
policy; `LINEAGE-SUFFIX` does not depend on it.

**Nested fan-out and the ancestry trade-off.** By default a nested continuation inside an existing branch domain inherits the same `branchId`,
and its children remain part of the same revocation domain — this is intentional:

```text
branchId = A
 ├── child 1: branchId = A
 └── child 2: branchId = A
```

A profile MAY allow an *authorized* nested continuation to create fresh branch domains:

```text
branchId = A
 ├── child C: branchId = C   (authorized creation)
 └── child D: branchId = D   (authorized creation)
```

The PCA still carries only the current `branchId`. The base profile MUST NOT require a `parentBranchId` field, a branch ancestry array, or a
growing path. The base representation therefore keeps PCA state constant-size and directly supports revocation of the currently propagated
branch domain; it does not carry recursive branch ancestry. When an authorized nested continuation creates a new branch domain, causal
ancestry between the old and new branch identifiers requires authenticated historical resolution if revocation must cross that boundary —
exactly as historical selectors require resolution into native cutoffs (Section 4). The derived `branchId` helps here: it commits to the
digest of its creation-point PCA (its `previousPcaHash`). Proving that a new branch domain was created from an earlier one requires
authenticating **both** the branch-creation PCA and its predecessor — or an authenticated record that binds `creationPCA.previousPcaHash` to
the predecessor's `branchId` — and verifying:

```text
creationPCA.previousPcaHash == H(predecessorPCA)
predecessorPCA.branchId     == claimedParentBranchId
creationPCA.branchId        == H( "PIC-Branch-v0" || creationPCA.previousPcaHash || creationPCA.branchCreationNonce )
```

An authenticated historical-index record MAY replace transport of the complete predecessor PCA only when it cryptographically binds
`creationPCA.previousPcaHash`, `claimedParentBranchId`, `creationPCA.branchId`, and `creationPCA.branchCreationNonce` or its authenticated
commitment. Complete-chain transport is not required, and recursive ancestry remains external and optional.

## 3. Revocation Strategies

This section is non-normative and illustrative. It shows the revocation targets expressible with PIC coordinates. The requirements these
strategies must satisfy are normative in Sections 4 and 5: coordinates, authorization constraints, witness rules, materialization rules,
monotonicity, and revocation-state requirements are already normative. The complete interoperable revocation-object format, its
serialization, distribution endpoints, and status-retrieval protocol are defined by a later revision. All examples share one minimal format:

```json
{
  "type": "PIC-Revocation-v0",
  "strategy": "…",
  "target": { "…": "…" },
  "issuedAt": "2026-07-18T10:00:00Z",
  "issuer": "did:example:revocation-authority"
}
```

The `proof` field is omitted for brevity. A valid revocation is signed by an authorized authority (Section 5.1); an object signed by an
unauthorized party has no effect.

### 3.1 Native Causal Revocations

These strategies are directly enforceable from the propagated coordinates in the received transition once the applicable authenticated and
sufficiently fresh revocation state is available. Whole-lineage revocation is the degenerate suffix from the origin:
`LINEAGE(lineageId) = LINEAGE-SUFFIX(lineageId, 0)`.

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

**`BRANCH-SUFFIX`** — one branch domain and everything causally after a position, in **branch-capable** profiles (Section 2.4).

```json
{
  "type": "PIC-Revocation-v0",
  "strategy": "BRANCH-SUFFIX",
  "target": {
    "lineageId": "L1",
    "branchId": "base64url-hash-value",
    "fromCounter": 101
  },
  "issuedAt": "2026-07-18T10:00:00Z",
  "issuer": "did:example:revocation-authority"
}
```

```text
reject if:
  PCA.lineageId          == target.lineageId
  AND PCA.branchId       == target.branchId
  AND PCA.lineageCounter >= target.fromCounter
```

`LINEAGE-SUFFIX` revokes every branch of a lineage from a counter onward; `BRANCH-SUFFIX` revokes only the matching branch domain from a
counter onward.

```text
PCA100
 ├── PCA101-A  branchId=A   revoked by BRANCH-SUFFIX(L, A, 101)
 └── PCA101-B  branchId=B   remains valid
```

The root branch domain is directly targetable: its `branchId` is the derived `rootBranchId = H("PIC-Root-Branch-v0" || lineageId)`
(Section 2.4), so `BRANCH-SUFFIX(lineageId, rootBranchId, fromCounter)` is a well-formed target like any other branch domain.

### 3.2 Identity and Evidence Selectors

These target **hop-local evidence** — a key, a delegate, an attestation, or a historical issuer. They have direct effect while the element is
*presented*; they are not automatically retroactive over descendants that no longer carry it. Reaching those descendants is Section 4.

```text
KEY          reject when the revoked verification method is present in the received transition
DELEGATE     reject when the revoked executor is present in the received transition
ATTESTATION  reject when the revoked attestation is presented as conformance evidence
ISSUER       direct only if originIssuer or an equivalent propagated binding is available
```

When `originIssuer` is propagated (Section 2.1), issuer revocation is a **direct, persistent** selector — `PCA.originIssuer ==
target.issuerId` — not hop-local. When it is not propagated, `ISSUER` is a historical selector and must be resolved into
`LINEAGE-SUFFIX(lineageId, 0)` for the issuer's known lineages (Section 4).

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

### 3.3 Dynamic Restrictions

These restrict *effective* authority without rewriting the signed chain. `AUTHORITY` removes operations; `EXECUTION-CONTRACT` restricts who
or what may continue.

```text
signed operations    = { READ, WRITE }
active restrictions  = { remove WRITE }
effective operations = { READ }
```

A restriction may be scoped to a lineage suffix or a whole grant:

```json
{ "strategy": "AUTHORITY", "target": { "lineageId": "L1", "fromCounter": 42, "operations": ["WRITE"] } }
```

```json
{ "strategy": "AUTHORITY", "target": { "grantId": "G1", "operations": ["WRITE"] } }
```

The normative rules for scope, matching, effective authority, and the empty case are in Section 5.2.

### 3.4 Retrospective Annotation

**`AUDIT-RANGE`** marks a historical interval as compromised, for audit or incident response. It is *not* a forward-validity rule:

```text
PCA0 -> PCA1 -> PCA2 -> PCA3 -> PCA4 -> PCA5
                 [ affected incident interval ]
```

By Lemma 1 of the paper a PCA's validity is the composition of Proofs of Relationship back to PCA0, so no valid suffix can stand above an
invalid segment. The forward consequence of flagging an interval from counter `k` is therefore `LINEAGE-SUFFIX(fromCounter = k)`.

### 3.5 Summary

| Category | Strategies | Direct meaning |
| --- | --- | --- |
| Native causal revocation | `LINEAGE-SUFFIX`, `BRANCH-SUFFIX`, `GRANT` | Directly enforceable from propagated execution coordinates and authenticated revocation state |
| Persistent issuer revocation | direct `ORIGIN-ISSUER`, when `originIssuer` is propagated | Directly enforceable from the propagated origin binding |
| Identity/evidence selector | `KEY`, `DELEGATE`, `ATTESTATION`, resolved `ISSUER` | Blocks presented evidence; historical causal effect requires authenticated resolution and authorized suffix materialization |
| Dynamic restriction | `AUTHORITY`, `EXECUTION-CONTRACT` | Restricts effective authority or conformance without rewriting the signed chain |
| Retrospective annotation | `AUDIT-RANGE` | Marks a historical incident interval; forward invalidity is represented by a suffix cutoff |

## 4. Making Selectors Causal

This section is normative. It defines how an identity/evidence selector (Section 3.2) becomes causal cutoffs that reach descendants no longer
carrying the evidence:

```text
KEY / DELEGATE / ATTESTATION / ISSUER
        |  authenticated historical resolution
        v
affected execution positions:

    (lineageId, counter)
    or, when branchId is authenticated:
    (lineageId, branchId, counter)
        |
        v
authorized native cutoff materialization:

    LINEAGE-SUFFIX  or  BRANCH-SUFFIX
        |
        v
O(1) downstream verification in lineage length
```

Historical resolution produces authenticated execution coordinates. A lineage-only position materializes `LINEAGE-SUFFIX`. A position that
also carries an authenticated `branchId` MAY materialize `BRANCH-SUFFIX` when branch-selective revocation is authorized. The resolver falls
back to `LINEAGE-SUFFIX` when branch identity is unavailable, unauthenticated, or when the entire causal future must be revoked.
`LINEAGE-SUFFIX` crosses branch-domain changes; `BRANCH-SUFFIX` affects only the matching `branchId`.

The ordinary incremental revocation check remains O(1) in lineage length, assuming the applicable revocation state is already authenticated
and indexed. O(1) does not include network retrieval, revocation-state synchronization, historical resolution, batch generation, witness
construction, or index construction. After materialization, the downstream check of `LINEAGE-SUFFIX`, `BRANCH-SUFFIX`, `GRANT`, and indexed
restrictions is O(1) in lineage length.

Three checks are kept separate throughout this section:

```text
Position authenticity:       Did the selector actually occur at this lineage position?
Cutoff authorization:        Is this authority allowed to invalidate the causal future?
Native suffix verification:  Does the current PCA match the authorized lineage and counter cutoff?
```

A key controller is not, by that fact alone, a lineage revocation authority.

### 4.1 Position Witness

A position is proven by a **position witness**; a bare `(lineageId, atCounter)` assertion is not a witness. When a position must be proven, a
valid position witness MUST be one of: a complete signed PCA, an authenticated PCA extract, a snapshot attestation, an authenticated
historical-index record, a Merkle inclusion proof against an authenticated commitment, or a succinct proof. The base illustrative form is a
complete PCA or an authenticated extract:

```json
{
  "lineageId": "L1",
  "atCounter": 7,
  "positionWitness": {
    "type": "SignedPCAExtract",
    "pcaHash": "sha256:…",
    "signedFields": {
      "lineageId": "L1",
      "lineageCounter": 7,
      "branchId": "sha256:…",
      "executor": "did:example:bob",
      "verificationMethod": "did:example:bob#key-1"
    },
    "issuer": "did:example:bob",
    "proof": { "…": "signature or authenticated inclusion proof" }
  }
}
```

The witness MUST cryptographically bind the selector, the `lineageId`, the `lineageCounter`, the PCA content or digest, the witness issuer,
and its own integrity. The Verifier or materializer MUST verify that `witness.lineageId == position.lineageId`, `witness.lineageCounter ==
position.atCounter`, the witness selector equals the revoked selector, the witness cryptographic integrity is valid, and the witness belongs
to the claimed PCA or authenticated history. A hash accompanied by unauthenticated fields MUST NOT be accepted.

**Branch binding.** When a position witness is used to materialize `BRANCH-SUFFIX`, the witness MUST also cryptographically bind the
`branchId` carried by the historical PCA at that position, and the Verifier or materializer MUST additionally verify `witness.branchId ==
position.branchId`. A bare assertion that a known historical position belonged to a given branch domain MUST NOT be sufficient; the witness
MUST prove that the selector occurred at the claimed position, that the position belonged to the claimed lineage, that it carried the claimed
`branchId`, and that it belongs to the authenticated PCA or authenticated history. `branchId` is OPTIONAL in a position witness that supports
only `LINEAGE-SUFFIX`, and mandatory when the result is `BRANCH-SUFFIX`.

**Extract integrity.** A `SignedPCAExtract` is not an arbitrary new object signed by the historical executor. It MUST be one of: a selective
disclosure of fields covered by the original PCA signature, a proof derived from the original signed PCA, or an authenticated extract issued
by a trusted historical index or snapshot authority. A `SignedPCAExtract` MUST prove that the disclosed fields were covered by the original
PCA authentication; a new signature over reconstructed fields is not, by itself, proof that those fields appeared in the historical PCA. This
rule applies even when the signing key is not compromised.

**Compromised-key corroboration.** For a `KEY` revocation caused by actual or suspected compromise, a position witness authenticated only by
the revoked key MUST NOT be sufficient evidence that the claimed position was accepted into the lineage: an attacker controlling the
compromised key could fabricate a PCA or `SignedPCAExtract` that claims an arbitrary `lineageId` and counter. Such a witness MUST be
corroborated by evidence independent of the revoked key:

```text
the valid successor PCA that references the claimed PCA through previousPcaHash,
    where the successor is not authenticated solely by the compromised key
an authenticated historical position index
an authenticated snapshot or checkpoint
a transparency-log inclusion proof
an attestation from an independently trusted materialization authority
an equivalent independent cryptographic proof
```

The simplest causal corroboration is `PCA[k+1].previousPcaHash == H(PCA[k])`. Corroboration proves that the claimed position was *accepted
into the lineage* — whether the acceptance was caused by the legitimate holder or by the compromise adversary; in both cases the position is
real and its causal future warrants the cutoff. Corroboration does not, and need not, prove that the position predates the compromise; that
distinction requires trusted time (Section 5.5), not corroboration. It prevents cutoffs rooted in positions that were never part of the
lineage at all.

Independent corroboration is not universally mandatory. In the **key-compromise case** above it is mandatory. In the **ordinary executor
self-position case**, an uncompromised executor proving its own current position to revoke its continuations MAY use its complete signed PCA
or authenticated extract when the applicable policy recognizes that executor and its key as currently valid. In the **delegate and
attestation cases**, a self-contained signed witness MAY be sufficient only when the signing key is not the evidence being treated as
compromised, the profile accepts that issuer as authoritative for the claim, and the witness is cryptographically bound to the authenticated
lineage. The selected profile MUST define the required independence assumptions.

### 4.2 Cutoff Authorization

Every derived cutoff requires two independent proofs:

```text
1. POSITION AUTHENTICITY  — the selector actually appeared in the named lineage at the stated counter (Section 4.1)
2. CUTOFF AUTHORIZATION    — the party materializing the suffix is authorized to invalidate the causal future from that position
```

The base profile MUST use the conservative model:

```text
identity/evidence revocation
  -> authenticated historical resolution
  -> authorized lineage or grant authority
  -> materialized LINEAGE-SUFFIX
```

**Conservative model (base).** The final `LINEAGE-SUFFIX` is authorized directly by the lineage or grant authority. A position witness is
RECOMMENDED as evidence *during* historical resolution and MAY be omitted from the final suffix object when the authorized materializing
authority has independently established the position; that authority MUST NOT issue a cutoff from an untrusted or unauthenticated position
assertion. The downstream Verifier checks the authorization and target of the resulting native `LINEAGE-SUFFIX` and does not need to
re-evaluate the historical selector witness. The controller of a revoked key is **not** automatically a lineage revocation authority.

**Advanced evidence-authority model.** A profile MAY explicitly authorize a key controller, delegate authority, attestation issuer, or
equivalent evidence authority to invalidate suffixes rooted in proven uses of the revoked evidence. Then a valid position witness MUST
accompany or be cryptographically referenced by every derived cutoff, the witness MUST prove that the revoked selector appeared in the
claimed lineage at the claimed counter, and the profile MUST explicitly define why that evidence authority is also authorized to invalidate
the resulting causal suffix.

In short: a position witness is **mandatory** when the authority to create the cutoff is derived from the proven historical use itself; it is
**recommended, but need not be carried in the final suffix record**, when an independently authorized lineage or grant authority materializes
the cutoff. The provenance of cutoff authorization MUST NOT be left implicit.

### 4.3 Known Positions

A selector MAY carry a bounded set of `knownPositions`. `knownPositions` MUST be OPTIONAL, MUST be bounded by the profile, MUST be used only
for small sets, and MUST NOT be an unbounded array. Each entry MUST be authenticated or resolved through an authenticated process; an inline
or referenced `positionWitness` (Section 4.1) MUST be present when the selected authorization model requires it (Section 4.2). Each authorized
and verified position implies, by default:

```text
LINEAGE-SUFFIX(lineageId = position.lineageId, fromCounter = position.atCounter)
```

When `position.branchId` is cryptographically authenticated, branch-selective materialization is supported by the profile, and the
materializing authority is authorized to revoke that branch domain, the position MAY instead imply:

```text
BRANCH-SUFFIX(lineageId = position.lineageId, branchId = position.branchId, fromCounter = position.atCounter)
```

`LINEAGE-SUFFIX` is used when `branchId` is absent, unauthenticated, or unknown, or when every branch of the lineage must be invalidated;
`BRANCH-SUFFIX` is used only when `branchId` is authenticated and the cutoff is intentionally limited to the selected branch domain. A bare or
unauthenticated `branchId` MUST NOT justify branch-selective materialization. The position-witness requirements of Section 4.1 (including the
branch binding for `BRANCH-SUFFIX`) and the cutoff-authorization requirements of Section 4.2 apply unchanged.

Large sets MUST instead be published as separate `LINEAGE-SUFFIX` records, separate `BRANCH-SUFFIX` records, an authenticated paginable batch,
or an authenticated revocation feed, depending on the authenticated coordinates and authorized scope of each position.

### 4.4 Historical Position Index

A deployment that needs retroactive causal revocation SHOULD keep a minimal index mapping a selector to the positions where it occurred:

```text
bob#key-1
  -> (L1, 1)
  -> (L8, 27)
  -> (L9, 4)
```

which yields `LINEAGE-SUFFIX(L1, 1)`, `LINEAGE-SUFFIX(L8, 27)`, `LINEAGE-SUFFIX(L9, 4)`. The index MUST be authenticated, MUST bind the
selector to the position, and MUST have verifiable integrity; an unauthenticated log MUST NOT be treated as sufficient. It MAY be used to
generate position witnesses. A deployment intending branch-selective materialization SHOULD also record the authenticated `branchId` of each
position; an index that does not record it supports only lineage-wide cutoffs, because Section 4.1 requires an authenticated branch binding
for `BRANCH-SUFFIX` materialization. It is not the full-chain profile, does not require keeping all PCA bytes, and keeps the ordinary
downstream path O(1) after materialization. Retention, access control, and privacy are responsibilities of the deployment or the applicable profile.

### 4.5 Not Carrying Full History

The base incremental profile does not require each PCA to carry the complete list of historical executors, keys, or attestations. Doing so
would cause unbounded growth, larger messages and signatures, correlation, duplicate data, and complex canonicalization. A future extension
MAY instead use a cryptographic accumulator, a Merkle proof, an authenticated index, a transparency log, a snapshot commitment, or a succinct
proof to show historical membership without transporting a full array.

## 5. Revocation Authorization and State

This section is normative.

### 5.1 Who May Revoke

A revocation takes effect only if signed by an authorized issuer; an unauthorized object has no effect. There MUST be a **verifiable
binding** between the revoker and the target — listing who may revoke is not enough, and the binding MUST be provable to the Verifier that
receives the revocation.

| Revoker | May revoke | Binding proven by |
| --- | --- | --- |
| The origin issuer | its own lineage | `AuthorizedLineageRevoker(lineageId, revocation.issuer, revocation.proof)` |
| An executor at counter `k` | `fromCounter = k+1` (its own future); `fromCounter = k` only if policy allows | its own signed PCA or extract, or an authenticated index |
| The branch-domain creator | the branch it created, after its creation point | the branch-creation PCA as position witness + proven authority-continuity with the creator (Section 5.1) |
| The grant authority | the grant and its contract terms | `AuthorizedGrantRevoker(grantId, issuer)` |
| The key controller | that key | control of the verification method |
| The attestation issuer | that attestation | the attestation's issuer signature |

**Origin-issuer authorization.** For the direct origin case, `AuthorizedLineageRevoker` requires both `revocation.issuer == PCA.originIssuer`
and a `revocation.proof` that validates under a currently authorized revocation method for that origin issuer. An identifier match without a
valid proof MUST NOT authorize revocation.

**Counter semantics.** `fromCounter = k` revokes hop `k` *and* its future; `fromCounter = k+1` keeps hop `k` valid and blocks every
continuation. An executor at counter `k` MUST NOT revoke a position upstream of itself unless it separately holds the origin, grant, or
revocation authority, and its position MUST be proven by a position witness, a validated PCA, an authenticated historical index, a snapshot
attestation, or an equivalent cryptographic proof — never by an unproven claim of "its position in the chain".

**Executor self-position.** An executor requesting revocation of its own continuations normally already holds the simplest valid evidence:
the PCA it produced. It MAY prove its position by presenting its complete signed PCA, or an authenticated extract carrying the `lineageId`,
`lineageCounter`, executor identity, and verification method. The proof MUST establish that the PCA is valid, that it belongs to the claimed
lineage, that it carries the claimed counter, and that the revocation issuer controls the executor identity or signing method bound to it:

```json
{
  "type": "ExecutorPositionWitness",
  "pca": {
    "lineageId": "L1",
    "lineageCounter": 42,
    "proofOfRelationship": { "executor": "did:example:bob" },
    "proof": { "verificationMethod": "did:example:bob#key-1", "signature": "…" }
  }
}
```

No external historical index or registry is required in this case; an authenticated index, snapshot, or equivalent proof remains valid when
the original PCA is unavailable, or when another authority materializes the cutoff.

**Grant revocation.** A `GRANT` revocation MUST be accepted only when the Verifier can establish `AuthorizedGrantRevoker(target.grantId,
revocation.issuer)`. The profile MUST define how this predicate is proven — for example a signed grant credential, a grant-authority field
committed in PCA0, an authenticated grant registry, or a profile-defined grant commitment. Possession or knowledge of a `grantId` alone MUST
NOT authorize its revocation.

**Branch revocation.** A `BRANCH-SUFFIX` MUST be accepted only when the revocation issuer is authorized to revoke the targeted branch domain,
expressed as `AuthorizedBranchRevoker(lineageId, branchId, fromCounter, revocationIssuer, revocationProof)`. The profile MUST define how this
binding is proven; possible authorities are the origin issuer (when policy grants branch-wide authority), the grant authority, the
branch-domain creator, or an explicitly delegated branch revocation authority. Proof of branch creation consists of the branch-creation PCA
itself: a valid PCA whose `branchId` correctly derives from its `previousPcaHash` and `branchCreationNonce`, whose signature verifies under
the creator's key, and which carries valid branch-creation authorization (Section 2.4), serving as the position witness.

Current control of the exact historical signing key is not the only permitted proof. The revocation issuer MUST prove continuity with the
identity or authority that issued the branch-creation PCA, which MAY be established by current control of the original signing key, an
authenticated key-rotation or key-successor proof accepted by the profile, a current verification method bound to the same executor identity,
or an equivalent profile-defined authority-continuity proof. The proof MUST preserve continuity with the branch-domain creator. The nonce
proves only that `branchId` was correctly derived from this creation transition; it proves nothing about who was authorized to perform it.
Knowledge of `lineageId`, `branchId`, `branchCreationNonce`, or `fromCounter` MUST NOT by itself authorize branch revocation.

### 5.2 Dynamic Restriction Requirements

A profile that supports dynamic restrictions MUST define the predicate `ApplicableRestriction(restriction, PCA, verificationContext)`,
together with the restriction target syntax, the matching rules, the scope, the precedence, the authority of the restriction issuer, the
composition of multiple restrictions, and the behavior on conflict. The minimal scopes are `lineageId`, `lineageId + fromCounter`, `grantId`,
`originIssuer` (when supported), and resource or tenant in a resource-aware profile. A branch-capable profile that supports dynamic
restrictions MUST additionally support `lineageId + branchId`, and SHOULD support `lineageId + branchId + fromCounter` for restrictions that
begin at a specific causal position within the selected branch domain.

**`AUTHORITY`.** Effective authority subtracts applicable restrictions from the signed authority:

```text
effectiveAuthority(PCA) = signedAuthority(PCA) − ApplicableAuthorityRestrictions(PCA)
```

Non-expansion still compares the *signed* state — `signedAuthority(current) <= signedAuthority(predecessor)` — so a PCA signed before a
restriction does not become malformed; a PCA already attenuated to `{READ}` continues normally after `WRITE` is revoked. The concrete
operation is authorized against `effectiveAuthority(current)`, downstream of chain validation, never as an input to the non-expansion check.
When `effectiveAuthority` is **empty**, the base behavior is: the chain may remain cryptographically and semantically valid but authorizes no
operation. A profile MAY require the hop to be rejected when effective authority is empty, but MUST declare this explicitly.

**`EXECUTION-CONTRACT`.** The effective contract combines the signed contract with applicable restrictions; the profile MUST define the
composition operator and the restrictiveness order.

```text
signed executionModel = { deterministic, agentic }
restriction removes   = { agentic }
effective model       = { deterministic }
```

An agentic executor is rejected; a deterministic one may continue.

**Branch-scoped restrictions.** In a branch-capable profile a restriction MAY be scoped to a branch domain. It applies when:

```text
PCA.lineageId    == restriction.target.lineageId
AND PCA.branchId == restriction.target.branchId
AND ( restriction.target.fromCounter is absent
      OR PCA.lineageCounter >= restriction.target.fromCounter )
```

matching consistently with `ApplicableRestriction`. Both `AUTHORITY` and `EXECUTION-CONTRACT` MAY be branch-scoped:

```json
{ "strategy": "AUTHORITY", "target": { "lineageId": "L1", "branchId": "B1", "fromCounter": 42, "operations": ["WRITE"] } }
```

```json
{ "strategy": "EXECUTION-CONTRACT", "target": { "lineageId": "L1", "branchId": "B1", "fromCounter": 42, "remove": { "executionModel": ["agentic"] } } }
```

The `remove` wrapper makes the restriction direction explicit: the named execution model is removed from the effective execution contract,
not declared as allowed. (`AUTHORITY` needs no wrapper: its `operations` are, by definition, the values removed from effective authority.)

The scopes differ in effect:

```text
BRANCH-SUFFIX                     invalidates the selected branch domain from a position onward
branch-scoped AUTHORITY           removes selected operations from the effective authority of the branch domain
branch-scoped EXECUTION-CONTRACT  restricts which executors, environments, or execution models may continue
                                  within the branch domain
```

Branch-scoped restrictions obey the same authorization, authentication, freshness, rollback-protection, composition, conflict-resolution,
monotonicity, and availability requirements as all other dynamic restrictions. A branch-scoped restriction MUST NOT expand signed authority,
modify the signed PCA, alter Proof of Relationship, alter predecessor uniqueness, or affect sibling branch domains carrying a different
`branchId`. It is applied to effective authority or effective conformance only; signed-state non-expansion MUST continue to compare the
signed current and predecessor states, not the dynamically restricted effective state.

**Branch creation and restriction inheritance.** When a transition creates a new branch domain, all restrictions applicable to the
predecessor domain MUST be evaluated before branch creation, under the anti-escape validation order of Section 2.4. A branch-scoped
restriction may therefore prevent the continuation itself, the use of an operation the transition requires, the selected executor or
execution model, or the creation of a new branch domain, when the applicable effective authority or execution contract no longer permits it.

A newly created branch domain carries a new `branchId`, so a restriction scoped only to the predecessor `branchId` does not automatically
match the new domain after the branch-creation transition has been validly accepted. To restrict the new branch domain, the restriction MUST
be materialized for the new `branchId`, expressed at lineage scope, expressed at grant scope, or inherited through an explicit
profile-defined rule. Any profile-defined inheritance rule MUST be explicit, authenticated, deterministic, and monotonic, and MUST avoid
introducing implicit or unbounded branch ancestry; the base profile SHOULD NOT imply recursive restriction inheritance across branch-domain
changes. Branch-domain scope, lineage-wide scope, and grant-wide scope remain distinct, and sibling branches carrying a different `branchId`
remain unaffected by a branch-scoped restriction unless another applicable lineage-, grant-, or sibling-specific restriction matches them.

Unlike `BRANCH-SUFFIX`, which categorically rejects a matching creation transition under the anti-escape validation order of Section 2.4, a
branch-scoped dynamic restriction affects branch creation through the resulting effective authority or effective execution contract. It may
therefore prevent the transition when the restricted operation, executor, environment, execution model, or branch-creation permission is no
longer allowed. If the creation transition remains permitted and is validly accepted, the new domain does not automatically inherit a
restriction scoped only to the predecessor `branchId`, unless the restriction is separately materialized for the new `branchId` or inherited
through an explicit profile-defined rule. This asymmetry is intentional: it follows from the selected restriction scope and from the absence
of recursive branch ancestry in the base profile.

### 5.3 Monotonicity

Security revocations and restrictions applied to an existing lineage or grant MUST be append-only and MUST become only equally or more
restrictive over time:

```text
effectiveRestrictions(t + 1) is at least as restrictive as effectiveRestrictions(t)
```

under the profile-defined restriction order. A relaxation MUST require a new grant, a new PCA0, and a new lineage. It MUST NOT be implemented
by deleting an existing revocation, replaying an older revocation view, replacing the active state with a less restrictive state, or silently
un-revoking an existing lineage. A temporary operational suspension MAY be defined by a separate profile, but it MUST NOT weaken or remove a
security revocation.

### 5.4 Revocation State and Availability

Revocation state is append-only and identified by a monotonic version or commitment; it MAY be pulled by the Verifier or stapled by the
Prover. A profile MUST specify how the revocation view is authenticated, how freshness is determined, who defines the minimum acceptable
version and how that minimum is authenticated, how rollback is detected, and what happens when revocation state is unavailable. For
unavailability the profile MUST choose one explicitly defined behavior — for example **fail closed**, accept only a fresh stapled proof,
accept within a bounded offline window, or another explicitly defined behavior.

> Short per-hop expiry bounds the interval in which a newly issued revocation may not yet have reached a Verifier, but does not eliminate
> that interval.

### 5.5 Trusted Time and Key Compromise

A self-declared `issuedAt` timestamp cannot prove that a signature was created before key compromise. Known historical positions are
converted into suffix revocations (Section 4). Unknown or newly forged positions are blocked by the direct key-status check when the key is
presented (Section 3.2), not by previously enumerated suffixes. A position witness offered as evidence for a compromised key MUST be
corroborated by evidence independent of the revoked key (Section 4.1); such corroboration establishes that the position was accepted into the
lineage, not that it predates the compromise. A future extension MAY use a trusted timestamp, a transparency log, hardware monotonic time, or
forward-secure signatures.

### 5.6 Limitations

- **Branch domains.** Branch-domain revocation is supported through one fixed-size derived `branchId` (Section 2.4). The base profile does
  not carry recursive branch ancestry. When an authorized nested continuation creates a new branch domain, causal ancestry between the old
  and new branch identifiers requires authenticated historical resolution if revocation must cross that boundary. Nested children that inherit
  the same `branchId` are intentionally revoked as one branch domain. `BRANCH-SUFFIX` is as strong as the branch-domain creation policy;
  `LINEAGE-SUFFIX` strikes every branch of the matching lineage from the selected counter onward and remains the escape-resistant cutoff.
  Sibling branches with different `branchId` values are not struck by a `BRANCH-SUFFIX`.
- **Domain aliasing.** An authorized successor that deliberately reuses another sibling's branch-creation nonce at the same fan-out point
  obtains the same `branchId` and thereby joins that sibling's branch domain, accepting its shared revocation fate. This is voluntary domain
  sharing, not a forgery: it requires branch-creation authorization and the same creation point, and harming the co-domain sibling still
  requires a separately authorized revocation of the shared domain. Deployments that need strict per-successor isolation should rely on
  per-branch authorization policy or `LINEAGE-SUFFIX` granularity.
- **Restriction scope across domain creation.** A dynamic restriction scoped only to one `branchId` does not automatically match descendants
  of a newly created branch domain. The creation transition remains subject to that restriction while it is evaluated in the predecessor
  domain and may be rejected when the resulting effective authority or execution contract does not permit it. If the transition is validly
  accepted, descendants in the new domain are not subject to the predecessor-domain restriction unless it is materialized for the new
  `branchId`, expressed at lineage or grant scope, or inherited through an explicit profile-defined rule (Section 5.2). This does not mean the
  new domain regains authority: it may still be constrained by signed attenuation, lineage-scoped restrictions, grant-scoped restrictions,
  other branch-specific restrictions, and execution-contract restrictions. Issuers that intend a restriction to cover the causal future across
  authorized domain changes SHOULD use lineage or grant scope, or define explicit authenticated inheritance.
- **Privacy.** In the incremental profile, historical executor identities do not travel with the lineage: a Verifier sees the identities and
  evidence of the *presented* transition — the current executor identity, the immediate predecessor identity, and the current transition
  evidence — together with the persistent execution coordinates the profile requires; older executor identities are not carried by default.
  `lineageId`, `grantId`, `originIssuer` (when propagated), and `branchId` (in branch-capable profiles) remain persistent correlators. A
  profile with unlinkability requirements MUST define a privacy-preserving representation or lookup mechanism without weakening revocation
  matching (for example pairwise or blinded identifiers, per-segment commitments, privacy-preserving lookup, or selective disclosure).
  Uniqueness is not mathematically absolute: the derived construction makes intentional cross-branch collision require a hash collision and
  makes accidental collision negligible under the selected security level, and copying a `branchCreationNonce` to a different creation point
  yields a different `branchId` (deliberate reuse at the *same* creation point is the domain-aliasing case above).
- **Incremental visibility.** Direct `KEY`, `DELEGATE`, and `ATTESTATION` see only the evidence in the received transition (Section 3.2);
  reaching the past requires Section 4.

## 6. Counter Capacity

This appendix is non-normative. Exhausting `lineageCounter` requires completing that many *causal* hops on one path:

```text
secondsToOverflow = (2^64 − 1 − currentCounter) / R
    where R = maximum accepted hops per second on one lineage path
```

Each path is causally sequential; fan-out permits several paths but does not parallelize one path. A concrete `R` depends on hardware,
network, and application logic and is not fixed here. Under any realistic per-lineage rate a `uint64` counter is practically inexhaustible,
though a profile that wants the mathematically unbounded case MAY use a CBOR bignum. The normative point is only the one in Section 2.3:
overflow and wraparound are rejected.

The following values are approximate and illustrative, taken at `currentCounter = 0` on one causally sequential path and rounded:

| Accepted hops per second on one path | Approximate time to exhaustion |
| -----------------------------------: | -----------------------------: |
| 1 | about 584 billion years |
| 1,000 | about 584 million years |
| 1,000,000 | about 584 thousand years |
| 1,000,000,000 | about 584 years |

Even under extremely aggressive illustrative rates, the exhaustion horizon remains operationally remote. The table communicates scale, not a
performance claim, and the rates are not deployment benchmarks.

The propagated coordinates support the native predicates: `lineageId` and `lineageCounter` support lineage cutoffs, `branchId` supports
branch-domain cutoffs, and `grantId` supports grant-wide revocation. A frontier accumulator remains an *optional* extension for membership
proofs and cryptographic audit of the prefix.

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
