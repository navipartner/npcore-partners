page 6184841 "NPR TMP-AssetHeader"
{
    Extensible = False;
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR WalletAssetHeader";

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
                field(TransactionId; Rec.TransactionId)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Transaction Id field.', Comment = '%';
                }
                field(SystemId; Rec.SystemId)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the SystemId field.', Comment = '%';
                }
            }
        }
        area(Factboxes)
        {

        }
    }

}
