page 6014489 "NPR Report Usage Log Entries"
{
    // NPR5.48/TJ  /20181108 CASE 324444 New object

    Caption = 'Report Usage Log Entries';
    Editable = false;
    PageType = List;
    SourceTable = "NPR Report Usage Log Entry";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Database Name"; "Database Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Database Name field';
                }
                field("Tenant Id"; "Tenant Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tenant Id field';
                }
                field("Company Name"; "Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company Name field';
                }
                field("Report Id"; "Report Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Report Id field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("User Id"; "User Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User Id field';
                }
                field("Used on"; "Used on")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Used on field';
                }
            }
        }
    }

    actions
    {
    }
}

