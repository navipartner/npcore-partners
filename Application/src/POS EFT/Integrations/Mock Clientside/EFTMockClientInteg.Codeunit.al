codeunit 6184511 "NPR EFT Mock Client Integ."
{
    // NPR5.46/MMV /20181008 CASE 290734 Created object
    // NPR5.49/MMV /20190312 CASE 345188 Renamed object
    // NPR5.51/MMV /20190626 CASE 359385 Added gift card load support.


    trigger OnRun()
    begin
    end;

    var
        Description: Label 'Mock client-side via Stargate';
        BalanceDescription: Label 'Gift card balance enquiry';
        ReprintLastDescription: Label 'Reprint last terminal receipt';
        CompBlobCaption1: Label 'Blob Caption 1';
        CompBlobCaption2: Label 'Blob Caption 2';
        CompBlobDesc1: Label 'Blob Description 1 ';
        CompBlobDesc2: Label 'Blob Description 2';
        CompGenCaption1: Label 'Gen Caption 1';
        CompGenCaption2: Label 'Gen Caption 2';
        CompGenDesc1: Label 'Gen Description 1';
        CompGenDesc2: Label 'Gen Description 2';
        UnitBlobCap: Label 'Blob Caption';
        UnitBlobDesc: Label 'Blob Description';
        UnitConnMethodCaption: Label 'Connection Method';
        UnitConnMethodDesc: Label 'Cable used to connect terminal on local machine';
        UnitConnMethodOptionString: Label 'USB,Ethernet';
        UnitIPCaption: Label 'IP';
        UnitIPDesc: Label 'IP Address used for ethernet connected terminal';
        UnitVirtualComCaption: Label 'COM Port';
        UnitVirtualComDesc: Label 'Virtual COM Port number for USB connected terminal';

    local procedure IntegrationType(): Text
    begin
        exit('MOCK_CLIENT_SIDE');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnDiscoverIntegrations', '', false, false)]
    local procedure OnDiscoverIntegrations(var tmpEFTIntegrationType: Record "NPR EFT Integration Type" temporary)
    begin
        tmpEFTIntegrationType.Init();
        tmpEFTIntegrationType.Code := IntegrationType();
        tmpEFTIntegrationType.Description := Description;
        tmpEFTIntegrationType."Codeunit ID" := CODEUNIT::"NPR EFT Mock Client Integ.";
        tmpEFTIntegrationType.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnDiscoverAuxiliaryOperations', '', false, false)]
    local procedure OnDiscoverAuxiliaryOperations(var tmpEFTAuxOperation: Record "NPR EFT Aux Operation" temporary)
    begin
        //Any non standard EFT operations are registered here:

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 1;
        tmpEFTAuxOperation.Description := BalanceDescription;
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 2;
        tmpEFTAuxOperation.Description := ReprintLastDescription;
        tmpEFTAuxOperation.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnConfigureIntegrationUnitSetup', '', false, false)]
    local procedure OnConfigureIntegrationUnitSetup(EFTSetup: Record "NPR EFT Setup")
    var
        Blob1: Codeunit "Temp Blob";
        Blob2: Codeunit "Temp Blob";
    begin
        if EFTSetup."EFT Integration Type" <> IntegrationType() then
            exit;

        //Getting values will initialize them in case this is first time setup or some of them was added in a new release.
        GetConnectionMethod(EFTSetup);
        GetIPAddr(EFTSetup);
        GetVirtualCOM(EFTSetup);
        GetPOSUnitBlob1(EFTSetup, Blob1);
        GetPOSUnitBlob2(EFTSetup, Blob2);

        //Show the generic parameter page.
        EFTSetup.ShowEftPOSUnitParameters();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnConfigureIntegrationPaymentSetup', '', false, false)]
    local procedure OnConfigureIntegrationPaymentSetup(EFTSetup: Record "NPR EFT Setup")
    var
        Blob1: Codeunit "Temp Blob";
        Blob2: Codeunit "Temp Blob";
    begin
        if EFTSetup."EFT Integration Type" <> IntegrationType() then
            exit;

        //Getting values will initialize them in case this is first time setup or some of them was added in a new release.
        GetPaymentParam1(EFTSetup);
        GetPaymentParam2(EFTSetup);
        GetPaymentBlob1(EFTSetup, Blob1);
        GetPaymentBlob2(EFTSetup, Blob2);

        //Show the generic parameter page.
        EFTSetup.ShowEftPaymentParameters();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateBeginWorkshiftRequest', '', false, false)]
    local procedure OnCreateBeginWorkshiftRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        //Fill any type specific information onto the request record before the request is fired.
        EftTransactionRequest.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateEndWorkshiftRequest', '', false, false)]
    local procedure OnCreateEndWorkshiftRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        //Fill any type specific information onto the request record before the request is fired.
        EftTransactionRequest.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreatePaymentOfGoodsRequest', '', false, false)]
    local procedure OnCreatePaymentOfGoodsRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        //Fill any type specific information onto the request record before the request is fired.
        EftTransactionRequest."Reference Number Input" := EftTransactionRequest.Token;
        EftTransactionRequest.Recoverable := true;
        EftTransactionRequest."Auto Voidable" := true;
        EftTransactionRequest."Manual Voidable" := true;
        EftTransactionRequest.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateRefundRequest', '', false, false)]
    local procedure OnCreateRefundRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        //Fill any type specific information onto the request record before the request is fired.
        EftTransactionRequest."Reference Number Input" := EftTransactionRequest.Token;
        EftTransactionRequest.Recoverable := true;
        EftTransactionRequest."Auto Voidable" := true;
        EftTransactionRequest."Manual Voidable" := true;
        EftTransactionRequest.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateVoidRequest', '', false, false)]
    local procedure OnCreateVoidRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        //Fill any type specific information onto the request record before the request is fired.
        EftTransactionRequest.Recoverable := true;
        EftTransactionRequest.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateVerifySetupRequest', '', false, false)]
    local procedure OnCreateVerifySetupRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        //Fill any type specific information onto the request record before the request is fired.
        EftTransactionRequest.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateLookupTransactionRequest', '', false, false)]
    local procedure OnCreateLookupTransactionRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        //Fill any type specific information onto the request record before the request is fired.
        EftTransactionRequest.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateAuxRequest', '', false, false)]
    local procedure OnCreateAuxRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        //Fill any type specific information onto the request record before the request is fired.
        EftTransactionRequest.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateGiftCardLoadRequest', '', false, false)]
    local procedure OnCreateGiftCardLoadRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        //-NPR5.51 [359385]
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        //Fill any type specific information onto the request record before the request is fired.
        EftTransactionRequest."Reference Number Input" := EftTransactionRequest.Token;
        EftTransactionRequest.Recoverable := true;
        EftTransactionRequest."Auto Voidable" := true;
        EftTransactionRequest."Manual Voidable" := true;
        EftTransactionRequest.Insert(true);
        //+NPR5.51 [359385]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnAfterFinancialCommit', '', false, false)]
    local procedure OnAfterFinancialCommit(EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;

        //This function is after transaction result & payment line commit - best place for terminal print.
        EftTransactionRequest.PrintReceipts(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnSendEftDeviceRequest', '', false, false)]
    local procedure OnSendEftDeviceRequest(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        EFTMockClientProtocol: Codeunit "NPR EFT Mock Client Prot.";
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        EFTMockClientProtocol.SendEftDeviceRequest(EftTransactionRequest);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnQueueCloseBeforeRegisterBalance', '', false, false)]
    local procedure OnQueueCloseBeforeRegisterBalance(POSSession: Codeunit "NPR POS Session"; var tmpEFTSetup: Record "NPR EFT Setup" temporary)
    var
        POSSetup: Codeunit "NPR POS Setup";
        EFTSetup: Record "NPR EFT Setup";
    begin
        POSSession.GetSetup(POSSetup);

        EFTSetup.SetFilter("POS Unit No.", POSSetup.GetPOSUnitNo());
        EFTSetup.SetRange("EFT Integration Type", IntegrationType());
        if not EFTSetup.FindFirst() then begin
            EFTSetup.SetRange("POS Unit No.", '');
            if not EFTSetup.FindFirst() then
                exit;
        end;

        tmpEFTSetup := EFTSetup;
        tmpEFTSetup.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184512, 'OnAfterProtocolResponse', '', false, false)]
    local procedure OnAfterProtocolResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTInterface: Codeunit "NPR EFT Interface";
    begin
        EFTInterface.EftIntegrationResponse(EftTransactionRequest);
    end;

    [EventSubscriber(ObjectType::Table, 6184481, 'OnGetParameterNameCaption', '', false, false)]
    local procedure OnSetPaymentBlobParameterName(Parameter: Record "NPR EFTType Paym. BLOB Param."; var Caption: Text)
    begin
        if Parameter."Integration Type" <> IntegrationType() then
            exit;

        case Parameter.Name of
            'Payment wide BLOB Parameter':
                Caption := CompBlobCaption1;
            'Payment wide BLOB Parameter 2':
                Caption := CompBlobCaption2;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6184481, 'OnGetParameterDescriptionCaption', '', false, false)]
    local procedure OnSetPaymentBlobParameterDescription(Parameter: Record "NPR EFTType Paym. BLOB Param."; var Caption: Text)
    begin
        if Parameter."Integration Type" <> IntegrationType() then
            exit;

        case Parameter.Name of
            'Payment wide BLOB Parameter':
                Caption := CompBlobDesc1;
            'Payment wide BLOB Parameter 2':
                Caption := CompBlobDesc2;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6184481, 'OnLookupParameterValue', '', false, false)]
    local procedure OnLookupPaymentBlobParameterValue(var Parameter: Record "NPR EFTType Paym. BLOB Param.")
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6184481, 'OnValidateParameterValue', '', false, false)]
    local procedure OnValidatePaymentBlobParameterValue(var Parameter: Record "NPR EFTType Paym. BLOB Param.")
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6184483, 'OnGetParameterNameCaption', '', false, false)]
    local procedure OnSetPaymentGenParameterName(Parameter: Record "NPR EFT Type Pay. Gen. Param."; var Caption: Text)
    begin
        if Parameter."Integration Type" <> IntegrationType() then
            exit;

        case Parameter.Name of
            'Payment wide Parameter':
                Caption := CompGenCaption1;
            'Payment wide Parameter 2':
                Caption := CompGenCaption2;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6184483, 'OnGetParameterDescriptionCaption', '', false, false)]
    local procedure OnSetPaymentGenParameterDescription(Parameter: Record "NPR EFT Type Pay. Gen. Param."; var Caption: Text)
    begin
        if Parameter."Integration Type" <> IntegrationType() then
            exit;

        case Parameter.Name of
            'Payment wide Parameter':
                Caption := CompGenDesc1;
            'Payment wide Parameter 2':
                Caption := CompGenDesc2;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6184483, 'OnGetParameterOptionStringCaption', '', false, false)]
    local procedure OnSetPaymentGenParameterOptionCaption(Parameter: Record "NPR EFT Type Pay. Gen. Param."; var Caption: Text)
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6184483, 'OnLookupParameterValue', '', false, false)]
    local procedure OnLookupPaymentGenParameterValue(var Parameter: Record "NPR EFT Type Pay. Gen. Param."; var Handled: Boolean)
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6184483, 'OnValidateParameterValue', '', false, false)]
    local procedure OnValidatePaymentGenParameterValue(var Parameter: Record "NPR EFT Type Pay. Gen. Param.")
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6184482, 'OnGetParameterNameCaption', '', false, false)]
    local procedure OnSetUnitBlobParameterName(Parameter: Record "NPR EFTType POSUnit BLOBParam."; var Caption: Text)
    begin
        if Parameter."Integration Type" <> IntegrationType() then
            exit;

        case Parameter.Name of
            'Editable Binary Parameter':
                Caption := UnitBlobCap;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6184482, 'OnGetParameterDescriptionCaption', '', false, false)]
    local procedure OnSetUnitBlobParameterDescription(Parameter: Record "NPR EFTType POSUnit BLOBParam."; var Caption: Text)
    begin
        if Parameter."Integration Type" <> IntegrationType() then
            exit;

        case Parameter.Name of
            'Editable Binary Parameter':
                Caption := UnitBlobDesc;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6184482, 'OnLookupParameterValue', '', false, false)]
    local procedure OnLookupUnitBlobParameterValue(var Parameter: Record "NPR EFTType POSUnit BLOBParam.")
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6184482, 'OnValidateParameterValue', '', false, false)]
    local procedure OnValidateUnitBlobParameterValue(var Parameter: Record "NPR EFTType POSUnit BLOBParam.")
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6184484, 'OnGetParameterNameCaption', '', false, false)]
    local procedure OnSetUnitGenParameterName(Parameter: Record "NPR EFTType POSUnit Gen.Param."; var Caption: Text)
    begin
        if Parameter."Integration Type" <> IntegrationType() then
            exit;

        case Parameter.Name of
            'Connection Method':
                Caption := UnitConnMethodCaption;
            'LAN IP':
                Caption := UnitIPCaption;
            'Virtual COM Port':
                Caption := UnitVirtualComCaption;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6184484, 'OnGetParameterDescriptionCaption', '', false, false)]
    local procedure OnSetUnitGenParameterDescription(Parameter: Record "NPR EFTType POSUnit Gen.Param."; var Caption: Text)
    begin
        if Parameter."Integration Type" <> IntegrationType() then
            exit;

        case Parameter.Name of
            'Connection Method':
                Caption := UnitConnMethodDesc;
            'LAN IP':
                Caption := UnitIPDesc;
            'Virtual COM Port':
                Caption := UnitVirtualComDesc;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6184484, 'OnGetParameterOptionStringCaption', '', false, false)]
    local procedure OnSetUnitGenParameterOptionCaption(Parameter: Record "NPR EFTType POSUnit Gen.Param."; var Caption: Text)
    begin
        if Parameter."Integration Type" <> IntegrationType() then
            exit;

        case Parameter.Name of
            'Connection Method':
                Caption := UnitConnMethodOptionString;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6184484, 'OnLookupParameterValue', '', false, false)]
    local procedure OnLookupUnitGenParameterValue(var Parameter: Record "NPR EFTType POSUnit Gen.Param."; var Handled: Boolean)
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6184484, 'OnValidateParameterValue', '', false, false)]
    local procedure OnValidateUnitGenParameterValue(var Parameter: Record "NPR EFTType POSUnit Gen.Param.")
    var
        RegEx: Codeunit "NPR RegEx";
    begin
        if Parameter."Integration Type" <> IntegrationType() then
            exit;

        case Parameter.Name of
            'LAN IP':
                if Parameter.Value <> '' then
                    if not RegEx.IsMatch(Parameter.Value, '^(?:(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])(\.(?!$)|$)){4}$') then
                        Parameter.FieldError(Value);
        end;
    end;

    procedure GetConnectionMethod(EFTSetup: Record "NPR EFT Setup"): Integer
    var
        EFTTypePOSUnitGenParam: Record "NPR EFTType POSUnit Gen.Param.";
    begin
        exit(EFTTypePOSUnitGenParam.GetOptionParameterValue(IntegrationType(), EFTSetup."POS Unit No.", 'Connection Method', 0, 'USB,Ethernet', true));
    end;

    procedure GetIPAddr(EFTSetup: Record "NPR EFT Setup"): Text
    var
        EFTTypePOSUnitGenParam: Record "NPR EFTType POSUnit Gen.Param.";
    begin
        exit(EFTTypePOSUnitGenParam.GetTextParameterValue(IntegrationType(), EFTSetup."POS Unit No.", 'LAN IP', '', true));
    end;

    procedure GetVirtualCOM(EFTSetup: Record "NPR EFT Setup"): Integer
    var
        EFTTypePOSUnitGenParam: Record "NPR EFTType POSUnit Gen.Param.";
    begin
        exit(EFTTypePOSUnitGenParam.GetIntegerParameterValue(IntegrationType(), EFTSetup."POS Unit No.", 'Virtual COM Port', 40, true));
    end;

    local procedure GetPOSUnitBlob1(EFTSetup: Record "NPR EFT Setup"; var TempBlob: Codeunit "Temp Blob")
    var
        EFTTypePOSUnitBLOBParam: Record "NPR EFTType POSUnit BLOBParam.";
    begin
        EFTTypePOSUnitBLOBParam.GetParameterValue(IntegrationType(), EFTSetup."POS Unit No.", 'Editable Binary Parameter', true, TempBlob);
    end;

    local procedure GetPOSUnitBlob2(EFTSetup: Record "NPR EFT Setup"; var TempBlob: Codeunit "Temp Blob")
    var
        EFTTypePOSUnitBLOBParam: Record "NPR EFTType POSUnit BLOBParam.";
    begin
        EFTTypePOSUnitBLOBParam.GetParameterValue(IntegrationType(), EFTSetup."POS Unit No.", 'Non-editable Binary Parameter', false, TempBlob);
    end;

    local procedure GetPaymentParam1(EFTSetup: Record "NPR EFT Setup"): Text
    var
        EFTTypePaymentGenParam: Record "NPR EFT Type Pay. Gen. Param.";
    begin
        exit(EFTTypePaymentGenParam.GetTextParameterValue(IntegrationType(), EFTSetup."Payment Type POS", 'Payment wide Parameter', 'DefaultValue', true));
    end;

    local procedure GetPaymentParam2(EFTSetup: Record "NPR EFT Setup"): Text
    var
        EFTTypePaymentGenParam: Record "NPR EFT Type Pay. Gen. Param.";
    begin
        exit(EFTTypePaymentGenParam.GetTextParameterValue(IntegrationType(), EFTSetup."Payment Type POS", 'Payment wide Parameter 2', 'DefaultValue', true));
    end;

    local procedure GetPaymentBlob1(EFTSetup: Record "NPR EFT Setup"; var TempBlob: Codeunit "Temp Blob")
    var
        EFTTypePaymentBLOBParam: Record "NPR EFTType Paym. BLOB Param.";
    begin
        EFTTypePaymentBLOBParam.GetParameterValue(IntegrationType(), EFTSetup."Payment Type POS", 'Payment wide BLOB Parameter', true, TempBlob);
    end;

    local procedure GetPaymentBlob2(EFTSetup: Record "NPR EFT Setup"; var TempBlob: Codeunit "Temp Blob")
    var
        EFTTypePaymentBLOBParam: Record "NPR EFTType Paym. BLOB Param.";
    begin
        EFTTypePaymentBLOBParam.GetParameterValue(IntegrationType(), EFTSetup."Payment Type POS", 'Payment wide BLOB Parameter 2', true, TempBlob)
    end;
}

