
# Authorization Code for Ticket Rescheduling

Ticket rescheduling is made easy for self-service online for online users.  
This is done by a [web setup](../howto/ChangeTicketReservation.md) and adding an authorization code (pin code) printed on the ticket. The authorization code is explained in more detail in the following text.

The maximum length for the produced **Authorization Code** is 10 characters. The template can be specified on the **Ticket Setup** page, and is characterized by the following:  

- The template starts with the **[** character and ends with the **]** character.  
- The first character after **[** determines what type of random characters or digits to generate;  
    - N for digits 0–9  
    - A for uppercase letters A-Z        
    - X is a combination of N and A  

> [!NOTE]
> A number will repeat the random character. Characters outside of the **[** and **]** will be copied verbatim. The **[ ]** characters may not be used.     
       **Examples:**     
[N*4]-[N*4] will produce a code similar to "1234-5678" (this is the implied default value).  
NP-[X*3] will produce a code similar to "NP-X2Y".  

## Access the ticket authorization code in Business Central

The authorization code is also generated back-office for the backend worker to see:

1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button and search for **Ticket List**.     
   The list of existing tickets is displayed.  
2. Find the ticket you need to retreive the authorization code for.
3. Go to the **Navigate** tab and open **Ticket Request**.         
   You can now see the unique authorization code in its respective column. 

>[!NOTE]
> The **Authorization Code** is not for back office users working in Business Central. It is intended for the customer to change their own reservation online (which requires that the feature is set up on the website). This will produce a random number such as "2842-3921" which can be put on a print ticket in the [**Ticket Designer**](../tutorial/TicketDesigner.md). 
### Related links

- [Set up DIY printed tickets](../howto/SetUpDIYPrintedTicket.md)  
- [Ticket Designer](../tutorial/TicketDesigner.md) 
- [Change Ticket Reservation](../howto/ChangeTicketReservation.md)