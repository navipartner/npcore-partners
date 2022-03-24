# Change Ticket Reservation

With this functionality it is easy for you to change a customer's ticket reservation in regards to time and date. To change the existing reservation, follow the provided steps.

 
**Procedure in BC**

>[!IMPORTANT]
>The default setting is to not allow rescheduling. It is administrated on the **Ticket BOM** page.

1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Ticket BOM** and choose the related link. Then navigate to the **Reschedule Policy** column.  
2. You can choose between three options:

- **Not Allowed** - this is the default option.
- **Always (Until used)** - the ticket can not be rescheduled after it has been used.
- **Cut-Off (Hours)** - if selected, you need to specify the number of hours before ticket expires in the field **Reschedule Cut-Off (Hours)**. It is implied that the ticket is unused.  
    - **Reschedule Cut-Off (Hours)** - you need to specify a number of hours before ticket arrival is no longer possible. The value 24 would allow rescheduling up to 24 hours before the event ends. The default mode is to allow the admission until the event ends, and this can be controlled by the **Event Arrival Until Time** option located in the **Ticket Schedules** administrative section. Note that hours can be expressed in decimals. Also note that they can be negative, which makes it possible to reschedule after the event has been concluded. For example, the value -24 would allow rescheduling up to 24 hours after event has completed – provided the ticket was unused.  
The default **Authorization Code Scheme** is "[N*4]-[N*4]" and can be changed in **Ticket Setup**  

>[!NOTE]
> The [**Authorization Code**](../explanation/AuthorizationCode.md) is not for back office users working in Business Central. It is intended for the customer to change their own reservation online (which requires that the feature is set up on the website). This will produce a random number such as "2842-3921" which can be put on a print ticket in the [**Ticket Designer**](../tutorial/TicketDesigner.md) .  
 

3. Find the customer's ticket in the **Ticket List** (for example, by using the **External Ticket No.**).  
4. Click **Process** and choose **Change Ticket Reservation**.  
   A popup window is displayed. 
5. Click the **Scheduled Time Description** cell describing the open record.  
   You can now view the other admission lines.  
6. Choose the new time and date that the customer would prefer to change to.
7. Click **OK**.     
   Ticket reservation has been successfully changed.
