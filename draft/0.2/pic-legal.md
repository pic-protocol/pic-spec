# PIC Legal Appendices

**Version:** 0.2 (Draft)  
**Status**: Draft – Not a Standard  
**Date:** 2026-07-15  
**Source:** [github.com/pic-protocol/pic-spec/draft/0.2/pic-legal.md](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-legal.md)

## Scope and Applicability

This document contains the legal, governance, and attribution appendices shared
by all PIC specification documents. It is **incorporated by reference** into
each of the following documents (collectively, the "**PIC Documents**"):

- [PIC Specification](./pic-spec.md) — `draft/0.2/pic-spec.md`
- [PIC Prover and Verifier Specification](./pic-prover-verifier-spec.md) — `draft/0.2/pic-prover-verifier-spec.md`
- any other document published in the official PIC Spec repositories that
  explicitly incorporates these appendices by reference.

For the purposes of these appendices, the terms "**this specification**",
"**this document**", and "**the PIC Specification**" refer to each and all of
the PIC Documents, individually and collectively, including this document
itself.

In case of conflict between these appendices and any individual PIC Document,
these appendices prevail for legal, governance, licensing, and attribution
matters.

## Appendix A. Use of Automated Language Assistance

The PIC Documents have used automated language assistance tools solely to improve grammar, clarity, and phrasing. All substantive technical content and editorial decisions remain the responsibility of the PIC Spec Contributors under the stewardship of Nitro Agility S.r.l.

## Appendix B. Authorship, Stewardship, Attribution, and Derivative Works

### B.1 Scope and Roles

This appendix defines the separation between:

- the **PIC Model** (theoretical framework and foundational results), and
- the **PIC Documents** (the specifications listed in "Scope and Applicability": terminology, normative requirements, structure, examples, and maintenance process).

This separation is intentional and MUST be preserved in references, derivative works, and claims of conformance.

### B.2 PIC Model — Authorship (Theoretical Framework)

The **Provenance Identity Continuity (PIC) Model**, including its formal definitions, invariants, execution semantics, and foundational proofs (including the structural resolution of the confused deputy class under the PIC assumptions), originates from the original theoretical work of **Nicola Gallo**.

Authorship of the PIC Model is independent of repository ownership, maintainer status, stewardship of the specification, or any publishing entity.

Primary references for the PIC Model include:

