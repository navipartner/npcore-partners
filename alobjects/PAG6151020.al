page 6151020 "NpRv POS Issue Voucher Refs."
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher

    AutoSplitKey = true;
    Caption = 'Issue Retail Voucher References';
    DataCaptionExpression = Format(Quantity) + ' ' + VoucherType.Description;
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NpRv Sale Line POS Reference";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Reference No.";"Reference No.")
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        SetVoucherView();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        exit(CheckQuantity());
    end;

    var
        SaleLinePOSVoucher: Record "NpRv Sale Line POS Voucher";
        VoucherType: Record "NpRv Voucher Type";
        Text000: Label 'Reference No. Quantity does not match.\  - Sales Line Quantity: %1\  - Reference No. Quantity: %2\\Close anyway?';
        Quantity: Decimal;

    local procedure CheckQuantity(): Boolean
    var
        RefNoQty: Decimal;
    begin
        RefNoQty := Count;
        if Quantity = RefNoQty then
          exit(true);

        exit(Confirm(Text000,true,Quantity,RefNoQty));
    end;

    procedure SetSaleLinePOSVoucher(NewSaleLinePOSVoucher: Record "NpRv Sale Line POS Voucher";NewQuantity: Decimal)
    begin
        SaleLinePOSVoucher := NewSaleLinePOSVoucher;
        Quantity := NewQuantity;
    end;

    local procedure SetVoucherView()
    var
        NpRvVoucherMgt: Codeunit "NpRv Voucher Mgt.";
    begin
        FilterGroup(2);
        NpRvVoucherMgt.SetSaleLinePOSReferenceFilter(SaleLinePOSVoucher,Rec);
        FilterGroup(0);

        if VoucherType.Get(SaleLinePOSVoucher."Voucher Type") then;
    end;
}

