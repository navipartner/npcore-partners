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
                    ToolTip = 'Specifies the value of the Dimension Popup Enabled field';
                }
                field("Dimension Code"; "Dimension Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dimension Code field';
                }
                field("Popup per"; "Popup per")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Popup per field';
                }
                field("Popup every"; "Popup every")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Popup every field';
                }
                field("Popup Start Time"; "Popup Start Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Popup Start Time field';
                }
                field("Popup End Time"; "Popup End Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Popup End Time field';
                }
                field("Popup Mode"; "Popup Mode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dimension Popup Mode field';
                }
                field("Create New Dimension Values"; "Create New Dimension Values")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create New Dimension Values field';
                }
                field("Skip Popup on Dimension Value"; "Skip Popup on Dimension Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Skip Popup on Dimension Value field';
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
                ToolTip = 'Executes the POS Payment View Log Entries action';
            }
            action("POS Sales Workflows")
            {
                Caption = 'POS Sales Workflows';
                Image = Setup;
                RunObject = Page "NPR POS Sales Workflows";
                ApplicationArea = All;
                ToolTip = 'Executes the POS Sales Workflows action';
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

