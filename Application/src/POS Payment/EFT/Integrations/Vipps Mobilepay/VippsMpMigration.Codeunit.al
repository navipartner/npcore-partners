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
        VippsMpWebhookSetup: Codeunit "NPR Vipps Mp Webhook Setup";
        VippsMpQrMgt: Codeunit "NPR Vipps Mp Qr Mgt.";
        Deleted: Integer;
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
            VippsMpStore.SetFilter("Webhook Reference", VippsMpWebhook."Webhook Reference");
            VippsMpStore.FindFirst();
            VippsMpWebhookSetup.SynchronizeWebhooks(VippsMpStore, Deleted);
            VippsMpWebhookSetup.DeleteWebhook(VippsMpStore, VippsMpWebhook);
        end;
        while VippsMpQrCallback.Next() <> 0 do begin
            VippsMpQrMgt.RemoveQrBarcode(VippsMpQrCallback);
        end;
        //BeforeDelete Use for clear
        VippsMpStore.DeleteAll();
    end;

    procedure MigrateMobilepaytoVipps()
    var
        NewEFTSetup: Record "NPR EFT Setup";
        CurrentEFTSetup: Record "NPR EFT Setup";
        MobilePayV10PaymentSetup: Record "NPR MobilePayV10 Payment Setup";
        VippsMpUnitSetup: Record "NPR Vipps Mp Unit Setup";
        MobilePayV10UnitSetup: Record "NPR MobilePayV10 Unit Setup";
        VippsMpStore: Record "NPR Vipps Mp Store";
        VippsMpWebhook: Record "NPR Vipps Mp Webhook";
        VippsMpQrCallback: Record "NPR Vipps Mp QrCallback";
        POSUnit: Record "NPR POS Unit";
        VippsMpWebhookSetup: Codeunit "NPR Vipps Mp Webhook Setup";
        VippsMpQrMgt: Codeunit "NPR Vipps Mp Qr Mgt.";
        VippsMpUtil: Codeunit "NPR Vipps Mp Util";
        EnvironmentInformation: Codeunit "Environment Information";
        MobilePayV10Integration: Codeunit "NPR MobilePayV10 Integration";
        tempMobilePayStores: Record "NPR MobilePayV10 Store" temporary;
        EftSetupMapOldToNew: Dictionary of [Code[10], Code[10]];
        PayTypePos: Code[10];
        PaymentTypePosNo: Text;
        I: Integer;
        Token: JsonToken;
        Token2: JsonToken;
        StoreIdToMsnMapning: JsonObject;
    begin
        GetMapningsDictionary(StoreIdToMsnMapning);
        //Get all Mobilepay setups
        CurrentEFTSetup.SetRange("EFT Integration Type", 'MOBILEPAY_V10');
        //Explicit empty string, so names will be: "VIPPS MP", "VIPPS MP1"...
        PaymentTypePosNo := '';
        //For each EFT Setup Using Mobilepay V10:
        while CurrentEFTSetup.Next() <> 0 do begin
            if (not EftSetupMapOldToNew.ContainsKey(CurrentEFTSetup."Payment Type POS")) then begin
                //Add so we can reference this EFT Setup for other records.
                EftSetupMapOldToNew.Add(CurrentEFTSetup."Payment Type POS", 'VIPPS MP' + PaymentTypePosNo);
                //Create duplicate "POS Posting Setup" and duplicate "POS Payment Method"
                PaymentTypePosDuplicate(CurrentEFTSetup."Payment Type POS", 'VIPPS MP' + PaymentTypePosNo);
                PosPostingDuplicate(CurrentEFTSetup."Payment Type POS", 'VIPPS MP' + PaymentTypePosNo);
                VippsMpPaymentSetupDuplicate(CurrentEFTSetup."Payment Type POS", 'VIPPS MP' + PaymentTypePosNo);
                //Handles the case where customers have more complex setup.
                I := I + 1;
                PaymentTypePosNo := Format(I);
            end;
            //Create EFT Setup Equivalent
            EftSetupMapOldToNew.Get(CurrentEFTSetup."Payment Type POS", PayTypePos);
            NewEFTSetup.Init();
            NewEFTSetup."Payment Type POS" := PayTypePos;
            NewEFTSetup."POS Unit No." := CurrentEFTSetup."POS Unit No.";
            NewEFTSetup."EFT Integration Type" := 'VIPPS_MOBILEPAY';
            NewEFTSetup.Insert();

            //PrepareMapInfo
            MobilePayV10UnitSetup.Get(NewEFTSetup."POS Unit No.");
            if (tempMobilePayStores.Count() = 0) then
                MobilePayV10Integration.GetMobilePayStores(CurrentEFTSetup, tempMobilePayStores);
            tempMobilePayStores.Get(MobilePayV10UnitSetup."Store ID");
            MobilePayV10PaymentSetup.Get(CurrentEFTSetup."Payment Type POS");
            StoreIdToMsnMapning.Get(MobilePayV10UnitSetup."Store ID", Token);
            Token.AsObject().Get('MSN', Token2);

            //Create Store If not already created
            if (not VippsMpStore.Get(Token2.AsValue().AsText())) then begin
                VippsMpStore.Init();
