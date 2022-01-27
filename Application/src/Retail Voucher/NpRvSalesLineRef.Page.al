page 6151020 "NPR NpRv Sales Line Ref."
{
    Extensible = False;
    AutoSplitKey = true;
    Caption = 'Issue Retail Voucher References';
    DataCaptionExpression = Format(Quantity) + ' ' + VoucherType.Description;
    DelayedInsert = true;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR NpRv Sales Line Ref.";
    SourceTableView = SORTING("Sales Line Id", "Voucher No.", "Reference No.");
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Reference No."; Rec."Reference No.")
                {

                    ToolTip = 'Specifies the value of the Reference No. field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Sales Line Id" := NpRvSalesLine.Id;
    end;

    trigger OnOpenPage()
    begin
        SetVoucherView();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        exit(CheckQuantity());
    end;

    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        VoucherType: Record "NPR NpRv Voucher Type";
        Text000: Label 'Reference No. Quantity does not match.\  - Sales Line Quantity: %1\  - Reference No. Quantity: %2\\Close anyway?';
        Quantity: Decimal;

    local procedure CheckQuantity(): Boolean
    var
        RefNoQty: Decimal;
    begin
        RefNoQty := Rec.Count();
        if Quantity = RefNoQty then
            exit(true);

        exit(Confirm(Text000, true, Quantity, RefNoQty));
    end;

    procedure SetNpRvSalesLine(NewNpRvSalesLine: Record "NPR NpRv Sales Line"; NewQuantity: Decimal)
    begin
        NpRvSalesLine := NewNpRvSalesLine;
        Quantity := NewQuantity;
    end;

    local procedure SetVoucherView()
    var
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        Rec.FilterGroup(2);
        NpRvVoucherMgt.SetSalesLineReferenceFilter(NpRvSalesLine, Rec);
        Rec.FilterGroup(0);

        if VoucherType.Get(NpRvSalesLine."Voucher Type") then;
    end;
}

