page 6184871 "DropBox Overview"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created

    Caption = 'DropBox Overview';
    Editable = false;
    PageType = List;
    SourceTable = "DropBox Overview";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Account Code";"Account Code")
                {
                }
                field("File Name";"File Name")
                {
                }
                field(Name;Name)
                {
                }
            }
        }
    }

    actions
    {
    }
}

