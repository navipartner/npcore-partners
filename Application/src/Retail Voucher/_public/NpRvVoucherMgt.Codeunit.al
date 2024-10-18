codeunit 6151010 "NPR NpRv Voucher Mgt."
{
    TableNo = "NPR NpRv Voucher";

    trigger OnRun()
    begin
        SendSingleVoucher(Rec);
    end;

    var
        NpRegex: Codeunit "NPR RegEx";
        InvalidRefNoErr: Label 'Invalid EAN13: %1.', Comment = '%1=ReferenceNo';
        DuplicateRefNoErr: Label 'System could not generate a unique reference number for voucher %1 (voucher type %2) using reference number generation pattern %3. Please consider changing the pattern for the voucher type, and try again.', Comment = '%1 - voucher number, %2 - voucher type, %3 - reference number pattern';

    internal procedure ResetInUseQty(Voucher: Record "NPR NpRv Voucher")
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
    begin
        NpRvSalesLine.SetRange("Voucher No.", Voucher."No.");
        NpRvSalesLine.SetRange(Type, NpRvSalesLine.Type::Payment);
        if not NpRvSalesLine.IsEmpty() then
            NpRvSalesLine.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sale Line", 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeletePOSSaleLine(var Rec: Record "NPR POS Sale Line"; RunTrigger: Boolean)
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
    begin
        if Rec.IsTemporary then
            exit;

        SetSalesLineFilter(Rec, NpRvSalesLine);
        if NpRvSalesLine.IsEmpty() then
            exit;
        DeleteExternalVoucher(Rec, NpRvSalesLine);
        NpRvSalesLine.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpRv Sales Line", 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeleteNpRvSalesLine(var Rec: Record "NPR NpRv Sales Line"; RunTrigger: Boolean)
    var
        NpRvSalesLineReference: Record "NPR NpRv Sales Line Ref.";
    begin
        if Rec.IsTemporary then
            exit;

        SetSalesLineReferenceFilter(Rec, NpRvSalesLineReference);
        if NpRvSalesLineReference.IsEmpty then
            exit;

        NpRvSalesLineReference.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Create Entry", 'OnAfterInsertPOSSalesLine', '', true, false)]
    local procedure OnAfterInsertPOSSalesLine(SalePOS: Record "NPR POS Sale"; SaleLinePOS: Record "NPR POS Sale Line"; POSEntry: Record "NPR POS Entry"; var POSSalesLine: Record "NPR POS Entry Sales Line")
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
    begin
        SetSalesLineFilter(SaleLinePos, NpRvSalesLine);
        if NpRvSalesLine.IsEmpty() then
            exit;

        NpRvSalesLine.SetFilter(Type, '%1|%2|%3', NpRvSalesLine.Type::"New Voucher", NpRvSalesLine.Type::"Top-up", NpRvSalesLine.Type::"Partner Issue Voucher");
        if NpRvSalesLine.FindSet() then
            repeat
                NpRvSalesLine."Document Line No." := POSSalesLine."Line No.";
                IssueVouchers(NpRvSalesLine, SaleLinePos);
            until NpRvSalesLine.Next() = 0;

        if SaleLinePOS."Amount Including VAT" <> 0 then begin
            SetSalesLineFilter(SaleLinePos, NpRvSalesLine);
            NpRvSalesLine.SetRange(Type, NpRvSalesLine.Type::Payment);
            if NpRvSalesLine.FindFirst() then
                PostPayment(NpRvSalesLine, SaleLinePos, POSSalesLine."Line No.");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Create Entry", 'OnAfterInsertPOSPaymentLine', '', true, false)]
    local procedure OnAfterInsertPOSPaymentLine(SalePOS: Record "NPR POS Sale"; SaleLinePOS: Record "NPR POS Sale Line"; POSEntry: Record "NPR POS Entry"; POSPaymentLine: Record "NPR POS Entry Payment Line")
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
    begin
        SetSalesLineFilter(SaleLinePos, NpRvSalesLine);
        if NpRvSalesLine.IsEmpty() then
            exit;

        NpRvSalesLine.SetFilter(Type, '%1|%2|%3', NpRvSalesLine.Type::"New Voucher", NpRvSalesLine.Type::"Top-up", NpRvSalesLine.Type::"Partner Issue Voucher");
        if NpRvSalesLine.FindSet() then
            repeat
                NpRvSalesLine."Document Line No." := POSPaymentLine."Line No.";
                IssueVouchers(NpRvSalesLine, SaleLinePos);
            until NpRvSalesLine.Next() = 0;

        if SaleLinePOS."Amount Including VAT" <> 0 then begin
            SetSalesLineFilter(SaleLinePos, NpRvSalesLine);
            NpRvSalesLine.SetRange(Type, NpRvSalesLine.Type::Payment);
            if NpRvSalesLine.FindFirst() then
                PostPayment(NpRvSalesLine, SaleLinePos, POSPaymentLine."Line No.");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnAfterEndSale', '', true, true)]
    local procedure OnAfterEndSale(var Sender: Codeunit "NPR POS Sale"; SalePOS: Record "NPR POS Sale")
    begin
        SendVoucher(SalePOS);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Sales Doc. Exp. Mgt.", 'OnAfterDebitSalePostEvent', '', true, true)]
    local procedure OnAfterDebitSalePostEvent(var Sender: Codeunit "NPR Sales Doc. Exp. Mgt."; SalePOS: Record "NPR POS Sale"; SalesHeader: Record "Sales Header"; Posted: Boolean)
    begin
        SendVoucher(SalePOS);
    end;

    local procedure SendVoucher(SalePOS: Record "NPR POS Sale")
    var
        Voucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        NpDcCouponModuleMgt: Codeunit "NPR NpDc Coupon Module Mgt.";
    begin
        VoucherEntry.SetFilter("Entry Type", '%1|%2|%3', VoucherEntry."Entry Type"::"Issue Voucher", VoucherEntry."Entry Type"::Payment, VoucherEntry."Entry Type"::"Top-up");
        VoucherEntry.SetRange("Register No.", SalePOS."Register No.");
        VoucherEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        NpDcCouponModuleMgt.OnAfterSendVoucherSelection(VoucherEntry, SalePOS);

        if VoucherEntry.IsEmpty() then
            exit;

        VoucherEntry.FindSet();
        repeat
            if Voucher.Get(VoucherEntry."Voucher No.") then
                SendSingleVoucher(Voucher);
        until VoucherEntry.Next() = 0;
    end;

    procedure IssueVouchers(var NpRvSalesLine: Record "NPR NpRv Sales Line")
    var
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        VoucherType: Record "NPR NpRv Voucher Type";
        SignFactor: Integer;
        VoucherAmount: Decimal;
        VoucherQty: Decimal;
    begin
        SignFactor := 1;
        VoucherType.Get(NpRvSalesLine."Voucher Type");
        case NpRvSalesLine."Document Source" of
            NpRvSalesLine."Document Source"::"Sales Document":
                begin
                    if not GetVoucherQtyAndUnitPriceFromSalesLine(NpRvSalesLine, VoucherQty, VoucherAmount) then
                        exit;
                    if NpRvSalesLine.IsCreditDocType() then
                        SignFactor := -1;
                end;
            NpRvSalesLine."Document Source"::"Payment Line":
                begin
                    if not FindMagentoPaymentLine(NpRvSalesLine, MagentoPaymentLine) then
                        exit;

                    if ((MagentoPaymentLine."Document Table No." = Database::"Sales Header") and
                        (MagentoPaymentLine."Document Type" in [MagentoPaymentLine."Document Type"::"Credit Memo", MagentoPaymentLine."Document Type"::"Return Order"])) or
                       (MagentoPaymentLine."Document Table No." = Database::"Sales Cr.Memo Header")
                    then
                        MagentoPaymentLine.Amount := -MagentoPaymentLine.Amount;
                    if MagentoPaymentLine.Amount >= 0 then
                        exit;

                    VoucherQty := 1;
                    VoucherAmount := -MagentoPaymentLine.Amount;
                end;
        end;

        IssueVoucher(NpRvSalesLine, VoucherType, SignFactor, VoucherAmount, VoucherQty);
    end;

    internal procedure IssueVouchers(var NpRvSalesLine: Record "NPR NpRv Sales Line"; SaleLinePOS: Record "NPR POS Sale Line")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        VoucherType: Record "NPR NpRv Voucher Type";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        SignFactor: Integer;
        VoucherAmount: Decimal;
        VoucherDiscountAmount: Decimal;
        VoucherQty: Decimal;
    begin
        SignFactor := 1;
        VoucherType.Get(NpRvSalesLine."Voucher Type");
        if SaleLinePOS."Line Type" = SaleLinePOS."Line Type"::"POS Payment" then begin
            SaleLinePOS."Unit Price" := Abs(SaleLinePOS."Amount Including VAT");
            SaleLinePOS.Quantity := 1;
        end;
        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        VoucherQty := SaleLinePOS.Quantity;
        if SaleLinePOS."Line Type" = SaleLinePOS."Line Type"::"Issue Voucher" then begin
            if SaleLinePOs.Quantity <> 0 then
                VoucherAmount := SaleLinePOS."Amount Including VAT" / SaleLinePOS.Quantity
            else
                VoucherAmount := SaleLinePOS."Amount Including VAT";

            if SaleLinePOS.Quantity <> 0 then
                VoucherDiscountAmount := SaleLinePOS."Discount Amount" / SaleLinePOS.Quantity
            else
                VoucherDiscountAmount := SaleLinePOS."Discount Amount";

            if (not SaleLinePOS."Price Includes VAT") then
                VoucherAmount += POSSaleTaxCalc.CalcAmountWithVAT(VoucherDiscountAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision")
            else
                VoucherAmount += VoucherDiscountAmount
        end else
            VoucherAmount := SaleLinePOS."Unit Price";

        IssueVoucher(NpRvSalesLine, VoucherType, SignFactor, VoucherAmount, VoucherQty);
    end;

    local procedure IssueVoucher(var NpRvSalesLine: Record "NPR NpRv Sales Line"; VoucherType: Record "NPR NpRv Voucher Type"; SignFactor: Integer; VoucherAmount: Decimal; VoucherQty: Decimal)
    var
        NpRvSalesLineReference: Record "NPR NpRv Sales Line Ref.";
        i: Integer;
    begin
        if VoucherAmount <= 0 then
            exit;
        if VoucherQty <= 0 then
            exit;

        for i := 1 to VoucherQty do begin
            Clear(NpRvSalesLineReference);
            NpRvSalesLineReference.SetRange("Sales Line Id", NpRvSalesLine.Id);
            if NpRvSalesLineReference.FindFirst() then;

            IssueVoucher(VoucherType, VoucherAmount * SignFactor, NpRvSalesLine, NpRvSalesLineReference);
        end;
    end;

    local procedure IssueVoucher(VoucherType: Record "NPR NpRv Voucher Type"; VoucherAmount: Decimal; var NpRvSalesLine: Record "NPR NpRv Sales Line"; var NpRvSalesLineReference: Record "NPR NpRv Sales Line Ref.")
    var
        Voucher: Record "NPR NpRv Voucher";
        PrevVoucher: Text;
    begin
        case true of
            (NpRvSalesLine."Document Source" = NpRvSalesLine."Document Source"::"Sales Document") and NpRvSalesLine.IsCreditDocType(),
            NpRvSalesLine.Type = NpRvSalesLine.Type::"Top-up":
                Voucher.Get(NpRvSalesLine."Voucher No.");

            NpRvSalesLine.Type = NpRvSalesLine.Type::"New Voucher":
                begin
                    if NpRvSalesLineReference."Reference No." = '' then
                        VoucherType.TestField("Reference No. Pattern");

                    Voucher.Init();
                    if NpRvSalesLine."Starting Date" > CurrentDateTime then
                        Voucher."Starting Date" := NpRvSalesLine."Starting Date";
                    Voucher.Validate("Voucher Type", VoucherType.Code);
                    Voucher."No." := NpRvSalesLineReference."Voucher No.";
                    Voucher."Reference No." := NpRvSalesLineReference."Reference No.";
                    OnBeforeInsertIssuedVoucher(Voucher, NpRvSalesLine);
                    Voucher.Insert(true);

                    PrevVoucher := Format(Voucher);
                    Voucher.Description := CopyStr(Voucher."Reference No." + ' ' + VoucherType.Description, 1, MaxStrLen(Voucher.Description));
                    Voucher."Customer No." := NpRvSalesLine."Customer No.";
                    Voucher."Contact No." := NpRvSalesLine."Contact No.";
                    Voucher.Name := NpRvSalesLine.Name;
                    Voucher."Name 2" := NpRvSalesLine."Name 2";
                    Voucher.Address := NpRvSalesLine.Address;
                    Voucher."Address 2" := NpRvSalesLine."Address 2";
                    Voucher."Post Code" := NpRvSalesLine."Post Code";
                    Voucher.City := NpRvSalesLine.City;
                    Voucher.County := NpRvSalesLine.County;
                    Voucher."Country/Region Code" := NpRvSalesLine."Country/Region Code";
                    Voucher."E-mail" := NpRvSalesLine."E-mail";
                    Voucher."Phone No." := NpRvSalesLine."Phone No.";
                    Voucher."Send via Print" := NpRvSalesLine."Send via Print";
                    Voucher."Send via E-mail" := NpRvSalesLine."Send via E-mail";
                    Voucher."Send via SMS" := NpRvSalesLine."Send via SMS";
                    Voucher."Voucher Message" := NpRvSalesLine."Voucher Message";
                    OnBeforeModifyIssuedVoucher(Voucher, NpRvSalesLine, VoucherType);
                    if PrevVoucher <> Format(Voucher) then
                        Voucher.Modify(true);
                end;
        end;

        if NpRvSalesLineReference.Find() then
            NpRvSalesLineReference.Delete();

        PostIssueVoucher(Voucher, VoucherType, VoucherAmount, NpRvSalesLine);
        MarkRetailVoucherSalesLineAsPosted(NpRvSalesLine.Id);
    end;

    local procedure FindMagentoPaymentLine(NpRvSalesLine: Record "NPR NpRv Sales Line"; var MagentoPaymentLine: Record "NPR Magento Payment Line"): Boolean
    begin
        MagentoPaymentLine.SetFilter("Document Table No.", '%1|%2', Database::"Sales Invoice Header", Database::"Sales Cr.Memo Header");
        MagentoPaymentLine.SetRange("Document Type", 0);
        MagentoPaymentLine.SetRange("Document No.", NpRvSalesLine."Posting No.");
        MagentoPaymentLine.SetRange("Line No.", NpRvSalesLine."Document Line No.");
        if MagentoPaymentLine.FindFirst() then
            exit(true);

        if MagentoPaymentLine.Get(Database::"Sales Header", NpRvSalesLine."Document Type", NpRvSalesLine."Document No.", NpRvSalesLine."Document Line No.") then
            exit(true);

        exit(false);
    end;

    local procedure MarkRetailVoucherSalesLineAsPosted(NpRvSalesLineId: Guid)
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
    begin
        if NpRvSalesLine.Get(NpRvSalesLineId) then
            if not NpRvSalesLine.Posted then begin
                NpRvSalesLine.Posted := true;
                NpRvSalesLine.Modify();
            end;
    end;

    internal procedure GetVoucherQtyAndUnitPriceFromSalesLine(NpRvSalesLine: Record "NPR NpRv Sales Line"; var VoucherQty: Decimal; var VoucherUnitPrice: Decimal): Boolean
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        VoucherQty := 0;
        VoucherUnitPrice := 0;
        if not SalesLine.Get(NpRvSalesLine."Document Type", NpRvSalesLine."Document No.", NpRvSalesLine."Document Line No.") then
            exit(false);

        VoucherQty := SalesLine."Qty. to Invoice";
        VoucherUnitPrice := SalesLine."Unit Price";
        if SalesHeader.Get(SalesHeader."Document Type", SalesLine."Document No.") and not SalesHeader."Prices Including VAT" then
            VoucherUnitPrice := VoucherUnitPrice * (1 + SalesLine."VAT %" / 100);

        exit(true);
    end;

    internal procedure InitialEntryExists(Voucher: Record "NPR NpRv Voucher"): Boolean
    var
        VoucherEntry: Record "NPR NpRv Voucher Entry";
    begin
        VoucherEntry.SetCurrentKey("Voucher No.", "Entry Type", "Partner Code");
        VoucherEntry.SetRange("Voucher No.", Voucher."No.");
        VoucherEntry.SetRange("Entry Type", VoucherEntry."Entry Type"::"Issue Voucher");
        exit(not VoucherEntry.IsEmpty());
    end;

    local procedure PostIssueVoucher(Voucher: Record "NPR NpRv Voucher"; VoucherType: Record "NPR NpRv Voucher Type"; VoucherAmount: Decimal; var NpRvSalesLine: Record "NPR NpRv Sales Line")
    var
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        POSUnit: Record "NPR POS Unit";
    begin
        VoucherEntry.Init();
        VoucherEntry."Entry No." := 0;
        VoucherEntry."Voucher No." := Voucher."No.";
        VoucherEntry.Correction :=
            (NpRvSalesLine."Document Source" = NpRvSalesLine."Document Source"::"Sales Document") and NpRvSalesLine.IsCreditDocType();
        case NpRvSalesLine.Type of
            NpRvSalesLine.Type::"New Voucher":
                begin
                    if not VoucherEntry.Correction then
                        if InitialEntryExists(Voucher) then
                            exit;

                    VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::"Issue Voucher";
                end;
            NpRvSalesLine.Type::"Top-up":
                VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::"Top-up";
            NpRvSalesLine.Type::"Partner Issue Voucher":
                begin
                    if not VoucherEntry.Correction then
                        if InitialEntryExists(Voucher) then
                            exit;

                    VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::"Partner Issue Voucher";
                end;
        end;
        VoucherEntry."Voucher Type" := Voucher."Voucher Type";
        VoucherEntry.Amount := VoucherAmount;
        VoucherEntry."Remaining Amount" := VoucherEntry.Amount;
        VoucherEntry.Positive := VoucherEntry.Amount > 0;
        VoucherEntry."Posting Date" := Workdate();
        VoucherEntry.Open := VoucherEntry.Amount <> 0;
        VoucherEntry."Register No." := NpRvSalesLine."Register No.";
        if POSUnit.Get(VoucherEntry."Register No.") then
            VoucherEntry."POS Store Code" := POSUnit."POS Store Code";
        VoucherEntry.Company := CopyStr(CompanyName(), 1, MaxStrLen(VoucherEntry.Company));
        case NpRvSalesLine."Document Source" of
            NpRvSalesLine."Document Source"::POS:
                begin
                    VoucherEntry."Document Type" := VoucherEntry."Document Type"::"POS Entry";
                    VoucherEntry."Document No." := NpRvSalesLine."Sales Ticket No.";
                    VoucherEntry."Document Line No." := NpRvSalesLine."Document Line No.";
                end;
            NpRvSalesLine."Document Source"::"Sales Document",
            NpRvSalesLine."Document Source"::"Payment Line":
                begin
                    if NpRvSalesLine.IsCreditDocType() then
                        VoucherEntry."Document Type" := VoucherEntry."Document Type"::"Credit Memo"
                    else
                        VoucherEntry."Document Type" := VoucherEntry."Document Type"::Invoice;
                    VoucherEntry."Document No." := NpRvSalesLine."Posting No.";
                    VoucherEntry."Document Line No." := NpRvSalesLine."Document Line No.";
                    VoucherEntry."External Document No." := NpRvSalesLine."External Document No.";
                end;
        end;
        VoucherEntry."Partner Code" := VoucherType."Partner Code";
        VoucherEntry."User ID" := CopyStr(UserId, 1, MaxStrLen(VoucherEntry."User ID"));
        VoucherEntry."Closed by Entry No." := 0;
        OnBeforeInsertIssuedVoucherEntry(VoucherEntry, Voucher, NpRvSalesLine);
        VoucherEntry.Insert();

        case VoucherEntry."Entry Type" of
            VoucherEntry."Entry Type"::"Issue Voucher":
                CreateGlobalVoucher(Voucher);
            VoucherEntry."Entry Type"::"Top-up":
                TopUpVoucher(VoucherEntry, Voucher);
        end;

        ApplyEntry(VoucherEntry);
        if VoucherEntry."Entry Type" = VoucherEntry."Entry Type"::"Top-up" then
            ExtendVoucherEndingDate(VoucherEntry."Posting Date", Voucher);
    end;


    local procedure PostIssueForeignVoucher(Voucher: Record "NPR NpRv Voucher"; VoucherType: Record "NPR NpRv Voucher Type"; VoucherAmount: Decimal; var NpRvSalesLine: Record "NPR NpRv Sales Line")
    var
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        POSUnit: Record "NPR POS Unit";
    begin
        VoucherEntry.Init();
        VoucherEntry."Entry No." := 0;
        VoucherEntry."Voucher No." := Voucher."No.";
        if InitialEntryExists(Voucher) then
            exit;
        VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::"Partner Issue Voucher";
        VoucherEntry."Voucher Type" := Voucher."Voucher Type";
        VoucherEntry.Amount := VoucherAmount;
        VoucherEntry."Remaining Amount" := VoucherEntry.Amount;
        VoucherEntry.Positive := VoucherEntry.Amount > 0;
        VoucherEntry."Posting Date" := WorkDate();
        VoucherEntry.Open := VoucherEntry.Amount <> 0;
        VoucherEntry."Register No." := NpRvSalesLine."Register No.";
        if POSUnit.Get(VoucherEntry."Register No.") then
            VoucherEntry."POS Store Code" := POSUnit."POS Store Code";
        VoucherEntry.Company := CopyStr(CompanyName(), 1, MaxStrLen(VoucherEntry.Company));
        VoucherEntry."Document Type" := VoucherEntry."Document Type"::"POS Entry";
        VoucherEntry."External Document No." := NpRvSalesLine."Sales Ticket No.";

        VoucherEntry."Partner Code" := VoucherType."Partner Code";
        VoucherEntry."User ID" := CopyStr(UserId, 1, MaxStrLen(VoucherEntry."User ID"));
        VoucherEntry."Closed by Entry No." := 0;
        OnBeforeInsertIssuedForeignVoucherEntry(VoucherEntry, Voucher, NpRvSalesLine);
        VoucherEntry.Insert();
    end;

    [Obsolete('Replaced with Codeunit.run(Codeunit::"NPR NpRv Voucher Mgt."...)', '2023-06-28')]
    internal procedure SendVoucher(Voucher: Record "NPR NpRv Voucher")
    begin
        SendSingleVoucher(Voucher);
    end;

    local procedure SendSingleVoucher(Voucher: Record "NPR NpRv Voucher")
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        NpRvModuleMgt: Codeunit "NPR NpRv Module Mgt.";
        NpRvModuleSendDefault: Codeunit "NPR NpRv Module Send: Def.";
        Handled: Boolean;
    begin
        if not VoucherType.Get(Voucher."Voucher Type") then
            exit;

        Voucher.CalcFields(Amount);
        if Voucher.Amount <= 0 then
            exit;

        Voucher.CalcFields("Send Voucher Module");
        NpRvModuleMgt.OnRunSendVoucher(Voucher, VoucherType, Handled);

        if not Handled then
            NpRvModuleSendDefault.SendVoucher(Voucher);
    end;

    internal procedure LogSending(NpRvVoucher: Record "NPR NpRv Voucher"; SendingType: Integer; LogMessage: Text; SentTo: Text; ErrorMessage: Text)
    var
        NpRvSendingLog: Record "NPR NpRv Sending Log";
        OutStr: OutStream;
    begin
        NpRvVoucher.CalcFields(Amount);

        NpRvSendingLog.Init();
        NpRvSendingLog."Entry No." := 0;
        NpRvSendingLog."Voucher No." := NpRvVoucher."No.";
        NpRvSendingLog."Log Date" := CurrentDateTime;
        if SendingType > 0 then
            NpRvSendingLog."Sending Type" := SendingType;
        NpRvSendingLog."Log Message" := CopyStr(LogMessage, 1, MaxStrLen(NpRvSendingLog."Log Message"));
        NpRvSendingLog."Sent to" := CopyStr(SentTo, 1, MaxStrLen(NpRvSendingLog."Sent to"));
        NpRvSendingLog.Amount := NpRvVoucher.Amount;
        NpRvSendingLog."User ID" := CopyStr(UserId, 1, MaxStrLen(NpRvSendingLog."User ID"));
        NpRvSendingLog."Error during Send" := ErrorMessage <> '';
        if ErrorMessage <> '' then begin
            NpRvSendingLog."Error Message".CreateOutStream(OutStr, TEXTENCODING::UTF8);
            OutStr.WriteText(ErrorMessage);
        end;
        NpRvSendingLog.Insert(true);
    end;

    [Obsolete('Delete when final v1/v2 workflow is gone', '2023-06-28')]
    internal procedure ApplyPayment(FrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session"; NpRvSalesLine: Record "NPR NpRv Sales Line"; EndSale: Boolean)
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        NpRvModuleMgt: Codeunit "NPR NpRv Module Mgt.";
        NpRvModulePaymentDefault: Codeunit "NPR NpRv Module Pay.: Default";
        Handled: Boolean;
    begin
        VoucherType.Get(NpRvSalesLine."Voucher Type");
        NpRvModuleMgt.OnRunApplyPayment(FrontEnd, POSSession, VoucherType, NpRvSalesLine, EndSale, Handled);
        if Handled then
            exit;

        NpRvModulePaymentDefault.ApplyPayment(FrontEnd, POSSession, VoucherType, NpRvSalesLine, EndSale);
    end;

    internal procedure PostPayment(var NpRvSalesLine: Record "NPR NpRv Sales Line")
    var
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        Voucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        POSUnit: Record "NPR POS Unit";
    begin
        if not FindMagentoPaymentLine(NpRvSalesLine, MagentoPaymentLine) then
            exit;

        Voucher.Get(NpRvSalesLine."Voucher No.");

        InitVoucherEntry(Voucher, VoucherEntry);
        if (MagentoPaymentLine."Document Table No." = Database::"Sales Cr.Memo Header") or
           (MagentoPaymentLine."Document Type" in [MagentoPaymentLine."Document Type"::"Credit Memo", MagentoPaymentLine."Document Type"::"Return Order"])
        then
            VoucherEntry."Document Type" := VoucherEntry."Document Type"::"Credit Memo"
        else
            VoucherEntry."Document Type" := VoucherEntry."Document Type"::Invoice;

        if NpRvSalesLine."Posting No." <> '' then
            VoucherEntry."Document No." := NpRvSalesLine."Posting No."
        else
            VoucherEntry."Document No." := MagentoPaymentLine."Document No.";
        VoucherEntry."Posting Date" := MagentoPaymentLine."Posting Date";
        if VoucherEntry."Document Type" = VoucherEntry."Document Type"::"Credit Memo" then
            VoucherEntry.Amount := MagentoPaymentLine.Amount
        else
            VoucherEntry.Amount := -MagentoPaymentLine.Amount;
        if POSUnit.Get(NpRvSalesLine."Register No.") then
            VoucherEntry."POS Store Code" := POSUnit."POS Store Code";
        VoucherEntry.Company := CopyStr(CompanyName(), 1, MaxStrLen(VoucherEntry.Company));
        VoucherEntry."Remaining Amount" := VoucherEntry.Amount;
        VoucherEntry.Positive := VoucherEntry.Amount > 0;
        VoucherEntry.Open := VoucherEntry.Amount <> 0;
        VoucherEntry.Correction := VoucherEntry."Document Type" = VoucherEntry."Document Type"::"Credit Memo";
        OnBeforeInsertPaymentVoucherEntry(VoucherEntry, NpRvSalesLine);
        VoucherEntry.Insert();

        RedeemVoucher(VoucherEntry, Voucher);
        RedeemPartnerVouchers(VoucherEntry, Voucher);

        ApplyEntry(VoucherEntry);
        ArchiveClosedVoucher(Voucher);
        MarkRetailVoucherSalesLineAsPosted(NpRvSalesLine.Id);
    end;

    internal procedure PostPayment(var NpRvSalesLine: Record "NPR NpRv Sales Line"; SaleLinePOS: Record "NPR POS Sale Line"; DocumentLineNo: Integer)
    var
        Voucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        POSUnit: Record "NPR POS Unit";
    begin
        Voucher.Get(NpRvSalesLine."Voucher No.");

        InitVoucherEntry(Voucher, VoucherEntry);
        VoucherEntry."Document Type" := VoucherEntry."Document Type"::"POS Entry";
        VoucherEntry."Register No." := SaleLinePOS."Register No.";
        VoucherEntry."Document No." := SaleLinePOS."Sales Ticket No.";
        VoucherEntry."Document Line No." := DocumentLineNo;
        VoucherEntry."Posting Date" := SaleLinePOS.Date;
        VoucherEntry.Amount := -SaleLinePOS."Amount Including VAT";
        VoucherEntry."Remaining Amount" := VoucherEntry.Amount;
        if POSUnit.Get(NpRvSalesLine."Register No.") then
            VoucherEntry."POS Store Code" := POSUnit."POS Store Code";
        VoucherEntry.Company := CopyStr(CompanyName(), 1, MaxStrLen(VoucherEntry.Company));
        VoucherEntry.Positive := VoucherEntry.Amount > 0;
        VoucherEntry.Open := VoucherEntry.Amount <> 0;
        OnBeforeInsertPaymentVoucherEntry(VoucherEntry, NpRvSalesLine);
        VoucherEntry.Insert();

        RedeemVoucher(VoucherEntry, Voucher);
        RedeemPartnerVouchers(VoucherEntry, Voucher);

        ApplyEntry(VoucherEntry);
        ArchiveClosedVoucher(Voucher);
        MarkRetailVoucherSalesLineAsPosted(NpRvSalesLine.Id);
    end;

    local procedure InitVoucherEntry(var Voucher: Record "NPR NpRv Voucher"; var VoucherEntry: Record "NPR NpRv Voucher Entry")
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
    begin
        VoucherEntry.Init();
        VoucherEntry."Entry No." := 0;
        VoucherEntry."Voucher No." := Voucher."No.";
        VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::Payment;
        VoucherEntry."Voucher Type" := Voucher."Voucher Type";
        VoucherEntry."User ID" := CopyStr(UserId, 1, MaxStrLen(VoucherEntry."User ID"));
        VoucherEntry."Closed by Entry No." := 0;
        if NpRvVoucherType.Get(Voucher."Voucher Type") then
            VoucherEntry."Partner Code" := NpRvVoucherType."Partner Code";
    end;

    procedure ApplyEntry(var VoucherEntry: Record "NPR NpRv Voucher Entry")
    var
        VoucherEntryApply: Record "NPR NpRv Voucher Entry";
    begin
        if VoucherEntry.IsTemporary then
            exit;
        if not VoucherEntry.Open then
            exit;
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21)
        VoucherEntryApply.ReadIsolation := IsolationLevel::ReadCommitted;
#ENDIF
        VoucherEntryApply.SetCurrentKey("Voucher No.", Open, Positive);
        VoucherEntryApply.SetRange("Voucher No.", VoucherEntry."Voucher No.");
        VoucherEntryApply.SetRange(Open, true);
        VoucherEntryApply.SetRange(Positive, not VoucherEntry.Positive);
        if VoucherEntryApply.FindSet() then
            repeat
                if Abs(VoucherEntryApply."Remaining Amount") >= Abs(VoucherEntry."Remaining Amount") then
                    ApplyEntry(VoucherEntryApply, VoucherEntry)
                else
                    ApplyEntry(VoucherEntry, VoucherEntryApply);

                VoucherEntry."Partner Clearing" := VoucherEntry."Partner Code" <> VoucherEntry."Closed by Partner Code";
                VoucherEntryApply."Partner Clearing" := VoucherEntryApply."Partner Code" <> VoucherEntryApply."Closed by Partner Code";
                VoucherEntry.Modify();
                VoucherEntryApply.Modify();
            until (VoucherEntryApply.Next() = 0) or not VoucherEntry.Open;
    end;

    local procedure ApplyEntry(var VoucherEntryApply: Record "NPR NpRv Voucher Entry"; var VoucherEntry: Record "NPR NpRv Voucher Entry")
    begin
        VoucherEntryApply."Remaining Amount" += VoucherEntry."Remaining Amount";
        if VoucherEntryApply."Remaining Amount" = 0 then begin
            VoucherEntryApply."Closed by Entry No." := VoucherEntry."Entry No.";
            VoucherEntryApply."Closed by Partner Code" := VoucherEntry."Partner Code";
            VoucherEntryApply.Open := false;
        end;

        VoucherEntry."Remaining Amount" := 0;
        VoucherEntry."Closed by Entry No." := VoucherEntryApply."Entry No.";
        VoucherEntry."Closed by Partner Code" := VoucherEntryApply."Partner Code";
        VoucherEntry.Open := false;
    end;

    procedure ArchiveVouchers(var VoucherFilter: Record "NPR NpRv Voucher")
    var
        Voucher: Record "NPR NpRv Voucher";
    begin
        Voucher.Copy(VoucherFilter);
        if Voucher.GetFilters = '' then
            Voucher.SetRecFilter();

        if not Voucher.FindSet() then
            exit;

        repeat
            ArchiveVoucher(Voucher);
        until Voucher.Next() = 0;
    end;

    local procedure ArchiveVoucher(var Voucher: Record "NPR NpRv Voucher")
    var
        VoucherEntry: Record "NPR NpRv Voucher Entry";
    begin
        Voucher.CalcFields(Amount);
        if Voucher.Amount <> 0 then begin
            VoucherEntry.Init();
            VoucherEntry."Entry No." := 0;
            VoucherEntry."Voucher No." := Voucher."No.";
            VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::"Manual Archive";
            VoucherEntry."Voucher Type" := Voucher."Voucher Type";
            VoucherEntry.Amount := -Voucher.Amount;
            VoucherEntry."Remaining Amount" := VoucherEntry.Amount;
            VoucherEntry.Positive := VoucherEntry.Amount > 0;
            VoucherEntry."Posting Date" := Today();
            VoucherEntry.Open := true;
            VoucherEntry."Register No." := '';
            VoucherEntry."Document No." := '';
            VoucherEntry."User ID" := CopyStr(UserId, 1, MaxStrLen(VoucherEntry."User ID"));
            VoucherEntry."Closed by Entry No." := 0;
            VoucherEntry.Insert();

            ApplyEntry(VoucherEntry);
        end;

        ArchiveClosedVoucher(Voucher);
    end;

    internal procedure ArchiveClosedVoucher(var Voucher: Record "NPR NpRv Voucher")
    var
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        NpRvSendingLog: Record "NPR NpRv Sending Log";
    begin
        Voucher.CalcFields(Open);
        if Voucher.Open then
            exit;

        if Voucher."Allow Top-up" then
            exit;

        InsertArchivedVoucher(Voucher, ArchVoucher);
        VoucherEntry.SetRange("Voucher No.", Voucher."No.");
        if VoucherEntry.FindSet() then begin
            repeat
                InsertArchivedVoucherEntry(ArchVoucher, VoucherEntry);
            until VoucherEntry.Next() = 0;
            VoucherEntry.DeleteAll();
        end;
        NpRvSendingLog.SetRange("Voucher No.", Voucher."No.");
        if NpRvSendingLog.FindSet() then begin
            repeat
                InsertArchivedSendingLog(ArchVoucher, NpRvSendingLog);
            until NpRvSendingLog.Next() = 0;
            NpRvSendingLog.DeleteAll();
        end;
        OnAfterArchiveVoucher(Voucher, ArchVoucher);
        Voucher.Delete();
    end;

    local procedure InsertArchivedVoucher(Voucher: Record "NPR NpRv Voucher"; var ArchVoucher: Record "NPR NpRv Arch. Voucher")
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        VoucherType.Get(Voucher."Voucher Type");
        Voucher."Arch. No." := Voucher."No.";
        if (Voucher."No. Series" <> VoucherType."Arch. No. Series") and (VoucherType."Arch. No. Series" <> '') then begin
            Voucher."Arch. No. Series" := VoucherType."Arch. No. Series";
            Voucher."Arch. No." := NoSeriesMgt.GetNextNo(VoucherType."Arch. No. Series", Today, true);
        end;

        ArchVoucher.Init();
        ArchVoucher."No." := Voucher."Arch. No.";
        ArchVoucher."Voucher Type" := Voucher."Voucher Type";
        ArchVoucher.Description := Voucher.Description;
        ArchVoucher."Reference No." := Voucher."Reference No.";
        ArchVoucher."Starting Date" := Voucher."Starting Date";
        ArchVoucher."Ending Date" := Voucher."Ending Date";
        ArchVoucher."No. Series" := Voucher."No. Series";
        ArchVoucher."Arch. No. Series" := Voucher."Arch. No. Series";
        ArchVoucher."Arch. No." := Voucher."No.";
        ArchVoucher."Account No." := Voucher."Account No.";
        ArchVoucher."Provision Account No." := Voucher."Provision Account No.";
        ArchVoucher."Print Object Type" := Voucher."Print Object Type";
        ArchVoucher."Print Object ID" := Voucher."Print Object ID";
        ArchVoucher."Print Template Code" := Voucher."Print Template Code";
        ArchVoucher."Customer No." := Voucher."Customer No.";
        ArchVoucher."Contact No." := Voucher."Contact No.";
        ArchVoucher.Name := Voucher.Name;
        ArchVoucher."Name 2" := Voucher."Name 2";
        ArchVoucher.Address := Voucher.Address;
        ArchVoucher."Address 2" := Voucher."Address 2";
        ArchVoucher."Post Code" := Voucher."Post Code";
        ArchVoucher.City := Voucher.City;
        ArchVoucher.County := Voucher.County;
        ArchVoucher."Country/Region Code" := Voucher."Country/Region Code";
        ArchVoucher."E-mail" := Voucher."E-mail";
        ArchVoucher."Phone No." := Voucher."Phone No.";
        ArchVoucher."Voucher Message" := Voucher."Voucher Message";
        ArchVoucher."E-mail Template Code" := Voucher."E-mail Template Code";
        ArchVoucher."SMS Template Code" := Voucher."SMS Template Code";
        ArchVoucher."Send via Print" := Voucher."Send via Print";
        ArchVoucher."Send via E-mail" := Voucher."Send via E-mail";
        ArchVoucher."Send via SMS" := Voucher."Send via SMS";
        ArchVoucher.Comment := Voucher.Comment;
        OnBeforeInsertArchivedVoucher(Voucher, ArchVoucher);
        ArchVoucher.Insert();
    end;

    local procedure InsertArchivedVoucherEntry(ArchVoucher: Record "NPR NpRv Arch. Voucher"; VoucherEntry: Record "NPR NpRv Voucher Entry")
    var
        ArchVoucherEntry: Record "NPR NpRv Arch. Voucher Entry";
    begin
        SelectLatestVersion();

        ArchVoucherEntry.Init();
        ArchVoucherEntry."Entry No." := 0;
        ArchVoucherEntry."Original Entry No." := VoucherEntry."Entry No.";
        ArchVoucherEntry."Arch. Voucher No." := ArchVoucher."No.";
        ArchVoucherEntry."Entry Type" := VoucherEntry."Entry Type";
        ArchVoucherEntry."Voucher Type" := VoucherEntry."Voucher Type";
        ArchVoucherEntry.Positive := VoucherEntry.Positive;
        ArchVoucherEntry.Amount := VoucherEntry.Amount;
        ArchVoucherEntry."Posting Date" := VoucherEntry."Posting Date";
        ArchVoucherEntry.Open := VoucherEntry.Open;
        ArchVoucherEntry."Remaining Amount" := VoucherEntry."Remaining Amount";
        ArchVoucherEntry."Register No." := VoucherEntry."Register No.";
        ArchVoucherEntry."Document Type" := VoucherEntry."Document Type";
        ArchVoucherEntry."External Document No." := VoucherEntry."External Document No.";
        ArchVoucherEntry."Document No." := VoucherEntry."Document No.";
        ArchVoucherEntry."Document Line No." := VoucherEntry."Document Line No.";
        ArchVoucherEntry."User ID" := VoucherEntry."User ID";
        ArchVoucherEntry."POS Store Code" := VoucherEntry."POS Store Code";
        ArchVoucherEntry.Company := VoucherEntry.Company;
        ArchVoucherEntry."Partner Code" := VoucherEntry."Partner Code";
        ArchVoucherEntry."Closed by Partner Code" := VoucherEntry."Closed by Partner Code";
        ArchVoucherEntry."Partner Clearing" := VoucherEntry."Partner Clearing";
        ArchVoucherEntry.Correction := VoucherEntry.Correction;
        ArchVoucherEntry."Closed by Entry No." := VoucherEntry."Closed by Entry No.";
        OnBeforeInsertArchiveEntry(ArchVoucherEntry, VoucherEntry);
        ArchVoucherEntry.Insert();
    end;

    local procedure InsertArchivedSendingLog(ArchVoucher: Record "NPR NpRv Arch. Voucher"; NpRvSendingLog: Record "NPR NpRv Sending Log")
    var
        NpRvArchSendingLog: Record "NPR NpRv Arch. Sending Log";
    begin
        NpRvArchSendingLog.Init();
        NpRvArchSendingLog."Entry No." := 0;
        NpRvArchSendingLog."Arch. Voucher No." := ArchVoucher."No.";
        NpRvArchSendingLog."Sending Type" := NpRvSendingLog."Sending Type";
        NpRvArchSendingLog."Log Message" := NpRvSendingLog."Log Message";
        NpRvArchSendingLog."Log Date" := NpRvSendingLog."Log Date";
        NpRvArchSendingLog."Sent to" := NpRvSendingLog."Sent to";
        NpRvArchSendingLog.Amount := NpRvSendingLog.Amount;
        NpRvArchSendingLog."User ID" := NpRvSendingLog."User ID";
        NpRvArchSendingLog."Error during Send" := NpRvSendingLog."Error during Send";
        if NpRvSendingLog."Error Message".HasValue() then begin
            NpRvSendingLog.CalcFields("Error Message");
            NpRvArchSendingLog."Error Message" := NpRvSendingLog."Error Message";
        end;
        NpRvArchSendingLog."Original Entry No." := NpRvSendingLog."Entry No.";
        NpRvArchSendingLog.Insert();
    end;

    internal procedure UnarchiveVoucher(ArchVoucherCode: Code[20]; RemoveLastEntry: Boolean)
    var
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        Voucher: Record "NPR NpRv Voucher";
    begin
        ArchVoucher.Get(ArchVoucherCode);
#if not BC17
        ArchVoucher.TestField("Disabled at Shopify", false);
#endif

        Voucher.Init();
        Voucher.TransferFields(ArchVoucher);
        Voucher."No." := ArchVoucher."Arch. No.";
        if Voucher."No." = '' then
            Voucher."No." := ArchVoucher."No.";
        Voucher.Insert();

        UnarchiveVoucherEntries(ArchVoucher."No.", Voucher."No.", RemoveLastEntry);
        UnarchiveVoucherSendingLogs(ArchVoucher."No.", Voucher."No.");
        OnAfterUnArchiveVoucher(ArchVoucher, Voucher);

        ArchVoucher.Delete();
    end;

    local procedure UnarchiveVoucherEntries(ArchVoucherNo: Code[20]; RestoredVoucherNo: Code[20]; RemoveLastEntry: Boolean)
    var
        ArchVoucherEntry: Record "NPR NpRv Arch. Voucher Entry";
        SalesInvHeader: Record "Sales Invoice Header";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        Voucher: Record "NPR NpRv Voucher";
        VoucherType: Record "NPR NpRv Voucher Type";
        LastEntry: Boolean;
        CannotBeUnarchived: Label 'The Voucher %1 cannot be unarchived as the document it was last redeemed in has already been posted.', Comment = '%1 = Retail voucher number';
    begin
        ArchVoucherEntry.SetRange("Arch. Voucher No.", ArchVoucherNo);

        if RemoveLastEntry then
            if ArchVoucherEntry.FindLast() then begin
                case ArchVoucherEntry."Document Type" of
                    ArchVoucherEntry."Document Type"::Invoice:
                        if SalesInvHeader.Get(ArchVoucherEntry."Document No.") then
                            Error(CannotBeUnarchived, ArchVoucherNo);
                    ArchVoucherEntry."Document Type"::"POS Entry":
                        Error(CannotBeUnarchived, ArchVoucherNo);
                end;
            end;

        if ArchVoucherEntry.FindSet(true) then
            repeat
                VoucherEntry.Init();
                VoucherEntry.TransferFields(ArchVoucherEntry);
                VoucherEntry."Entry No." := ArchVoucherEntry."Original Entry No.";
                VoucherEntry."Voucher No." := RestoredVoucherNo;
                VoucherEntry.Open := true;
                LastEntry := ArchVoucherEntry.Next() = 0;
                if not (LastEntry and RemoveLastEntry) then begin
                    VoucherEntry.Insert();

                    if Voucher.Get(VoucherEntry."Entry No.") then begin
                        VoucherType.Get(Voucher."Voucher Type");
                        ProcessGlobalVoucherEntry(VoucherEntry, Voucher);
                    end;
                end;
            until LastEntry;
        ArchVoucherEntry.DeleteAll();
    end;

    local procedure ProcessGlobalVoucherEntry(VoucherEntry: Record "NPR NpRv Voucher Entry"; Voucher: Record "NPR NpRv Voucher")
    var
    begin
        case VoucherEntry."Entry Type" of
            VoucherEntry."Entry Type"::"Issue Voucher":
                CreateGlobalVoucher(Voucher);
            VoucherEntry."Entry Type"::Payment:
                begin
                    RedeemVoucher(VoucherEntry, Voucher);
                    RedeemPartnerVouchers(VoucherEntry, Voucher);
                end;
            VoucherEntry."Entry Type"::"Partner Payment":
                RedeemPartnerVouchers(VoucherEntry, Voucher);
            VoucherEntry."Entry Type"::"Top-up":
                TopUpVoucher(VoucherEntry, Voucher);
        end;
    end;

    local procedure UnarchiveVoucherSendingLogs(ArchVoucherNo: Code[20]; RestoredVoucherNo: Code[20])
    var
        ArchVoucherSendingLog: Record "NPR NpRv Arch. Sending Log";
        VoucherSendingLog: Record "NPR NpRv Sending Log";
    begin
        ArchVoucherSendingLog.SetRange("Arch. Voucher No.", ArchVoucherNo);
        if ArchVoucherSendingLog.FindSet(true) then
            repeat
                VoucherSendingLog.Init();
                VoucherSendingLog.TransferFields(ArchVoucherSendingLog);
                VoucherSendingLog."Entry No." := ArchVoucherSendingLog."Original Entry No.";
                VoucherSendingLog."Voucher No." := RestoredVoucherNo;
                if ArchVoucherSendingLog."Error Message".HasValue then begin
                    ArchVoucherSendingLog.CalcFields("Error Message");
                    VoucherSendingLog."Error Message" := ArchVoucherSendingLog."Error Message";
                end;
                VoucherSendingLog.Insert();
            until ArchVoucherSendingLog.Next() = 0;
        ArchVoucherSendingLog.DeleteAll();
    end;

    internal procedure FindVoucher(VoucherTypeCode: Code[20]; ReferenceNo: Text[50]; var Voucher: Record "NPR NpRv Voucher"): Boolean
    begin
        OnBeforeFindVoucher(ReferenceNo);
        if VoucherTypeCode <> '' then
            Voucher.SetFilter("Voucher Type", VoucherTypeCode);
        Voucher.SetRange("Reference No.", ReferenceNo);
        exit(Voucher.FindFirst());
    end;

    internal procedure FindArchivedVoucher(VoucherTypeCode: Text; ReferenceNo: Text; var ArchVoucher: Record "NPR NpRv Arch. Voucher"): Boolean
    begin
        if VoucherTypeCode <> '' then
            ArchVoucher.SetFilter("Voucher Type", VoucherTypeCode);
        ArchVoucher.SetRange("Reference No.", ReferenceNo);
        exit(ArchVoucher.FindFirst());
    end;

    internal procedure FindPartnerVoucher(VoucherTypeCode: Code[20]; ReferenceNo: Text[50]; var Voucher: Record "NPR NpRv Voucher") Handled: Boolean
    var
        NpRvModuleMgt: Codeunit "NPR NpRv Module Mgt.";
    begin
        if VoucherTypeCode = '' then
            exit(false);
        NpRvModuleMgt.OnRunFindVoucher(VoucherTypeCode, ReferenceNo, Voucher, Handled);
    end;

    internal procedure ValidateVoucher(var TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary)
    var
        NpRvModuleMgt: Codeunit "NPR NpRv Module Mgt.";
        NpRvModuleValidateDefault: Codeunit "NPR NpRv Module Valid.: Def.";
        Handled: Boolean;
    begin
        NpRvModuleMgt.OnRunValidateVoucher(TempNpRvVoucherBuffer, Handled);
        if Handled then
            exit;

        NpRvModuleValidateDefault.ValidateVoucher(TempNpRvVoucherBuffer);
    end;

    procedure RedeemVoucher(VoucherEntry: Record "NPR NpRv Voucher Entry"; Voucher: Record "NPR NpRv Voucher")
    var
        NpRvModuleMgt: Codeunit "NPR NpRv Module Mgt.";
        Handled: Boolean;
    begin
        NpRvModuleMgt.OnRunRedeemVoucher(VoucherEntry, Voucher, Handled);
    end;

    procedure RedeemPartnerVouchers(VoucherEntry: Record "NPR NpRv Voucher Entry"; Voucher: Record "NPR NpRv Voucher")
    var
        NpRvModuleValidGlobal: Codeunit "NPR NpRv Module Valid.: Global";
    begin
        NpRvModuleValidGlobal.RedeemPartnerVouchers(VoucherEntry, Voucher);
    end;

    procedure CreateGlobalVoucher(Voucher: Record "NPR NpRv Voucher")
    var
        NpRvModuleMgt: Codeunit "NPR NpRv Module Mgt.";
        Handled: Boolean;
    begin
        NpRvModuleMgt.OnRunCreateGlobalVoucher(Voucher, Handled);
    end;

    internal procedure TopUpVoucher(VoucherEntry: Record "NPR NpRv Voucher Entry"; Voucher: Record "NPR NpRv Voucher")
    var
        NpRvModuleMgt: Codeunit "NPR NpRv Module Mgt.";
        Handled: Boolean;
    begin
        NpRvModuleMgt.OnRunTopUpVoucher(VoucherEntry, Voucher, Handled);
    end;

    internal procedure UpdateVoucherAmount(Voucher: Record "NPR NpRv Voucher")
    var
        NpRvModuleMgt: Codeunit "NPR NpRv Module Mgt.";
        Handled: Boolean;
    begin
        NpRvModuleMgt.OnRunUpdateVoucherAmount(Voucher, Handled);
    end;

    [TryFunction]
    internal procedure TryValidateGlobalVoucherSetup(NpRvGlobalVoucherSetup: Record "NPR NpRv Global Vouch. Setup")
    var
        NpRvModuleMgt: Codeunit "NPR NpRv Module Mgt.";
        Handled: Boolean;
    begin
        NpRvModuleMgt.OnRunTryValidateGlobalVoucherSetup(NpRvGlobalVoucherSetup, Handled);
    end;

    internal procedure Voucher2Buffer(var NpRvVoucher: Record "NPR NpRv Voucher"; var TempNpRvGlobalVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary)
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        NPRPOSUnit: Record "NPR POS Unit";
    begin
        if NpRvVoucherType.Get(NpRvVoucher."Voucher Type") then;

        NpRvVoucher.CalcFields(Amount, "Issue Date", "Issue Register No.", "Issue Document No.", "Issue User ID", "Issue Partner Code");
        TempNpRvGlobalVoucherBuffer."Voucher Type" := NpRvVoucher."Voucher Type";
        TempNpRvGlobalVoucherBuffer."No." := NpRvVoucher."No.";
        TempNpRvGlobalVoucherBuffer."Validate Voucher Module" := NpRvVoucherType."Validate Voucher Module";
        TempNpRvGlobalVoucherBuffer.Description := NpRvVoucher.Description;
        TempNpRvGlobalVoucherBuffer."Starting Date" := NpRvVoucher."Starting Date";
        TempNpRvGlobalVoucherBuffer."Ending Date" := NpRvVoucher."Ending Date";
        TempNpRvGlobalVoucherBuffer."Account No." := NpRvVoucher."Account No.";
        TempNpRvGlobalVoucherBuffer.Amount := NpRvVoucher.Amount;
        TempNpRvGlobalVoucherBuffer.Name := NpRvVoucher.Name;
        TempNpRvGlobalVoucherBuffer."Name 2" := NpRvVoucher."Name 2";
        TempNpRvGlobalVoucherBuffer.Address := NpRvVoucher.Address;
        TempNpRvGlobalVoucherBuffer."Address 2" := NpRvVoucher."Address 2";
        TempNpRvGlobalVoucherBuffer."Post Code" := NpRvVoucher."Post Code";
        TempNpRvGlobalVoucherBuffer.City := NpRvVoucher.City;
        TempNpRvGlobalVoucherBuffer.County := NpRvVoucher.County;
        TempNpRvGlobalVoucherBuffer."Country/Region Code" := NpRvVoucher."Country/Region Code";
        TempNpRvGlobalVoucherBuffer."E-mail" := NpRvVoucher."E-mail";
        TempNpRvGlobalVoucherBuffer."Phone No." := NpRvVoucher."Phone No.";
        TempNpRvGlobalVoucherBuffer."Voucher Message" := NpRvVoucher."Voucher Message";
        TempNpRvGlobalVoucherBuffer."Issue Date" := NpRvVoucher."Issue Date";
        TempNpRvGlobalVoucherBuffer."Issue Register No." := NpRvVoucher."Issue Register No.";
        TempNpRvGlobalVoucherBuffer."Issue Sales Ticket No." := NpRvVoucher."Issue Document No.";
        TempNpRvGlobalVoucherBuffer."Issue User ID" := NpRvVoucher."Issue User ID";
        TempNpRvGlobalVoucherBuffer."Issue Partner Code" := NpRvVoucher."Issue Partner Code";
        if NPRPOSUnit.Get(NpRvVoucher."Issue Register No.") then
            TempNpRvGlobalVoucherBuffer."POS Store Code" := NPRPOSUnit."POS Store Code";
        TempNpRvGlobalVoucherBuffer.Company := CopyStr(CompanyName(), 1, MaxStrlen(TempNpRvGlobalVoucherBuffer.Company));
    end;

    local procedure SetSalesLineFilter(SaleLinePOS: Record "NPR POS Sale Line"; var NpRvSalesLine: Record "NPR NpRv Sales Line")
    begin
        Clear(NpRvSalesLine);
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21)
        NpRvSalesLine.ReadIsolation := IsolationLevel::ReadCommitted;
#ENDIF
        NpRvSalesLine.SetCurrentKey("Retail ID", "Document Source", Type);
        NpRvSalesLine.SetRange("Retail ID", SaleLinePOS.SystemId);
        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::POS);
    end;

    internal procedure SetSalesLineReferenceFilter(NpRvSalesLine: Record "NPR NpRv Sales Line"; var NpRvSalesLineReference: Record "NPR NpRv Sales Line Ref.")
    begin
        NpRvSalesLineReference.SetRange("Sales Line Id", NpRvSalesLine.Id);
    end;

    procedure GenerateTempVoucher(VoucherType: Record "NPR NpRv Voucher Type"; var TempVoucher: Record "NPR NpRv Voucher" temporary)
    begin
        GenerateTempVoucher(VoucherType, TempVoucher, '');
    end;

    internal procedure GenerateTempVoucher(VoucherType: Record "NPR NpRv Voucher Type"; var TempVoucher: Record "NPR NpRv Voucher" temporary; CustomRefereceNo: Text[50])
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
        ReferenceNo: Text;
        ReferenceErr: Label 'Generated reference no. %1 is too long. Max length is %2.';
    begin
        CheckVoucherTypeQty(VoucherType.Code);

        TempVoucher.Init();
        TempVoucher."No." := '';
        TempVoucher.Validate("Voucher Type", VoucherType.Code);
        if VoucherType."No. Series" <> '' then
            NoSeriesMgt.InitSeries(TempVoucher."No. Series", '', 0D, TempVoucher."No.", TempVoucher."No. Series");

        if CustomRefereceNo <> '' then
            ReferenceNo := CustomRefereceNo
        else
            ReferenceNo := GenerateReferenceNo(TempVoucher);

        if StrLen(ReferenceNo) > MaxStrLen(TempVoucher."Reference No.") then
            Error(ReferenceErr, ReferenceNo, MaxStrLen(TempVoucher."Reference No."))
        else
            TempVoucher."Reference No." := CopyStr(ReferenceNo, 1, MaxStrLen(TempVoucher."Reference No."));
        TempVoucher.Description := CopyStr(TempVoucher."Reference No." + ' ' + VoucherType.Description, 1, MaxStrLen(TempVoucher.Description));
        OnAfterGenerateTempVoucher(VoucherType, TempVoucher);
    end;

    internal procedure GenerateReferenceNo(Voucher: Record "NPR NpRv Voucher") ReferenceNo: Text
    var
        VoucherType: Record "NPR NpRv Voucher Type";
    begin
        VoucherType.Get(Voucher."Voucher Type");

        case VoucherType."Reference No. Type" of
            VoucherType."Reference No. Type"::Pattern:
                begin
                    ReferenceNo := GenerateReferenceNoPattern(Voucher);
                    exit(ReferenceNo);
                end;
            VoucherType."Reference No. Type"::EAN13:
                begin
                    ReferenceNo := GenerateReferenceNoEAN13(Voucher);
                    exit(ReferenceNo);
                end;
        end;

        exit('');
    end;

    local procedure GenerateReferenceNoPattern(Voucher: Record "NPR NpRv Voucher") ReferenceNo: Text
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        i: Integer;
    begin
        VoucherType.Get(Voucher."Voucher Type");
        if VoucherType."Reference No. Type" <> VoucherType."Reference No. Type"::Pattern then
            exit('');

        for i := 1 to 100 do begin
            ReferenceNo := GenerateReferenceNo(VoucherType."Reference No. Pattern", Voucher."No.", MaxStrLen(Voucher."Reference No."));
            if CheckReferenceNoHasNotBeenUsedBefore(Voucher."No.", ReferenceNo) then
                exit(ReferenceNo);
        end;
        Error(DuplicateRefNoErr, Voucher."No.", VoucherType.Code, VoucherType."Reference No. Pattern");
    end;

    local procedure GenerateReferenceNoEAN13(Voucher: Record "NPR NpRv Voucher") ReferenceNo: Text
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        i: Integer;
        CheckSum: Integer;
        InvalidReferenceNoLength: Label 'Invalid EAN13: %1. Reference No. length cannot exceed more than 12 characters.', Comment = '%1=ReferenceNo';
    begin
        VoucherType.Get(Voucher."Voucher Type");
        if VoucherType."Reference No. Type" <> VoucherType."Reference No. Type"::EAN13 then
            exit('');

        for i := 1 to 100 do begin
            ReferenceNo := GenerateReferenceNo(VoucherType."Reference No. Pattern", Voucher."No.", MaxStrLen(Voucher."Reference No."));
            if StrLen(ReferenceNo) < 12 then
                ReferenceNo := CopyStr(ReferenceNo, 1, 2) + PadStr('', 12 - StrLen(ReferenceNo), '0') + CopyStr(ReferenceNo, 3);
            if StrLen(ReferenceNo) > 12 then
                Error(InvalidReferenceNoLength, ReferenceNo);
            if not TryGetCheckSum(ReferenceNo, CheckSum) then
                Error(InvalidRefNoErr, ReferenceNo);
            ReferenceNo := ReferenceNo + Format(CheckSum);

            if CheckReferenceNoHasNotBeenUsedBefore(Voucher."No.", ReferenceNo) then
                exit(ReferenceNo);
        end;
        Error(DuplicateRefNoErr, Voucher."No.", VoucherType.Code, VoucherType."Reference No. Pattern");
    end;

    local procedure GenerateReferenceNo(ReferenceNoPattern: Code[20]; VoucherNo: Code[20]; MaxLenght: Integer) ReferenceNo: Text
    begin
        ReferenceNo := ReferenceNoPattern;
        ReferenceNo := NpRegex.RegExReplaceN(ReferenceNo);
        ReferenceNo := NpRegex.RegExReplaceAN(ReferenceNo);
        ReferenceNo := NpRegex.RegExReplaceS(ReferenceNo, VoucherNo);
        ReferenceNo := UpperCase(CopyStr(ReferenceNo, 1, MaxLenght));
    end;

    internal procedure CheckReferenceNoHasNotBeenUsedBefore(ExcludeVoucherNo: Code[20]; ReferenceNoToCheck: Text): Boolean
    var
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        Voucher: Record "NPR NpRv Voucher";
    begin
        Voucher.SetFilter("No.", '<>%1', ExcludeVoucherNo);
        Voucher.SetRange("Reference No.", ReferenceNoToCheck);
        if not Voucher.IsEmpty() then
            exit(false);

        ArchVoucher.SetRange("Reference No.", ReferenceNoToCheck);
        exit(ArchVoucher.IsEmpty());
    end;

    internal procedure CheckReferenceNoAlreadyUsed(VocuherNo: Code[20]; RefereceNo: Text) ReferenceNoAlreadyUsed: Boolean
    begin
        ReferenceNoAlreadyUsed := not CheckReferenceNoHasNotBeenUsedBefore(VocuherNo, RefereceNo);
        if ReferenceNoAlreadyUsed then
            exit;
        ReferenceNoAlreadyUsed := CheckReferenceNoUsedInSale(RefereceNo);
    end;

    local procedure CheckReferenceNoUsedInSale(ReferenceNoFilterText: Text) ReferenceNoUsed: Boolean;
    var
        NpRvSalesLineRef: Record "NPR NpRv Sales Line Ref.";
    begin
        if ReferenceNoFilterText = '' then
            exit;

        NpRvSalesLineRef.Reset();
        NpRvSalesLineRef.SetCurrentKey("Reference No.");
        NpRvSalesLineRef.SetFilter("Reference No.", ReferenceNoFilterText);
        ReferenceNoUsed := not NpRvSalesLineRef.IsEmpty;
    end;

    [TryFunction]
    local procedure TryGetCheckSum(ReferenceNo: Text; var CheckSum: Integer)
    begin
        CheckSum := StrCheckSum(ReferenceNo, '131313131313');
    end;

    internal procedure ArchiveRetailVoucher(var RetailVoucher: Record "NPR NpRv Voucher"; VoucherAmount: Decimal)
    var
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
    begin
        VoucherEntry.Init();
        VoucherEntry."Entry No." := 0;
        VoucherEntry."Voucher No." := RetailVoucher."No.";
        VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::"Manual Archive";
        VoucherEntry."Voucher Type" := RetailVoucher."Voucher Type";
        VoucherEntry.Amount := -VoucherAmount;
        VoucherEntry."Remaining Amount" := VoucherEntry.Amount;
        VoucherEntry.Positive := VoucherEntry.Amount > 0;
        VoucherEntry."Posting Date" := Today();
        VoucherEntry.Open := true;
        VoucherEntry."Register No." := '';
        VoucherEntry."Document No." := '';
        VoucherEntry."User ID" := CopyStr(UserId(), 1, MaxStrLen(VoucherEntry."User ID"));
        VoucherEntry."Closed by Entry No." := 0;

        InsertArchivedVoucher(RetailVoucher, ArchVoucher);
        InsertArchivedVoucherEntry(ArchVoucher, VoucherEntry);
        OnAfterArchiveVoucher(RetailVoucher, ArchVoucher);
    end;

    internal procedure OpenRetailVoucher(Voucher: Record "NPR NpRv Voucher"; VoucherAmount: Decimal)
    var
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        VoucherType: Record "NPR NpRv Voucher Type";
        VoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        if VoucherMgt.InitialEntryExists(Voucher) then
            exit;

        VoucherType.Get(Voucher."Voucher Type");

        VoucherEntry.Init();
        VoucherEntry."Entry No." := 0;
        VoucherEntry."Voucher No." := Voucher."No.";
        VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::"Issue Voucher";
        VoucherEntry."Voucher Type" := Voucher."Voucher Type";
        VoucherEntry.Amount := VoucherAmount;
        VoucherEntry."Remaining Amount" := VoucherEntry.Amount;

        VoucherEntry.Positive := VoucherEntry.Amount > 0;
        VoucherEntry."Posting Date" := WorkDate();
        VoucherEntry.Open := VoucherEntry.Amount <> 0;
        VoucherEntry."Partner Code" := VoucherType."Partner Code";
        VoucherEntry."Closed by Entry No." := 0;
        VoucherEntry.Insert();

        CreateGlobalVoucher(Voucher);
    end;

    internal procedure PrepareVoucherBuffer(var TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary; var SalePOS: Record "NPR POS Sale"; VoucherType: Record "NPR NpRv Voucher Type"; ReferenceNo: Text)
    var
        TooLongReferenceErr: Label 'Reference No. %1 is too long. Max length is %2 characters.';
    begin
        TempNpRvVoucherBuffer.Init();
        TempNpRvVoucherBuffer."Voucher Type" := VoucherType.Code;
        TempNpRvVoucherBuffer."Validate Voucher Module" := VoucherType."Validate Voucher Module";
        if StrLen(ReferenceNo) > MaxStrLen(TempNpRvVoucherBuffer."Reference No.") then
            Error(TooLongReferenceErr, ReferenceNo, MaxStrLen(TempNpRvVoucherBuffer."Reference No.")) else
            TempNpRvVoucherBuffer."Reference No." := CopyStr(ReferenceNo, 1, MaxStrLen(TempNpRvVoucherBuffer."Reference No."));
        TempNpRvVoucherBuffer."Redeem Date" := SalePOS.Date;
        TempNpRvVoucherBuffer."Redeem Partner Code" := VoucherType."Partner Code";
        TempNpRvVoucherBuffer."Redeem Register No." := SalePOS."Register No.";
        TempNpRvVoucherBuffer."Redeem Sales Ticket No." := SalePOS."Sales Ticket No.";
        TempNpRvVoucherBuffer."Redeem User ID" := SalePOS."Salesperson Code";
    end;

    internal procedure InsertNpRvSalesLine(var TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary; var SalePOS: Record "NPR POS Sale"; var NpRvSalesLine: Record "NPR NpRv Sales Line"; var VoucherType: Record "NPR NpRv Voucher Type"; var POSLine: Record "NPR POS Sale Line")
    begin
        NpRvSalesLine.Init();
        NpRvSalesLine.Id := CreateGuid();
        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::POS;
        NpRvSalesLine."Retail ID" := POSLine.SystemID;
        NpRvSalesLine."Register No." := SalePOS."Register No.";
        NpRvSalesLine."Sales Ticket No." := SalePOS."Sales Ticket No.";
        NpRvSalesLine."Sale Date" := POSLine.Date;
        NpRvSalesLine."Sale Line No." := POSLine."Line No.";

        NpRvSalesLine.Type := NpRvSalesLine.Type::Payment;
        NpRvSalesLine."Voucher No." := TempNpRvVoucherBuffer."No.";
        NpRvSalesLine."Reference No." := TempNpRvVoucherBuffer."Reference No.";
        NpRvSalesLine."Voucher Type" := VoucherType.Code;
        NpRvSalesLine.Description := VoucherType.Description;
        NpRvSalesLine.Insert(true);
    end;

    [Obsolete('Delete when final v1/v2 workflow is gone', '2023-06-28')]
    internal procedure ApplyVoucherPayment(var VoucherTypeCode: Code[20]; VoucherNumber: Text; var PaymentLine: Record "NPR POS Sale Line"; var SalePOS: Record "NPR POS Sale"; var POSSession: Codeunit "NPR POS Session"; var FrontEnd: Codeunit "NPR POS Front End Management"; var POSPaymentLine: Codeunit "NPR POS Payment Line"; var POSLine: Record "NPR POS Sale Line"; EndSale: Boolean)
    var
        TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary;
        VoucherType: Record "NPR NpRv Voucher Type";
        Voucher: Record "NPR NpRv Voucher";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
    begin
        if VoucherTypeCode = '' then
            VoucherTypeCode := GetVoucherTypeFromReferenceNumber(VoucherNumber);


        VoucherType.Get(VoucherTypeCode);
        CheckVoucherType(VoucherType, SalePOS);

        PrepareVoucherBuffer(TempNpRvVoucherBuffer, SalePOS, VoucherType, VoucherNumber);
        ValidateVoucher(TempNpRvVoucherBuffer);

        POSLine."No." := VoucherType."Payment Type";
        POSLine."Voucher Category" := VoucherType."Voucher Category";
        POSLine."Register No." := SalePOS."Register No.";
        POSLine.Description := TempNpRvVoucherBuffer.Description;
        POSLine."Sales Ticket No." := SalePOS."Sales Ticket No.";
        POSLine."Amount Including VAT" := TempNpRvVoucherBuffer.Amount;
        POSPaymentLine.InsertPaymentLine(POSLine, 0);
        POSPaymentLine.GetCurrentPaymentLine(POSLine);
        PaymentLine."Discount Code" := TempNpRvVoucherBuffer."No.";
        if FindVoucher(TempNpRvVoucherBuffer."Voucher Type", TempNpRvVoucherBuffer."Reference No.", Voucher) then begin
            UpdateTaxSetup(POSLine, SalePOS, Voucher."Account No.");
            POSPaymentLine.ReverseUnrealizedSalesVAT(POSLine);
            POSLine.Modify();
        end;

        CheckCustomer(VoucherType, Voucher, SalePOS);

        InsertNpRvSalesLine(TempNpRvVoucherBuffer, SalePOS, NpRvSalesLine, VoucherType, POSLine);

        ApplyPayment(FrontEnd, POSSession, NpRvSalesLine, EndSale);
    end;

    internal procedure ApplyForeignVoucherPayment(VoucherTypeCode: Code[20]; VoucherNumber: Text; var PaymentLine: Record "NPR POS Sale Line"; var SalePOS: Record "NPR POS Sale"; var POSSession: Codeunit "NPR POS Session"; var FrontEnd: Codeunit "NPR POS Front End Management"; var POSPaymentLine: Codeunit "NPR POS Payment Line"; var POSLine: Record "NPR POS Sale Line"; AmountToCapture: Decimal)
    var
        TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary;
        VoucherType: Record "NPR NpRv Voucher Type";
        Voucher: Record "NPR NpRv Voucher";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        PaymentNpRvSalesLine: Record "NPR NpRv Sales Line";
    begin
        VoucherType.Get(VoucherTypeCode);
        InsertForeignVoucher(Voucher, VoucherType, VoucherNumber);
        PrepareVoucherBuffer(TempNpRvVoucherBuffer, SalePOS, VoucherType, VoucherNumber);
        TempNpRvVoucherBuffer."No." := Voucher."No.";
        TempNpRvVoucherBuffer.Amount := AmountToCapture;
        POSLine."No." := VoucherType."Payment Type";
        POSLine."Voucher Category" := VoucherType."Voucher Category";
        POSLine."Register No." := SalePOS."Register No.";
        POSLine.Description := Voucher.Description;
        POSLine."Sales Ticket No." := SalePOS."Sales Ticket No.";
        POSLine."Amount Including VAT" := TempNpRvVoucherBuffer.Amount;
        POSPaymentLine.InsertPaymentLine(POSLine, 0);
        POSPaymentLine.GetCurrentPaymentLine(POSLine);
        PaymentLine."Discount Code" := TempNpRvVoucherBuffer."No.";
        if FindVoucher(TempNpRvVoucherBuffer."Voucher Type", TempNpRvVoucherBuffer."Reference No.", Voucher) then begin
            UpdateTaxSetup(POSLine, SalePOS, Voucher."Account No.");
            POSPaymentLine.ReverseUnrealizedSalesVAT(POSLine);
            POSLine.Modify();

        end;

        InsertNpRvSalesLine(TempNpRvVoucherBuffer, SalePOS, NpRvSalesLine, VoucherType, POSLine);
        PaymentNpRvSalesLine := NpRvSalesLine;
        PostIssueForeignVoucher(Voucher, VoucherType, AmountToCapture, NpRvSalesLine);

        ApplyPayment(FrontEnd, POSSession, PaymentNpRvSalesLine, false);
    end;

    local procedure UpdateTaxSetup(var Line: Record "NPR POS Sale Line"; SalePOS: Record "NPR POS Sale"; AccountNo: Code[20])
    var
        VATPostingSetup: Record "VAT Posting Setup";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
    begin
        InitFromGLAccount(Line, AccountNo);
        VATPostingSetup.Get(Line."VAT Bus. Posting Group", Line."VAT Prod. Posting Group");
        POSSaleTaxCalc.UpdateSourceTaxSetup(Line, VATPostingSetup, SalePOS, 0);
    end;

    local procedure InitFromGLAccount(var Line: Record "NPR POS Sale Line"; AccountNo: Code[20])
    var
        GLAccount: Record "G/L Account";
    begin
        if AccountNo = '' then
            exit;
        GLAccount.Get(AccountNo);
        GLAccount.CheckGLAcc();
        Line."Gen. Posting Type" := GLAccount."Gen. Posting Type";
        Line."Gen. Bus. Posting Group" := GLAccount."Gen. Bus. Posting Group";
        Line."Gen. Prod. Posting Group" := GLAccount."Gen. Prod. Posting Group";
        Line."VAT Bus. Posting Group" := GLAccount."VAT Bus. Posting Group";
        Line."VAT Prod. Posting Group" := GLAccount."VAT Prod. Posting Group";
        Line."Tax Group Code" := GLAccount."Tax Group Code";
    end;

    local procedure InsertForeignVoucher(var Voucher: Record "NPR NpRv Voucher"; VoucherType: Record "NPR NpRv Voucher Type"; VoucherNumber: Text)
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
        TooLongErr: Label 'Voucher %1 is too long. Max length is %2';
    begin
        Voucher.Init();
        Voucher."No." := '';
        Voucher.Validate("Voucher Type", VoucherType.Code);
        if VoucherType."No. Series" <> '' then
            NoSeriesMgt.InitSeries(Voucher."No. Series", '', 0D, Voucher."No.", Voucher."No. Series");
        if StrLen(VoucherNumber) > MaxStrLen(Voucher."Reference No.") then
            Error(TooLongErr, VoucherNumber, MaxStrLen(Voucher."Reference No."));
        Voucher."Reference No." := CopyStr(VoucherNumber, 1, MaxStrLen(Voucher."Reference No."));
        Voucher.Description := CopyStr(Voucher."Reference No." + ' ' + VoucherType.Description, 1, MaxStrLen(Voucher.Description));

        Voucher.Insert();
    end;

    local procedure DeleteExternalVoucher(POSSaleLine: Record "NPR POS Sale Line"; var NpRvSalesLine: Record "NPR NpRv Sales Line")
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        POSPaymentMethod: Record "NPR POS Payment Method";
        Voucher: Record "NPR NpRv Voucher";
        NpRvVoucherEntry: Record "NPR NpRv Voucher Entry";
        POSQuoteEntry: Record "NPR POS Saved Sale Entry";
    begin
        POSQuoteEntry.SetRange("Register No.", POSSaleLine."Register No.");
        POSQuoteEntry.SetRange("Sales Ticket No.", POSSaleLine."Sales Ticket No.");
        if not POSQuoteEntry.IsEmpty() then
            exit;
        NpRvSalesLine.FindFirst();
        if NpRvVoucherType.Get(NpRvSalesLine."Voucher Type") then
            if POSPaymentMethod.Get(NpRvVoucherType."Payment Type") then
                if POSPaymentMethod."Processing Type" = POSPaymentMethod."Processing Type"::"FOREIGN VOUCHER" then begin
                    if Voucher.Get(NpRvSalesLine."Voucher No.") then begin
                        Voucher.Delete();
                        NpRvVoucherEntry.SetRange("Voucher No.", Voucher."No.");
                        if not NpRvVoucherEntry.IsEmpty() then
                            NpRvVoucherEntry.DeleteAll();
                    end;
                end;
    end;

    local procedure CheckVoucherType(VoucherType: Record "NPR NpRv Voucher Type"; var SalePOS: Record "NPR POS Sale")
    var
        POSStoreGroupLine: Record "NPR POS Store Group Line";
        NotAllowedErr: Label '%1 %2 is not allowed to be used in store %3', Comment = '%1 = Voucher Type Caption, %2 = Voucher Type Code, %3 = Store Code';
    begin
        if VoucherType."POS Store Group" = '' then
            exit;
        if not POSStoreGroupLine.Get(VoucherType."POS Store Group", SalePOS."POS Store Code") then
            Error(NotAllowedErr, VoucherType.TableCaption(), VoucherType.Code, SalePOS."POS Store Code");
    end;

    local procedure CheckCustomer(VoucherType: Record "NPR NpRv Voucher Type"; Voucher: Record "NPR NpRv Voucher"; var SalePOS: Record "NPR POS Sale")
    var
        WrongCustomerTok: Label 'Voucher %1 is issued for customer %2 and cannot be used by customer %3.';
    begin
        if not VoucherType."Validate Customer No." then
            exit;
        if Voucher."Customer No." = '' then
            exit;
        if SalePOS."Customer No." <> Voucher."Customer No." then
            Error(WrongCustomerTok, Voucher."Reference No.", Voucher."Customer No.", SalePOS."Customer No.");
    end;

    internal procedure GetVoucherTypeFromReferenceNumber(VoucherNumber: Text) VoucherType: Code[20]
    var
        Voucher: Record "NPR NpRv Voucher";
    begin
        Voucher.Reset();
        Voucher.SetCurrentKey("Reference No.");
        Voucher.SetRange(Open, true);
        Voucher.SetRange("Reference No.", VoucherNumber);
        if Voucher.Find('-') and (Voucher.Next() = 0) then begin
            VoucherType := Voucher."Voucher Type";
            exit;
        end;

        if Page.RunModal(0, Voucher) <> Action::LookupOK then
            exit;

        VoucherType := Voucher."Voucher Type";
    end;

    internal procedure GetVoucher(VoucherNumber: Text[50]; VoucherType: Text[20]; SelectFromList: Boolean; var Voucher: Record "NPR NpRv Voucher") Found: Boolean
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        TryFindPartnerVoucher: Codeunit "NPR Try Find Partner Voucher";
    begin
        OnBeforeGetVoucher(VoucherNumber);
        NpRvVoucherType.Reset();
        NpRvVoucherType.SetFilter(Code, VoucherType);
        NpRvVoucherType.SetLoadFields("Code");
        if NpRvVoucherType.FindSet() then
            repeat
                Clear(TryFindPartnerVoucher);
                TryFindPartnerVoucher.SetReferenceNo(VoucherNumber);
                TryFindPartnerVoucher.SetVoucherType(NpRvVoucherType.Code);
                if TryFindPartnerVoucher.Run() then;
            until NpRvVoucherType.Next() = 0;

        Voucher.Reset();
        Voucher.SetCurrentKey("Reference No.");
        Voucher.SetRange(Open, true);
        Voucher.SetFilter("Voucher Type", VoucherType);
        Voucher.SetRange("Reference No.", VoucherNumber);

        if SelectFromList and (VoucherNumber = '') then begin
            Voucher.SetRange("Reference No.");
            Found := Page.RunModal(0, Voucher) = Action::LookupOK;
            exit;
        end;

        Found := Voucher.Find('-') and (Voucher.Next() = 0);
        if Found then
            exit;

        if VoucherNumber = '' then
            exit;

        Found := Page.RunModal(0, Voucher) = Action::LookupOK;
    end;

    procedure CheckVoucherTypeQty(VoucherTypeCode: Code[20])
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        MaxCountErr: Label '%1 for %2 %3 is exceeded.';
    begin
        VoucherType.Get(VoucherTypeCode);
        if VoucherType."Max Voucher Count" = 0 then
            exit;
        VoucherType.CalcFields("Voucher Qty. (Open)", "Voucher Qty. (Closed)", "Arch. Voucher Qty.");
        if (VoucherType."Voucher Qty. (Closed)" + VoucherType."Voucher Qty. (Open)" + VoucherType."Arch. Voucher Qty.") >= VoucherType."Max Voucher Count" then
            Error(MaxCountErr, VoucherType.FieldCaption("Max Voucher Count"), VoucherType.TableCaption, VoucherType.Code);
    end;

    internal procedure IssueReturnVoucher(var POSSession: Codeunit "NPR POS Session"; VoucherTypeCode: Text; Amount: Decimal; Email: Text[80]; PhoneNo: Text[30]; SendMethodPrint: Boolean; SendMethodEmail: Boolean; SendMethodSMS: Boolean; VoucherSalesLineParentID: Guid)
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        PaymentLinePOS: Record "NPR POS Sale Line";
        NpRvSalesLineReference: Record "NPR NpRv Sales Line Ref.";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        POSPaymentMethod: Record "NPR POS Payment Method";
        TempVoucher: Record "NPR NpRv Voucher" temporary;
        CurrentPOSPaymentMethod: Record "NPR POS Payment Method";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SaleAmount: Decimal;
        SubTotal: Decimal;
        MaximumReturnAmountErr: Label 'Maximum Return Amount is: %1', Comment = '%1=ReturnAmount';
    begin
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.GetCurrentPaymentLine(PaymentLinePOS);
        CurrentPOSPaymentMethod.Get(PaymentLinePOS."No.");
        POSPaymentLine.CalculateBalance(CurrentPOSPaymentMethod, SaleAmount, PaidAmount, ReturnAmount, SubTotal);

        VoucherType.Get(VoucherTypeCode);

        ReturnAmount := PaidAmount - SaleAmount;
        POSPaymentMethod.Get(VoucherType."Payment Type");
        if POSPaymentMethod."Rounding Precision" > 0 then
            ReturnAmount := Round(ReturnAmount, POSPaymentMethod."Rounding Precision");

        if Amount > ReturnAmount then
            Error(MaximumReturnAmountErr, ReturnAmount);

        GenerateTempVoucher(VoucherType, TempVoucher);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS.Validate("Line Type", SaleLinePOS."Line Type"::"POS Payment");
        SaleLinePOS.Validate("No.", VoucherType."Payment Type");
        SaleLinePOS."Voucher Category" := VoucherType."Voucher Category";
        SaleLinePOS.Description := VoucherType.Description;
        SaleLinePOS.Quantity := 0;
        SaleLinePOS."Unit Price" := 0;
        SaleLinePOS."Amount Including VAT" := -Amount;
        POSPaymentLine.InsertPaymentLine(SaleLinePOS, 0);
        POSPaymentLine.GetCurrentPaymentLine(SaleLinePOS);
        SaleLinePOS.Quantity := 1;
        SaleLinePOS.Description := TempVoucher.Description;
        UpdateTaxSetup(SaleLinePOS, SalePOS, TempVoucher."Account No.");
        POSPaymentLine.ReverseUnrealizedSalesVAT(SaleLinePOS);
        SaleLinePOS.Modify();

        NpRvSalesLine.Init();
        NpRvSalesLine."Send via Print" := SendMethodPrint;
        NpRvSalesLine."Send via E-mail" := SendMethodEmail;
        NpRvSalesLine."Send via SMS" := SendMethodSMS;
        if Email <> '' then
            NpRvSalesLine."E-mail" := Email;
        if PhoneNo <> '' then
            NpRvSalesLine."Phone No." := PhoneNo;
        NpRvSalesLine.Id := CreateGuid();
        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::POS;
        NpRvSalesLine."Retail ID" := SaleLinePOS.SystemId;
        NpRvSalesLine."Register No." := SaleLinePOS."Register No.";
        NpRvSalesLine."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
        NpRvSalesLine."Sale Date" := SaleLinePOS.Date;
        NpRvSalesLine."Sale Line No." := SaleLinePOS."Line No.";
        NpRvSalesLine.Type := NpRvSalesLine.Type::"New Voucher";
        NpRvSalesLine."Voucher Type" := VoucherType.Code;
        NpRvSalesLine."Starting Date" := CurrentDateTime;
        NpRvSalesLine."Parent Id" := VoucherSalesLineParentID;
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        NpRvSalesLine.Validate("Customer No.", SalePOS."Customer No.");

        NpRvSalesLine."Voucher No." := TempVoucher."No.";
        NpRvSalesLine."Reference No." := TempVoucher."Reference No.";
        NpRvSalesLine.Description := TempVoucher.Description;
        NpRvSalesLine.Insert();

        SetSalesLineReferenceFilter(NpRvSalesLine, NpRvSalesLineReference);
        if NpRvSalesLineReference.IsEmpty then begin
            NpRvSalesLineReference.Init();
            NpRvSalesLineReference.Id := CreateGuid();
            NpRvSalesLineReference."Voucher No." := TempVoucher."No.";
            NpRvSalesLineReference."Reference No." := TempVoucher."Reference No.";
            NpRvSalesLineReference."Sales Line Id" := NpRvSalesLine.Id;
            NpRvSalesLineReference.Insert();

            SaleLinePOS.Description := TempVoucher.Description;
            SaleLinePOS.Modify();
        end;
    end;

    internal procedure IssueReturnVoucher(var POSSession: Codeunit "NPR POS Session"; VoucherTypeCode: Text; Amount: Decimal; Email: Text[80]; PhoneNo: Text[30]; SendMethodPrint: Boolean; SendMethodEmail: Boolean; SendMethodSMS: Boolean)
    var
        DummyGuid: Guid;
    begin
        IssueReturnVoucher(POSSession, VoucherTypeCode, Amount, Email, PhoneNo, SendMethodPrint, SendMethodEmail, SendMethodSMS, DummyGuid);
    end;

    internal procedure TopUpVoucher(var POSSession: Codeunit "NPR POS Session"; VoucherNo: Text; DiscountType: Text; AmtInput: Decimal; DiscountAmount: Decimal; DiscountPct: Decimal)
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        NpRvVoucher.Get(VoucherNo);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS.Validate("Line Type", SaleLinePOS."Line Type"::"Issue Voucher");
        SaleLinePOS.Validate("No.", NpRvVoucher."Account No.");
        SaleLinePOS.Description := NpRvVoucher.Description;
        SaleLinePOS.Quantity := 1;
        POSSaleLine.InsertLine(SaleLinePOS);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        SaleLinePOS."Unit Price" := AmtInput;
        case DiscountType of
            '0':
                SaleLinePOS."Discount Amount" := DiscountAmount;
            '1':
                SaleLinePOS."Discount %" := DiscountPct;
        end;
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        if SaleLinePOS."Discount Amount" > 0 then
            SaleLinePOS."Discount Type" := SaleLinePOS."Discount Type"::Manual;
        SaleLinePOS.Modify(true);

        NpRvSalesLine.Init();
        NpRvSalesLine.Id := CreateGuid();
        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::POS;
        NpRvSalesLine."Retail ID" := SaleLinePOS.SystemId;
        NpRvSalesLine."Register No." := SaleLinePOS."Register No.";
        NpRvSalesLine."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
        NpRvSalesLine."Sale Date" := SaleLinePOS.Date;
        NpRvSalesLine."Sale Line No." := SaleLinePOS."Line No.";
        NpRvSalesLine.Type := NpRvSalesLine.Type::"Top-up";
        NpRvSalesLine."Voucher No." := NpRvVoucher."No.";
        NpRvSalesLine."Voucher Type" := NpRvVoucher."Voucher Type";
        NpRvSalesLine.Description := NpRvVoucher.Description;
        NpRvSalesLine."Starting Date" := CurrentDateTime;
        NpRvSalesLine."Send via Print" := NpRvVoucher."Send via Print";
        NpRvSalesLine."Send via E-mail" := NpRvVoucher."Send via E-mail";
        NpRvSalesLine."Send via SMS" := NpRvVoucher."Send via SMS";
        if NpRvVoucher."Send via E-mail" then
            NpRvSalesLine."E-mail" := NpRvVoucher."E-mail";
        if NpRvVoucher."Send via SMS" then
            NpRvSalesLine."Phone No." := NpRvVoucher."Phone No.";
        NpRvSalesLine.Insert(true);
    end;

    internal procedure InitNpRvExtVoucherWS()
    var
        WebService: Record "Web Service Aggregate";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        if not WebService.ReadPermission then
            exit;

        if not WebService.WritePermission then
            exit;

        WebServiceManagement.CreateTenantWebService(WebService."Object Type"::Codeunit, Codeunit::"NPR NpRv Ext. Voucher WS", 'external_voucher_services', true);
    end;

    internal procedure PrepareForCashApplication(VoucherTypeCode: Code[20]; VoucherNumber: Text; var PaymentLine: Record "NPR POS Sale Line"; var SalePOS: Record "NPR POS Sale"; var POSPaymentLine: Codeunit "NPR POS Payment Line"; var POSLine: Record "NPR POS Sale Line")
    var
        TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary;
        VoucherType: Record "NPR NpRv Voucher Type";
        Voucher: Record "NPR NpRv Voucher";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
    begin
        VoucherType.Get(VoucherTypeCode);
        PrepareVoucherBuffer(TempNpRvVoucherBuffer, SalePOS, VoucherType, VoucherNumber);
        ValidateVoucher(TempNpRvVoucherBuffer);

        POSLine."No." := VoucherType."Payment Type";
        POSLine."Voucher Category" := VoucherType."Voucher Category";
        POSLine."Register No." := SalePOS."Register No.";
        POSLine.Description := TempNpRvVoucherBuffer.Description;
        POSLine."Sales Ticket No." := SalePOS."Sales Ticket No.";
        POSLine."Amount Including VAT" := TempNpRvVoucherBuffer.Amount;
        POSPaymentLine.InsertPaymentLine(POSLine, 0);
        POSPaymentLine.GetCurrentPaymentLine(POSLine);
        PaymentLine."Discount Code" := TempNpRvVoucherBuffer."No.";
        if FindVoucher(TempNpRvVoucherBuffer."Voucher Type", TempNpRvVoucherBuffer."Reference No.", Voucher) then begin
            UpdateTaxSetup(POSLine, SalePOS, Voucher."Account No.");
            POSPaymentLine.ReverseUnrealizedSalesVAT(POSLine);
            POSLine.Modify();
        end;

        InsertNpRvSalesLine(TempNpRvVoucherBuffer, SalePOS, NpRvSalesLine, VoucherType, POSLine);
    end;


    procedure TrimTypeAndReference(VoucherType: Text; var VoucherTypeCode: Code[20]; ReferenceNo: Text; var VoucherReferenceNumber: Text[50])
    var
        TooLongErr: Label '%1 cannot have more than %2 characters.';
    begin
        if StrLen(ReferenceNo) > MaxStrLen(VoucherReferenceNumber) then
            Error(TooLongErr, 'ReferenceNo', MaxStrLen(VoucherReferenceNumber));
        VoucherReferenceNumber := CopyStr(ReferenceNo, 1, MaxStrLen(VoucherReferenceNumber));
        if StrLen(VoucherType) > MaxStrLen(VoucherTypeCode) then
            Error(TooLongErr, 'VoucherTypeCode', VoucherTypeCode);
        VoucherTypeCode := CopyStr(VoucherType, 1, MaxStrLen(VoucherTypeCode));
    end;

    local procedure GenerateVoucherWithReference(VoucherType: Record "NPR NpRv Voucher Type"; var Voucher: Record "NPR NpRv Voucher"; ReferenceNo: Text[50])
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
        DuplicateReferenceNoErr: Label 'System could not generate a unique reference number for voucher %1 (voucher type %2).', Comment = '%1 - voucher number, %2 - voucher type';
    begin
        Voucher.Init();
        Voucher."No." := '';
        Voucher.Validate("Voucher Type", VoucherType.Code);
        if VoucherType."No. Series" <> '' then
            NoSeriesMgt.InitSeries(Voucher."No. Series", '', 0D, Voucher."No.", Voucher."No. Series");

        if not CheckReferenceNoHasNotBeenUsedBefore(Voucher."No.", ReferenceNo) then
            Error(DuplicateReferenceNoErr, Voucher."No.", VoucherType.Code);

        Voucher."Reference No." := ReferenceNo;
        Voucher.Description := CopyStr(Voucher."Reference No." + ' ' + VoucherType.Description, 1, MaxStrLen(Voucher.Description));
        Voucher.Insert();
    end;

    procedure IssueVoucher(VoucherTypeCode: Code[20]; ReferenceNo: Text[50]; VoucherAmount: Decimal)
    var
        Voucher: Record "NPR NpRv Voucher";
        VoucherType: Record "NPR NpRv Voucher Type";
    begin
        VoucherType.Get(VoucherTypeCode);
        CheckVoucherTypeQty(VoucherType.Code);

        GenerateVoucherWithReference(VoucherType, Voucher, ReferenceNo);

        PostIssueVoucherEntry(Voucher, VoucherAmount, VoucherType);
    end;

    procedure IssueVouchers(VoucherTypeCode: Code[20]; VoucherQty: Integer; VoucherAmount: Decimal)
    var
        Voucher: Record "NPR NpRv Voucher";
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        i: Integer;
    begin

        NpRvVoucherType.Get(VoucherTypeCode);
        for i := 1 to VoucherQty do begin
            Clear(Voucher);
            GenerateTempVoucher(NpRvVoucherType, Voucher);
            Voucher.Insert();
            PostIssueVoucherEntry(Voucher, VoucherAmount, NpRvVoucherType);
        end;
    end;

    local procedure PostIssueVoucherEntry(Voucher: Record "NPR NpRv Voucher"; VoucherAmount: Decimal; VoucherType: Record "NPR NpRv Voucher Type")
    var
        VoucherEntry: Record "NPR NpRv Voucher Entry";
    begin
        VoucherEntry.Init();
        VoucherEntry."Entry No." := 0;
        VoucherEntry."Voucher No." := Voucher."No.";
        VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::"Issue Voucher";
        VoucherEntry."Voucher Type" := Voucher."Voucher Type";
        VoucherEntry.Amount := VoucherAmount;
        VoucherEntry."Remaining Amount" := VoucherEntry.Amount;
        VoucherEntry.Positive := VoucherEntry.Amount > 0;
        VoucherEntry."Posting Date" := DT2Date(Voucher."Starting Date");
        VoucherEntry.Open := VoucherEntry.Amount <> 0;
        VoucherEntry."Document Type" := VoucherEntry."Document Type"::Invoice;
        VoucherEntry."Partner Code" := VoucherType."Partner Code";
        VoucherEntry."User ID" := CopyStr(UserId, 1, MaxStrLen(VoucherEntry."User ID"));
        VoucherEntry."Closed by Entry No." := 0;
        VoucherEntry.Insert();

        ApplyEntry(VoucherEntry);
    end;


    #region V3
    internal procedure ApplyPayment(POSSession: Codeunit "NPR POS Session"; NpRvSalesLine: Record "NPR NpRv Sales Line"; EndSale: Boolean; var ActionContext: JsonObject)
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        NpRvModuleMgt: Codeunit "NPR NpRv Module Mgt.";
        NpRvModulePaymentDefault: Codeunit "NPR NpRv Module Pay.: Default";
        Handled: Boolean;
    begin
        VoucherType.Get(NpRvSalesLine."Voucher Type");
        NpRvModuleMgt.OnRunApplyPaymentV3(POSSession, VoucherType, NpRvSalesLine, EndSale, Handled, ActionContext);
        if Handled then
            exit;

        NpRvModulePaymentDefault.ApplyPayment(POSSession, VoucherType, NpRvSalesLine, EndSale, ActionContext);
    end;

    internal procedure ApplyVoucherPayment(VoucherTypeCode: Code[20]; VoucherNumber: Text; SuggestedAmount: Decimal; var PaymentLine: Record "NPR POS Sale Line"; var SalePOS: Record "NPR POS Sale"; var POSSession: Codeunit "NPR POS Session"; var POSPaymentLine: Codeunit "NPR POS Payment Line"; var POSLine: Record "NPR POS Sale Line"; EndSale: Boolean; var ActionContext: JsonObject)
    var
        TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary;
        VoucherType: Record "NPR NpRv Voucher Type";
        Voucher: Record "NPR NpRv Voucher";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvModuleMgt: Codeunit "NPR NpRv Module Mgt.";
    begin
        VoucherType.Get(VoucherTypeCode);
        CheckVoucherType(VoucherType, SalePOS);

        PrepareVoucherBuffer(TempNpRvVoucherBuffer, SalePOS, VoucherType, VoucherNumber);
        ValidateVoucher(TempNpRvVoucherBuffer);

        NpRvModuleMgt.OnPreApplyPaymentV3(TempNpRvVoucherBuffer, SalePOS, VoucherType, VoucherNumber, SuggestedAmount);

        POSLine."No." := VoucherType."Payment Type";
        POSLine."Voucher Category" := VoucherType."Voucher Category";
        POSLine."Register No." := SalePOS."Register No.";
        POSLine.Description := TempNpRvVoucherBuffer.Description;
        POSLine."Sales Ticket No." := SalePOS."Sales Ticket No.";
        POSLine."Amount Including VAT" := TempNpRvVoucherBuffer.Amount;
        POSPaymentLine.InsertPaymentLine(POSLine, 0);
        POSPaymentLine.GetCurrentPaymentLine(POSLine);
        PaymentLine."Discount Code" := TempNpRvVoucherBuffer."No.";
        if FindVoucher(TempNpRvVoucherBuffer."Voucher Type", TempNpRvVoucherBuffer."Reference No.", Voucher) then begin
            UpdateTaxSetup(POSLine, SalePOS, Voucher."Account No.");
            POSPaymentLine.ReverseUnrealizedSalesVAT(POSLine);
            POSLine.Modify();
        end;

        InsertNpRvSalesLine(TempNpRvVoucherBuffer, SalePOS, NpRvSalesLine, VoucherType, POSLine);

        ActionContext.Add('paymentNo', VoucherType."Payment Type");
        ApplyPayment(POSSession, NpRvSalesLine, EndSale, ActionContext);
    end;

    internal procedure ApplyVoucherPayment(VoucherTypeCode: Code[20]; VoucherNumber: Text; var PaymentLine: Record "NPR POS Sale Line"; var SalePOS: Record "NPR POS Sale"; var POSSession: Codeunit "NPR POS Session"; var POSPaymentLine: Codeunit "NPR POS Payment Line"; var POSLine: Record "NPR POS Sale Line"; EndSale: Boolean; var ActionContext: JsonObject)
    begin
        ApplyVoucherPayment(VoucherTypeCode,
                            VoucherNumber,
                            0,
                            PaymentLine,
                            SalePOS,
                            POSSession,
                            POSPaymentLine,
                            POSLine,
                            EndSale,
                            ActionContext)
    end;

    procedure ExtendVoucherEndingDate(PostingDate: Date; NpRvVoucher: Record "NPR NpRv Voucher")
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
    begin
        NpRvVoucherType.Get(NpRvVoucher."Voucher Type");
        if not NpRvVoucherType."Top-up Extends Ending Date" then
            exit;
        NpRvVoucher."Ending Date" := CreateDateTime(CalcDate(NpRvVoucherType."Valid Period", DT2Date(CurrentDateTime())), DT2Time(CurrentDateTime()));
        NpRvVoucher.Modify();
    end;

    internal procedure GetVoucherPaymentMethod(ReferenceNo: Text[50]) PaymentMethodCode: Code[10]
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
    begin
        NpRvVoucher.SetLoadFields("Voucher Type");
        NpRvVoucher.SetRange("Reference No.", ReferenceNo);
        if not NpRvVoucher.FindFirst() then
            exit;
        NpRvVoucherType.SetLoadFields("Payment Type");
        if not NpRvVoucherType.Get(NpRvVoucher."Voucher Type") then
            exit;
        PaymentMethodCode := NpRvVoucherType."Payment Type";
    end;

    internal procedure CheckVoucherCanBeUsedWithItem(PaymentMethodCode: Code[10]; ItemNo: Code[20]; ItemCategoryCode: Code[20]): Boolean
    var
        POSPaymentMethodItem: Record "NPR POS Payment Method Item";
    begin
        POSPaymentMethodItem.SetRange("POS Payment Method Code", PaymentMethodCode);
        if POSPaymentMethodItem.IsEmpty() then
            exit(true);
        POSPaymentMethodItem.SetRange("No.", ItemNo);
        POSPaymentMethodItem.SetRange(Type, POSPaymentMethodItem.Type::Item);
        if not POSPaymentMethodItem.IsEmpty() then
            exit(true);
        POSPaymentMethodItem.SetRange("No.", ItemCategoryCode);
        POSPaymentMethodItem.SetRange(Type, POSPaymentMethodItem.Type::"Item Categories");
        if not POSPaymentMethodItem.IsEmpty() then
            exit(true);
    end;
    #endregion


    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertIssuedVoucher(var Voucher: Record "NPR NpRv Voucher"; SaleLinePOSVoucher: Record "NPR NpRv Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertIssuedVoucherEntry(var VoucherEntry: Record "NPR NpRv Voucher Entry"; Voucher: Record "NPR NpRv Voucher"; NpRvSalesLine: Record "NPR NpRv Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertIssuedForeignVoucherEntry(var VoucherEntry: Record "NPR NpRv Voucher Entry"; Voucher: Record "NPR NpRv Voucher"; NpRvSalesLine: Record "NPR NpRv Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPaymentVoucherEntry(var VoucherEntry: Record "NPR NpRv Voucher Entry"; SaleLinePOSVoucher: Record "NPR NpRv Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertArchiveEntry(var ArchVoucherEntry: Record "NPR NpRv Arch. Voucher Entry"; NpRvVoucherEntry: Record "NPR NpRv Voucher Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertArchivedVoucher(Voucher: Record "NPR NpRv Voucher"; var ArchVoucher: Record "NPR NpRv Arch. Voucher")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterArchiveVoucher(Voucher: Record "NPR NpRv Voucher"; ArchVoucher: Record "NPR NpRv Arch. Voucher")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUnArchiveVoucher(ArchVoucher: Record "NPR NpRv Arch. Voucher"; Voucher: Record "NPR NpRv Voucher")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGenerateTempVoucher(VoucherType: Record "NPR NpRv Voucher Type"; var TempVoucher: Record "NPR NpRv Voucher")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFindVoucher(var ReferenceNo: Text[50])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetVoucher(var VoucherNumber: Text[50])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifyIssuedVoucher(var Voucher: Record "NPR NpRv Voucher"; SaleLinePOSVoucher: Record "NPR NpRv Sales Line"; VoucherType: Record "NPR NpRv Voucher Type")
    begin
    end;

}