# Glossary 

This topic contains the list of Business Central and NPRetail specific terms that should be used in your topics to ensure that our documentation is standardized.

- **Role Center** - the Business Center landing page.
- **Role Explorer** - opened from the **Role Center** by clicking the burger icon (three vertical lines in the top-right corner). Each element on the role explorer is an action that opens a page. Accordingly, you can also use the role explorer as a means to navigate in Business Central.
- **Tell Me** - the popup window that displays when you click the **Search** button.
- **Major Tom** - Windows desktop POS software developed by NaviPartner. It is written in C# and it embeds the web client, prevents accidental interaction with the browser, and serves as a middleware between the web browser and the local hardware.
- **EFT (Electronic Funds Transfer)** - Credit card terminals, MobilePay, AliPay etc.
- **Tax Free** - A POS service where tourists taking home certain purchased goods, can get a VAT refund when leaving the country.
- **Hardware Connector** - Local desktop service developed by NaviPartner. Allows hardware access from the browser.
- **Flexiiterm** - Legacy PSAM integration for old NETS terminals.
- **BAXI** - NETS latest terminal type which NPRetail has an integration for.
- **RFID** - Radio-frequency identification. In NPRetail, RFID is used to tag items for easier inventory and tracking.
- **NP Core** - This repository. Contains the entire back-end architecture to support POS processes.
- **Transcendence** - Stand-alone control add-in written to support previous version of NP Retail in C/SIDE and C/AL. Transcendence is no longer maintained, except for critical fixes.
- **Dragonglass** - Control add-in that supersedes Transcendence as POS frontend. Dragonglass also embeds chunks of Transcendence as failover to support execution of Workflows v1 front-end actions.
- **Workflows** - A feature of NP Retail front end responsible for coordinating business logic that executes in response to button clicks in POS. There are two versions of workflows. Both version of workflows allow AL developers to write JavaScript code that executes in the front end, that invokes any back-end code only when necessary.
- **Workflows v1** - First iteration of workflows, based on custom-built API, that allows structuring AL code in the back end to support asynchronous behavior of JavaScript that's executing in the front end. Workflows v1 are an essential part of the Transcendence front-end framework. Workflows v1 were designed primarily with AL developers in mind, requiring minimum understanding of JavaScript while still being able to write most of front-end logic.
- **Workflows v2** - 	Second iteration of workflows, based on JavaScript built-in [Promises API](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise) . This iteration is far more robust, it coordinates the entire execution of business logic from the front end, and includes some features Workflows v1 was uncapable of, such as parallel execution, nesting, sequencing, and similar. Workflows v2 are an essential part of Dragonglass.
- **Stargate** - Communication layer that spans all three levels of NP Retail: back end (AL), front end (JavaScript) and Major Tom (C#). Is currently being outphased, for the hardware connector.
- **Crane** - An internal tool that helps to manage MS Business Central/Dynamics NAV development environments using Docker containers. They can be ordered from the case system.
- **Dimensions** - Values that categorize entries so you can track and analyze them on documents, such as sales orders. Dimensions can, for example, indicate the project or department an entry came from. For more information, refer to the [Microsoft documentation](https://docs.microsoft.com/en-us/dynamics365/business-central/finance-dimensions).
- **Magento**/**The web**- 
- **The backend** - is that NP Ecommerce?
- **Clickonce** - A deployment technology that enables you to create self-updating Windows-based applications that can be installed and run with minimal user interraction.
- **Click & Collect** - A hybrid e-commerce model in which people purchase or select items online and pick them up in-store.
- **Dynamics NAV** - an easily adaptable ERP solution which helps small and medium-sized businesses to automate and connect their sales, purchasing, operations, accounting, and stock management. The latest version of Dynamics NAV is Dynamics 365 Business Central.
- **GDPR (General Data Protection Regulation)** - A legal framework that sets guidelines for the collection and processing of personal information from individuals who live in the European Union. It mandates that the EU visitors be given a number of data disclosures.
- **BOM (Bill of Materials)** - A centralized source of information used to manufacture a product.

