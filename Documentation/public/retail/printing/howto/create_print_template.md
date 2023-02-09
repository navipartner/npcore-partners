# Create a print template

There are multiple system print templates you can choose from, but if you need a template that is completely different from the available choices, or one that needs to be slightly modified, you can either create a new template or copy an existing one, change it, and save it in the environment for future use. 

1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Print Template List**, and open the related link.    
   On fresh installation, an empty template list is displayed.
2. To fetch preconfigured print templates from our Azure server, click **Actions** in the ribbon, followed by **Download Template Data**.     
   The list of available templates is displayed. You can choose to add, skip or replace any of these templates.
3. There are several available options from this point forward:   
   - If you have a prepared template saved locally, you can click **Actions** in the ribbon, followed by **Import Package File** to upload it.
   - If you need to edit one of the existing templates, click **Edit**.
   - If you want to create a copy of one of the existing templates, click **Actions** in the ribbon, followed by **Create Copy**. You can modify this copy as much as needed without impacting the state of the original.
   - Click **New** to create a completely new template, and populate the necessary fields as indicated in further text. 

4. Provide the template **Code**.       
   The code is a descriptive identifier of the template. It should ideally help distinguish this template from the others. For example, **ZT230_COUPON** lets you know what the printer's model and purpose is just from reading the code.
5. Select the **Printer Type**. You can choose between [Matrix and Line printers](../explanation/print_template_output_setup.md).      
   Depending on your selection in the previous step, the next panel will either contain the options related to **Matrix Settings** or **Line Settings**.
6. Configure the settings in the panel below.     
   - The **Line Settings** panel consists of a dropdown list of available line printing devices, and the options for distribution of the item's content in columns. 
   - The **Matrix Settings** panel contains a dropdown list of available printing devices.  
7. (Optional) In the **Processing** panel provide the codeunits which will be used for generating unique scannable tags on the output.    
   The preprocessing codeunit is used for splitting the items into components before they are printed, while the postprocessing codeunit restores the components back into a complete item afterwards. These codeunits are useful if multiple items with extensive lines are printed. 
8. (Optional) For additional setup, use one of the **Actions** in the ribbon:   
   - **Edit Data Items** - State which entities will be used as data sources mapped to the printed item. 
   - **Edit Layout** - Design the layout of the item by providing the X and Y coordinates (for Matrix templates) or the order and content of each line (for Line templates). 
   - **Edit Device Settings** - Configure the device-specific settings. You can override the default settings of a device, typically related to calibration, media specifications or encoding.

### Related links

- [Set up the printing module (Hardware Connector)](setup_print.md)
- [Print Template Output Setup](../explanation/print_template_output_setup.md)