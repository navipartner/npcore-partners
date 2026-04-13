# User-Agent Header for Magento HTTP Requests — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers-extended-cc:executing-plans to implement this plan task-by-task.

**Goal:** Add a `User-Agent: Microsoft-Dynamics-365-Business-Central-NP-Retail` header to all outbound HTTP requests from BC to Magento, enabling Cloudflare WAF filtering.

**Architecture:** A new internal `UserAgentHelper` codeunit in `_Misc/` provides the User-Agent string from a single source. Each Magento-facing HTTP call site adds the header via its existing `HttpHeaders` variable before calling `.Send()` / `.Post()`. The NpXml module adds it as a fallback when no User-Agent was configured via template headers.

**Tech Stack:** AL (Business Central), HttpClient/HttpRequestMessage/HttpHeaders types

---

### Task 1: Create UserAgentHelper codeunit

**Files:**
- Create: `Application/src/_Misc/UserAgentHelper.Codeunit.al`

**Step 1: Get next object ID**

Use the `/al-id-manager:get-next-id` skill to get the next available codeunit ID for the Application app.

**Step 2: Create the codeunit**

```al
codeunit <ID> "NPR UserAgent Helper"
{
    Access = Internal;

    procedure GetUserAgentHeader(): Text
    begin
        exit('Microsoft-Dynamics-365-Business-Central-NP-Retail');
    end;
}
```

**Step 3: Commit**

```bash
git add Application/src/_Misc/UserAgentHelper.Codeunit.al
git commit -m "feat: add UserAgentHelper codeunit for Magento WAF identification"
```

---

### Task 2: Add User-Agent to Magento v1 core codeunits

**Files:**
- Modify: `Application/src/Magento/MagentoInvNpXmlValue.Codeunit.al` (around line 118-127)
- Modify: `Application/src/Magento/_public/MagentoMgt.Codeunit.al` (around lines 116-132 and 165-188)

**Step 1: MagentoInvNpXmlValue — add User-Agent to HeadersReq**

In the procedure that builds the SOAP request, after `HttpWebRequest.GetHeaders(HeadersReq);` (line 118) and before `Client.Send` (line 127), add:

```al
        _UserAgentHelper: Codeunit "NPR UserAgent Helper";
```
to the var section, and add this line after `MagentoInventoryCompany.SetRequestHeadersAuthorization(HeadersReq);` (line 120):

```al
        HeadersReq.Add('User-Agent', _UserAgentHelper.GetUserAgentHeader());
```

**Step 2: MagentoMgt — add User-Agent to GET method (MagentoApiGet)**

In `MagentoApiGet`, after the if/else block that adds Accept/Authorization headers to `HeadersReq` (line 126), add:

```al
        HeadersReq.Add('User-Agent', _UserAgentHelper.GetUserAgentHeader());
```

Add `_UserAgentHelper: Codeunit "NPR UserAgent Helper";` to the var section.

**Step 3: MagentoMgt — add User-Agent to POST method (MagentoApiPost)**

In `MagentoApiPost`, after the if/else block that adds headers to `HeadersReq` (line 180), add:

```al
        HeadersReq.Add('User-Agent', _UserAgentHelper.GetUserAgentHeader());
```

Add `_UserAgentHelper: Codeunit "NPR UserAgent Helper";` to the var section.

**Step 4: Commit**

```bash
git add Application/src/Magento/MagentoInvNpXmlValue.Codeunit.al Application/src/Magento/_public/MagentoMgt.Codeunit.al
git commit -m "feat: add User-Agent header to Magento v1 API requests"
```

---

### Task 3: Add User-Agent to MagentoPicture table

**Files:**
- Modify: `Application/src/Magento/_public/MagentoPicture.Table.al` (around line 197-211)

**Step 1: Add User-Agent to TryCheckPicture**

This procedure has no headers variable yet. Add one and set User-Agent before Send:

Add to var section:
```al
        _UserAgentHelper: Codeunit "NPR UserAgent Helper";
        Headers: HttpHeaders;
```

After `Request.SetRequestUri(PictureUrl);` (line 207), before `Client.Send` (line 208), add:

```al
        Request.GetHeaders(Headers);
        Headers.Add('User-Agent', _UserAgentHelper.GetUserAgentHeader());
```

**Step 2: Add User-Agent to TryDownloadPicture**

This procedure uses `WebClient.Get()` (line 190) which doesn't use HttpRequestMessage. Set User-Agent via DefaultRequestHeaders:

Add to var section:
```al
        _UserAgentHelper: Codeunit "NPR UserAgent Helper";
        Headers: HttpHeaders;
```

Before `WebClient.Get(PictureUrl, Response);` (line 190), add:

```al
        Headers := WebClient.DefaultRequestHeaders();
        Headers.Add('User-Agent', _UserAgentHelper.GetUserAgentHeader());
```

**Step 2: Commit**

```bash
git add Application/src/Magento/_public/MagentoPicture.Table.al
git commit -m "feat: add User-Agent header to Magento picture HEAD requests"
```

---

### Task 4: Add User-Agent to Magento 2 core codeunits

**Files:**
- Modify: `Application/src/Magento 2/M2SetupMgt.Codeunit.al` (around lines 478-485 and 516-528)
- Modify: `Application/src/Magento 2/M2PictureMgt.Codeunit.al` (around line 125-133)
- Modify: `Application/src/Magento 2/M2AccountManager.Codeunit.al` (around line 1524-1531)
- Modify: `Application/src/Magento 2/M2AccountLookupMgt.Codeunit.al` (around line 465-472)

**Step 1: M2SetupMgt — GET method (MagentoApiGet)**

After `Headers.Add('Accept', 'naviconnect/xml');` (line 482), add:

