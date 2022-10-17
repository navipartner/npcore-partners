# Create and customize Base Calendar for Admission

Assigning and customizing a base calendar is a simple approach to making exceptions in regards to a time when a time-slot should be closed rather than open.

These exceptions can be applied to [various ticketing entities](../explanation/BaseCalendar.md).

To create and customize the base calendar for an admission, follow the provided steps:

1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Ticket Admission**, and choose the related link.

2. For the **Admission Code** you should assign an **Admission Base Calendar**, so find the field **Admission Base Calendar Code**, and select the relevant **Base Calendar Code** from the dropdown list. 
   
    - With this setting, all dates marked as non-working by the **Base Calendar** will also mark the related time-slots as closed. 
    - Note that it is required to recalculate the time-slot entries for the change to take effect.

To make a specific change for this admission code, the **Base Calendar** needs to be customized:

> [!Note] 
> Adjacent to the **Admission Base Calendar Code** field, you can find the **Admission Customized Calendar** flow field. Its value is either **Yes** or **No** depending on whether this admission code has customizations or not.
   
3. Click the value in the **Admission Customized Calendar**.    
   A page showing the merged result of base calendar and customizations for this admission code is displayed.
4. Click the **Edit** icon on top to make the page editable.
5. Mark a date in the list as non-working.
6. Enter a description, and state why this date is non-working.
7. Close the page.

> [!Important]
> When customizing the admission base calendar or the underlying base calendar, it is required to recalculate the time-slot entries for the change to take effect.

The process is identical for assigning and customizing the **Base Calendar** for:

- Admission
- Admission Schedule
- Admission Schedule Lines
- Ticket BOM



### Related links

- [Business Central - Set Up Base Calendar](https://learn.microsoft.com/en-us/dynamics365/business-central/across-how-to-assign-base-calendars)