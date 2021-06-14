codeunit 6014442 "NPR DE Fiskaly DSFINVK"
{
    [TryFunction]
    procedure CreateDSFINVKDocument(var DSFINVKJson: JsonObject; DSFINVKClosing: Record "NPR DSFINVK Closing")
    begin
        FirstFiscalNo := '';
        LastFiscalNo := '';

        WorkShiftDate := DSFINVKClosing."Closing Date";

        DePosUnit.Get(DSFINVKClosing."POS Unit No.");
        FillTransactionData();

        DSFINVKJson.Add('head', GetHeader());
        DSFINVKJson.Add('client_id', Format(DePosUnit."Client ID", 0, 4));
        DSFINVKJson.Add('cash_point_closing_export_id', DSFINVKClosing."DSFINVK Closing No.");
        DSFINVKJson.Add('cash_statement', CreateCashStatement());
        DSFINVKJson.Add('transactions', CreateTransactions());
    end;

    local procedure GetHeader() HeadJson: JsonObject
    begin
        HeadJson.Add('first_transaction_export_id', FirstFiscalNo);
        HeadJson.Add('last_transaction_export_id', LastFiscalNo);
        HeadJson.Add('export_creation_date', GetUnixTime(CurrentDateTime));
    end;

    local procedure FillTransactionData()
    var
        DeAuditError: Label 'There is De Audit Aux Log with error, No.: %1';
    begin
        PosEntry.Reset();
        PosEntry.SetRange("Entry Date", WorkShiftDate);
        PosEntry.FindSet();
        repeat
            if DeAuditLog.Get(PosEntry."Entry No.") then begin
                if DeAuditLog."Has Error" then
                    Error(DeAuditError, DeAuditLog."POS Entry No.");

                if FirstFiscalNo = '' then
                    FirstFiscalNo := PosEntry."Fiscal No.";
                LastFiscalNo := PosEntry."Fiscal No.";

                FillTmpPayment();
                FillTmpVat();
            end;
        until PosEntry.Next() = 0;
    end;

    local procedure FillTmpPayment()
    var
        PaymentLine: Record "NPR POS Entry Payment Line";
        PaymentMapper: Record "NPR Payment Method Mapper";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        PaymentLine.Reset();
        PaymentLine.SetCurrentKey("POS Payment Method Code", "Currency Code");
        PaymentLine.SetRange("POS Entry No.", PosEntry."Entry No.");
        if PaymentLine.FindSet() then
            repeat
                PaymentMapper.Get(PaymentLine."POS Payment Method Code");
                PaymentLineTmp.Reset();
                PaymentLineTmp.SetRange("POS Period Register No.", PaymentMapper."DSFINVK Type".AsInteger()); //"POS Period Register No." is used for DSFINVK Type
                PaymentLineTmp.SetRange(Description, DeAuditLog."Transaction ID"); //Description is used for Fiskaly Transaction ID
                PaymentLineTmp.SetRange("Currency Code", PaymentLine."Currency Code");
                if PaymentLineTmp.FindFirst() then begin
                    PaymentLineTmp."Amount (LCY)" += PaymentLine."Amount (LCY)";
                    PaymentLineTmp.Modify();
                end
                else begin
                    PaymentLineTmp.Init();
                    PaymentLineTmp := PaymentLine;
                    if PaymentLineTmp."Currency Code" = '' then
                        PaymentLineTmp."Currency Code" := GeneralLedgerSetup."LCY Code";
                    PaymentLineTmp."POS Period Register No." := PaymentMapper."DSFINVK Type".AsInteger(); //"POS Period Register No." is used for DSFINVK Type
                    PaymentLineTmp.Description := DeAuditLog."Transaction ID"; //Description is used for Fiskaly Transaction ID
                    PaymentLineTmp.Insert();
                end;
            until PaymentLine.Next() = 0;
    end;

    local procedure FillTmpVat()
    var
        TaxAmountLine: Record "NPR POS Entry Tax Line";
        TaxMapper: Record "NPR VAT Post. Group Mapper";
    begin
        TaxAmountLine.Reset();
        TaxAmountLine.SetRange("POS Entry No.", PosEntry."Entry No.");
        if TaxAmountLine.FindSet() then
            repeat
                TaxMapper.RESET();
                TaxMapper.SETRANGE("VAT Identifier", TaxAmountLine."VAT Identifier");
                TaxMapper.FINDFIRST();

                TaxAmountLineTmp.Reset();
                TaxAmountLineTmp.SetRange("Print Order", TaxMapper."DSFINVK ID"); //"Print Order" is used for DSFINVK Vat ID
                TaxAmountLineTmp.SetRange("Print Description", DeAuditLog."Transaction ID"); //"Print Description" is used for Fiskaly Transaction ID
                if TaxAmountLineTmp.FindFirst() then begin
                    TaxAmountLineTmp."Amount Including Tax" += TaxAmountLine."Amount Including Tax";
                    TaxAmountLineTmp."Tax Base Amount" += TaxAmountLine."Tax Base Amount";
                    TaxAmountLineTmp."Tax Amount" += TaxAmountLine."Tax Amount";
                    TaxAmountLineTmp.Modify();
                end
                else begin
                    TaxAmountLineTmp.Init();
                    TaxAmountLineTmp := TaxAmountLine;
                    TaxAmountLineTmp."Print Order" := TaxMapper."DSFINVK ID"; //"Print Order" is used for DSFINVK Vat ID
                    TaxAmountLineTmp."Print Description" := DeAuditLog."Transaction ID"; //"Print Description" is used for Fiskaly Transaction ID
                    TaxAmountLineTmp.Insert();
                end;
            until TaxAmountLine.Next() = 0;
    end;

    local procedure CreateCashStatement() CashStatement: JsonObject
    begin
        CashStatement.Add('business_cases', CreateBusinessCases());
        CashStatement.Add('payment', CreatePayment());
    end;

    local procedure CreateTransactions() Transactions: JsonArray
    var
        Transaction: JsonObject;
        Security: JsonObject;
    begin
        PosEntry.Reset();
        PosEntry.SetRange("Entry Date", WorkShiftDate);
        PosEntry.FindSet();
        repeat
            if DeAuditLog.Get(PosEntry."Entry No.") then begin
                Clear(Security);
                Clear(Transaction);
                Security.Add('tss_tx_id', Format(DeAuditLog."Transaction ID", 0, 4));
                Transaction.Add('head', CreateTransactionHeader());
                Transaction.Add('data', CreateTransactionData());
                Transaction.Add('security', Security);
                Transactions.Add(Transaction);
            end;
        until PosEntry.Next() = 0;
    end;

    local procedure CreateBusinessCases() BusinessCases: JsonArray
    var
        BusinessCase: JsonObject;
    begin
        Clear(BusinessCase);
        BusinessCase.Add('type', 'Umsatz'); //We are sendig data only for sales, that is why here is only one Business case
        BusinessCase.Add('amounts_per_vat_id', CreateAmountsPerVatId(''));
        BusinessCases.Add(BusinessCase);
    end;

    local procedure CreateAmountsPerVatId(TransactionId: Text) AmountsPerVatId: JsonArray
    var
        OldVatId: Integer;
        InclVat: Decimal;
        ExclVat: Decimal;
        Vat: Decimal;
    begin
        OldVatId := -1;
        InclVat := 0;
        ExclVat := 0;
        Vat := 0;
        TaxAmountLineTmp.Reset();
        TaxAmountLineTmp.SetCurrentKey("Print Order"); //"Print Order" is used for DSFINVK Vat ID
        if TransactionId <> '' then
            TaxAmountLineTmp.SetRange("Print Description", TransactionId);
        if not TaxAmountLineTmp.FindSet() then
            exit;
        repeat
            if OldVatId < 0 then
                OldVatId := TaxAmountLineTmp."Print Order";
            if OldVatId <> TaxAmountLineTmp."Print Order" then begin
                AmountsPerVatId.Add(CreateAmountsPerVatIdJson(OldVatId, InclVat, ExclVat, Vat));
                InclVat := TaxAmountLineTmp."Amount Including Tax";
                ExclVat := TaxAmountLineTmp."Tax Base Amount";
                Vat := TaxAmountLineTmp."Tax Amount";
                OldVatId := TaxAmountLineTmp."Print Order";
            end
            else begin
                InclVat += TaxAmountLineTmp."Amount Including Tax";
                ExclVat += TaxAmountLineTmp."Tax Base Amount";
                Vat += TaxAmountLineTmp."Tax Amount";
            end;
        until TaxAmountLineTmp.Next() = 0;

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
        CashAmountsCurrency: JsonArray;
        PaymentTypes: JsonArray;
        DSFINVKPaymentType: Enum "NPR DSFINVK Payment Type";
        FullAmount: Decimal;
        CashAmount: Decimal;
        PaymentAmout: Decimal;
        OldCurrency: Text;
        OldType: Integer;
    begin
        FullAmount := 0;
        CashAmount := 0;
        PaymentAmout := 0;
        OldType := -1;
        OldCurrency := '';
        PaymentLineTmp.Reset();
        PaymentLineTmp.SetCurrentKey("Currency Code");
        if not PaymentLineTmp.FindSet() then
            exit;
        repeat
            POSPayment.Get(PaymentLineTmp."POS Payment Method Code");
            FullAmount += PaymentLineTmp."Amount (LCY)";
            if POSPayment."Processing Type" = POSPayment."Processing Type"::CASH then
                CashAmount += PaymentLineTmp."Amount (LCY)";

            if OldCurrency = '' then
                OldCurrency := PaymentLineTmp."Currency Code";

            if OldCurrency <> PaymentLineTmp."Currency Code" then begin
                CashAmountsCurrency.Add(CreatePaymentType(OldCurrency, PaymentAmout, ''));
                PaymentAmout := PaymentLineTmp."Amount (LCY)";
                OldCurrency := PaymentLineTmp."Currency Code";
            end
            else
                PaymentAmout += PaymentLineTmp."Amount (LCY)";
        until PaymentLineTmp.Next() = 0;

        if PaymentAmout > 0 then begin
            CashAmountsCurrency.Add(CreatePaymentType(OldCurrency, PaymentAmout, ''));
            PaymentAmout := 0;
        end;
        OldCurrency := '';

        Payment.Add('full_amount', FullAmount);
        Payment.Add('cash_amount', CashAmount);
        Payment.Add('cash_amounts_by_currency', CashAmountsCurrency);

        PaymentLineTmp.Reset();
        PaymentLineTmp.SetCurrentKey("POS Period Register No.", "Currency Code");
        PaymentLineTmp.FindSet();
        repeat
            POSPayment.Get(PaymentLineTmp."POS Payment Method Code");
            if OldCurrency = '' then
                OldCurrency := PaymentLineTmp."Currency Code";
            if OldType < 0 then
                OldType := PaymentLineTmp."POS Period Register No.";

            if (OldCurrency <> PaymentLineTmp."Currency Code") or (OldType <> PaymentLineTmp."POS Period Register No.") then begin
                PaymentTypes.Add(CreatePaymentType(OldCurrency, PaymentAmout, DSFINVKPaymentType.Names.Get((PaymentLineTmp."POS Period Register No." + 1))));
                PaymentAmout := PaymentLineTmp."Amount (LCY)";
                OldCurrency := PaymentLineTmp."Currency Code";
                OldType := PaymentLineTmp."POS Period Register No.";
            end
            else
                PaymentAmout += PaymentLineTmp."Amount (LCY)";
        until PaymentLineTmp.Next() = 0;

        if PaymentAmout > 0 then
            PaymentTypes.Add(CreatePaymentType(OldCurrency, PaymentAmout, DSFINVKPaymentType.Names.Get((PaymentLineTmp."POS Period Register No." + 1))));

        Payment.Add('payment_types', PaymentTypes);
    end;

    local procedure CreatePaymentType(OldCurrency: Text; PaymentAmout: Decimal; Type: Text) CurrencyPayment: JsonObject
    begin
        if Type <> '' then
            CurrencyPayment.Add('type', Type);
        CurrencyPayment.Add('currency_code', OldCurrency);
        CurrencyPayment.Add('amount', Format(PaymentAmout, 0, '<Precision,2:26><Standard Format,4>'));
    end;

    local procedure CreateTransactionHeader() TransactionHeader: JsonObject
    var
        Customer: Record Customer;
        TransactionHeadUser: JsonObject;
        TransactionHeadBuyer: JsonObject;
    begin
        TransactionHeadUser.Add('user_export_id', UserId);

        if Customer.Get(PosEntry."Customer No.") then begin
            TransactionHeadBuyer.Add('name', Customer.Name);
            TransactionHeadBuyer.Add('buyer_export_id', Customer."No.");
        end
        else begin
            TransactionHeadBuyer.Add('name', 'POSCustomer');
            TransactionHeadBuyer.Add('buyer_export_id', '1');
        end;

        TransactionHeadBuyer.Add('type', 'Kunde');

        TransactionHeader.Add('type', 'AVRechnung'); //We only use simple sale for now
        if PosEntry."Amount Incl. Tax" > 0 then
            TransactionHeader.Add('storno', false)
        else
            TransactionHeader.Add('storno', true);
        TransactionHeader.Add('number', PosEntry."Entry No.");
        TransactionHeader.Add('timestamp_start', GetUnixTime(DeAuditLog."Start Time"));
        TransactionHeader.Add('timestamp_end', GetUnixTime(DeAuditLog."Finish Time"));
        TransactionHeader.Add('user', TransactionHeadUser);
        TransactionHeader.Add('buyer', TransactionHeadBuyer);
        TransactionHeader.Add('tx_id', Format(DeAuditLog."Transaction ID", 0, 4));
        TransactionHeader.Add('transaction_export_id', PosEntry."Fiscal No.");
        TransactionHeader.Add('closing_client_id', Format(DeAuditLog."Client ID", 0, 4));
    end;

    local procedure CreateTransactionData() TransactionData: JsonObject
    var
        FullAmount: Decimal;
    begin
        TransactionData.Add('payment_types', GetTransactionPaymentTypes(FullAmount));
        TransactionData.Add('full_amount_incl_vat', FullAmount);
        TransactionData.Add('amounts_per_vat_id', CreateAmountsPerVatId(DeAuditLog."Transaction ID"));
        TransactionData.Add('lines', CreateTransactionLines());
    end;

    local procedure GetTransactionPaymentTypes(var FullAmount: Decimal) TransactionPaymentTypes: JsonArray
    var
        POSPayment: Record "NPR POS Payment Method";
        DSFINVKPaymentType: Enum "NPR DSFINVK Payment Type";
        PaymentAmout: Decimal;
        OldCurrency: Text;
        OldType: Integer;
    begin
        FullAmount := 0;
        OldType := -1;
        PaymentLineTmp.Reset();
        PaymentLineTmp.SetCurrentKey("POS Period Register No.", "Currency Code");
        PaymentLineTmp.SetRange(Description, DeAuditLog."Transaction ID");
        if not PaymentLineTmp.FindSet() then
            exit;
        repeat
            POSPayment.Get(PaymentLineTmp."POS Payment Method Code");
            if OldCurrency = '' then
                OldCurrency := PaymentLineTmp."Currency Code";
            if OldType < 0 then
                OldType := PaymentLineTmp."POS Period Register No.";

            if (OldCurrency <> PaymentLineTmp."Currency Code") or (OldType <> PaymentLineTmp."POS Period Register No.") then begin
                TransactionPaymentTypes.Add(CreatePaymentType(OldCurrency, PaymentAmout, DSFINVKPaymentType.Names.Get((PaymentLineTmp."POS Period Register No." + 1))));
                PaymentAmout := PaymentLineTmp."Amount (LCY)";
                OldCurrency := PaymentLineTmp."Currency Code";
                OldType := PaymentLineTmp."POS Period Register No.";
            end
            else
                PaymentAmout += PaymentLineTmp."Amount (LCY)";
            FullAmount += PaymentLineTmp."Amount (LCY)";
        until PaymentLineTmp.Next() = 0;

        if PaymentAmout > 0 then
            TransactionPaymentTypes.Add(CreatePaymentType(OldCurrency, PaymentAmout, DSFINVKPaymentType.Names.Get((PaymentLineTmp."POS Period Register No." + 1))));
    end;

    local procedure CreateTransactionLines() TransactionLines: JsonArray
    var
        POSLines: Record "NPR POS Entry Sales Line";
        VatMapper: Record "NPR VAT Post. Group Mapper";
        TransactionLine: JsonObject;
        TransactionLineBusinessCase: JsonObject;
        TransactionLineItem: JsonObject;
        AmountsPerVatIdList: JsonArray;
    begin
        POSLines.Reset();
        POSLines.SetRange("POS Entry No.", PosEntry."Entry No.");
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

    procedure GetUnixTime(ToDateTime: DateTime): Integer
    var
        Duration: Duration;
        DurationMs: BigInteger;
        FromDateTime: DateTime;
    begin
        Evaluate(FromDateTime, '1970-01-01T00:00:00Z', 9);
        Duration := ToDateTime - FromDateTime;
        DurationMs := Duration;
        exit((DurationMs / 1000) div 1);
    end;

    var
        DePosUnit: Record "NPR DE POS Unit Aux. Info";
        PosEntry: Record "NPR POS Entry";
        DeAuditLog: Record "NPR DE POS Audit Log Aux. Info";
        PaymentLineTmp: Record "NPR POS Entry Payment Line" temporary;
        TaxAmountLineTmp: Record "NPR POS Entry Tax Line" temporary;
        WorkShiftDate: Date;
        FirstFiscalNo: Text;
        LastFiscalNo: Text;
}