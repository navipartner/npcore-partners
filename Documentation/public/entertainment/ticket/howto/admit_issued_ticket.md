# Admit an issued ticket

It is possible to admit issued tickets both from the POS and Business Central. 

## Admit an issued ticket from the POS

The POS contains several command buttons that are used for ticketing. To admit an issued ticket from the POS, follow the provided steps: 

1. Add a POS button that has the **Action Code** set to **TM_TICKETMGMT**, and the **Parameter** set to **Register Arrival**. 
2. Click this button.    
   A popup for inputting the external ticket number is displayed. When confirming the dialog, the ticket will be validated for arrival to the specified admission code (it can be set under the POS action parameters). If no admission code is defined, the default one from **Ticket Admission BOM** will be used. 
3. You can also admit a ticket for arrival on the POS from the EAN Box. To do this, add **Ticket_Arrival** as the **Event Code** in **POS Input Box Setup** to enable scanning the ticket from the EAN Box. 

## Admit an issued ticket from Business Central

To admit an issued ticket from Business Central, follow the provided steps: 

1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Ticket List**, and choose the related link.   
2. Search for the ticket using its **External Ticket No.**.
3. Click **Navigate**, and then **Access Entries**.    
   The **Ticket Access Entry List** is displayed as a result.
4. Click **Process**, and then **Register Arrival**.   
   The ticket is admitted as a result.

### Related links

- [Issue a ticket from the POS](issue_ticket_from_pos.md)
- [Create a prepaid ticket](create_prepaid_ticket.md)
- [Create a postpaid ticket](create_postpaid_ticket.md)