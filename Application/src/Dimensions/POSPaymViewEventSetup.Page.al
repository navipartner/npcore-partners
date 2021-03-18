page 6151054 "NPR POS Paym. View Event Setup"
{

    Caption = 'POS Payment View Event Setup';
    PageType = Card;
    SourceTable = "NPR POS Paym. View Event Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Dimension Popup Enabled"; Rec."Dimension Popup Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dimension Popup Enabled field';
                }
                field("Dimension Code"; Rec."Dimension Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dimension Code field';
                }
                field("Popup per"; Rec."Popup per")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Popup per field';
                }
                field("Popup every"; Rec."Popup every")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Popup every field';
                }
                field("Popup Start Time"; Rec."Popup Start Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Popup Start Time field';
                }
                field("Popup End Time"; Rec."Popup End Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Popup End Time field';
                }
                field("Popup Mode"; Rec."Popup Mode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dimension Popup Mode field';
                }
                field("Create New Dimension Values"; Rec."Create New Dimension Values")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create New Dimension Values field';
                }
                field("Skip Popup on Dimension Value"; Rec."Skip Popup on Dimension Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Skip Popup on Dimension Value field';
                }
            }
            group(FilterGr)
            {
                Caption = 'Popup Filter';
                part("NPR Popup Dim. Filter"; "NPR Popup Dim. Filter")
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
                ToolTip = 'Executes the POS Payment View Log Entries action';
            }
            action("POS Scenarios")
            {
                Caption = 'POS Scenarios';
                Image = Setup;
                RunObject = Page "NPR POS Scenarios";
                ApplicationArea = All;
                ToolTip = 'Executes the POS Scenarios action';
            }
        }
    }

    trigger OnInit()
    begin
        if not Rec.Get then begin
            Rec.Init;
            Rec.Insert;
        end;
    end;
}

