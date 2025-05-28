codeunit 85213 "NPR Library DE Fiscal"
{
    EventSubscriberInstance = Manual;

    internal procedure CreateAuditProfileSetup(var POSAuditProfile: Record "NPR POS Audit Profile"; var POSUnit: Record "NPR POS Unit")
    var
        ConnectionParameterSet: Record "NPR DE Audit Setup";
        DETSSClient: Record "NPR DE POS Unit Aux. Info";
        DETSS: Record "NPR DE TSS";
        DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
        LibraryDEFiscal: Codeunit "NPR Library DE Fiscal";
    begin
        InsertPOSAuditProfile(POSAuditProfile);
        AllowGapsInNoSeries(POSAuditProfile);

        EnableFiscalization();

        UpdatePOSAuditProfileOnPOSUnit(POSAuditProfile, POSUnit);

        BindSubscription(LibraryDEFiscal);
        CreateTestConnectionParameterSet(ConnectionParameterSet);
        CreateTSS(DETSS, ConnectionParameterSet);
        DEFiskalyCommunication.CreateTSS(DETSS, ConnectionParameterSet);
        CreateTSSClient(DETSSClient, POSUnit, DETSS);
        DEFiskalyCommunication.CreateClient(DETSSClient);
        UnbindSubscription(LibraryDEFiscal);
    end;

    local procedure InsertPOSAuditProfile(var POSAuditProfile: Record "NPR POS Audit Profile")
    var
        DEAuditMgt: Codeunit "NPR DE Audit Mgt.";
    begin
        POSAuditProfile.Init();
        POSAuditProfile.Code := DEAuditMgt.HandlerCode();
        POSAuditProfile."Allow Printing Receipt Copy" := POSAuditProfile."Allow Printing Receipt Copy"::Always;
        POSAuditProfile."Audit Handler" := DEAuditMgt.HandlerCode();
        POSAuditProfile."Audit Log Enabled" := true;
        POSAuditProfile."Fill Sale Fiscal No. On" := POSAuditProfile."Fill Sale Fiscal No. On"::Successful;
        POSAuditProfile."Balancing Fiscal No. Series" := CreateNumberSeries();
        POSAuditProfile."Sale Fiscal No. Series" := CreateNumberSeries();
        POSAuditProfile."Sales Ticket No. Series" := CreateNumberSeries();
        POSAuditProfile."Credit Sale Fiscal No. Series" := CreateNumberSeries();
        POSAuditProfile.Insert();
    end;

    local procedure AllowGapsInNoSeries(var POSAuditProfile: Record "NPR POS Audit Profile")
    var
        NoSeriesLine: Record "No. Series Line";
    begin
        NoSeriesLine.SetRange("Series Code", POSAuditProfile."Sales Ticket No. Series");
        NoSeriesLine.SetRange(Open, true);
        NoSeriesLine.FindLast();
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesLine.Validate(Implementation, NoSeriesLine.Implementation::Sequence);
#ELSE
        NoSeriesLine.Validate("Allow Gaps in Nos.", true);
#ENDIF
        NoSeriesLine.Modify();
    end;

    local procedure UpdatePOSAuditProfileOnPOSUnit(var POSAuditProfile: Record "NPR POS Audit Profile"; var POSUnit: Record "NPR POS Unit")
    begin
        POSUnit."POS Audit Profile" := POSAuditProfile.Code;
        POSUnit.Modify();
    end;

    internal procedure CreateTestConnectionParameterSet(var ConnectionParameterSet: Record "NPR DE Audit Setup")
    var
        DESecretMgt: Codeunit "NPR DE Secret Mgt.";
    begin
        if not ConnectionParameterSet.Get(GetTestConnectionParamCode()) then begin
            ConnectionParameterSet.Init();
            ConnectionParameterSet."Primary Key" := GetTestConnectionParamCode();
            ConnectionParameterSet.Insert();
        end;

        ConnectionParameterSet."Api URL" := GetFiskalyApiUrl();
        ConnectionParameterSet."Submission Api URL" := GetSubmissionApiUrl();
        DESecretMgt.SetSecretKey(ConnectionParameterSet.ApiKeyLbl(), '123');
        DESecretMgt.SetSecretKey(ConnectionParameterSet.ApiSecretLbl(), '123');
        ConnectionParameterSet.Modify();
    end;

    internal procedure CreateConnectionParameterSet(var ConnectionParameterSet: Record "NPR DE Audit Setup")
    var
        LibraryUtility: Codeunit "Library - Utility";
        DESecretMgt: Codeunit "NPR DE Secret Mgt.";
    begin
        ConnectionParameterSet.Init();
        ConnectionParameterSet.Validate(
            "Primary Key",
            CopyStr(
                LibraryUtility.GenerateRandomCode(ConnectionParameterSet.FieldNo("Primary Key"), Database::"NPR DE Audit Setup"),
                1,
                LibraryUtility.GetFieldLength(Database::"NPR DE Audit Setup", ConnectionParameterSet.FieldNo("Primary Key"))));

        ConnectionParameterSet."Api URL" := GetFiskalyApiUrl();
        ConnectionParameterSet."Submission Api URL" := GetSubmissionApiUrl();
        DESecretMgt.SetSecretKey(ConnectionParameterSet.ApiKeyLbl(), '123');
        DESecretMgt.SetSecretKey(ConnectionParameterSet.ApiSecretLbl(), '123');
        ConnectionParameterSet.Insert(true);
    end;

    internal procedure UpdateRegistrationNumberOnCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation."Registration No." := GetTaxpayerRegistrationNo();
        CompanyInformation.Modify(true);
    end;

    internal procedure UpdateLegalTaxpayerDataOnConnectionParameterSet(var ConnectionParameterSet: Record "NPR DE Audit Setup")
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        ConnectionParameterSet.Validate("Taxpayer Person Type", ConnectionParameterSet."Taxpayer Person Type"::legal);
        ConnectionParameterSet.SetDefaultLegalPersonFieldValues();
        ConnectionParameterSet."Taxpayer Tax Office Number" := GetTaxpayerTaxOfficeNumber();
        ConnectionParameterSet."Taxpayer Company Name" := CopyStr(LibraryUtility.GenerateRandomAlphabeticText(MaxStrLen(ConnectionParameterSet."Taxpayer Company Name"), 1), 1, MaxStrLen(ConnectionParameterSet."Taxpayer Company Name"));
        ConnectionParameterSet."Taxpayer Legal Form" := ConnectionParameterSet."Taxpayer Legal Form"::"91";
        ConnectionParameterSet."Taxpayer Street" := CopyStr(LibraryUtility.GenerateRandomAlphabeticText(MaxStrLen(ConnectionParameterSet."Taxpayer Street"), 1), 1, MaxStrLen(ConnectionParameterSet."Taxpayer Street"));
        ConnectionParameterSet."Taxpayer House Number" := CopyStr(LibraryUtility.GenerateRandomNumericText(MaxStrLen(ConnectionParameterSet."Taxpayer House Number")), 1, MaxStrLen(ConnectionParameterSet."Taxpayer House Number"));
        ConnectionParameterSet."Taxpayer Town" := GetTaxpayerTown();
        ConnectionParameterSet."Taxpayer ZIP Code" := GetTaxpayerZIPCode();
        ConnectionParameterSet.Modify(true);
    end;

    internal procedure CreateEstablishment(var DEEstablishment: Record "NPR DE Establishment"; POSStoreCode: Code[10]; ConnectionParameterSetCode: Code[10])
    begin
        DEEstablishment.Init();
        DEEstablishment.Validate("POS Store Code", POSStoreCode);
        DEEstablishment.Validate("Connection Parameter Set Code", ConnectionParameterSetCode);
        DEEstablishment.Insert(true);
    end;

    internal procedure SetAddressDataOnEstablishment(var DEEstablishment: Record "NPR DE Establishment")
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        DEEstablishment.Street := CopyStr(LibraryUtility.GenerateRandomAlphabeticText(MaxStrLen(DEEstablishment.Street), 1), 1, MaxStrLen(DEEstablishment.Street));
        DEEstablishment."House Number" := CopyStr(LibraryUtility.GenerateRandomNumericText(MaxStrLen(DEEstablishment."House Number")), 1, MaxStrLen(DEEstablishment."House Number"));
        DEEstablishment.Town := GetTaxpayerTown();
        DEEstablishment."ZIP Code" := GetTaxpayerZIPCode();
        DEEstablishment.Modify(true);
    end;

    internal procedure EnableFiscalization()
    var
        DEFiscalizationSetup: Record "NPR DE Fiscalization Setup";
    begin
        if not DEFiscalizationSetup.Get() then
            DEFiscalizationSetup.Insert();

        DEFiscalizationSetup."Enable DE Fiscal" := true;
        DEFiscalizationSetup.Modify(true);
    end;

    internal procedure CreateTSS(var DETSS: Record "NPR DE TSS"; ConnectionParameterSet: Record "NPR DE Audit Setup")
    begin
        DETSS.Init();
        DETSS.Code := '0001';
        DETSS.Validate("Connection Parameter Set Code", ConnectionParameterSet."Primary Key");
        DETSS.Insert(true);
    end;

    internal procedure CreateTSS(var DETSS: Record "NPR DE TSS"; ConnectionParameterSetCode: Code[10])
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        DETSS.Init();
        DETSS.Validate(
            Code,
            CopyStr(
                LibraryUtility.GenerateRandomCode(DETSS.FieldNo(Code), Database::"NPR DE TSS"),
                1,
                LibraryUtility.GetFieldLength(Database::"NPR DE TSS", DETSS.FieldNo(Code))));

        DETSS.Validate("Connection Parameter Set Code", ConnectionParameterSetCode);
        DETSS.Insert(true);
    end;

    internal procedure CreateTSSClient(var DETSSClient: Record "NPR DE POS Unit Aux. Info"; POSUnit: Record "NPR POS Unit"; DETSS: Record "NPR DE TSS")
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        DETSSClient.Init();
        DETSSClient.Validate("POS Unit No.", POSUnit."No.");
        DETSSClient.Validate("TSS Code", DETSS.Code);
        DETSSClient."Cash Register Brand" := GetCashRegisterBrand();
        DETSSClient."Cash Register Model" := GetCashRegisterModel();
        DETSSClient."Serial Number" := CopyStr(LibraryUtility.GenerateRandomText(20), 1, MaxStrLen(DETSSClient."Serial Number"));
        DETSSClient.Insert(true);
    end;

    internal procedure CreateTSSClient(var DETSSClient: Record "NPR DE POS Unit Aux. Info"; POSUnitNo: Code[10]; TSSCode: Code[10])
    begin
        DETSSClient.Init();
        DETSSClient.Validate("POS Unit No.", POSUnitNo);
        DETSSClient.Validate("TSS Code", TSSCode);
        DETSSClient.Validate("Fiskaly Client Created at", CurrentDateTime());
        DETSSClient.Insert(true);
    end;

    internal procedure UpdateAdditionalDataOnTSSClient(var DETSSClient: Record "NPR DE POS Unit Aux. Info")
    begin
        DETSSClient.Validate("Acquisition Date", Today());
        DETSSClient.Validate("Commissioning Date", Today());
        DETSSClient.Validate("Cash Register Brand", GetCashRegisterBrand());
        DETSSClient.Validate("Cash Register Model", GetCashRegisterModel());
        DETSSClient.Validate(Software, GetSoftware());
        DETSSClient.Validate("Client Type", DETSSClient."Client Type"::"1");
        DETSSClient.Modify(true);
    end;
    #region Standard record creating

    internal procedure CreatePOSUnit(var POSUnit: Record "NPR POS Unit"; var POSStore: Record "NPR POS Store"; var POSPostingProfile: Record "NPR POS Posting Profile")
    var
        POSSetup: Record "NPR POS Setup";
        _LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        _LibraryPOSMasterData.CreatePOSSetup(POSSetup);
        _LibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
        POSPostingProfile."POS Period Register No. Series" := '';
        POSPostingProfile.Modify();
        _LibraryPOSMasterData.CreatePOSStore(POSStore, POSPostingProfile.Code);
        POSStore."Registration No." := '123456789';
        POSStore."Country/Region Code" := 'DE';
        POSStore.Modify();
        _LibraryPOSMasterData.CreatePOSUnit(POSUnit, POSStore.Code, POSPostingProfile.Code);
    end;

    internal procedure CreatePOSPaymentMethod(var POSPaymentMethod: Record "NPR POS Payment Method"; PaymentProcessingType: Enum "NPR Payment Processing Type")
    var
        PaymentMethodMapper: Record "NPR Payment Method Mapper";
        _LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        _LibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethod, PaymentProcessingType, '', false);
        PaymentMethodMapper.Init();
        PaymentMethodMapper."POS Payment Method" := POSPaymentMethod.Code;
        if PaymentProcessingType in [PaymentProcessingType::CASH] then
            PaymentMethodMapper."Fiskaly Payment Type" := PaymentMethodMapper."Fiskaly Payment Type"::CASH
        else
            PaymentMethodMapper."Fiskaly Payment Type" := PaymentMethodMapper."Fiskaly Payment Type"::NON_CASH;
        PaymentMethodMapper.Insert();
    end;

    internal procedure CreateVATPostingSetup(VATBusPostingGroup: Code[20]; VATProdPostingGroup: Code[20])
    var
        VATPostGroupMapper: Record "NPR VAT Post. Group Mapper";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        VATPostingSetup.SetRange("VAT Bus. Posting Group", VATBusPostingGroup);
        VATPostingSetup.SetRange("VAT Prod. Posting Group", VATProdPostingGroup);
        VATPostingSetup.SetFilter("VAT %", '<>%1', 0);
        VATPostingSetup.FindFirst();
        VATPostingSetup."VAT Identifier" := '17';
        VATPostingSetup.Modify();

        VATPostGroupMapper.Init();
        VATPostGroupMapper."VAT Bus. Posting Group" := VATBusPostingGroup;
        VATPostGroupMapper."VAT Prod. Pos. Group" := VATProdPostingGroup;
        VATPostGroupMapper."VAT Identifier" := '17';
        VATPostGroupMapper."Fiskaly VAT Rate Type" := VATPostGroupMapper."Fiskaly VAT Rate Type"::NORMAL;
        VATPostGroupMapper.Insert();
    end;

    #endregion Standard record creating

    #region Test Values
    local procedure CreateNumberSeries(): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        LibraryUtility.CreateNoSeries(NoSeries, true, false, false);
        LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, 'TEST_1', 'TEST_99999999');
        exit(NoSeries.Code);
    end;

    local procedure GetTaxpayerRegistrationNo(): Text[20]
    var
