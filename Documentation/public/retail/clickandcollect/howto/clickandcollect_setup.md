# Set up the Click & Collect module in NP Retail

To set up the Click & Collect module in NP Retail, follow the provided steps:

## Prerequisites

 - Make sure the web service for Click & Collect exists in the company. You can check this in the **Web Services** administrative section.       

![Click & Collect Web Service Example](../images/collect_store_webservice.png "Click & Collect WS")

 - Make sure there's a user whose **License Type** is set to **External User** in the environment.      
   You need to make sure that a password in **Business Central Password Authentication** is set for the user, as well as adequate permissions in the **User Permission Sets** panel of the **User Card**. 
 - The **Role** on the **My Settings** page needs to be set to **NP Retail** so that you can have access to the necessary configurations for the Click & Collect module.

The Click & Collect module configuration consists of the following tasks:

- Create a new **Collect Store**.
- Configure the **Collect Workflow Module**.
- Create a new **Collect Workflow**.

Each one is individually addressed in further text. 

## Create a new Collect Store

The following procedure contains necessary steps for creating a collect store that can be successfully used with the Click & Collect module.

1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Collect Stores**, and choose the related link.            
   The card contains various options for managing collect stores.  
2. To create a new store card, click **New**.             
   The **Collect Store Card** popup window is displayed. Use the provided fields to create a collect store.       
3. Provide the company name in the **Company Name** field.      
   The **Service URL** field is populated automatically if the store is in the same tenant, but it needs to be provided manually if that's not the case. 
4. Provide the service username and password in the designated fields. 
5. Activate the **Local Store** toggle switch if you're creating a source collect store, or leave it inactive if you're creating a target/collecting store.    
   If this toggle switch is active, the new **POS Relations** section displays in the **Store Card**. This section can be used for defining which POS store/unit the collect store is associated with.          

The following actions can be taken after completing the initial procedure. All of them can be accessed from the **Collect Store Card** ribbon. 

| Field Name      | Description |
| ----------- | ----------- |
| **Validate Store Setup** | Check if the **Service URL**, **Username**, and **Password** are correct. |
| **Update Contact Information** | Pull either **Cash Register**, **Location** or **Company Information** from the specified company. |
| **Show Address** | Open Google Maps based on the contact address, from where the geolocation can manually be copied from the URL. | 
| **Show Geolocation** | Open Google Maps based on the geolocation latitude and longitude. |
| **Stores by Distance** | Display a list of other stores with distance to the current store. | 

## Configure Collect Workflow Module

The **Collect Workflow Module** administrative section contains the codes and IDs used in the Click & Collect module for sending and collecting orders. Its default state is presented in the following screenshot, but it can be edited if needed.

![Click & Collect Workflow Module](../images/collect-workflow-module.png "Click & Collect Workflow Module")

## Create a new Collect Workflow

The collect workflows define the behavior/functionality of collect orders which are sent to a given store. You can create three different kinds of workflows - **None**, **Mail**, and **SMS**.

To create a new collect workflow, refer to the provided steps:

1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Collect Workflows**, and choose the related link.            
   The card contains various options for managing collect workflows.
2. Click **New**, populate the fields according to your business needs.   
3. Use the options in the **Send Order** section to determine whether the store will receive email notifications about the order, define what the email template looks like, how the customers are mapped during the order import in the collecting store, and so on. 

   | Field Name      | Description |
   | ----------- | ----------- |
   | **Notify Store via Email/ Notify Store via SMS** | If the collecting store should receive a notification, you need to tick one of these checkboxes, depending on the desired notification method. | 
   | **E-mail Template/ SMS Template** |  Use this field to define the email/SMS template to be sent. | 
   | **Customer Mapping** | Use this field to define how customers should be mapped during the order import in the collecting store. |
   | **Processing Expiry Duration** | Use this field to define the duration of the processing time. |

