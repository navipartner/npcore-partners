# Inventory setup

The **Inventory Setup** administrative section serves as a tool for the establishing the initial configurations that should be applied in order to improve the inventory management processes. The following options have crucial impact on how the inventory is going to be managed in your WMS environment:

- **Automatic Cost Posting** - this field presents a link between the **Item Ledger** and the **Journal Ledger**. If the automatic cost posting is activated, each time a line is inserted in the **Item Ledger**, a line will automatically be created in the **General Ledger Entries**. If you deactivate this option, you will need to post the values manually at regular intervals with the **Post Inventory Cost to G/L** action.

- **Expected Cost Posting to G/L** - This option is useful when managing interim accounts. Whenever a document is posted, a value entry line will be created with the expected cost (**Cost Amount (Expected)**). This expected cost affects the inventory value, but it will not be posted to the general ledger unless this option is selected. 

- **Automatic Cost Adjustment** - if activated, the cost on the **Outbound Ledger Entries** will be updated with the cost of inbound ledger entries when an item transaction is posted. This option is the most useful when used with the FIFO cost updates.
  - **Never** - cost adjustment will not occur automatically. You can schedule cost adjustment in the **Adjust Cost - Item Entries** administrative section.
  - **Always** - as soon as you post an entry to the **Item Ledger Entries**, the cost adjustment report will be triggered. 
