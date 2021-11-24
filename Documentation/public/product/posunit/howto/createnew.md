# Create a new POS unit (apply the same setup to multiple POS units)

This topic describes the process of creating a new POS unit by using an already existing one as a reference. As soon as you have at least one POS unit in the system, you can use data inside it as a source of information for creating a new one with ease. 

Each POS store can contain multiple POS units. Most of the time, these units have almost identical setup, the difference being their number, since they have to be unique, and payment bin (virtual representation of a cash register, or a safe). Consequently, the process of POS unit creation is very simple if the setup of another POS unit is used as a reference. 

### Prerequisites

 - Have at least one existing POS unit in the system that you can copy values from.

 
To create a new POS unit:

1. From the **Role Center**, search the **POS Unit List** and click on it once it's displayed in the results.  
   A list of all existing POS units is displayed.  
2. Click on the POS unit you wish to use as a reference for creating a new one.  
   The **POS Unit Card** popup window is displayed.
3. Click the plus sign at the top of the screen.
4. Populate the necessary fields (except **Default POS Payment Bin**) in the new POS unit by using the old POS unit card as a reference.  
   You can switch back and forth between the two POS units until you're satisfied with your selection.
   > [!NOTE]
   > Make sure that the value in the **No.** field is different than the one used for the first POS unit.
5. Click on the field next to the **Default POS Payment Bin** and then **Select from full list**.  
6. Click **New** or **Edit List** and add an entry for the new payment bin.  
   Make sure it has the same **POS Store Code** as the other payment bins used with that POS unit.  

## Next steps:

After you create a POS unit, you need to link it to a user before it can become functional.

1. Navigate to **User Setup**.   
   The easiest way to achieve this is by using the built-in search functionality.
2. In the **User Setup** screen, fill out all necessary fields.  
   Make sure you've added the number of the newly-created POS unit in the **POS Unit No.** field.

The new POS unit is created, attached to the POS store, and is now fully operational.

### Related links

- [Create a new POS unit (from the top)](../../../../public/404.md)
- [Configure a payment terminal for a POS unit](../../../../public/404.md)
- [POS unit profiles](../../../../public/404.md)









  