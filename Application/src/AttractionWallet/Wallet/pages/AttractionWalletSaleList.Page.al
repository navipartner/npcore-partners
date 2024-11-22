page 6184876 "NPR AttractionWalletSaleList"
{
    Extensible = False;
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR AttractionWalletSaleHdr";
    Caption = 'Attraction Wallet List';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(WalletNumber; Rec.WalletNumber)
                {
                    ToolTip = 'Specifies the value of the Wallet Number field.';
                    ApplicationArea = NPRRetail;
                }
                field(ReferenceNumber; Rec.ReferenceNumber)
                {
                    ToolTip = 'Specifies the value of the Wallet Reference Number field.';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the value of the Name field.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}