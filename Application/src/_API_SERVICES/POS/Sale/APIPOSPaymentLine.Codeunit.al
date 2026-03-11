#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248629 "NPR API POS Payment Line"
{
    Access = Internal;

    procedure ListPaymentLines(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        SaleId: Text;
        SaleSystemId: Guid;
        POSSale: Record "NPR POS Sale";
        POSSaleLine: Record "NPR POS Sale Line";
        Json: Codeunit "NPR Json Builder";
    begin
        Request.SkipCacheIfNonStickyRequest(POSSaleTableIds());

        SaleId := Request.Paths().Get(3);
        if SaleId = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: saleId'));

        if not Evaluate(SaleSystemId, SaleId) then
            exit(Response.RespondBadRequest('Invalid saleId format'));

        POSSale.ReadIsolation := IsolationLevel::ReadCommitted;
        if not POSSale.GetBySystemId(SaleSystemId) then
            exit(Response.RespondResourceNotFound());

        Json.StartArray('');
        POSSaleLine.SetRange("Register No.", POSSale."Register No.");
        POSSaleLine.SetRange("Sales Ticket No.", POSSale."Sales Ticket No.");
        POSSaleLine.SetRange("Line Type", POSSaleLine."Line Type"::"POS Payment");
        POSSaleLine.ReadIsolation := IsolationLevel::ReadCommitted;

        if POSSaleLine.FindSet() then
            repeat
                AddPaymentLineToJson(POSSaleLine, Json);
            until POSSaleLine.Next() = 0;
        Json.EndArray();

        exit(Response.RespondOK(Json.BuildAsArray()));
    end;

    procedure GetPaymentLine(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        SaleId: Text;
        PaymentLineId: Text;
        SaleSystemId: Guid;
        PaymentLineSystemId: Guid;
        POSSale: Record "NPR POS Sale";
        POSSaleLine: Record "NPR POS Sale Line";
        Json: Codeunit "NPR Json Builder";
    begin
        Request.SkipCacheIfNonStickyRequest(POSSaleTableIds());

        SaleId := Request.Paths().Get(3);
        PaymentLineId := Request.Paths().Get(5);

        if not Evaluate(SaleSystemId, SaleId) then
            exit(Response.RespondBadRequest('Invalid saleId format'));
        if not Evaluate(PaymentLineSystemId, PaymentLineId) then
            exit(Response.RespondBadRequest('Invalid paymentLineId format'));

        POSSale.ReadIsolation := IsolationLevel::ReadCommitted;
        if not POSSale.GetBySystemId(SaleSystemId) then
            exit(Response.RespondResourceNotFound());

        POSSaleLine.ReadIsolation := IsolationLevel::ReadCommitted;
        if not POSSaleLine.GetBySystemId(PaymentLineSystemId) then
            exit(Response.RespondResourceNotFound());

        if (POSSaleLine."Register No." <> POSSale."Register No.") or
           (POSSaleLine."Sales Ticket No." <> POSSale."Sales Ticket No.") or
           (POSSaleLine."Line Type" <> POSSaleLine."Line Type"::"POS Payment") then
            exit(Response.RespondResourceNotFound());

        AddPaymentLineToJson(POSSaleLine, Json);

        exit(Response.RespondOK(Json.Build()));
    end;

    procedure CreatePaymentLine(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        SaleId: Text;
        SaleSystemId: Guid;
        Body: JsonToken;
        POSSale: Record "NPR POS Sale";
        APIPOSSale: Codeunit "NPR API POS Sale";
        DeltaBuilder: Codeunit "NPR API POS Delta Builder";
        PaymentMethodCode: Code[10];
        PaymentAmount: Decimal;
        PaymentType: Text;
        Description: Text[100];
        TempText: Text;
        LineId: Guid;
    begin
        Request.SkipCacheIfNonStickyRequest(POSSaleTableIds());

        SaleId := Request.Paths().Get(3);
        if SaleId = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: saleId'));

        if not Evaluate(SaleSystemId, SaleId) then
            exit(Response.RespondBadRequest('Invalid saleId format'));

        if not POSSale.GetBySystemId(SaleSystemId) then
            exit(Response.RespondResourceNotFound());

        if not Evaluate(LineId, Request.Paths().Get(5)) then
            exit(Response.RespondBadRequest('Invalid paymentLineId format'));

        Body := Request.BodyJson();

        if not GetJsonText(Body, 'paymentMethodCode', TempText) then
            exit(Response.RespondBadRequest('Missing required field: paymentMethodCode'));
        PaymentMethodCode := CopyStr(TempText, 1, MaxStrLen(PaymentMethodCode));

        if not GetJsonDecimal(Body, 'amount', PaymentAmount) then
            exit(Response.RespondBadRequest('Missing required field: amount'));

        if not GetJsonText(Body, 'paymentType', PaymentType) then
            exit(Response.RespondBadRequest('Missing required field: paymentType'));

        if GetJsonText(Body, 'description', TempText) then
            Description := CopyStr(TempText, 1, MaxStrLen(Description));
        if Description = '' then
            Description := PaymentMethodCode;

        APIPOSSale.ReconstructSession(SaleSystemId);
        DeltaBuilder.StartDataCollection();

        case PaymentType of
            'Cash':
                CreateCashPayment(PaymentMethodCode, PaymentAmount, Description, LineId);
            'EFT':
                CreateEFTPayment(Body, PaymentMethodCode, PaymentAmount, Description, POSSale, LineId);
            else
                exit(Response.RespondBadRequest('Invalid paymentType. Supported types: Cash, EFT'));
        end;

        exit(Response.RespondCreated(DeltaBuilder.BuildDeltaResponse()));
    end;

    procedure DeletePaymentLine(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        SaleId: Text;
        PaymentLineId: Text;
        SaleSystemId: Guid;
        PaymentLineSystemId: Guid;
        POSSale: Record "NPR POS Sale";
        POSSaleLine: Record "NPR POS Sale Line";
        APIPOSSale: Codeunit "NPR API POS Sale";
        DeltaBuilder: Codeunit "NPR API POS Delta Builder";
    begin
        Request.SkipCacheIfNonStickyRequest(POSSaleTableIds());

        SaleId := Request.Paths().Get(3);
        PaymentLineId := Request.Paths().Get(5);

        if not Evaluate(SaleSystemId, SaleId) then
            exit(Response.RespondBadRequest('Invalid saleId format'));
        if not Evaluate(PaymentLineSystemId, PaymentLineId) then
            exit(Response.RespondBadRequest('Invalid paymentLineId format'));

        if not POSSale.GetBySystemId(SaleSystemId) then
            exit(Response.RespondResourceNotFound());

        if not POSSaleLine.GetBySystemId(PaymentLineSystemId) then
            exit(Response.RespondResourceNotFound());

        if (POSSaleLine."Register No." <> POSSale."Register No.") or
           (POSSaleLine."Sales Ticket No." <> POSSale."Sales Ticket No.") or
           (POSSaleLine."Line Type" <> POSSaleLine."Line Type"::"POS Payment") then
            exit(Response.RespondResourceNotFound());

        APIPOSSale.ReconstructSession(SaleSystemId);
        DeltaBuilder.StartDataCollection();

        POSSaleLine.Delete(true);

        exit(Response.RespondOK(DeltaBuilder.BuildDeltaResponse()));
    end;

    local procedure CreateCashPayment(PaymentMethodCode: Code[10]; Amount: Decimal; Description: Text[100]; LineId: Guid)
    var
        TempPaymentLine: Record "NPR POS Sale Line" temporary;
        POSSession: Codeunit "NPR POS Session";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
    begin
        TempPaymentLine.Init();
        TempPaymentLine."Line Type" := TempPaymentLine."Line Type"::"POS Payment";
        TempPaymentLine."No." := PaymentMethodCode;
        TempPaymentLine.Description := Description;
        TempPaymentLine."Amount Including VAT" := Amount;
        TempPaymentLine.SystemId := LineId;

        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.SetUseCustomSystemId(true);
        POSPaymentLine.InsertPaymentLine(TempPaymentLine, 0); // 0 = no foreign currency
    end;

    local procedure CreateEFTPayment(Body: JsonToken; PaymentMethodCode: Code[10]; Amount: Decimal; Description: Text[100]; POSSale: Record "NPR POS Sale"; LineId: Guid)
    var
        TempPaymentLine: Record "NPR POS Sale Line" temporary;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTReceipt: Record "NPR EFT Receipt";
        MappedPOSPaymentMethod: Record "NPR POS Payment Method";
        EFTPaymentMapping: Codeunit "NPR EFT Payment Mapping";
        MaskedCardNo: Text;
        PSPReference: Text;
        PARToken: Text;
        CardApplicationId: Text;
        ActualPaymentMethodCode: Code[10];
        Success: Boolean;
        EFTReceiptLines: JsonArray;
        EFTReceiptLine: JsonToken;
        ReceiptLineText: Text;
        EntryNo: Integer;
        EFTReceiptEntryNo: Integer;
        POSSession: Codeunit "NPR POS Session";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
    begin
        ActualPaymentMethodCode := PaymentMethodCode;

        GetJsonText(Body, 'maskedCardNo', MaskedCardNo);
        GetJsonText(Body, 'pspReference', PSPReference);
        GetJsonText(Body, 'parToken', PARToken);
        GetJsonText(Body, 'cardApplicationId', CardApplicationId);
        GetJsonBoolean(Body, 'success', Success);

        EFTTransactionRequest.Init();
        EFTTransactionRequest."Register No." := POSSale."Register No.";
        EFTTransactionRequest."Sales Ticket No." := POSSale."Sales Ticket No.";
        EFTTransactionRequest."POS Payment Type Code" := ActualPaymentMethodCode;
        EFTTransactionRequest."Original POS Payment Type Code" := PaymentMethodCode;
        EFTTransactionRequest."Integration Type" := 'POS_API';
        EFTTransactionRequest.Started := CurrentDateTime;
        EFTTransactionRequest.Finished := CurrentDateTime;
        EFTTransactionRequest."Card Number" := CopyStr(MaskedCardNo, 1, MaxStrLen(EFTTransactionRequest."Card Number"));
        EFTTransactionRequest."PSP Reference" := CopyStr(PSPReference, 1, MaxStrLen(EFTTransactionRequest."PSP Reference"));
        EFTTransactionRequest."External Payment Token" := CopyStr(PARToken, 1, MaxStrLen(EFTTransactionRequest."External Payment Token"));
        EFTTransactionRequest."Card Application ID" := CopyStr(CardApplicationId, 1, MaxStrLen(EFTTransactionRequest."Card Application ID"));
        EFTTransactionRequest.Successful := Success;
        EFTTransactionRequest."Amount Input" := Amount;
        EFTTransactionRequest."Amount Output" := Amount;
        EFTTransactionRequest."External Result Known" := true;

        EFTTransactionRequest.Insert(true);
        EntryNo := EFTTransactionRequest."Entry No.";

        // Attempt to map to a more specific payment method based on card info (BIN, issuer ID, application ID)
        if EFTPaymentMapping.FindPaymentType(EFTTransactionRequest, MappedPOSPaymentMethod) then begin
            ActualPaymentMethodCode := MappedPOSPaymentMethod.Code;
            EFTTransactionRequest."POS Payment Type Code" := ActualPaymentMethodCode;
            EFTTransactionRequest.Modify();
        end;

        TempPaymentLine.Init();
        TempPaymentLine."Line Type" := TempPaymentLine."Line Type"::"POS Payment";
        TempPaymentLine."No." := ActualPaymentMethodCode;
        TempPaymentLine.Description := Description;
        TempPaymentLine."Amount Including VAT" := Amount;
        TempPaymentLine.SystemId := LineId;
        TempPaymentLine."EFT Approved" := Success;

        if GetJsonArray(Body, 'eftReceipt', EFTReceiptLines) then begin
            EFTReceipt.SetRange("Register No.", POSSale."Register No.");
            EFTReceipt.SetRange("Sales Ticket No.", POSSale."Sales Ticket No.");
            if EFTReceipt.FindLast() then;
            EFTReceiptEntryNo := EFTReceipt."Entry No." + 1;
            EFTReceipt.Reset();

            foreach EFTReceiptLine in EFTReceiptLines do begin
                if EFTReceiptLine.IsValue() then begin
                    ReceiptLineText := EFTReceiptLine.AsValue().AsText();
                    EFTReceipt.Init();
                    EFTReceipt."Entry No." := EFTReceiptEntryNo;
                    EFTReceipt."Register No." := POSSale."Register No.";
                    EFTReceipt."Sales Ticket No." := POSSale."Sales Ticket No.";
                    EFTReceipt."EFT Trans. Request Entry No." := EntryNo;
                    EFTReceipt.Date := Today;
                    EFTReceipt."Transaction Time" := Time;
                    EFTReceipt.Text := CopyStr(ReceiptLineText, 1, MaxStrLen(EFTReceipt.Text));
                    EFTReceipt.Insert(true);
                    EFTReceiptEntryNo += 1;
                end;
            end;
        end;

        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.SetUseCustomSystemId(true);
        POSPaymentLine.InsertPaymentLine(TempPaymentLine, 0);
    end;

    internal procedure AddPaymentLineToJson(POSSaleLine: Record "NPR POS Sale Line"; var Json: Codeunit "NPR Json Builder")
    begin
        Json.StartObject('')
            .AddProperty('id', Format(POSSaleLine.SystemId, 0, 4).ToLower())
            .AddProperty('sortKey', POSSaleLine."Line No.")
            .AddProperty('paymentMethodCode', POSSaleLine."No.")
            .AddProperty('description', POSSaleLine.Description)
            .AddProperty('amountInclVat', POSSaleLine."Amount Including VAT")
        .EndObject();
    end;

    local procedure GetJsonText(Body: JsonToken; PropertyName: Text; var Value: Text): Boolean
    var
        JToken: JsonToken;
    begin
        if not Body.AsObject().Get(PropertyName, JToken) then
            exit(false);
        if JToken.IsValue() then begin
            Value := JToken.AsValue().AsText();
            exit(true);
        end;
        exit(false);
    end;

    local procedure GetJsonDecimal(Body: JsonToken; PropertyName: Text; var Value: Decimal): Boolean
    var
        JToken: JsonToken;
    begin
        if not Body.AsObject().Get(PropertyName, JToken) then
            exit(false);
        if JToken.IsValue() then begin
            Value := JToken.AsValue().AsDecimal();
            exit(true);
        end;
        exit(false);
    end;

    local procedure GetJsonBoolean(Body: JsonToken; PropertyName: Text; var Value: Boolean): Boolean
    var
        JToken: JsonToken;
    begin
        if not Body.AsObject().Get(PropertyName, JToken) then
            exit(false);
        if JToken.IsValue() then begin
            Value := JToken.AsValue().AsBoolean();
            exit(true);
        end;
        exit(false);
    end;

    local procedure GetJsonArray(Body: JsonToken; PropertyName: Text; var Value: JsonArray): Boolean
    var
        JToken: JsonToken;
    begin
        if not Body.AsObject().Get(PropertyName, JToken) then
            exit(false);
        if JToken.IsArray() then begin
            Value := JToken.AsArray();
            exit(true);
        end;
        exit(false);
    end;

    local procedure POSSaleTableIds(): List of [Integer]
    var
        TableIdList: List of [Integer];
    begin
        TableIdList.Add(Database::"NPR POS Sale");
        TableIdList.Add(Database::"NPR POS Sale Line");
        exit(TableIdList);
    end;
}
#endif
