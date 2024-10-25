page 6184849 "NPR AttractionWalletList"
{
    Extensible = False;
    PageType = List;
    Editable = false;
    UsageCategory = None;
    SourceTable = "NPR AttractionWallet";
    Caption = 'Attraction Wallets';
    ShowFilter = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(ReferenceNumber; Rec.ReferenceNumber)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Reference Number field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field(ExpirationDate; Rec.ExpirationDate)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Expiration Date field.', Comment = '%';
                }
            }
        }

    }
}