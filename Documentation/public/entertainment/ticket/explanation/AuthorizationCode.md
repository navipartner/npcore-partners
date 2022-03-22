
# Authorization Code for Ticket Rescheduling

Ticket rescheduling is made easy for self-service online for online users.  
This is done by a web setup and adding an authorization code (pin code) printed on the ticket.

[Read the  step on 'Change Ticket Reservation' for context](../howto/ChangeTicketReservation.md)

The maximum length for the produced **Authorization Code** is 10 characters. The template options include:  
- The template starts with a the "[" character and ends with a the "]" character.  

The first characters after [ determines what type of random characters or digits to generate;  
- N for digits 0 – 9  
- A for uppercase letters A-Z        
- X is a combination of N and A  

>[NOTE]
>A number will repeat the random character. Characters outside of the [ and ] will be copied verbatim. The [ ] characters may not be used.  
Examples:  
[N*4]-[N*4] will produce a code similar to "1234-5678" (this is the implied default value)  
NP-[X*3] will produce a code similar to "NP-X2Y"  

The template can be specified on the **Ticket Setup** page.  

The authorization code is also generated back-office for the backend worker to see:
1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button and search for **Ticket List**.  
2. Find the ticket you need to find the authorization code for.
3. Go to the **Navitage tab** and select **Ticket Request**. You can now see the unique authorization code in its respectful column. 

>[!NOTE]
> The **Authorization Code** is not for the person working back office in BC. It is useful for the customer to change their own reservation online (This requires that the feature is set up on the website). This will produce a random number such as "2842-3921" wich can be put on a print ticket in the **Ticket Designer**.  
[Read more about setting up DIY printed tickets](../howto/SetUpDIYPrintedTicket.md)  
[Read more about the Ticket Designer](../tutorial/TicketDesigner.md) 