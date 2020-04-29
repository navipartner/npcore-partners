page 6060080 "MCS Recommendations Setup"
{
    // NPR5.30/BR  /20170215  CASE 252646 Object Created

    Caption = 'MCS Recommendations Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "MCS Recommendations Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Max. History Records per Call";"Max. History Records per Call")
                {
                }
                field("Online Recommendations Model";"Online Recommendations Model")
                {
                }
                field("Background Send POS Lines";"Background Send POS Lines")
                {
                }
                field("Background Send Sales Lines";"Background Send Sales Lines")
                {
                }
                field("Max. Rec. per Sales Document";"Max. Rec. per Sales Document")
                {
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

