page 6184871 "NPR DropBox Overview"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created

    Caption = 'DropBox Overview';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR DropBox Overview";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Account Code"; "Account Code")
                {
                    ApplicationArea = All;
                }
                field("File Name"; "File Name")
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

