# **PIC PROTOCOL**

**Version:** 0.1  
**Status**: Draft – Not a Standard  
**Date:** 2025-12-06  
**Source:** [github.com/pic-protocol/pic-spec/draft/0.1/pic-protocol.md](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.1/pic-protocol.md)

---

## Abstract

This document defines one or more **PIC Protocol** specifications: concrete
protocol encodings, message formats, and interoperability profiles that
implement the **Provenance Identity Continuity (PIC) Model** as normatively
defined by the **PIC Spec**.

The PIC Protocol layer translates the abstract execution invariants of the PIC
Model into deployable protocol-level mechanisms, without redefining, extending,
or altering the underlying theoretical model or its normative semantics.

In case of conflict, the **PIC Spec** is authoritative.

---

## Relationship to the PIC Model and PIC Spec

- The **PIC Model** defines the foundational execution theory and invariants.
- The **PIC Spec** defines the normative semantics of the PIC Model.
- **PIC Protocol** documents define concrete protocol encodings that implement
  the PIC Spec.

This document is **subordinate** to the PIC Spec and **derivative** of both the
PIC Model and PIC Spec. It does not introduce new conceptual authority,
invariants, or authorship claims.

---

## Table of Contents

1. [Introduction](#1-introduction)  
A. [Use of Automated Language Assistance](#appendix-a--use-of-automated-language-assistance)  
B. [Authorship, Stewardship, Attribution, and Derivative Works](#appendix-b--authorship-stewardship-attribution-and-derivative-works)
C. [Disclaimer and Limitation of Liability](#appendix-c--disclaimer-and-limitation-of-liability)  

---

## 1. Introduction

The PIC Protocol layer specifies how systems can implement the
**Provenance Identity Continuity (PIC)** execution model at the protocol level.

Unlike the PIC Model and PIC Spec, which define execution semantics and
invariants, PIC Protocol documents focus on:

- message formats,
- challenge / response encodings,
- interoperability profiles,
- protocol-level constraints and assumptions.

PIC Protocol specifications **MUST** faithfully preserve the invariants defined
by the PIC Model and PIC Spec. Any protocol that violates these invariants is
**not PIC-compliant**, regardless of naming or intent.

---

## Appendix A. Use of Automated Language Assistance

The PIC Specification has used automated language assistance tools solely to improve grammar, clarity, and phrasing. All substantive technical content and editorial decisions remain the responsibility of the PIC Spec Contributors under the stewardship of Nitro Agility S.r.l.

---

## Appendix B. Authorship, Stewardship, Attribution, and Derivative Works

### B.1 Scope and Roles

This appendix defines the separation between:

- the **PIC Model** (theoretical framework and foundational results), and
- the **PIC Specification** (this document: terminology, normative requirements, structure, examples, and maintenance process).

This separation is intentional and MUST be preserved in references, derivative works, and claims of conformance.

---

### B.2 PIC Model — Authorship (Theoretical Framework)

The **Provenance Identity Continuity (PIC) Model**, including its formal definitions, invariants, execution semantics, and foundational proofs (including the structural resolution of the confused deputy class under the PIC assumptions), originates from the original theoretical work of **Nicola Gallo**.

Authorship of the PIC Model is independent of repository ownership, maintainer status, stewardship of the specification, or any publishing entity.

Primary references for the PIC Model include:

- Gallo, N. (2025). *Authority Propagation Models: PoP vs PoC and the Confused Deputy Problem*. Zenodo. DOI: 10.5281/zenodo.17833000  
- Gallo, N. (2025). *Authority is a Continuous System*. Zenodo. DOI: 10.5281/zenodo.17860199  
- Gallo, N. (2025). *PIC Model — Provenance Identity Continuity for Distributed Execution Systems*. Zenodo. DOI: 10.5281/zenodo.17777421  

---

### B.3 PIC Specification — Stewardship, Publication, and Canonical Status

This document (the **PIC Specification**) is authored, developed, published, maintained, and stewarded by:

**Nitro Agility S.r.l.** (the “Specification Steward”)

All normative text of this PIC Specification — including structure, terminology, requirements, examples, editorial content, and all subsequent edits incorporated into the canonical version — is produced and maintained under the stewardship of Nitro Agility S.r.l.

The Specification Steward is responsible for:

- publication and maintenance of the PIC Specification,
- editorial decisions and normative text,
- contribution review and acceptance,
- release management and designation of canonical versions,
- specification governance and process.

The canonical PIC Specification is the version designated by the Specification Steward in the official PIC Spec repositories.

---

### B.4 License

The PIC Model references and this PIC Specification are published under the **Creative Commons Attribution 4.0 International (CC BY 4.0)** license.

CC BY 4.0 governs copyright and redistribution only.  
It does not imply any warranty, support obligation, operational responsibility, or professional services.

---

### B.5 Mandatory Attribution and Correct Referencing

Any academic, technical, or commercial work that references, implements, or claims conformance with PIC MUST clearly distinguish between:

1. **The PIC Model (theoretical framework)**  
   **Author:** Nicola Gallo

2. **The PIC Specification (this document)**  
   **Publisher and Steward:** Nitro Agility S.r.l.

A compliant reference MUST acknowledge both roles.

**Example attribution (acceptable):**

> “Based on the Provenance Identity Continuity (PIC) Model created by Nicola Gallo.  
> Conforms to the PIC Specification published and maintained by Nitro Agility S.r.l.”

Attribution MUST NOT:

- omit the PIC Model author when referencing the PIC Model, or
- attribute the PIC Model’s foundational concepts and proofs to parties other than its author, or
- represent a fork or derivative as the canonical PIC Specification without Steward designation.

---

### B.6 Derivative Works, Forks, and Implementations

Derivative works (modified specifications, extensions, profiles, or adaptations):

- MUST clearly state they are **derivative works** of the PIC Specification,
- MUST preserve the attribution requirements in B.5,
- SHOULD document any substantive semantic or security-relevant changes,
- MUST NOT claim to be the canonical PIC Specification unless explicitly designated by the Specification Steward.

Implementations (software libraries, SDKs, middleware, gateways, services):

- MAY claim authorship of the implementation code,
- MUST NOT claim authorship of the PIC Model’s foundational concepts, invariants, or proofs.

---

### B.7 Contributors and Responsibility Boundaries

#### B.7.1 PIC Spec Contributors

“PIC Spec Contributors” are individuals or organizations that contribute text, reviews, examples, or discussion to the PIC Specification repositories.

Contributions by **Nicola Gallo**, **Antonio Radesca**, and **any other employee, associate, contractor, or co-founder of Nitro Agility S.r.l.** to the PIC Specification are made **on behalf of Nitro Agility S.r.l.**, and **not in a personal capacity**. All such contributions are incorporated as part of the Nitro Agility–stewarded specification.

For avoidance of doubt: where Nicola Gallo contributes to the PIC Specification repositories, he does so as a representative of Nitro Agility S.r.l. for purposes of the specification text and its maintenance. This does not alter or diminish his independent authorship of the underlying **PIC Model**.

**Contribution does not imply:**

- authorship of the PIC Model, or
- acceptance of operational responsibility, warranty, or liability for the PIC Specification.

The Specification Steward (Nitro Agility S.r.l.) retains full editorial and governance control over what becomes normative in the PIC Specification.

#### B.7.2 External Contributors

External contributors (i.e., contributors not acting on behalf of Nitro Agility S.r.l.) contribute on an “as-is” basis.

External contributors:

- do not become stewards, publishers, or operators by contributing,
- do not provide warranties or professional advice,
- are not responsible for maintenance, release management, or governance of the PIC Specification.

Operational and editorial responsibility for the PIC Specification remains with the Specification Steward.

---

### B.8 Credits

**PIC Model Author (Theoretical Framework):**

- **Nicola Gallo** (in personal capacity)

**PIC Specification Steward / Publisher:**

- **Nitro Agility S.r.l.**

**PIC Spec Contributors (non-exhaustive, in order of appearance):**

1. **Nicola Gallo (on behalf of Nitro Agility S.r.l.)** — contributor to specification text and examples  
2. **Nitro Agility S.r.l.** — specification stewardship, editorial maintenance, governance  
3. *Add your name here via pull request (individual or organization)*

---

### B.9 Stewardship Transfer

Stewardship of the PIC Specification MAY be transferred by Nitro Agility S.r.l. to another organization.

Such a transfer does not affect:

- authorship of the PIC Model (Nicola Gallo),
- the CC BY 4.0 license terms,
- the attribution requirements defined in this appendix.

The new steward (if any) becomes the Specification Steward for canonical designation and maintenance of the PIC Specification.

---

## Appendix C. Disclaimer and Limitation of Liability

THIS SPECIFICATION IS PROVIDED **"AS IS" AND "AS AVAILABLE"**, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND NON-INFRINGEMENT.

THIS SPECIFICATION **DOES NOT GUARANTEE SECURITY, CORRECTNESS, OR FITNESS FOR ANY PARTICULAR IMPLEMENTATION OR DEPLOYMENT CONTEXT**.  
SECURITY, SAFETY, AND CORRECT BEHAVIOR DEPEND ENTIRELY ON PROPER IMPLEMENTATION, CONFIGURATION, AND OPERATION.

IN NO EVENT SHALL THE AUTHORS, CONTRIBUTORS, ACKNOWLEDGED INDIVIDUALS, OR COPYRIGHT HOLDERS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, CONSEQUENTIAL, OR PUNITIVE DAMAGES (INCLUDING BUT NOT LIMITED TO PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES, LOSS OF USE, DATA, PROFITS, OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SPECIFICATION, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

USE OF THIS SPECIFICATION, INCLUDING ANY CLAIMS OF CONFORMANCE OR COMPATIBILITY, **DOES NOT IMPLY ENDORSEMENT** BY THE AUTHORS OR PIC SPEC CONTRIBUTORS UNLESS EXPLICITLY STATED IN WRITING.

IMPLEMENTERS AND USERS ASSUME **ALL RISKS** ASSOCIATED WITH THE USE OF THIS SPECIFICATION AND ANY IMPLEMENTATIONS OR DERIVATIVE WORKS BASED UPON IT.

THIS DISCLAIMER SHALL BE GOVERNED BY AND CONSTRUED IN ACCORDANCE WITH APPLICABLE LAW, WITHOUT REGARD TO CONFLICT OF LAW PRINCIPLES.

IF ANY PROVISION OF THIS DISCLAIMER IS HELD TO BE UNENFORCEABLE, THE REMAINING PROVISIONS SHALL CONTINUE IN FULL FORCE AND EFFECT.

THE AUTHORS AND CONTRIBUTORS HAVE NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, PATCHES, OR CORRECTIONS.

THIS SPECIFICATION DOES NOT CONSTITUTE LEGAL, SECURITY, OR PROFESSIONAL ADVICE.

### Responsibility and Legal Context

This specification is published and maintained by **Nitro Agility S.r.l.** as the Specification Steward.

Nothing in this document creates a contractual relationship between individual contributors and users of this specification.

### Legal Context Regarding Claims

To the extent permitted by applicable law, claims, disputes, or actions arising from the use of this specification, the PIC Model, or any implementation should be addressed to the **Specification Steward** in relation to the specification’s publication and maintenance activities.

Nothing in this document shall be interpreted as creating personal operational responsibility for the PIC Model author, whose role is limited to authorship of the underlying theoretical framework and its referenced publications.

---

## References

- [1] Gallo, N. (2025). *Authority Propagation Models: PoP vs PoC and the Confused Deputy Problem*. Zenodo. [doi.org/10.5281/zenodo.17833000](https://doi.org/10.5281/zenodo.17833000)
- [2] Gallo, N. (2025). *PIC Model — Provenance Identity Continuity for Distributed Execution Systems (0.1-draft)*. Zenodo. [doi.org/10.5281/zenodo.17777421](https://doi.org/10.5281/zenodo.17777421)
- [3] Gallo, N. (2025). *Authority is a Continuous System. (0.1-draft)*. Zenodo. [doi.org/10.5281/zenodo.17860199](https://doi.org/10.5281/zenodo.17860199)
