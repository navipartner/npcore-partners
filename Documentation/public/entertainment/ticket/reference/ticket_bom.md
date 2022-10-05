# Ticket BOM (reference guide)

In this administrative section, the entire sales department of Business Central is joined with the Entertainment part, i.e. this is where the ticket admission schedule lines are connected to the item (by joining the **Item No.** with the created **Admission Code**). This topic contains the most important fields and options that should be defined in the **Ticket BOM** administrative section:

| Field Name      | Description |
| ----------- | ----------- |
| **Item No.** | Specifies the identification number of an item created in the ERP system that is used in the POS for selling a specific ticket. |
| **Variant Code** | Specifies the code that is added to the value in the **Item No.** column to determine the ticket type (e.g. according to the attendees age). Only one dimension of variants is supported by Microsoft. |
| **Admission Code** | Specifies the code of the admission the ticket can be used for. Tickets offer different levels of clearance, and they may allow access to multiple venues. |
| **Default** | When there are multiple admissions associated with one ticket, you can select the default one by ticking a checkbox in this column. |
| **Ticket Schedule Selection** | Specifies the default POS schedule selection behavior, intended to provide a smart-assist for the walk-up ticket process. The following options are available: **Same As Admission**, **Today**, **Next Available**, **Schedule Entry Required**, **None**. |
| **Sales From Date**/**Sales Until Date** | Specifies the date from which the ticket can be purchased and the date until which the ticket can be purchased respectively. |
| **Enforce Schedule Sales Limits** | Specify whether the dates specified in **Sales From Date** and **Sales Until Date** fields are enforced. |
| **Admission Entry Validation** | Specifies how many times the ticket can be validated when admitting the entry. |
| **Admission Method** | Determines which event needs to precede the ticket being recorded as admitted. The available options are **On Scan**, **On Sale**, **Always**, and **Per Unit**. |
| **Percentage of Adm. Capacity** | Specifies the percentage of maximum admission capacity for the provided item. |
| **POS Sale May Exceed Capacity** | If ticket, the maximum capacity can be exceeded when the ticket is sold in the POS. |
| **Max No. of Entries** | Determines the maximum number of entries to the admission that can be made before the ticket becomes invalid. |
| **Admission Dependency Code** | Specifies if some events/locations are mutually exclusive, or if there are locations/events managed by the ticket that need to be visited in a specific order. |
| **Revisit Condition (Statistics)** | Specifies how to determine a unique visitor when a ticket is used more than once. |
| **Duration Formula** | The formula provided here determines the period during which the ticket is valid. |
| **Allow Rescan Within (Sec.)** | Specifies the number of seconds after the scan during which the ticket can be rescanned, even though the ticket only allows a single admission. If no value is stated, the ticket can't be scanned (assuming a single entry is allowed). |
| **Description** | The information you provide in this field will be included in the printed ticket as additional information. |
| **Admission Description** | Specifies useful information about the admission that can be included on a printed card. |
| **Reschedule Policy** | If set to **Cut-Off**, you can specify how much in advance before the event starts will it be possible to reschedule. |
| **Reschedule Cut-Off (Hours)** | Specifies after how many hours it will be possible to reschedule if the **Cut-Off (Hours)** is selected in the **Reschedule Policy** column. |
| **Revoke Policy** | Specifies whether it's possible to receive a refund for a ticket. |
| **Notification Profile Code** | Specifies which events will trigger notifications to be sent to the ticket-holder. This option is useful in the CRM context. |
| **Refund Price %** | Specifies the percentage of the ticket price that is refunded to customers (provided that refunds are performed). |
| **Preferred Sales Display Method** | Specifies what is the ticket scheduling going to be displayed like - as a calendar or a schedule. |
| **Ticket Base Calendar Code** | You can specify the days on which the venue will not be working, e.g. for a public holiday. The system takes note of this, and makes sure the tickets on those selected days are never created. |
| **Customized Calendar** | Specifies variations to the base calendar, if any. |
| **Publish as eTicket** | Specifies that this ticket should be published using the Apple Wallet technology. |
| **eTicket Type Code** | Specifies the ticket design options used for displaying the ticket in the eWallet. |
| **Publish Ticket URL** | Specifies the URL to the server on which you can share the ticket with customers. |

