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
        tmpRetailList.Insert();
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
        if not POSUnit.Get(POSAuditLog."Active POS Unit No.") then
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
    local procedure CreateDeFiskalyOnSale(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SalePOS: Record "NPR POS Sale")
    var
        PosEntry: Record "NPR POS Entry";
        NPRDEAuditSetup: Record "NPR DE Audit Setup";
        POSUnitAux: Record "NPR DE POS Unit Aux. Info";
        DeAuditAux: Record "NPR DE POS Audit Log Aux. Info";
        DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
        DocumentJson: JsonObject;
        ResponseJson: JsonObject;
    begin
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;
        if POSSalesWorkflowStep."Subscriber Function" <> 'CreateDeFiskalyOnSale' then
            exit;

        PosEntry.SetFilter("Document No.", '=%1', SalePOS."Sales Ticket No.");
        PosEntry.SetFilter("POS Unit No.", '%1', SalePOS."Register No.");
        if (not PosEntry.FindFirst()) then
            exit;
        IF NOT POSUnitAux.GET(PosEntry."POS Unit No.") THEN
            EXIT;
        IF NOT DeAuditAux.GET(PosEntry."Entry No.") THEN
            EXIT;
        IF NOT NPRDEAuditSetup.GET() THEN
            EXIT;

        if PosEntry."Entry Type" <> PosEntry."Entry Type"::"Direct Sale" then
            exit;

        CreateDocumentJson(PosEntry."Entry No.", POSUnitAux, DocumentJson);

        if not DEFiskalyCommunication.SendDocument(DeAuditAux, DocumentJson, ResponseJson, NPRDEAuditSetup) then
            SetErrorMsg(DeAuditAux)
        else
            if not DeAuxInfoInsertResponse(DeAuditAux, ResponseJson) then
                SetErrorMsg(DeAuditAux);

        OnHandleDEAuditAuxLogBeforeModify(DeAuditAux, ResponseJson);
        DeAuditAux.Modify();
        NPRDEAuditSetup.Modify();
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
        TaxAmountLine: Record "NPR POS Entry Tax Line";
        TaxMapper: Record "NPR VAT Post. Group Mapper";
        TaxJsonObject: JsonObject;
    begin
        TaxAmountLine.Reset();
        TaxAmountLine.SetRange("POS Entry No.", EntryNo);
        if TaxAmountLine.FindSet() then
            repeat
                Clear(TaxJsonObject);
                TaxMapper.RESET();
                TaxMapper.SETRANGE("VAT Identifier", TaxAmountLine."VAT Identifier");
                TaxMapper.FINDFIRST();
                TaxJsonObject.Add('vat_rate', TaxMapper."Fiscal Name");
                TaxJsonObject.Add('amount', Format(TaxAmountLine."Amount Including Tax", 0, '<Precision,2:26><Standard Format,2>'));
                TaxArray.Add(TaxJsonObject);
            until TaxAmountLine.Next() = 0;
    end;

    local procedure GetPaymentTypes(EntryNo: Integer) PaymentArray: JsonArray
    var
        PaymentLine: Record "NPR POS Entry Payment Line";
        PaymentMapper: Record "NPR Payment Method Mapper";
        PaymentJsonObject: JsonObject;
    begin
        PaymentLine.Reset();
        PaymentLine.SetRange("POS Entry No.", EntryNo);
        if PaymentLine.FindSet() then
            repeat
                Clear(PaymentJsonObject);
                PaymentMapper.Get(PaymentLine."POS Payment Method Code");
                PaymentJsonObject.Add('payment_type', PaymentMapper."Fiscal Name");
                PaymentJsonObject.Add('amount', Format(PaymentLine.Amount, 0, '<Precision,2:26><Standard Format,2>'));
                if PaymentLine."Currency Code" <> '' then
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
        DeAuditAux."Has Error" := true;
    end;

    [TryFunction]
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
        DeAuditAux."Has Error" := false;
        Clear(DeAuditAux."Error Message");
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnBeforeInitSale', '', false, false)]
    local procedure OnBeforeLogin(SaleHeader: Record "NPR POS Sale"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
        POSStore: Record "NPR POS Store";
        NPRDEAuditSetup: Record "NPR DE Audit Setup";
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

        NPRDEAuditSetup.Get();
        NPRDEAuditSetup.TestField("Api URL");
        if not NPRDEAuditSetup.HasApiKey() then
            Error(NoApiKeyLbl);
        if not NPRDEAuditSetup.HasApiSecret() then
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
        CheckTssJobQueue();
        CheckDSFINVKJobQueue();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workshift Checkpoint", 'OnAfterEndWorkshift', '', true, true)]
    local procedure OnAfterEndWorkshiftDeFiscaly(Mode: Option; UnitNo: Code[20]; Successful: Boolean; PosEntryNo: Integer)
    var
        POSWorkshifCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSUnit: Record "NPR POS Unit";
        DSFINVKClosing: Record "NPR DSFINVK Closing";
        DSFINVKMng: Codeunit "NPR DE Fiskaly DSFINVK";
        DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
        DSFINVKJson: JsonObject;
        DSFINVKResponseJson: JsonObject;
        AccessToken: Text;
        NextClosingId: Integer;
    begin
        if not Successful then
            exit;

        if not POSUnit.Get(UnitNo) then
            exit;

        if not IsEnabled(POSUnit."POS Audit Profile") then
            exit;

        POSWorkshifCheckpoint.Reset();
        POSWorkshifCheckpoint.SetRange("POS Entry No.", PosEntryNo);
        if not POSWorkshifCheckpoint.FindFirst() then
            exit;
        if not (POSWorkshifCheckpoint.Type = POSWorkshifCheckpoint.Type::ZREPORT) then
            exit;

        DSFINVKClosing.Reset();
        DSFINVKClosing.SetRange("POS Unit No.", UnitNo);
        DSFINVKClosing.SetRange("Closing Date", WorkDate());
        if not DSFINVKClosing.FindFirst() then begin
            DSFINVKClosing.LockTable();
            DSFINVKClosing.Reset();
            DSFINVKClosing.SetRange("POS Unit No.", UnitNo);
            if DSFINVKClosing.FindLast() then
                NextClosingId := DSFINVKClosing."DSFINVK Closing No." + 1
            else
                NextClosingId := 1;

            DSFINVKClosing.Init();
            DSFINVKClosing."DSFINVK Closing No." := NextClosingId;
            DSFINVKClosing."POS Unit No." := UnitNo;
            DSFINVKClosing."POS Entry No." := PosEntryNo;
            DSFINVKClosing."Closing Date" := WorkDate();
            DSFINVKClosing.Insert();
        end
        else
            if DSFINVKClosing.State <> DSFINVKClosing.State::" " then
                exit;

        if not DSFINVKMng.CreateDSFINVKDocument(DSFINVKJson, DSFINVKClosing) then begin
            SetDSFINVKErrorMsg(DSFINVKClosing);
            exit;
        end;

        if not GetJwtToken(AccessToken) then begin
            SetDSFINVKErrorMsg(DSFINVKClosing);
            exit;
        end;

        DSFINVKClosing."Closing ID" := CreateGuid(); //Fiskaly does not allow update of Cash Point Closings 
        if not DEFiskalyCommunication.SendDSFINVK(DSFINVKJson, DSFINVKResponseJson, DEAuditSetup, 'PUT', '/cash_point_closings/' + Format(DSFINVKClosing."Closing ID", 0, 4), AccessToken) then begin
            SetDSFINVKErrorMsg(DSFINVKClosing);
            exit;
        end;
        DSFINVKClosing.State := DSFINVKClosing.State::PENDING;
        DSFINVKClosing."Has Error" := false;
        Clear(DSFINVKClosing."Error Message");
        DSFINVKClosing.Modify();
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR DE Audit Mgt.");
    end;

    local procedure CheckTssJobQueue()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobDescLbl: Label 'Auto-created for sending Fiskaly', Locked = true;
    begin
        JobQueueEntry.Reset();
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR DE Fiskaly Job");
        if JobQueueEntry.FindFirst() then
            exit;

        JobQueueEntry.InitRecurringJob(10);
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"NPR DE Fiskaly Job";
        JobQueueEntry."User ID" := CopyStr(UserId, 1, 65);
        JobQueueEntry.Description := JobDescLbl;
        JobQueueEntry.Insert(true);
    end;

    local procedure CheckDSFINVKJobQueue()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobDescLbl: Label 'Auto-created for sending DSFINVK', Locked = true;
    begin
        JobQueueEntry.Reset();
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR DE Fiskaly DSFINVK Job");
        if JobQueueEntry.FindFirst() then
            exit;

        JobQueueEntry.InitRecurringJob(10);
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"NPR DE Fiskaly DSFINVK Job";
        JobQueueEntry."User ID" := CopyStr(UserId, 1, 65);
        JobQueueEntry.Description := JobDescLbl;
        JobQueueEntry.Insert(true);
    end;

    procedure GetJwtToken(var AccessTokenPar: Text): Boolean
    var
        FiskalyJWT: Codeunit "NPR FiskalyJWT";
        DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
        RefreshTokenJson: JsonObject;
        JWTResponseJson: JsonObject;
        RefreshToken: Text;
    begin
        if not FiskalyJWT.GetToken(AccessTokenPar, RefreshToken) then begin
            DEAuditSetup.Get();
            if RefreshToken <> '' then
                RefreshTokenJson.Add('refresh_token', RefreshToken)
            else begin
                RefreshTokenJson.Add('api_key', DEAuditSetup.GetApiKey());
                RefreshTokenJson.Add('api_secret', DEAuditSetup.GetApiSecret());
            end;
            if not DEFiskalyCommunication.SendDSFINVK(RefreshTokenJson, JWTResponseJson, DEAuditSetup, 'POST', '/auth', '') then begin
                exit(false);
            end
            else
                FiskalyJWT.SetJWT(JWTResponseJson, AccessTokenPar);
        end;
        exit(true);
    end;

    procedure SetErrorMsg(var DeAuditAux: Record "NPR DE POS Audit Log Aux. Info")
    var
        StrOut: OutStream;
    begin
        DeAuditAux."Error Message".CreateOutStream(StrOut, TextEncoding::UTF8);
        StrOut.Write(GetLastErrorText);
    end;

    procedure SetDSFINVKErrorMsg(var DSFINVKClosing: Record "NPR DSFINVK Closing")
    var
        StrOut: OutStream;
    begin
        DSFINVKClosing."Error Message".CreateOutStream(StrOut, TextEncoding::UTF8);
        StrOut.Write(GetLastErrorText);
        DSFINVKClosing."Has Error" := true;
        Clear(DSFINVKClosing."Closing ID");
        DSFINVKClosing.Modify();
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