# Set up CS UIs

CS UIs are used for defining the look and feel of the NP WMS mobile interface. NaviPartner provides standard UIs which can be implemented and modified as per requirements of the users, but you can create completely new UIs as well.

To set up CS UIs, follow the provided steps:

1. In Business Central, click the ![Lightbulb that opens the Tell Me feature](../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **CS UIs** and choose the related link.        
   A list of configured UIs is displayed, along with the options for creating new ones.
2. Click **New**.

3. Fill out the necessary fields in the **General** section with the following information:
    
 - **Code** - Enter a unique ID for the UI.

 - **Description** - Enter the description for the UI.

 - **Form Type** - Define which [UI template](../explanation/cs-uis.md) is used for the CS UI you're setting up.

 - **Handling codeunit** - Make selection from the dropdown list of objects which control the actions of the UI in the back-end.

> [!Note]
> For any new UI, you should check with NaviPartner if there is an existing codeunit for the action needed or else a new codeunit will have to be developed.

 - **Next UI** Enter the ID of the UI that will be opened after the current one.     
   For **Selection List** form types, the next UI is defined on the **UI Subform** section.

- **Data Pattern Code**  Enter the pattern code that this UIs will use. The data pattern code defines what will be displayed as lines and which data users need to input. This is used only with the form type **Data List Input**.

4. Provide the necessary information in the **UI Subform** section, used for customization of individual UI areas like header, body, and footer.

> [!Note]
> The field type most commonly associated with the **Header** is **Text Type**, while the **Body** is usually a combination of the **Text Type** and the data coming from the database. 

## Video walkthrough

> [!Video https://www.youtube.com/embed/O2Lt-tCaOxY]

### Related links

- [Capture Service UIs](../explanation/cs-uis.md)
- [CS UI Structure](../explanation/cs_ui_structure.md)