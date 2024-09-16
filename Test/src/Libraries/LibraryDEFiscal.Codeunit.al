codeunit 85213 "NPR Library DE Fiscal"
{
    EventSubscriberInstance = Manual;

    internal procedure CreateAuditProfileSetup(var POSAuditProfile: Record "NPR POS Audit Profile"; var POSUnit: Record "NPR POS Unit")
    var
        DEAuditSetup: Record "NPR DE Audit Setup";
        DETSS: Record "NPR DE TSS";
        DEPOSUnitAuxInfo: Record "NPR DE POS Unit Aux. Info";
        NoSeriesLine: Record "No. Series Line";
        LibraryDEFiscal: Codeunit "NPR Library DE Fiscal";
    begin
        POSAuditProfile.Init();
        POSAuditProfile.Code := HandlerCode();
        POSAuditProfile."Allow Printing Receipt Copy" := POSAuditProfile."Allow Printing Receipt Copy"::Always;
        POSAuditProfile."Audit Handler" := HandlerCode();
        POSAuditProfile."Audit Log Enabled" := true;
        POSAuditProfile."Fill Sale Fiscal No. On" := POSAuditProfile."Fill Sale Fiscal No. On"::Successful;
        POSAuditProfile."Balancing Fiscal No. Series" := CreateNumberSeries();
        POSAuditProfile."Sale Fiscal No. Series" := CreateNumberSeries();
        POSAuditProfile."Sales Ticket No. Series" := CreateNumberSeries();
        POSAuditProfile."Credit Sale Fiscal No. Series" := CreateNumberSeries();
        POSAuditProfile.Insert();
        NoSeriesLine.SetRange("Series Code", POSAuditProfile."Sales Ticket No. Series");
        NoSeriesLine.SetRange(Open, true);
        NoSeriesLine.FindLast();
        NoSeriesLine.Validate("Allow Gaps in Nos.", true);
        NoSeriesLine.Modify();

        POSUnit."POS Audit Profile" := POSAuditProfile.Code;
        POSUnit.Modify();

        BindSubscription(LibraryDEFiscal);
        CreateDEConnectionParamSet(DEAuditSetup);
        CreateTSSClient(DETSS, DEAuditSetup);
        CreateDEPOSUnitAuxInfo(DEPOSUnitAuxInfo, POSUnit, DETSS, DEAuditSetup);
        UnbindSubscription(LibraryDEFiscal);
    end;

    internal procedure HandlerCode(): Text
    var
        HandlerCodeTxt: Label 'DE_FISKALY', Locked = true, MaxLength = 20;
    begin
        exit(HandlerCodeTxt);
    end;

    internal procedure CreateNumberSeries(): Text
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        LibraryUtility.CreateNoSeries(NoSeries, true, false, false);
        LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, 'TEST_1', 'TEST_99999999');
        exit(NoSeries.Code);
    end;

    internal procedure CreateDEConnectionParamSet(var DEAuditSetup: Record "NPR DE Audit Setup")
    var
        DESecretMgt: Codeunit "NPR DE Secret Mgt.";
    begin
        DEAuditSetup.Init();
        DEAuditSetup."Primary Key" := GetTestConnectionParamCode();
        DEAuditSetup.Description := GetTestDescription();
        DEAuditSetup."Api URL" := GetConnectionParamApiURL();
        DEAuditSetup.Insert();
        DESecretMgt.SetSecretKey(DEAuditSetup.ApiKeyLbl(), '123');
        DESecretMgt.SetSecretKey(DEAuditSetup.ApiSecretLbl(), '123');
    end;

    internal procedure CreateTSSClient(var DETSS: Record "NPR DE TSS"; DEAuditSetup: Record "NPR DE Audit Setup")
    var
        DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
    begin
        DETSS.Init();
        DETSS.Code := '0001';
        DETSS.SystemId := CreateGuid();
        DETSS.Description := GetTestDescription();
        DETSS."Connection Parameter Set Code" := DEAuditSetup."Primary Key";
        DETSS.Insert();

        DEFiskalyCommunication.CreateTSS(DETSS, DEAuditSetup);
    end;

    internal procedure CreateDEPOSUnitAuxInfo(var DEPOSUnitAuxInfo: Record "NPR DE POS Unit Aux. Info"; POSUnit: Record "NPR POS Unit"; DETSS: Record "NPR DE TSS"; DEAuditSetup: Record "NPR DE Audit Setup")
    var
        DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
    begin
        DEPOSUnitAuxInfo.Init();
        DEPOSUnitAuxInfo."Cash Register Brand" := GetTestDEPOSUnitAuxInfoCashRegisterData();
        DEPOSUnitAuxInfo."Cash Register Model" := GetTestDEPOSUnitAuxInfoCashRegisterData();
        DEPOSUnitAuxInfo."TSS Code" := DETSS.Code;
        DEPOSUnitAuxInfo."POS Unit No." := POSUnit."No.";
        DEPOSUnitAuxInfo.Insert();

        DEFiskalyCommunication.CreateClient(DEPOSUnitAuxInfo);
    end;

    #region Standard record creating

    internal procedure CreatePOSUnit(var POSUnit: Record "NPR POS Unit"; var POSStore: Record "NPR POS Store"; var POSPostingProfile: Record "NPR POS Posting Profile")
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
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
        VATPostingSetup: Record "VAT Posting Setup";
        VATPostGroupMapper: Record "NPR VAT Post. Group Mapper";
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

    local procedure GetTestConnectionParamCode(): Code[20]
    begin
        exit('TEST');
    end;

    local procedure GetConnectionParamApiURL(): Text[250]
    begin
        exit('https://kassensichv-middleware.fiskaly.com/api/v2');
    end;

    local procedure GetTestDescription(): Text[100]
    begin
        exit('TEST');
    end;

    local procedure GetTestDEPOSUnitAuxInfoCashRegisterData(): Text[50]
    begin
        exit('TEST_BRAND');
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
        ResponseText: Text;
        JToken: JsonToken;
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