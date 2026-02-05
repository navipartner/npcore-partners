page 6059790 "NPR Pdf2Nav Posting Setup"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Extensible = false;
    Caption = 'Pdf2BC Posting Setup';
    PageType = Card;
    SourceTable = "NPR SalesPost Pdf2Nav Setup";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                group("When posting with Pdf2Nav:")
                {
                    Caption = 'When posting with Pdf2BC:';
                    field("Always Print Ship"; Rec."Always Print Ship")
                    {
                        ToolTip = 'Specifies the value of the Always Print Sales Shipment field';
                        ApplicationArea = NPRLegacyEmail;
                    }
                    field("Always Print Receive"; Rec."Always Print Receive")
                    {
                        ToolTip = 'Specifies the value of the Always Print Sales Return Receipt field';
                        ApplicationArea = NPRLegacyEmail;
                    }
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then
            Rec.Insert();
    end;
}

