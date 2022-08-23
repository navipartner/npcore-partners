# POS End of Day Profile (reference guide)

In the POS End of Day profile it is defined how and how often the End of Day will be performed. The following fields should be set up to define it: 

| Field Name      | Description |
| ----------- | ----------- |
| **Code**       | The unique code for the profile.     |
| **Description**   | The short description of profile.        |
| **End of Day Frequency**  |  There are two available options: **Daily** (End of Day will be performed every day) or **Never** (End of Day will never be performed). |
| **End of Day Type** | **Master&Slave** (there are master and slave POS units, the master unit is a unit in which balancing is performed for slave POS units) or **Individual** (every POS unit has to be balanced individually). |
| **Master POS unit No.** | The POS unit in which the balancing is performed if the **End of Day Type** is **Master&Slave**. |
| **Z-report UI** | There are two available options: **Summary+Balancing** – when running the Z-report the page with summary will be opened first, followed by the balancing page or **Only Balancing** – the balancing page is opened immediately. |
| **X-Report UI** | There are two available options: **Summary+Balancing** when running the X-report the page with summary will be opened first, followed by the balancing page  or **Only Balancing** – the balancing page is opened immediately. |
| **Close Workshift UI** | You can choose between either **Print** or **No print**. |
| **Force Blind Counting** | If this field is checked on the balancing page the amount won't be shown in the system. |
| **SMS profile** | The SMS template which will be used for sending an SMS after the balancing is done. |
| **Z-Report Number Series** | The number series used for creating the **Document No.** in the POS entry for entries created from running the Z report. |
| **X-Report Number series** | The number series used for creating the **Document No.** in the POS entry for entries created from running the X report. |
| **Show Zero Amount Lines** | All payment methods will be shown on the balancing page even if they haven’t been used. |
| **Hide Turnover Section** |  If this field is checked, the turnover section will be hidden on the summary page. |

![endofday](../images/End%20of%20day%20profile.PNG)

### Related links

- [Balance the POS (Z-report)](../howto/balance_the_pos.md)
- [POS Display Profile](POS_Display_profile.md)
- [POS Input Box Profile](../explanation/POS_input_box_profile.md)
- [POS Unit Receipt Profile](../explanation/POS_unit_Receipt_profile.md)
- [POS View Profile](POS_view_profile.md)
- [POS Audit Profile](POS_audit_profile.md)
- [Set up the POS Global Sales Profile](../howto/POS_Global.md)
- [Set up POS Posting Profile](../howto/POS_Pos_Prof.md)
- [Set up POS Pricing Profile](../howto/POS_Pricing_profile.md)