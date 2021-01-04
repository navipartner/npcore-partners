page 6059986 "NPR Sale POS Activities"
{
    // NPR4.10/VB/20150602 CASE 213003 Support for Web Client (JavaScript) client
    // NPR4.16/MHA/20151105 CASE 226711 Moved Control Action to Empty CueGroup to support Web Client

    Caption = 'Sale Activities';
    PageType = CardPart;
    UsageCategory = Administration;
    SourceTable = "NPR Sale POS Cue";

    layout
    {
        area(content)
        {
            cuegroup(Cues)
            {
                Caption = ' ';
                field("Saved Sales"; "Saved Sales")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR TouchScreen: Saved sales";
                    ToolTip = 'Specifies the value of the Saved Sales field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        if not RetailConfiguration.Get then exit;

        case RetailConfiguration."Show saved expeditions" of
            RetailConfiguration."Show saved expeditions"::All:
                ;
            RetailConfiguration."Show saved expeditions"::Register:
                SetFilter("Register Filter", RetailFormCode.FetchRegisterNumber);
            RetailConfiguration."Show saved expeditions"::Salesperson:
                // Fix for salesperson
                ;
            RetailConfiguration."Show saved expeditions"::"Register+Salesperson":
                begin
                    // Fix for salesperson
                    SetFilter("Register Filter", RetailFormCode.FetchRegisterNumber);
                end;
        end;

        Reset;
        if not Get then begin
            Init;
            Insert;
        end;
    end;

    var
        RetailConfiguration: Record "NPR Retail Setup";
        RetailFormCode: Codeunit "NPR Retail Form Code";
}

