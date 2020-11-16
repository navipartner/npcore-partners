query 6151372 "NPR CS Rfid Items"
{
    // NPR5.47/NPKNAV/20181026  CASE 318296 Transport NPR5.47 - 26 October 2018
    // NPR5.48/JDH /20181109 CASE 334163 Missing Object Caption Added
    // NPR5.50/CLVA/20190425 CASE 247747 Added Filter "Time Stamp"

    Caption = 'CS Rfid Items';

    elements
    {
        dataitem(CS_Rfid_Data; "NPR CS Rfid Data")
        {
            filter(Time_Stamp; "Time Stamp")
            {
            }
            column(Combined_key; "Combined key")
            {
            }
            column(Cross_Reference_Item_No; "Cross-Reference Item No.")
            {
            }
            column(Item_Description; "Item Description")
            {
            }
            column(Cross_Reference_Variant_Code; "Cross-Reference Variant Code")
            {
            }
            column(Variant_Description; "Variant Description")
            {
            }
            column(Item_Group_Code; "Item Group Code")
            {
            }
            column(Image_Url; "Image Url")
            {
            }
            column(Count_)
            {
                Method = Count;
            }
        }
    }
}

