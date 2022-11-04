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

  > [!Note]
  > The **Code** field is required.

3. Provide the company name in the **Company Name** field.      
   The **Service Url** field is populated automatically if the store is in the same tenant, but it needs to be provided manually if that's not the case. 
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

1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Collect Workflows** and choose the related link.            
   The card contains various options for managing collect workflows.
2. Click **New**, populate the fields according to your business needs.

   Among others, the options are available:   

| Field Name      | Description |
| ----------- | ----------- |
| **Notify Store via Email/ Notify Store via SMS** | If the collecting store should receive a notification, you need to tick one of these checkboxes, depending on the desired notification method. | 
| **E-mail Template/ SMS Template** | Use this field to define the email/SMS template to be sent. | 
| **Customer Mapping** | Use this field to define how customers should be mapped during the order import in the collecting store. |
| **Processing Expiry Duration** | Use this field to define the duration of the processing time. |
| **Archive on Delivery** | Define if the collect order will be automatically archived when delivered, rejected or if the order expires. |
| **Notify Customer via Email/SMS** | If enabled, the customer will receive a notification for each order status. Note that the template definition is very important. If the template hasn't been defined for a status, even if the checkmark is ticked, a notification will not be sent. |

3. Use the options in the **Send Order** section to determine whether the store will receive email notifications about the order, define what the email template looks like, how the customers are mapped during the order import in the collecting store, and so on. 
4. Define the options in the **Order Status** section if you wish to notify the customer about each step of the order delivery process, and to define templates for each one of those notifications. 
5. Use the options in the **IC Clearing** section to determine how the intercompany reconciliation is performed across multiple companies when orders/items are transferred, sold, and shipped.

## Next steps

### Set up the POS Audit Profile

The logic of prepayment of 100% is that all payment is done at the moment when the order is placed. For the system to post and deliver the initial sales order, a "zero" sale needs to be executed at the end of the process. Therefore, it is necessary to tick the **Enable Zero Amount Sales** checkbox in the [POS Audit Profile](../../posunit/reference/POS_audit_profile.md).

### Related links

- [Click & Collect introduction](../intro.md)
- [POS actions for the Click & Collect module](../explanation/clickandcollect-pos.md)