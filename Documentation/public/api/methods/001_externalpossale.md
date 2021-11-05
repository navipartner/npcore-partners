# Create POS Entries from External Systems

The external POS Sales functionality provides a way to create POS Sales from external systems. The External POS Sales are later converted into POS Entries.

The process can be detailed in 3 steps:
1. Create External POS Sales using the Business Central API.
2. Convert External POS Sales into POS Entries. (open an External POS Entry and see the action **Convert To POS Entry**.
3. Based on the setup in the **Store**, field **Auto Process External POS Sales**, the system creates an Import Type which is then used to automatically create and process Import Entries (import entries are linked to the External POS Sale using the **Document ID** = **External POS Sale Entry No.**). The result is that External POS Sales can be automatically converted into POS Entries.

Link to External POS Sale API openapi playground:
[External POS Sale API](/api/sandbox.html?spec=external_pos_sale.json)

