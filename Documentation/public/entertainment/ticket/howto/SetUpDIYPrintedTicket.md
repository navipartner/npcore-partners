# Set up DIY printed tickets (and Ticket Designer)

When setting up a ticket to a ticket design in Ticket Designer you:
1.	Apply a **ticket type** to the item card. 
>[!NOTE] 
>When the customer purchases a ticket the ticket/reservation is created in BC.
2.	Create the ticket design with the same name as the ticket type in the **Ticket Designer**.
3.	During the creation of the ticket (during a webshop order) Magento will recognize the **ticket type** and connect it to the **Ticket Designer** where a design has been created with **the same name as the ticket type**. 

If you however wish for tickets, created back office (e.g. Pre paid tickets), to have a separate design from the other ticket design you need to:
1.	Create **a new ticket design** in the **Ticket Designer** and provide it with a new name separate from the **ticket type**
2.	Add the new ticket design name to the cell in the **Ticket Layout Code**.
3.	When you create new tickets back office these will now be provided with the design defined in **Ticket Layout Code** instead of the ticket type design. 

[For a guide on the **Ticket Designer**](../tutorial/TicketDesigner.md)
