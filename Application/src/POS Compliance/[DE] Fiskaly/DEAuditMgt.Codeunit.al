codeunit 6014444 "NPR DE Audit Mgt."
{
    Access = Internal;
    SingleInstance = true;

    procedure HandlerCode(): Code[20]
    begin
        exit('DE_FISKALY');
    end;

    local procedure IsEnabled(POSAuditProfileCode: Code[20]): Boolean
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
    begin
        if not POSAuditProfile.Get(POSAuditProfileCode) then
            exit(false);
        exit(IsEnabled(POSAuditProfile));
    end;

    local procedure IsEnabled(POSAuditProfile: Record "NPR POS Audit Profile"): Boolean
    begin
        exit(POSAuditProfile."Audit Handler" = HandlerCode());
    end;

    procedure ShouldDisplayNotification(POSAuditProfile: Record "NPR POS Audit Profile"; xPOSAuditProfile: Record "NPR POS Audit Profile"): Boolean
    var
        DEPosUnitSetup: Record "NPR DE POS Unit Aux. Info";
    begin
        if not IsEnabled(POSAuditProfile) then
            exit(false);
        if POSAuditProfile."Audit Handler" = xPOSAuditProfile."Audit Handler" then
            exit(false);
        exit(DEPosUnitSetup.IsEmpty());
    end;

    procedure OnActionShowSetup()
    begin
        Page.RunModal(Page::"NPR DE POS Unit Aux. Info List");
    end;

    procedure OnActionLearnMore()
    var
        LearnMoreLinkLbl: Label 'https://docs.navipartner.com/docs/fiscalization/germany/how-to/setup';
    begin
        Hyperlink(LearnMoreLinkLbl);
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR POS Audit Profiles", 'OnHandlePOSAuditProfileAdditionalSetup', '', true, true)]
    local procedure OnHandlePOSAuditProfileAdditionalSetup(POSAuditProfile: Record "NPR POS Audit Profile")
    begin
        if not IsEnabled(POSAuditProfile) then
            exit;
        OnActionShowSetup();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnLookupAuditHandler', '', true, true)]
    local procedure OnLookupAuditHandler(var tmpRetailList: Record "NPR Retail List" temporary)
    begin
        tmpRetailList.Number += 1;
        tmpRetailList.Choice := CopyStr(HandlerCode(), 1, MaxStrLen(tmpRetailList.Choice));
        tmpRetailList.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnHandleAuditLogBeforeInsert', '', true, true)]
    local procedure OnHandleAuditLogBeforeInsert(var POSAuditLog: Record "NPR POS Audit Log")
    var
        DeAuditAux: Record "NPR DE POS Audit Log Aux. Info";
        POSUnitAux: Record "NPR DE POS Unit Aux. Info";
        POSUnit: Record "NPR POS Unit";
        DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
    begin
        if (POSAuditLog."Active POS Unit No." = '') then
            POSAuditLog."Active POS Unit No." := POSAuditLog."Acted on POS Unit No.";
        if not POSUnitAux.Get(POSAuditLog."Active POS Unit No.") then
            exit;
        if not POSUnit.Get(POSAuditLog."Active POS Unit No.") then
            exit;
        if not IsEnabled(POSUnit."POS Audit Profile") then
            exit;

        case POSAuditLog."Action Type" of
            POSAuditLog."Action Type"::DIRECT_SALE_END:
                begin
                    InitDeAuxInfo(DeAuditAux, POSUnitAux, POSAuditLog, Enum::"NPR DE Fiskaly Receipt Type"::RECEIPT);
                    OnHandleDEAuditAuxLogBeforeInsert(DeAuditAux);
                    DeAuditAux.Insert(true);
                    DEFiskalyCommunication.SendDocument(DeAuditAux);
                end;
            POSAuditLog."Action Type"::CANCEL_SALE_END:
                begin
                    InitDeAuxInfo(DeAuditAux, POSUnitAux, POSAuditLog, Enum::"NPR DE Fiskaly Receipt Type"::CANCELLATION);
                    OnHandleDEAuditAuxLogBeforeInsert(DeAuditAux);
                    DeAuditAux.Insert(true);
                    DEFiskalyCommunication.SendDocument(DeAuditAux);
                end;
        end;
    end;

    procedure CreateDeFiskalyOnSale(SalePOS: Record "NPR POS Sale")
    var
        DeAuditAux: Record "NPR DE POS Audit Log Aux. Info";
        PosAuditProfile: Record "NPR POS Audit Profile";
        PosEntry: Record "NPR POS Entry";
        PosUnit: Record "NPR POS Unit";
        DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
    begin
        if not PosUnit.Get(SalePOS."Register No.") then
            exit;
        if not PosUnit.GetProfile(PosAuditProfile) then
            exit;
        if not IsEnabled(PosAuditProfile) then
            exit;

        PosEntry.SetCurrentKey("Document No.");
        PosEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        PosEntry.SetRange("POS Unit No.", SalePOS."Register No.");
        if not PosEntry.FindFirst() then
            exit;
        if not (PosEntry."Entry Type" in [PosEntry."Entry Type"::"Direct Sale", PosEntry."Entry Type"::"Cancelled Sale"]) then
            exit;
        if not DeAuditAux.Get(PosEntry."Entry No.") then
            exit;

        DEFiskalyCommunication.SendDocument(DeAuditAux);
    end;

    procedure CreateDocumentJson(var DeAuditAux: Record "NPR DE POS Audit Log Aux. Info"; NewTransactionState: Enum "NPR DE Fiskaly Trx. State"; var DocumentJson: JsonObject)
    var
        ReceiptDataJson: JsonObject;
        ReceiptJson: JsonObject;
        StandardJson: JsonObject;
    begin
        if DeAuditAux."Fiskaly Transaction Type" = DeAuditAux."Fiskaly Transaction Type"::Unknown then
            DeAuditAux."Fiskaly Transaction Type" := DeAuditAux."Fiskaly Transaction Type"::RECEIPT;
        ReceiptDataJson.Add('receipt_type',
            Enum::"NPR DE Fiskaly Receipt Type".Names().Get(Enum::"NPR DE Fiskaly Receipt Type".Ordinals().IndexOf(DeAuditAux."Fiskaly Transaction Type".AsInteger())));
        ReceiptDataJson.Add('amounts_per_vat_rate', GetVatRates(DeAuditAux."POS Entry No."));
        ReceiptDataJson.Add('amounts_per_payment_type', GetPaymentTypes(DeAuditAux."POS Entry No."));
        ReceiptJson.Add('receipt', ReceiptDataJson);
        StandardJson.Add('standard_v1', ReceiptJson);
        DocumentJson.Add('schema', StandardJson);
        DocumentJson.Add('state', Enum::"NPR DE Fiskaly Trx. State".Names().Get(Enum::"NPR DE Fiskaly Trx. State".Ordinals().IndexOf(NewTransactionState.AsInteger())));
        DocumentJson.Add('client_id', Format(DeAuditAux."Client ID", 0, 4));
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
                TaxMapper.SetRange("VAT Identifier", TaxAmountLine."VAT Identifier");
                TaxMapper.FindFirst();
                TaxJsonObject.Add('vat_rate', Enum::"NPR DE Fiskaly VAT Rate".Names().Get(Enum::"NPR DE Fiskaly VAT Rate".Ordinals().IndexOf(TaxMapper."Fiskaly VAT Rate Type".AsInteger())));
                TaxJsonObject.Add('amount', Format(TaxAmountLine."Amount Including Tax", 0, '<Precision,2:5><Standard Format,2>'));
                TaxArray.Add(TaxJsonObject);
            until TaxAmountLine.Next() = 0;
    end;

    local procedure GetPaymentTypes(EntryNo: Integer) PaymentArray: JsonArray
    var
        PaymentMapper: Record "NPR Payment Method Mapper";
        PaymentLine: Record "NPR POS Entry Payment Line";
        PaymentJsonObject: JsonObject;
    begin
        PaymentLine.Reset();
        PaymentLine.SetRange("POS Entry No.", EntryNo);
        if PaymentLine.FindSet() then
            repeat
                Clear(PaymentJsonObject);
                PaymentMapper.Get(PaymentLine."POS Payment Method Code");
                PaymentJsonObject.Add('payment_type', Enum::"NPR DE Fiskaly Payment Type".Names().Get(Enum::"NPR DE Fiskaly Payment Type".Ordinals().IndexOf(PaymentMapper."Fiskaly Payment Type".AsInteger())));
                PaymentJsonObject.Add('amount', Format(PaymentLine.Amount, 0, '<Precision,2:26><Standard Format,2>'));
                if PaymentLine."Currency Code" <> '' then
                    PaymentJsonObject.Add('currency_code', PaymentLine."Currency Code");
                PaymentArray.Add(PaymentJsonObject);
            until PaymentLine.Next() = 0;
    end;

    local procedure InitDeAuxInfo(var DeAuditAux: Record "NPR DE POS Audit Log Aux. Info"; POSUnitAuxPar: Record "NPR DE POS Unit Aux. Info"; POSAuditLog: Record "NPR POS Audit Log"; FiskalyTransactionType: Enum "NPR DE Fiskaly Receipt Type")
    var
        Licenseinformation: Codeunit "NPR License Information";
    begin
        DeAuditAux.Init();
        DeAuditAux."POS Entry No." := POSAuditLog."Acted on POS Entry No.";
        DeAuditAux."NPR Version" := CopyStr(Licenseinformation.GetRetailVersion(), 1, MaxStrLen(DeAuditAux."NPR Version"));
        DeAuditAux.Validate("TSS Code", POSUnitAuxPar."TSS Code");
        DeAuditAux."Client ID" := POSUnitAuxPar.SystemId;
        DeAuditAux."Serial Number" := POSUnitAuxPar."Serial Number";
        DeAuditAux."Fiskaly Transaction Type" := FiskalyTransactionType;
        DeAuditAux."Transaction ID" := POSAuditLog."Active POS Sale SystemId";
        if IsNullGuid(DeAuditAux."Transaction ID") then
            DeAuditAux."Transaction ID" := CreateGuid();
        DeAuditAux."Has Error" := true;
    end;

    [TryFunction]
    procedure DeAuxInfoInsertResponse(var DeAuditAux: Record "NPR DE POS Audit Log Aux. Info"; ResponseJson: JsonToken)
    var
        xDeAuditAux: Record "NPR DE POS Audit Log Aux. Info";
        DETSS: Record "NPR DE TSS";
        TypeHelper: Codeunit "Type Helper";
        Token: JsonToken;
        UnexpectedResponseJsonErr: Label 'Unexpected response json.\%1';
        OutStr: OutStream;
        State: Text;
    begin
        if not ResponseJson.IsObject() then
            Error(UnexpectedResponseJsonErr, ResponseJson);

        xDeAuditAux := DeAuditAux;
        DeAuditAux.Init();
        DeAuditAux."POS Entry No." := xDeAuditAux."POS Entry No.";
        DeAuditAux."NPR Version" := xDeAuditAux."NPR Version";
        DeAuditAux."Fiskaly Transaction Type" := xDeAuditAux."Fiskaly Transaction Type";
        if not IsNullGuid(xDeAuditAux.SystemId) then
            DeAuditAux.SystemId := xDeAuditAux.SystemId;

        ResponseJson.SelectToken('_id', Token);
        DeAuditAux."Transaction ID" := Token.AsValue().AsText();

        ResponseJson.SelectToken('tss_id', Token);
        DeAuditAux."TSS ID" := Token.AsValue().AsText();
        if DETSS.GetBySystemId(DeAuditAux."TSS ID") then
            DeAuditAux."TSS Code" := DETSS.Code;

        ResponseJson.SelectToken('client_id', Token);
        DeAuditAux.Validate("Client ID", Token.AsValue().AsText());

        ResponseJson.SelectToken('state', Token);
        State := Token.AsValue().AsText();
        if not Enum::"NPR DE Fiskaly Trx. State".Names().Contains(State) then
            DeAuditAux."Fiskaly Transaction State" := DeAuditAux."Fiskaly Transaction State"::Unknown
        else
            DeAuditAux."Fiskaly Transaction State" := Enum::"NPR DE Fiskaly Trx. State".FromInteger(Enum::"NPR DE Fiskaly Trx. State".Ordinals().Get(Enum::"NPR DE Fiskaly Trx. State".Names().IndexOf(State)));

        ResponseJson.SelectToken('latest_revision', Token);
        DeAuditAux."Latest Revision" := Token.AsValue().AsInteger();

        ResponseJson.SelectToken('time_start', Token);
        DeAuditAux."Start Time" := TypeHelper.EvaluateUnixTimestamp(Token.AsValue().AsBigInteger());
        if ResponseJson.SelectToken('time_end', Token) then
            DeAuditAux."Finish Time" := TypeHelper.EvaluateUnixTimestamp(Token.AsValue().AsBigInteger());
        if ResponseJson.SelectToken('log.timestamp_format', Token) then
            DeAuditAux."Time Format" := CopyStr(Token.AsValue().AsText(), 1, MaxStrLen(DeAuditAux."Time Format"));

        if ResponseJson.SelectToken('signature.counter', Token) then
            DeAuditAux."Signature Count" := Token.AsValue().AsInteger();
        if ResponseJson.SelectToken('signature.algorithm', Token) then
            DeAuditAux."Signature Algorithm" := CopyStr(Token.AsValue().AsText(), 1, MaxStrLen(DeAuditAux."Signature Algorithm"));
        if ResponseJson.SelectToken('signature.value', Token) then begin
            DeAuditAux.Signature.CreateOutStream(OutStr);
            OutStr.Write(Token.AsValue().AsText());
        end;
        if ResponseJson.SelectToken('signature.public_key', Token) then begin
            DeAuditAux."Public Key".CreateOutStream(OutStr);
            OutStr.Write(Token.AsValue().AsText());
        end;

        if ResponseJson.SelectToken('qr_code_data', Token) then begin
            DeAuditAux."QR Data".CreateOutStream(OutStr);
            OutStr.Write(Token.AsValue().AsText());
        end;

        if DeAuditAux."Fiskaly Transaction State" in [DeAuditAux."Fiskaly Transaction State"::FINISHED, DeAuditAux."Fiskaly Transaction State"::CANCELLED] then
            DeAuditAux."Fiscalization Status" := DeAuditAux."Fiscalization Status"::Fiscalized
        else
            DeAuditAux."Fiscalization Status" := DeAuditAux."Fiscalization Status"::"Transaction Started";
        DeAuditAux."Has Error" := false;

        OnHandleDEAuditAuxLogBeforeModify(DeAuditAux, ResponseJson);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnBeforeInitSale', '', false, false)]
    local procedure OnBeforeLogin(SaleHeader: Record "NPR POS Sale"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        CompanyInformation: Record "Company Information";
        POSUnitAudit: Record "NPR DE POS Unit Aux. Info";
        DETSS: Record "NPR DE TSS";
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSEndofDayProfile: Record "NPR POS End of Day Profile";
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        DESecretMgt: Codeunit "NPR DE Secret Mgt.";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
        MissingConnectionParameterErr: Label 'Please specify %1 in %2 %3=%4 and then try again.', Comment = '%1 - missing parameter name, %2 - "NPR DE Audit Setup" table caption, %3 - "NPR DE Audit Setup" table primary key field caption, %4 - "NPR DE Audit Setup" table primary key field value';
        ParameterFieldCaptionsLbl: Label 'Api Key,Api Secret';
    begin
        //Error upon POS login if any configuration is missing or clearly not set according to compliance

        FrontEnd.GetSession(POSSession);
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        if not IsEnabled(POSUnit."POS Audit Profile") then
            exit;

        POSUnitAudit.Get(POSUnit."No.");
        POSUnitAudit.TestField(SystemId);
        POSUnitAudit.TestField("Serial Number");
        POSUnitAudit.TestField("TSS Code");
        POSUnitAudit.TestField("Fiskaly Client Created at");

        DETSS.Get(POSUnitAudit."TSS Code");
        DETSS.TestField(SystemId);
        DETSS.TestField("Fiskaly TSS Created at");
        DETSS.TestField("Connection Parameter Set Code");

        DEConnectionParameterSet.Get(DETSS."Connection Parameter Set Code");
        DEConnectionParameterSet.TestField("Api URL");
        if not DESecretMgt.HasSecretKey(DEConnectionParameterSet.ApiKeyLbl()) then
            Error(MissingConnectionParameterErr, SelectStr(1, ParameterFieldCaptionsLbl), DEConnectionParameterSet.TableCaption(), DEConnectionParameterSet.FieldCaption("Primary Key"), DEConnectionParameterSet."Primary Key");
        if not DESecretMgt.HasSecretKey(DEConnectionParameterSet.ApiSecretLbl()) then
            Error(MissingConnectionParameterErr, SelectStr(2, ParameterFieldCaptionsLbl), DEConnectionParameterSet.TableCaption(), DEConnectionParameterSet.FieldCaption("Primary Key"), DEConnectionParameterSet."Primary Key");

        POSAuditProfile.Get(POSUnit."POS Audit Profile");
        POSAuditProfile.TestField("Sale Fiscal No. Series");
        POSAuditProfile.TestField("Credit Sale Fiscal No. Series");
        POSAuditProfile.TestField("Balancing Fiscal No. Series");
        POSAuditProfile.TestField("Fill Sale Fiscal No. On", POSAuditProfile."Fill Sale Fiscal No. On"::Successful);
        POSAuditProfile.TestField("Print Receipt On Sale Cancel", false);
        POSAuditProfile.TestField("Do Not Print Receipt on Sale", false);

        if POSEndofDayProfile.Get(POSUnit."POS End of Day Profile") then
            POSEndofDayProfile.TestField(POSEndofDayProfile."End of Day Type", POSEndofDayProfile."End of Day Type"::INDIVIDUAL);

        POSStore.Get(POSUnit."POS Store Code");
        POSStore.TestField("Registration No.");
        POSStore.TestField("Country/Region Code");

        CompanyInformation.Get();
        CompanyInformation.TestField("VAT Registration No.");
        CheckTssJobQueue();
        CheckDSFINVKJobQueue();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workshift Checkpoint", 'OnAfterEndWorkshift', '', true, true)]
    local procedure OnAfterEndWorkshiftDeFiscaly(Mode: Option; UnitNo: Code[10]; Successful: Boolean; PosEntryNo: Integer)
    begin
        DoEndWorkshiftDeFiscaly(UnitNo, Successful, PosEntryNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR End Of Day UI Handler", 'OnAfterZReport', '', true, true)]
    local procedure NPREndOfDayUIHandlerOnAfterZReport(UnitNo: Code[10]; Successful: Boolean; PosEntryNo: Integer)
    begin
        DoEndWorkshiftDeFiscaly(UnitNo, Successful, PosEntryNo);
    end;

    local procedure CheckTssJobQueue()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        JobDescLbl: Label 'Auto-created for sending Fiskaly', Locked = true;
    begin
        JobQueueEntry.Reset();
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR DE Fiskaly Job");
        if JobQueueEntry.FindFirst() then
            exit;

        if JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            Codeunit::"NPR DE Fiskaly Job",
            '',
            JobDescLbl,
            CurrentDateTime(),
            10,
            '',
            JobQueueEntry)
        then
            JobQueueMgt.StartJobQueueEntry(JobQueueEntry);
    end;

    local procedure CheckDSFINVKJobQueue()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        JobDescLbl: Label 'Auto-created for sending DSFINVK', Locked = true;
    begin
        JobQueueEntry.Reset();
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR DE Fiskaly DSFINVK Job");
        if JobQueueEntry.FindFirst() then
            exit;

        if JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            Codeunit::"NPR DE Fiskaly DSFINVK Job",
            '',
            JobDescLbl,
            CurrentDateTime(),
            10,
            '',
            JobQueueEntry)
        then
            JobQueueMgt.StartJobQueueEntry(JobQueueEntry);
    end;

    local procedure DoEndWorkshiftDeFiscaly(UnitNo: Code[10]; Successful: Boolean; PosEntryNo: Integer)
    var
        ConnectionParameters: Record "NPR DE Audit Setup";
        DSFINVKClosing: Record "NPR DSFINVK Closing";
        POSUnit: Record "NPR POS Unit";
        POSWorkshifCheckpoint: Record "NPR POS Workshift Checkpoint";
        DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
        DSFINVKMng: Codeunit "NPR DE Fiskaly DSFINVK";
        NextClosingId: Integer;
        DSFINVKJson: JsonObject;
        DSFINVKResponseJson: JsonToken;
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

        if not ConnectionParameters.GetSetup(DSFINVKClosing) then begin
            SetDSFINVKErrorMsg(DSFINVKClosing);
            exit;
        end;

        if not DSFINVKMng.CreateDSFINVKDocument(DSFINVKJson, DSFINVKClosing) then begin
            SetDSFINVKErrorMsg(DSFINVKClosing);
            exit;
        end;

        DSFINVKClosing."Closing ID" := CreateGuid(); //Fiskaly does not allow update of Cash Point Closings
        if not DEFiskalyCommunication.SendRequest_DSFinV_K(DSFINVKJson, DSFINVKResponseJson, ConnectionParameters, 'PUT', '/cash_point_closings/' + Format(DSFINVKClosing."Closing ID", 0, 4)) then begin
            SetDSFINVKErrorMsg(DSFINVKClosing);
            exit;
        end;
        DSFINVKClosing.State := DSFINVKClosing.State::PENDING;
        DSFINVKClosing."Has Error" := false;
        Clear(DSFINVKClosing."Error Message");
        DSFINVKClosing.Modify();
    end;

    procedure SetErrorMsg(var DeAuditAux: Record "NPR DE POS Audit Log Aux. Info")
    var
        StrOut: OutStream;
    begin
        DeAuditAux."Error Message".CreateOutStream(StrOut, TextEncoding::UTF8);
        StrOut.Write(GetLastErrorText);
        DeAuditAux."Has Error" := true;
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
    local procedure OnHandleDEAuditAuxLogBeforeModify(var DEPOSAuditAuxLog: Record "NPR DE POS Audit Log Aux. Info"; ResponseJson: JsonToken)
    begin
    end;

    var
        DEConnectionParameterSet: Record "NPR DE Audit Setup";
}