#pragma warning disable AA0139
                VippsMpStore."Merchant Serial Number" := Token2.AsValue().AsText();
#pragma warning restore AA0139
                VippsMpStore."Partner API Enabled" := MobilePayV10PaymentSetup.Environment = MobilePayV10PaymentSetup.Environment::Production;
                VippsMpStore.Sandbox := MobilePayV10PaymentSetup.Environment = MobilePayV10PaymentSetup.Environment::Sandbox;
                VippsMpStore."Store Name" := tempMobilePayStores."Store Name";
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
            //Create Merchante Webhook if not exist
            if (VippsMpStore."Webhook Reference" = '') then begin
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
                VippsMpWebhookSetup.CreateWebhook(VippsMpStore, VippsMpWebhook);
                VippsMpStore."Webhook Reference" := VippsMpWebhook."Webhook Reference";
                VippsMpStore.Modify();
            end;

            POSUnit.Get(NewEFTSetup."POS Unit No.");
            //Create Merchant QR
            if (not VippsMpQrCallback.Get(MobilePayV10UnitSetup."Beacon ID")) then begin
                VippsMpQrCallback.Init();
                VippsMpQrCallback."Merchant Qr Id" := MobilePayV10UnitSetup."Beacon ID";
                VippsMpQrCallback."Merchant Serial Number" := VippsMpStore."Merchant Serial Number";
                VippsMpQrCallback."Location Description" := POSUnit.Name;
                VippsMpQrCallback.Insert();
                //CREATE QR in Vipps
                VippsMpQrMgt.CreateUpdateMobilepayQr(VippsMpQrCallback);
            end;

            //Create Unit Config
            VippsMpUnitSetup.Init();
            VippsMpUnitSetup."POS Unit No." := NewEFTSetup."POS Unit No.";
            VippsMpUnitSetup."Merchant Serial Number" := VippsMpStore."Merchant Serial Number";
            VippsMpUnitSetup."Merchant Qr Id" := VippsMpQrCallback."Merchant Qr Id";
            VippsMpUnitSetup.Insert();
        end;
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

        OrgPayMethod.SetFilter(Code, OrgPayTypePos);
        OrgPayMethod.FindFirst();
        PayMethod.TransferFields(OrgPayMethod);
        PayMethod.Init();
        PayMethod.TransferFields(OrgPayMethod);
        PayMethod.Code := NewPayTypePos;
        PayMethod.Description := 'Vipps Mobilepay';
        PayMethod.Insert();
    end;

    local procedure PosPostingDuplicate(OrgPayTypePos: Code[10]; NewPayTypePos: Code[10])
    var
        OrgPosPosting: Record "NPR POS Posting Setup";
        PosPosting: Record "NPR POS Posting Setup";
    begin
        OrgPosPosting.SetFilter("POS Payment Method Code", OrgPayTypePos);
        while OrgPosPosting.Next() <> 0 do begin
            PosPosting.Init();
            PosPosting.TransferFields(OrgPosPosting);
            PosPosting."POS Payment Method Code" := NewPayTypePos;
            PosPosting.Insert();
        end;
    end;

    local procedure VippsMpPaymentSetupDuplicate(OrgPayTypePos: Code[10]; NewPayTypePos: Code[10])
    var
        MobilePayV10PaymentSetup: Record "NPR MobilePayV10 Payment Setup";
        VippsMpPaymentSetup: Record "NPR Vipps Mp Payment Setup";
    begin
        //Create Payment Config
        MobilePayV10PaymentSetup.Get(OrgPayTypePos);
        VippsMpPaymentSetup.Init();
        VippsMpPaymentSetup."Payment Type POS" := NewPayTypePos;
        if (MobilePayV10PaymentSetup."Log Level" = MobilePayV10PaymentSetup."Log Level"::All) then
            VippsMpPaymentSetup."Log Level" := VippsMpPaymentSetup."Log Level"::All;
        if (MobilePayV10PaymentSetup."Log Level" = MobilePayV10PaymentSetup."Log Level"::Errors) then
            VippsMpPaymentSetup."Log Level" := VippsMpPaymentSetup."Log Level"::Error;
        VippsMpPaymentSetup.Insert();
    end;


}