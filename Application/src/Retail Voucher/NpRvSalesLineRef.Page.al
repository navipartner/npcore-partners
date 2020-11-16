page 6151020 "NPR NpRv Sales Line Ref."
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher
    // NPR5.55/MHA /20200512  CASE 402015 Updated object name

    AutoSplitKey = true;
    Caption = 'Issue Retail Voucher References';
    DataCaptionExpression = Format(Quantity) + ' ' + VoucherType.Description;
    DelayedInsert = true;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR NpRv Sales Line Ref.";
    SourceTableView = SORTING("Sales Line Id", "Voucher No.", "Reference No.");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Reference No."; "Reference No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        //-NPR5.55 [402015]
        "Sales Line Id" := NpRvSalesLine.Id;
        //+NPR5.55 [402015]
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
        RefNoQty := Count;
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
        FilterGroup(2);
        NpRvVoucherMgt.SetSalesLineReferenceFilter(NpRvSalesLine, Rec);
        FilterGroup(0);

        if VoucherType.Get(NpRvSalesLine."Voucher Type") then;
    end;
}

