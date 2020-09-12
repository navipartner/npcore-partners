page 6151054 "NPR POS Paym. View Event Setup"
{
    // NPR5.51/MHA /20190723  CASE 351688 Object created
    // NPR5.51/MHA /20190823  CASE 359601 Added field 80 "Skip Popup on Dimension Value"

    Caption = 'POS Payment View Event Setup';
    PageType = Card;
    SourceTable = "NPR POS Paym. View Event Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Dimension Popup Enabled"; "Dimension Popup Enabled")
                {
                    ApplicationArea = All;
                }
                field("Dimension Code"; "Dimension Code")
                {
                    ApplicationArea = All;
                }
                field("Popup per"; "Popup per")
                {
                    ApplicationArea = All;
                }
                field("Popup every"; "Popup every")
                {
                    ApplicationArea = All;
                }
                field("Popup Start Time"; "Popup Start Time")
                {
                    ApplicationArea = All;
                }
                field("Popup End Time"; "Popup End Time")
                {
                    ApplicationArea = All;
                }
                field("Popup Mode"; "Popup Mode")
                {
                    ApplicationArea = All;
                }
                field("Create New Dimension Values"; "Create New Dimension Values")
                {
                    ApplicationArea = All;
                }
                field("Skip Popup on Dimension Value"; "Skip Popup on Dimension Value")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("POS Payment View Log Entries")
            {
                Caption = 'POS Payment View Log Entries';
                Image = History;
                RunObject = Page "NPR POS Paym. View Log Entries";
                ApplicationArea = All;
            }
            action("POS Sales Workflows")
            {
                Caption = 'POS Sales Workflows';
                Image = Setup;
                RunObject = Page "NPR POS Sales Workflows";
                ApplicationArea = All;
            }
        }
    }

    trigger OnInit()
    begin
        if not Get then begin
            Init;
            Insert;
        end;
    end;
}

