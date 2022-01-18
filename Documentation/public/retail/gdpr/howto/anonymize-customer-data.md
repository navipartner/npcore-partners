# Anonymize customer data

In accordance with the General Data Protection Regulation, it is possible to perform anonymization of customer data. Anonymization refers to the process of removing direct and indirect personal identifiers that may be used to lead to identification of an individual being.

To do anonymize customer data, follow the provided steps.

> [!Important] 
> Anonymization process is an irreversible process and has to be performed in a Test Company prior to doing the same in Live Company.

1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **User Setup** and choose the related link.       
   The list of users you can set up is displayed.    
2. Tick the **Anonymize Customers** checkbox to enable the functionality of anonymizing customers in the system. 
3. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Customers** and choose the related link.     
   The list of customers in the current environment is displayed. 
4. Open the **Customer Card** of the customer whose data you wish to anonymize. 
5. Click the **Actions** button in the ribbon, and then **Customer Anonymization** in the dropdown that displays.      
   If the **Anonymize Customers** checkbox isn't enabled in **User Setup**, or if some documents related to this customer are still in use, this action will not be possible. 
6. Click **Yes** in the popup window that is displayed.     
   A confirmation message is displayed and the customer's data is now anonymized.     
   You can see if the customer is anonymized through the status of the **Anonymized** toggle switch, and you can check when the customer was anonymized in the **Anonymized Date** field. 

### Anonymizing customers automatically after a certain period

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