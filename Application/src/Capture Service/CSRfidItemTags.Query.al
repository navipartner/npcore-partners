query 6151373 "NPR CS Rfid Item Tags"
{
    // NPR5.47/NPKNAV/20181026  CASE 318296 Transport NPR5.47 - 26 October 2018
    // NPR5.48/JDH /20181109 CASE 334163 Missing Object Caption Added
    // NPR5.48/CLVA/20181227 CASE 247747 Added Filter "Time_Stamp"

    Caption = 'CS Rfid Item Tags';

    elements
    {
        dataitem(CS_Rfid_Data; "NPR CS Rfid Data")
        {
            filter(Time_Stamp; "Time Stamp")
            {
            }
            column("Key"; "Key")
            {
            }
            column(Combined_key; "Combined key")
            {
            }
            column(Item_Group_Code; "Item Group Code")
            {
            }
            column(Count_)
            {
                Method = Count;
            }
        }
    }
}

