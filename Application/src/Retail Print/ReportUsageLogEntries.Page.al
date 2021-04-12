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
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Database Name"; Rec."Database Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Database Name field';
                }
                field("Tenant Id"; Rec."Tenant Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tenant Id field';
                }
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company Name field';
                }
                field("Report Id"; Rec."Report Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Report Id field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("User Id"; Rec."User Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User Id field';
                }
                field("Used on"; Rec."Used on")
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