```al
        Headers.Add('User-Agent', _UserAgentHelper.GetUserAgentHeader());
```

Add `_UserAgentHelper: Codeunit "NPR UserAgent Helper";` to the var section of this procedure.

**Step 2: M2SetupMgt — POST method (MagentoApiPost)**

After the if/else block that adds Authorization/Accept headers (ends at line 525), add:

```al
        Headers.Add('User-Agent', _UserAgentHelper.GetUserAgentHeader());
```

Note: `Headers` is reused for both content and request headers in this procedure. The User-Agent must be added after `HttpWebRequest.GetHeaders(Headers)` (line 516), not before. Add it after the if/else block at line 525.

Add `_UserAgentHelper: Codeunit "NPR UserAgent Helper";` to the var section.

**Step 3: M2PictureMgt**

After `RequestHeaders.Add('Authorization', MagentoSetup."Api Authorization");` (line 129), add:

```al
        RequestHeaders.Add('User-Agent', _UserAgentHelper.GetUserAgentHeader());
```

Add `_UserAgentHelper: Codeunit "NPR UserAgent Helper";` to the var section.

**Step 4: M2AccountManager**

After the if/else block that adds Authorization to `Headers` (line 1528), add:

```al
        Headers.Add('User-Agent', _UserAgentHelper.GetUserAgentHeader());
```

Add `_UserAgentHelper: Codeunit "NPR UserAgent Helper";` to the var section.

**Step 5: M2AccountLookupMgt**

After the if/else block that adds Authorization to `Headers` (line 469), add:

```al
        Headers.Add('User-Agent', _UserAgentHelper.GetUserAgentHeader());
```

Add `_UserAgentHelper: Codeunit "NPR UserAgent Helper";` to the var section.

**Step 6: Commit**

```bash
git add Application/src/Magento\ 2/M2SetupMgt.Codeunit.al Application/src/Magento\ 2/M2PictureMgt.Codeunit.al Application/src/Magento\ 2/M2AccountManager.Codeunit.al Application/src/Magento\ 2/M2AccountLookupMgt.Codeunit.al
git commit -m "feat: add User-Agent header to Magento 2 API requests"
```

---

### Task 5: Replace hardcoded User-Agent in M2MSITaskMgt

**Files:**
- Modify: `Application/src/Magento 2/M2 Integration/MSI Integration/M2MSITaskMgt.Codeunit.al` (line 201)

**Step 1: Replace hardcoded string with helper call**

Change line 201 from:
```al
        SetHeader(ClientHeaders, 'User-Agent', 'Microsoft-Dynamics-365-Business-Central-NP-Retail');
```
to:
```al
        SetHeader(ClientHeaders, 'User-Agent', _UserAgentHelper.GetUserAgentHeader());
```

Add `_UserAgentHelper: Codeunit "NPR UserAgent Helper";` to the codeunit's global var section (around line 95-98), since `InitializeHttpClient` is a local procedure.

**Step 2: Commit**

```bash
git add Application/src/Magento\ 2/M2\ Integration/MSI\ Integration/M2MSITaskMgt.Codeunit.al
git commit -m "refactor: use UserAgentHelper in M2MSITaskMgt instead of hardcoded string"
```

---

### Task 6: Add User-Agent fallback to NpXml

**Files:**
- Modify: `Application/src/__Legacy (STILL SUPPORTED)/NpXml/_public/NpXmlMgt.Codeunit.al` (around lines 601-608)
- Modify: `Application/src/__Legacy (STILL SUPPORTED)/NpXml/NpXmlTemplateMgt.Codeunit.al` (around line 238)

**Step 1: Add fallback after template header processing in NpXmlMgt**

After the repeat/until loop that processes `NpXmlApiHeader` records (line 605) and before `RequestMessage.Content(RequestContent);` (line 607), add a check: if no User-Agent was set by the template headers, add the default.

```al
        if not RequestHeader.Contains('User-Agent') then
            RequestHeader.Add('User-Agent', _UserAgentHelper.GetUserAgentHeader());
```

Add `_UserAgentHelper: Codeunit "NPR UserAgent Helper";` to the var section of this procedure.

**Step 2: Add User-Agent to NpXmlTemplateMgt template download**

`ImportNpXmlTemplateUrl` uses `Client.Get()` (line 238) to download templates — the URL can point to Magento. Add User-Agent via DefaultRequestHeaders.

Add to var section:
```al
        _UserAgentHelper: Codeunit "NPR UserAgent Helper";
        ClientHeaders: HttpHeaders;
```

Before `Client.Get(TemplateUrl + ...)` (line 238), add:

```al
                ClientHeaders := Client.DefaultRequestHeaders();
                ClientHeaders.Add('User-Agent', _UserAgentHelper.GetUserAgentHeader());
```

**Step 3: Commit**

```bash
git add "Application/src/__Legacy (STILL SUPPORTED)/NpXml/_public/NpXmlMgt.Codeunit.al" "Application/src/__Legacy (STILL SUPPORTED)/NpXml/NpXmlTemplateMgt.Codeunit.al"
git commit -m "feat: add User-Agent fallback to NpXml when not configured via template headers"
```

---

### Task 7: Compile and verify

**Step 1: Compile**

Use `/bcdev` skill to download symbols and compile with `-suppressWarnings`. Verify no compilation errors from the new codeunit reference or header additions.

**Step 2: Verify all send points have coverage**

Grep to confirm no Magento-facing `.Send(` calls remain without User-Agent:

```bash
# All Magento .Send points should now reference UserAgentHelper or already have User-Agent
grep -rn "Client.Send\|_HttpClient.Post" Application/src/Magento/ Application/src/Magento\ 2/
```

Cross-reference each result with a nearby `User-Agent` or `UserAgentHelper` reference.

**Step 3: Final commit if any fixes needed**
