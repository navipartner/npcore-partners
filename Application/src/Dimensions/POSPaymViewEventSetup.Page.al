page 6151054 "NPR POS Paym. View Event Setup"
{
    Extensible = False;

    Caption = 'POS Payment View Event Setup';
    PageType = Card;
    SourceTable = "NPR POS Paym. View Event Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            group(General)
            {
                field("Dimension Popup Enabled"; Rec."Dimension Popup Enabled")
                {

                    ToolTip = 'Specifies the value of the Dimension Popup Enabled field';
                    ApplicationArea = NPRRetail;
                }
                field("Dimension Code"; Rec."Dimension Code")
                {

                    ToolTip = 'Specifies the value of the Dimension Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Popup per"; Rec."Popup per")
                {

                    ToolTip = 'Specifies the value of the Popup per field';
                    ApplicationArea = NPRRetail;
                }
                field("Popup every"; Rec."Popup every")
                {

                    ToolTip = 'Specifies the value of the Popup every field';
                    ApplicationArea = NPRRetail;
                }
                field("Popup Start Time"; Rec."Popup Start Time")
                {

                    ToolTip = 'Specifies the value of the Popup Start Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Popup End Time"; Rec."Popup End Time")
                {

                    ToolTip = 'Specifies the value of the Popup End Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Popup Mode"; Rec."Popup Mode")
                {

                    ToolTip = 'Specifies the value of the Dimension Popup Mode field';
                    ApplicationArea = NPRRetail;
                }
                field("Create New Dimension Values"; Rec."Create New Dimension Values")
                {

                    ToolTip = 'Specifies the value of the Create New Dimension Values field';
                    ApplicationArea = NPRRetail;
                }
                field("Skip Popup on Dimension Value"; Rec."Skip Popup on Dimension Value")
                {

                    ToolTip = 'Specifies the value of the Skip Popup on Dimension Value field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(FilterGr)
            {
                Caption = 'Popup Filter';
                part("NPR Popup Dim. Filter"; "NPR Popup Dim. Filter")
                {
                    ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the POS Payment View Log Entries action';
                ApplicationArea = NPRRetail;
            }
            action("POS Scenarios")
            {
                Caption = 'POS Scenarios';
                Image = Setup;
                RunObject = Page "NPR POS Scenarios";

                ToolTip = 'Executes the POS Scenarios action';
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnInit()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}

