query 6151371 "NPR CS Rfid Item Groups"
{
    // NPR5.47/NPKNAV/20181026  CASE 318296 Transport NPR5.47 - 26 October 2018
    // NPR5.48/JDH /20181109 CASE 334163 Missing Object Caption Added
    // NPR5.50/CLVA/20190425 CASE 247747 Added Filter "Time Stamp"

    Caption = 'CS Rfid Item Groups';

    elements
    {
        dataitem(CS_Rfid_Data; "NPR CS Rfid Data")
        {
            filter(Time_Stamp; "Time Stamp")
            {
            }
            column(Item_Group_Code; "Item Group Code")
            {
            }
            column(Item_Group_Description; "Item Group Description")
            {
            }
            column(Count_)
            {
                Method = Count;
            }
        }
    }
}

