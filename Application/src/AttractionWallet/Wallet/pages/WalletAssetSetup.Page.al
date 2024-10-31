page 6184844 "NPR WalletAssetSetup"
{
    Extensible = False;
    PageType = Card;
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    SourceTable = "NPR WalletAssetSetup";
    Caption = 'Attraction Wallet Setup';

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Code field.';
                    Visible = false;
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Enabled field.';
                }
                field(WalletReferencePattern; Rec.ReferencePattern)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Use patterns within square brackets to generate dynamic content: [S]: Inserts the SystemId (up to 20 characters long). [N*4]: Generates a random numeric string of 4 digits (e.g., 8392). [A*4]: Generates a random alphabetic string of 4 letters (e.g., XQZT). [X*4] or [AN*4]: Generates a random alphanumeric string of 4 characters (e.g., A7B9). Any other text is included verbatim.';
                }
                field(EnableEndOfSalePrint; Rec.EnableEndOfSalePrint)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Enable End Of Sale Print field.', Comment = '%';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        Setup: Record "NPR WalletAssetSetup";
    begin
        if (Setup.Get()) then
            exit;

        Setup.Init();
        Setup.Insert();
    end;
}