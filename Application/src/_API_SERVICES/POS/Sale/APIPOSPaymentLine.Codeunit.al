#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248629 "NPR API POS Payment Line"
{
    Access = Internal;

    procedure IntegrationType(): Code[20]
    begin
        exit('POS_API');
    end;

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

    [CommitBehavior(CommitBehavior::Ignore)] // Keep the external attempt and its payment line in one API transaction.
    procedure CreatePaymentLine(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        SaleId: Text;
        SaleSystemId: Guid;
        Body: JsonToken;
        POSSale: Record "NPR POS Sale";
        POSSaleLine: Record "NPR POS Sale Line";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        APIPOSSale: Codeunit "NPR API POS Sale";
        DeltaBuilder: Codeunit "NPR API POS Delta Builder";
        PaymentMethodCode: Code[10];
        PaymentAmount: Decimal;
        PaymentType: Text;
        Description: Text[100];
        TempText: Text;
        ValidationError: Text;
        LineId: Guid;
        Success: Boolean;
        InvalidSuccessLbl: Label 'Invalid field: success. Expected a boolean.';
        RefundsNotImplementedLbl: Label 'refunds not implemented';
        DuplicatePaymentLineLbl: Label '%1 with %2 %3 already exists.', Comment = '%1 = POS sale line table caption, %2 = SystemId field caption, %3 = caller-supplied line ID';
    begin
        Request.SkipCacheIfNonStickyRequest(POSSaleTableIds());

        SaleId := Request.Paths().Get(3);
        if SaleId = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: saleId'));

        if not Evaluate(SaleSystemId, SaleId) then
            exit(Response.RespondBadRequest('Invalid saleId format'));

        if not POSSale.GetBySystemId(SaleSystemId) then
            exit(Response.RespondResourceNotFound());

        if not APIPOSSale.AssertPOSUnitOpenForSale(POSSale."Register No.") then
            exit(Response.RespondBadRequest(StrSubstNo('POS Unit ''%1'' is not open for sales.', POSSale."Register No.")));

        if not Evaluate(LineId, Request.Paths().Get(5)) then
            exit(Response.RespondBadRequest('Invalid paymentLineId format'));

        Body := Request.BodyJson();

        if not GetJsonText(Body, 'paymentMethodCode', TempText) then
            exit(Response.RespondBadRequest('Missing required field: paymentMethodCode'));
        if not CheckTextLength(Body, 'paymentMethodCode', MaxStrLen(PaymentMethodCode), ValidationError) then
            exit(Response.RespondBadRequest(ValidationError));
        PaymentMethodCode := CopyStr(TempText, 1, MaxStrLen(PaymentMethodCode));

        if not GetJsonDecimal(Body, 'amount', PaymentAmount) then
            exit(Response.RespondBadRequest('Missing required field: amount'));

        if not GetJsonText(Body, 'paymentType', PaymentType) then
            exit(Response.RespondBadRequest('Missing required field: paymentType'));

        if PaymentType = 'EFT' then begin
            if Body.AsObject().Contains('success') then
                if not GetJsonBoolean(Body, 'success', Success) then
                    exit(Response.RespondBadRequest(InvalidSuccessLbl));
            if PaymentAmount < 0 then
                exit(Response.RespondBadRequest(RefundsNotImplementedLbl));
            if not CheckTextLength(Body, 'maskedCardNo', MaxStrLen(EFTTransactionRequest."Card Number"), ValidationError) then
                exit(Response.RespondBadRequest(ValidationError));
            if not CheckTextLength(Body, 'pspReference', MaxStrLen(EFTTransactionRequest."PSP Reference"), ValidationError) then
                exit(Response.RespondBadRequest(ValidationError));
            if not CheckTextLength(Body, 'parToken', MaxStrLen(EFTTransactionRequest."Payment Account Reference"), ValidationError) then
                exit(Response.RespondBadRequest(ValidationError));
            if not CheckTextLength(Body, 'cardApplicationId', MaxStrLen(EFTTransactionRequest."Card Application ID"), ValidationError) then
                exit(Response.RespondBadRequest(ValidationError));
            if POSSaleLine.GetBySystemId(LineId) then
                exit(Response.RespondBadRequest(StrSubstNo(DuplicatePaymentLineLbl, POSSaleLine.TableCaption, POSSaleLine.FieldCaption(SystemId), LineId)));
        end;

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
                CreateEFTPayment(Body, PaymentMethodCode, PaymentAmount, Description, POSSale, LineId, Success);
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

        if not APIPOSSale.AssertPOSUnitOpenForSale(POSSale."Register No.") then
            exit(Response.RespondBadRequest(StrSubstNo('POS Unit ''%1'' is not open for sales.', POSSale."Register No.")));

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

    local procedure CreateEFTPayment(Body: JsonToken; PaymentMethodCode: Code[10]; Amount: Decimal; Description: Text[100]; POSSale: Record "NPR POS Sale"; LineId: Guid; Success: Boolean)
    var
        TempPaymentLine: Record "NPR POS Sale Line" temporary;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTReceipt: Record "NPR EFT Receipt";
        MappedPOSPaymentMethod: Record "NPR POS Payment Method";
        GLSetup: Record "General Ledger Setup";
        POSUnit: Record "NPR POS Unit";
        PaymentLine: Record "NPR POS Sale Line";
        EFTPaymentMapping: Codeunit "NPR EFT Payment Mapping";
        TimeZoneMgt: Codeunit "NPR Time Zone Mgt.";
        RecordedAt: DateTime;
        MaskedCardNo: Text;
        // Keep these lengths aligned with the PSP Reference and Payment Account Reference fields.
        PSPReference: Text[16];
        PARToken: Text[100];
        CardApplicationId: Text;
        ActualPaymentMethodCode: Code[10];
        EFTReceiptLines: JsonArray;
        EFTReceiptLine: JsonToken;
        ReceiptLineText: Text;
        EntryNo: Integer;
        EFTReceiptEntryNo: Integer;
        POSSession: Codeunit "NPR POS Session";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        InsertPaymentLineLbl: Label 'Failed to insert %1.', Comment = '%1 = POS sale line table caption';
    begin
        ActualPaymentMethodCode := PaymentMethodCode;

        GetJsonText(Body, 'maskedCardNo', MaskedCardNo);
#pragma warning disable AA0139 // The sole caller validates PSP/PAR lengths with CheckTextLength before these reads.
        GetJsonText(Body, 'pspReference', PSPReference);
        GetJsonText(Body, 'parToken', PARToken);
#pragma warning restore AA0139
        GetJsonText(Body, 'cardApplicationId', CardApplicationId);

        GLSetup.Get();
        POSUnit.Get(POSSale."Register No.");
        EFTTransactionRequest.Init();
        EFTTransactionRequest."Register No." := POSSale."Register No.";
        EFTTransactionRequest."Sales Ticket No." := POSSale."Sales Ticket No.";
        EFTTransactionRequest."Sales ID" := POSSale.SystemId;
        EFTTransactionRequest."Processing Type" := EFTTransactionRequest."Processing Type"::PAYMENT;
#pragma warning disable AA0139 // BC user names and this field both hold 50 characters.
        EFTTransactionRequest."User ID" := UserId();
#pragma warning restore AA0139
        EFTTransactionRequest."Self Service" := POSUnit."POS Type" = POSUnit."POS Type"::UNATTENDED;
        EFTTransactionRequest."Currency Code" := GLSetup."LCY Code";
        EFTTransactionRequest."POS Description" := Description;
        EFTTransactionRequest."POS Payment Type Code" := ActualPaymentMethodCode;
        EFTTransactionRequest."Original POS Payment Type Code" := PaymentMethodCode;
        EFTTransactionRequest."Integration Type" := IntegrationType();
        RecordedAt := CurrentDateTime;
        EFTTransactionRequest.Started := RecordedAt;
        EFTTransactionRequest.Finished := RecordedAt;
        TimeZoneMgt.GetLocalDateTime(RecordedAt, EFTTransactionRequest."Transaction Date", EFTTransactionRequest."Transaction Time");
        EFTTransactionRequest."Card Number" := CopyStr(MaskedCardNo, 1, MaxStrLen(EFTTransactionRequest."Card Number"));
        EFTTransactionRequest."PSP Reference" := PSPReference;
        // The caller supplies the PSP itself, not the terminal's merchant.PSP convention parsed by OnValidate.
        EFTTransactionRequest."External Transaction ID" := PSPReference;
        EFTTransactionRequest."Reference Number Output" := PSPReference;
        EFTTransactionRequest."Payment Account Reference" := PARToken;
        EFTTransactionRequest."Card Application ID" := CopyStr(CardApplicationId, 1, MaxStrLen(EFTTransactionRequest."Card Application ID"));
        EFTTransactionRequest.Successful := Success;
        EFTTransactionRequest."Amount Input" := Amount;
        if Success then begin
            EFTTransactionRequest."Amount Output" := Amount;
            EFTTransactionRequest."Result Amount" := Amount;
        end;
        EFTTransactionRequest."Financial Impact" := Success and (Amount <> 0);
        EFTTransactionRequest."External Result Known" := true;
        EFTTransactionRequest."Result Processed" := true;

        // Attempt to map to a more specific payment method based on card info (BIN, issuer ID, application ID)
        if EFTPaymentMapping.FindPaymentType(EFTTransactionRequest, MappedPOSPaymentMethod) then begin
            ActualPaymentMethodCode := MappedPOSPaymentMethod.Code;
            EFTTransactionRequest."POS Payment Type Code" := ActualPaymentMethodCode;
            EFTTransactionRequest."Card Name" := CopyStr(MappedPOSPaymentMethod.Description, 1, MaxStrLen(EFTTransactionRequest."Card Name"));
        end;

        MappedPOSPaymentMethod.Get(ActualPaymentMethodCode);
        MappedPOSPaymentMethod.TestField("Block POS Payment", false);
        EFTTransactionRequest.Insert(true);
        EntryNo := EFTTransactionRequest."Entry No.";

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
                    EFTReceipt.Date := EFTTransactionRequest."Transaction Date";
                    EFTReceipt."Transaction Time" := EFTTransactionRequest."Transaction Time";
                    EFTReceipt.Text := CopyStr(ReceiptLineText, 1, MaxStrLen(EFTReceipt.Text));
                    EFTReceipt.Insert(true);
                    EFTReceiptEntryNo += 1;
                end;
            end;
        end;

        if not Success then
            exit;

        TempPaymentLine.Init();
        TempPaymentLine."Line Type" := TempPaymentLine."Line Type"::"POS Payment";
        TempPaymentLine."No." := ActualPaymentMethodCode;
        TempPaymentLine.Description := Description;
        TempPaymentLine."Amount Including VAT" := Amount;
        TempPaymentLine.SystemId := LineId;
        TempPaymentLine."EFT Approved" := Success;
        TempPaymentLine.Reference := CopyStr(EFTTransactionRequest."Reference Number Output", 1, MaxStrLen(TempPaymentLine.Reference));
        TempPaymentLine."EFT Card Number" := EFTTransactionRequest."Card Number";
        TempPaymentLine."EFT Card Name" := EFTTransactionRequest."Card Name";
        TempPaymentLine."EFT Card Application ID" := EFTTransactionRequest."Card Application ID";
        TempPaymentLine."EFT Payment Account Reference" := EFTTransactionRequest."Payment Account Reference";

        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.SetUseCustomSystemId(true);
        if not POSPaymentLine.InsertPaymentLine(TempPaymentLine, 0) then
            Error(InsertPaymentLineLbl, TempPaymentLine.TableCaption);
        POSPaymentLine.GetCurrentPaymentLine(PaymentLine);
        EFTTransactionRequest."Sales Line ID" := PaymentLine.SystemId;
        EFTTransactionRequest."Sales Line No." := PaymentLine."Line No.";
        EFTTransactionRequest.Modify();
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

    local procedure CheckTextLength(Body: JsonToken; PropertyName: Text; MaximumLength: Integer; var ValidationError: Text): Boolean
    var
        Value: Text;
        ValueTooLongLbl: Label '%1 must not exceed %2 characters.', Comment = '%1 = JSON property name, %2 = maximum number of characters';
    begin
        if not GetJsonText(Body, PropertyName, Value) then
            exit(true);
        if StrLen(Value) <= MaximumLength then
            exit(true);
        ValidationError := StrSubstNo(ValueTooLongLbl, PropertyName, MaximumLength);
        exit(false);
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
        JsonValueText: Text;
    begin
        if not Body.AsObject().Get(PropertyName, JToken) then
            exit(false);
        if JToken.IsValue() then begin
            JToken.WriteTo(JsonValueText);
            if not (JsonValueText in ['true', 'false']) then
                exit(false);
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
