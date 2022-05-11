# End-of-day report troubleshooting

- **What happens when there is shortage in cash during generation of the end-of-day report?**       

When you finish the day with difference between the amount of cash collected and the amount of cash recorded in the accounting system, the difference will be recorded in the general ledger account once the end-of-day report is generated. The general ledger account (**G/L account**) is set up in the **POS Posting Setup**. 

- **Is it possible to generate a report that shows the total sales by each payment method?**     

Yes. For this purpose, it's recommended to use the **POS Entry Payment Details** report, which can provide a full list of payments performed over a selected period of time if you filter the report results according to the **POS Payment Method Code** parameter.

- **Is it possible to close the day/shift by closing the POS store, instead of closing each POS unit individually?**       

Yes. To do this, follow the provided steps:
    1. Open one of the POS units which belong to the same store, and navigate to the **Profiles** section. 
    2. Open the **End of Day Profile** dropdown list, and click **New**.
    3. Select **Master & Slave** in the **End of Day Type** field.
    4. Select which POS unit will be the master one in the **Master POS Unit No.** field.      
       The selected POS unit needs to have the same profile selected as the other POS units, and they need to share the same **POS Store Code**.