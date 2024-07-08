codeunit 6184763 "NPR Vipps Mp Migration"
{
    Access = Internal;

    procedure ClearALLVippsSetup()
    var
        POSPostingSetup: Record "NPR POS Posting Setup";
        POSPaymentMethod: Record "NPR POS Payment Method";
        EFTSetup: Record "NPR EFT Setup";
        VippsMpPaymentSetup: Record "NPR Vipps Mp Payment Setup";
        VippsMpUnitSetup: Record "NPR Vipps Mp Unit Setup";
        VippsMpStore: Record "NPR Vipps Mp Store";
        VippsMpWebhook: Record "NPR Vipps Mp Webhook";
        VippsMpQrCallback: Record "NPR Vipps Mp QrCallback";
        VippsMpWebhookAPI: Codeunit "NPR Vipps Mp Webhook API";
        VippsMpQRAPI: Codeunit "NPR Vipps Mp QR API";
    //Deleted: Integer;
    begin
        POSPostingSetup.SetFilter("POS Payment Method Code", 'VIPPS MP*');
        POSPostingSetup.DeleteAll();
        POSPaymentMethod.SetFilter("Code", 'VIPPS MP*');
        POSPaymentMethod.DeleteAll();
        EFTSetup.SetFilter("EFT Integration Type", 'VIPPS_MOBILEPAY');
        EFTSetup.DeleteAll();
        VippsMpPaymentSetup.DeleteAll();
        VippsMpUnitSetup.DeleteAll();
        while VippsMpWebhook.Next() <> 0 do begin
            Clear(VippsMpStore);
            VippsMpStore.SetFilter("Webhook Reference", VippsMpWebhook."Webhook Reference");
            if (VippsMpStore.FindFirst()) then begin
                if (VippsMpWebhookAPI.DeleteWebhook(VippsMpWebhook."Webhook Id", VippsMpStore)) then begin

                end;
            end;
            VippsMpWebhook.Delete();
        end;
        while VippsMpQrCallback.Next() <> 0 do begin
            Clear(VippsMpStore);
            if (VippsMpStore.Get(VippsMpQrCallback."Merchant Serial Number")) then begin
                if (not VippsMpQRAPI.DeleteCallbackQr(VippsMpStore, VippsMpQrCallback."Merchant Qr Id")) then begin

                end;
            end;
            VippsMpQrCallback.Delete();
        end;
        //BeforeDelete Use for clear
        VippsMpStore.DeleteAll();
    end;

    procedure MigrateMobilepaytoVipps()
    var
        CurrentEFTSetup: Record "NPR EFT Setup";
        VippsMpUnitSetup: Record "NPR Vipps Mp Unit Setup";
        VippsMpStore: Record "NPR Vipps Mp Store";
        EftSetupMapOldToNew: Dictionary of [Code[10], Code[10]];
        PayTypePos: Code[10];
        PaymentTypePosNo: Text;
        MobilpeyaSetupErr: Text;
        I: Integer;
        StoreIdToMsnMapning: JsonObject;
    begin
        //Get all Mobilepay setups
        CurrentEFTSetup.SetRange("EFT Integration Type", 'MOBILEPAY_V10');
        if (CurrentEFTSetup.Count() = 0) then begin
            Message('No Mobilepay V10 integrations found.');
            exit;
        end;
        if (not ValidateMobilepayV10Setup(MobilpeyaSetupErr)) then begin
            Message(MobilpeyaSetupErr);
            exit;
        end;
        GetMapningsDictionary(StoreIdToMsnMapning);

        //Explicit empty string, so names will be: "VIPPS MP", "VIPPS MP1"...
        PaymentTypePosNo := '';
        //Create Names for payment methods.
        while CurrentEFTSetup.Next() <> 0 do begin
            if (not EftSetupMapOldToNew.ContainsKey(CurrentEFTSetup."Payment Type POS")) then begin
                EftSetupMapOldToNew.Add(CurrentEFTSetup."Payment Type POS", 'VIPPS MP' + PaymentTypePosNo);
                I := I + 1;
                PaymentTypePosNo := Format(I);
            end;
        end;
        //Create duplicate records using Payment Type Pos.
        foreach PayTypePos in EftSetupMapOldToNew.Keys() do begin
            PaymentTypePosDuplicate(PayTypePos, EftSetupMapOldToNew.Get(PayTypePos));
            PosPostingDuplicate(PayTypePos, EftSetupMapOldToNew.Get(PayTypePos));
            VippsMpPaymentSetupDuplicate(PayTypePos, EftSetupMapOldToNew.Get(PayTypePos));
        end;
        //Create EFT Records
        CurrentEFTSetup.Reset();
        Clear(CurrentEFTSetup);
        CurrentEFTSetup.SetRange("EFT Integration Type", 'MOBILEPAY_V10');
        while CurrentEFTSetup.Next() <> 0 do begin
            CreateEftSetup(EftSetupMapOldToNew.Get(CurrentEFTSetup."Payment Type POS"), CurrentEFTSetup."POS Unit No.");
            CreateVippsUnitSetup(CurrentEFTSetup, StoreIdToMsnMapning);
        end;
        //Create Webhook
        VippsMpStore.Reset();
        while VippsMpStore.Next() <> 0 do begin
            CreateWebhook(VippsMpStore);
        end;
        //Create Static QRs
        VippsMpUnitSetup.Reset();
        while VippsMpUnitSetup.Next() <> 0 do begin
            CreateQr(VippsMpUnitSetup);
        end;
    end;

    local procedure ValidateMobilepayV10Setup(var MobilpeyaSetupErr: Text): Boolean
    var
        SetupErrLbl: Label 'Mobilepay_V10 setup error, please correct or delete affected EFT Setups:\';
        MpPaySetupLbl: Label '- Mobilepay_V10 payment parameters missing for Payment Method: %1.\';
        MpUnitSetupLbl: Label '- Mobilepay_V10 unit parameters missing for pos unit: %1.\';
        MpUnitSetupParameterLbl: Label '- Mobilepay_V10 unit parameter ''%1'' missing for pos unit: %2.\';
        EFTSetup: Record "NPR EFT Setup";
        MobilePayV10UnitSetup: Record "NPR MobilePayV10 Unit Setup";
        MobilePayV10PaymentSetup: Record "NPR MobilePayV10 Payment Setup";
    begin
        MobilpeyaSetupErr := SetupErrLbl;
        EFTSetup.SetRange("EFT Integration Type", 'MOBILEPAY_V10');
        while (EFTSetup.Next() <> 0) do begin
            if (not MobilePayV10PaymentSetup.Get(EFTSetup."Payment Type POS")) then
                MobilpeyaSetupErr += StrSubstNo(MpPaySetupLbl, EFTSetup."Payment Type POS");
            if (not MobilePayV10UnitSetup.Get(EFTSetup."POS Unit No.")) then begin
                MobilpeyaSetupErr += StrSubstNo(MpUnitSetupLbl, EFTSetup."POS Unit No.");
            end else begin
                if (MobilePayV10UnitSetup."Store ID" = '') then
                    MobilpeyaSetupErr += StrSubstNo(MpUnitSetupParameterLbl, 'Store Id', EFTSetup."POS Unit No.");
                if (MobilePayV10UnitSetup."Beacon ID" = '') then
                    MobilpeyaSetupErr += StrSubstNo(MpUnitSetupParameterLbl, 'Beacon Id', EFTSetup."POS Unit No.");
            end;
        end;
        exit(MobilpeyaSetupErr = SetupErrLbl);
    end;

    local procedure SafeUrlName(StoreName: Text; Msn: Text): Text
    var
        Txt: Text;
        Res: Text;
        Cha: Char;
        Index: Integer;
        RegEx: Codeunit "NPR RegEx";
    begin
        Txt := StoreName + '-' + Msn;
        Index := 1;
        while Index < StrLen(Txt) do begin
            Cha := Txt[Index];
            if (RegEx.IsMatch(Cha, '[0-9a-zA-Z-]')) then begin
                Res += Cha;
            end;
            Index += 1;
        end;
        exit(Res);
    end;

    [NonDebuggable]
    local procedure GetMapningsDictionary(var JsonMap: JsonObject)
    var
        Http: HttpClient;
        Resp: HttpResponseMessage;
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        SasToken: Text;
        MigrationJsonTxt: Text;
    begin
        if (not AzureKeyVaultMgt.TryGetAzureKeyVaultSecret('VippsMobilepayMigrationSasToken', SasToken)) then
            Error('The SasToken secret was not found.');
        Http.Get('https://npvippsmobilepay8959.blob.core.windows.net/migrationdata/vippsmigration.json?' + SasToken, Resp);
        if (not Resp.IsSuccessStatusCode()) then
            Error('Error: %1', Resp.HttpStatusCode());
        Resp.Content.ReadAs(MigrationJsonTxt);
        JsonMap.ReadFrom(MigrationJsonTxt);
    end;

    local procedure PaymentTypePosDuplicate(OrgPayTypePos: Code[10]; NewPayTypePos: Code[10])
    var
        OrgPayMethod: Record "NPR POS Payment Method";
        PayMethod: Record "NPR POS Payment Method";
    begin
        if (not PayMethod.Get(NewPayTypePos)) then begin
            OrgPayMethod.SetFilter(Code, OrgPayTypePos);
            OrgPayMethod.FindFirst();
            PayMethod.TransferFields(OrgPayMethod);
            PayMethod.Init();
            PayMethod.TransferFields(OrgPayMethod);
            PayMethod.Code := NewPayTypePos;
            PayMethod.Description := 'Vipps Mobilepay';
            PayMethod.Insert();
        end;
    end;

    local procedure CreateEftSetup(NewPayTypePos: Code[10]; POSUnitNo: Code[10])
    var
        EFTSetup: Record "NPR EFT Setup";
    begin
        if (not EFTSetup.Get(NewPayTypePos, POSUnitNo)) then begin
            EFTSetup.Init();
            EFTSetup."Payment Type POS" := NewPayTypePos;
            EFTSetup."POS Unit No." := POSUnitNo;
            EFTSetup."EFT Integration Type" := 'VIPPS_MOBILEPAY';
            EFTSetup.Insert();
        end;
    end;

    local procedure PosPostingDuplicate(OrgPayTypePos: Code[10]; NewPayTypePos: Code[10])
    var
        OrgPosPosting: Record "NPR POS Posting Setup";
        PosPosting: Record "NPR POS Posting Setup";
    begin
        OrgPosPosting.SetFilter("POS Payment Method Code", OrgPayTypePos);
        while OrgPosPosting.Next() <> 0 do begin
            if (not PosPosting.Get(OrgPosPosting."POS Store Code", NewPayTypePos, OrgPosPosting."POS Payment Bin Code")) then begin
                PosPosting.Init();
                PosPosting.TransferFields(OrgPosPosting);
                PosPosting."POS Payment Method Code" := NewPayTypePos;
                PosPosting.Insert();
            end;
        end;
    end;

    local procedure VippsMpPaymentSetupDuplicate(OrgPayTypePos: Code[10]; NewPayTypePos: Code[10])
    var
        MobilePayV10PaymentSetup: Record "NPR MobilePayV10 Payment Setup";
        VippsMpPaymentSetup: Record "NPR Vipps Mp Payment Setup";
    begin
        //Create Payment Config
        MobilePayV10PaymentSetup.Get(OrgPayTypePos);
        if (not VippsMpPaymentSetup.Get(NewPayTypePos)) then begin
            VippsMpPaymentSetup.Init();
            VippsMpPaymentSetup."Payment Type POS" := NewPayTypePos;
            if (MobilePayV10PaymentSetup."Log Level" = MobilePayV10PaymentSetup."Log Level"::All) then
                VippsMpPaymentSetup."Log Level" := VippsMpPaymentSetup."Log Level"::All;
            if (MobilePayV10PaymentSetup."Log Level" = MobilePayV10PaymentSetup."Log Level"::Errors) then
                VippsMpPaymentSetup."Log Level" := VippsMpPaymentSetup."Log Level"::Error;
            VippsMpPaymentSetup.Insert();
        end;
    end;

    local procedure CreateVippsUnitSetup(CurrentEFTSetup: Record "NPR EFT Setup"; StoreIdToMsnMapning: JsonObject)
    var
        MobilePayV10UnitSetup: Record "NPR MobilePayV10 Unit Setup";
        MobilePayV10PaymentSetup: Record "NPR MobilePayV10 Payment Setup";
        VippsMpUnitSetup: Record "NPR Vipps Mp Unit Setup";
        VippsMpStore: Record "NPR Vipps Mp Store";
        CurrentMsn: Text;
        NoMapningLbl: Label 'The mobilepay store id %1 used with pos unit %2 did not correspond to any known vipps mobilepay msn.';
        UnitSetupExistLbl: Label 'An existing Vipps Mobilepay Unit setup was found for pos unit %1, do you wan''t to re-use existing setup?';
        MsnEmptyLbl: Label 'There was no value associated with the merchant serial number. skipping setup for pos unit %1';
        Token: JsonToken;
        Token2: JsonToken;
    begin
        if (VippsMpUnitSetup.Get(CurrentEFTSetup."POS Unit No.")) then begin
            if (Confirm(StrSubstNo(UnitSetupExistLbl, CurrentEFTSetup."POS Unit No."))) then begin
                exit;
            end else begin
                VippsMpUnitSetup.Delete();
                VippsMpUnitSetup.Reset();
            end;
        end;
        MobilePayV10UnitSetup.Get(CurrentEFTSetup."POS Unit No.");
        MobilePayV10PaymentSetup.Get(CurrentEFTSetup."Payment Type POS");
        if (not StoreIdToMsnMapning.Get(MobilePayV10UnitSetup."Store ID", Token)) then begin
            Message(StrSubstNo(NoMapningLbl, MobilePayV10UnitSetup."Store ID", MobilePayV10UnitSetup."POS Unit No."));
            exit;
        end;
        if (not Token.AsObject().Get('MSN', Token2)) then begin
            Message(StrSubstNo(NoMapningLbl, MobilePayV10UnitSetup."Store ID", MobilePayV10UnitSetup."POS Unit No."));
            exit;
        end;
        //Create the Unit Setup.
        VippsMpUnitSetup.Init();
        VippsMpUnitSetup."POS Unit No." := CurrentEFTSetup."POS Unit No.";
        VippsMpUnitSetup.Insert();

        //Create the Store
        CurrentMsn := Token2.AsValue().AsText();
        if (CurrentMsn = '') then begin
            Message(StrSubstNo(MsnEmptyLbl, CurrentEFTSetup."POS Unit No."));
            exit;
        end;
        if (not VippsMpStore.Get(CurrentMsn)) then begin
            VippsMpStore.Init();
#pragma warning disable AA0139
            VippsMpStore."Merchant Serial Number" := CurrentMsn;
#pragma warning restore AA0139
            VippsMpStore."Partner API Enabled" := MobilePayV10PaymentSetup.Environment = MobilePayV10PaymentSetup.Environment::Production;
            VippsMpStore.Sandbox := MobilePayV10PaymentSetup.Environment = MobilePayV10PaymentSetup.Environment::Sandbox;
            //Used for testing purpose:
            if (VippsMpStore.Sandbox) then begin
#pragma warning disable AA0139
                if (Token.AsObject().Contains('client_id')) then begin
                    Token.AsObject().Get('client_id', Token2);
                    VippsMpStore."Client Id" := Token2.AsValue().AsText();
                    Token.AsObject().Get('client_secret', Token2);
                    VippsMpStore."Client Secret" := Token2.AsValue().AsText();
                    Token.AsObject().Get('subscription_key', Token2);
                    VippsMpStore."Client Sub. Key" := Token2.AsValue().AsText();
                end;
#pragma warning restore AA0139
            end;
            VippsMpStore.Insert();
        end;
        VippsMpUnitSetup."Merchant Serial Number" := VippsMpStore."Merchant Serial Number";
        VippsMpUnitSetup.Modify();
    end;

    local procedure CreateWebhook(VippsMpStore: Record "NPR Vipps Mp Store")
    var
        VippsMpWebhook: Record "NPR Vipps Mp Webhook";
        VippsMpWebhookAPI: Codeunit "NPR Vipps Mp Webhook API";
        VippsMpUtil: Codeunit "NPR Vipps Mp Util";
        EnvironmentInformation: Codeunit "Environment Information";
        VippsMpWebhookSetup: Codeunit "NPR Vipps Mp Webhook Setup";
        WebhookObj: JsonObject;
        WebhookToBeDeleted: List of [Text];
        Token: JsonToken;
        Token2: JsonToken;
        Token3: JsonToken;
        WebhookId: Text;
        Retry: Boolean;
        LookupFailLbl: Label 'Could not fetch the webhooks from Vipps Mobilepay. Do you want to retry?. Error: %1';
        SkippLbl: Label 'Skipping webhook setup for Msn %1';
    begin
        Retry := true;
        while Retry do begin
            if (not VippsMpWebhookAPI.GetAllRegisteredWebhooks(VippsMpStore, WebhookObj)) then begin
                Retry := Confirm(StrSubstNo(LookupFailLbl, GetLastErrorText()));
                if (not Retry) then begin
                    Message(StrSubstNo(SkippLbl, VippsMpStore."Merchant Serial Number"));
                    exit;
                end;
            end else begin
                break;
            end;
        end;
        if (not WebhookObj.Get('webhooks', Token)) then begin
            Message('Unexpected Error (webhook fetch): Api did not respond with proper value. ' + StrSubstNo(SkippLbl, VippsMpStore."Merchant Serial Number"));
            exit;
        end;
        //Identify invalid webhooks and clean up.
        foreach Token2 in Token.AsArray() do begin
            if (Token2.AsObject().Get('id', Token3)) then begin
                WebhookId := Token3.AsValue().AsText();
                VippsMpWebhook.Reset();
                VippsMpWebhook.SetRange("Webhook Id", WebhookId);
                if (VippsMpWebhook.FindFirst()) then begin
                    if (VippsMpWebhook."Webhook Secret" = '') then
                        WebhookToBeDeleted.Add(WebhookId);
                end else begin
                    WebhookToBeDeleted.Add(WebhookId);
                end;
            end;
        end;
        foreach WebhookId in WebhookToBeDeleted do begin
            VippsMpWebhookAPI.DeleteWebhook(WebhookId, VippsMpStore);
        end;
        VippsMpWebhook.Reset();
        if (not VippsMpWebhook.Get(VippsMpStore."Webhook Reference")) then begin
            VippsMpStore."Webhook Reference" := '';
        end;
        if (VippsMpStore."Webhook Reference" = '') then begin
            VippsMpWebhook.Reset();
            VippsMpWebhook.SetRange("Merchant Serial Number", VippsMpStore."Merchant Serial Number");
            if (VippsMpWebhook.FindFirst()) then begin
                VippsMpStore."Webhook Reference" := VippsMpWebhook."Webhook Reference";
            end else begin
                VippsMpWebhook.Init();
                VippsMpWebhook."Merchant Serial Number" := VippsMpStore."Merchant Serial Number";
#pragma warning disable AA0139
                VippsMpWebhook."Webhook Reference" := VippsMpUtil.RemoveCurlyBraces(CreateGuid());
                if (EnvironmentInformation.IsOnPrem()) then begin
                    VippsMpWebhook."OnPrem AF Credential Id" := SafeUrlName(VippsMpStore."Store Name", VippsMpStore."Merchant Serial Number");
                    VippsMpWebhook."OnPrem AF Credential Key" := VippsMpUtil.RemoveCurlyBraces(CreateGuid());
#pragma warning restore AA0139
                end;
                VippsMpWebhook.Insert();
            end;
            VippsMpWebhookSetup.CreateWebhook(VippsMpStore, VippsMpWebhook);
            VippsMpStore."Webhook Reference" := VippsMpWebhook."Webhook Reference";
            VippsMpStore.Modify();
        end;
    end;

    local procedure CreateQr(VippsMpUnitSetup: Record "NPR Vipps Mp Unit Setup")
    var
        POSUnit: Record "NPR POS Unit";
        VippsMpQrCallback: Record "NPR Vipps Mp QrCallback";
        MobilePayV10UnitSetup: Record "NPR MobilePayV10 Unit Setup";
        VippsMpQRAPI: Codeunit "NPR Vipps Mp QR API";
        VippsMpStore: Record "NPR Vipps Mp Store";
        Retry: Boolean;
        JsonResponse: JsonObject;
        Token: JsonToken;
        QrExistLbl: Label 'The Unit setup for pos unit %1 already contains a definition for qr, do you wan''t to re-use this?';
        RetryErrLbl: Label 'The operation of %1 failed. Do you wan''t to retry the operation?';
        SkippLbl: Label 'Skipping qr setup for pos unit %1';
    begin
        if (VippsMpUnitSetup."Merchant Qr Id" <> '') then begin
            if (Confirm(QrExistLbl)) then begin
                Message(StrSubstNo(SkippLbl, VippsMpUnitSetup."POS Unit No."));
                exit;
            end else begin
                VippsMpUnitSetup."Merchant Qr Id" := '';
                VippsMpUnitSetup.Modify();
            end;
        end;
        POSUnit.Get(VippsMpUnitSetup."POS Unit No.");
        MobilePayV10UnitSetup.Get(VippsMpUnitSetup."POS Unit No.");
        //Create Merchant QR
        if (not VippsMpQrCallback.Get(MobilePayV10UnitSetup."Beacon ID")) then begin
            VippsMpQrCallback.Init();
            VippsMpQrCallback."Merchant Qr Id" := MobilePayV10UnitSetup."Beacon ID";
            VippsMpQrCallback."Merchant Serial Number" := VippsMpUnitSetup."Merchant Serial Number";
            VippsMpQrCallback."Location Description" := POSUnit.Name;
            VippsMpQrCallback.Insert();
            VippsMpUnitSetup."Merchant Qr Id" := VippsMpQrCallback."Merchant Qr Id";
            VippsMpUnitSetup.Modify();
            //CREATE QR in Vipps
            if (not VippsMpStore.Get(VippsMpUnitSetup."Merchant Serial Number")) then begin
                Message('No Vipps store configured for this unit setup. ' + StrSubstNo(SkippLbl, VippsMpUnitSetup."POS Unit No."));
                exit;
            end;
            Retry := True;
            while Retry do begin
                if (VippsMpQRAPI.CreateORUpdateMobilepayQr(VippsMpStore, VippsMpQrCallback."Merchant Qr Id", VippsMpQrCallback."Location Description")) then begin
                    break;
                end else begin
                    Retry := Confirm(StrSubstNo(RetryErrLbl, 'creating qr'));
                    if (not Retry) then begin
                        Message(StrSubstNo(SkippLbl, VippsMpUnitSetup."POS Unit No."));
                        exit;
                    end;
                end;
            end;
            Retry := True;
            while Retry do begin
                if (VippsMpQRAPI.GetMerchantCallBackQrInfo(VippsMpStore, VippsMpQrCallback."Merchant Qr Id", JsonResponse)) then begin
                    break;
                end else begin
                    Retry := Confirm(StrSubstNo(RetryErrLbl, 'fetching qr data'));
                    if (not Retry) then begin
                        Message(StrSubstNo(SkippLbl, VippsMpUnitSetup."POS Unit No."));
                        exit;
                    end;
                end;
            end;
            if (not JsonResponse.Get('qrContent', Token)) then begin
                Message('Unexpected result: ' + GetLastErrorText() + '. ' + StrSubstNo(SkippLbl, VippsMpUnitSetup."POS Unit No."));
                exit;
            end;
#pragma warning disable AA0139
            VippsMpQrCallback."Qr Content" := Token.AsValue().AsText();
#pragma warning restore AA0139
            VippsMpQrCallback.Modify();
        end;
        VippsMpUnitSetup."Merchant Qr Id" := VippsMpQrCallback."Merchant Qr Id";
    end;
}