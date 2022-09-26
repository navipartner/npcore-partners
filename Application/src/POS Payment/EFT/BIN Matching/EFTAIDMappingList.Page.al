page 6060010 "NPR EFT AID Mapping List"
{
    Extensible = False;
    Caption = 'EFT AID Mapping List';
    PageType = List;
    SourceTable = "NPR EFT AID Mapping";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("ApplicationID"; Rec.ApplicationID)
                {

                    ToolTip = 'Application ID (AID) is an identifier that can determine card scheme (e.g. VISA or MASTERCARD) and the specific product (e.g. credit or debit card)';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Here you can specify a small helper text to distingush between AID';
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