page 6060080 "NPR MCS Recommendations Setup"
{
    // NPR5.30/BR  /20170215  CASE 252646 Object Created

    Caption = 'MCS Recommendations Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR MCS Recommendations Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Max. History Records per Call"; "Max. History Records per Call")
                {
                    ApplicationArea = All;
                }
                field("Online Recommendations Model"; "Online Recommendations Model")
                {
                    ApplicationArea = All;
                }
                field("Background Send POS Lines"; "Background Send POS Lines")
                {
                    ApplicationArea = All;
                }
                field("Background Send Sales Lines"; "Background Send Sales Lines")
                {
                    ApplicationArea = All;
                }
                field("Max. Rec. per Sales Document"; "Max. Rec. per Sales Document")
                {
                    ApplicationArea = All;
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

