page 6151296 "NPR EFT Adyen Local Unit Setup"
{
    Extensible = False;
    Caption = 'EFT Adyen Local POS Unit Setup';
    DelayedInsert = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Card;
    UsageCategory = None;
    ShowFilter = false;
    SourceTable = "NPR EFT Adyen Local Unit Setup";
    ObsoleteState = Pending;
    ObsoleteTag = '2024-09-09';
    ObsoleteReason = 'Use EFT Adyen Unit Setup instead';

    layout
    {
        area(content)
        {
            group(General)
            {
                field(TerminalIP; Rec."Terminal LAN IP")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specify the IP of the adyen terminal on the same LAN as the POS device. Do not specify the http protcol prefix or the port postfix.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '2024-09-09';
                    ObsoleteReason = 'Use EFT Adyen Unit Setup instead';
                }

                field(PoiId; Rec.POIID)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specify the unique identifier of the terminal. Format: [device model]-[serial number].';
                    ObsoleteState = Pending;
                    ObsoleteTag = '2024-09-09';
                    ObsoleteReason = 'Use EFT Adyen Unit Setup instead';
                }
            }
        }
    }
}