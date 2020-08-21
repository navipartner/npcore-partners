page 6014489 "Report Usage Log Entries"
{
    // NPR5.48/TJ  /20181108 CASE 324444 New object

    Caption = 'Report Usage Log Entries';
    Editable = false;
    PageType = List;
    SourceTable = "Report Usage Log Entry";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Database Name"; "Database Name")
                {
                    ApplicationArea = All;
                }
                field("Tenant Id"; "Tenant Id")
                {
                    ApplicationArea = All;
                }
                field("Company Name"; "Company Name")
                {
                    ApplicationArea = All;
                }
                field("Report Id"; "Report Id")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("User Id"; "User Id")
                {
                    ApplicationArea = All;
                }
                field("Used on"; "Used on")
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

