page 6059986 "NPR Sale POS Activities"
{
    Caption = 'Sale Activities';
    PageType = CardPart;
    SourceTable = "NPR Sale POS Cue";
UsageCategory = None;
    layout
    {
        area(content)
        {
            cuegroup(Cues)
            {
                ShowCaption = false;
                field("Saved Sales"; Rec."Saved Sales")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR TouchScreen: Saved sales";
                    ToolTip = 'Specifies the value of the Saved Sales field';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not RetailConfiguration.Get then exit;

        case RetailConfiguration."Show saved expeditions" of
            RetailConfiguration."Show saved expeditions"::All:
                ;
            RetailConfiguration."Show saved expeditions"::Register:
                Rec.SetFilter("Register Filter", RetailFormCode.FetchRegisterNumber);
            RetailConfiguration."Show saved expeditions"::Salesperson:
                // Fix for salesperson
                ;
            RetailConfiguration."Show saved expeditions"::"Register+Salesperson":
                begin
                    // Fix for salesperson
                    Rec.SetFilter("Register Filter", RetailFormCode.FetchRegisterNumber);
                end;
        end;

        Rec.Reset;
        if not Rec.Get then begin
            Rec.Init;
            Rec.Insert;
        end;
    end;

    var
        RetailConfiguration: Record "NPR Retail Setup";
        RetailFormCode: Codeunit "NPR Retail Form Code";
}

