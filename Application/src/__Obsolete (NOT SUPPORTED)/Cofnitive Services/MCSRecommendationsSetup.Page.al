page 6060080 "NPR MCS Recommendations Setup"
{
    // NPR5.30/BR  /20170215  CASE 252646 Object Created
    ObsoleteState = Pending;
    ObsoleteReason = 'On February 15, 2018, “Recommendations API is no longer under active development”';
    Caption = 'MCS Recommendations Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR MCS Recommendations Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Max. History Records per Call"; "Max. History Records per Call")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Max. History Records per Call field';
                }
                field("Online Recommendations Model"; "Online Recommendations Model")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Online Recommendations Model field';
                }
                field("Background Send POS Lines"; "Background Send POS Lines")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Background Send POS Lines field';
                }
                field("Background Send Sales Lines"; "Background Send Sales Lines")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Background Send Sales Lines field';
                }
                field("Max. Rec. per Sales Document"; "Max. Rec. per Sales Document")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Max. Rec. per Sales Document field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
            Init;
            Insert;
        end;
    end;
}