- Gallo, N. (2026). *Proof-of-Continuity: A Temporal Model for Authority Propagation in Distributed Systems and AI Agents*. arXiv:2607.08906 [cs.CR]. [arxiv.org/abs/2607.08906](https://arxiv.org/abs/2607.08906)  
- Gallo, N. (2025). *Authority Propagation Models: PoP vs PoC and the Confused Deputy Problem*. Zenodo. DOI: 10.5281/zenodo.17833000  
- Gallo, N. (2025). *Authority is a Continuous System*. Zenodo. DOI: 10.5281/zenodo.17860199  
- Gallo, N. (2025). *PIC Model — Provenance Identity Continuity for Distributed Execution Systems*. Zenodo. DOI: 10.5281/zenodo.17777421  

### B.3 PIC Documents — Stewardship, Publication, and Canonical Status

The PIC Documents are authored, developed, published, maintained, and stewarded by:

**Nitro Agility S.r.l.** (the “Specification Steward”)

All normative text of the PIC Documents — including structure, terminology, requirements, examples, editorial content, and all subsequent edits incorporated into the canonical versions — is produced and maintained under the stewardship of Nitro Agility S.r.l.

The Specification Steward is responsible for:

- publication and maintenance of the PIC Documents,
- editorial decisions and normative text,
- contribution review and acceptance,
- release management and designation of canonical versions,
- specification governance and process.

The canonical version of each PIC Document is the version designated by the Specification Steward in the official PIC Spec repositories.

### B.4 License

The PIC Model references and the PIC Documents are published under the **Creative Commons Attribution 4.0 International (CC BY 4.0)** license.

CC BY 4.0 governs copyright and redistribution only.  
It does not imply any warranty, support obligation, operational responsibility, or professional services.

### B.5 Mandatory Attribution and Correct Referencing

Any academic, technical, or commercial work that references, implements, or claims conformance with PIC MUST clearly distinguish between:

1. **The PIC Model (theoretical framework)**  
   **Author:** Nicola Gallo

2. **The PIC Documents (the specifications)**  
   **Publisher and Steward:** Nitro Agility S.r.l.

A compliant reference MUST acknowledge both roles.

**Example attribution (acceptable):**

> “Based on the Provenance Identity Continuity (PIC) Model created by Nicola Gallo.  
> Conforms to the PIC Specification published and maintained by Nitro Agility S.r.l.”

Attribution MUST NOT:

- omit the PIC Model author when referencing the PIC Model, or
- attribute the PIC Model’s foundational concepts and proofs to parties other than its author, or
- represent a fork or derivative as a canonical PIC Document without Steward designation.

### B.6 Derivative Works, Forks, and Implementations

Derivative works (modified specifications, extensions, profiles, or adaptations):

- MUST clearly state they are **derivative works** of the PIC Documents,
- MUST preserve the attribution requirements in B.5,
- SHOULD document any substantive semantic or security-relevant changes,
- MUST NOT claim to be a canonical PIC Document unless explicitly designated by the Specification Steward.

Implementations (software libraries, SDKs, middleware, gateways, services):

- MAY claim authorship of the implementation code,
- MUST NOT claim authorship of the PIC Model’s foundational concepts, invariants, or proofs.

### B.7 Contributors and Responsibility Boundaries

#### B.7.1 PIC Spec Contributors

“PIC Spec Contributors” are individuals or organizations that contribute text, reviews, examples, or discussion to the PIC Specification repositories.

Contributions by **Nicola Gallo**, **Antonio Radesca**, and **any other employee, associate, contractor, or co-founder of Nitro Agility S.r.l.** to the PIC Documents are made **on behalf of Nitro Agility S.r.l.**, and **not in a personal capacity**. All such contributions are incorporated as part of the Nitro Agility–stewarded specifications.

For avoidance of doubt: where Nicola Gallo contributes to the PIC Specification repositories, he does so as a representative of Nitro Agility S.r.l. for purposes of the specification text and its maintenance. This does not alter or diminish his independent authorship of the underlying **PIC Model**.

**Contribution does not imply:**

- authorship of the PIC Model, or
- acceptance of operational responsibility, warranty, or liability for the PIC Documents.

The Specification Steward (Nitro Agility S.r.l.) retains full editorial and governance control over what becomes normative in the PIC Documents.

#### B.7.2 External Contributors

External contributors (i.e., contributors not acting on behalf of Nitro Agility S.r.l.) contribute on an “as-is” basis.

External contributors:

- do not become stewards, publishers, or operators by contributing,
- do not provide warranties or professional advice,
- are not responsible for maintenance, release management, or governance of the PIC Documents.

Operational and editorial responsibility for the PIC Documents remains with the Specification Steward.

#### B.7.3 Contributor Listing in PIC Documents

Each PIC Document MAY list its editors and contributors in its document header.

- **Editors** maintain the document text on behalf of the Specification Steward, which retains full editorial and governance control (B.7.1).
- Contributor lists are **non-exhaustive** and ordered by first appearance.
- Inclusion in a list requires a pull request accepted by the document's editors, who act on behalf of the Specification Steward; the editors retain full discretion over listing. Omission from a list does not diminish any contribution.
- Being listed as editor or contributor does **not** confer authorship of the PIC Model, stewardship of the specification, or any operational responsibility or liability (B.7.1, B.7.2).

### B.8 Credits

**PIC Model Author (Theoretical Framework):**

- **Nicola Gallo** (in personal capacity)

**PIC Documents Steward / Publisher:**

- **Nitro Agility S.r.l.**

**PIC Spec Contributors (non-exhaustive, in order of appearance):**

1. **Nicola Gallo (on behalf of Nitro Agility S.r.l.)** — contributor to specification text and examples  
2. **Nitro Agility S.r.l.** — specification stewardship, editorial maintenance, governance  
3. *Add your name here via pull request (individual or organization)*

### B.9 Stewardship Transfer

Stewardship of the PIC Documents MAY be transferred by Nitro Agility S.r.l. to another organization.

Such a transfer does not affect:

- authorship of the PIC Model (Nicola Gallo),
- the CC BY 4.0 license terms,
- the attribution requirements defined in this appendix.

The new steward (if any) becomes the Specification Steward for canonical designation and maintenance of the PIC Documents.

## Appendix C. Disclaimer and Limitation of Liability

THIS SPECIFICATION IS PROVIDED **"AS IS" AND "AS AVAILABLE"**, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND NON-INFRINGEMENT.

THIS SPECIFICATION **DOES NOT GUARANTEE SECURITY, CORRECTNESS, OR FITNESS FOR ANY PARTICULAR IMPLEMENTATION OR DEPLOYMENT CONTEXT**.  
SECURITY, SAFETY, AND CORRECT BEHAVIOR DEPEND ENTIRELY ON PROPER IMPLEMENTATION, CONFIGURATION, AND OPERATION.

IN NO EVENT SHALL THE AUTHORS, CONTRIBUTORS, ACKNOWLEDGED INDIVIDUALS, OR COPYRIGHT HOLDERS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, CONSEQUENTIAL, OR PUNITIVE DAMAGES (INCLUDING BUT NOT LIMITED TO PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES, LOSS OF USE, DATA, PROFITS, OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SPECIFICATION, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

USE OF THIS SPECIFICATION, INCLUDING ANY CLAIMS OF CONFORMANCE OR COMPATIBILITY, **DOES NOT IMPLY ENDORSEMENT** BY THE AUTHORS OR PIC SPEC CONTRIBUTORS UNLESS EXPLICITLY STATED IN WRITING.

IMPLEMENTERS AND USERS ASSUME **ALL RISKS** ASSOCIATED WITH THE USE OF THIS SPECIFICATION AND ANY IMPLEMENTATIONS OR DERIVATIVE WORKS BASED UPON IT.

THIS DISCLAIMER SHALL BE GOVERNED BY AND CONSTRUED IN ACCORDANCE WITH THE LAWS OF ITALY, WITHOUT REGARD TO CONFLICT OF LAW PRINCIPLES. TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, ANY DISPUTE ARISING OUT OF OR IN CONNECTION WITH THIS SPECIFICATION SHALL BE SUBJECT TO THE EXCLUSIVE JURISDICTION OF THE COURTS OF MATERA, ITALY.

IF ANY PROVISION OF THIS DISCLAIMER IS HELD TO BE UNENFORCEABLE, THE REMAINING PROVISIONS SHALL CONTINUE IN FULL FORCE AND EFFECT.

THE AUTHORS AND CONTRIBUTORS HAVE NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, PATCHES, OR CORRECTIONS.

THIS SPECIFICATION DOES NOT CONSTITUTE LEGAL, SECURITY, OR PROFESSIONAL ADVICE.

### Responsibility and Legal Context

The PIC Documents are published and maintained by **Nitro Agility S.r.l.** as the **Specification Steward**.

Nothing in this document creates a contractual relationship between any **individual contributor** and any user of this specification.  
No duty of care is assumed or created by publication of this document.

To the **maximum extent permitted by applicable law**, any claims, disputes, or legal actions arising from:

- the use of this specification,
- any claim of conformance, compatibility, or derivation from PIC,
- any implementation, deployment, product, or service that references or relies on this specification,

should be directed to the **Specification Steward (Nitro Agility S.r.l.)** and/or the relevant **implementer**, as applicable.

For avoidance of doubt, implementers and operators remain solely responsible for their own implementations, deployments, products, services, security, and compliance claims.

### Exclusion of Personal Liability (PIC Model Author)

**Nicola Gallo**, as the author of the underlying **PIC Model** (theoretical framework), is recognized solely for **academic authorship** of that theoretical work.

This recognition does **not**:

- create any personal liability for this specification or its use,
- create any warranty, support, maintenance, or professional services obligation,
- create any contractual, fiduciary, advisory, or professional relationship with users,
- constitute endorsement of this specification or of any implementation or deployment.

To the maximum extent permitted by applicable law, **Nicola Gallo** disclaims all liability for any loss or damages arising from the use of this specification or from any implementation, deployment, product, or service based on it.

The PIC Model author’s role is strictly limited to authorship of academic publications referenced by this specification.  
All operational, legal, and commercial responsibility for this specification rests with the **Specification Steward (Nitro Agility S.r.l.)**, and for implementations with their respective **implementers/operators**.

## Appendix D. Acknowledgements

The PIC Model author thanks the following individuals for discussions and feedback during the development of the theoretical framework.

### D.1 Acknowledged Individuals

*No individuals are acknowledged in this version.*

### D.2 Scope and Limitations of Acknowledgement

Acknowledgement in this appendix:

1. **Recognizes informal contribution** to early-stage theoretical discussions only
2. **Does NOT imply**:
   - co-authorship of the PIC Model
   - co-authorship of the PIC Documents
   - contribution to the PIC Documents' text, structure, or normative content
   - endorsement of the PIC Model, the PIC Documents, or any implementation
   - affiliation with the Specification Steward (Nitro Agility S.r.l.)
   - any ongoing involvement or advisory role
3. **Does NOT create**:
   - any legal, contractual, or fiduciary relationship
   - any responsibility for errors, omissions, or defects in the PIC Model or the PIC Documents
   - any liability for implementations, deployments, or uses of this specification
   - any obligation to provide support, maintenance, or updates

### D.3 Disclaimer for Acknowledged Individuals

ACKNOWLEDGED INDIVIDUALS ARE RECOGNIZED SOLELY FOR INFORMAL DISCUSSIONS RELATED TO THE THEORETICAL PIC MODEL.

THEY BEAR **NO RESPONSIBILITY** FOR:

- the correctness, completeness, or security of the PIC Model,
- the content, accuracy, or fitness of the PIC Documents,
- any implementation, deployment, or use based on this specification,
- any claims, damages, or liabilities arising from the PIC Model or the PIC Documents.

ACKNOWLEDGEMENT IS **INFORMATIONAL ONLY** AND SHALL NOT BE CONSTRUED AS CREATING ANY LEGAL OBLIGATION, WARRANTY, OR LIABILITY ON THE PART OF ACKNOWLEDGED INDIVIDUALS.

Any claims, disputes, or legal actions related to the **PIC Documents** or any implementation, deployment, or use thereof  
MUST be directed exclusively to the **Specification Steward (Nitro Agility S.r.l.)**.

Any reference to the **original theoretical PIC Model** is made solely in its capacity as an **academic work of authorship**.  
The PIC Model is provided **for scholarly and informational purposes only**, and **creates no warranty, duty of care, or legal obligation of any kind** toward any third party.

To the **maximum extent permitted by applicable law**, the PIC Model author **disclaims all liability** for any claim, loss, or damages arising from any specification, implementation, deployment, product, service, security outcome, or commercial use that references or relies on this specification or the PIC Model, **whether framed in contract, tort, negligence, strict liability, or any other theory of liability**.

Accordingly, responsibility for any such claims rests with the **Specification Steward** and/or the relevant **implementer or operator**, as applicable.

Acknowledged individuals are explicitly excluded from **all** such claims.

## References

- [1] Gallo, N. (2026). *Proof-of-Continuity: A Temporal Model for Authority Propagation in Distributed Systems and AI Agents*. arXiv:2607.08906 [cs.CR]. [arxiv.org/abs/2607.08906](https://arxiv.org/abs/2607.08906)
