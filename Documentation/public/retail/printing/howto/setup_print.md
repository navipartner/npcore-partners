# Set up the printing module (Hardware Connector)

There are three available printer extensions you can choose from when setting up the default printers for report printing:

- Hardware Connector
- MPOS
- PrintNode

This how-to guide focuses on the recommended option that is the Hardware Connector, while the MPOS and PrintNode output setups will be explained in separate articles. 

To set up the printing module, follow the provided steps:


1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Hardware Connector Report Printer Setup**, and open the related link.    
   The administrative section containing the list of all printers connected to the current environment is displayed.
2. Create a **New** printer.
3. Populate the necessary fields: 
   
   | Field Name      | Description |
   | ----------- | ----------- |
   | **Printer Name** |  The name you provide here needs to match the name of the printer connected to your PC. You can learn the printer name in the **Printers & scanners** Windows administrative section. | 
   | **Paper Size** | Specifies the size of the object that will be printed. If you need to print a non-standard paper size (e.g. card), you should select **Custom**. | 
   | **Printer Paper Height**/**Printer Paper Width** | Specifies the dimensions of the printed content. These options are only available if the **Custom** paper size is selected.| 
   | **Printer Paper Unit** | Specifies the unit of measure in which the paper dimensions will be expressed. |
   | **Paper Source** | If the printer has multiple printing trays, you can specify which one to use. |
   | **Landscape** | Specifies whether the printed content will be displayed in a landscape layout. |

   Once you populate the necessary fields, the printer will be created and ready to be selected in the **Printer Selections** administrative section.

4. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Printer Selections**, and open the related link.     
   Here, you can choose one of the available reports, and modify it. Reports are used for ordering information from a database (e.g. invoices) in a structured and summarized way, thus preparing it to be printed.
5. Create **New**.   
6. Select the previously created printer in the **Printer Name** field, and populate other fields.   
   
   > [!Note]
   > The printer name will receive the prefix after it's been created. For Hardware Connector this prefix is **NPR_HWC_**, and it is followed by the printer ID from the **Hardware Connector Report Printer Setup**.

7. (Optional) Specify the **User ID** if you wish only a specific user to have access to it.     
   If no user ID is specified, the printer selection is applicable to all users.
8. (Optional) Specify the **Report ID** if you wish only a specific report to be applied to it.      
   If no report ID is specified, the printer selection is applicable to all reports. 

   > [!Note]
   > If neither **User ID** nor **Report ID** are specified the printer selection is applicable for all users and reports that aren't defined. 

9.  Open the [Hardware Connector Software](../../gettingstarted/hw_connector.md) before you start printing.     
   It needs to be running in the background. 

> [!Video https://www.youtube.com/embed/VKI0MNWorPA]

### Next steps

- To produce the MPOS HTTP MPOS output type, the printer needs to first be created in **MPOS Report Printer Setup**. 
- If you wish to print externally, you also need to configure the online service for handling printing in the **PrintNode Setup**.

### Related links

- [Navigation and reports](../../loyalty/explanation/Navigation%20and%20reports.md)
- [Customize report layout in Microsoft Word](../../reports/howto/set_up_word_report_layout.md)