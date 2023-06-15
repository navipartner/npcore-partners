# POS info card (reference guide)

POS info is used for capturing additional information on sales, items or customers on the POS. This information on sales can be used for statistics or further analysis on sales. You need to define a POS menu button that the salesperson can press to assign additional information to the sale. Furthermore, you can predefine static information regarding items and customers.

The following fields are available in the **POS Info Card**:

| Field Name      | Description |
| ----------- | ----------- |
| **Code** | Specifies a unique code for the POS info entity. |
| **Description** | Describes the POS info entity, and provides more information about its purpose. |
| **Message** | Provide a message which will be displayed on the POS. If you wish the salesperson to be able to provide a message themselves, leave this field blank. | 
| **Once per Transaction** | Indicates whether the POS info is set to be used per a line or per a whole transaction. If active, the POS info entity will be applied per a whole transaction. |
| **Copy from Header** | If active and if the POS info code is applied to the **POS Sale Header**. This code is inherited by all new sales lines. |
| **Available in Front-End** | If active, the POS info codes can be identified and made available in the front end via a data source extension. Those POS info codes can be displayed on a POS menu button, as well as on the sales view status bar and the caption box. |
| **Type** | Specifies how the POS info code is used. The following options are available: **Request Data** - the data needs to be selected from an existing set or input manually and recorded in the **POS Info POS Entry List**; **Write Default Message** - a predefined message from the **Message** field is displayed on the POS when information on a customer or an item is retrieved; **Show Message** - a predefined message from the **Message** field is displayed on the POS when a customer or an item is retrieved. |
| **Input Mandatory** | If active, the salesperson will be required to provide a **POS Info Code** if they press the POS menu button. | 
| **Input Type** | Select which type of input a salesperson needs to provide. You can choose between text, subcode (a list created in **POS Info SubCodes**) or table (a set of values provided in Business Central). |

There are multiple ways in which POS info can be useful. Refer to the article on [POS info setup](../howto/pos_info_setup.md) for more information and configuration instructions.