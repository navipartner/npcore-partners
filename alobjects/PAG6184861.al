page 6184861 "Azure Storage Overview"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created

    Caption = 'Azure Storage Overview';
    Editable = false;
    PageType = List;
    SourceTable = "Azure Storage Overview";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Account name"; "Account name")
                {
                    ApplicationArea = All;
                }
                field("Container Name"; "Container Name")
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

