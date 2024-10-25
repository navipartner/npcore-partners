page 6184845 "NPR TMP-AssetLineRef"
{
    Extensible = False;
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR WalletAssetLineReference";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field(EntryNo; Rec.EntryNo)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Entry No. field.', Comment = '%';
                }

                field(WalletEntryNo; Rec.WalletEntryNo)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Wallet Entry No. field.', Comment = '%';
                }
                field(ExpirationDate; Rec.ExpirationDate)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Expiration Date field.', Comment = '%';
                }
                field(SupersededBy; Rec.SupersededBy)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Superseded By field.', Comment = '%';
                }
                field(WalletLineEntryNo; Rec.WalletAssetLineEntryNo)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Wallet Line Entry No. field.', Comment = '%';
                }
                field(AssetType; Rec.AssetType)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Asset Type field.', Comment = '%';
                }
                field(AssetReference; Rec.AssetReference)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Asset Reference field.', Comment = '%';
                }

            }
        }
        area(Factboxes)
        {

        }
    }

}