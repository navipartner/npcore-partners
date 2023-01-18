# Create a POS theme

To create a POS theme, you need to do the following:

1. Create a new CSS file for the style.
2. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Web Client Dependencies**, and choose the related link. 
3. Create a new stylesheet dependency, and name it.
4. Click **Import File**, and import the stylesheet.
5. In the **POS Themes** page, create a new record, name it *ATHEME*.
6. Click **Theme Dependencies** to create a new record for that theme. Add the following information:
   - Set **View** for the **Target Type**.
   - Leave the **Target Code** blank.
   - Leave the **Target View Type** unchanged.
   - Set **Stylesheet** as the **Dependency Type**.
   - Add **ATHEME** in **Dependency Code**.
7. Navigate to the **POS View Profile** in the POS unit, and change the theme accordingly. For each **POS View Profile** that requires this theme, set the **POS Theme Code** to **ATHEME**.      


### Related links

- [POS Self-Service Profile](../../pos_profiles/howto/pos_self_service_prof.md)
- [Create a new POS unit](createnew.md)
- [POS view profile (reference guide)](../../pos_profiles/reference/POS_view_profile.md)