# Set up tickets using the Ticket Setup Wizard

This tutorial will teach you how to create the setup for a fully functional ticket.

1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Ticket Setup** and choose the related link.
2. From the **Ticket Setup** page, open the **Ticket Wizard** by clicking the corresponding action in the ribbon.    
   The **Ticket Setup Wizard** is displayed.
3. Fill in the **Code** for the ticket type.     
   You can either choose an existing ticket type from the dropdown list or create a new one.   

> [!NOTE]
> You can create a new ticket type in the **Ticket Setup Wizard** by typing the name of choice in the **Code** field, and then filling out the **Ticket Type** fields in the **Advanced** section of the window.

4. In the **No.** field, write the item number of your choice or opt for automatic generation.     
   By default, a generic next-in-line item number will be generated and set to **<GENERATE>**. This number can be changed to an item number of your choice.  
5. Fill in **Description** with the description for your ticket. 

> [!IMPORTANT]
> This description will also be the name on the webshop. However, you can change this in the **Item Card** under the **Magento** tab.

6.	Choose the **Item Group** for your ticket.
7.	Fill out the **Unit Price** for the ticket.
8.	Pick the **Start Date** and **Until Date**.
9.	Move on to the **Schedules** table and set the **Start Time** and the **Stop Time** of the ticket.
10.	Check off which weekdays the tickets will be usable on.

> [!NOTE] 
> If needed, you can create several schedule lines with different start and stop times, and different weekdays, but still within the period between the start and until dates.

11. Set your **Capacity Control**. 
    For capacity control by amount, the capacity will usually be set to **Sales**, and for limited capacity it will be none.
12.	Set your **Capacity Amount**. 
    The provided value determines the number of available tickets.
13.	Set **Prebook From** to determine how long in advance it will be possible to book the tickets.         
    **Example:** 14D = 14 Days; 3M = Three months.
14.	Check **Prebook is Required** if you wish to make the reservation mandatory. If checked, the reservation will be created on sales and admission will only be allowed at the time specified on the reservation entry. The default schedule rule applies.
15. In **Advanced** you can choose whether you want the admission code to be generated automatically or if you wish to create one manually. 
16.	Click **OK**.    
    The ticket is now created.


## Next Steps
 - [Issue tickets from Business Central](../howto/issue_ticket.md)
 - [Issue tickets from POS](../../../../public/404.md)

### Related links
- [Ticket admission](../explanation/admission.md)
- [Admission dependency code](../explanation/AdmissionDependencyCode.md)
- [Set up refund policy](../howto/SetUpRefundPolicy.md)