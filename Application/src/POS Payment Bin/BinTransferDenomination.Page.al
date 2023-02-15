page 6151237 "NPR BinTransferDenomination"
{
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR BinTransferDenomination";
    Caption = 'Bin Transfer Denomination';
    InsertAllowed = false;
    Extensible = false;
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(EntryNo; Rec.EntryNo)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Entry No. field.';
                    Visible = false;
                    Editable = false;
                }
                field(Denomination; Rec.Denomination)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Denomination field.';
                    Editable = false;
                }
                field(DenominationType; Rec.DenominationType)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Type field.';
                    Editable = false;
                }
                field(DenominationVariantID; Rec.DenominationVariantID)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Denomination Variant ID field.';
                    Editable = false;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Quantity field.';
                    Editable = _IsEditable;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Amount field.';
                    Editable = _IsEditable;
                }
                field(POSPaymentMethodCode; Rec.POSPaymentMethodCode)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the POS Payment Method Code field.';
                    Visible = false;
                    Editable = false;
                }
            }
        }

    }

    internal procedure SetEditable()
    begin
        _IsEditable := true;
    end;

    var
        _IsEditable: Boolean;
}