page 6151381 "CS Rfid Tag Models"
{
    // NPR5.47/CLVA/20181011 CASE 307282 Object created
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to Object
    // NPR5.48/CLVA/20181218 CASE 335051 Added action "Update Rfid Tags"
    // NPR5.50/CLVA/20190425 CASE 352134 Deleted Action "Update Rfid Tags"

    Caption = 'CS Rfid Tag Models';
    PageType = List;
    SourceTable = "CS Rfid Tag Models";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Family;Family)
                {
                }
                field(Model;Model)
                {
                }
                field(Discontinued;Discontinued)
                {
                }
            }
        }
    }

    actions
    {
    }
}

