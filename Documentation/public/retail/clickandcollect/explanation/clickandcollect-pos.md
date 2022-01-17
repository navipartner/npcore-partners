# POS actions for the Click & Collect module

The following POS actions in the **Menu Buttons Setup** administrative section need to be used in order to enable the Click & Collect functionalities in the store:

> [!Note]
> To edit parameters of the POS actions, first click on the POS action you wish to edit, and then **Process** button in the ribbon, followed by **Parameters**. 

- **Create Click N Collect Order** with the **CREATE_COLLECT_ORD** action code is mainly used for creating Click & Collect orders via POS in the local store.     

In the **POS Parameter Values section**, you can pre-set the order amount percentage that needs to be made by a customer as prepayment. in the **prepaymentPercent** row. If not set, customers will be prompted to insert a percentage which will be taken as prepayment in the sales order.  

- **Process Click N Collect Order** with the **PROCESS_COLLECT_ORD** action code is mainly used for processing collect orders via the POS in the collecting store.
- **Pickup Click N Collect Order** with the **DELIVER_COLLECT_ORD** action code is mainly used for delivering the processed collect orders via the POS in the collecting store. 

### Related links
-[Set up the Click & Collect module in NP Retail](../howto/clickandcollect_setup.md)