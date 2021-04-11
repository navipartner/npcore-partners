codeunit 6014444 "NPR DE Audit Mgt."
{
    SingleInstance = true;

    procedure HandlerCode(): Text
    begin
        exit('DE_FISKALY');
    end;

    local procedure IsEnabled(POSAuditProfileCode: Code[20]): Boolean
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
        DeAuditSetupMsg: Label 'DE Audit Setup must be entered through Action Additional setup in POS Audit Profiles.';
    begin
        if not Initialized then begin
            if not POSAuditProfile.Get(POSAuditProfileCode) then
                exit(false);
            if POSAuditProfile."Audit Handler" <> HandlerCode() then
                exit(false);
            if not DEAuditSetup.Get() then
                Message(DeAuditSetupMsg);
            Initialized := true;
            Enabled := true;
        end;
        exit(Enabled);
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR POS Audit Profiles", 'OnHandlePOSAuditProfileAdditionalSetup', '', true, true)]
    local procedure OnHandlePOSAuditProfileAdditionalSetup(POSAuditProfile: Record "NPR POS Audit Profile")
    begin
        if not IsEnabled(POSAuditProfile.Code) then
            exit;
        Page.Run(Page::"NPR DE Audit Setup");
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnLookupAuditHandler', '', true, true)]
    local procedure OnLookupAuditHandler(var tmpRetailList: Record "NPR Retail List" temporary)
    begin
        tmpRetailList.Number += 1;
        tmpRetailList.Choice := HandlerCode();
        tmpRetailList.Insert;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnHandleAuditLogBeforeInsert', '', true, true)]
    local procedure OnHandleAuditLogBeforeInsert(var POSAuditLog: Record "NPR POS Audit Log")
    var
        POSUnitAux: Record "NPR DE POS Unit Aux. Info";
        POSUnit: Record "NPR POS Unit";
        DeAuditAux: Record "NPR DE POS Audit Log Aux. Info";
    begin
        if (POSAuditLog."Active POS Unit No." = '') then
            POSAuditLog."Active POS Unit No." := POSAuditLog."Acted on POS Unit No.";
        if not POSUnitAux.Get(POSAuditLog."Active POS Unit No.") then
            exit;
        if not IsEnabled(POSUnit."POS Audit Profile") then
            exit;

        if (POSAuditLog."Action Type" = POSAuditLog."Action Type"::DIRECT_SALE_END) then begin
            InitDeAuxInfo(DeAuditAux, POSUnitAux, POSAuditLog);
            OnHandleDEAuditAuxLogBeforeInsert(DeAuditAux);
            DeAuditAux.Insert();
        end;
    end;

    // Insert the workflow step in  POS Workflows
    [EventSubscriber(ObjectType::Table, 6150730, 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "NPR POS Sales Workflow Step"; RunTrigger: Boolean)
    var
        Text000: Label 'Create Sales in DE Fiskaly';
    begin
        if Rec."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;
        if Rec."Subscriber Function" <> 'CreateDeFiskalyOnSale' then
            exit;

        Rec.Description := Text000;
        Rec."Sequence No." := 10;
    end;

    // The methods subscribes to event posted during end of sale
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnFinishSale', '', true, true)]
    local procedure CreateDeFiskalyOnSale(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SalePOS: Record "NPR Sale POS")
    var
        PosEntry: Record "NPR POS Entry";
        DEAuditSetup: Record "NPR DE Audit Setup";
        POSUnitAux: Record "NPR DE POS Unit Aux. Info";
        DeAuditAux: Record "NPR DE POS Audit Log Aux. Info";
        DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
        DocumentJson: JsonObject;
        ResponseJson: JsonObject;
        StrOut: OutStream;
    begin
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;
        if POSSalesWorkflowStep."Subscriber Function" <> 'CreateDeFiskalyOnSale' then
            exit;

        PosEntry.SetFilter("Document No.", '=%1', SalePOS."Sales Ticket No.");
        PosEntry.SetFilter("POS Unit No.", '%1', SalePOS."Register No.");
        if (not PosEntry.FindFirst()) then
            exit;

        if PosEntry."Entry Type" <> PosEntry."Entry Type"::"Direct Sale" then
            exit;

        CreateDocumentJson(PosEntry."Entry No.", POSUnitAux, DocumentJson);

        if not DEFiskalyCommunication.SendDocument(DeAuditAux, DocumentJson, ResponseJson, DEAuditSetup) then begin
            DeAuditAux."Error Message".CreateOutStream(StrOut, TextEncoding::UTF8);
            StrOut.Write(GetLastErrorText);
        end
        else
            DeAuxInfoInsertResponse(DeAuditAux, ResponseJson);

        OnHandleDEAuditAuxLogBeforeModify(DeAuditAux, ResponseJson);
        DeAuditAux.Modify();
        DEAuditSetup.Modify();
    end;

    procedure CreateDocumentJson(POSEntryNo: Integer; POSUnitAudit: Record "NPR DE POS Unit Aux. Info"; var DocumentJson: JsonObject)
    var
        StandardJson: JsonObject;
        ReceiptJson: JsonObject;
        ReceiptDataJson: JsonObject;
    begin
        ReceiptDataJson.Add('receipt_type', 'RECEIPT');
        ReceiptDataJson.Add('amounts_per_vat_rate', GetVatRates(POSEntryNo));
        ReceiptDataJson.Add('amounts_per_payment_type', GetPaymentTypes(POSEntryNo));
        ReceiptJson.Add('receipt', ReceiptDataJson);
        StandardJson.Add('standard_v1', ReceiptJson);
        DocumentJson.Add('schema', StandardJson);
        DocumentJson.Add('state', 'FINISHED');
        DocumentJson.Add('client_id', Format(POSUnitAudit."Client ID", 0, 4));
    end;

    local procedure GetVatRates(EntryNo: Integer) TaxArray: JsonArray
    var
        TaxAmountLine: Record "NPR POS Tax Amount Line";
        TaxMapper: Record "NPR VAT Prod Post Group Mapper";
        TaxJsonObject: JsonObject;
    begin
        TaxAmountLine.Reset();
        TaxAmountLine.SetRange("POS Entry No.", EntryNo);
        if TaxAmountLine.FindSet() then
            repeat
                TaxMapper.Get(TaxAmountLine."VAT Identifier");
                TaxJsonObject.Add('vat_rate', TaxMapper."Fiscal Name");
                TaxJsonObject.Add('amount', Format(TaxAmountLine."Amount Including Tax", 0, '<Precision,2:26><Standard Format,2>'));
                TaxArray.Add(TaxJsonObject);
            until TaxAmountLine.Next() = 0;
    end;

    local procedure GetPaymentTypes(EntryNo: Integer) PaymentArray: JsonArray
    var
        PaymentLine: Record "NPR POS Payment Line";
        PaymentMapper: Record "NPR Payment Method Mapper";
        PaymentJsonObject: JsonObject;
    begin
        PaymentLine.Reset();
        PaymentLine.SetRange("POS Entry No.", EntryNo);
        if PaymentLine.FindSet() then
            repeat
                PaymentMapper.Get(PaymentLine."POS Payment Method Code");
                PaymentJsonObject.Add('payment_type', PaymentMapper."Fiscal Name");
                PaymentJsonObject.Add('amount', Format(PaymentLine.Amount, 0, '<Precision,2:26><Standard Format,2>'));
                PaymentJsonObject.Add('currency_code', PaymentLine."Currency Code");
                PaymentArray.Add(PaymentJsonObject);
            until PaymentLine.Next() = 0;
    end;

    local procedure InitDeAuxInfo(var DeAuditAux: Record "NPR DE POS Audit Log Aux. Info"; POSUnitAuxPar: Record "NPR DE POS Unit Aux. Info"; POSAuditLog: Record "NPR POS Audit Log")
    var
        Licenseinformation: Codeunit "NPR License Information";
    begin
        DeAuditAux.Init();
        DeAuditAux."POS Entry No." := POSAuditLog."Acted on POS Entry No.";
        DeAuditAux."NPR Version" := CopyStr(Licenseinformation.GetRetailVersion(), 1, MaxStrLen(DeAuditAux."NPR Version"));
        DeAuditAux."TSS ID" := POSUnitAuxPar."TSS ID";
        DeAuditAux."Client ID" := POSUnitAuxPar."Client ID";
        DeAuditAux."Serial Number" := POSUnitAuxPar."Serial Number";
        DeAuditAux."Fiscalization Status" := DeAuditAux."Fiscalization Status"::"Not Fiscalized";
        DeAuditAux."Transaction ID" := CreateGuid();
        DeAuditAux.Error := true;
    end;

    procedure DeAuxInfoInsertResponse(var DeAuditAux: Record "NPR DE POS Audit Log Aux. Info"; ResponseJson: JsonObject)
    var
        TypeHelper: Codeunit "Type Helper";
        ResponseTokenList: List of [JsonToken];
        Token: JsonToken;
        OutStr: OutStream;
    begin
        ResponseTokenList := ResponseJson.Values();
        DeAuditAux."Transaction ID" := ResponseTokenList.Get(17).AsValue().AsText();
        DeAuditAux."Start Time" := TypeHelper.EvaluateUnixTimestamp(ResponseTokenList.Get(2).AsValue().AsBigInteger());
        DeAuditAux."Finish Time" := TypeHelper.EvaluateUnixTimestamp(ResponseTokenList.Get(3).AsValue().AsBigInteger());

        ResponseTokenList.Get(12).SelectToken('timestamp_format', Token);
        DeAuditAux."Time Format" := Token.AsValue().AsText();
        ResponseTokenList.Get(13).SelectToken('counter', Token);
        DeAuditAux."Signature Count" := Token.AsValue().AsInteger();
        ResponseTokenList.Get(13).SelectToken('algorithm', Token);
        DeAuditAux."Signature Algorithm" := Token.AsValue().AsText();
        ResponseTokenList.Get(13).SelectToken('value', Token);
        DeAuditAux.Signature.CreateOutStream(OutStr);
        OutStr.Write(Token.AsValue().AsText());
        ResponseTokenList.Get(13).SelectToken('public_key', Token);
        DeAuditAux."Public Key".CreateOutStream(OutStr);
        OutStr.Write(Token.AsValue().AsText());
        DeAuditAux."QR Data".CreateOutStream(OutStr);
        OutStr.Write(ResponseTokenList.Get(9).AsValue().AsText());

        DeAuditAux."Fiscalization Status" := DeAuditAux."Fiscalization Status"::Fiscalized;
        DeAuditAux.Error := false;
        Clear(DeAuditAux."Error Message");
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnBeforeInitSale', '', false, false)]
    local procedure OnBeforeLogin(SaleHeader: Record "NPR Sale POS"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
        POSStore: Record "NPR POS Store";
        DEAuditSetup: Record "NPR DE Audit Setup";
        POSEndofDayProfile: Record "NPR POS End of Day Profile";
        POSAuditProfile: Record "NPR POS Audit Profile";
        CompanyInformation: Record "Company Information";
        POSUnitAudit: Record "NPR DE POS Unit Aux. Info";
        NoApiKeyLbl: Label 'Fiskaly Api Key must be entered in DE Audit Setup.';
        NoApiSecretLbl: Label 'Fiskaly Api Secret must be entered in DE Audit Setup.';
    begin
        //Error upon POS login if any configuration is missing or clearly not set according to compliance

        FrontEnd.GetSession(POSSession);
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        if not IsEnabled(POSUnit."POS Audit Profile") then
            exit;

        POSUnitAudit.Get(POSUnit."No.");
        POSUnitAudit.TestField("TSS ID");
        POSUnitAudit.TestField("Client ID");
        POSUnitAudit.TestField("Serial Number");

        DEAuditSetup.Get();
        DEAuditSetup.TestField("Api URL");
        if not DEAuditSetup.HasApiKey() then
            Error(NoApiKeyLbl);
        if not DEAuditSetup.HasApiSecret() then
            Error(NoApiSecretLbl);

        POSAuditProfile.Get(POSUnit."POS Audit Profile");
        POSAuditProfile.TestField("Sale Fiscal No. Series");
        POSAuditProfile.TestField("Credit Sale Fiscal No. Series");
        POSAuditProfile.TestField("Balancing Fiscal No. Series");
        POSAuditProfile.TestField("Fill Sale Fiscal No. On", POSAuditProfile."Fill Sale Fiscal No. On"::Successful);
        POSAuditProfile.TestField("Print Receipt On Sale Cancel", false);

        if POSEndofDayProfile.Get(POSUnit."POS End of Day Profile") then begin
            POSEndofDayProfile.TestField(POSEndofDayProfile."End of Day Type", POSEndofDayProfile."End of Day Type"::INDIVIDUAL);
        end;

        POSStore.Get(POSUnit."POS Store Code");
        POSStore.TestField("Registration No.");
        POSStore.TestField("Country/Region Code");

        CompanyInformation.Get();
        CompanyInformation.TestField("VAT Registration No.");
        CheckJobQueue();
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR DE Audit Mgt.");
    end;

    local procedure CheckJobQueue()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.Reset();
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR DE Fiskaly Job");
        JobQueueEntry.FindFirst();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnHandleDEAuditAuxLogBeforeInsert(var DEPOSAuditAuxLog: Record "NPR DE POS Audit Log Aux. Info")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnHandleDEAuditAuxLogBeforeModify(var DEPOSAuditAuxLog: Record "NPR DE POS Audit Log Aux. Info"; ResponseJson: JsonObject)
    begin
    end;

    var
        DEAuditSetup: Record "NPR DE Audit Setup";
        Initialized: Boolean;
        Enabled: Boolean;
}