#pragma warning disable AA0240
        RegistrationNoLbl: Label '9198011310010', Locked = true; // it has to be according to German law
#pragma warning restore AA0240
    begin
        exit(RegistrationNoLbl);
    end;

    local procedure GetTaxpayerTaxOfficeNumber(): Code[4]
    var
        TaxpayerTaxOfficeNumberLbl: Label '9198', Locked = true; // it has to be according to German law
    begin
        exit(TaxpayerTaxOfficeNumberLbl);
    end;

    local procedure GetTaxpayerTown(): Text[50]
    var
        TaxpayerTownLbl: Label 'Berlin', Locked = true;
    begin
        exit(TaxpayerTownLbl);
    end;

    local procedure GetTaxpayerZIPCode(): Code[20]
    var
        TaxpayerZIPCodeLbl: Label '10178', Locked = true; // it has to have German value
    begin
        exit(TaxpayerZIPCodeLbl);
    end;

    local procedure GetFiskalyApiUrl(): Text[250]
    var
        FiskalyApiUrlLbl: Label 'https://kassensichv-middleware.fiskaly.com/api/v2', Locked = true;
    begin
        exit(FiskalyApiUrlLbl);
    end;

    local procedure GetSubmissionApiUrl(): Text[250]
    var
        SubmissionApiUrlLbl: Label 'https://kassensichv.fiskaly.com/submission-api/v1', Locked = true;
    begin
        exit(SubmissionApiUrlLbl);
    end;

    local procedure GetTestConnectionParamCode(): Code[10]
    begin
        exit('TEST');
    end;

    local procedure GetCashRegisterBrand(): Text[250]
    var
        CashRegisterBrandLbl: Label 'NaviPartner', Locked = true;
    begin
        exit(CashRegisterBrandLbl);
    end;

    local procedure GetCashRegisterModel(): Text[250]
    var
        CashRegisterModelLbl: Label 'NaviPartner', Locked = true;
    begin
        exit(CashRegisterModelLbl);
    end;

    local procedure GetSoftware(): Text[250]
    var
        SoftwareLbl: Label 'BC Software', Locked = true;
    begin
        exit(SoftwareLbl);
    end;
    #endregion Test Values

    #region Http Mock Response Subscribers

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR DE Fiskaly Communication", 'OnBeforeSendHttpRequestForCreateTSS', '', false, false)]
    local procedure OnBeforeSendHttpRequestForCreateTSS(sender: Codeunit "NPR DE Fiskaly Communication"; var DETSS: Record "NPR DE TSS"; RequestBodyJsonIn: JsonObject; var ResponseJsonOut: JsonToken; DEAuditSetup: Record "NPR DE Audit Setup"; var IsHandled: Boolean)
    var
        ResponseText: Text;
    begin
        IsHandled := true;
        ResponseText := '{' +
                '"certificate": "string",' +
                '"serial_number": "string",' +
                '"public_key": "string",' +
                '"signature_algorithm": "ecdsa-plain-SHA256",' +
                '"signature_timestamp_format": "unixTime",' +
                '"transaction_data_encoding": "UTF-8",' +
                '"max_number_registered_clients": 9007199254740991,' +
                '"max_number_active_transactions": 9007199254740991,' +
                '"supported_update_variants": "SIGNED",' +
                '"metadata": {' +
                    '"my_property_1": "1234",' +
                    '"my_property_2": "https://my-internal-system/path/to/resource/1234"' +
                '},' +
                '"_id":"' + CreateGuid() + '",' +
                '"_type": "TSS",' +
                '"_env": "TEST",' +
                '"_version": "2.1.18",' +
                '"time_creation": 1577833200,' +
                '"admin_puk": "ABCD123456",' +
                '"state": "CREATED"' +
            '}';
        ResponseJsonOut.ReadFrom(ResponseText);

        sender.UpdateDeTssWithDataFromFiskaly(DETSS, ResponseJsonOut, DEAuditSetup);
        if DETSS."Fiskaly TSS State".AsInteger() < DETSS."Fiskaly TSS State"::UNINITIALIZED.AsInteger() then
            sender.UpdateTSS_State(DETSS, DETSS."Fiskaly TSS State"::UNINITIALIZED, true, DEAuditSetup);

        sender.UpdateTSS_AdminPIN(DETSS, '', DEAuditSetup);

        if DETSS."Fiskaly TSS State".AsInteger() < DETSS."Fiskaly TSS State"::INITIALIZED.AsInteger() then begin
            sender.TSS_AuthenticateAdmin(DETSS, DEAuditSetup);
            sender.UpdateTSS_State(DETSS, DETSS."Fiskaly TSS State"::INITIALIZED, true, DEAuditSetup);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR DE Fiskaly Communication", 'OnBeforeSendHttpRequestForAuthenticateAdmin', '', false, false)]
    local procedure OnBeforeSendHttpRequestForAuthenticateAdmin(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR DE Fiskaly Communication", 'OnBeforeSendHttpRequestForUpdateTSS_State', '', false, false)]
    local procedure OnBeforeSendHttpRequestForUpdateTSS_State(sender: Codeunit "NPR DE Fiskaly Communication"; var DETSS: Record "NPR DE TSS"; NewState: Enum "NPR DE TSS State"; RequestBody: JsonObject; ResponseJson: JsonToken; UpdateBCInfo: Boolean; DEAuditSetup: Record "NPR DE Audit Setup"; var IsHandled: Boolean)
    var
        ResponseText: Text;
    begin
        IsHandled := true;
        ResponseText := '{' +
                '"description": "fiskaly sign cloud-TSE (tss_id)",' +
                '"state": "' + Format(NewState) + '",' +
                '"certificate": "string",' +
                '"serial_number": "string",' +
                '"public_key": "string",' +
                '"bsi_certification_id": "string",' +
                '"bsi_certification_valid_to": 1577833200,' +
                '"signature_counter": "string",' +
                '"signature_algorithm": "ecdsa-plain-SHA256",' +
                '"signature_timestamp_format": "unixTime",' +
                '"transaction_counter": "string",' +
                '"transaction_data_encoding": "UTF-8",' +
                '"number_registered_clients": 9007199254740991,' +
                '"max_number_registered_clients": 9007199254740991,' +
                '"number_active_transactions": 9007199254740991,' +
                '"max_number_active_transactions": 9007199254740991,' +
                '"supported_update_variants": "SIGNED",' +
                '"metadata": {' +
                    '"my_property_1": "1234",' +
                    '"my_property_2": "https://my-internal-system/path/to/resource/1234"' +
                '},' +
                '"_id": "' + DETSS.SystemId + '",' +
                '"_type": "TSS",' +
                '"_env": "TEST",' +
                '"_version": "2.1.18",' +
                '"time_creation": 1577833200,' +
                '"time_uninit": 1577833200,' +
                '"time_init": 1577833200,' +
                '"time_defective": 1577833200,' +
                '"time_disable": 1577833200' +
            '}';

        ResponseJson.ReadFrom(ResponseText);

        if UpdateBCInfo then
            sender.UpdateDeTssWithDataFromFiskaly(DETSS, ResponseJson, DEAuditSetup);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR DE Fiskaly Communication", 'OnBeforeSendHttpRequestForUpdateAdminPin', '', false, false)]
    local procedure OnBeforeSendHttpRequestForUpdateAdminPin(var DETSS: Record "NPR DE TSS"; DESecretMgt: Codeunit "NPR DE Secret Mgt."; NewAdminPIN: Text; var IsHandled: Boolean)
    begin
        IsHandled := true;

        DESecretMgt.SetSecretKey(DETSS.AdminPINSecretLbl(), NewAdminPIN);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR DE Fiskaly Communication", 'OnBeforeSendHttpRequestForCreateClient', '', false, false)]
    local procedure OnBeforeSendHttpRequestForCreateClient(sender: Codeunit "NPR DE Fiskaly Communication"; var DEPOSUnitAuxInfo: Record "NPR DE POS Unit Aux. Info"; DETSS: Record "NPR DE TSS"; RequestBody: JsonObject; ResponseJson: JsonToken; DEAuditSetup: Record "NPR DE Audit Setup"; var IsHandled: Boolean)
    var
        ResponseText: Text;
    begin
        IsHandled := true;
        ResponseText := '{' +
            '"serial_number": "123",' +
            '"state": "REGISTERED",' +
            '"tss_id":"' + DETSS.SystemId + '",' +
            '"metadata": {' +
                '"my_property_1": "1234",' +
                '"my_property_2": "https://my-internal-system/path/to/resource/1234"' +
            '},' +
            '"_id": "00000000-0000-0000-0000-000000000000",' +
            '"_type": "CLIENT",' +
            '"_env": "TEST",' +
            '"_version": "2.1.18",' +
            '"time_creation": 1577833200' +
        '}';
        ResponseJson.ReadFrom(ResponseText);
        sender.UpdateDeTssClientWithDataFromFiskaly(DEPOSUnitAuxInfo, ResponseJson);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR DE Fiskaly Communication", 'OnBeforeSendHttpRequestForSendTransaction', '', false, false)]
    local procedure OnBeforeSendHttpRequestForSendTransaction(sender: Codeunit "NPR DE Fiskaly Communication"; var DeAuditAux: Record "NPR DE POS Audit Log Aux. Info"; RequestBody: JsonObject; ResponseJson: JsonToken; ConnectionParameters: Record "NPR DE Audit Setup"; var IsHandled: Boolean)
    var
        DEAuditMgt: Codeunit "NPR DE Audit Mgt.";
        JToken: JsonToken;
        ResponseText: Text;
    begin
        IsHandled := true;

        RequestBody.Get('state', JToken);
        if JToken.AsValue().AsText() = Enum::"NPR DE Fiskaly Trx. State".Names().Get(Enum::"NPR DE Fiskaly Trx. State".Ordinals().IndexOf(Enum::"NPR DE Fiskaly Trx. State"::ACTIVE.AsInteger())) then
            ResponseText := '{' +
                '"number": 9007199254740991,' +
                '"time_start": 1577833200,' +
                '"client_serial_number": "string",' +
                '"tss_serial_number": "string",' +
                '"state": "ACTIVE",' +
                '"client_id": "' + DeAuditAux."Client Id" + '",' +
                '"schema": {' +
                    '"standard_v1": {' +
                    '"receipt": {"receipt_type": "RECEIPT","amounts_per_vat_rate": [{"vat_rate": "NORMAL","amount": "20.25"}],"amounts_per_payment_type": [{"payment_type": "CASH","amount": "0.12","currency_code": "USD"}]},' +
                    '"order": {"line_items": [{"quantity": "10.98","text": "Eisbecher “Himbeere“","price_per_unit": "20.25"}]},' +
                    '"other": {}' +
                    '},' +
                    '"dsfinvtw_v1": {"power_up": {},"power_off": {},"driver_status": {},"trip_receipt": {},"empty_trip": {"kilometer_reading": "string"},"break": {"kilometer_reading": "string"},"other": "string"},' +
                    '"raw": {"process_type": "Kassenbeleg-V1","process_data": "dGVzdA=="}' +
                '},' +
                '"revision": 1,' +
                '"latest_revision": 1,' +
                '"tss_id": "' + DeAuditAux."TSS ID" + '",' +
                '"metadata": {"my_property_1": "1234","my_property_2": "https://my-internal-system/path/to/resource/1234"},' +
                '"_type": "TRANSACTION",' +
                '"_id": "00000000-0000-0000-0000-000000000000",' +
                '"_env": "TEST",' +
                '"_version": "2.1.18",' +
                '"time_end": 1577833200,' +
                '"qr_code_data": "V0;955002-00;Kassenbeleg-V1;Beleg^0.00_2.55_0.00_0.00_0.00^2.55:Bar;18;112;2019-07-10T18:41:04.000Z;2019-07-10T18:41:04.000Z;ecdsa-plain-SHA256;unixTime;MEQCIAy4P9k+7x9saDO0uRZ4El8QwN+qTgYiv1DIaJIMWRiuAiAt+saFDGjK2Yi5Cxgy7PprXQ5O0seRgx4ltdpW9REvwA==;BHhWOeisRpPBTGQ1W4VUH95TXx2GARf8e2NYZXJoInjtGqnxJ8sZ3CQpYgjI+LYEmW5A37sLWHsyU7nSJUBemyU=",' +
                '"log": {' +
                    '"operation": "Start",' +
                    '"timestamp": 1577833200,' +
                    '"timestamp_format": "unixTime"' +
                '},' +
                '"signature": {' +
                    '"value": "t1coefxr+xZ6t5LiOiWX2GxHjiJMIlJcA/BU8Bq38DE=",' +
                    '"algorithm": "ecdsa-plain-SHA256",' +
                    '"counter": "123456",' +
                    '"public_key": "bUQNdYkyDv1r3GV5jn2kL3xgkKZUR/Z1sXsLUuuzhZqJuE3K8rF+liB5QcfA68TGRJ25AugPCFmav8+Eotw9jKNRf3tCOJOcEYZdnorsHPfvlC4xSwoiBPVm8M+ypj8ENnVOQyMhwk28OHXxBa+X6kBwrBGs4ThloET0WOoCOi3em5XLwdVSCPkZzY5mlXmgry9KMgYTCSF26k9nQnFcHy9xBobOxIn8S8jx3v9AbMGU3gJU9oL3i3jFFgez8yJqT8qkKUmPFoQJF7sx5wDUC9kynQiPcjHB46rYUDDAeBDVt7O+iRFuj6mtsnsveThGKISPfXcEQQqtVbUEMxdx"' +
                '}' +
            '}'
        else
            ResponseText := '{' +
              '"number": 9007199254740991,' +
              '"time_start": 1577833220,' +
              '"client_serial_number": "string",' +
              '"tss_serial_number": "string",' +
              '"state": "FINISHED",' +
              '"client_id": "' + DeAuditAux."Client Id" + '",' +
              '"schema": {' +
                  '"standard_v1": {' +
                  '"receipt": {"receipt_type": "RECEIPT","amounts_per_vat_rate": [{"vat_rate": "NORMAL","amount": "20.25"}],"amounts_per_payment_type": [{"payment_type": "CASH","amount": "0.12","currency_code": "USD"}]},' +
                  '"order": {"line_items": [{"quantity": "10.98","text": "Eisbecher “Himbeere“","price_per_unit": "20.25"}]},' +
                  '"other": {}' +
                  '},' +
                  '"dsfinvtw_v1": {"power_up": {},"power_off": {},"driver_status": {},"trip_receipt": {},"empty_trip": {"kilometer_reading": "string"},"break": {"kilometer_reading": "string"},"other": "string"},' +
                  '"raw": {"process_type": "Kassenbeleg-V1","process_data": "dGVzdA=="}' +
              '},' +
              '"revision": 1,' +
              '"latest_revision": 1,' +
              '"tss_id": "' + DeAuditAux."TSS ID" + '",' +
              '"metadata": {"my_property_1": "1234","my_property_2": "https://my-internal-system/path/to/resource/1234"},' +
              '"_type": "TRANSACTION",' +
              '"_id": "00000000-0000-0000-0000-000000000000",' +
              '"_env": "TEST",' +
              '"_version": "2.1.18",' +
              '"time_end": 1577833200,' +
              '"qr_code_data": "V0;955002-00;Kassenbeleg-V1;Beleg^0.00_2.55_0.00_0.00_0.00^2.55:Bar;18;112;2019-07-10T18:41:04.000Z;2019-07-10T18:41:04.000Z;ecdsa-plain-SHA256;unixTime;MEQCIAy4P9k+7x9saDO0uRZ4El8QwN+qTgYiv1DIaJIMWRiuAiAt+saFDGjK2Yi5Cxgy7PprXQ5O0seRgx4ltdpW9REvwA==;BHhWOeisRpPBTGQ1W4VUH95TXx2GARf8e2NYZXJoInjtGqnxJ8sZ3CQpYgjI+LYEmW5A37sLWHsyU7nSJUBemyU=",' +
              '"log": {' +
                  '"operation": "Finish",' +
                  '"timestamp": 1577833220,' +
                  '"timestamp_format": "unixTime"' +
              '},' +
              '"signature": {' +
                  '"value": "t1coefxr+xZ6t5LiOiWX2GxHjiJMIlJcA/BU8Bq38DE=",' +
                  '"algorithm": "ecdsa-plain-SHA256",' +
                  '"counter": "123456",' +
                  '"public_key": "bUQNdYkyDv1r3GV5jn2kL3xgkKZUR/Z1sXsLUuuzhZqJuE3K8rF+liB5QcfA68TGRJ25AugPCFmav8+Eotw9jKNRf3tCOJOcEYZdnorsHPfvlC4xSwoiBPVm8M+ypj8ENnVOQyMhwk28OHXxBa+X6kBwrBGs4ThloET0WOoCOi3em5XLwdVSCPkZzY5mlXmgry9KMgYTCSF26k9nQnFcHy9xBobOxIn8S8jx3v9AbMGU3gJU9oL3i3jFFgez8yJqT8qkKUmPFoQJF7sx5wDUC9kynQiPcjHB46rYUDDAeBDVt7O+iRFuj6mtsnsveThGKISPfXcEQQqtVbUEMxdx"' +
              '}' +
          '}';

        ResponseJson.ReadFrom(ResponseText);
        DEAuditMgt.DeAuxInfoInsertResponse(DeAuditAux, ResponseJson);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR DE Fiskaly Communication", 'OnBeforeSendHttpRequestForGetTSSClientList', '', false, false)]
    local procedure OnBeforeSendHttpRequestForGetTSSClientList(sender: Codeunit "NPR DE Fiskaly Communication"; DETSS: Record "NPR DE TSS"; ResponseJson: JsonToken; var PosUnitAuxDE: Record "NPR DE POS Unit Aux. Info"; var IsHandled: Boolean)
    var
        ResponseText: Text;
    begin
        IsHandled := true;

        ResponseText := '{' +
                '"data": [' +
                    '{' +
                        '"serial_number": "string",' +
                        '"state": "REGISTERED",' +
                        '"tss_id": "' + DETSS.SystemId + '",' +
                        '"metadata": {' +
                            '"my_property_1": "1234",' +
                            '"my_property_2": "https://my-internal-system/path/to/resource/1234"' +
                        '},' +
                        '"_id": "' + CreateGuid() + '",' +
                        '"_type": "CLIENT",' +
                        '"_env": "TEST",' +
                        '"_version": "2.1.18",' +
                        '"time_creation": 1577833200,' +
                        '"time_update": 1577833200' +
                    '},' +
                    '{' +
                        '"serial_number": "string",' +
                        '"state": "REGISTERED",' +
                        '"tss_id": "' + DETSS.SystemId + '",' +
                        '"metadata": {' +
                            '"my_property_1": "1234",' +
                            '"my_property_2": "https://my-internal-system/path/to/resource/1234"' +
                        '},' +
                        '"_id": "' + CreateGuid() + '",' +
                        '"_type": "CLIENT",' +
                        '"_env": "TEST",' +
                        '"_version": "2.1.18",' +
                        '"time_creation": 1577833200,' +
                        '"time_update": 1577833200' +
                    '},' +
                    '{' +
                        '"serial_number": "string",' +
                        '"state": "REGISTERED",' +
                        '"tss_id": "' + DETSS.SystemId + '",' +
                        '"metadata": {' +
                            '"my_property_1": "1234",' +
                            '"my_property_2": "https://my-internal-system/path/to/resource/1234"' +
                        '},' +
                        '"_id": "' + CreateGuid() + '",' +
                        '"_type": "CLIENT",' +
                        '"_env": "TEST",' +
                        '"_version": "2.1.18",' +
                        '"time_creation": 1577833200,' +
                        '"time_update": 1577833200' +
                    '}' +
                '],' +
                '"count": 9007199254740991,' +
                '"_type": "CLIENT_LIST",' +
                '"_env": "TEST",' +
                '"_version": "2.1.18"' +
            '}';
        ResponseJson.ReadFrom(ResponseText);

        sender.UpdateDeTssClientFromFiskaly(PosUnitAuxDE, ResponseJson);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR DE Fiskaly Communication", 'OnBeforeSendHttpRequestForUpsertTaxpayer', '', false, false)]
    local procedure HandleOnBeforeSendHttpRequestForUpsertTaxpayer(sender: Codeunit "NPR DE Fiskaly Communication"; var ConnectionParameterSet: Record "NPR DE Audit Setup"; var ResponseJsonOut: JsonToken; var IsHandled: Boolean)
    var
        ResponseText: Text;
    begin
        ResponseText :=
            '{' +
            '   "tax_number": "' + ConnectionParameterSet."Taxpayer Registration No." + '",' +
            '   "tax_office_number": "' + ConnectionParameterSet."Taxpayer Tax Office Number" + '",' +
            '   "general_information": {' +
            '       "person": "' + Enum::"NPR DE Taxpayer Person Type".Names().Get(Enum::"NPR DE Taxpayer Person Type".Ordinals().IndexOf(ConnectionParameterSet."Taxpayer Person Type".AsInteger())) + '",' +
            '       "information": {' +
            '           "company_name": "' + ConnectionParameterSet."Taxpayer Company Name" + '",' +
            '           "legal_form": "' + Enum::"NPR DE Taxpayer Legal Form".Names().Get(Enum::"NPR DE Taxpayer Legal Form".Ordinals().IndexOf(ConnectionParameterSet."Taxpayer Legal Form".AsInteger())) + '"' +
            '       },' +
            '       "address": {' +
            '           "post_address": {' +
            '               "street": "' + ConnectionParameterSet."Taxpayer Street" + '",' +
            '               "house_number": "' + ConnectionParameterSet."Taxpayer House Number" + '",' +
            '               "town": "' + ConnectionParameterSet."Taxpayer Town" + '",' +
            '               "zip_code": "' + ConnectionParameterSet."Taxpayer ZIP Code" + '"' +
            '           }' +
            '       },' +
            '   },' +
            '   "metadata": {' +
            '       "bc_company_name": "' + CompanyName() + '",' +
            '       "bc_code": "' + ConnectionParameterSet."Primary Key" + '",' +
            '       "bc_description": "' + ConnectionParameterSet.Description + '"' +
            '   }' +
            '}';

        ResponseJsonOut.ReadFrom(ResponseText);
        sender.PopulateConnectionParameterSetForTaxpayer(ConnectionParameterSet, ResponseJsonOut);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR DE Fiskaly Communication", 'OnBeforeSendHttpRequestForRetrieveTaxpayer', '', false, false)]
    local procedure HandleOnBeforeSendHttpRequestForRetrieveTaxpayer(sender: Codeunit "NPR DE Fiskaly Communication"; var ConnectionParameterSet: Record "NPR DE Audit Setup"; var ResponseJsonOut: JsonToken; var IsHandled: Boolean)
    var
        LibraryUtility: Codeunit "Library - Utility";
        ResponseText: Text;
    begin
        ResponseText :=
            '{' +
            '   "tax_number": "' + GetTaxpayerRegistrationNo() + '",' +
            '   "tax_office_number": "' + GetTaxpayerTaxOfficeNumber() + '",' +
            '   "general_information": {' +
            '       "person": "' + Enum::"NPR DE Taxpayer Person Type".Names().Get(Enum::"NPR DE Taxpayer Person Type".Ordinals().IndexOf(Enum::"NPR DE Taxpayer Person Type"::legal.AsInteger())) + '",' +
            '       "information": {' +
            '           "company_name": "' + LibraryUtility.GenerateRandomAlphabeticText(MaxStrLen(ConnectionParameterSet."Taxpayer Company Name"), 1) + '",' +
            '           "legal_form": "' + Enum::"NPR DE Taxpayer Legal Form".Names().Get(Enum::"NPR DE Taxpayer Legal Form".Ordinals().IndexOf(Enum::"NPR DE Taxpayer Legal Form"::"91".AsInteger())) + '"' +
            '       },' +
            '       "address": {' +
            '           "post_address": {' +
            '               "street": "' + LibraryUtility.GenerateRandomAlphabeticText(MaxStrLen(ConnectionParameterSet."Taxpayer Street"), 1) + '",' +
            '               "house_number": "' + LibraryUtility.GenerateRandomNumericText(MaxStrLen(ConnectionParameterSet."Taxpayer House Number")) + '",' +
            '               "town": "' + GetTaxpayerTown() + '",' +
            '               "zip_code": "' + GetTaxpayerZIPCode() + '"' +
            '           }' +
            '       },' +
            '   },' +
            '   "metadata": {' +
            '       "bc_company_name": "' + CompanyName() + '",' +
            '       "bc_code": "' + ConnectionParameterSet."Primary Key" + '",' +
            '       "bc_description": "' + ConnectionParameterSet.Description + '"' +
            '   }' +
            '}';

        ResponseJsonOut.ReadFrom(ResponseText);
        sender.PopulateConnectionParameterSetForTaxpayer(ConnectionParameterSet, ResponseJsonOut);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR DE Fiskaly Communication", 'OnBeforeSendHttpRequestForUpsertEstablishment', '', false, false)]
    local procedure HandleOnBeforeSendHttpRequestForUpsertEstablishment(sender: Codeunit "NPR DE Fiskaly Communication"; var DEEstablishment: Record "NPR DE Establishment"; var ResponseJsonOut: JsonToken; var IsHandled: Boolean)
    var
        ResponseText: Text;
    begin
        if DEEstablishment."Decommissioning Date" = 0D then
            ResponseText :=
                '{' +
                '   "address": {' +
                '       "street": "' + DEEstablishment.Street + '",' +
                '       "house_number": "' + DEEstablishment."House Number" + '",' +
                '       "town": "' + DEEstablishment.Town + '",' +
                '       "zip_code": "' + DEEstablishment."ZIP Code" + '"' +
                '   },' +
                '   "metadata": {' +
                '       "bc_company_name": "' + CompanyName() + '",' +
                '       "bc_code": "' + DEEstablishment."POS Store Code" + '",' +
                '       "bc_description": "' + DEEstablishment.Description + '"' +
                '   }' +
                '}'
        else
            ResponseText :=
                '{' +
                '   "address": {' +
                '       "street": "' + DEEstablishment.Street + '",' +
                '       "house_number": "' + DEEstablishment."House Number" + '",' +
                '       "town": "' + DEEstablishment.Town + '",' +
                '       "zip_code": "' + DEEstablishment."ZIP Code" + '"' +
                '   },' +
                '   "decommissioning_date": "' + Format(DEEstablishment."Decommissioning Date", 0, '<Day,2>.<Month,2>.<Year4>') + '",' +
                '   "metadata": {' +
                '       "bc_company_name": "' + CompanyName() + '",' +
                '       "bc_code": "' + DEEstablishment."POS Store Code" + '",' +
                '       "bc_description": "' + DEEstablishment.Description + '"' +
                '   }' +
                '}';

        ResponseJsonOut.ReadFrom(ResponseText);
        sender.PopulateEstablishment(DEEstablishment, ResponseJsonOut);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR DE Fiskaly Communication", 'OnBeforeSendHttpRequestForRetrieveEstablishment', '', false, false)]
    local procedure HandleOnBeforeSendHttpRequestForRetrieveEstablishment(sender: Codeunit "NPR DE Fiskaly Communication"; var DEEstablishment: Record "NPR DE Establishment"; var ResponseJsonOut: JsonToken; var IsHandled: Boolean)
    var
        LibraryUtility: Codeunit "Library - Utility";
        ResponseText: Text;
    begin
        ResponseText :=
            '{' +
            '   "address": {' +
            '       "street": "' + LibraryUtility.GenerateRandomAlphabeticText(MaxStrLen(DEEstablishment.Street), 1) + '",' +
            '       "house_number": "' + LibraryUtility.GenerateRandomNumericText(MaxStrLen(DEEstablishment."House Number")) + '",' +
            '       "town": "' + GetTaxpayerTown() + '",' +
            '       "zip_code": "' + GetTaxpayerZIPCode() + '"' +
            '   },' +
            '   "metadata": {' +
            '       "bc_company_name": "' + CompanyName() + '",' +
            '       "bc_code": "' + DEEstablishment."POS Store Code" + '",' +
            '       "bc_description": "' + DEEstablishment.Description + '"' +
            '   }' +
            '}';

        ResponseJsonOut.ReadFrom(ResponseText);
        sender.PopulateEstablishment(DEEstablishment, ResponseJsonOut);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR DE Fiskaly Communication", 'OnBeforeSendHttpRequestForUpsertClientAdditionalData', '', false, false)]
    local procedure HandleOnBeforeSendHttpRequestForUpsertClientAdditionalData(sender: Codeunit "NPR DE Fiskaly Communication"; var DETSSClient: Record "NPR DE POS Unit Aux. Info"; var ResponseJsonOut: JsonToken; var IsHandled: Boolean)
    var
        ResponseText: Text;
    begin
        if DETSSClient."Decommissioning Date" = 0D then
            ResponseText :=
                '{' +
                '   "date_acquisition": "' + Format(DETSSClient."Acquisition Date", 0, '<Day,2>.<Month,2>.<Year4>') + '",' +
                '   "date_commissioning": "' + Format(DETSSClient."Commissioning Date", 0, '<Day,2>.<Month,2>.<Year4>') + '",' +
                '   "manufacturer": "' + DETSSClient."Cash Register Brand" + '",' +
                '   "model": "' + DETSSClient."Cash Register Model" + '",' +
                '   "software": "' + DETSSClient.Software + '",' +
                '   "type": "' + Enum::"NPR DE Client Type".Names().Get(Enum::"NPR DE Client Type".Ordinals().IndexOf(DETSSClient."Client Type".AsInteger())) + '"' +
                '}'
        else
            ResponseText :=
                '{' +
                '   "date_acquisition": "' + Format(DETSSClient."Acquisition Date", 0, '<Day,2>.<Month,2>.<Year4>') + '",' +
                '   "date_commissioning": "' + Format(DETSSClient."Commissioning Date", 0, '<Day,2>.<Month,2>.<Year4>') + '",' +
                '   "date_decommissioning": "' + Format(DETSSClient."Decommissioning Date", 0, '<Day,2>.<Month,2>.<Year4>') + '",' +
                '   "manufacturer": "' + DETSSClient."Cash Register Brand" + '",' +
                '   "model": "' + DETSSClient."Cash Register Model" + '",' +
                '   "software": "' + DETSSClient.Software + '",' +
                '   "type": "' + Enum::"NPR DE Client Type".Names().Get(Enum::"NPR DE Client Type".Ordinals().IndexOf(DETSSClient."Client Type".AsInteger())) + '"' +
                '}';

        ResponseJsonOut.ReadFrom(ResponseText);
        sender.PopulateClientAdditionalData(DETSSClient, ResponseJsonOut);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR DE Fiskaly Communication", 'OnBeforeSendHttpRequestForRetrieveClientAdditionalData', '', false, false)]
    local procedure HandleOnBeforeSendHttpRequestForRetrieveClientAdditionalData(sender: Codeunit "NPR DE Fiskaly Communication"; var DETSSClient: Record "NPR DE POS Unit Aux. Info"; var ResponseJsonOut: JsonToken; var IsHandled: Boolean)
    var
        ResponseText: Text;
    begin
        ResponseText :=
            '{' +
            '   "date_acquisition": "' + Format(Today(), 0, '<Day,2>.<Month,2>.<Year4>') + '",' +
            '   "date_commissioning": "' + Format(Today(), 0, '<Day,2>.<Month,2>.<Year4>') + '",' +
            '   "manufacturer": "' + GetCashRegisterBrand() + '",' +
            '   "model": "' + GetCashRegisterModel() + '",' +
            '   "software": "' + GetSoftware() + '",' +
            '   "type": "' + Enum::"NPR DE Client Type".Names().Get(Enum::"NPR DE Client Type".Ordinals().IndexOf(Enum::"NPR DE Client Type"::"1".AsInteger())) + '"' +
            '}';

        ResponseJsonOut.ReadFrom(ResponseText);
        sender.PopulateClientAdditionalData(DETSSClient, ResponseJsonOut);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR DE Fiskaly Communication", 'OnBeforeSendHttpRequestForCreateSubmission', '', false, false)]
    local procedure HandleOnBeforeSendHttpRequestForCreateSubmission(sender: Codeunit "NPR DE Fiskaly Communication"; var DESubmission: Record "NPR DE Submission"; var ResponseJsonOut: JsonToken; var IsHandled: Boolean)
    var
        ResponseText: Text;
    begin
        ResponseText :=
            '{' +
            '   "establishment_id": "' + Format(DESubmission."Establishment Id", 0, 4).ToLower() + '",' +
            '   "state": "' + Enum::"NPR DE Submission State".Names().Get(Enum::"NPR DE Submission State".Ordinals().IndexOf(Enum::"NPR DE Submission State"::CREATED.AsInteger())) + '",' +
            '   "time_created": "' + Format(CurrentDateTime(), 0, 9) + '",' +
            '   "metadata": {' +
            '       "bc_company_name": "' + CompanyName() + '",' +
            '       "bc_entry_no": "' + Format(DESubmission."Entry No.") + '",' +
            '       "bc_pos_store_code": "' + DESubmission."POS Store Code" + '"' +
            '   }' +
            '}';

        ResponseJsonOut.ReadFrom(ResponseText);
        sender.PopulateSubmission(DESubmission, ResponseJsonOut);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR DE Fiskaly Communication", 'OnBeforeSendHttpRequestForRetrieveSubmission', '', false, false)]
    local procedure HandleOnBeforeSendHttpRequestForRetrieveSubmission(sender: Codeunit "NPR DE Fiskaly Communication"; var DESubmission: Record "NPR DE Submission"; var ResponseJsonOut: JsonToken; var IsHandled: Boolean)
    var
        ResponseText: Text;
    begin
        ResponseText :=
            '{' +
            '   "establishment_id": "' + Format(DESubmission."Establishment Id", 0, 4).ToLower() + '",' +
            '   "state": "' + Enum::"NPR DE Submission State".Names().Get(Enum::"NPR DE Submission State".Ordinals().IndexOf(Enum::"NPR DE Submission State"::VALIDATION_TRIGGERED.AsInteger())) + '",' +
            '   "time_created": "' + Format(CurrentDateTime(), 0, 9) + '",' +
            '   "time_generated": "' + Format(CurrentDateTime(), 0, 9) + '",' +
            '   "metadata": {' +
            '       "bc_company_name": "' + CompanyName() + '",' +
            '       "bc_entry_no": "' + Format(DESubmission."Entry No.") + '",' +
            '       "bc_pos_store_code": "' + DESubmission."POS Store Code" + '"' +
            '   }' +
            '}';

        ResponseJsonOut.ReadFrom(ResponseText);
        sender.PopulateSubmission(DESubmission, ResponseJsonOut);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR DE Fiskaly Communication", 'OnBeforeSendHttpRequestForTriggerSubmissionTransmission', '', false, false)]
    local procedure HandleOnBeforeSendHttpRequestForTriggerSubmissionTransmission(sender: Codeunit "NPR DE Fiskaly Communication"; var DESubmission: Record "NPR DE Submission"; var ResponseJsonOut: JsonToken; var IsHandled: Boolean)
    var
        ResponseText: Text;
    begin
        ResponseText :=
            '{' +
            '   "establishment_id": "' + Format(DESubmission."Establishment Id", 0, 4).ToLower() + '",' +
            '   "state": "' + Enum::"NPR DE Submission State".Names().Get(Enum::"NPR DE Submission State".Ordinals().IndexOf(Enum::"NPR DE Submission State"::TRANSMISSION_PENDING.AsInteger())) + '",' +
            '   "time_created": "' + Format(CurrentDateTime(), 0, 9) + '",' +
            '   "time_generated": "' + Format(CurrentDateTime(), 0, 9) + '",' +
            '   "metadata": {' +
            '       "bc_company_name": "' + CompanyName() + '",' +
            '       "bc_entry_no": "' + Format(DESubmission."Entry No.") + '",' +
            '       "bc_pos_store_code": "' + DESubmission."POS Store Code" + '"' +
            '   }' +
            '}';

        ResponseJsonOut.ReadFrom(ResponseText);
        sender.PopulateSubmission(DESubmission, ResponseJsonOut);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR DE Fiskaly Communication", 'OnBeforeSendHttpRequestForCancelSubmissionTransmission', '', false, false)]
    local procedure HandleOnBeforeSendHttpRequestForCancelSubmissionTransmission(sender: Codeunit "NPR DE Fiskaly Communication"; var DESubmission: Record "NPR DE Submission"; var ResponseJsonOut: JsonToken; var IsHandled: Boolean)
    var
        ResponseText: Text;
    begin
        ResponseText :=
            '{' +
            '   "establishment_id": "' + Format(DESubmission."Establishment Id", 0, 4).ToLower() + '",' +
            '   "state": "' + Enum::"NPR DE Submission State".Names().Get(Enum::"NPR DE Submission State".Ordinals().IndexOf(Enum::"NPR DE Submission State"::TRANSMISSION_CANCELLED.AsInteger())) + '",' +
            '   "time_created": "' + Format(CurrentDateTime(), 0, 9) + '",' +
            '   "time_generated": "' + Format(CurrentDateTime(), 0, 9) + '",' +
            '   "metadata": {' +
            '       "bc_company_name": "' + CompanyName() + '",' +
            '       "bc_entry_no": "' + Format(DESubmission."Entry No.") + '",' +
            '       "bc_pos_store_code": "' + DESubmission."POS Store Code" + '"' +
            '   }' +
            '}';

        ResponseJsonOut.ReadFrom(ResponseText);
        sender.PopulateSubmission(DESubmission, ResponseJsonOut);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR DE Audit Mgt.", 'OnBeforeCheckTssJobQueue', '', false, false)]
    local procedure OnBeforeCheckTssJobQueue(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR DE Audit Mgt.", 'OnBeforeCheckDSFINVKJobQueue', '', false, false)]
    local procedure OnBeforeCheckDSFINVKJobQueue(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;
    #endregion Http Mock Response Subscribers
}