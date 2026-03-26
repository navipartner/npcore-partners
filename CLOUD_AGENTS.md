# Agents

## Cursor Cloud specific instructions

### Overview

This is an NP Retail (NaviPartner) Business Central ISV app monorepo. The primary application code is in `Application/`, tests in `Test/`, and API documentation in `fern/`. See `CLAUDE.md` for coding rules, conventions, and the standard development workflow.

### bcdev CLI

The bcdev CLI is cloned at `~/claude_plugin_marketplace/bcdev-cli/bin/bcdev-ensure`. Use it for downloading symbols, compiling, publishing, and running tests. Full skill documentation is at `~/claude_plugin_marketplace/bcdev-cli/skills/bcdev/SKILL.md`.

### AL ID Manager

When creating new AL objects/fields/enum values, use the AL ID Manager API. Instructions at `~/claude_plugin_marketplace/al-id-manager/skills/get-next-id/SKILL.md`.

### Crane Container Provisioning

To create a new BC development container, use the Crane SOAP API with the `crane_key` environment variable. Template `CLOUD-CORE` provides the latest BC version. Containers take ~20 minutes to boot. SOAP request format:

```bash
curl -s -X POST "https://api.navipartner.dk/npcase/crane/api/v1/" \
  -H "Ocp-Apim-Subscription-Key: ${crane_key}" \
  -H "Content-Type: text/xml; charset=utf-8" \
  -H "SOAPAction: urn:microsoft-dynamics-schemas/codeunit/CraneAPI:CreateCursorContainer" \
  -d '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cran="urn:microsoft-dynamics-schemas/codeunit/CraneAPI">
   <soapenv:Header/>
   <soapenv:Body>
      <cran:CreateCursorContainer>
         <cran:craneTemplateCode>CLOUD-CORE</cran:craneTemplateCode>
         <cran:containerUrl>?</cran:containerUrl>
         <cran:userName>?</cran:userName>
         <cran:password>?</cran:password>
      </cran:CreateCursorContainer>
   </soapenv:Body>
</soapenv:Envelope>'
```

After creation, you **must sleep for a full 35 minutes** before making ANY request to the container (including health-check polls). The container imports demo data during this window and premature requests will crash the data import. After the 35-minute grace period, poll `{containerUrl}/BC` (following redirects) until the sign-in page responds. Save credentials to `~/.env`.

If you have already created a container for your task previously and stored the credentials in .env then the container might be stopped now.
If so, the following SOAP request will start it again (no need to wait 35 minutes in this case, just start polling immediately as data import is not executed again):
```
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cran="urn:microsoft-dynamics-schemas/codeunit/CraneAPI">
   <soapenv:Header/>
   <soapenv:Body>
      <cran:StartContainer>
         <cran:containerId>?</cran:containerId>
      </cran:StartContainer>
   </soapenv:Body>
</soapenv:Envelope>
```

Once you are done with your task, stop your container using the following SOAP request:
```
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cran="urn:microsoft-dynamics-schemas/codeunit/CraneAPI">
   <soapenv:Header/>
   <soapenv:Body>
      <cran:StopContainer>
         <cran:containerId>?</cran:containerId>
      </cran:StopContainer>
   </soapenv:Body>
</soapenv:Envelope>
```

### Compilation on Linux (Case Sensitivity)

The `.al` files reference `src/_ControlAddins/` (lowercase 'i' in 'ins') but the actual directory is `src/_ControlAddIns/` (uppercase 'I'). On Linux, create a symlink:

```bash
cd /workspace/Application/src && ln -sf _ControlAddIns _ControlAddins
```

This symlink is not tracked by git and must be recreated each session. The update script handles this automatically.

### app.json Version Targeting

Per `CLAUDE.md`, the checked-in `app.json` targets BC17 (oldest supported). For local compilation, temporarily update `platform`, `application`, `runtime`, and `preprocessorSymbols` to match your Crane container's BC version. **Do not commit app.json changes.** Back up originals as `app.json.orig` first.

Formula: `runtime = BC_version - 11` (e.g., BC27 → runtime 16.0).

The `CLOUD-CORE` Crane template always points at the latest released BC version from Microsoft (currently BC27). When setting `preprocessorSymbols`, define **only** the target version (e.g., `["BC27", "BC2700"]`).

### launch.json

launch.json files are gitignored. Create them at:
- `Application/.vscode/launch.json`
- `Test/.vscode/launch.json`

Use Crane container URL, port 443, `serverInstance: "BC"`, and `authentication: "UserPassword"`.

### POS Testing

To open the POS page directly in BC, append `?page=6150750` to the BC URL. For normal BC pages, use the search function in the top-right corner of the Role Center.

### Fern API Docs

After changing AL API endpoints, update fern definitions and validate with `cd fern && fern check`. See `CLAUDE.md` for common pitfalls.
