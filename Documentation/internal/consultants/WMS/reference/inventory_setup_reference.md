# Inventory setup (reference guide)

The **Inventory Setup** administrative section serves as a tool for the establishing the initial configurations that should be applied in order to improve the inventory management processes. The following options have crucial impact on how the inventory is going to be managed in Business Central:


| Field Name      | Description |
| ----------- | ----------- |
|  **Automatic Cost Posting**   | Enabling this toggle switch establishes the integration between the **Item Ledger** and the **General Ledger**. For each posted entry in the **Item Ledger**, a corresponding one will automatically be posted to the inventory account, adjustment account, and the COGS account in the **General Ledger**. If you don't wish the entries to be posted automatically, you can manually post the values at regular intervals with the **Post Inventory Cost to G/L** batch job. Note that it's recommended to run the Automatic Cost Adjustment Report before posting inventory cost to the General Ledger.  |
|  **Automatic Cost Adjustment**  | If active, the cost of the **Outbound Ledger Entries** will be updated with the cost of **Inbound Ledger Entries** when an item transaction is posted. The following options are available: **Always** - as soon as you post an entry to the **Item Ledger Entries**, the cost adjustment report will be triggered; **Never** - cost adjustment will not occur automatically (you can schedule cost adjustment in the **Adjust Cost - Item Entries** administrative section); **Week**/**Month**/**Quarter**/**Year** - time periods after which costs will be adjustment automatically.    |
|  **Default Costing Method**  |  Specifies which [costing method](../explanation/fifo_and_lifo.md) will be used for calculating the unit cost by making assumptions about the flow of physical items through a company. A different costing method defined on the **Item Card** will override this selection if specified. |
|  **Prevent Negative Inventory** | Specifies if it's possible to post transactions that will bring inventory levels below zero.   |
|  **Skip Prompt to Create Item**  |  Specifies if a message about creating a new item card is displayed when you enter an item number that doesn't exist.  |
|  **Copy Item Descr. to Entries**  |  Specifies if the description on item cards will be copied to the Item Ledger Entries during the posting process.  |
|  **Location Mandatory** |  Specifies if a location code is required when posting item transactions. In combination with the **Components at Location** field in the **Manufacturing Setup** administrative section, it greatly impacts the way in which the planning system handles demand lines with/without location codes.  |
|  **Item Group Dimension Code**   |  Specifies which dimension will be used for product groups in analysis reports.  |
|  **Item Nos.** |  Specifies the number series that will be used to assign numbers to items.  |
| **Posted Direct Trans. Nos**   | Specifies the number series from which numbers are assigned to new records.  |
| **Direct Transfer Posting** |  Specifies whether direct transfer is posted separately in forms of shipment and receipt or as a single direct transfer document. |


