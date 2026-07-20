---
title: "PIC Sandboxed Execution Specification"
abbrev: "PIC Sandboxed Execution"
docname: draft-pic-sandboxed-execution-latest
category: info
ipr: none
submissiontype: independent
stand_alone: yes
smart_quotes: false
pi: [toc, sortrefs, symrefs]
date: 2026-07-20

author:
  - ins: N. Gallo
    name: Nicola Gallo
    org: Nitro Agility S.r.l.

normative: {}
informative: {}
---

--- note_Document_Status

**Version:** 0.2 (Draft)
**Status**: Draft – Not a Standard
**Date:** 2026-07-20
**Source:** [github.com/pic-protocol/pic-spec/draft/0.2/pic-lineage-guardrail-spec.md](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-lineage-guardrail-spec.md)

This revision defines the **Sandboxed Execution**: PIC applied recursively — an outer PIC lineage that carries and governs an inner
Multi-Lineage Execution. It introduces no new PCA type and no trusted sandbox.

--- note_Editors

- **Nicola Gallo** (Nitro Agility S.r.l.) Lead Editor
- *Add your name via pull request (individual or organization) — listing is subject to editor approval (see [Contributors](#contributors)).*

--- note_Contributors

- *Add your name via pull request (individual or organization) — listing is subject to editor approval (see [Contributors](#contributors)).*

--- abstract

This document is the **PIC Sandboxed Execution Specification**, a subordinate specification of the
[PIC Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-spec.md). It retains its historical repository
filename (`pic-lineage-guardrail-spec.md`).

A **Multi-Lineage Execution** carries one or more independent PIC lineages together for one proposed transition. When such a transition must
be validated and controlled by configured policy, that control is itself an execution — and PIC governs it the way it governs any other: as
a lineage.

A **Sandboxed Execution** places the Multi-Lineage Execution inside an ordinary outer PIC lineage. Each **guardrail** is a normal executor
of that outer lineage: it verifies the outer continuation, verifies every carried inner lineage, applies the enforcement function, and — on
permit — proves the next ordinary outer PCA.

No new PCA type is introduced, no trusted sandbox, and no external guardrail authority. The outer lineage is identified only by the
operation `ENFORCE` and by one signed profile field, `multiLineage`, that carries the inner execution. The construction is recursive: an
inner leg may itself be a Sandboxed Execution.

> A Sandboxed Execution is PIC applied recursively: an outer PIC execution carries and governs an inner PIC execution.

Guardrails build on the PCA format of the
[PIC Prover and Verifier Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-prover-verifier-spec.md) and are
consistent with the [PIC Revocation Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-revocation-spec.md);
they do not alter Proof of Relationship, non-expansion, or the rule that every PCA continues exactly one predecessor. In case of conflict,
the **PIC Specification** is authoritative.

--- middle

# Introduction

This section is non-normative. It introduces the three concepts this specification builds on, and the single idea that connects them: PIC
carries PIC.

~~~text
LINEAGE EXECUTION
-----------------
one origin; one predecessor per PCA; non-expansion

MULTI-LINEAGE EXECUTION
-----------------------
n >= 1 independent Lineage Executions carried together

SANDBOXED EXECUTION
-------------------
an outer PIC Lineage Execution carrying a Multi-Lineage Execution
~~~

The whole construction reduces to one picture:

~~~text
Sandboxed Execution
    = outer PIC lineage
      carrying
      inner Multi-Lineage Execution
~~~

The outer lineage applies PIC recursively to the execution that validates and controls the inner execution.

## Lineage Execution

> A **Lineage Execution** is a single-origin PIC execution in which every PCA continues exactly one predecessor under PoR, and authority
> remains bounded by the origin authority context.

- one origin, PCA0;
- every later PCA continues exactly one predecessor, witnessed by PoR;
- non-expansion at every hop, so authority only narrows;
- no authority is imported from another lineage;
- physical executor behavior is outside the protocol guarantee.

~~~text
PCA0-A { READ, BACKUP }
   |
   | PoR + non-expansion
   v
PCA1-A { BACKUP }
   |
   v
NEXT EXECUTOR

One origin. One predecessor per PCA. Authority only narrows.
~~~

The construction — PCA format, Prover, Verifier — is defined by the
[PIC Prover and Verifier Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-prover-verifier-spec.md);
revocation by the [PIC Revocation Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-revocation-spec.md); the
formal model and proofs by the PIC Model [[1]](#references). This document restates none of them.

## Multi-Lineage Execution

> A **Multi-Lineage Execution** carries one or more independent Lineage Executions together for one proposed transition, without merging
> their authorities.

- it carries `n >= 1` independent PIC lineages;
- each lineage remains independently verifiable;
- it has no combined authority of its own;
- it is the execution input carried by the `multiLineage` field (Section 2.4).

~~~text
+======================================+
| MULTI-LINEAGE EXECUTION              |
|                                      |
| leg A: PCA1-A { BACKUP }             |
| leg B: PCA0-B { WRITE-S3 }           |
|                                      |
| authorities remain separate          |
+======================================+

Distinct lineages, one proposed transition.
~~~

## Sandboxed Execution

A **Sandboxed Execution** is a multi-hop outer PIC execution. Its executors are guardrails, and each guardrail continues exactly one
predecessor under the ordinary PIC Proof of Relationship rules:

~~~text
OUTER SANDBOXED EXECUTION

PCA-G[n-1]              PCA-G[n]                PCA-G[n+1]
Guardrail n-1  --PoR--> Guardrail n  --PoR-->  Guardrail n+1
                            |
                            | carries and evaluates
                            v
                     Multi-Lineage Execution
                     [ leg A | leg B | ... ]
~~~

The guardrails are the executors of the outer Lineage Execution. They are not a parallel guardrail chain and do not use a separate
continuity model. The executor at outer hop `n` produces `PCA-G[n]`; the executor at hop `n+1` verifies it as its received predecessor.
Every non-origin PCA continues exactly one predecessor in its own lineage, and inner PCAs are never additional outer predecessors.

Each guardrail:

1. receives an ordinary outer PCA carrying `multiLineage`;
2. verifies the outer PIC continuation;
3. verifies every inner leg;
4. applies the enforcement function;
5. on permit, proves the next ordinary outer PCA;
6. on deny, produces no authorizing continuation for that crossing.

> A **guardrail** is an executor of a Sandboxed Execution: it verifies the outer continuation, verifies the carried inner execution,
> applies the enforcement function, and, on permit, proves the next ordinary outer PCA.

An execution is sandboxed not because a physical boundary forced guardrail invocation, but because the next conforming guardrail accepts and
continues only a valid outer PCA.

> The execution is sandboxed because it can continue **as valid PIC state** only through valid guardrail hops of the outer lineage.

This specification does not prevent a compromised executor from attempting local physical actions outside the signed execution.

## Requirements Notation

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and
"OPTIONAL" are to be interpreted as described in BCP 14 [[2]](#references) [[3]](#references) when, and only when, they appear in all capitals
in normative text. The sections defining `multiLineage`, sandbox origination, the Guardrail Prover and Verifier profile, the operation
profile, Acceptance, Bypass rejection behavior, materializing-guardrail requirements, and Recursion resource limits are normative. The
Abstract, Introduction, explanatory diagrams, examples, and Security Boundary explanations are non-normative unless a requirement is
explicitly expressed using BCP 14 keywords.

# Recursive Execution Model

## Outer and Inner Execution

~~~text
outer execution = Sandboxed Execution
inner execution = Multi-Lineage Execution carried in multiLineage
~~~

The outer execution is an ordinary Lineage Execution with its own PCA0, authority context, PoR chain, execution contract, continuation, and
revocation coordinates. Every inner leg independently has the same PIC structure.

The outer execution does not absorb the inner lineages. It carries them as execution inputs and continues on its own authority, `ENFORCE`.

~~~text
Outer authority  = ENFORCE
Inner lineages   = execution inputs carried for evaluation
Outer authority != union of inner authorities
~~~

## PIC Carrying PIC (PIC of PIC)

The inner execution is already represented by PIC. The execution that validates and controls it is therefore represented by another
ordinary PIC lineage. This is PIC carrying PIC — informally, PIC of PIC.

The guardrail process must itself be controlled, across guardrails not yet known, so the controlled Multi-Lineage Execution becomes the
signed subject of that outer lineage — and the same construction can be nested again.

~~~text
OUTER PIC LINEAGE
PCA-G[n]
|
+-- invariants.operations: [ENFORCE]
+-- executionContract: required next-guardrail properties
+-- multiLineage:
    |
    +-- INNER PIC LEG A
    +-- INNER PIC LEG B
    +-- ...
~~~

~~~text
PCA-G[n-1] --> PCA-G[n] --> PCA-G[n+1]
                   |
                   +-- multiLineage
                         |
                         +-- independently verified PIC legs
~~~

> PIC does not stop at protecting application execution. It can protect the execution that protects application execution.

## Recursive Multi-Lineage Safety

Ordinary PIC prevents authority originating in one Lineage Execution from being represented as a valid continuation of another. Multi-Lineage
Execution preserves this property by carrying independently valid lineages as separate legs rather than creating their authority union.

Sandboxed Execution applies PIC recursively to the process that evaluates their joint participation. The outer lineage carries only
`ENFORCE`; every inner leg retains its own origin authority.

~~~text
OUTER SANDBOXED EXECUTION
authority: { ENFORCE }
|
+-- multiLineage
    |
    +-- LEG A
    |   origin: A
    |   authority: { READ-ALL }
    |
    +-- LEG B
        origin: B
        authority: { BACKUP }

No authority union is created.
~~~

Policy may permit Leg A and Leg B to participate in one concrete transition. Policy does not create `{ READ-ALL, BACKUP }` as a new lineage
authority. Both of the following are rejected by ordinary PIC origin binding and non-expansion:

~~~text
invalid outer authority:
{ ENFORCE, READ-ALL, BACKUP }

invalid Leg B successor:
{ BACKUP, READ-ALL }
~~~

PIC eliminates cross-lineage authority composition from valid PIC state. Sandboxed Execution recursively protects the decision that
determines whether independently valid lineages may participate in one exact transition.

This is a guarantee about valid and accepted PIC state. It does not prove that a compromised executor cannot perform an unauthorized physical
action locally.

## The `multiLineage` PCA Profile Field

`multiLineage` is a signed profile extension of an ordinary PCA, in the same extension style as the revocation coordinates of the
[PIC Revocation Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-revocation-spec.md), Section 2. It carries
one Multi-Lineage Execution; inside it, `legs` is the bounded list of independently verifiable PIC inputs.

~~~json
{
  "multiLineage": {
    "legs": [
      {
        "pca": { "...": "ordinary signed PCA" },
        "predecessor": { "...": "when required by the selected validation profile" },
        "role": "..."
      }
    ],
    "context": {
      "destination": "...",
      "requestsDigest": "sha256:...",
      "payloadDigest": "sha256:...",
      "freshness": "..."
    }
  }
}
~~~

Semantics:

- the whole `multiLineage` field is covered by the outer PCA's ordinary single signature;
- every leg is an ordinary PIC PCA, or the profile-selected proof representation of one;
- each leg keeps its own origin, predecessor relation, authority context, and revocation coordinates;
- legs are never merged;
- the list is bounded by the profile;
- a leg MAY itself contain `multiLineage`; recursion has no special terminal depth in the model;
- implementations MAY impose resource and maximum-depth limits; these are implementation and profile limits, not PIC-semantic changes.

`multiLineage` MUST NOT alter `previousPcaHash`, create additional predecessors, enter `invariants.operations`, import authority from its
legs, or replace PoR, any leg's signature, or any leg's validation.

Exactness. The outer request binding commits to the complete presented `multiLineage`. The Verifier reconstructs the leg set and context
from the presented objects and recomputes every supplied digest; an added, removed, or substituted leg causes rejection.

> Exactness applies to the authenticated Multi-Lineage Execution presented to the guardrail. Detecting inputs hidden before presentation
> requires a profile-defined authenticated input manifest or observation source.

Two distinct functions must not be confused:

~~~text
multiLineage
    carries the complete inner execution

proofOfRelationship.request
    binds the concrete ENFORCE action to the exact multiLineage
~~~

For every non-origin outer PCA, the ordinary `proofOfRelationship.request` MUST contain a cryptographic commitment to the complete canonical
`multiLineage` field carried by that PCA. The request profile contains at least:

~~~text
proofOfRelationship.request.operation
proofOfRelationship.request.target
proofOfRelationship.request.securityDomain       (when applicable)
proofOfRelationship.request.multiLineageDigest
proofOfRelationship.request.policyCommitment
proofOfRelationship.request.inputsCommitment
proofOfRelationship.request.semanticProfile      (when applicable)
proofOfRelationship.request.enforcementResult
proofOfRelationship.request.requestDigest
proofOfRelationship.request.payloadDigest
~~~

This profile does not redefine the base request format
([PIC Prover and Verifier Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-prover-verifier-spec.md),
Section 2.3); it extends the request binding. The PCA signature protects the complete `multiLineage` field as part of the PCA; the request
commitment additionally pins the concrete `ENFORCE` operation to that exact inner execution under the executed-vs-signed rule.

`multiLineageDigest` is mandatory in every non-origin outer PCA and is computed as:

~~~text
request.multiLineageDigest
    ==
H( "PIC-Multi-Lineage-v0" || canonical(PCA.multiLineage) )
~~~

The selected profile MUST define the canonical encoding, hash suite, domain separator, leg ordering and whether it is semantic,
duplicate-leg handling, maximum leg count, treatment of optional fields, normalization rules, and included context fields. `requestDigest`
and `payloadDigest` MAY bind additional material, but MUST NOT replace `multiLineageDigest`. The Verifier MUST reject a missing digest, an
unknown canonicalization profile, a non-canonical field, a digest mismatch, an added, removed, or substituted leg, a forbidden duplicate, a
semantically significant reordering, or a mismatch between the carried context and the committed context.

The decision is recorded only at `proofOfRelationship.request.enforcementResult`, where `enforcementResult` is `permit` or `deny`. It records
the result for the exact `multiLineage`, destination, request, payload, policy, committed inputs, semantic profile, and crossing context
bound by the same outer request. A `permit` MAY appear in an authorizing outer successor; a `deny` MUST NOT authorize continuation. A profile
MAY record a denial for audit, but MUST NOT introduce a denial PCA type or interpret a deny-bearing PCA as permission to cross the governed
boundary.

Evolution across hops. The outer PCA at hop `n` carries the exact inner execution evaluated by guardrail `n`. The next guardrail receives
that signed object and MAY continue the same inner execution or evaluate a profile-valid successor Multi-Lineage Execution.

> A successor outer PCA MUST NOT silently mutate `multiLineage`. If the proposed inner execution changes, the successor request MUST bind the
> complete new `multiLineage`, and every changed leg MUST independently validate as required by its own PIC lineage and the selected profile.

An unchanged inner execution may be re-carried unchanged. An inner leg may continue only through its own valid PIC successor. A removed leg
is not an attenuation of the outer authority; it is a change to the execution input and MUST be visible in the signed request binding. Inner
authority is never silently added, removed, replaced, or imported.

The recursion is structural, not authority composition:

~~~text
PCA
 +-- multiLineage
      +-- leg: PCA
      +-- leg: PCA
      +-- leg: PCA
           +-- multiLineage
                +-- ...
~~~

## Originating the Sandboxed Execution

Three roles are distinct:

~~~text
proposing executor
    proposes the inner Multi-Lineage Execution

authorized sandbox origin
    originates the outer Sandboxed Execution

first guardrail
    creates the first non-origin outer continuation
~~~

A Sandboxed Execution MUST begin with an ordinary origin PCA, `PCA0-G`, created by an authorized sandbox origin. The proposing executor MAY
also be the sandbox origin only when the applicable origination policy explicitly authorizes it to originate that outer lineage. Possession
of the inner PCAs does not authorize creation of `PCA0-G`, and the candidate first guardrail MUST NOT create its own `PCA0-G`.

The authorized sandbox origin may be the protected application, policy governance, a deployment authority, or another origin explicitly
authorized by the applicable origin policy. No special guardrail key or separate guardrail authority is required.

The selected Sandboxed Execution profile MUST define how authorization to originate `PCA0-G` is represented and verified. A valid origin
signature identifies who created `PCA0-G`; it is not, by itself, proof that the issuer was authorized to originate a Sandboxed Execution under
the applicable profile. The authorization evidence MAY be an origin trust policy, an authenticated application or deployment configuration, a
signed origination grant, a policy-governance authorization, an attested origin role, or another profile-defined verifiable mechanism; this
revision mandates none.

`AuthorizedSandboxOrigin(PCA0-G)` means the issuer of `PCA0-G` is authorized, under the selected Sandboxed Execution profile and receiving
deployment policy, to originate an outer lineage with the presented `ENFORCE` authority and execution contract.

`PCA0-G` establishes the outer authority and the future guardrail contract; it does not evaluate the inner execution. It is an ordinary
PCA0 — no predecessor, no PoR, signed by its authorized origin — containing at least:

~~~json
{
  "invariants": {
    "operations": ["ENFORCE"],
    "executionContract": { "...": "properties required of future guardrail executors" }
  },
  "continuation": { "...": "challenge for the first guardrail" }
}
~~~

`PCA0-G` MAY carry an origin-level commitment identifying the execution proposal, but it MUST NOT contain a guardrail verdict.

The first guardrail receives `PCA0-G` and the proposed Multi-Lineage Execution, proves conformance to the `PCA0-G` execution contract,
validates every inner leg, applies the enforcement function, and — on permit — produces the ordinary successor `PCA1-G`.

~~~text
PCA0-G
  establishes ENFORCE authority
  establishes future guardrail contract
  emits the first continuation challenge

PCA1-G
  is produced by the first guardrail
  carries the evaluated multiLineage
  binds the concrete ENFORCE request
  records the permit result
~~~

The complete first sequence:

~~~text
INNER EXECUTION PROPOSAL
Multi-Lineage Execution
[ leg A | leg B | ... ]
          |
          v
AUTHORIZED SANDBOX ORIGIN
PCA0-G
  operations: [ENFORCE]
  executionContract: required guardrail properties
  continuation: challenge for first guardrail
          |
          | PoR
          v
FIRST GUARDRAIL
  verify PCA0-G
  verify every inner leg
  apply enforcement function
          |
       permit
          |
          v
PCA1-G
  ordinary PIC successor
  request.operation: ENFORCE
  request.multiLineageDigest: H(multiLineage)
  multiLineage: exact evaluated inner execution
  request.enforcementResult: permit
  continuation: challenge for next guardrail
          |
          | PoR
          v
NEXT GUARDRAIL
~~~

`PCA1-G`, not `PCA0-G`, is the first outer PCA attributable to a guardrail decision. Subsequent guardrails produce `PCA2-G`, `PCA3-G`, and
so on.

## Guardrail Prover and Verifier Profile

A guardrail performs two nested verification levels over the existing ordinary PIC procedures, then — on permit — proves the next PCA. It
MUST perform the phases in order.

**Phase 1 — Outer PIC verification.** The guardrail acts as an ordinary PIC Verifier for the outer execution:

1. validate the outer predecessor;
2. verify `previousPcaHash`;
3. verify the predecessor continuation challenge;
4. verify the guardrail executor attestation;
5. verify execution-contract conformance;
6. verify outer non-expansion;
7. verify time, freshness, profile, and revocation requirements;
8. verify the outer request operation is `ENFORCE`;
9. recompute and verify the request commitment to the complete `multiLineage`.

**Phase 2 — Inner PIC verification.** Only after Phase 1 succeeds, for every leg:

1. validate the leg using the selected ordinary PIC validation profile;
2. verify its origin or immediate predecessor as required;
3. verify signature and PoR;
4. verify predecessor binding;
5. verify non-expansion;
6. verify request binding and executed-vs-signed requirements;
7. verify execution-contract conformance;
8. verify freshness and time;
9. verify revocation coordinates and active revocation state.

Any invalid outer check or inner leg produces deny before policy evaluation.

**Phase 3 — Enforcement function.** Over the validated inner execution and the exact crossing context, the guardrail evaluates the
profile-defined enforcement function. A PDP is only one possible implementation.

> The profile defines the required enforcement result and its signed inputs. It does not require a specific PDP, policy language, vendor,
> process boundary, or deployment topology.

Every leg-describing input used by the enforcement function MUST be cryptographically or operationally bound to the corresponding leg by a
mechanism that is not under the unilateral control of the executor whose execution is being evaluated. This includes, when used, `role`,
semantic scopes, labels, data classifications, tenant or security-domain claims, accountable-party claims, environment claims, application
identity, purpose or intent metadata, policy-selection metadata, and translation or semantic-profile identifiers. Accepted binding mechanisms
MAY include origin-bound signed metadata, signed declarations from an accepted authority, trusted derivation from validated PCA contents,
policy-controlled mappings, authenticated deployment configuration, attested execution context, verified external attributes, or
profile-defined authenticated manifests.

An untrusted executor's claim alone MUST NOT be sufficient as an enforcement input. The enforcement function MUST evaluate only inputs whose
source, binding, interpretation profile, and integrity satisfy the selected Sandboxed Execution profile. An input required by policy that is
unauthenticated, ambiguously bound, semantically unmapped, inconsistent with the presented PCA, unavailable, or controlled only by the
proposing executor MUST produce deny or indeterminate-deny.

Failure, unavailable policy, indeterminate result, inconsistent semantic mapping, or missing committed inputs produce deny.

**Phase 4 — Outer proving.** On permit, the guardrail produces the next ordinary outer PCA under the standard PIC Prover procedure. It MUST:

1. identify exactly one outer predecessor;
2. produce valid PoR;
3. retain or attenuate `ENFORCE`;
4. preserve or strengthen the execution contract;
5. carry the exact evaluated `multiLineage`;
6. bind its canonical digest in the request;
7. bind the enforcement inputs and permit result;
8. emit a fresh continuation;
9. sign the complete PCA once.

No additional approval signature is created. The next guardrail repeats the same procedure — and that repetition is the sandbox.

~~~text
receive outer PCA
      |
Phase 1: validate outer PIC continuation
      |
Phase 2: validate every inner PIC leg
      |
Phase 3: apply enforcement function
      |
   permit?
   /    \
 no      yes
 X       Phase 4: build and sign next ordinary outer PCA
~~~

**Hop-specific result.** An enforcement result is hop-specific. A `permit` in `PCA-G[n]` applies only to the exact execution bound by that
PCA — its `multiLineage`, destination, requests, payload commitments, policy commitment, input commitment, semantic profile, and crossing
context. It does not authorize `PCA-G[n+1]`, a later crossing, a changed destination, a changed payload, a changed policy, a modified
`multiLineage`, or any physical action not bound by the request.

~~~text
PCA-G[n]
permit for exact crossing X
        |
        v
does not imply
        |
        v
PCA-G[n+1]
permit for crossing Y
~~~

Every later guardrail MUST verify the received outer continuation, verify the exact carried inner execution, evaluate the enforcement
function applicable to that hop, produce its own signed result, and produce a new ordinary outer continuation only on permit.

## Operation Profile

This revision uses one operation class, `ENFORCE`:

- it means: validate the carried Multi-Lineage Execution, apply the enforcement function, and decide whether the outer execution may
  continue;
- it grants none of the authority carried by the inner legs;
- it is subject to ordinary PIC non-expansion: the outer lineage MAY retain or attenuate it, never add broader operations.

Future revisions MAY define additional recursive-control operation classes, using the same ordinary PCA, PoR, and profile-extension model.

# Acceptance

Two checks are separate: `ENFORCE` must belong to the outer authority context, and the concrete executed request must be `ENFORCE`.

~~~text
ENFORCE in PCA-G[n].invariants.operations                    (authority)
PCA-G[n].proofOfRelationship.request.operation == ENFORCE    (executed action)
~~~

For every non-origin outer hop, both MUST hold. A conforming guardrail or receiving outer executor MUST accept the outer continuation only
if:

~~~text
ValidOuterPIC(PCA-G[n-1], PCA-G[n])
AND ValidSandboxOriginForSelectedProfile
AND ENFORCE in PCA-G[n].invariants.operations
AND PCA-G[n].proofOfRelationship.request.operation == ENFORCE
AND PCA-G[n].proofOfRelationship.request.multiLineageDigest
      == H(canonical(PCA-G[n].multiLineage))
AND ValidMultiLineage(PCA-G[n].multiLineage)
AND ExactPresentedExecutionBinding
AND EnforcementResult == permit
AND Fresh
AND NotRevoked
~~~

For `PCA0-G`, only the ordinary PCA0 origin validation and the presence of `ENFORCE` in its origin authority context apply; it has no PoR
request.

Origin authorization is part of acceptance. For a full-chain profile:

~~~text
ValidSandboxOrigin(PCA0-G)
    =
ValidOrdinaryPCA0(PCA0-G)
AND AuthorizedSandboxOrigin(PCA0-G)
~~~

For an incremental profile, authorization of the sandbox origin is established inductively from the authenticated validation state accepted
by the selected chain-validation profile; a deployment MAY additionally require direct evidence of `PCA0-G`, an authenticated checkpoint, a
Trust Plane validation, a full-chain proof, or a succinct proof. Not every incremental receiver carries `PCA0-G`.

A receiving deployment MAY restrict the sandbox origins it accepts and MAY require a minimum outer execution contract. Such restrictions
narrow acceptance; they do not create outer authority.

`ValidMultiLineage` means every presented leg validates independently under its own PIC lineage and selected validation profile.

The receiving component MUST recompute all digests and MUST reject:

- a missing `multiLineage`;
- an invalid outer continuation;
- an invalid inner leg;
- an added, removed, or substituted presented leg;
- a mismatched request, destination, or payload;
- an invalid policy or input commitment;
- a non-permit decision;
- stale, replayed, or revoked state.

This profile adds no second signature system: guardrail approval is the ordinary outer PCA signature, nothing else. Each `permit` is
hop-specific: it authorizes only the exact crossing bound by its own outer PCA, never a later hop or a changed crossing.

# Bypass

A sender may physically present the inner execution without a valid outer continuation. The next conforming guardrail rejects it because the
required Sandboxed Execution lineage is absent or invalid.

~~~text
BYPASS ATTEMPT

sender ---- inner Multi-Lineage only ----> next conforming guardrail
                                           reject:
                                           no valid outer continuation
~~~

> The failure is not prevented at the faulty hop; it is blocked at the next conforming one.

## Non-PIC-Aware Target

A non-PIC-aware target cannot verify the outer Sandboxed Execution. For such a target, the final hop of the Sandboxed Execution is the
**materializing guardrail** — an ordinary executor of the outer lineage that performs the exact physical action permitted by its own bound
outer request.

It MUST:

1. validate its outer predecessor;
2. validate every inner leg;
3. evaluate the enforcement function;
4. produce or complete the ordinary outer PCA for the exact action;
5. materialize exactly the bound action;
6. use the bound destination, request, payload, participants, and context;
7. prevent post-decision substitution within its own implementation.

After the decision, control of the materialized target operation does not return to the proposing executor.

~~~text
proposing executor
      |
      | proposed Multi-Lineage Execution
      v
materializing guardrail
      |
      | validates outer PIC
      | validates inner legs
      | evaluates enforcement
      | physically performs exact permitted action
      v
non-PIC-aware target
~~~

The materializing guardrail is not a new trusted authority, a special PCA type, a required service mesh, a universal gateway, or a
protocol-level physical sandbox; it remains an ordinary executor of the outer PIC lineage. PIC does not prevent all direct physical access to
a non-PIC-aware target: ensuring that the target cannot also be reached through unrelated credentials, alternate routes, or physical access
remains a deployment responsibility, addressed by the
[PIC Architecture and Deployment Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-architecture-deployment-spec.md).

## Consecutive Collusion

A sender colluding with a receiving hop that deliberately ignores the Sandboxed Execution profile is a non-conforming or consecutive-collusion
case under the [PIC Prover and Verifier Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-prover-verifier-spec.md).
Detection beyond the colluding pair depends on the selected chain-validation profile and the authenticated history available to the later
Verifier: a full-chain, Trust Plane, authenticated-checkpoint, or approved succinct-proof profile may detect the invalid prefix according to
its guarantees, while an incremental Verifier without authenticated evidence of the earlier prefix has the consecutive-collusion limitation
already documented by that specification (Section 6.8). Sandboxed Execution introduces no new failure class.

# Recursion

The model is recursively closed. No special root guardrail object exists, and no new trust primitive appears at deeper levels.

~~~text
PCA outer
 +-- multiLineage
      +-- PCA inner A
      +-- PCA inner B
           +-- multiLineage
                +-- deeper PIC execution
~~~

At every level:

- the same ordinary PCA structure is reused;
- the same PoR semantics are reused;
- the same non-expansion semantics are reused;
- validation recursively invokes the appropriate PIC Verifier profile;
- each level has exactly one predecessor in its own lineage;
- an inner PCA is never an additional predecessor of the outer PCA;
- no authority flows upward from inner lineages.

At every recursive level the same separation holds: one predecessor in the local lineage, origin-bounded authority, ordinary PoR, ordinary
non-expansion, exact request binding, and independent revocation.

~~~text
LEVEL 0
outer PCA { ENFORCE }
|
+-- multiLineage
    |
    +-- LEVEL 1 / Leg A
    |   PCA { READ }
    |
    +-- LEVEL 1 / Leg B
        PCA { ENFORCE }
        |
        +-- multiLineage
            |
            +-- LEVEL 2 / Leg C
                PCA { WRITE }
~~~

Nesting adds execution structure. It does not create authority inheritance between recursive levels.

The model is recursively composable to arbitrary finite depth — not literal infinite execution. Implementations MUST bound maximum recursion
depth, leg count, encoded size, and total validation work. Resource limits cause rejection or indeterminate-deny according to the profile;
they do not change PIC semantics.

# Security Boundary

## Model Guarantee

Within the accepted model:

- an outer hop without valid PoR cannot continue;
- an unauthorized guardrail cannot become a valid successor;
- the outer authority cannot expand beyond `ENFORCE`;
- an invalid inner PCA causes rejection;
- a different inner execution cannot be substituted without invalidating the signed binding;
- skipping guardrails cannot produce a valid outer continuation.

This specification adds no independent trust primitive. The trusted elements remain those already required by the PIC Prover and Verifier
model: Verifier correctness, origin trust boundaries, sandbox-origin authorization, attestation issuers, canonicalization and hash profiles,
revocation-state authenticity and freshness, cryptographic primitives, and the physical correctness of any materializing implementation.
Sandboxed Execution changes the anchor of enforcement, not the kind of trust assumed: enforcement is represented as an ordinary PIC
continuation checked by the next conforming outer executor. Trust is not eliminated; no special trusted sandbox or independently recognized
guardrail authority is added.

## Implementation Failure

The guarantee can fail physically if cryptographic primitives fail, keys or attestation issuers are compromised, a Verifier omits required
checks, an executor performs a different physical action from the signed one, or canonicalization or digest construction is implemented
incorrectly. These break the implementation or its assumptions, not the model.

## Semantic Divergence

The enforcement function may be incorrect, dishonest, or semantically divergent. Signing the policy identifier, version, input commitments,
semantic profile, and result makes the decision attributable and checkable. PIC proves the continuity and integrity of that decision; it
does not prove that a human policy or its interpretation is correct.

# Model Summary

~~~text
LINEAGE EXECUTION
one origin;
one predecessor per PCA;
authority never expands.

MULTI-LINEAGE EXECUTION
independent lineages participate together;
their authorities are never merged.

SANDBOXED EXECUTION
an outer ENFORCE lineage carries the Multi-Lineage Execution;
each guardrail verifies and continues that outer lineage.

PIC CARRYING PIC — PIC OF PIC
the execution that validates PIC execution
is itself represented and protected by PIC.
~~~

The result is recursive execution safety: independently originated authorities may participate in one evaluated transition without becoming
one authority state, and the evaluation process itself continues only as valid PIC state.

Physical executor behavior, implementation failure, cryptographic compromise, unavailable authenticated history, and policy-semantic error
remain at the stated boundaries of the model.

# Contributors {#contributors}

The editors and contributors of this document are listed in the **document header** above. Listing is governed by Appendix B.7 of the
[PIC Legal Appendices](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-legal.md).

# Legal Notices

The appendices governing:

- **A.** Use of Automated Language Assistance,
- **B.** Authorship, Stewardship, Attribution, and Derivative Works,
- **C.** Disclaimer and Limitation of Liability,
- **D.** Acknowledgements,

are maintained in a single canonical document, the **[PIC Legal Appendices](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-legal.md)** (`draft/0.2/pic-legal.md`), and are
**incorporated into this specification by reference** as if fully set forth herein.

In case of conflict between this document and the PIC Legal Appendices, the PIC Legal Appendices prevail for legal, governance, licensing,
and attribution matters.

This specification is subordinate to the [PIC Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-spec.md), which defines the normative semantics of the PIC Model and is
the entry point of the specification set. This document does not introduce new conceptual authority, invariants, or authorship claims beyond
those defined in the PIC Legal Appendices.

# References {#references}

- [1] Gallo, N. (2026). *Proof-of-Continuity: A Temporal Model for Authority Propagation in Distributed Systems and AI Agents*. arXiv:2607.08906 [cs.CR]. [arxiv.org/abs/2607.08906](https://arxiv.org/abs/2607.08906)
- [2] Bradner, S. (1997). *Key words for use in RFCs to Indicate Requirement Levels*. BCP 14, RFC 2119. [rfc-editor.org/rfc/rfc2119](https://www.rfc-editor.org/rfc/rfc2119)
- [3] Leiba, B. (2017). *Ambiguity of Uppercase vs Lowercase in RFC 2119 Key Words*. BCP 14, RFC 8174. [rfc-editor.org/rfc/rfc8174](https://www.rfc-editor.org/rfc/rfc8174)
