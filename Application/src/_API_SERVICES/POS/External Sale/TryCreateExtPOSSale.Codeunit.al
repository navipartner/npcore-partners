#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248183 "NPR Try Create Ext POS Sale"
{
    Access = Internal;

    var
        _RequestJson: JsonObject;
        _Response: Codeunit "NPR API Response";
        _LineNo: Integer;
        _ExternalPOSSaleEvents: Codeunit "NPR External POS Sale Events";
        _APIExternalPOSSale: Codeunit "NPR API External POS Sale";

    trigger OnRun()
    var
        ExternalPOSSale: Record "NPR External POS Sale";
        TempJToken: JsonToken;
        Json: Codeunit "NPR Json Builder";
    begin
        ExternalPOSSale := JsonToSale(_RequestJson);

        if (_RequestJson.SelectToken('saleLines', TempJToken)) then
            foreach TempJToken in TempJToken.AsArray() do
                JsonToSaleLine(TempJToken.AsObject(), ExternalPOSSale);

        if (_RequestJson.SelectToken('paymentLines', TempJToken)) then
            foreach TempJToken in TempJToken.AsArray() do
                JsonToPaymentLine(TempJToken.AsObject(), ExternalPOSSale);

        // TODO: Avoid actually reading the entire objects again
        Json := _APIExternalPOSSale.SaleToJson(Json, ExternalPOSSale);
        _Response.RespondCreated(Json);
    end;

    local procedure JsonToSale(Sale: JsonObject) ExternalPOSSale: Record "NPR External POS Sale"
    var
        TempJToken: JsonToken;
        Customer: Record Customer;
        POSSale: Codeunit "NPR POS Sale";
        POSStore: Record "NPR POS Store";
        POSPostingProfile: Record "NPR POS Posting Profile";
        UserSetup: Record "User Setup";
    begin
        ExternalPOSSale.Init();
        ExternalPOSSale."Entry No." := 0;

        Sale.SelectToken('startedAt', TempJToken);
        ExternalPOSSale.Date := DT2Date(TempJToken.AsValue().AsDateTime());
        ExternalPOSSale."Start Time" := DT2Time(TempJToken.AsValue().AsDateTime());

        /**
         * Important to get the POS Unit first as the validation on POS Store will
         * trigger dimension "calculation" which includes this field.
         */
        Sale.SelectToken('posUnit', TempJToken);
        ExternalPOSSale.Validate("Register No.", TempJToken.AsValue().AsCode());
        ExternalPOSSale.TestField("Register No.");

        Sale.SelectToken('posStore', TempJToken);
        ExternalPOSSale.Validate("POS Store Code", TempJToken.AsValue().AsCode());
        ExternalPOSSale.TestField("POS Store Code");

        POSStore.Get(ExternalPOSSale."POS Store Code");
        ExternalPOSSale."Country Code" := POSStore."Country/Region Code";
        ExternalPOSSale."Location Code" := POSStore."Location Code";

        POSPostingProfile.Get(POSStore."POS Posting Profile");
        ExternalPOSSale."Tax Liable" := POSPostingProfile."Tax Liable";
        ExternalPOSSale."Tax Area Code" := POSPostingProfile."Tax Area Code";
        ExternalPOSSale."Gen. Bus. Posting Group" := POSPostingProfile."Gen. Bus. Posting Group";
        ExternalPOSSale."VAT Bus. Posting Group" := POSPostingProfile."VAT Bus. Posting Group";

        if (Sale.SelectToken('receiptNo', TempJToken)) then
#pragma warning disable AA0139
            ExternalPOSSale."Sales Ticket No." := TempJToken.AsValue().AsText()
#pragma warning restore AA0139
        else
            ExternalPOSSale."Sales Ticket No." := POSSale.GetNextReceiptNo(ExternalPOSSale."Register No.");

        if (Sale.SelectToken('salespersonCode', TempJToken)) then
            ExternalPOSSale.Validate("Salesperson Code", TempJToken.AsValue().AsCode());

        if (Sale.SelectToken('customerId', TempJToken)) then begin
            Customer.SetLoadFields("No.");
            Customer.GetBySystemId(TempJToken.AsValue().AsText());
            ExternalPOSSale.Validate("Customer No.", Customer."No.");
        end;

        Sale.SelectToken('pricesIncludeVAT', TempJToken);
        ExternalPOSSale.Validate("Prices Including VAT", TempJToken.AsValue().AsBoolean());

        if (Sale.SelectToken('externalDocumentNo', TempJToken)) then
#pragma warning disable AA0139
            ExternalPOSSale."External Document No." := TempJToken.AsValue().AsCode();
#pragma warning restore AA0139

        if (ExternalPOSSale."Salesperson Code" = '') then begin
            UserSetup.Get(UserId());
            UserSetup.TestField("Salespers./Purch. Code");
            ExternalPOSSale."Salesperson Code" := UserSetup."Salespers./Purch. Code";
        end;

        ExternalPOSSale.Insert(true);
    end;

    local procedure JsonToSaleLine(SaleLine: JsonObject; ExternalPOSSale: Record "NPR External POS Sale") ExternalPOSSaleLine: Record "NPR External POS Sale Line"
    var
        TempJToken: JsonToken;
    begin
        _LineNo += 10000;

        ExternalPOSSaleLine.Init();
        ExternalPOSSaleLine."External POS Sale Entry No." := ExternalPOSSale."Entry No.";
        ExternalPOSSaleLine."Line No." := _LineNo;

        SaleLine.SelectToken('type', TempJToken);
        Evaluate(ExternalPOSSaleLine."Line Type", TempJToken.AsValue().AsText());

        SaleLine.SelectToken('code', TempJToken);
        ExternalPOSSaleLine.Validate("No.", TempJToken.AsValue().AsCode());

        if (SaleLine.SelectToken('variantCode', TempJToken)) then
            ExternalPOSSaleLine.Validate("Variant Code", TempJToken.AsValue().AsCode());

        SaleLine.SelectToken('qty', TempJToken);
        ExternalPOSSaleLine.Validate(Quantity, TempJToken.AsValue().AsDecimal());

        SaleLine.SelectToken('unitPrice', TempJToken);
        ExternalPOSSaleLine.Validate("Unit Price", TempJToken.AsValue().AsDecimal());

        if (SaleLine.SelectToken('vatPercent', TempJToken)) then
            ExternalPOSSaleLine.Validate("VAT %", TempJToken.AsValue().AsDecimal());

        if (SaleLine.SelectToken('amount', TempJToken)) then
            ExternalPOSSaleLine.Validate(Amount, TempJToken.AsValue().AsDecimal());

        SaleLine.SelectToken('amountIncludingVAT', TempJToken);
        ExternalPOSSaleLine.Validate("Amount Including VAT", TempJToken.AsValue().AsDecimal());

        if (SaleLine.SelectToken('discountType', TempJToken)) then
            Evaluate(ExternalPOSSaleLine."Discount Type", TempJToken.AsValue().AsText());

        SaleLine.SelectToken('discountAmount', TempJToken);
        ExternalPOSSaleLine.Validate("Discount Amount", TempJToken.AsValue().AsDecimal());

        if (SaleLine.SelectToken('unitOfMeasureCode', TempJToken)) then
            ExternalPOSSaleLine.Validate("Unit of Measure Code", TempJToken.AsValue().AsCode());

        SaleLine.SelectToken('description', TempJToken);
        ExternalPOSSaleLine.Description := CopyStr(TempJToken.AsValue().AsText(), 1, MaxStrLen(ExternalPOSSaleLine.Description));

        if (SaleLine.SelectToken('description2', TempJToken)) then
            ExternalPOSSaleLine."Description 2" := CopyStr(TempJToken.AsValue().AsText(), 1, MaxStrLen(ExternalPOSSaleLine."Description 2"));

        if (SaleLine.SelectToken('returnReasonCode', TempJToken)) then
            ExternalPOSSaleLine.Validate("Return Reason Code", TempJToken.AsValue().AsCode());

        ExternalPOSSaleLine.Insert(true);

        ExternalPOSSaleLine.UpdateVAT();
        ExternalPOSSaleLine.Modify(true);
    end;

    local procedure JsonToPaymentLine(PaymentLine: JsonObject; ExternalPOSSale: Record "NPR External POS Sale") ExternalPOSPaymentLine: Record "NPR External POS Sale Line"
    var
        TempJToken: JsonToken;
    begin
        _LineNo += 10000;

        ExternalPOSPaymentLine.Init();
        ExternalPOSPaymentLine."External POS Sale Entry No." := ExternalPOSSale."Entry No.";
        ExternalPOSPaymentLine."Line No." := _LineNo;
        ExternalPOSPaymentLine.Validate("Line Type", Enum::"NPR POS Sale Line Type"::"POS Payment");

        PaymentLine.SelectToken('paymentMethodCode', TempJToken);
        ExternalPOSPaymentLine.Validate("No.", TempJToken.AsValue().AsCode());

        PaymentLine.SelectToken('description', TempJToken);
        ExternalPOSPaymentLine.Description := CopyStr(TempJToken.AsValue().AsText(), 1, MaxStrLen(ExternalPOSPaymentLine.Description));

        PaymentLine.SelectToken('amountIncludingVAT', TempJToken);
        ExternalPOSPaymentLine."Amount Including VAT" := TempJToken.AsValue().AsDecimal();

        if (PaymentLine.SelectToken('currencyAmount', TempJToken)) then
            ExternalPOSPaymentLine."Currency Amount" := TempJToken.AsValue().AsDecimal();

        ExternalPOSPaymentLine.Insert(true);

        if (PaymentLine.SelectToken('additionalEftData', TempJToken)) then
            _ExternalPOSSaleEvents.OnAfterInsertPaymentLineFromRestApi(ExternalPOSPaymentLine, TempJToken.AsObject());
    end;

    internal procedure SetParameters(RequestJson: JsonObject; var Response: Codeunit "NPR API Response")
    begin
        _RequestJson := RequestJson;
        _Response := Response;
    end;
}
#endif