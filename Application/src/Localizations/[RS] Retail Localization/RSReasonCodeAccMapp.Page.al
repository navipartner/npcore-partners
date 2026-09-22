page 6150980 "NPR RS Reason Code Acc. Mapp."
{
    Caption = 'RS Retail Reason Code Account Mapping';
    PageType = List;
    Extensible = false;
    UsageCategory = Administration;
    ApplicationArea = NPRRSRLocal;
    SourceTable = "NPR RS Reason Code Acc. Mapp.";
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Reason Type"; Rec."Reason Type")
                {
                    ApplicationArea = NPRRSRLocal;
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = NPRRSRLocal;
                }
                field("Surplus Account"; Rec."Surplus Account")
                {
                    ApplicationArea = NPRRSRLocal;
                }
                field("Shortage Account"; Rec."Shortage Account")
                {
                    ApplicationArea = NPRRSRLocal;
                }
            }
        }
    }
}
