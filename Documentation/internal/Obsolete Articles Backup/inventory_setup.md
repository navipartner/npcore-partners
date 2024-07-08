# Inventory setup

The inventory setup determines where items should be posted when receiving or selling items. When inventory transactions such as inventory adjustments are changed, the item costs are recorded. To ensure this change of inventory values is reflected correctly in your financial books, the inventory costs are posted to the relevant inventory accounts in the general ledger. It is possible to also get an overview of what values can be posted to the G/L without performing the posting itself. 

> [!Note]
> While inventory ledgers are documents which track inventory transactions only, general ledgers function as a collective summary of transactions for a single business posted to subsidiary ledger accounts, including the inventory ledgers. 

The three main things that need to be configured in the **Inventory Setup** are:

- **Automatic Cost Posting** - This setting is used as a bridge between the item ledger and the general ledger. BC can either create the G/L entries for each entry inserted in the inventory ledger, or this will be done by running the **Post Inventory Cost to G/L** report.     
    The default selection is **Never**, which indicates that the cost posting will not be run automatically. If you select **Always**, as soon as you post an entry in **Item Ledger Entries**, the cost adjustment will be triggered. Alternatively, it's possible to select a period of time after which the cost posting will occur automatically.
    
    > [!Note]
    > If you select **Never**, you can schedule cost posting manually in the **Adjust Cost - Item Entries** administrative section.


- **Expected Cost Posting to G/L** - This settings is intended for determining the financial impact. It determines whether interim accounts (those accounts which cover an activity within a period of less than one fiscal year) will be used. 


- **Automatic Cost Adjustment** - This setting enables automatic cost update on the outbound ledger entries with the cost of inbound ledger entries (FIFO cost update).

It is also possible to configure whether the location is mandatory when posting the cost. If the business uses only one warehouse, it's recommended to activate the **Location Mandatory** toggle switch.



Inventory and items

