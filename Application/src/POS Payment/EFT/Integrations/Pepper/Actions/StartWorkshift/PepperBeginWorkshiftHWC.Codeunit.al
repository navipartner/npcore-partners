codeunit 6184497 "NPR Pepper Begin Workshift HWC"
{

    Access = Internal;

    var
        _LastResultCode: Integer;
        _ResultString: Text;
        _Envelope: JsonObject;
        _StartWorkshift: JsonObject;
        _ConfigDriver: JsonObject;
        _InitializedRequest: Boolean;
        _InitializedResponse: Boolean;

    #region Request
    procedure InitializeProtocol()
    var
        PepperTerminalCaptions: Codeunit "NPR Pepper Terminal Captions";
        PepperLabels: JsonObject;
    begin

        ClearAll();
        _Envelope.ReadFrom('{}');
        _Envelope.Add('WorkflowName', Format(Enum::"NPR POS Workflow"::EFT_PEPPER_OPEN));
        _Envelope.Add('HwcName', 'EFTPepper');

        PepperTerminalCaptions.GetLabels(PepperLabels);

        _Envelope.Add('Type', 'StartWorkshift');
        _Envelope.Add('Captions', PepperLabels);

        _ConfigDriver.ReadFrom('{}');

        _LastResultCode := -999998;
        _InitializedRequest := true;
    end;

    procedure AssembleHwcRequest(): JsonObject
    begin
        _StartWorkshift.Add('ConfigDriver', _ConfigDriver);
        _Envelope.Add('StartWorkshiftRequest', _StartWorkshift);
        exit(_Envelope);
    end;

    procedure SetTimeout(TimeoutMilliSeconds: Integer)
    begin

        if not _InitializedRequest then
            InitializeProtocol();

        if (TimeoutMilliSeconds = 0) then
            TimeoutMilliSeconds := 15000;

        _Envelope.Add('Timeout', TimeoutMilliSeconds);
    end;

    procedure SetHwcVerboseLogLevel()
    begin
        _Envelope.Add('LogLevel', 'Verbose');
    end;

    procedure SetReceiptEncoding(PepperEncodingName: Code[20])
    begin

        if not _InitializedRequest then
            InitializeProtocol();

        // Default value is UTF-8
        if (PepperEncodingName <> '') then
            _Envelope.Add('PepperReceiptEncoding', PepperEncodingName);
    end;

    procedure SetPepperFolder(Folder: Text[250])
    begin

        if not _InitializedRequest then
            InitializeProtocol();

        _StartWorkshift.Add('DllPath', Folder);
    end;

    procedure SetILP_UseConfigurationInstanceId(InstanceId: Integer)
    begin

        if not _InitializedRequest then
            InitializeProtocol();

        _StartWorkshift.Add('PepperConfigInstanceId', InstanceId);
    end;

    procedure SetILP_XmlConfigurationString(XmlConfigContents: Text)
    begin

        if not _InitializedRequest then
            InitializeProtocol();

        _StartWorkshift.Add('XmlConfigurationString', XmlConfigContents);
    end;

    procedure SetILP_XmlLicenseString(XmlLicenseContents: Text)
    begin

        if not _InitializedRequest then
            InitializeProtocol();

        _StartWorkshift.Add('XmlLicenseString', XmlLicenseContents);
    end;

    procedure SetILP_ForceGetPepperLicense(LicenseId: Code[8]; CustomerId: Code[8])
    begin

        if not _InitializedRequest then
            InitializeProtocol();

        _StartWorkshift.Add('LicenseId', LicenseId);
        _StartWorkshift.Add('CustomerId', CustomerId);
    end;

    procedure SetCDP_ComPort(ComPortNumber: Integer)
    begin

        if not _InitializedRequest then
            InitializeProtocol();

        _ConfigDriver.Add('ComPort', ComPortNumber);
    end;

    procedure SetCDP_IpAddressAndPort(IpAddressAndPort: Text[30])
    begin

        if not _InitializedRequest then
            InitializeProtocol();

        _ConfigDriver.Add('IPAddress', IpAddressAndPort);
    end;

    procedure SetCDP_EftTerminalInformation(EftTerminalType: Integer; Language: Integer; UnitNumber: Integer; ReceiptFormat: Code[2])
    begin

        if not _InitializedRequest then
            InitializeProtocol();

        _ConfigDriver.Add('PayTermType', EftTerminalType);
        _ConfigDriver.Add('LanguageCode', Language);
        _ConfigDriver.Add('CashRegisterNbr', UnitNumber);
        _ConfigDriver.Add('ReceiptFormat', ReceiptFormat);
    end;

    procedure SetCDP_MatchboxInformation(FileOutputOption: Integer; CompanyId: Code[10]; ShopId: Code[10]; PosId: Code[10]; FileName: Text)
    begin

        if not _InitializedRequest then
            InitializeProtocol();

        _ConfigDriver.Add('MbxFileSw', FileOutputOption);

        _ConfigDriver.Add('MbxCompanyId', CompanyId);
        _ConfigDriver.Add('MbxShopId', ShopId);
        _ConfigDriver.Add('MbxPosId', PosId);
        _ConfigDriver.Add('MbxFile', FileName);
    end;

    procedure SetCDP_Filenames(OpenPrintFile: Text; ClosePrintFile: Text; TrxPrintFile: Text; CCTrxPrintFile: Text; DiffPrintFile: Text; EndOfDayPrintFile: Text; JournalPrintFile: Text; IniPrintFile: Text)
    begin

        if not _InitializedRequest then
            InitializeProtocol();

        _ConfigDriver.Add('OpenPrintFile', OpenPrintFile);
        _ConfigDriver.Add('ClosePrintFile', ClosePrintFile);
        _ConfigDriver.Add('TrxPrintFile', TrxPrintFile);
        _ConfigDriver.Add('CCTrxPrintFile', CCTrxPrintFile);
        _ConfigDriver.Add('DiffPrintFile', DiffPrintFile);
        _ConfigDriver.Add('EodPrintFile', EndOfDayPrintFile);
        _ConfigDriver.Add('JourPrintFile', JournalPrintFile);
        _ConfigDriver.Add('IniPrintFile', IniPrintFile);
    end;

    procedure SetCDP_AdditionalParameters(XmlAdditionalParameters: Text)
    begin

        if not _InitializedRequest then
            InitializeProtocol();

        _ConfigDriver.Add('XmlAdditionalParameters', XmlAdditionalParameters);
    end;

    procedure SetHeaderFooters(OverwriteClientFiles: Boolean; ConfigurationFolder: Text; TrxHeaderContents: Text; TrxFooterContents: Text; CcTrxHeaderContents: Text; CcTrxFooterContents: Text; AdmHeaderContents: Text; AdmFooterContents: Text)
    begin

        if not _InitializedRequest then
            InitializeProtocol();

        _StartWorkshift.Add('OverwriteClientHeaderAndFooterFiles', OverwriteClientFiles);
        _StartWorkshift.Add('ConfigurationFileFolder', ConfigurationFolder);

        _StartWorkshift.Add('TrxHeaderData', TrxHeaderContents);
        _StartWorkshift.Add('TrxFooterData', TrxFooterContents);

        _StartWorkshift.Add('CcTrxHeaderData', CcTrxHeaderContents);
        _StartWorkshift.Add('CcTrxFooterData', CcTrxFooterContents);

        _StartWorkshift.Add('AdministrationHeaderData', AdmHeaderContents);
        _StartWorkshift.Add('AdministrationFooterData', AdmFooterContents);
    end;

    procedure SetPOP_Operator(OperatorNumber: Integer)
    begin

        if not _InitializedRequest then
            InitializeProtocol();

        _StartWorkshift.Add('OperatorNbr', OperatorNumber);
    end;

    procedure SetPOP_AdditionalParameters(XmlAdditionalParameters: Text)
    begin
    end;

    #endregion

    #region Response

    procedure SetResponse(HwcResponse: JsonObject)
    var
        JToken: JsonToken;
    begin

        // Lets blow up on invalid response
        HwcResponse.Get('ResultCode', JToken);
        _LastResultCode := JToken.AsValue().AsInteger();

        HwcResponse.Get('ResultString', JToken);
        _ResultString := JToken.AsValue().AsText();

        HwcResponse.Get('StartWorkshiftResponse', JToken);
        _StartWorkshift := JToken.AsObject();

        _InitializedResponse := true;
    end;

    procedure GetILP_XmlLicenseString(var XmlLicenseContents: Text) HaveLicenseText: Boolean
    var
        JToken: JsonToken;
    begin

        if (not _InitializedResponse) then
            exit(false);

        _StartWorkshift.Get('XmlLicenseString', JToken);
        XmlLicenseContents := JToken.AsValue().AsText();
        exit(XmlLicenseContents <> '');
    end;

    procedure GetCDP_RecoveryRequired() RecoveryRequired: Boolean
    var
        JToken: JsonToken;
    begin

        if (not _InitializedResponse) then
            exit(false);

        _StartWorkshift.Get('RecoveryRequired', JToken);
        exit(JToken.AsValue().AsBoolean());
    end;

    procedure GetPOP_ResultCode() ResultCode: Integer
    begin

        if (not _InitializedResponse) then
            exit(-999999);

        exit(_LastResultCode);
    end;

    procedure GetPOP_ResultString() ResultString: Text
    begin
        if (not _InitializedResponse) then
            exit('');

        exit(_ResultString);
    end;

    procedure GetPOP_OpenReceipt() OpenReceipt: Text
    var
        JToken: JsonToken;
    begin

        if (not _InitializedResponse) then
            exit('');

        _StartWorkshift.Get('OpenReceipt', JToken);
        exit(JToken.AsValue().AsText());
    end;

    procedure SetTransactionEntryNo(EntryNo: Integer)
    begin

        if not _InitializedRequest then
            InitializeProtocol();

        _Envelope.Add('EntryNo', EntryNo);
    end;

    #endregion

}