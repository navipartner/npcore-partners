# Create POS Entries from external systems via API

The external POS Sales functionality provides a way to create POS Sales from external systems. The External POS Sales are subsequently converted into POS Entries.

To create POS Entries from external systems follow the provided steps:

1. Create External POS Sales using the Business Central API.
2. Convert External POS Sales into POS Entries.    
   To do so, open an External POS Entry, and click **Convert To POS Entry**.
3. Based on the setup in the **Auto Process External POS Sales** field of the **Store**, the system creates an **Import Type** which is used to automatically create and process **Import Entries** (import entries are linked to the external POS sale with the **Document ID** = **External POS Sale Entry No.**). The result is that external POS sales can be automatically converted into POS entries.

Refer to the [External POS Sale OpenAPI playground](/api/sandbox.html?spec=external_pos_sale.json) to learn how to correctly consume the provided service.

