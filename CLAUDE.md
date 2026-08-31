The Application folder contains the source code of NP Retail, NP Attraction and our ecommerce integrations for Shopify and Magento. There's also various smaller modules that supports these three main products.  
All of it is compiled into one Microsoft Business Central ISV .app

## Build
We support the latest Business Central SaaS major release and the preceding major release. As of 28 August 2026, BC28 is the latest release, so BC27 is the oldest supported version. OnPrem releases are out of scope.
For local compilation, temporarily set `platform`, `application`, `runtime`, and `preprocessorSymbols` in both `Application/app.json` and `Test/app.json` to match the target version. The runtime is the BC major version minus 11, so BC28 uses runtime 17.0. The Base Application dependency is implicit through `platform` and `application`.
Use the /bcdev claude skill to download symbols, compile, publish and run tests.
Use the -suppressWarnings flag when compiling unless directed to show warnings.  
When setting `preprocessorSymbols` for local compilation, define only the target version, for example `["BC28", "BC2800"]`. Each symbol selects code for that specific version, so additional symbols enable code paths that do not apply to the target. The codebase still contains guards for unsupported legacy versions. Those guards need deliberate cleanup and do not mean the versions are supported.



## Info
- We have our own API module in Application/src/_API and Application/src/_API_SERVICES which we use to expose modern REST apis instead of odata pages/codeunits.  
The Fern .yml API documentation for our .al endpoints lives in a separate repository: https://github.com/navipartner/documentation  
- We have a big control addin that runs our react based POS frontend, communicating with .al via Application/src/POS Core/POSDragonglass.Page.al
- Our tests are in a separate BC .app in the repo root /Test/app.json.
- Our PR pipelines validate the supported BC SaaS version window. For the few areas that need version-specific code, use compiler preprocessor symbols.
- Our app contains a Sentry.io telemetry integration which we use instead of BCs application insights.  
When troubleshooting performance, you can narrow down what exactly is taking time by using codeunits:  
Application/src/Sentry/_public/Sentry.Codeunit.al  
Application/src/Sentry/_public/SentrySpan.Codeunit.al  
to create a span around the interesting piece of code.  
For errors, you can log them to Sentry via Sentry.AddLastErrorIfProgrammingBug(). This function is important because AL has the flaw that it mixes together not-a-bug translated user mistakes with actually-bug errors and we only want to log the latter in Sentry, in english. The function tries to distinguish by parsing the english error text. A guaranteed way to get your error logged to a developer is to add "This is a programming bug" at the end of your english error label.

## Rules
- Do not commit any app.json changes as our pipeline manages this file for the final artifacts.
- We limit public object and procedures as much as possible, putting public objects inside a _public folder inside their module folder to make sure we know the developer truly intended his objects to be public rather than just forgetting to set Access = Internal;
- Always remember to update the Fern .yml API specification in https://github.com/navipartner/documentation when changing the .al APIs.
- All changes must remain compatible with every supported Business Central SaaS version. OnPrem is out of scope.
- For new big features/modules without existing test libraries & code in place, design the application code with injection of interfaces implementation mocks in mind at the top level, allowing the test code to implement mocks that read from temporary records and write into temporary records, skipping the database completely. This means passing records around by reference in all internal functions so the temporary records are kept intact.
- Never log API request/response bodies such as JSON/XML to blob/media fields as this is very slow in BC SaaS and our API module already logs all request/responses & metadata in cloudflare (our proxy around BC) & sentry.
- If you need to log an error of the exception kind (="If this happened there's a bug and a developer needs to know about it"), use our sentry codeunit and make sure the error message is written in non-translated english with "This is a programming bug" at the end of the message.
- Use the /al-id-manager claude skill to get next id when you create new objects, new table/tableextension fields and new enum/enumextension values.
- Naming conventions for AL variables:
  - **Global variables** (codeunit/table/page-level `var` block): prefix with underscore, e.g. `_Item`, `_POSUnit`. The underscore is how readers tell at a glance that a symbol is codeunit-lived state, not a local.
  - **Locals, parameters, and return variables**: NO underscore prefix. An underscore on anything other than a global is a bug — rename it.
  - When a parameter would naturally share the same name as a local inside the procedure, do NOT rename the local (the local keeps the clean domain name). Instead postfix the parameter with `Param`. Example: parameter `VATBusPostingGroupParam: Code[20]`, local `VATBusPostingGroup: Code[20]`. This keeps reads at the call site and inside the body both natural.
- User-facing errors must use `Label` declarations (translatable) and inject `TableCaption` / `FieldCaption` dynamically rather than hardcoding English field or table names in the format string — this keeps the message in sync with captions and translations. Example: `Label 'No %1 for %2 ''%3''...', Comment = '%1 = ..., %2 = ...';` called with `VATPostingSetup.TableCaption, VATPostingSetup.FieldCaption("VAT Bus. Posting Group"), ...`. The only English error strings that should be left un-Label'd are the "This is a programming bug" Sentry-targeted ones described above.
