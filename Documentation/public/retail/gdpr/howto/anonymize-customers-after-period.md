# Anonymize customers automatically after a certain period

You can anonymize multiple customers simultaneously after a certain period. To do so:

1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Customer GDPR Setup** and choose the related link.
2. Filter by customer posting groups and general business posting groups in order to restrict the list of customers to be anonymized. 
3. Click **Extract Customers** to get a list of customers which will be anonymized based on the applied filters.    
   The extraction gives you an overview of how many members will be anonymized. You can run the task using the **No_of_Customers** parameter.      
   The code unit to set up the task for running automatic customer anonymization is 6151060, and can be set up using the two parameters individually. 

   - **CHECK_PERIOD = No** - this task anonymizes customers with **To Anonymize On** field having a value irrespective of the GDPR period setup and the customer doesn't have any documents open. 
   - **CHECK_PERIOD = Yes and No_of_Customers** - this task anonymizes all customers which don't have transactions after the period X after the GDPR setup, and who don't have any transactions open, irrespectively of whether the **To Anonymize On** field has a value under the **Customer Card**

   ### Related links
   - [General Data Protection Regulation](../intro.md)
   - [Anonymize customer data](/public/retail/gdpr/howto/anonymize-customer-data.md)