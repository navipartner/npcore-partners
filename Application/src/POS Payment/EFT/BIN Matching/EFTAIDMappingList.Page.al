page 6060010 "NPR EFT AID Mapping List"
{
    Extensible = False;
    Caption = 'EFT AID Mapping List';
    PageType = ListPart;
    UsageCategory = none;
    SourceTable = "NPR EFT Aid Rid Mapping";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(RID; Rec.RID)
                {
                    ToolTip = 'The Registered application provider ID (RID) identifies a Card Scheme / Payment Network.';
                    ApplicationArea = NPRRetail;
                }
                field("ApplicationID"; Rec.AID)
                {

                    ToolTip = 'Application ID (AID) is an identifier that can determine card scheme (e.g. VISA or MASTERCARD) and the specific product (e.g. credit or debit card)';
                    ApplicationArea = NPRRetail;
                }
                field("Bin Group Code"; Rec."Bin Group Code")
                {

                    ToolTip = 'The Bin Group code that matches the application id.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}