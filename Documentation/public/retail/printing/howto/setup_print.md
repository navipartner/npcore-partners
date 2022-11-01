# Set up the printing module

Several actions need to be performed to make the printing solution effective.

1. A printer needs to be created in **Hardware Connector Report Printer Setup** (NPR HWC Printer (6014668)).
2. In **Printer Selection** in Business Central you should set this printer as a wildcard for the **Report ID** *0*, and the **User ID** left empty (Printer Selection (78)).     
  On the drilldown for the **Printer Name**, you will see printers, but with a printer prefix attached to the name.
  For the report to be printed, it should be defined in the **Report Selection**.
3. NP Hardware Connector Software needs to be running in the background. 

> [!Note]
> For the MPOS, the printer is created in **MPOS Report Printer Setup**, and then Business Central **Printer Selections** for reporting printing become visible. 

The report printing is done via the hardware connector rather than being hardcoded into Major Tom, so you can use it from anywhere. This means that if you're printing multiple reports from standard Business Central in one go, and it's inconvenient to save one PDF at a time, you can use the hardware connector print method instead. 

### Related links

- [Navigation and reports](../../loyalty/explanation/Navigation%20and%20reports.md)
- [Customize report layout in Microsoft Word](../../reports/howto/set_up_word_report_layout.md)