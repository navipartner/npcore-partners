# Change Ticket Reservation

This topic describes how you can change a customer's existing reservation. With this function it is easy for you to change a customer's ticket reservation in regards to time and date.

 
**Procedure in BC**

>[!IMPORTANT]
>The default setting is to not allow rescheduling. It is administrated on the **Ticket BOM** page.

1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Ticket BOM** and choose the related link. Then navigate to the **Reschedule Policy** column.  
2. Here you will have to choose between three options:

- **Not Allowed** - this is the default option.
- **Always (Until used)** - the ticket can not be rescheduled after it has been used.
- **Cut-Off (Hours)** - if selected, you need to specify the number of hours before ticket expires in the field **Reschedule Cut-Off (Hours)**. Implies that ticket is unused.  
    - **Reschedule Cut-Off (Hours)** - you need to specify a number of hours before ticket arrival is no longer possible. The value 24 would allow rescheduling up to 24 hours before the event ends. The default mode is to allow the admission until the event ends, and this can be controlled by the **Event Arrival Until Time** option located in the **Ticket Schedules** administrative section. Note that hours can be expressed in decimals. Also note that they can be negative, which makes it possible to reschedule after the event has completed. For example, the value -24 would allow rescheduling up to 24 hours after event has completed – provided ticket was unused.
The default **Authorization Code Scheme** is "[N*4]-[N*4]".  

>[!NOTE]
> The **Authorization Code** is not for the person working back office in BC. It is useful for the customer to change their own reservation online (This requires that the feature is set up on the website). This will produce a random number such as "2842-3921". 

The maximum length for the produced **Authorization Code** is 10 characters. The template options include:  
Template starts with a the "[" character and ends with a the "]" character.   
The first characters after [ determines what type of random characters or digits to generate;  
N for digits 0 – 9  
A for uppercase letters A-Z        
X is a combination of N and A  

- A number will repeat the random character. Characters outside of the [ and ] will be copied verbatim. The [ ] characters may not be used.  

Examples:  
[N*4]-[N*4] will produce a code similar to "1234-5678" (this is the implied default value)  
NP-[X*3] will produce a code similar to "NP-X2Y"  

The template can be specified on the **Ticket Setup** page.  
- In the ticket designer you can add the Authorization Code/Pin code for the customer. 


**Procedure in BC continued**

3. Find the customers ticket in **Ticket List** (using eg. External Ticket No.)  
4. Click on **Process** and choose **Change Ticket Reservation**.  
A popup window will now open. 
5. Click on the **Scheduled Time Description** cell describing the open record.  
You can now view the other admission lines.  
6. Now choose the new time and date that eg. the customer wants to change to.
7. Press **OK**.