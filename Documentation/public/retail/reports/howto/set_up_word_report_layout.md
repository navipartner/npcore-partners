# Customize report layout in Microsoft Word

Business Central has a possibility to utilize Microsoft Word for report layouts. In this way, it can be quite easy to design sales invoices, credit memos, or any other reports with specific layouts. 

To set up report layouts in Business Central, follow the provided steps:

1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Report Layout Selection**, and open the related link.       
   The page with the list of all reports available in the system is displayed.
2. Find the report you wish to customize with the **Search** functionality in the ribbon.
3. Click **Custom Layouts** in the ribbon.       
   The list of all custom layouts that are created for this report is displayed.     
   ![custom_layouts](images/../../images/custom_layouts.png)
4. Select the layout you want to modify, click **Layout** in the ribbon, followed by **Export Layout**.    
   As a result, a Word file is downloaded to your PC.
5. Open the downloaded file, and [enable the **Developer** tab](https://support.microsoft.com/en-us/office/show-the-developer-tab-in-word-e356706f-1891-4bb8-8d72-f57a51146792) in Word.
   The file should closely resemble the file in the provided screenshot.
   ![downloaded_word_file](../../images/../reports/images/downloaded_word_file.png)
6. Navigate to the **Developer** tab, and select the **XML Mapping Pane** option.      
   XML Mapping is displayed on the right side of the Word window as a result. 
7. In the **Custom XML Part**, select the report you want to customize.     
   Data items and fields for the report are displayed.
8. Replace all placeholders in the downloaded file with actual fields from the report.     
   You can always change the layout of the report if necessary. After the fields are mapped, the resulting layout should resemble the one presented in the following screenshot:
   ![report_layout_fixed](../images/report_layout_fixed.png)
9. Save the file, and go back to Business Central to select the layout you want to import.
10. Click **Layout** in the ribbon, followed by **Import Layout**.
11. After the import is completed, go back to the **Report Layout Selection**, and select the layout you've just uploaded.