4. Define the options in the **Order Status** section if you wish to notify the customer about each step of the order delivery process, and to define templates for each one of those notifications. 

   | Field Name      | Description |
   | ----------- | ----------- |
   | **Archive on Delivery** | Define if the collect order will be automatically archived when delivered, rejected or if the order expires. |
   | **Notify Customer via Email/SMS** | If enabled, the customer will receive a notification for each order status. Note that the template definition is very important. If the template hasn't been defined for a status, even if the checkmark is ticked, a notification will not be sent. |

5. Use the options in the **IC Clearing** section to determine how the intercompany reconciliation is performed across multiple companies when orders/items are transferred, sold, and shipped.
6. If you've set the store to send notifications via SMS or email, you need to do additional setup in either the **Email Setup** or the **SMS Setup** administrative section:

   #### SMS Setup

   Populate all fields in the [**SMS Setup**](../../sms/howto/smshowto.md) administrative section if you've previously selected **Notify Store via SMS** in the **Collect Workflow Card**, and select the SMS templates you wish to use in notifications.
   
   #### E-mail Setup

   The email setup procedure slightly differs depending on whether the environment you're on is on-prem or SaaS. 
   ##### SaaS

   On SaaS environments, you first need to set up the email account. 

   1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Email Accounts**, and choose the related link. 
   2. Click **New**, and then **Add an email account**.
   3. Choose the **SMTP** option, and click **Next**.     
      The **Setup SMTP Account** popup window is displayed. 
   4. Provide the following information:       
      - the name that will be used to identify the account (**Account Name**)
      - the **Sender Type** (whether it's a currently logged-in user or another user, who will be specified)
      - the email address of the user (if **Specific User** is selected in **Sender Type**)
      - the URL to the SMTP server (**Server Url**)
      - the **Authentication** type, and the accompanying data if needed (e.g. username and password).
      - Specify if the mail server requires a secure connection that uses encryption or certificates. 
   5. Click **Finish**.      
      If you wish, you can also send a test email to check the validity of all provided information. 
   6. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **E-mail Templates**, and choose the related link. 
   7. Create a template that is going to be used for email notifications or use one of the existing options. 

   ##### On-prem

   For on-prem environments, you don't need to set up email accounts. However, you need to set up similar options in the **SMTP Mail Setup** administrative section instead.

## Next steps

### Set up the POS Audit Profile

The logic of prepayment of 100% is that all payment is done at the moment when the order is placed. For the system to post and deliver the initial sales order, a "zero" sale needs to be executed at the end of the process. Therefore, it is necessary to tick the **Enable Zero Amount Sales** checkbox in the [POS Audit Profile](../../pos_profiles/reference/POS_audit_profile.md).

### Apply Click & Collect on POS

To apply the Click & Collect feature in store, you need to use the following POS actions which are configured in [**Menu Buttons Setup**](../../posunit/reference/pos_menu_buttons.md) of the specific [**POS Menu**](../../posunit/explanation/POS_menu.md) section:

   #### Create Click N Collect Order (CREATE_COLLECT_ORD)

   This action is mainly used for creating Click & Collect orders on the POS in local stores. 

   In the parameter setup, you can preset the percentage of the order amount that you want the customer to prepay. For example, if you want the ordering shop to collect the entire prepayment amount, you need to set the percentage to 100. If not set, the user will be presented with a pop-up window to insert a percentage to be taken as a prepayment on the sales order. 

   #### Process Click N Collect Order (PROCESS_COLLECT_ORD)

   This action is mainly used for processing collect orders via the POS in the collecting store. You can define how the POS action is going to find the location filter to apply on collect orders. 

   #### Pickup Click N Collect Order (DELIVER_COLLECT_ORD)

   This action is used for delivering the processed collect orders via the POS in the collecting store. 


### Related links

- [Click & Collect introduction](../intro.md)
- [POS actions for the Click & Collect module](../explanation/clickandcollect-pos.md)