# Maintaining CS UIs

1. Click the ![Lightbulb that opens the Tell Me feature](../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **CS UIs** and choose the related link.        
   A list of configured UIs is displayed.
2. Choose the **New** action.

3. Fill out the necessary fields with the following information:
    
The important fields in the **Header** are:

- **Code** Enter a unique ID for the UI.

- **Description** Enter the description for the UI.

- **Form Type** Tick the checkbox to define the location as the only location where the employee can perform warehouse activities.

- **Handling codeunit** Enter the BC codeunit which controls the action of the UI.

> [!Note]
> For any new UI, you should check with NaviPartner if there is an existing codeunit for the action needed or else a new codeunit will have to be developed.

 - **Next UI** Enter the next UI which will open.

> [!Note]
> For **Menus**, the next UI is defined on the lines.

- **Data Pattern Code**  Enter the Patten code which this UIs will use.
    (Data pattern code defines what will be displayed as lines and which data user will have to input. This is used only with form type **Data List Input**)



> [!Note]
> NaviPartner provides standard UIs which can be implemented and modified as per requirements of the users.

- **Subform**

    The Subform defines what data is being displayed as header part on the mobile device.

    It is subdivided into three sections:

    1. Header
       Here the text to be displayed as the header on the UI.
       Normally for headers we have Text type 'Field Type'

    2. Body
       Here the data to be displayed as the body of the UI.
       It can be a mixture of Text and data coming from the database.

    3. Footer
        Here the text to be displayed as footer on the UI.
    
    Enter the required fields.