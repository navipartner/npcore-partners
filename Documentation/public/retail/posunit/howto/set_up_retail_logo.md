# Set up retail logo

This article describes how to use the Retail Logo module, removing the need to upload logos on each receipt printer with a driver utility, and making the process much faster.

When using this module, the logos are stored in each print-job (with minimal print speed impact).

> [!Note]
> The supported image formats: BMP, GIF, JPG, PNG, TIFF, EXIF. The maximum supported image size is 1MB. 

- Images will be resized to 512px width - In case of width < 512, the image will be padded with white pixels on the right side. In case of width >  512 the height and width will be scaled down with constant aspect ratio. 

- Images will be converted to black & white automatically depending on the brightness of each pixel. 

> [!Note]
> If you don't wish to use the automatic conversion, scale the images to 512px manually in image-editing software before uploading the logo to Business Central. 

## Procedure

1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Retail Logo Setup**, and open the related link.       
2. Click **Import Logo**, and select the logo file in the opened dialog.     
   A line is created in the **Retail Logo Setup**.
3. Check if you're satisfied with what the logo looks like in the preview fact box on the right when selecting the newly added line. 
4. Check if the logo looks fine on print, by clicking **Print Logo** when selecting the newly added line.     
   Note that the object output for the sales receipt is used for the printer selection. An error will be displayed if no printers can be found. 
5. Define the necessary values in the line's columns: 
   - **Sequence** - specify the order in which logos will be printed in case of multiple logos which use the same keyword.
   - **Keyword** - provide the keyword for the logo; the following keywords are supported:
     - **RECEIPT** - this is the regular receipt logo used on top of all receipts.
     - **TAXFREE** - this is a tax-free logo, printed on tax-free vouchers.
   - **Register No.** - if left blank, all registers without a specified number filter match will print this logo.
   - **Start Date** - set a start date (inclusive) from which this logo will be printed. You can keep this field blank if no interval is needed.
   - **End Date** - Set an end date (inclusive) from which this logo will no longer be printed. You can keep this field blank if no interval is needed.