codeunit 85193 "NPR Library AT Fiscal"
{
    EventSubscriberInstance = Manual;

    var
        SignedAsText: Text;

    internal procedure CreateAuditProfileAndATSetups(var POSAuditProfile: Record "NPR POS Audit Profile"; var VATPostingSetup: Record "VAT Posting Setup"; var POSUnit: Record "NPR POS Unit")
    begin
        InsertPOSAuditProfile(POSAuditProfile);
        AllowGapsInNoSeries(POSAuditProfile."Sales Ticket No. Series");

        EnableATFiscalization();

        UpdatePOSAuditProfileOnPOSUnit(POSUnit, POSAuditProfile.Code);

        SetVATPctOnVATPostingSetup(VATPostingSetup, 20);
        InsertATVATPostingSetupMapping(VATPostingSetup);
        InsertATPOSPaymentMethodMapping();
    end;

    local procedure InsertPOSAuditProfile(var POSAuditProfile: Record "NPR POS Audit Profile")
    var
        ATAuditMgt: Codeunit "NPR AT Audit Mgt.";
    begin
        POSAuditProfile.Init();
        POSAuditProfile.Code := ATAuditMgt.HandlerCode();
        POSAuditProfile."Audit Handler" := ATAuditMgt.HandlerCode();
        POSAuditProfile."Audit Log Enabled" := true;
        POSAuditProfile."Fill Sale Fiscal No. On" := POSAuditProfile."Fill Sale Fiscal No. On"::Successful;
        POSAuditProfile.AllowSalesAndReturnInSameTrans := false;
        POSAuditProfile."Balancing Fiscal No. Series" := CreateNumberSeries();
        POSAuditProfile."Sale Fiscal No. Series" := CreateNumberSeries();
        POSAuditProfile."Sales Ticket No. Series" := CreateNumberSeries();
        POSAuditProfile."Credit Sale Fiscal No. Series" := CreateNumberSeries();
        POSAuditProfile.Insert();
    end;

    local procedure AllowGapsInNoSeries(SeriesCode: Code[20])
    var
        NoSeriesLine: Record "No. Series Line";
    begin
        NoSeriesLine.SetRange("Series Code", SeriesCode);
        NoSeriesLine.SetRange(Open, true);
        NoSeriesLine.FindLast();
        NoSeriesLine.Validate("Allow Gaps in Nos.", true);
        NoSeriesLine.Modify();
    end;

    internal procedure EnableATFiscalization()
    var
        ATFiscalizationSetup: Record "NPR AT Fiscalization Setup";
        FiskalyAPIURLLbl: Label 'https://rksv.fiskaly.com/api/v1/', Locked = true;
    begin
        if not ATFiscalizationSetup.Get() then
            ATFiscalizationSetup.Insert();

        ATFiscalizationSetup."AT Fiscal Enabled" := true;
        ATFiscalizationSetup."Fiskaly API URL" := FiskalyAPIURLLbl;
        ATFiscalizationSetup.Modify();
    end;

    local procedure UpdatePOSAuditProfileOnPOSUnit(var POSUnit: Record "NPR POS Unit"; POSAuditProfileCode: Code[20])
    begin
        POSUnit."POS Audit Profile" := POSAuditProfileCode;
        POSUnit.Modify();
    end;

    local procedure SetVATPctOnVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; VATPct: Decimal)
    begin
        VATPostingSetup."VAT %" := VATPct;
        VATPostingSetup.Modify();
    end;

    internal procedure CreateATOrganization(var ATOrganization: Record "NPR AT Organization")
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        ATOrganization.Init();
        ATOrganization.Validate(
            Code,
            CopyStr(
                LibraryUtility.GenerateRandomCode(ATOrganization.FieldNo(Code), Database::"NPR AT Organization"),
                1,
                LibraryUtility.GetFieldLength(Database::"NPR AT Organization", ATOrganization.FieldNo(Code))));
        ATOrganization.Validate(Description, ATOrganization.Code);  // Validating Description as Code because value is not important.
        ATOrganization.Insert(true);
    end;

    internal procedure AuthenticateATOrganizaiton(var ATOrganization: Record "NPR AT Organization")
    begin
        ATOrganization.Validate("FON Authentication Status", ATOrganization."FON Authentication Status"::AUTHENTICATED);
        ATOrganization.Validate("FON Authenticated At", CurrentDateTime());
        ATOrganization.Modify(true);
    end;

    internal procedure CreateATSCU(var ATSCU: Record "NPR AT SCU")
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        ATSCU.Init();
        ATSCU.Validate(
            Code,
            CopyStr(
                LibraryUtility.GenerateRandomCode(ATSCU.FieldNo(Code), Database::"NPR AT SCU"),
                1,
                LibraryUtility.GetFieldLength(Database::"NPR AT SCU", ATSCU.FieldNo(Code))));
        ATSCU.Validate(Description, ATSCU.Code);  // Validating Description as Code because value is not important.
        ATSCU.Insert(true);
    end;

    internal procedure InitializeATSCU(var ATSCU: Record "NPR AT SCU"; ATOrganizationCode: Code[20])
    begin
        ATSCU.Validate("AT Organization Code", ATOrganizationCode);
        ATSCU.Validate(State, ATSCU.State::INITIALIZED);
        ATSCU.Validate("Certificate Serial Number", Format(CreateGuid(), 0, 4));
        ATSCU.Validate("Pending At", CurrentDateTime());
        ATSCU.Validate("Created At", CurrentDateTime());
        ATSCU.Validate("Initialized At", CurrentDateTime());
        ATSCU.Modify(true);
    end;

    internal procedure CreateATCashRegister(var ATCashRegister: Record "NPR AT Cash Register"; POSUnitNo: Code[10])
    begin
        ATCashRegister.Init();
        ATCashRegister.Validate("POS Unit No.", POSUnitNo);
        ATCashRegister.Validate(Description, POSUnitNo);
        ATCashRegister.Insert(true);
    end;

    internal procedure InitializeATCashRegister(var ATCashRegister: Record "NPR AT Cash Register"; ATSCUCode: Code[20])
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        ATCashRegister.Validate("AT SCU Code", ATSCUCode);
        ATCashRegister.Validate(State, ATCashRegister.State::INITIALIZED);
        ATCashRegister.Validate("Serial Number", LibraryUtility.GenerateRandomAlphabeticText(10, 1));
        ATCashRegister.Validate("Created At", CurrentDateTime());
        ATCashRegister.Validate("Registered At", CurrentDateTime());
        ATCashRegister.Validate("Initialized At", CurrentDateTime());
        ATCashRegister.Validate("Initialization Receipt Id", CreateGuid());
        ATCashRegister.Modify(true);
    end;

    local procedure InsertATVATPostingSetupMapping(var VATPostingSetup: Record "VAT Posting Setup")
    var
        ATVATPostingSetupMap: Record "NPR AT VAT Posting Setup Map";
    begin
        if not ATVATPostingSetupMap.Get(VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group") then begin
            ATVATPostingSetupMap.Init();
            ATVATPostingSetupMap."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
            ATVATPostingSetupMap."VAT Prod. Posting Group" := VATPostingSetup."VAT Prod. Posting Group";
            ATVATPostingSetupMap."VAT Identifier" := VATPostingSetup."VAT Identifier";
            ATVATPostingSetupMap."AT VAT Rate" := ATVATPostingSetupMap."AT VAT Rate"::STANDARD;
            ATVATPostingSetupMap.Insert();
        end;
    end;

    local procedure InsertATPOSPaymentMethodMapping()
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        ATPOSPaymentMethodMap: Record "NPR AT POS Payment Method Map";
    begin
        POSPaymentMethod.FindSet();
        repeat
            if not ATPOSPaymentMethodMap.Get(POSPaymentMethod.Code) then begin
                ATPOSPaymentMethodMap.Init();
                ATPOSPaymentMethodMap."POS Payment Method Code" := POSPaymentMethod.Code;
                ATPOSPaymentMethodMap."AT Payment Type" := ATPOSPaymentMethodMap."AT Payment Type"::CASH;
                ATPOSPaymentMethodMap.Insert();
            end;
        until POSPaymentMethod.Next() = 0;
    end;

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

    internal procedure SetSigned(Signed: Boolean)
    begin
        if Signed then
            SignedAsText := 'true'
        else
            SignedAsText := 'false';
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR AT Fiskaly Communication", 'OnBeforeSetAuthorizationOnPrepareHttpRequest', '', false, false)]
    local procedure HandleOnBeforeSetAuthorizationOnPrepareHttpRequest(var RequestHeaders: HttpHeaders; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR AT Fiskaly Communication", 'OnBeforeSendHttpRequestForAuthenticateFON', '', false, false)]
    local procedure HandleOnBeforeSendHttpRequestForAuthenticateFON(sender: Codeunit "NPR AT Fiskaly Communication"; var ResponseText: Text; var ATOrganization: Record "NPR AT Organization"; var IsHandled: Boolean)
    begin
        ResponseText :=
            '{' +
            '   "fon_participant_id": "mockdata123",' +
            '   "fon_user_id": "mock-data",' +
            '   "authentication_status": "AUTHENTICATED",' +
            '   "time_authentication": 1718276232' +
            '}';

        sender.PopulateATOrganizationForRetrieveFONStatus(ATOrganization, ResponseText);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR AT Fiskaly Communication", 'OnBeforeSendHttpRequestForRetrieveFONStatus', '', false, false)]
    local procedure HandleOnBeforeSendHttpRequestForRetrieveFONStatus(sender: Codeunit "NPR AT Fiskaly Communication"; var ResponseText: Text; var ATOrganization: Record "NPR AT Organization"; var IsHandled: Boolean)
    begin
        ResponseText :=
            '{' +
            '   "fon_participant_id": "mockdata123",' +
            '   "fon_user_id": "mock-data",' +
            '   "authentication_status": "AUTHENTICATED",' +
            '   "time_authentication": 1718276232' +
            '}';

        sender.PopulateATOrganizationForAuthenticateFON(ATOrganization, ResponseText);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR AT Fiskaly Communication", 'OnBeforeSendHttpRequestForCreateSCU', '', false, false)]
    local procedure HandleOnBeforeSendHttpRequestForCreateSCU(sender: Codeunit "NPR AT Fiskaly Communication"; var ResponseText: Text; var ATSCU: Record "NPR AT SCU"; var IsHandled: Boolean)
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();

        ResponseText :=
            '{' +
            '   "_id": "' + Format(ATSCU.SystemId, 0, 4).ToLower() + '",' +
            '   "_type": "SIGNATURE_CREATION_UNIT",' +
            '   "_env": "TEST",' +
            '   "_version": "1.2.4",' +
            '   "state": "CREATED",' +
            '   "legal_entity_id": { ' +
            '       "vat_id": "' + CompanyInformation."VAT Registration No." + '"' +
            '   },' +
            '   "legal_entity_name": "' + CompanyInformation.Name + '",' +
            '   "certificate_serial_number": "5c8e5", ' +
            '   "time_pending": 1577833200,' +
            '   "time_creation": 1577833200,' +
            '   "metadata": {' +
            '       "bc_company_name": "' + CompanyName() + '",' +
            '       "bc_code": "' + ATSCU.Code + '",' +
            '       "bc_description": "' + ATSCU.Description + '"' +
            '   }' +
            '}';

        sender.PopulateATSCUForCreateSCU(ATSCU, ResponseText);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR AT Fiskaly Communication", 'OnBeforeSendHttpRequestForRetrieveSCU', '', false, false)]
    local procedure HandleOnBeforeSendHttpRequestForRetrieveSCU(sender: Codeunit "NPR AT Fiskaly Communication"; var ResponseText: Text; var ATSCU: Record "NPR AT SCU"; var IsHandled: Boolean)
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();

        ResponseText :=
            '{' +
            '   "_id": "' + Format(ATSCU.SystemId, 0, 4).ToLower() + '",' +
            '   "_type": "SIGNATURE_CREATION_UNIT",' +
            '   "_env": "TEST",' +
            '   "_version": "1.2.4",' +
            '   "state": "DECOMMISSIONED",' +
            '   "legal_entity_id": { ' +
            '       "vat_id": "' + CompanyInformation."VAT Registration No." + '"' +
            '   },' +
            '   "legal_entity_name": "' + CompanyInformation.Name + '",' +
            '   "certificate_serial_number": "5c8e5", ' +
            '   "time_pending": 1577833200,' +
            '   "time_creation": 1577833200,' +
            '   "metadata": {' +
            '       "bc_company_name": "' + CompanyName() + '",' +
            '       "bc_code": "' + ATSCU.Code + '",' +
            '       "bc_description": "' + ATSCU.Description + '"' +
            '   },' +
            '   "time_initialization": 1577833200,' +
            '   "time_decommission": 1577833200' +
            '}';

        sender.PopulateATSCUForRetrieveSCU(ATSCU, ResponseText);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR AT Fiskaly Communication", 'OnBeforeSendHttpRequestForUpdateSCU', '', false, false)]
    local procedure HandleOnBeforeSendHttpRequestForUpdateSCU(sender: Codeunit "NPR AT Fiskaly Communication"; var ResponseText: Text; var ATSCU: Record "NPR AT SCU"; var IsHandled: Boolean)
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();

        ResponseText :=
            '{' +
            '   "_id": "' + Format(ATSCU.SystemId, 0, 4).ToLower() + '",' +
            '   "_type": "SIGNATURE_CREATION_UNIT",' +
            '   "_env": "TEST",' +
            '   "_version": "1.2.4",' +
            '   "state": "INITIALIZED",' +
            '   "legal_entity_id": { ' +
            '       "vat_id": "' + CompanyInformation."VAT Registration No." + '"' +
            '   },' +
            '   "legal_entity_name": "' + CompanyInformation.Name + '",' +
            '   "certificate_serial_number": "' + ATSCU."Certificate Serial Number" + '", ' +
            '   "time_pending": 1577833200,' +
            '   "time_creation": 1577833200,' +
            '   "metadata": {' +
            '       "bc_company_name": "' + CompanyName() + '",' +
            '       "bc_code": "' + ATSCU.Code + '",' +
            '       "bc_description": "' + ATSCU.Description + '"' +
            '   },' +
            '   "time_initialization": 1577833200' +
            '}';

        sender.PopulateATSCUForUpdateSCU(ATSCU, ResponseText);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR AT Fiskaly Communication", 'OnBeforeSendHttpRequestForCreateCashRegister', '', false, false)]
    local procedure HandleOnBeforeSendHttpRequestForCreateCashRegister(sender: Codeunit "NPR AT Fiskaly Communication"; var ResponseText: Text; var ATCashRegister: Record "NPR AT Cash Register"; var IsHandled: Boolean)
    begin
        ResponseText :=
            '{' +
            '   "_id": "' + Format(ATCashRegister.SystemId, 0, 4).ToLower() + '",' +
            '   "_type": "CASH_REGISTER",' +
            '   "_env": "TEST",' +
            '   "_version": "1.2.4",' +
            '   "state": "CREATED",' +
            '   "serial_number": "1",' +
            '   "turnover_counter": "0",' +
            '   "description": "' + ATCashRegister.Description + '",' +
            '   "time_creation": 1577833200,' +
            '   "metadata": {' +
            '       "bc_company_name": "' + CompanyName() + '",' +
            '       "bc_code": "' + ATCashRegister."POS Unit No." + '",' +
            '       "bc_description": "' + ATCashRegister.Description + '",' +
            '       "bc_scu_code": "' + ATCashRegister."AT SCU Code" + '"' +
            '   }' +
            '}';

        sender.PopulateATCashRegisterForCreateCashRegister(ATCashRegister, ResponseText);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR AT Fiskaly Communication", 'OnBeforeSendHttpRequestForRetrieveCashRegister', '', false, false)]
    local procedure HandleOnBeforeSendHttpRequestForRetrieveCashRegister(sender: Codeunit "NPR AT Fiskaly Communication"; var ResponseText: Text; var ATCashRegister: Record "NPR AT Cash Register"; var IsHandled: Boolean)
    begin
        ResponseText :=
            '{' +
            '   "_id": "' + Format(ATCashRegister.SystemId, 0, 4).ToLower() + '",' +
            '   "_type": "CASH_REGISTER",' +
            '   "_env": "TEST",' +
            '   "_version": "1.2.4",' +
            '   "state": "DECOMMISSIONED",' +
            '   "serial_number": "1",' +
            '   "turnover_counter": "0",' +
            '   "description": "' + ATCashRegister.Description + '",' +
            '   "time_creation": 1577833200,' +
            '   "metadata": {' +
            '       "bc_company_name": "' + CompanyName() + '",' +
            '       "bc_code": "' + ATCashRegister."POS Unit No." + '",' +
            '       "bc_description": "' + ATCashRegister.Description + '",' +
            '       "bc_scu_code": "' + ATCashRegister."AT SCU Code" + '"' +
            '   },' +
            '   "time_registration": 1577833200,' +
            '   "time_initialization": 1577833200,' +
            '   "initialization_receipt_id": "' + Format(CreateGuid(), 0, 4).ToLower() + '",' +
            '   "time_decommission": 1577833200,' +
            '   "decommission_receipt_id": "' + Format(CreateGuid(), 0, 4).ToLower() + '"' +
            '}';

        sender.PopulateATCashRegisterForRetrieveCashRegister(ATCashRegister, ResponseText);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR AT Fiskaly Communication", 'OnBeforeSendHttpRequestForUpdateCashRegister', '', false, false)]
    local procedure HandleOnBeforeSendHttpRequestForUpdateCashRegister(sender: Codeunit "NPR AT Fiskaly Communication"; var ResponseText: Text; var ATCashRegister: Record "NPR AT Cash Register"; var IsHandled: Boolean)
    begin
        ResponseText :=
            '{' +
            '   "_id": "' + Format(ATCashRegister.SystemId, 0, 4).ToLower() + '",' +
            '   "_type": "CASH_REGISTER",' +
            '   "_env": "TEST",' +
            '   "_version": "1.2.4",' +
            '   "state": "REGISTERED",' +
            '   "serial_number": "' + ATCashRegister."Serial Number" + '",' +
            '   "turnover_counter": "0",' +
            '   "description": "' + ATCashRegister.Description + '",' +
            '   "time_creation": 1577833200,' +
            '   "metadata": {' +
            '       "bc_company_name": "' + CompanyName() + '",' +
            '       "bc_code": "' + ATCashRegister."POS Unit No." + '",' +
            '       "bc_description": "' + ATCashRegister.Description + '",' +
            '       "bc_scu_code": "' + ATCashRegister."AT SCU Code" + '"' +
            '   },' +
            '   "time_registration": 1577833200' +
            '}';

        sender.PopulateATCashRegisterForUpdateCashRegister(ATCashRegister, ResponseText);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR AT Fiskaly Communication", 'OnBeforeSendHttpRequestForValidateReceipt', '', false, false)]
    local procedure HandleOnBeforeSendHttpRequestForValidateReceipt(sender: Codeunit "NPR AT Fiskaly Communication"; var ResponseText: Text; var ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info"; var IsHandled: Boolean)
    begin
        ResponseText :=
            '{' +
            '   "validation_result": "SUCCESS",' +
            '   "time_validation": 1577833200' +
            '}';

        sender.PopulateATPOSAuditLogAuxInfoForValidateReceipt(ATPOSAuditLogAuxInfo, ResponseText);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR AT Fiskaly Communication", 'OnBeforeSendHttpRequestForSignReceipt', '', false, false)]
    local procedure HandleOnBeforeSendHttpRequestForSignReceipt(sender: Codeunit "NPR AT Fiskaly Communication"; var ResponseText: Text; var ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info"; var IsHandled: Boolean)
    begin
        ResponseText :=
            '{' +
            '   "_id": "a1c66ed2-a263-4774-8acc-8eb69782e4d3",' +
            '   "_type": "RECEIPT",' +
            '   "_env": "TEST",' +
            '   "_version": "1.2.4",' +
            '   "signed":' + SignedAsText + ',' +
            '   "receipt_type": "NORMAL",' +
            '   "receipt_number": "1",' +
            '   "time_signature": 1717590850,' +
            '   "cash_register_id": "' + ATPOSAuditLogAuxInfo."AT Cash Register Id" + '",' +
            '   "cash_register_serial_number": "' + ATPOSAuditLogAuxInfo."AT Cash Register Serial Number" + '",' +
            '   "signature_creation_unit_id": "' + ATPOSAuditLogAuxInfo."AT SCU Id" + '",' +
            '   "qr_code_data": "_R1-AT3_DpsGIA_13_2024-06-05T14:34:10_10,00_0,00_0,00_0,00_0,00_MEy7sIwaAA8=_f5286073-ab7f-4550-8585-0653a9550677_JhuqOEnGmEI=_npU4fSqnkI8=",' +
            '   "schema": {' +
            '      "standard_v1": {' +
            '           "amounts_per_vat_rate": [' +
            '               {' +
            '                   "vat_rate": "STANDARD",' +
            '                   "amount": "10.00"' +
            '               }' +
            '           ],' +
            '           "amounts_per_payment_type": [' +
            '               {' +
            '                   "payment_type": "CASH",' +
            '                   "amount": "10.00",' +
            '                   "currency_code": "EUR"' +
            '               }' +
            '            ],' +
            '            "line_items": [' +
            '                {' +
            '                    "quantity": "1",' +
            '                    "text": "TEST DUMMY",' +
            '                    "price_per_unit": "10.00"' +
            '                }' +
            '            ]' +
            '       },' +
            '       "raw": {' +
            '           "gross_amount_standard": "10.00",' +
            '           "gross_amount_reduced_1": "0.00",' +
            '           "gross_amount_reduced_2": "0.00",' +
            '           "gross_amount_special": "0.00",' +
            '           "gross_amount_zero": "0.00"' +
            '       }' +
            '   },' +
            '   "metadata": {' +
            '       "bc_company_name": "' + CompanyName() + '",' +
            '       "bc_cash_register_code": "' + ATPOSAuditLogAuxInfo."POS Unit No." + '",' +
            '       "bc_scu_code": "' + ATPOSAuditLogAuxInfo."AT SCU Code" + '"' +
            '   },' +
            '   "hints": []' +
            '}';

        sender.PopulateATPOSAuditLogAuxInfoForSignReceipt(ATPOSAuditLogAuxInfo, ResponseText);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR AT Fiskaly Communication", 'OnBeforeSendHttpRequestForSignControlReceipt', '', false, false)]
    local procedure HandleOnBeforeSendHttpRequestForSignControlReceipt(sender: Codeunit "NPR AT Fiskaly Communication"; var ResponseText: Text; var ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info"; var IsHandled: Boolean)
    begin
        ResponseText :=
            '{' +
            '   "_id": "a1c66ed2-a263-4774-8acc-8eb69782e4d3",' +
            '   "_type": "RECEIPT",' +
            '   "_env": "TEST",' +
            '   "_version": "1.2.4",' +
            '   "signed": true,' +
            '   "receipt_type": "NORMAL",' +
            '   "receipt_number": "1",' +
            '   "time_signature": 1717590850,' +
            '   "cash_register_id": "' + ATPOSAuditLogAuxInfo."AT Cash Register Id" + '",' +
            '   "cash_register_serial_number": "' + ATPOSAuditLogAuxInfo."AT Cash Register Serial Number" + '",' +
            '   "signature_creation_unit_id": "' + ATPOSAuditLogAuxInfo."AT SCU Id" + '",' +
            '   "qr_code_data": "_R1-AT3_DpsGIA_13_2024-06-05T14:34:10_0,00_0,00_0,00_0,00_0,00_MEy7sIwaAA8=_f5286073-ab7f-4550-8585-0653a9550677_JhuqOEnGmEI=_npU4fSqnkI8=",' +
            '   "schema": {' +
            '      "standard_v1": {' +
            '           "amounts_per_vat_rate": [' +
            '               {' +
            '                   "vat_rate": "ZERO",' +
            '                   "amount": "0.00"' +
            '               }' +
            '           ],' +
            '            "line_items": [' +
            '                {' +
            '                    "quantity": "1",' +
            '                    "text": "Nullbeleg",' +
            '                    "price_per_unit": "0.00"' +
            '                }' +
            '            ]' +
            '       },' +
            '       "raw": {' +
            '           "gross_amount_standard": "0.00",' +
            '           "gross_amount_reduced_1": "0.00",' +
            '           "gross_amount_reduced_2": "0.00",' +
            '           "gross_amount_special": "0.00",' +
            '           "gross_amount_zero": "0.00"' +
            '       }' +
            '   },' +
            '   "metadata": {' +
            '       "bc_company_name": "' + CompanyName() + '",' +
            '       "bc_cash_register_code": "' + ATPOSAuditLogAuxInfo."POS Unit No." + '",' +
            '       "bc_scu_code": "' + ATPOSAuditLogAuxInfo."AT SCU Code" + '"' +
            '   },' +
            '   "hints": []' +
            '}';

        sender.PopulateATPOSAuditLogAuxInfoForSignControlReceipt(ATPOSAuditLogAuxInfo, ResponseText);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR AT Audit Mgt.", 'OnBeforePrintReceiptOnHandleOnAfterEndSale', '', false, false)]
    local procedure HandleOnBeforePrintReceiptOnHandleOnAfterEndSale(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;
}
