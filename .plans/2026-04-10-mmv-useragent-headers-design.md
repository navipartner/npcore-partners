# Add User-Agent Header to Magento HTTP Requests

## Goal

Add a `User-Agent` header to all outbound HTTP requests from BC to Magento, enabling Cloudflare WAF filtering on the Magento side. The header value `'Microsoft-Dynamics-365-Business-Central-NP-Retail'` identifies our traffic so Cloudflare can distinguish it from other internet traffic.

## Decisions

- **Scope:** Only requests that talk to Magento servers. Payment gateway calls (Stripe, Vipps, Dibs, Quickpay, Adyen, Nets Easy) are excluded as they talk to payment providers.
- **Value source:** Hardcoded string `'Microsoft-Dynamics-365-Business-Central-NP-Retail'` (already used in 3 existing files). Not key vault — the source is open and WAF just needs a distinguishing identifier.
- **Code organization:** New `UserAgentHelper` codeunit in `_Misc/` folder with a single function returning the string. All call sites reference this helper.
- **NpXml behavior:** If no User-Agent header is configured in the NpXml template headers, automatically add the default from the helper as a fallback.
- **Failure behavior:** N/A — no external dependency, the value is a compile-time constant.

## New Codeunit

`Application/src/_Misc/UserAgentHelper.Codeunit.al`
- Access = Internal
- Single procedure: returns `'Microsoft-Dynamics-365-Business-Central-NP-Retail'`

## Files to Modify

### Add User-Agent header (currently missing)

| File | Send Lines | Header Variable |
|------|-----------|-----------------|
| `Magento/MagentoInvNpXmlValue.Codeunit.al` | 127 | `HeadersReq` |
| `Magento/_public/MagentoMgt.Codeunit.al` | 132, 188 | `HeadersReq` |
| `Magento/_public/MagentoPicture.Table.al` | 208 | Needs `Request.GetHeaders()` |
| `Magento 2/M2SetupMgt.Codeunit.al` | 485, 528 | `Headers` |
| `Magento 2/M2PictureMgt.Codeunit.al` | 133 | `RequestHeaders` |
| `Magento 2/M2AccountManager.Codeunit.al` | 1531 | `Headers` |
| `Magento 2/M2AccountLookupMgt.Codeunit.al` | 472 | `Headers` |

### Replace hardcoded string with helper call

| File | Line | Current Value |
|------|------|---------------|
| `Magento 2/M2 Integration/MSI Integration/M2MSITaskMgt.Codeunit.al` | 201 | `'Microsoft-Dynamics-365-Business-Central-NP-Retail'` |

### Add fallback User-Agent

| File | Location | Change |
|------|----------|--------|
| `__Legacy (STILL SUPPORTED)/NpXml/_public/NpXmlMgt.Codeunit.al` | After template header processing (~line 608) | If no User-Agent was added by template headers, add default |

## Out of Scope

- Payment gateway codeunits (Stripe, Vipps, Dibs, Quickpay, Adyen, Nets Easy)
- NaviConnect module (no direct HTTP sends found)
- Endpoint module (no direct HTTP sends found)
- Non-Magento integrations (Shopify, Sentry, SMS, SendGrid, etc.)
