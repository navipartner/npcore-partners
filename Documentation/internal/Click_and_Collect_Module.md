## Click & collect module

The Click & Collect module enables customers to collect online orders in stores, thus avoiding delivery charges and making the delivery time shorter. An order can also just be placed in one store, and collected in another one. 

**Prerequisites:**

 - Make sure the web service for Click & Collect exists in the company.
 - A user whose **License Type** is **External user** needs to be created.
   You need to make sure that a password in **Business Central Password Authentication** is set for the user, as well as adequate permissions in the **User Permission Sets** panel of the **User Card**. 
 - The **Role** in the **My Settings** page needs to be set to **NP Retail** so that you can have access to the necessary configurations for the Click & Collect module.

To configure a Click & Collect module, you need to complete the following tasks:

- Create a new **Collect Store**.
- Create a new **Collect Workflow Module**.
- Create a new **Collect Workflow**.


To create a new collect store:

1. Search for **Collect Stores** and click **New**.      
   The **Collect Store Card** popup window is displayed. The card contains extensive options for setting up a collect store.
2. Add the company name in the **Company Name** field.     
   The **Service Url** field is populated automatically according to the company name.
3. Add service username and password in the designated fields.
4. Activate the **Local Store** toggle switch if the store you're creating is the one which distributes the ordered items to the collecting store. If you're creating a card for the collecting store, don't activate the **Local Store** toggle switch.
5. Fill out the rest of the fields according to your business needs.

  ## Create collect workflow

The collect workflows define the behavior/functionality of collect orders being sent to a given store. 

To create a collect workflow:

1. Search for **Collect Workflows** and click **New**.
   The **Collect Workflow Card** window is displayed.
2. In the **General** section, specify the code and description (for example WF TEST or SMS).
3. In the **Send Order** section, specify whether the collecting store should be notified via email or SMS about the order pick-up.
4. In the **Order Status** section, specify whether the customer should be notified on each order status.      
> [!NOTE]
> The template needs to be defined for a status. If the **Notify Customer via Email/SMS** toggle switch is active and the template isn't defined, the notification will not be sent.        
5. Search for the **SMS Setup**/**E-mail Setup** depending on which type of notification you wish to send to the customer when the order status is changed.   
> [!NOTE]
> SMS is run by a **Job Queue** in BC17.    
6. Search for the **POS Unit List**, find the POS unit you need, and in its **POS Audit Profile**, enable the **Allow Zero Amount Sales** toggle switch.   
   For the system to post and deliver the initial sales order, it's necessary to execute a zero sale at the end of the process.
7. 



## Audit Profile

In order to post and deliver the initial sales order, it's necessary to execute a zero profit at the end of the day. Consequently, we need to allow a zero amount sales to conclude the sales order process. This is done in the **POS Unit** setup for the audit profile.