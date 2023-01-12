# Set up Membership module web services

To set up the ticket web services, follow the provided steps:

1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Web Services**, and choose the related link.    
   The list of all available web services is displayed.
2. Click **New** in the ribbon. 
3. Select **Codeunit** in the **Object Type** field, and provide **6060128** as the **Object ID**.
4. State **member_services** as the **Service Name**.    
   
   > [!Note]
   > In a multitenant environment, you need to perform this from the **default** tenant. You can see which tenant you're currently using in the URL.

5. Refer to the [list of member web services](../reference/member_webservice.md) to decide on the next action you wish to take. 
6. (Optional) Set up [auto-renewal process](auto_renewal.md).