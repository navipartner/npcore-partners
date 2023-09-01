codeunit 6059981 "NPR NpRv Issue POSAction Mgt-B"
{
    Access = Internal;
    procedure FindSendMethod(POSSale: Codeunit "NPR POS Sale"; var Email: Text; var PhoneNo: Text)
    var
        Customer: Record Customer;
        SalePOS: Record "NPR POS Sale";
    begin
        POSSale.GetCurrentSale(SalePOS);
        if SalePOS."Customer No." = '' then
            exit;

        if Customer.Get(SalePOS."Customer No.") then begin
            Email := Customer."E-Mail";
            PhoneNo := Customer."Phone No.";
        end;
        ;
    end;

    procedure CreateNpRvSalesLine(POSSale: Codeunit "NPR POS Sale"; var NpRvSalesLine: Record "NPR NpRv Sales Line"; TempVoucher: Record "NPR NpRv Voucher" temporary; VoucherType: Record "NPR NpRv Voucher Type"; POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        NpRvSalesLine.Init();
        NpRvSalesLine.Id := CreateGuid();
        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::POS;
        NpRvSalesLine."Retail ID" := SaleLinePOS.SystemId;
        NpRvSalesLine."Register No." := SaleLinePOS."Register No.";
        NpRvSalesLine."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
        NpRvSalesLine."Sale Date" := SaleLinePOS.Date;
        NpRvSalesLine."Sale Line No." := SaleLinePOS."Line No.";
        NpRvSalesLine."Voucher No." := TempVoucher."No.";
        NpRvSalesLine."Reference No." := TempVoucher."Reference No.";
        NpRvSalesLine.Description := TempVoucher.Description;
        NpRvSalesLine.Type := NpRvSalesLine.Type::"New Voucher";
        NpRvSalesLine."Voucher Type" := VoucherType.Code;
        NpRvSalesLine.Description := VoucherType.Description;
        NpRvSalesLine."Starting Date" := CurrentDateTime;
        POSSale.GetCurrentSale(SalePOS);
        NpRvSalesLine.Validate("Customer No.", SalePOS."Customer No.");
        NpRvSalesLine.Insert();
    end;

    procedure CreateNpRvSalesLineRef(NpRvSalesLine: Record "NPR NpRv Sales Line"; TempVoucher: Record "NPR NpRv Voucher" temporary)
    var
        NpRvSalesLineReference: Record "NPR NpRv Sales Line Ref.";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        NpRvVoucherMgt.SetSalesLineReferenceFilter(NpRvSalesLine, NpRvSalesLineReference);
        if NpRvSalesLineReference.IsEmpty then begin
            NpRvSalesLineReference.Init();
            NpRvSalesLineReference.Id := CreateGuid();
            NpRvSalesLineReference."Voucher No." := TempVoucher."No.";
            NpRvSalesLineReference."Reference No." := TempVoucher."Reference No.";
            NpRvSalesLineReference."Sales Line Id" := NpRvSalesLine.Id;
            NpRvSalesLineReference.Insert(true);
        end;
    end;

    procedure IssueVoucherCreate(var POSSaleLine: Codeunit "NPR POS Sale Line"; var TempVoucher: Record "NPR NpRv Voucher" temporary; VoucherType: Record "NPR NpRv Voucher Type"; DiscountType: Text; Quantity: Integer; Amount: Decimal; Discount: Decimal)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        QtyNotPositiveErr: Label 'You must specify a positive quantity.';
    begin
        NpRvVoucherMgt.GenerateTempVoucher(VoucherType, TempVoucher);
        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS.Validate("Line Type", SaleLinePOS."Line Type"::"Issue Voucher");
        SaleLinePOS.Validate("No.", VoucherType."Account No.");
        SaleLinePOS.Description := VoucherType.Description;
        SaleLinePOS.Quantity := Quantity;
        if SaleLinePOS.Quantity < 0 then
            Error(QtyNotPositiveErr);

        POSSaleLine.InsertLine(SaleLinePOS);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLinePOS."Unit Price" := Amount;

        case DiscountType of
            '0':
                begin
                    SaleLinePOS."Discount Amount" := Discount * SaleLinePOS.Quantity;
                end;
            '1':
                begin
                    SaleLinePOS."Discount %" := Discount;
                end;
        end;
        SaleLinePOS."Price Includes VAT" := true;

        OverrideVoucherAmount(VoucherType, SaleLinePOS);

        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        if SaleLinePOS."Discount Amount" > 0 then
            SaleLinePOS."Discount Type" := SaleLinePOS."Discount Type"::Manual;
        SaleLinePOS.Description := TempVoucher.Description;
        SaleLinePOS.Modify(true);
    end;

    procedure SelectVoucherType(var VoucherTypeCode: Text): Boolean
    var
        VoucherType: Record "NPR NpRv Voucher Type";
    begin
        VoucherTypeCode := '';
        if Page.RunModal(0, VoucherType) <> Action::LookupOK then
            exit(false);

        VoucherTypeCode := VoucherType.Code;
        exit(true);
    end;

    local procedure OverrideVoucherAmount(VoucherType: Record "NPR NpRv Voucher Type"; var SaleLinePOS: Record "NPR POS Sale Line")
    begin
        if VoucherType."Voucher Amount" = 0 then
            exit;
        SaleLinePOS."Unit Price" := VoucherType."Voucher Amount";
    end;

    local procedure UpdateSaleLinePOS(NewReferenceNo: Text[50]; NpRvSalesLine: Record "NPR NpRv Sales Line"; var SaleLinePOS: Record "NPR POS Sale Line")
    var
        VoucherType: Record "NPR NpRv Voucher Type";
    begin
        if NewReferenceNo = NpRvSalesLine."Reference No." then
            exit;

        VoucherType.Get(NpRvSalesLine."Voucher Type");
        SaleLinePOS.Description := CopyStr(NewReferenceNo + ' ' + VoucherType.Description, 1, MaxStrLen(SaleLinePOS.Description));
        SaleLinePOS.Modify();
    end;

    procedure ContactInfo(SaleLinePOS: Record "NPR POS Sale Line")
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
    begin
        NpRvSalesLine.SetRange("Register No.", SaleLinePOS."Register No.");
        NpRvSalesLine.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        NpRvSalesLine.SetRange("Sale Date", SaleLinePOS.Date);
        NpRvSalesLine.SetRange("Sale Line No.", SaleLinePOS."Line No.");
        if not NpRvSalesLine.FindSet() then
            exit;

        repeat
            Page.RunModal(Page::"NPR NpRv Sales Line Card", NpRvSalesLine);
            Commit();
        until NpRvSalesLine.Next() = 0;
    end;

    procedure ScanReferenceNos(SaleLinePOS: Record "NPR POS Sale Line"; Quantity: Decimal)
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvSalesLineReferences: Page "NPR NpRv Sales Line Ref.";
        NpRvSalesLineRef: Record "NPR NpRv Sales Line Ref.";
    begin
        if not GuiAllowed then
            exit;

        NpRvSalesLine.SetRange("Retail ID", SaleLinePOS.SystemId);
        NpRvSalesLine.SetRange(Type, NpRvSalesLine.Type::"New Voucher");
        if not NpRvSalesLine.FindFirst() then
            exit;

        NpRvSalesLineReferences.SetNpRvSalesLine(NpRvSalesLine, Quantity);
        NpRvSalesLineReferences.RunModal();

        NpRvSalesLineRef.SetRange("Sales Line Id", NpRvSalesLine.Id);
        if NpRvSalesLineRef.FindFirst() then
            UpdateSaleLinePOS(NpRvSalesLineRef."Reference No.", NpRvSalesLine, SaleLinePOS);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale Line", 'OnBeforeSetQuantity', '', true, true)]
    local procedure OnBeforeSetQuantity(var Sender: Codeunit "NPR POS Sale Line"; SaleLinePOS: Record "NPR POS Sale Line"; var NewQuantity: Decimal)
    begin
        ScanReferenceNos(SaleLinePOS, NewQuantity);
    end;
}