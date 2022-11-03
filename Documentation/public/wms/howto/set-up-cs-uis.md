# Set up CS UIs

CS UIs are used for defining the look and feel of the NP WMS mobile interface. NaviPartner provides standard UIs which can be implemented and modified as per requirements of the users, but you can create completely new UIs as well.

To set up CS UIs, follow the provided steps:

1. In Business Central, click the ![Lightbulb that opens the Tell Me feature](../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **CS UIs** and choose the related link.        
   A list of preset and custom UIs is displayed, along with the options for creating new ones.
2. Click **New**.

3. Fill out the necessary fields in the **General** section with the following information:

| Field Name      | Description |
| ----------- | ----------- |
| **Code**     | Specifies the unique ID for the UI. |
| **Description**   | Specifies the description of the UI.  |
| [**Form Type**](../explanation/cs-uis.md)  | Specifies which UI template is used for the CS UI you're setting up. |
| [**Handling codeunit**](../reference/handling_codeunits.md) | Specifies the selected object which controls the actions of the UI from the back-end.  |
| **Next UI** | Specifies the ID of the UI that will be opened after the current one. Note that the **Selection List** form type doesn't have the **Next UI** link as it gives users the option of navigating to multiple pages in no specific order. To specify which UIs users can navigate to from the selection list, you can provide the corresponding UI IDs in the **Call UI** column of the **CS UI Subform**.|
| [**Data Pattern Code**](../howto/set-up-datapatterncode.md) | Specifies the pattern code that this UIs will use. The data pattern code defines what will be displayed as lines and which data users need to input. This is used only with the form type **Data List Input**. |


> [!Note]
> For any new UI, you should check with NaviPartner if there is an existing codeunit for the action needed or else a new codeunit will have to be developed.

4. Provide the necessary information in the **UI Subform** section, used for customization of individual UI areas like header, body, and footer. You can also customize each UI **Area**, and specify another UI that can be accessed from it by choosing it from the **Call UI** dropdown list. 

> [!Note]
> The field type most commonly associated with the **Header** is **Text Type**, while the **Body** is usually a combination of the **Text Type** and the data coming from the database. 

5. (Optional) You can also set up the CS UI functions by clicking **CS UI** followed by **Set up CS UI Functions** in the ribbon, and then select the function from the list.    
   Functions are predefined segments that can be added to any CS UI. For example, there is a **BARCODE** function which, when added, introduces the **SCAN BARCODE** button to the CS UI. 

6. (Optional) Additionally, you can set up the CS UI filters by clicking **CS UI** followed by **Set up CS UI Filters** in the ribbon.
   CS UI filters provide the means of narrowing down the quantity of items which will be retrieved when a certain in-app page is opened. For example, if you open the **Pick List** page in the app, you will only see the list of inventory pick documents, while the other document types will be filtered out.


> [!Video https://share.synthesia.io/57815aae-5de8-4d83-86cc-64b1684c068b]


> [!Video https://share.synthesia.io/d3b750e9-aaef-4336-b8f8-bb7b9d0cb5bc]
### Related links

- [Capture Service UIs](../explanation/cs-uis.md)
- [CS UI Structure](../explanation/cs_ui_structure.md)
- [Handling codeunits - WMS](../reference/handling_codeunits.md)