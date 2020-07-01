codeunit 6184513 "EFT MobilePay Integration"
{
    // NPR5.46/MMV /20181008 CASE 290734 Created object
    // NPR5.46.01/MMV /20181025 CASE 333953 Fixed incorrect mobile pay environment optionstring
    // NPR5.47/MMV /20181030 CASE 334510 Added string length check
    // NPR5.48/MMV /20190107 CASE 341674 Skip validation on import.
    // NPR5.49/MMV /20190312 CASE 345188 Renamed object
    // NPR5.51/MMV /20190821 CASE 363895 Rewrote unix timestamp to not use .NET
    // NPR5.51/MMV /20190827 CASE 352248 Made "assigned" fields editable for support edge cases.
    // NPR5.54/MMV /20200206 CASE 388507 Updated sandbox URL & minor adjustments.


    trigger OnRun()
    begin
    end;

    var
        Description: Label 'MobilePay by Danske Bank';
        EnvironmentOption: Label 'DEMO,PROD';
        NoCashback: Label 'MobilePay integration does not support cashback';
        EFTSetup: Record "EFT Setup";
        ServiceBaseURL: Text;
        ServiceHost: Text;
        LocationID: Text;
        MerchantID: Text;
        APIKey: Text;
        Demo: Boolean;
        PoSID: Text;
        PoSUnitID: Text;
        MissingPOSUnitSetup: Label '%1 %2 is missing %3 setup';
        InvalidParameter: Label '%1 setup for %2 %3 has invalid %4 configuration.';
        Text6014517: Label 'Cash register %1 registered with POS-ID %2.';
        Text6014518: Label 'Name for cash register %1 updated to %2.';
        Text6014519: Label 'cash register %1 has been settled';
        Text6014520: Label 'PoS Unit with ID %1 now updated with attachment to cash register %2.';
        Text6014521: Label 'PoS Unit with ID %1 now attached to cash register %2.';
        Text6014522: Label 'attachment to PoS Unit has now been removed.';
        Text6014523: Label 'attachment to PoS Unit has been correctly registered.';
        Text6014524: Label 'PoS Unit with ID %1 is attached to cash register %2 with PoS ID %3';
        INCORRECT_POS_ID: Label 'Incorrect setup. PoS Unit %1 is currently attached to PoS ID %2';
        Text10: Label 'Idle, no payment requests in queue';
        Text20: Label 'Payment request is sent to customer';
        Text30: Label 'Awaiting customer check-in';
        Text40: Label 'Customer has cancelled the payment request';
        Text50: Label 'Error';
        Text60: Label 'Awaiting a token-related payment request update';
        Text70: Label 'Awaiting a payment request by the customer';
        Text80: Label 'Payment request is accepted by the customer';
        Text100: Label 'Payment is confirmed';
        PoSUnitAssigned: Boolean;
        PoSRegistered: Boolean;
        PaymentTypePOS: Record "Payment Type POS";
        POSUnit: Record "POS Unit";
        Register: Record Register;

    procedure IntegrationType(): Text
    begin
        exit('MOBILEPAY');
    end;

    local procedure "// EFT Interface implementation"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnDiscoverIntegrations', '', false, false)]
    local procedure OnDiscoverIntegrations(var tmpEFTIntegrationType: Record "EFT Integration Type" temporary)
    begin
        tmpEFTIntegrationType.Init;
        tmpEFTIntegrationType.Code := IntegrationType();
        tmpEFTIntegrationType.Description := Description;
        tmpEFTIntegrationType."Codeunit ID" := CODEUNIT::"EFT MobilePay Integration";
        tmpEFTIntegrationType.Insert;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnConfigureIntegrationUnitSetup', '', false, false)]
    local procedure OnConfigureIntegrationUnitSetup(EFTSetup: Record "EFT Setup")
    var
        EFTTypePOSUnitGenParam: Record "EFT Type POS Unit Gen. Param.";
        EFTTypePOSUnitBLOBParam: Record "EFT Type POS Unit BLOB Param.";
        EFTInterface: Codeunit "EFT Interface";
    begin
        if EFTSetup."EFT Integration Type" <> IntegrationType() then
            exit;

        GetLocationID(EFTSetup);
        GetPoSID(EFTSetup);
        GetPosUnitID(EFTSetup);
        GetPoSUnitAssigned(EFTSetup);
        GetPoSRegistered(EFTSetup);

        EFTSetup.ShowEftPOSUnitParameters();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnConfigureIntegrationPaymentSetup', '', false, false)]
    local procedure OnConfigureIntegrationPaymentSetup(EFTSetup: Record "EFT Setup")
    var
        EFTTypePaymentBLOBParam: Record "EFT Type Payment BLOB Param.";
        EFTTypePaymentGenParam: Record "EFT Type Payment Gen. Param.";
    begin
        if EFTSetup."EFT Integration Type" <> IntegrationType() then
            exit;

        GetAPIKey(EFTSetup);
        GetMerchantID(EFTSetup);
        GetEnvironment(EFTSetup);

        EFTSetup.ShowEftPaymentParameters();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreatePaymentOfGoodsRequest', '', false, false)]
    local procedure OnCreatePaymentOfGoodsRequest(var EftTransactionRequest: Record "EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        InitializeGlobals(EftTransactionRequest."POS Payment Type Code", EftTransactionRequest."Register No.");

        if (EftTransactionRequest."Cashback Amount" > 0) then
            Error(NoCashback);

        if (PoSID = '') or (PoSUnitID = '') then
            Error(MissingPOSUnitSetup, POSUnit.TableCaption, EftTransactionRequest."Register No.", IntegrationType());

        EftTransactionRequest."Hardware ID" := StrSubstNo('%1_%2_%3', MerchantID, LocationID, PoSID);
        EftTransactionRequest."Integration Version Code" := 'V06';
        EftTransactionRequest.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateLookupTransactionRequest', '', false, false)]
    local procedure OnCreateLookupTransactionRequest(var EftTransactionRequest: Record "EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;

        //TODO: Implement API request looking up transaction results so lost results can be recovered later in case of error.
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnSendEftDeviceRequest', '', false, false)]
    local procedure OnSendEftDeviceRequest(EftTransactionRequest: Record "EFT Transaction Request"; var Handled: Boolean)
    var
        EFTMobilePayProtocol: Codeunit "EFT MobilePay Protocol";
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        EFTMobilePayProtocol.SendEftDeviceRequest(EftTransactionRequest);
    end;

    local procedure "// Protocol Response"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184514, 'OnAfterProtocolResponse', '', false, false)]
    local procedure OnAfterProtocolResponse(var EftTransactionRequest: Record "EFT Transaction Request")
    var
        EFTInterface: Codeunit "EFT Interface";
    begin
        EFTInterface.EftIntegrationResponse(EftTransactionRequest);
    end;

    local procedure "// EFT Parameter Handling"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6184484, 'OnValidateParameterValue', '', false, false)]
    local procedure OnValidatePOSUnitGenParameter(var Parameter: Record "EFT Type POS Unit Gen. Param.")
    var
        EFTMobilePayIntegration: Codeunit "EFT MobilePay Integration";
    begin
        if Parameter."Integration Type" <> IntegrationType() then
            exit;

        case Parameter.Name of
            'PoS Unit ID':
                Parameter.Value := EFTMobilePayIntegration.ResolvePoSUnitId(Parameter.Value);
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6184484, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyPOSUnitGenParameter(var Rec: Record "EFT Type POS Unit Gen. Param."; var xRec: Record "EFT Type POS Unit Gen. Param."; RunTrigger: Boolean)
    var
        EFTTypePOSUnitGenParam: Record "EFT Type POS Unit Gen. Param.";
    begin
        //-NPR5.48 [341674]
        if not RunTrigger then
            exit;
        //+NPR5.48 [341674]
        if Rec."Integration Type" <> IntegrationType() then
            exit;

        case Rec.Name of
            'PoS Unit ID':
                begin
                    if xRec.Value <> '' then
                        //-NPR5.51 [352248]
                        if EFTTypePOSUnitGenParam.GetBooleanParameterValue(IntegrationType(), Rec."POS Unit No.", 'PoS Unit Assigned', false, true) then
                            //+NPR5.51 [352248]
                            Error('Unregister PoS Unit before adding new');
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6184485, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertEFTSetup(var Rec: Record "EFT Setup"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary or (not RunTrigger) then
            exit;
        if Rec."EFT Integration Type" <> IntegrationType() then
            exit;
        Rec.TestField("POS Unit No.");
    end;

    [EventSubscriber(ObjectType::Table, 6184485, 'OnAfterRenameEvent', '', false, false)]
    local procedure OnAfterRenameEFTSetup(var Rec: Record "EFT Setup"; var xRec: Record "EFT Setup"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary or (not RunTrigger) then
            exit;
        if Rec."EFT Integration Type" <> IntegrationType() then
            exit;
        Rec.TestField("POS Unit No.");
    end;

    local procedure "// API Operations"()
    begin
    end;

    procedure InitializeGlobals(PaymentType: Code[10]; RegisterNo: Code[10])
    var
        EFTTypePOSUnitGenParam: Record "EFT Type POS Unit Gen. Param.";
        EFTTypePaymentGenParam: Record "EFT Type Payment Gen. Param.";
        EFTSetupIn: Record "EFT Setup";
    begin
        EFTSetupIn.FindSetup(RegisterNo, PaymentType);
        if Format(EFTSetupIn.RecordId) = Format(EFTSetup.RecordId) then
            exit;
        EFTSetupIn.TestField("EFT Integration Type", IntegrationType());

        EFTSetup := EFTSetupIn;
        PaymentTypePOS.Get(EFTSetup."Payment Type POS");
        Register.Get(EFTSetup."POS Unit No.");

        LocationID := GetLocationID(EFTSetup);
        PoSID := GetPoSID(EFTSetup);
        PoSUnitID := GetPosUnitID(EFTSetup);
        PoSUnitAssigned := GetPoSUnitAssigned(EFTSetup);
        PoSRegistered := GetPoSRegistered(EFTSetup);

        APIKey := GetAPIKey(EFTSetup);
        MerchantID := GetMerchantID(EFTSetup);
        //-NPR5.46.01 [333953]
        //Demo := (GetEnvironment(EFTSetup) = 0);
        Demo := (GetEnvironment(EFTSetup) = 1);
        //+NPR5.46.01 [333953]

        if LocationID = '' then
            Error(InvalidParameter, IntegrationType(), POSUnit.TableCaption, RegisterNo, 'Location ID');
        if APIKey = '' then
            Error(InvalidParameter, IntegrationType(), PaymentTypePOS.TableCaption, PaymentTypePOS."No.", 'API Key');
        if MerchantID = '' then
            Error(InvalidParameter, IntegrationType(), PaymentTypePOS.TableCaption, PaymentTypePOS."No.", 'Merchant ID');

        if Demo then begin
            //-NPR5.54 [388507]
            //  ServiceHost := 'mobilepaypos-extest.cloudapp.net';
            //  ServiceBaseURL := 'http://mobilepaypos-extest.cloudapp.net/API/V06/';
            ServiceHost := 'sandprod-pos2.mobilepay.dk';
            ServiceBaseURL := 'https://sandprod-pos2.mobilepay.dk/API/V06/';
            //+NPR5.54 [388507]
        end else begin
            ServiceHost := 'mobilepaypos2.danskebank.dk';
            ServiceBaseURL := 'https://mobilepaypos2.danskebank.dk/API/V06/';
        end;
    end;

    procedure RegisterPoS(EFTSetupIn: Record "EFT Setup")
    var
        RegisterPoSId: Text;
        EFTTypePOSUnitGenParam: Record "EFT Type POS Unit Gen. Param.";
        NewPoSID: Text;
    begin
        ClearAll;
        ClearLastError();
        InitializeGlobals(EFTSetupIn."Payment Type POS", EFTSetupIn."POS Unit No.");

        if InvokeRegisterPoS(PoSID) then begin
            EFTTypePOSUnitGenParam.UpdateParameterValue(IntegrationType, EFTSetup."POS Unit No.", 'PoS ID', PoSID);
            EFTTypePOSUnitGenParam.UpdateParameterValue(IntegrationType, EFTSetup."POS Unit No.", 'PoS Registered', true);
            PoSRegistered := true;
            Message(Text6014517, EFTSetup."POS Unit No.", PoSID);
        end else
            Error(GetLastErrorText);
    end;

    procedure UpdateRegisteredPoSName(EFTSetupIn: Record "EFT Setup")
    var
        EFTTypePOSUnitGenParam: Record "EFT Type POS Unit Gen. Param.";
    begin
        ClearAll;
        ClearLastError();
        InitializeGlobals(EFTSetupIn."Payment Type POS", EFTSetupIn."POS Unit No.");

        if not PoSRegistered then
            Error(MissingPOSUnitSetup, POSUnit.TableCaption, EFTSetup."POS Unit No.", IntegrationType());

        if InvokeUpdateRegisteredPoSName() then
            Message(Text6014518, EFTSetup."POS Unit No.", Register.Description)
        else
            Error(GetLastErrorText);
    end;

    procedure UnRegisterPoS(EFTSetupIn: Record "EFT Setup")
    var
        EFTTypePOSUnitGenParam: Record "EFT Type POS Unit Gen. Param.";
    begin
        ClearAll;
        ClearLastError();
        InitializeGlobals(EFTSetupIn."Payment Type POS", EFTSetupIn."POS Unit No.");

        if not PoSRegistered then
            Error(MissingPOSUnitSetup, POSUnit.TableCaption, EFTSetup."POS Unit No.", IntegrationType());

        if InvokeUnRegisterPoS() then begin
            EFTTypePOSUnitGenParam.UpdateParameterValue(IntegrationType, EFTSetup."POS Unit No.", 'PoS Registered', false);
            PoSRegistered := false;
            Message(Text6014519, EFTSetup."POS Unit No.");
        end else
            Error(GetLastErrorText);
    end;

    procedure AssignPoSUnitIdToPoS(EFTSetupIn: Record "EFT Setup")
    var
        RegisterPoSUnitId: Text[50];
        EFTTypePOSUnitGenParam: Record "EFT Type POS Unit Gen. Param.";
    begin
        ClearAll;
        ClearLastError();
        InitializeGlobals(EFTSetupIn."Payment Type POS", EFTSetupIn."POS Unit No.");

        if not PoSRegistered then
            Error(MissingPOSUnitSetup, POSUnit.TableCaption, EFTSetup."POS Unit No.", IntegrationType());
        if PoSUnitAssigned then
            Error(InvalidParameter, IntegrationType(), POSUnit.TableCaption, EFTSetup."POS Unit No.", 'PoS Unit Assigned');
        if PoSUnitID = '' then
            Error(InvalidParameter, IntegrationType(), POSUnit.TableCaption, EFTSetup."POS Unit No.", 'PoS Unit ID');

        if InvokeAssignPoSUnitIdToPoS(PoSUnitID) then begin
            EFTTypePOSUnitGenParam.UpdateParameterValue(IntegrationType, EFTSetup."POS Unit No.", 'PoS Unit ID', PoSUnitID);
            EFTTypePOSUnitGenParam.UpdateParameterValue(IntegrationType, EFTSetup."POS Unit No.", 'PoS Unit Assigned', true);
            PoSUnitAssigned := true;
            Message(Text6014521, PoSUnitID, EFTSetup."POS Unit No.");
        end else
            Error(GetLastErrorText);
    end;

    procedure UnAssignPoSUnitIdToPoS(EFTSetupIn: Record "EFT Setup")
    var
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
        RegisterPoSUnitId: Text[50];
        EFTTypePOSUnitGenParam: Record "EFT Type POS Unit Gen. Param.";
    begin
        ClearAll;
        ClearLastError();
        InitializeGlobals(EFTSetupIn."Payment Type POS", EFTSetupIn."POS Unit No.");

        if not PoSRegistered then
            Error(InvalidParameter, IntegrationType(), POSUnit.TableCaption, EFTSetup."POS Unit No.", 'PoS Registered');
        if not PoSUnitAssigned then
            Error(InvalidParameter, IntegrationType(), POSUnit.TableCaption, EFTSetup."POS Unit No.", 'PoS Unit Assigned');
        if PoSUnitID = '' then
            Error(InvalidParameter, IntegrationType(), POSUnit.TableCaption, EFTSetup."POS Unit No.", 'PoS Unit ID');

        if InvokeUnAssignPoSUnitIdToPoS(PoSUnitID) then begin
            EFTTypePOSUnitGenParam.UpdateParameterValue(IntegrationType(), EFTSetup."POS Unit No.", 'PoS Unit Assigned', false);
            PoSUnitAssigned := false;
            Message(Text6014522);
        end else
            Error(GetLastErrorText);
    end;

    procedure ReadPoSAssignPoSUnitId(EFTSetupIn: Record "EFT Setup")
    var
        RegisteredPoSUnitId: Text;
        EFTTypePOSUnitGenParam: Record "EFT Type POS Unit Gen. Param.";
    begin
        ClearAll;
        ClearLastError();
        InitializeGlobals(EFTSetupIn."Payment Type POS", EFTSetupIn."POS Unit No.");

        if InvokeReadPoSAssignPoSUnitId(RegisteredPoSUnitId) then begin
            if PoSUnitID = RegisteredPoSUnitId then
                Message(Text6014523)
            else begin
                EFTTypePOSUnitGenParam.UpdateParameterValue(IntegrationType(), EFTSetup."POS Unit No.", 'PoS Unit ID', RegisteredPoSUnitId);
                //-NPR5.54 [388507]
                EFTTypePOSUnitGenParam.UpdateParameterValue(IntegrationType(), EFTSetup."POS Unit No.", 'PoS Unit Assigned', true);
                //+NPR5.54 [388507]
                PoSUnitID := RegisteredPoSUnitId;
                Message(Text6014520, PoSUnitID, EFTSetup."POS Unit No.");
            end;
        end else
            Error(GetLastErrorText);
    end;

    procedure ReadPoSUnitAssignedPoSId(EFTSetupIn: Record "EFT Setup")
    var
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
        RegisterPoSUnitId: Text[50];
        RegisterPoSId: Text[50];
        EFTTypePOSUnitGenParam: Record "EFT Type POS Unit Gen. Param.";
        Found: Boolean;
    begin
        ClearAll;
        ClearLastError();
        InitializeGlobals(EFTSetupIn."Payment Type POS", EFTSetupIn."POS Unit No.");

        //-NPR5.54 [388507]
        //RegisterPoSUnitId := ResolvePoSUnitId(RegisterPoSUnitId);
        RegisterPoSUnitId := ResolvePoSUnitId(PoSUnitID);
        //+NPR5.54 [388507]
        if InvokeReadPoSUnitAssignedPoSId(RegisterPoSUnitId, RegisterPoSId) then begin
            if RegisterPoSId <> '' then begin
                EFTTypePOSUnitGenParam.SetRange("Integration Type", IntegrationType());
                EFTTypePOSUnitGenParam.SetRange(Name, 'PoS ID');
                EFTTypePOSUnitGenParam.SetRange(Value, RegisterPoSId);
                Found := EFTTypePOSUnitGenParam.FindFirst;
            end;
            if Found then
                Message(Text6014524, RegisterPoSUnitId, EFTTypePOSUnitGenParam."POS Unit No.", RegisterPoSId)
            //-NPR5.54 [388507]
            else
                Message(INCORRECT_POS_ID, RegisterPoSUnitId, RegisterPoSId);
            //+NPR5.54 [388507]
        end else
            Error(GetLastErrorText);
    end;

    procedure PaymentStart(var EftTransactionRequest: Record "EFT Transaction Request"): Boolean
    begin
        ClearLastError();
        InitializeGlobals(EftTransactionRequest."POS Payment Type Code", EftTransactionRequest."Register No.");

        EftTransactionRequest."Reference Number Input" := StrSubstNo('%1-%2-%3', EftTransactionRequest."Register No.", EftTransactionRequest."Sales Ticket No.", EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify;

        if MerchantID = '' then
            Error(InvalidParameter, IntegrationType(), PaymentTypePOS.TableCaption, PaymentTypePOS."No.", 'Merchant ID');
        if LocationID = '' then
            Error(InvalidParameter, IntegrationType(), POSUnit.TableCaption, EFTSetup."POS Unit No.", 'Location ID');
        if PoSID = '' then
            Error(InvalidParameter, IntegrationType(), POSUnit.TableCaption, EFTSetup."POS Unit No.", 'PoS ID');
        if PoSUnitID = '' then
            Error(InvalidParameter, IntegrationType(), POSUnit.TableCaption, EFTSetup."POS Unit No.", 'PoS Unit ID');

        exit(InvokePaymentStart(EftTransactionRequest));
    end;

    procedure GetPaymentStatus(var EFTTransReq: Record "EFT Transaction Request"): Boolean
    var
        RegisterPoSId: Text[50];
        PaymentStatus: Integer;
        CustomerID: Text;
        TransactionID: Text;
    begin
        ClearLastError();
        if InvokeGetPaymentStatus(EFTTransReq, PaymentStatus, CustomerID, TransactionID) then begin
            if PaymentStatus <> EFTTransReq."Result Code" then begin
                EFTTransReq."Result Code" := PaymentStatus;
                //-NPR5.47 [334510]
                //EFTTransReq."Result Description" := GetPaymentStatusText(PaymentStatus);
                EFTTransReq."Result Description" := CopyStr(GetPaymentStatusText(PaymentStatus), 1, MaxStrLen(EFTTransReq."Result Description"));
                //+NPR5.47 [334510]
            end;

            if not (CustomerID in ['', 'null']) then
                EFTTransReq."External Customer ID" := CustomerID;

            if TransactionID <> '' then begin
                EFTTransReq."External Transaction ID" := TransactionID;
                EFTTransReq."Reference Number Output" := TransactionID;
            end;

            if EFTTransReq."Result Code" = 100 then begin //Success
                EFTTransReq.Successful := true;
                EFTTransReq."Amount Output" := EFTTransReq."Amount Input";
                EFTTransReq."Result Amount" := EFTTransReq."Amount Input";
            end;

            EFTTransReq.Modify; //Persist changes across multiple status checks.

            exit(true);
        end;

        exit(false);
    end;

    procedure PaymentCancel(var EFTTransReq: Record "EFT Transaction Request"): Boolean
    begin
        ClearLastError();
        InitializeGlobals(EFTTransReq."POS Payment Type Code", EFTTransReq."Register No.");
        exit(InvokePaymentCancel(EFTTransReq));
    end;

    local procedure "// Web Request Mgt."()
    begin
    end;

    [TryFunction]
    local procedure InvokeRegisterPoS(var PoSIdIn: Text[50])
    var
        RequestBody: Text[1024];
        ResponseText: Text[1024];
    begin
        if MerchantID = '' then
            Error(InvalidParameter, IntegrationType(), PaymentTypePOS.TableCaption, PaymentTypePOS."No.", 'Merchant ID');
        if LocationID = '' then
            Error(InvalidParameter, IntegrationType(), POSUnit.TableCaption, EFTSetup."POS Unit No.", 'Location ID');
        Register.TestField(Description);

        RequestBody := StrSubstNo('{"MerchantId":"%1",', MerchantID);
        RequestBody := RequestBody + StrSubstNo('"LocationId":"%1",', LocationID);
        RequestBody := RequestBody + StrSubstNo('"PosId":"%1",', PoSIdIn);
        RequestBody := RequestBody + StrSubstNo('"Name":"%1"}', Register.Description);

        InvokeRESTHTTPRequest(RequestBody, 'RegisterPoS', ResponseText);
        ReadJSONValue(ResponseText, 'PoSId', PoSIdIn);
    end;

    [TryFunction]
    local procedure InvokeUpdateRegisteredPoSName()
    var
        RequestBody: Text[1024];
        ResponseText: Text[1024];
    begin
        if MerchantID = '' then
            Error(InvalidParameter, IntegrationType(), PaymentTypePOS.TableCaption, PaymentTypePOS."No.", 'Merchant ID');
        if LocationID = '' then
            Error(InvalidParameter, IntegrationType(), POSUnit.TableCaption, EFTSetup."POS Unit No.", 'Location ID');
        if PoSID = '' then
            Error(InvalidParameter, IntegrationType(), POSUnit.TableCaption, EFTSetup."POS Unit No.", 'PoS ID');
        Register.TestField(Description);

        RequestBody := StrSubstNo('{"MerchantId":"%1",', MerchantID);
        RequestBody := RequestBody + StrSubstNo('"LocationId":"%1",', LocationID);
        RequestBody := RequestBody + StrSubstNo('"PosId":"%1",', PoSID);
        RequestBody := RequestBody + StrSubstNo('"Name":"%1"}', Register.Description);

        InvokeRESTHTTPRequest(RequestBody, 'UpdateRegisteredPoSName', ResponseText);
    end;

    [TryFunction]
    local procedure InvokeUnRegisterPoS()
    var
        RequestBody: Text[1024];
        ResponseText: Text[1024];
    begin
        if MerchantID = '' then
            Error(InvalidParameter, IntegrationType(), PaymentTypePOS.TableCaption, PaymentTypePOS."No.", 'Merchant ID');
        if LocationID = '' then
            Error(InvalidParameter, IntegrationType(), POSUnit.TableCaption, EFTSetup."POS Unit No.", 'Location ID');
        if PoSID = '' then
            Error(InvalidParameter, IntegrationType(), POSUnit.TableCaption, EFTSetup."POS Unit No.", 'PoS ID');

        RequestBody := StrSubstNo('{"MerchantId":"%1",', MerchantID);
        RequestBody := RequestBody + StrSubstNo('"LocationId":"%1",', LocationID);
        RequestBody := RequestBody + StrSubstNo('"PosId":"%1"}', PoSID);

        InvokeRESTHTTPRequest(RequestBody, 'UnRegisterPoS', ResponseText);
    end;

    [TryFunction]
    local procedure InvokeGetUniquePoSId(var PoSIdIn: Text[50])
    var
        RequestBody: Text[1024];
        ResponseText: Text[1024];
    begin
        if MerchantID = '' then
            Error(InvalidParameter, IntegrationType(), PaymentTypePOS.TableCaption, PaymentTypePOS."No.", 'Merchant ID');

        //-NPR5.54 [388507]
        //RequestBody := STRSUBSTNO('{"MerchantId":"%1"}',PaymentTypePOS."MobilePay Merchant ID");
        RequestBody := StrSubstNo('{"MerchantId":"%1"}', MerchantID);
        //+NPR5.54 [388507]

        InvokeRESTHTTPRequest(RequestBody, 'GetUniquePoSId', ResponseText);
        ReadJSONValue(ResponseText, 'PoSId', PoSIdIn);
    end;

    [TryFunction]
    local procedure InvokeAssignPoSUnitIdToPoS(var PoSUnitIdIn: Text[30])
    var
        RequestBody: Text[1024];
        ResponseText: Text[1024];
    begin
        if MerchantID = '' then
            Error(InvalidParameter, IntegrationType(), PaymentTypePOS.TableCaption, PaymentTypePOS."No.", 'Merchant ID');
        if LocationID = '' then
            Error(InvalidParameter, IntegrationType(), POSUnit.TableCaption, EFTSetup."POS Unit No.", 'Location ID');
        if PoSID = '' then
            Error(InvalidParameter, IntegrationType(), POSUnit.TableCaption, EFTSetup."POS Unit No.", 'PoS ID');

        RequestBody := StrSubstNo('{"MerchantId":"%1",', MerchantID);
        RequestBody += StrSubstNo('"LocationId":"%1",', LocationID);
        RequestBody += StrSubstNo('"PosId":"%1",', PoSID);
        RequestBody += StrSubstNo('"PoSUnitId":"%1"}', PoSUnitIdIn);

        InvokeRESTHTTPRequest(RequestBody, 'AssignPoSUnitIdToPoS', ResponseText);
    end;

    [TryFunction]
    local procedure InvokeUnAssignPoSUnitIdToPoS(var PoSUnitIdIn: Text[30])
    var
        RequestBody: Text[1024];
        ResponseText: Text[1024];
    begin
        if MerchantID = '' then
            Error(InvalidParameter, IntegrationType(), PaymentTypePOS.TableCaption, PaymentTypePOS."No.", 'Merchant ID');
        if LocationID = '' then
            Error(InvalidParameter, IntegrationType(), POSUnit.TableCaption, EFTSetup."POS Unit No.", 'Location ID');
        if PoSID = '' then
            Error(InvalidParameter, IntegrationType(), POSUnit.TableCaption, EFTSetup."POS Unit No.", 'PoS ID');
        if PoSUnitID = '' then
            Error(InvalidParameter, IntegrationType(), POSUnit.TableCaption, EFTSetup."POS Unit No.", 'PoS Unit ID');

        RequestBody := StrSubstNo('{"MerchantId":"%1",', MerchantID);
        RequestBody += StrSubstNo('"LocationId":"%1",', LocationID);
        RequestBody += StrSubstNo('"PosId":"%1",', PoSID);
        RequestBody += StrSubstNo('"PoSUnitId":"%1"}', PoSUnitID);

        InvokeRESTHTTPRequest(RequestBody, 'UnAssignPoSUnitIdToPoS', ResponseText);
    end;

    [TryFunction]
    local procedure InvokeReadPoSAssignPoSUnitId(var PoSUnitIdIn: Text[30])
    var
        RequestBody: Text[1024];
        ResponseText: Text[1024];
    begin
        if MerchantID = '' then
            Error(InvalidParameter, IntegrationType(), PaymentTypePOS.TableCaption, PaymentTypePOS."No.", 'Merchant ID');
        if LocationID = '' then
            Error(InvalidParameter, IntegrationType(), POSUnit.TableCaption, EFTSetup."POS Unit No.", 'Location ID');
        if PoSID = '' then
            Error(InvalidParameter, IntegrationType(), POSUnit.TableCaption, EFTSetup."POS Unit No.", 'PoS ID');

        RequestBody := StrSubstNo('{"MerchantId":"%1",', MerchantID);
        RequestBody += StrSubstNo('"LocationId":"%1",', LocationID);
        RequestBody += StrSubstNo('"PosId":"%1"}', PoSID);

        InvokeRESTHTTPRequest(RequestBody, 'ReadPoSAssignPoSUnitId', ResponseText);
        ReadJSONValue(ResponseText, 'PoSUnitId', PoSUnitIdIn);
    end;

    [TryFunction]
    local procedure InvokeReadPoSUnitAssignedPoSId(PoSUnitIdIn: Text[30]; var PoSIdIn: Text[50])
    var
        RequestBody: Text[1024];
        ResponseText: Text[1024];
    begin
        if MerchantID = '' then
            Error(InvalidParameter, IntegrationType(), PaymentTypePOS.TableCaption, PaymentTypePOS."No.", 'Merchant ID');
        if LocationID = '' then
            Error(InvalidParameter, IntegrationType(), POSUnit.TableCaption, EFTSetup."POS Unit No.", 'Location ID');

        RequestBody := StrSubstNo('{"MerchantId":"%1",', MerchantID);
        RequestBody += StrSubstNo('"LocationId":"%1",', LocationID);
        RequestBody += StrSubstNo('"PosUnitId":"%1"}', PoSUnitIdIn);

        InvokeRESTHTTPRequest(RequestBody, 'ReadPoSUnitAssignedPoSId', ResponseText);
        ReadJSONValue(ResponseText, 'PoSId', PoSIdIn);
    end;

    [TryFunction]
    local procedure InvokePaymentStart(var EFTTransReq: Record "EFT Transaction Request")
    var
        RequestBody: Text[1024];
        ResponseText: Text[1024];
        CustToken: Integer;
    begin
        RequestBody := StrSubstNo('{"MerchantId":"%1",', MerchantID);
        RequestBody += StrSubstNo('"LocationId":"%1",', LocationID);
        RequestBody += StrSubstNo('"PosId":"%1",', PoSID);
        RequestBody += StrSubstNo('"OrderId":"%1",', EFTTransReq."Reference Number Input");
        RequestBody += StrSubstNo('"Amount":"%1",', Format(EFTTransReq."Amount Input", 0, '<Precision,2:2><Standard Format,9>'));
        RequestBody += StrSubstNo('"BulkRef":"%1",', '');
        RequestBody += StrSubstNo('"ReceiptText":"%1",', '');
        RequestBody += '"Action":"Start",';
        RequestBody += StrSubstNo('"CustomerTokenCalc":%1,', Format(false, 0, 2));
        RequestBody += StrSubstNo('"HMAC":"%1"}', CalcPaymentHMAC(EFTTransReq));

        InvokeRESTHTTPRequest(RequestBody, 'PaymentStart', ResponseText);
    end;

    [TryFunction]
    local procedure InvokeGetPaymentStatus(EFTTransReq: Record "EFT Transaction Request"; var PaymentStatus: Integer; var CustomerID: Text; var TransactionID: Text)
    var
        RequestBody: Text[1024];
        ResponseText: Text[1024];
        PaymentStatusText: Text;
    begin
        RequestBody := StrSubstNo('{"MerchantId":"%1",', MerchantID);
        RequestBody += StrSubstNo('"LocationId":"%1",', LocationID);
        RequestBody += StrSubstNo('"PosId":"%1",', PoSID);
        RequestBody += StrSubstNo('"OrderId":"%1"}', EFTTransReq."Reference Number Input");

        InvokeRESTHTTPRequest(RequestBody, 'GetPaymentStatus', ResponseText);
        if ReadJSONValue(ResponseText, 'PaymentStatus', PaymentStatusText) then begin
            Evaluate(PaymentStatus, PaymentStatusText);
            if PaymentStatus <> EFTTransReq."Result Code" then begin
                ReadJSONValue(ResponseText, 'CustomerId', CustomerID);
                ReadJSONValue(ResponseText, 'TransactionId', TransactionID);
            end;
        end;
    end;

    [TryFunction]
    local procedure InvokePaymentCancel(var EFTTransReq: Record "EFT Transaction Request")
    var
        RequestBody: Text[1024];
        ResponseText: Text[1024];
        TransactionPaymentStatus: Text[30];
        TransactionCustomerID: Text[30];
        TransactionPaymentID: Text[30];
    begin
        RequestBody := StrSubstNo('{"MerchantId":"%1",', MerchantID);
        RequestBody += StrSubstNo('"LocationId":"%1",', LocationID);
        RequestBody += StrSubstNo('"PosId":"%1"}', PoSID);

        InvokeRESTHTTPRequest(RequestBody, 'PaymentCancel', ResponseText);
    end;

    local procedure InvokeRESTHTTPRequest(var JSONRequestBody: Text[1024]; ServiceName: Text[30]; var JSONResponseText: Text[1024]): Boolean
    var
        HttpWebRequest: DotNet npNetHttpWebRequest;
        ReqStream: DotNet npNetStream;
        ReqStreamWriter: DotNet npNetStreamWriter;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        ResponseStream: DotNet npNetStream;
        ResponseStreamReader: DotNet npNetStreamReader;
        ServiceURL: Text[100];
        AuthHeader: Text[100];
    begin
        ServiceURL := ServiceBaseURL + ServiceName;
        AuthHeader := CalcAuthHeader(ServiceURL, JSONRequestBody);

        HttpWebRequest := HttpWebRequest.Create(ServiceURL);
        HttpWebRequest.Host(ServiceHost);
        HttpWebRequest.ContentType('application/json');
        HttpWebRequest.Headers.Add('Authorization', AuthHeader);
        HttpWebRequest.Method('POST');

        ReqStream := HttpWebRequest.GetRequestStream;
        ReqStreamWriter := ReqStreamWriter.StreamWriter(ReqStream);
        ReqStreamWriter.Write(JSONRequestBody);
        ReqStreamWriter.Flush;
        ReqStreamWriter.Close;
        Clear(ReqStreamWriter);
        Clear(ReqStream);

        HttpWebResponse := HttpWebRequest.GetResponse;
        ResponseStream := HttpWebResponse.GetResponseStream;
        ResponseStreamReader := ResponseStreamReader.StreamReader(ResponseStream);
        JSONResponseText := ResponseStreamReader.ReadToEnd;
    end;

    local procedure "// Aux"()
    begin
    end;

    local procedure CalcAuthHeader(RequestUrl: Text[100]; ContentBody: Text[1024]): Text[100]
    var
        Encoding: DotNet npNetEncoding;
        AuthString: Text[1024];
        HashValue: Text[100];
        UnixTimeStamp: Integer;
    begin
        if APIKey = '' then
            Error(InvalidParameter, IntegrationType(), PaymentTypePOS.TableCaption, PaymentTypePOS."No.", 'API Key');

        UnixTimeStamp := GetUnixTime(CurrentDateTime);

        AuthString := StrSubstNo('%1 %2 %3', RequestUrl, ContentBody, UnixTimeStamp);
        HashValue := GetHmacSha256Hash(APIKey, AuthString, Encoding.UTF8);

        exit(StrSubstNo('%1 %2', HashValue, UnixTimeStamp));
    end;

    local procedure CalcPaymentHMAC(EftTransactionRequest: Record "EFT Transaction Request"): Text[100]
    var
        Encoding: DotNet npNetEncoding;
        HMACString: Text[1024];
        MerchantKey: Text[50];
        HashValue: Text[100];
        CharSet: Text[30];
    begin
        HMACString := StrSubstNo('%1%2#%3#%4#%5#%6#%7', MerchantID,
                                                       LocationID,
                                                       PoSID,
                                                       EftTransactionRequest."Reference Number Input",
                                                       Format(EftTransactionRequest."Amount Input", 0, '<Precision,2:2><Standard Format,9>'),
                                                       '', //BulkRef
                                                       ''); //Receipt Text

        Encoding := Encoding.GetEncoding('iso-8859-1');
        MerchantKey := CopyStr(MerchantID, 4, 6);
        HashValue := GetHmacSha256Hash(GetSha256Hash(MerchantKey, Encoding), HMACString, Encoding);

        exit(HashValue);
    end;

    procedure ResolvePoSUnitId(PoSUnitIdString: Text[100]) PoSUnitId: Text[30]
    var
        StartDelim: Text[30];
        EndDelim: Text[30];
    begin
        //QR Code example:
        //Mobilepaypos://pos?id=100000868977775&source=qr

        PoSUnitIdString := LowerCase(PoSUnitIdString);
        StartDelim := 'id=';
        EndDelim := '&';
        if StrPos(PoSUnitIdString, 'mobilepaypos://') = 1 then begin  //Scanned from QR code
            PoSUnitId := CopyStr(PoSUnitIdString, StrPos(PoSUnitIdString, StartDelim) + StrLen(StartDelim));
            PoSUnitId := CopyStr(PoSUnitId, 1, StrPos(PoSUnitId, EndDelim) - 1);
        end else
            PoSUnitId := PoSUnitIdString;
    end;

    local procedure ReadJSONValue(var JSONObject: Text[1024]; ValueName: Text[100]; var ValueAsText: Text[100]): Boolean
    var
        Buffer: Text[1024];
        ValuePos: Integer;
        i: Integer;
        TAB: Char;
        LF: Char;
        CR: Char;
        IsStringValue: Boolean;
        EndOfValue: Boolean;
    begin
        ValueName := StrSubstNo('"%1":', ValueName);
        ValuePos := StrPos(JSONObject, ValueName);
        if ValuePos = 0 then
            exit(false);

        ValuePos += StrLen(ValueName);
        ValueAsText := '';
        Buffer := CopyStr(JSONObject, ValuePos);

        //Trim prefixing white spaces
        TAB := 9;
        LF := 10;
        CR := 13;
        i := 1;
        while (CopyStr(Buffer, i, 1) in [' ', Format(TAB), Format(LF), Format(CR)]) do
            i += 1;

        if CopyStr(Buffer, i, 1) = '"' then begin//String
            IsStringValue := true;
            i += 1;
        end else
            IsStringValue := false;


        if IsStringValue then
            EndOfValue := (CopyStr(Buffer, i, 1) = '"')
        else
            EndOfValue := (CopyStr(Buffer, i, 1) in [',', '}']);
        while not EndOfValue do begin
            if CopyStr(Buffer, i, 1) = '\' then begin
                ValueAsText := ValueAsText + CopyStr(Buffer, i + 1, 1);
                i += 2;
            end else begin
                ValueAsText := ValueAsText + CopyStr(Buffer, i, 1);
                i += 1;
            end;
            if IsStringValue then
                EndOfValue := (CopyStr(Buffer, i, 1) = '"')
            else
                EndOfValue := (CopyStr(Buffer, i, 1) in [',', '}']);
        end;
        exit(true);
    end;

    local procedure GetUnixTime(ToDateTime: DateTime) UnixTimeStamp: Integer
    var
        Duration: Duration;
        DurationMs: BigInteger;
        FromDateTime: DateTime;
    begin
        //-NPR5.51 [363895]
        // TypeOfDateTime := GETDOTNETTYPE(SystemDateTime);
        //
        // DotNetArray := DotNetArray.CreateInstance(GETDOTNETTYPE(GETDOTNETTYPE('')),1);
        // DotNetArray.SetValue(TypeOfDateTime,0);
        // MethodInfo := TypeOfDateTime.GetMethod('Subtract', DotNetArray);
        //
        // DotNetArray := DotNetArray.CreateInstance(GETDOTNETTYPE(SystemObject),1);
        // DotNetArray.SetValue(SystemDateTime.DateTime(1970,1,1,0,0,0,DateTimeKind.Utc),0);
        //
        // Dur := MethodInfo.Invoke(ToDateTime,DotNetArray);
        //
        // TypeOfTimeSpan := GETDOTNETTYPE(Dur);
        // UnixTimeStamp := Convert.ToInt32(TypeOfTimeSpan.GetProperty('TotalSeconds').GetValue(Dur));

        Evaluate(FromDateTime, '1970-01-01T00:00:00Z', 9);
        Duration := ToDateTime - FromDateTime;
        DurationMs := Duration;
        exit((DurationMs / 1000) div 1); //Seconds with miliseconds shaved off
        //+NPR5.51 [363895]
    end;

    local procedure GetHmacSha256Hash("Key": Text; Value: Text; Encoding: DotNet npNetEncoding): Text
    var
        HmacSha256: DotNet npNetHMACSHA256;
        Convert: DotNet npNetConvert;
    begin
        HmacSha256 := HmacSha256.HMACSHA256(Encoding.GetBytes(Key));
        exit(Convert.ToBase64String(HmacSha256.ComputeHash(Encoding.GetBytes(Value))));
    end;

    local procedure GetSha256Hash(Value: Text; Encoding: DotNet npNetEncoding): Text
    var
        Sha256: DotNet npNetSHA256Managed;
        Convert: DotNet npNetConvert;
    begin
        Sha256 := Sha256.SHA256Managed();
        exit(Encoding.GetString(Sha256.ComputeHash(Encoding.GetBytes(Value))));
    end;

    procedure GetQRUri(): Text
    begin
        exit(StrSubstNo('mobilepaypos://pos?id=%1&source=qr', PoSUnitID));
    end;

    local procedure GetPaymentStatusText(PaymentStatus: Integer): Text
    begin
        case PaymentStatus of
            0, 10:
                exit(Text10);
            20:
                exit(Text20);
            30:
                exit(Text30);
            40:
                exit(Text40);
            50:
                exit(Text50);
            60:
                exit(Text60);
            70:
                exit(Text70);
            80:
                exit(Text80);
            100:
                exit(Text100);
        end;
    end;

    local procedure GetLocationID(EFTSetupIn: Record "EFT Setup"): Text
    var
        EFTTypePOSUnitGenParam: Record "EFT Type POS Unit Gen. Param.";
    begin
        exit(EFTTypePOSUnitGenParam.GetTextParameterValue(IntegrationType(), EFTSetupIn."POS Unit No.", 'Location ID', '', true));
    end;

    local procedure GetPoSID(EFTSetupIn: Record "EFT Setup"): Text
    var
        EFTTypePOSUnitGenParam: Record "EFT Type POS Unit Gen. Param.";
    begin
        exit(EFTTypePOSUnitGenParam.GetTextParameterValue(IntegrationType(), EFTSetupIn."POS Unit No.", 'PoS ID', '', false));
    end;

    local procedure GetPosUnitID(EFTSetupIn: Record "EFT Setup"): Text
    var
        EFTTypePOSUnitGenParam: Record "EFT Type POS Unit Gen. Param.";
    begin
        exit(EFTTypePOSUnitGenParam.GetTextParameterValue(IntegrationType(), EFTSetupIn."POS Unit No.", 'PoS Unit ID', '', true));
    end;

    local procedure GetPoSUnitAssigned(EFTSetupIn: Record "EFT Setup"): Boolean
    var
        EFTTypePOSUnitGenParam: Record "EFT Type POS Unit Gen. Param.";
    begin
        //-NPR5.51 [352248]
        exit(EFTTypePOSUnitGenParam.GetBooleanParameterValue(IntegrationType(), EFTSetupIn."POS Unit No.", 'PoS Unit Assigned', false, true));
        //+NPR5.51 [352248]
    end;

    local procedure GetPoSRegistered(EFTSetupIn: Record "EFT Setup"): Boolean
    var
        EFTTypePOSUnitGenParam: Record "EFT Type POS Unit Gen. Param.";
    begin
        //-NPR5.51 [352248]
        exit(EFTTypePOSUnitGenParam.GetBooleanParameterValue(IntegrationType(), EFTSetupIn."POS Unit No.", 'PoS Registered', false, true));
        //+NPR5.51 [352248]
    end;

    local procedure GetAPIKey(EFTSetupIn: Record "EFT Setup"): Text
    var
        EFTTypePaymentGenParam: Record "EFT Type Payment Gen. Param.";
    begin
        exit(EFTTypePaymentGenParam.GetTextParameterValue(IntegrationType(), EFTSetupIn."Payment Type POS", 'API Key', '', true));
    end;

    local procedure GetMerchantID(EFTSetupIn: Record "EFT Setup"): Text
    var
        EFTTypePaymentGenParam: Record "EFT Type Payment Gen. Param.";
    begin
        exit(EFTTypePaymentGenParam.GetTextParameterValue(IntegrationType(), EFTSetupIn."Payment Type POS", 'Merchant ID', '', true));
    end;

    local procedure GetEnvironment(EFTSetupIn: Record "EFT Setup"): Integer
    var
        EFTTypePaymentGenParam: Record "EFT Type Payment Gen. Param.";
    begin
        exit(EFTTypePaymentGenParam.GetOptionParameterValue(IntegrationType(), EFTSetupIn."Payment Type POS", 'Environment', 0, 'PROD,DEMO', true));
    end;
}

