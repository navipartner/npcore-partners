# Create a new POS unit (by using an existing one as reference)

As soon as you have at least one POS unit in the system, you can use configurations and data within as a source of information for creating a new one with ease. 

Each [POS store](../explanation/POS_store.md) can contain multiple POS units. Most of the time, these units have an almost identical setup, the difference being their number, (since they have to be unique) and [payment bin](create_pos_payment_bin.md) (virtual representation of a cash register, or a safe). To create a new POS unit, follow the provided steps:

## Prerequisites

 - Have at least one POS unit defined in the environment.

## Procedure

1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **POS Unit List**, and choose the related link.     
   A list of all existing POS units is displayed.  
2. Open the POS unit card you wish to use as a reference for creation of a new POS unit.     
   The **POS Unit Card** popup window is displayed.
3. Click **New**.
4. Populate the necessary fields (except **Default POS Payment Bin**) in the new POS unit by using the first POS unit card as a reference.    
   You can switch back and forth between the two POS unit cards until you're satisfied with your configuration.

   > [!NOTE]
   > Make sure that the value in the **No.** field is different than the one used for the first POS unit.

5. Open the **Default POS Payment Bin** dropdown list, and then **Select from full list**.       
   If there are no payment bins available, [create a new one](./create_pos_payment_bin.md)
6. Click **New** or **Edit List**, and add an entry for the new payment bin.    
   Make sure it has the same **POS Store Code** as the other payment bins used with that POS unit.  
7. (Optional) Refer to the [relevant articles](../../pos_profiles/intro.md) for configuring **Profiles**, if you wish them to be different than the ones defined in the former POS unit.

## Next steps:

### Link POS unit to user ID

After you create a POS unit, you need to link it to the POS user's ID before it can become fully operational.

1. Navigate to **User Setup**.   
   The easiest way to achieve this is by using the built-in search functionality.
2. In the **User Setup** screen, fill out all necessary fields.  
   Make sure you've added the number of the newly-created POS unit in the **POS Unit No.** field.

The new POS unit is created, attached to the [POS store](../howto/Create_new_POS_store.md), and ready to be used.

### Additional customization

- [Create a new item button in the POS](./Create_a_new_item_button_in_the_POS.md)
- [Create a POS payment bin](./create_pos_payment_bin.md)
- [Create a POS theme](pos_theme.md)
- [Add a logo to the POS screen](How_to_add_logo_to_the_POS_screen.md)
- [Create new buttons in the POS menu](add_button_to_pos_menu.md)

### Related links

- [Balance the POS (Z-report)](./balance_the_pos.md)
- [Configure the V4 POS balancing feature](balance_pos_v4.md)
- [Configure master/slave POS units](Configuration_of_master_slave_POS_units.md)
- [Configure an opening mechanism for a POS unit cash drawer](ConfigureCashDrawerOpening.md)
- [Create a POS payment method](POS_payment_methods.md)
- [Configure a receipt printout for a POS unit](receipt-printout.md)