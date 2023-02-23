# POS End of Day Profile (reference guide)

The End of Day profile can be used to summarize all data such as transactions, sales order statuses etc. that have been accumulated by the end of a single business day. You can define in what manner and how often the end-of-day process will be performed. The following fields should be set up:

| Field Name      | Description |
| ----------- | ----------- |
| **Code**       | The unique ID of the profile.     |
| **Description**   | The short description of the profile.        |
| **End of Day Frequency**  | You can determine at which frequency the POS balancing is performed. There are two available options: **NEVER** - it is up to the business to perform balancing when required; **DAILY** - when the POS unit is opened at the beginning of a work day, a reminder for balancing the POS is displayed, and the work shift can't start before balancing is performed. |

> [!Note]
> Daily balancing can also englobe more than one work shift on the same day. A business performs balancing at the end of each work shift. By doing so, it closes the current work shift, and opens the next one.



| Field Name      | Description |
| ----------- | ----------- |
| **End of Day Type** | You can choose between: **Individual** - EOD for each individual POS unit; **Master & Slave** - the POS unit you select will be the only one used for counting, and all physical cash is carried to it, to be counted as a single set (when counting is performed, the work shift for every individual slave POS unit is closed, and a new one is created and ready to work). |
| **Master POS Unit No.** | The POS unit on which the balancing is performed if the **End of Day Type** is **Master&Slave**. |

> [!Note]
> There's a validation process that prevents opening slave POS units until counting and balancing are completed on the master POS unit first. When this is done, the work shift of the slave POS unit becomes available for a new shift to start. Audit-wise, all transactions of slave POS units are accumulated on the master POS unit for the purpose of balancing. The transactions are still allocated to each individual POS unit.



| Field Name      | Description |
| ----------- | ----------- |
| **Z-report UI** | You can choose what is going to be displayed when the button for the POS balancing action is used: **Summary + Balancing** - if selected, you will get the screens for the **Statistics**; **Balancing Only** - if you choose this option, you will get the **Balancing** screen only (if there's a need for salespeople to access the **Balancing**, this is where such behavior is set up). |
| **X-Report UI** | This X-report screen contains the status of the POS unit. It's not used for performing cash count. You can set a POS menu button to display the status of the POS unit during the work shift. The following options are available: **Summary+Printing** - the **Statistics** screens are retrieved, along with the printed report; **Printing Only** - a report on the status of the POS unit is printed. |
| **Close Workshift UI** | You can have a printout on closing the work shift. Currently, it's not in use as when the balancing is completed, the work shift is automatically closed, and followed by a printout. |
| **Force Blind Counting** | The expected ledger balance of the cash is displayed on the counting screen. When this function is activated, the expected ledger balance of the counted cash isn't visible.  |
| **SMS profile** | You can set an SMS profile to send an SMS to the supervisor on the result of the counting. |
| **Z-Report Number Series** | The number series used for creating the **Document No.** in the POS entry for entries created from running the Z report. |
| **X-Report Number series** | The number series used for creating the **Document No.** in the POS entry for entries created from running the X report. |
| **Show Zero Amount Lines** | When counting is performed, by default the currency with zero amount for counting isn't displayed. If this function is activated, all currencies are displayed, even if they amount to zero. This function needs to be used with discretion, as it might confuse the salespeople.  |
| **Hide Turnover Section** | Hide the turnover statistics screen. |
| **Disable Difference Field** | If selected, salespeople will be prompted to provide the counted amount. Otherwise, if an amount is entered in the **Difference** field, the **Counting** field will automatically be updated with the difference between the expected ledger balance amount, and the **Difference** field. |
| **Require Denominations** | You can set an **Assist** button for denomination count on the following fields: **Counted Amount**, **Bank Deposit Amount**, and **Move to Bin Amount**. This section can only be seen on V3. |

![endofday](../images/End%20of%20day%20profile.PNG)

### Related links

- [Balance the POS (Z-report)](../../posunit/howto/balance_the_pos.md)
- [POS Display Profile](POS_Display_profile.md)
- [POS Input Box Profile](POS_input_box_profile.md)
- [POS Unit Receipt Profile](POS_unit_Receipt_profile.md)
- [POS View Profile](POS_view_profile.md)
- [POS Audit Profile](POS_audit_profile.md)
- [Set up the POS Global Sales Profile](../howto/POS_Global.md)
- [Set up POS Posting Profile](../howto/POS_Pos_Prof.md)
- [Set up POS Pricing Profile](../howto/POS_Pricing_profile.md)