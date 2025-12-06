# **PIC SPEC**

**Version:** 0.1 (Draft)  
**Date:** 2025-12-06  
**Author:** PIC Protocol Contributors  
**Source:** https://github.com/pic-protocol/pic-spec  
**License:** CC BY 4.0

---

## 1. Introduction

This specification originates from the formalization presented in **"Authority Propagation Models: PoP vs PoC and the Confused Deputy Problem"** [[1]](#references), which demonstrates that the confused deputy problem is formally impossible in any execution model satisfying `Provenance Identity Continuity (PIC)`.

As described in **“PIC Model — Provenance Identity Continuity for Distributed Execution Systems”** [[2]](#references), the PIC Model is grounded in the `Executor-First Paradigm`, which holds that identity is not a property embedded in static credentials or artifacts, but an emergent invariant of the execution state and its verifiable causal origin.

The `Provenance Identity Continuity (PIC) Model` specifies the invariants that identity **MUST** satisfy across a complete multi-hop causal execution. Accordingly, artifact possession is replaced by `**`execution provenance** as the sole continuity anchor.

Each execution hop **MUST** be treated as part of a verifiable distributed transaction that binds the `Executor` to its causal predecessor. This binding prevents detachment, impersonation, replay, and unintended authority inheritance commonly observed in token-based and credential-centric systems.

Because continuity is derived from provenance rather than possession, the model supports both identity-centric execution flows and anonymous capability-based flows. These flows reduce identity leakage, prevent impersonation via transferable credentials, and limit cross-domain replay vectors while preserving full causal verifiability.

Anonymous capability-based flows are inherently privacy-preserving in multi-hop environments, as they preserve continuity through `Proof of Continuity` rather than `Proof of Possession`, without exposing identity.

The PIC Model therefore establishes the following `Structural Impossibility Claim (NO-GO Result)`: within any PIC-compliant execution model, the confused deputy problem cannot arise as a valid execution state.

---

## 1.1 Normative Language

The key words **MUST**, **MUST NOT**, **REQUIRED**, **SHALL**, **SHALL NOT**, **SHOULD**, **SHOULD NOT**, **RECOMMENDED**, **MAY**, and **OPTIONAL** in this document are to be interpreted as described in RFC 2119 and RFC 8174 when, and only when, they appear in all capitals.

---

## 1.2 Model Conventions

Throughout this specification, indices denote execution hops. All terms subscripted with *i* (e.g., Hopᵢ, Eᵢ, PCAᵢ, PCCᵢ, PoCᵢ) refer to the same execution hop. The predecessor and successor execution hops are denoted by indices *i−1* and *i+1*, respectively.

Textual references such as “hop *i*” refer to the execution hop denoted formally as **Hopᵢ**.

---

## 1.3 Terminology

The following definitions are normative for this specification.

**Execution Hop (Hopᵢ)**  
A discrete execution step within a distributed transaction, representing a single bounded execution context in which an Executor operates. An execution hop forms the minimal unit of causal progression in the PIC Model and is uniquely positioned in the provenance chain by its immediate causal predecessor and successor.

**Executor (Eᵢ)**  
An active execution entity responsible for performing computations at hop *i* (Hopᵢ). An Executor acts within a bounded execution context and participates in causal authority transitions under Provenance Identity Continuity.
Each Executor **MUST** be associated with an identity and be capable of producing a valid `Proof of Identity (PoI)` and `Proof of Possession (PoP)`.
These proofs establish executor identity and control, but **DO NOT** grant or propagate authority, nor establish execution continuity in PIC-compliant models.

**Executor Characteristic (ECᵢ)**  
A non-transferable property of an Executor at hop *i* that is bound to its execution context. Executor Characteristics may include environmental, platform, or runtime attributes and are used to establish causal linkage, but do not constitute identity, authority, or policy input.

**Provenance (P)**  
The ordered, non-forgeable history of execution hops and authority derivations that causally led to a given execution state.

**Distributed Transaction (τ)**  
A causally linked sequence of execution hops forming a single logical operation across multiple execution contexts. Each hop participates in τ by verifying continuity with its immediate causal predecessor.

**Causal Authority Transition (CAT)**  
A normative mechanism that enforces Provenance Identity Continuity invariants by issuing PIC Causal Challenges, verifying Proofs of Continuity, and deriving subsequent PIC Causal Authority states.

**PIC Causal Authority (PCAᵢ)**  
The causally derived authority available to Executor *Eᵢ* at hop *i*. PIC Causal Authority represents execution-bound capability and is neither possessed nor transferable as an artifact.

**PIC Causal Challenge (PCCᵢ)**  
A freshness and causality challenge issued at hop *i* to require a Proof of Continuity from the Executor. A PIC Causal Challenge does not constitute a proof and conveys no authority by itself.

**Proof of Continuity (PoCᵢ)**  
A non-forgeable proof produced by Executor *Eᵢ* at hop *i* that demonstrates causal continuation from the immediately preceding execution hop under Provenance Identity Continuity.

**Proof of Identity (PoI)**  
A proof that asserts or validates a claimed identity, typically by demonstrating control over an identifying artifact. Proofs of Identity are insufficient to establish authority continuity in PIC-compliant execution models.

**Proof of Possession (PoP)**  
A proof that demonstrates control or possession of an artifact, credential, or secret. Proofs of Possession establish ownership but do not provide causal continuity or prevent confused deputy scenarios.

---

## 2. Provenance Identity Continuity Model

This section defines the execution semantics enforced by the Provenance Identity Continuity (PIC) Model. The PIC Model does not prescribe a system architecture, deployment topology, trust boundary, or specific protocol implementation. Instead, it defines causal invariants that MUST hold for any execution to be considered valid. Execution is modeled as a sequence of causally linked execution hops forming a distributed transaction, where authority is never assumed implicitly and continuity must be re-established explicitly at every hop boundary.

---

## 2.1 Execution Hop Semantics

An execution hop represents a causally isolated execution context within a distributed transaction. A hop defines the scope in which authority is exercised, consumed, and constrained, but not created or propagated. An execution hop is not a process, service, or container; it is a logical unit of execution whose validity is determined solely by its position in the provenance chain.

At hop *i* (formally **Hopᵢ**), execution is performed by a single Executor **Eᵢ** operating under `PIC Causal Authority (PCAᵢ)` derived exclusively from the immediately preceding hop **Hopᵢ₋₁**. Authority available at Hopᵢ is valid only as a causal continuation and cannot be inherited by unrelated executions, replayed outside its causal context, substituted via credentials or tokens, or reintroduced by external systems.

Within Hopᵢ, the Executor **MAY** perform any action permitted by PCAᵢ and constrained by applicable policy, but **MUST NOT** derive new authority, expand authority scope, or assert continuity beyond the current hop. Completion of execution at Hopᵢ does not, by itself, authorize execution at a subsequent hop. Progression beyond Hopᵢ requires an explicit causal transition that validates continuity and derives new authority under the PIC invariants.

---

## 2.2 Causal Authority Transition Semantics

A `Causal Authority Transition (CAT)` governs the progression from one execution hop to the next. The CAT is a logical mechanism that enforces Provenance Identity Continuity by mediating challenge issuance, continuity verification, policy evaluation, and authority derivation across hop boundaries. The CAT is not an architectural component or centralized service and may be implemented in-process, externally, or implicitly by a runtime environment, provided the PIC invariants are preserved.

The following diagram illustrates the causal relationship between execution hops and the role of the Causal Authority Transition. The dashed vertical line denotes an execution boundary and represents a causal separation, not a network, trust, or deployment boundary.

```text
                ┌────────────────────────┐
                │   Previous Execution   │
                │        Hopᵢ₋₁          │
                └───────────┬────────────┘
                            │
                            │  PIC Causal Authority (PCAᵢ)
                            ▼
┌─────────────────────────────────────────────┐
│                 Execution Hop Hopᵢ          │
│                                             │
│   ┌──────────────┐       PCCᵢ               │    ┌─────────────┐   
│   │   Executor   │◀─────────────────────────┼────│     CAT     │
│   │      Eᵢ      │──────────────────────────┼───▶│      E      │
│   └──────┬───────┘       PoCᵢ               │    └──────┬──────┘
│          │                                  │           │       
│          │        consumes PCAᵢ             │           │       
│          └──────────────────────────────────┼───────────┘       
│                                             │
└──────────────────────────┬──────────────────┘
                           │
                           │  PIC Causal Authority (PCAᵢ₊₁)
                           ▼
                ┌────────────────────────┐
                │     Next Execution     │
                │        Hopᵢ₊₁          │
                └────────────────────────┘
```

To initiate a transition from Hopᵢ to Hopᵢ₊₁, the CAT issues a `PIC Causal Challenge (PCCᵢ)` that establishes freshness and binds the transition to the specific execution context of Hopᵢ. In response, Executor **Eᵢ** produces a `Proof of Continuity (PoCᵢ)` demonstrating that execution at Hopᵢ is a valid causal continuation of Hopᵢ₋₁ and that authority has not been detached, replayed, or substituted.

The CAT **MUST** validate PoCᵢ against the provenance and authority state associated with Hopᵢ₋₁. The CAT **MUST** also evaluate applicable authorization policies. Policy evaluation **MAY** be performed by a distinct `Policy Decision Point (PDP)` or **MAY** be integrated directly within the CAT itself. In all cases, policy evaluation **MUST NOT** replace causal validation and **MUST NOT** introduce new authority independently of continuity; policies may only constrain, deny, or reduce authority derived through causal mechanisms.

If both causal validation and policy evaluation succeed, the CAT derives a new `PIC Causal Authority (PCAᵢ₊₁)` bound exclusively to the successor execution hop **Hopᵢ₊₁**. The derived PCAᵢ₊₁ defines the maximum authority available at the next hop and is non-transferable, non-replayable, and invalid outside of its causal context.

No execution at Hopᵢ₊₁ **MAY** occur without a successfully completed Causal Authority Transition. Any execution that bypasses challenge issuance, continuity verification, or policy evaluation violates Provenance Identity Continuity and cannot arise within a PIC-compliant execution model.

---

## 3. Data Mode

xxxx

---

## 4. Integration with Existing IAM Systems

This section describes how the PIC Model integrates with existing Identity and Access Management (IAM) systems by reinterpreting **configuration** and authorization artifacts as **execution entry conditions** rather than as transferable sources of authority. The intent of this section is explanatory and informative. It does not introduce new invariants beyond those defined by the PIC Model, but clarifies how existing IAM, policy, and configuration models map into PIC semantics.

---

## 4.1 Configuration as an Entry Condition

In traditional IAM systems, configuration artifacts such as **roles**, **trust relationships**, **policy bindings**, and **service identities** are commonly treated as direct or implicit sources of authority. Possession of a valid configuration-backed credential is generally sufficient to exercise the authority it represents, independent of how execution proceeds afterward.

In the **PIC Model**, configuration does **NOT** directly grant authority. Instead, configuration defines the **boundary conditions under which execution is permitted to begin**. Configuration artifacts establish the maximum potential scope of authority but **MUST NOT** authorize its use beyond the execution context in which they are evaluated.

Formally, the PIC Model interprets configuration as part of an **entry condition**, not as authority:

Configuration + Identity + Possession ⇒ `Entry Condition`

An `Entry Condition` allows an **Executor** to participate in the first execution hop of a distributed transaction, but it **MUST NOT** permit authority to propagate across execution boundaries without continuity verification.

This reinterpretation preserves the semantics of existing IAM configuration while eliminating authority detachment, replay, and unintended reuse.

---

## 4.2 Entry Conditions and Execution Initialization

When an IAM authorization decision succeeds, the resulting **configuration** and **possession state** enables an Executor to enter the initial **execution hop** of a distributed transaction. At this point, **Proof of Identity (PoI)** and **Proof of Possession (PoP)** establish that the Executor is legitimate and acting under valid credentials derived from configuration.

However, **no authority is assumed beyond the initial execution boundary**. Configuration artifacts **MUST NOT** be embedded into execution as capabilities, tokens, or transferable grants of authority. Instead, they act as static constraints that define which executions may begin, not how authority continues.

In PIC terms, configuration and possession together form an `Entry Condition` that is consumed at execution start. Any authority exercised beyond this point **MUST** be derived causally and **MUST NOT** be attributed to configuration alone.

---

## 4.3 Execution Continuity and Authority Derivation

After execution has begun, the **PIC Model** enforces **authority continuity** independently of IAM configuration. Each subsequent execution hop **MUST** be causally derived from the previous hop through a `Causal Authority Transition (CAT)`. Authority exists only as a function of verified continuity and **MUST NOT** be recreated, inherited, or replayed from configuration state.

This relationship can be expressed as:

`Entry Condition` + Continuity ⇒ Authority

**Proofs of Continuity (PoC)** bind execution hops together and ensure that authority remains attached to the execution that originally satisfied the entry condition. Even when configuration-backed credentials remain valid, execution **MUST NOT** advance without demonstrating continuity.

Authorization policy evaluation **MAY** further constrain or deny authority at a transition, but policy evaluation **MUST NOT** replace causal validation and **MUST NOT** introduce authority independently of continuity. Policy constrains authority; it does not create it.

---

## 4.4 IAM and PIC Integration Overview

The following diagram illustrates how **configuration**, IAM authorization, and PIC continuity integrate into a single execution model. IAM and configuration establish the `Entry Condition`, while PIC governs execution continuity and authority derivation across execution hops.

```text
        ┌────────────────────────────────────┐
        │          Configuration             │
        │ (Roles, Policies, Trust, Identity) │
        └──────────────────┬─────────────────┘
                           │
           Proof of Identity│ Proof of Possession
                           ▼
        ┌────────────────────────────────────┐
        │           Entry Condition          │
        │  (Authorized to begin execution)   │
        └──────────────────┬─────────────────┘
                           │
                           │  Execution begins
                           ▼
        ┌────────────────────────────────────┐
        │         Execution Hop Hopᵢ         │
        │            Executor Eᵢ             │
        └──────────────────┬─────────────────┘
                           │
               PCCᵢ / PoCᵢ │   Causal Authority Transition
                           ▼
        ┌────────────────────────────────────┐
        │     PIC Continuity Enforcement     │
        │               (CAT)                │
        └──────────────────┬─────────────────┘
                           │
                           │  PIC Causal Authority (PCAᵢ₊₁)
                           ▼
        ┌────────────────────────────────────┐
        │        Next Execution Hop          │
        │               Hopᵢ₊₁               │
        └────────────────────────────────────┘
```

In this model, **configuration and IAM** determine whether execution may begin, while **PIC** determines whether execution may continue. This preserves existing IAM semantics while enforcing strong guarantees on authority continuity.

---

## 4.5 Service Mesh and Gateway Integration

Service meshes, API gateways, and inter-service proxies operate directly in the **execution path** and therefore participate in execution continuity rather than entry authorization. Unlike IAM systems, which evaluate configuration at entry points, these components define execution hop boundaries and **MUST** be **continuity-native**.

A mesh or gateway that forwards execution based solely on possession of a configuration-backed token introduces a break in continuity. Therefore, in a PIC-compliant environment, service meshes and gateways **MUST** preserve, verify, and propagate **Proofs of Continuity**, either by embedding `CAT` logic directly or by invoking a tightly coupled continuity verifier.

---

## 4.6 Relationship to Existing Models

The PIC Model does not replace IAM, policy languages, or configuration systems. It **reclassifies their role**. Configuration defines the conditions under which execution may begin. Authority exists only as a consequence of causal continuation.

This separation enables incremental adoption of PIC in existing systems while eliminating confused deputy scenarios that arise from treating configuration artifacts as transferable authority.

Execution may begin because it is authorized by configuration, but it may continue **only because it is causally valid**.

---

## Appendix A. Use of Automated Language Assistance

The authors have used automated language assistance tools solely to improve grammar, clarity, and phrasing. All substantive technical content, including the conceptual model, formal results, and proofs, is the exclusive work of the authors.

---

## References

- [1] Gallo, N. (2025). *Authority Propagation Models: PoP vs PoC and the Confused Deputy Problem*. Zenodo. https://doi.org/10.5281/zenodo.17833000  
- [2] Gallo, N. (2025). *PIC Model — Provenance Identity Continuity for Distributed Execution Systems (0.1-draft)*. Zenodo. https://doi.org/10.5281/zenodo.17777421
