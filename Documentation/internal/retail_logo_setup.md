# Set up retail logo from Business Central

You can implement the retail logo module in such a way that you don't need to upload a new logo on each receipt printer with a driver utility, thus making the process much faster. When you use this module, the logos are stored in each print job. The impact of stored logos on the printing speed is minimal.

 - The maximum supported image size is 1MB.
 - The images will be resized to 512px if needed.    
   If the image width is lower than 512px, the image will be padded with white pixels on the right side. If the image width is higher than 512px, the height and width are scaled down with the constant aspect ratio.

1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Retail Logo Setup** and select the related link. 
2. Click **Import Logo** from the ribbon, and then **Choose** to select the image you wish to upload.      
   A new line is added to the list of retail logos.