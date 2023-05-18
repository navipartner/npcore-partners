# Set up event templates

Any event can be turned into an event template just like standard jobs can be used as job templates. Once defined, they can be copied and reused as many times as needed, thereby reducing the overhead time on some more trivial activities such as specifying frequently used resources, defining report templates or setting attributes.

To create a new event template, follow the provided steps:

1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Event List**, and open the related link.       
2. Click **New**.     
   The **Event Card** is displayed. You can provide all the necessary options here to create the configuration you need. 
3. Populate the **No.** field.      
   It's recommended to populate it manually so it's easily understood what the template is used for.
   
> [!Note]
> You can enable manual entry in the **No. Series** administrative section by ticking the **Manual Nos.** checkbox for the **E-VENT** number series.

4. Provide the **Customer No.**.    
   It's recommended to use the default customer that is reserved for event templates only.
5. When you assign the customer to the template, navigate to their **Customer Card** to block them.      
   This ensures that the customer will not be used when creating an event or anywhere else in the system.
6. Set the **Blocked** field (in the **Event Card**) to **All**.     
   This prevents you from creating a sales invoice or posting anything related to this event by mistake.
7. In the **Lines** section, you can set resources/items that are usually referenced alongside this template (e.g. room, tutor, brochures).
    - The line type **Resource** should be used for things like rooms, departments and people. The system can be set up to warn if a resource is being double-booked.
    - The line type **Item** should be used for things that are being sold, e.g. tickets, food, merchandise.
    - The line type **Text** can be used to create a program for the event on the order confirmation PDF:

        - 09:00 – Arrival
        - 09:20 – Breakfast
        - 10:00 – Meeting in meeting room B2
 
> [!Important]
> Don't specify a date unless you're creating an event for a specific date. The same applies for any specific quantities - if you're creating a template, it should have a broader use than an event, so adding specific data may get in the way of that.

## Next steps - Set up order confirmation PDF

If you want to set up an order confirmation PDF that is automatically created and populated with data from your templates, you need to set it under **Custom Report Layouts**. 

1. Navigate to **Custom Report Layouts**.
2. Create a **New** line. 
3. Provide the report ID 6060150 if the order confirmation is sent to a customer, or report ID 6060151  if it is sent to an internal team.      
4. Select the **Word Layout** and give it a fitting description.     
   You can now export it, set it up in Word, and import it again.
5. Navigate back to the event template, and set [**Report Layouts**](set_up_word_report_layout.md) to use the report you've just created.     
   Multiple event templates can use the same report layout.