# **PIC SPEC**

**Version:** 0.1 (Draft)  
**Date:** 2025-12-06  
**Author:** PIC Protocol Contributors  
**Source:** [github.com/pic-protocol/pic-spec](https://github.com/pic-protocol/pic-spec)  
**License:** CC BY 4.0

---

## 1. Introduction

This specification originates from the formalization presented in **"Authority Propagation Models: PoP vs PoC and the Confused Deputy Problem"** [1],
which demonstrates that the confused deputy problem is formally impossible in any execution model satisfying **Provenance Identity Continuity (PIC)**.

As described in **“PIC Model — Provenance Identity Continuity for Distributed Execution Systems”** [2], the PIC Model is grounded in the **Executor-First
Paradigm**, which holds that identity is not a property embedded in static credentials or artifacts, but an emergent invariant of the execution state
and its verifiable causal origin.

The **Provenance Identity Continuity (PIC) Model** specifies the invariants that identity **MUST** satisfy across a complete multi-hop causal execution.
Accordingly, artifact possession is replaced by **execution provenance** as the sole continuity anchor.

Each execution hop **MUST** be treated as part of a verifiable distributed transaction that binds the executor to its causal predecessor. This binding
prevents detachment, impersonation, replay, and unintended authority inheritance commonly observed in token-based and credential-centric systems.

Because continuity is derived from provenance rather than possession, the model supports both identity-centric execution flows and anonymous
capability-based flows. These flows reduce identity leakage, prevent impersonation via transferable credentials, and limit cross-domain replay
vectors while preserving full causal verifiability.

Anonymous capability-based flows are inherently privacy-preserving in multi-hop environments, as they preserve continuity through **Proof of
Continuity** rather than **Proof of Possession**, without exposing identity.

The PIC Model therefore establishes the following **Structural Impossibility Claim (NO-GO Result)**: within any PIC-compliant execution model, the confused
deputy problem cannot arise as a valid execution state.

## 1.1 Normative Language

The key words **MUST**, **MUST NOT**, **REQUIRED**, **SHALL**, **SHALL NOT**, **SHOULD**, **SHOULD NOT**, **RECOMMENDED**, **MAY**, and **OPTIONAL**
in this document are to be interpreted as described in RFC 2119 and RFC 8174 when, and only when, they appear in all capitals.

The following definitions are normative for this specification.

**Executor (Eᵢ)**  
An active execution entity responsible for performing computations at hop *i*.
An Executor acts within a bounded execution context and participates in
causal authority transitions under Provenance Identity Continuity.

**Executor Characteristic (C₍Eᵢ₎)**  
A non-transferable property of an Executor at hop *i* that is bound to its
execution context. Executor Characteristics may include environmental,
platform, or runtime attributes and are used to establish causal linkage,
but do not constitute identity or authority.

**Execution Hop (hop *i*)**  
A discrete execution step within a distributed transaction, representing a
single bounded execution context in which an Executor operates.
An execution hop forms the minimal unit of causal progression in the PIC
Model and is uniquely positioned in the provenance chain by its immediate
causal predecessor and successor.

**Provenance (P)**  
The ordered, non-forgeable history of execution hops and authority derivations
that causally led to a given execution state.

**Distributed Transaction (τ)**  
A causally linked sequence of execution hops forming a single logical
operation across multiple execution contexts. Each hop participates in τ by
verifying continuity with its immediate causal predecessor.

**Causal Authority Transition (CAT)**  
A normative mechanism that enforces Provenance Identity Continuity invariants
by issuing PIC Causal Challenges, verifying Proofs of Continuity, and
deriving subsequent PIC Causal Authority states.

**PIC Causal Authority (PCAᵢ)**  
The causally derived authority available to Executor *Eᵢ* at hop *i*. PIC
Causal Authority represents execution-bound capability and is neither
possessed nor transferable as an artifact.

**PIC Causal Challenge (PCCᵢ)**  
A freshness and causality challenge issued at hop *i* to require a Proof of
Continuity from the Executor. A PIC Causal Challenge does not constitute a
proof and conveys no authority by itself.

**Proof of Continuity (PoCᵢ)**  
A non-forgeable proof produced by Executor *Eᵢ* at hop *i* that demonstrates
causal continuation from the immediately preceding execution hop under
Provenance Identity Continuity.

**Proof of Identity**  
A proof that asserts or validates a claimed identity, typically by
demonstrating control over an identifying artifact. Proofs of Identity are
insufficient to establish authority continuity in PIC-compliant execution
models.

**Proof of Possession**  
A proof that demonstrates control or possession of an artifact, credential,
or secret. Proofs of Possession establish ownership but do not provide
causal continuity or prevent confused deputy scenarios.

## Architecture

xxxx

---

## Appendix A. Use of Automated Language Assistance

The authors have used automated language assistance tools solely to improve grammar, clarity, and phrasing.
All substantive technical content, including the conceptual model, formal results, and proofs, is the exclusive work of the authors.

## References

- [1] Gallo, N. (2025). Authority Propagation Models: PoP vs PoC and the Confused Deputy Problem. Zenodo. [doi.org/10.5281/zenodo.17833000](https://doi.org/10.5281/zenodo.17833000)
- [1] Gallo, N. (2025). PIC Model — Provenance Identity Continuity for Distributed Execution Systems (0.1-draft). Zenodo. [doi.org/10.5281/zenodo.17777421](https://doi.org/10.5281/zenodo.17777421)
