# NPR Module Licensing

Customers buy per-user seats (SKUs) in the NaviPartner Customer Portal. This module syncs the tenant's license
pools from the portal, lets admins assign seats to Business Central users (page "NPR Licensed Users"), reports
seat usage back to the portal, and decides what a user may see and use in NP Retail.

Some rules below are current product choices, marked as such. They may change with real-life experience; when one
changes, update this file together with the code.

## Model

- **SKU** = enum "NPR License Module" (portal slug in `LicenseMgt.ModuleSlugOf`). A **seat** is a row in
  "NPR License User": one user, one SKU, a status. Only `Active` rows count, with one exception (grace, below).
- **Capability** = enum "NPR License Capability": what a seat lets the user do. `"NPR License Capability Mgt".GrantsCapability`
  maps SKUs to capabilities. Code always asks for a capability, never for a SKU.

| SKU | Back Office | POS End of Sale (= may use the POS) | Ticket Management |
|---|:-:|:-:|:-:|
| POS (Retail POS) | X | X | |
| Retail without POS | X | | |
| Attraction POS | X | X | X |
| Attraction without POS | X | | X |
| KDS, Scanner | | | |

## Where it is enforced

1. **POS** (feature "NPR Module Licensing"). `"NPR License Mgt".CheckPOSLicense` runs when a POS session starts
   (`"NPR POS Session".OnInitialize`, raised by every POS host: the POS page, its testing copies and the
   Dragonglass web service at FrameworkReady), at salesperson login, and on every Dragonglass web-service request
   without the user's own open sale.
   Without a POS or Attraction POS seat the POS cannot be used at all. Nothing inside a running POS checks
   licenses, so new POS actions need no licensing code.
   The POS page asks `IsPOSStartAllowed` first and closes itself before raising the error. On SaaS, an error
   raised while a page the browser has cached is open crashes the web client ("Something went wrong"), so the
   POS page refuses only by closing first (at FrameworkReady) or with a Message and a close (in OnOpenPage).
2. **Back-office UI** (feature "License-Based Module Access", per company):
   - `"NPR License App Area Filter"` removes, per session, the NP application areas the user's seats do not grant
     (`CapabilityForTag`: single-tag exceptions first, then prefix groups such as `#NPRTicket*`, then Back Office
     for every other NP area).
   - Every session starts with the modules last applied for the user in this company (isolated storage; the first
     filtered session stores the live seats). Microsoft still resolves the base user/profile/company areas. The
     filter removes only NP tags and never rewrites company setup.
   - Why: BC's web server caches page metadata per user and company for all of that user's sessions, not per
     application area set. If a session starts with fewer areas than that cache, it fails with "Metadata for page
     ... does not contain a control definition". Setting the areas after company open clears that cache; BC's own
     setting at sign-in does not.
   - A seat change is switched in `OnAfterLogin`: the session stops the user's other client sessions, stores the
     new set and sets the areas (clearing the cache). It does not restart: `OnAfterLogin` runs before the role
     center loads, and a restart requested during a browser refresh left SaaS at "Getting ready". This happens once
     per change; a session that started while another one switched follows it unchecked.
   - A role-center notice explains missing NP access. While a change is pending, a notice says so and offers
     **Apply changes and restart** (same switch plus a restart, because the open pages were loaded with the old
     areas; refused with the name of the blocking session).
   - The POS page refuses to open without Back Office (its add-in is NP-tagged and would never load).
3. **Not enforced yet: KDS and the ticket scanner.** The devices sign in as Entra application users, so a
   per-employee seat cannot be checked until a device identity model is decided.

## Who is not enforced (`IsEnforcementActive`)

Current choices, may change:

- Environments other than SaaS production (sandboxes, containers), unless a developer symbol is set (below).
- Delegated admins (partners).
- Entra application users: the REST API, self-service kiosks, and the Dragonglass web-service POS when it runs as
  an application user. REST API sales are billed per order, not per seat. Before CORE-2396 the Dragonglass
  web-service POS needed a POS seat on its application user; to require it again, remove the application-user
  check in `IsEnforcementActive`.
