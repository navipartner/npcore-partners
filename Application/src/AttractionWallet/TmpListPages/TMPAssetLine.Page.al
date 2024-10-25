page 6184842 "NPR TMP-AssetLine"
{
    Extensible = False;
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR WalletAssetLine";

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
                field(ItemNo; Rec.ItemNo)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Item No. field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field(Type; Rec."Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Type field.', Comment = '%';
                }
                field(LineTypeSystemId; Rec.LineTypeSystemId)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Line Type System Id field.', Comment = '%';
                }
                field(LineTypeReference; Rec.LineTypeReference)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Line Type Reference field.', Comment = '%';
                }
                field(TransactionId; Rec.TransactionId)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Transaction Id field.', Comment = '%';
                }
                field(TransferControlledBy; Rec.TransferControlledBy)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Transfer Controlled By field.', Comment = '%';
                }
            }
        }
        area(Factboxes)
        {

        }
    }

}