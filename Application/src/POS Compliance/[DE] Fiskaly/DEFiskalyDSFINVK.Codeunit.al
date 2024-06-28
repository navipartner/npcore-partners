codeunit 6014442 "NPR DE Fiskaly DSFINVK"
{
    Access = Internal;
    [TryFunction]
    procedure CreateDSFINVKDocument(var DSFINVKJson: JsonObject; DSFINVKClosing: Record "NPR DSFINVK Closing")
    var
        DePosUnit: Record "NPR DE POS Unit Aux. Info";
        FirstFiscalNo: Text;
        LastFiscalNo: Text;
    begin
        DePosUnit.Get(DSFINVKClosing."POS Unit No.");
        FillTransactionData(DSFINVKClosing."Closing Date", FirstFiscalNo, LastFiscalNo);

        DSFINVKJson.Add('head', GetHeader(FirstFiscalNo, LastFiscalNo));
        DSFINVKJson.Add('client_id', Format(DePosUnit.SystemId, 0, 4));
        DSFINVKJson.Add('cash_point_closing_export_id', DSFINVKClosing."DSFINVK Closing No.");
        DSFINVKJson.Add('cash_statement', CreateCashStatement());
        DSFINVKJson.Add('transactions', CreateTransactions(DSFINVKClosing."Closing Date"));
    end;

    local procedure GetHeader(FirstFiscalNo: Text; LastFiscalNo: Text) HeadJson: JsonObject
    begin
        HeadJson.Add('first_transaction_export_id', FirstFiscalNo);
        HeadJson.Add('last_transaction_export_id', LastFiscalNo);
        HeadJson.Add('export_creation_date', GetUnixTime(CurrentDateTime));
    end;

    local procedure FillTransactionData(WorkShiftDate: Date; var FirstFiscalNo: Text; var LastFiscalNo: Text)
    var
        POSEntry: Record "NPR POS Entry";
        DeAuditLog: Record "NPR DE POS Audit Log Aux. Info";
        DeAuditError: Label 'There is DE Audit Aux Log with error, No.: %1', Comment = '%1 - DE POS Unit No.';
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        POSEntry.ReadIsolation := IsolationLevel::ReadCommitted;
#endif
        POSEntry.SetRange("Entry Date", WorkShiftDate);
        POSEntry.FindSet();
        repeat
            if DeAuditLog.Get(POSEntry."Entry No.") then begin
                if DeAuditLog."Has Error" then
                    Error(DeAuditError, DeAuditLog."POS Entry No.");

                if FirstFiscalNo = '' then
                    FirstFiscalNo := POSEntry."Fiscal No.";
                LastFiscalNo := POSEntry."Fiscal No.";

                FillTmpPayment(POSEntry, DeAuditLog);
                FillTmpVat(POSEntry, DeAuditLog);
            end;
        until POSEntry.Next() = 0;
    end;

    local procedure FillTmpPayment(POSEntry: Record "NPR POS Entry"; DeAuditLog: Record "NPR DE POS Audit Log Aux. Info")
    var
        PaymentLine: Record "NPR POS Entry Payment Line";
    begin
        PaymentLine.Reset();
        PaymentLine.SetCurrentKey("POS Payment Method Code", "Currency Code");
        PaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        if PaymentLine.FindSet() then
            repeat
                InsertTempPaymentLine(DeAuditLog, PaymentLine);
            until PaymentLine.Next() = 0;
    end;

    local procedure FillTmpVat(POSEntry: Record "NPR POS Entry"; DeAuditLog: Record "NPR DE POS Audit Log Aux. Info")
    var
        TaxAmountLine: Record "NPR POS Entry Tax Line";
    begin
        TaxAmountLine.Reset();
        TaxAmountLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        if TaxAmountLine.FindSet() then
            repeat
                InsertTempTaxAmountLine(DeAuditLog, TaxAmountLine);
            until TaxAmountLine.Next() = 0;
    end;

    local procedure CreateCashStatement() CashStatement: JsonObject
    begin
        CashStatement.Add('business_cases', CreateBusinessCases());
        CashStatement.Add('payment', CreatePayment());
    end;

    local procedure CreateTransactions(WorkShiftDate: Date) Transactions: JsonArray
    var
        POSEntry: Record "NPR POS Entry";
        DeAuditLog: Record "NPR DE POS Audit Log Aux. Info";
        Security: JsonObject;
        Transaction: JsonObject;
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        POSEntry.ReadIsolation := IsolationLevel::ReadCommitted;
#endif
        POSEntry.SetRange("Entry Date", WorkShiftDate);
        POSEntry.FindSet();
        repeat
            if DeAuditLog.Get(POSEntry."Entry No.") then begin
                Clear(Security);
                Clear(Transaction);
                Security.Add('tss_tx_id', Format(DeAuditLog."Transaction ID", 0, 4));
                Transaction.Add('head', CreateTransactionHeader(POSEntry, DeAuditLog));
                Transaction.Add('data', CreateTransactionData(POSEntry, DeAuditLog));
                Transaction.Add('security', Security);
                Transactions.Add(Transaction);
            end;
        until POSEntry.Next() = 0;
    end;

    local procedure CreateBusinessCases() BusinessCases: JsonArray
    var
        BusinessCase: JsonObject;
    begin
        BusinessCase.Add('type', 'Umsatz'); //We are sendig data only for sales, that is why here is only one Business case
        BusinessCase.Add('amounts_per_vat_id', CreateAmountsPerVatId(''));
        BusinessCases.Add(BusinessCase);
    end;

    local procedure CreateAmountsPerVatId(TransactionId: Text) AmountsPerVatId: JsonArray
    var
        ExclVat: Decimal;
        InclVat: Decimal;
        Vat: Decimal;
        OldVatId: Integer;
    begin
        OldVatId := -1;
        InclVat := 0;
        ExclVat := 0;
        Vat := 0;
        TempTaxAmountLine.Reset();
        //"Print Order" is used for DSFINVK Vat ID
        if TransactionId <> '' then
            TempTaxAmountLine.SetRange(SystemCreatedBy, TransactionId);
        if not TempTaxAmountLine.FindSet() then
            exit;
        repeat
            if OldVatId < 0 then
                OldVatId := TempTaxAmountLine."Print Order";
            if OldVatId <> TempTaxAmountLine."Print Order" then begin
                AmountsPerVatId.Add(CreateAmountsPerVatIdJson(OldVatId, InclVat, ExclVat, Vat));
                InclVat := TempTaxAmountLine."Amount Including Tax";
                ExclVat := TempTaxAmountLine."Tax Base Amount";
                Vat := TempTaxAmountLine."Tax Amount";
                OldVatId := TempTaxAmountLine."Print Order";
            end
            else begin
                InclVat += TempTaxAmountLine."Amount Including Tax";
                ExclVat += TempTaxAmountLine."Tax Base Amount";
                Vat += TempTaxAmountLine."Tax Amount";
            end;
        until TempTaxAmountLine.Next() = 0;

        if ((InclVat + ExclVat + Vat) > 0) then
            AmountsPerVatId.Add(CreateAmountsPerVatIdJson(OldVatId, InclVat, ExclVat, Vat));
    end;

    local procedure CreateAmountsPerVatIdJson(VatId: Integer; InclVat: Decimal; ExclVat: Decimal; Vat: Decimal) AmountPerVatId: JsonObject
    begin
        AmountPerVatId.Add('incl_vat', Format(InclVat, 0, '<Precision,2:26><Standard Format,4>'));
        AmountPerVatId.Add('excl_vat', Format(ExclVat, 0, '<Precision,2:26><Standard Format,4>'));
        AmountPerVatId.Add('vat', Format(Vat, 0, '<Precision,2:26><Standard Format,4>'));
        AmountPerVatId.Add('vat_definition_export_id', VatId);
    end;

    local procedure CreatePayment() Payment: JsonObject
    var
        POSPayment: Record "NPR POS Payment Method";
        CashAmount: Decimal;
        FullAmount: Decimal;
        PaymentAmout: Decimal;
        DSFINVKPaymentType: Enum "NPR DSFINVK Payment Type";
        OldType: Integer;
        CashAmountsCurrency: JsonArray;
        PaymentTypes: JsonArray;
        OldCurrency: Code[10];
    begin
        FullAmount := 0;
        CashAmount := 0;
        PaymentAmout := 0;
        OldType := -1;
        OldCurrency := '';
        TempPaymentLine.Reset();
        TempPaymentLine.SetCurrentKey("Currency Code");
        if not TempPaymentLine.FindSet() then
            exit;
        repeat
            POSPayment.Get(TempPaymentLine."POS Payment Method Code");
            FullAmount += TempPaymentLine."Amount (LCY)";
            if POSPayment."Processing Type" = POSPayment."Processing Type"::CASH then
                CashAmount += TempPaymentLine."Amount (LCY)";

            if OldCurrency = '' then
                OldCurrency := TempPaymentLine."Currency Code";

            if OldCurrency <> TempPaymentLine."Currency Code" then begin
                CashAmountsCurrency.Add(CreatePaymentType(OldCurrency, PaymentAmout, ''));
                PaymentAmout := TempPaymentLine."Amount (LCY)";
                OldCurrency := TempPaymentLine."Currency Code";
            end else
                PaymentAmout += TempPaymentLine."Amount (LCY)";
        until TempPaymentLine.Next() = 0;

        if PaymentAmout > 0 then begin
            CashAmountsCurrency.Add(CreatePaymentType(OldCurrency, PaymentAmout, ''));
            PaymentAmout := 0;
        end;
        OldCurrency := '';

        Payment.Add('full_amount', FullAmount);
        Payment.Add('cash_amount', CashAmount);
        Payment.Add('cash_amounts_by_currency', CashAmountsCurrency);

        TempPaymentLine.Reset();
        TempPaymentLine.SetCurrentKey("POS Period Register No.", "Currency Code");
        TempPaymentLine.FindSet();
        repeat
            POSPayment.Get(TempPaymentLine."POS Payment Method Code");
            if OldCurrency = '' then
                OldCurrency := TempPaymentLine."Currency Code";
            if OldType < 0 then
                OldType := TempPaymentLine."POS Period Register No.";

            if (OldCurrency <> TempPaymentLine."Currency Code") or (OldType <> TempPaymentLine."POS Period Register No.") then begin
                PaymentTypes.Add(CreatePaymentType(OldCurrency, PaymentAmout, DSFINVKPaymentType.Names.Get((TempPaymentLine."POS Period Register No." + 1))));
                PaymentAmout := TempPaymentLine."Amount (LCY)";
                OldCurrency := TempPaymentLine."Currency Code";
                OldType := TempPaymentLine."POS Period Register No.";
            end
            else
                PaymentAmout += TempPaymentLine."Amount (LCY)";
        until TempPaymentLine.Next() = 0;

        if PaymentAmout > 0 then
            PaymentTypes.Add(CreatePaymentType(OldCurrency, PaymentAmout, DSFINVKPaymentType.Names.Get((TempPaymentLine."POS Period Register No." + 1))));

        Payment.Add('payment_types', PaymentTypes);
    end;

    local procedure CreatePaymentType(OldCurrency: Code[10]; PaymentAmout: Decimal; Type: Text) CurrencyPayment: JsonObject
    begin
        if Type <> '' then
            CurrencyPayment.Add('type', Type);
        CurrencyPayment.Add('currency_code', OldCurrency);
        CurrencyPayment.Add('amount', Format(PaymentAmout, 0, '<Precision,2:26><Standard Format,4>'));
    end;

    local procedure CreateTransactionHeader(POSEntry: Record "NPR POS Entry"; DeAuditLog: Record "NPR DE POS Audit Log Aux. Info") TransactionHeader: JsonObject
    var
        Customer: Record Customer;
        TransactionHeadBuyer: JsonObject;
        TransactionHeadUser: JsonObject;
    begin
        TransactionHeadUser.Add('user_export_id', UserId);

        if Customer.Get(POSEntry."Customer No.") then begin
            TransactionHeadBuyer.Add('name', Customer.Name);
            TransactionHeadBuyer.Add('buyer_export_id', Customer."No.");
        end
        else begin
            TransactionHeadBuyer.Add('name', 'POSCustomer');
            TransactionHeadBuyer.Add('buyer_export_id', '1');
        end;

        TransactionHeadBuyer.Add('type', 'Kunde');

        TransactionHeader.Add('type', 'AVRechnung'); //We only use simple sale for now
        if POSEntry."Amount Incl. Tax" > 0 then
            TransactionHeader.Add('storno', false)
        else
            TransactionHeader.Add('storno', true);
        TransactionHeader.Add('number', POSEntry."Entry No.");
        TransactionHeader.Add('timestamp_start', GetUnixTime(DeAuditLog."Start Time"));
        TransactionHeader.Add('timestamp_end', GetUnixTime(DeAuditLog."Finish Time"));
        TransactionHeader.Add('user', TransactionHeadUser);
        TransactionHeader.Add('buyer', TransactionHeadBuyer);
        TransactionHeader.Add('tx_id', Format(DeAuditLog."Transaction ID", 0, 4));
        TransactionHeader.Add('transaction_export_id', POSEntry."Fiscal No.");
        TransactionHeader.Add('closing_client_id', Format(DeAuditLog."Client ID", 0, 4));
    end;

    local procedure CreateTransactionData(POSEntry: Record "NPR POS Entry"; DeAuditLog: Record "NPR DE POS Audit Log Aux. Info") TransactionData: JsonObject
    var
        FullAmount: Decimal;
    begin
        TransactionData.Add('payment_types', GetTransactionPaymentTypes(FullAmount, DeAuditLog));
        TransactionData.Add('full_amount_incl_vat', FullAmount);
        TransactionData.Add('amounts_per_vat_id', CreateAmountsPerVatId(DeAuditLog."Transaction ID"));
        TransactionData.Add('lines', CreateTransactionLines(POSEntry));
    end;

    local procedure GetTransactionPaymentTypes(var FullAmount: Decimal; DeAuditLog: Record "NPR DE POS Audit Log Aux. Info") TransactionPaymentTypes: JsonArray
    var
        POSPayment: Record "NPR POS Payment Method";
        PaymentAmout: Decimal;
        DSFINVKPaymentType: Enum "NPR DSFINVK Payment Type";
        OldType: Integer;
        OldCurrency: Code[10];
    begin
        FullAmount := 0;
        OldType := -1;
        TempPaymentLine.Reset();
        TempPaymentLine.SetCurrentKey("POS Period Register No.", "Currency Code");
        TempPaymentLine.SetRange(SystemCreatedBy, DeAuditLog."Transaction ID");
        if not TempPaymentLine.FindSet() then
            exit;
        repeat
            POSPayment.Get(TempPaymentLine."POS Payment Method Code");
            if OldCurrency = '' then
                OldCurrency := TempPaymentLine."Currency Code";
            if OldType < 0 then
                OldType := TempPaymentLine."POS Period Register No.";

            if (OldCurrency <> TempPaymentLine."Currency Code") or (OldType <> TempPaymentLine."POS Period Register No.") then begin
                TransactionPaymentTypes.Add(CreatePaymentType(OldCurrency, PaymentAmout, DSFINVKPaymentType.Names.Get((TempPaymentLine."POS Period Register No." + 1))));
                PaymentAmout := TempPaymentLine."Amount (LCY)";
                OldCurrency := TempPaymentLine."Currency Code";
                OldType := TempPaymentLine."POS Period Register No.";
            end
            else
                PaymentAmout += TempPaymentLine."Amount (LCY)";
            FullAmount += TempPaymentLine."Amount (LCY)";
        until TempPaymentLine.Next() = 0;

        if PaymentAmout > 0 then
            TransactionPaymentTypes.Add(CreatePaymentType(OldCurrency, PaymentAmout, DSFINVKPaymentType.Names.Get((TempPaymentLine."POS Period Register No." + 1))));
    end;

    local procedure CreateTransactionLines(POSEntry: Record "NPR POS Entry") TransactionLines: JsonArray
    var
        POSLines: Record "NPR POS Entry Sales Line";
        VatMapper: Record "NPR VAT Post. Group Mapper";
        AmountsPerVatIdList: JsonArray;
        TransactionLine: JsonObject;
        TransactionLineBusinessCase: JsonObject;
        TransactionLineItem: JsonObject;
    begin
        POSLines.Reset();
        POSLines.SetLoadFields("VAT Prod. Posting Group", "VAT Bus. Posting Group", "Amount Incl. VAT (LCY)", "Amount Excl. VAT (LCY)", "No.", Quantity, "Unit Price", "Line No.", Description);
        POSLines.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSLines.SetFilter(Type, '<>%1', POSLines.Type::Comment);
        if not POSLines.FindSet() then
            exit;
        repeat
            VatMapper.Get(POSLines."VAT Prod. Posting Group", POSLines."VAT Bus. Posting Group");
            Clear(TransactionLineBusinessCase);
            Clear(TransactionLineItem);
            Clear(TransactionLine);
            AmountsPerVatIdList.Add(CreateAmountsPerVatIdJson(VatMapper."DSFINVK ID", POSLines."Amount Incl. VAT (LCY)", POSLines."Amount Excl. VAT (LCY)", (POSLines."Amount Incl. VAT (LCY)" - POSLines."Amount Excl. VAT (LCY)")));
            TransactionLineBusinessCase.Add('type', 'Umsatz');
            TransactionLineBusinessCase.Add('amounts_per_vat_id', AmountsPerVatIdList);
            TransactionLineItem.Add('number', POSLines."No.");
            TransactionLineItem.Add('quantity', Format(POSLines.Quantity, 0, '<Precision,2:26><Standard Format,3>'));
            TransactionLineItem.Add('price_per_unit', Format(POSLines."Unit Price", 0, '<Precision,2:26><Standard Format,4>'));

            TransactionLine.Add('lineitem_export_id', Format(POSLines."Line No."));

            if POSLines."Amount Incl. VAT (LCY)" > 0 then
                TransactionLine.Add('storno', false)
            else
                TransactionLine.Add('storno', true);
            TransactionLine.Add('text', POSLines.Description);
            TransactionLine.Add('business_case', TransactionLineBusinessCase);
            TransactionLine.Add('item', TransactionLineItem);
            TransactionLines.Add(TransactionLine);
        until POSLines.Next() = 0;
    end;

    local procedure InsertTempPaymentLine(DeAuditLog: Record "NPR DE POS Audit Log Aux. Info"; var PaymentLine: Record "NPR POS Entry Payment Line")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        PaymentMapper: Record "NPR Payment Method Mapper";
    begin
        GeneralLedgerSetup.Get();
        PaymentMapper.Get(PaymentLine."POS Payment Method Code");
        TempPaymentLine.Reset();
        TempPaymentLine.SetRange("POS Period Register No.", PaymentMapper."DSFINVK Type".AsInteger()); //"POS Period Register No." is used for DSFINVK Type
        TempPaymentLine.SetRange(SystemCreatedBy, DeAuditLog."Transaction ID"); //SystemCreatedBy is used for Fiskaly Transaction ID
        TempPaymentLine.SetRange("Currency Code", PaymentLine."Currency Code");
        if TempPaymentLine.FindFirst() then begin
            TempPaymentLine."Amount (LCY)" += PaymentLine."Amount (LCY)";
            TempPaymentLine.Modify();
        end
        else begin
            TempPaymentLine.Init();
            TempPaymentLine := PaymentLine;
            if TempPaymentLine."Currency Code" = '' then
                TempPaymentLine."Currency Code" := GeneralLedgerSetup."LCY Code";
            TempPaymentLine."POS Period Register No." := PaymentMapper."DSFINVK Type".AsInteger(); //"POS Period Register No." is used for DSFINVK Type
            TempPaymentLine.SystemCreatedBy := DeAuditLog."Transaction ID"; //SystemCreatedBy is used for Fiskaly Transaction ID
            TempPaymentLine.Insert();
        end;
    end;

    local procedure InsertTempTaxAmountLine(DeAuditLog: Record "NPR DE POS Audit Log Aux. Info"; var TaxAmountLine: Record "NPR POS Entry Tax Line")
    var
        TaxMapper: Record "NPR VAT Post. Group Mapper";
    begin
        TaxMapper.Reset();
        TaxMapper.SetRange("VAT Identifier", TaxAmountLine."VAT Identifier");
        TaxMapper.FindFirst();

        TempTaxAmountLine.Reset();
        TempTaxAmountLine.SetRange("Print Order", TaxMapper."DSFINVK ID"); //"Print Order" is used for DSFINVK Vat ID
        TempTaxAmountLine.SetRange(SystemCreatedBy, DeAuditLog."Transaction ID"); //SystemCreatedBy is used for Fiskaly Transaction ID
        if TempTaxAmountLine.FindFirst() then begin
            TempTaxAmountLine."Amount Including Tax" += TaxAmountLine."Amount Including Tax";
            TempTaxAmountLine."Tax Base Amount" += TaxAmountLine."Tax Base Amount";
            TempTaxAmountLine."Tax Amount" += TaxAmountLine."Tax Amount";
            TempTaxAmountLine.Modify();
        end
        else begin
            TempTaxAmountLine.Init();
            TempTaxAmountLine := TaxAmountLine;
            TempTaxAmountLine."Print Order" := TaxMapper."DSFINVK ID"; //"Print Order" is used for DSFINVK Vat ID
            TempTaxAmountLine.SystemCreatedBy := DeAuditLog."Transaction ID"; //SystemCreatedBy is used for Fiskaly Transaction ID
            TempTaxAmountLine.Insert();
        end;
    end;

    procedure GetUnixTime(ToDateTime: DateTime): Integer
    var
        DurationMs: BigInteger;
        FromDateTime: DateTime;
        Duration: Duration;
    begin
        Evaluate(FromDateTime, '1970-01-01T00:00:00Z', 9);
        Duration := ToDateTime - FromDateTime;
        DurationMs := Duration;
        exit((DurationMs / 1000) div 1);
    end;

    var
        TempPaymentLine: Record "NPR POS Entry Payment Line" temporary;
        TempTaxAmountLine: Record "NPR POS Entry Tax Line" temporary;
}