- Web-service sessions whose user cannot read the User table (fail open: a person cannot be told apart from an
  application user there). Sessions with a UI are always people (application users cannot sign in to a client),
  so they are enforced without reading User.

## Expected behaviour (not errors)

- A seat change takes effect at the next POS start or salesperson login. The POS seat check does not interrupt a
  running POS, and locking and unlocking the POS does not re-check.
- A back-office assignment change is applied at the user's next sign-in (a browser refresh is enough), or with
  **Apply changes and restart**.
  That sign-in stops the user's other client sessions in any company, once per company, open or not: Active
  Session cannot tell an open browser from a closed one (SaaS listed closed browsers for hours). A POS open in another tab is stopped too.
- `StopSession` only reaches sessions on the same server instance. If the user has a session on another
  instance, nothing is stopped and the user keeps the previous NP layout (also wider than licensed after a
  revocation) until a later sign-in succeeds; the Apply error names the session, and an administrator can
  cancel it in the Business Central admin center (Environment > Sessions). APIs, permissions and the POS
  license gate are unaffected.
- The UI filter requires licensing read permissions only. If the assignments cannot be read, the session keeps
  Microsoft's areas (fail open). An empty successful read means the user has no module capabilities.
- Admin assignment changes never restart another user's session or change company/profile application areas.
  Each session reads its own user's assignments. Without read access to Active Session, a change stays pending.
- Switch "License-Based Module Access" on or off while the company's users are signed out (also right after the
  first deployment). A session keeps the feature decision it started with; changing the rollout switch during
  active sessions is outside the supported rollout procedure.
- A POS unit that must be balanced at login (a Z-report left from a previous day) can only be balanced by a user
  with a POS seat.
- An unfinished sale stays on its POS unit; the next licensed user resumes it.
- Grace: a seat the portal sync suspended automatically (pool shrink or expiry) still keeps the back office
  visible, but it does not open the POS.
- Pools are synced from the portal at the first POS start of a session (again after a refused start) and when the
  licensing pages open. All checks read the local rows, never the portal.

## Changing it

- **A new NP application area** belongs to Back Office automatically. To sell it separately: add a capability
  value, an exception in `CapabilityForTag`, and a `GrantsCapability` line for every SKU that should keep it.
- **Exemptions** live only in `IsEnforcementActive`.
- **Emergency switch-off (INF-1117, not implemented)** must be the first check in `IsEnforcementActive`, above the
  test override, so that it switches every check off at once.

## Developing and testing

- Symbol `MODULE_LICENSING_LOCAL_DEV`: enforce as in production but never call the portal; maintain the rows on
  "NPR Licensed Users" by hand. Symbol `MODULE_LICENSING_INTEGRATION_DEV`: enforce and talk to the PRELIVE portal.
  Set at most one; the pipeline sets neither.
- Tests: bind "NPR License Enforcement Mock" (Test app) to switch enforcement on for the test session; it can
  never switch it off. The POS gate tests are in "NPR POS License Gate Tests".
- "NPR License UI Session Tests" covers the stored applied set (grants/revocations stay pending until a switch),
  module-list isolation, UI grace and resolution through Microsoft's facade. The switch itself (stopping other
  sessions, setter) needs a browser: on a SaaS sandbox (October 2026), repeated grants and revocations showed after
  one browser refresh with no metadata error. Only that sandbox's BC version was tried.

## Rollout order

1. The portal accepts the SKU slugs `retail-without-pos`, `attraction-pos` and `attraction-without-pos`. The usage
   report sends every SKU, including those nobody has, so this must be live before the BC release.
2. Admins assign the new SKU seats while the old `pos` pools still exist. Shrinking `pos` pools first suspends
   Retail POS seats automatically, and those cashiers can no longer open the POS.
3. NP support enables "License-Based Module Access" per company. A company created later inherits it, like
   "NPR Module Licensing", when another company has it on.
