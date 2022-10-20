# Set up mobile POS view

Mobile view setup is defined exactly in the same way as in the non-mobile scenarios. There are default views for the login, sale, and payment functions. This is the default arrangement that Transcendence applies if there are no custom views defined.

To define a new mobile view:

1. Create a new POS View record by specifying the register filter to match the register number of the mobile device, and then specifying the M* view you defined.
2. Prefix it with "M" (this is just a convention, not a rule) – so, for example MPOS-SALE, MPOS-PAY, etc.


![MPOS VIEW](../images/MPOS%20View%202022-09-20.png) 


> [!Note]  
> MPOS uses the same configuration defined in [POS Unit.](../../posunit/reference/POS_view_profile.md)


![POS VIEW PROFILE](../images/MPOS%20-%20POS%20Unit%202022-09-20.png) 

### Related links

- [POS Display Profile](../../posunit/reference/POS_Display_profile.md)
- [POS Unit Receipt Profile](../../posunit/explanation/POS_unit_Receipt_profile.md)
- [POS Audit Profile](../../posunit/reference/POS_audit_profile.md)
- [POS End-of-Day Profile](../../posunit/reference/POS_End_of_Day_Profile.md)
- [Set up the POS Global Sales Profile](../../posunit/howto/POS_Global.md)
- [Set up POS Posting Profile](../../posunit/howto/POS_Pos_Prof.md)
- [Set up POS Pricing Profile](../../posunit/howto/POS_Pricing_profile.md)
- [Balance the POS (Z-report)](../../posunit/howto/balance_the_pos.md)