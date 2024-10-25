page 6184843 "NPR TMP-AssetHeaderRef"
{
    Extensible = False;
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR WalletAssetHeaderReference";

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
                field(LinkToTableId; Rec.LinkToTableId)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Link To Table Id field.', Comment = '%';
                }
                field(LinkToSystemId; Rec.LinkToSystemId)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Link To System Id field.', Comment = '%';
                }
                field(LinkToReference; Rec.LinkToReference)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Link To Reference field.', Comment = '%';
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
                field(SystemId; Rec.SystemId)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the SystemId field.', Comment = '%';
                }
                field(WalletHeaderEntryNo; Rec.WalletHeaderEntryNo)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Wallet Line Entry No. field.', Comment = '%';
                }
            }
        }
        area(Factboxes)
        {

        }
    }

}