page 6184861 "NPR Azure Storage Overview"
{
    Caption = 'Azure Storage Overview';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Azure Storage Overview";

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

