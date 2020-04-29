query 6151375 "CS Rfid Tag Models"
{
    // NPR5.48/CLVA/20181119 CASE 335051 Object created

    Caption = 'CS Rfid Tag Models';

    elements
    {
        dataitem(CS_Rfid_Tag_Models;"CS Rfid Tag Models")
        {
            filter(Discontinued;Discontinued)
            {
            }
            column(Family;Family)
            {
            }
            column(Model;Model)
            {
            }
        }
    }
}

