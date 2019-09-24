// TODO: CTRLUPGRADE - This codeunit is the remnants of old Stargate v1 protocol codeunit after all Proxy Manager stuff was taken out - it may contain some legit stuff, but most likely should all be removed - INVESTIGATE

codeunit 6184481 "Pepper Begin Workshift"
{
    // NPR5.25/TSA/20160513  CASE 239285 Version up to 5.0.398.2
    // NPR5.26/TSA/20160809 CASE 248452 Assembly Version Up - JBAXI Support, General Improvements

    SingleInstance = true;

    var
        InitializedRequest: Boolean;
        StartWorkShiftRequest: DotNet npNetStartWorkshiftRequest;
        StartWorkShiftResponse: DotNet npNetStartWorkshiftResponse;
        ConfigDriver: DotNet npNetConfigDriverParam;
        PepperOpen: DotNet npNetOpenParam;
        Labels: DotNet npNetProcessLabels;
        PepperTerminalCaptions: Codeunit "Pepper Terminal Captions";
        LastRestCode: Integer;

    local procedure InitializeProtocol()
    begin
        ClearAll();

        StartWorkShiftRequest := StartWorkShiftRequest.StartWorkshiftRequest();
        StartWorkShiftResponse := StartWorkShiftResponse.StartWorkshiftResponse();

        PepperTerminalCaptions.GetLabels(Labels);
        StartWorkShiftRequest.ProcessLabels := Labels;

        ConfigDriver := ConfigDriver.ConfigDriverParam();
        PepperOpen := PepperOpen.OpenParam();

        LastRestCode := -999998;
        InitializedRequest := true;
    end;

    procedure SetTimout(TimeoutMillies: Integer)
    begin

        if not InitializedRequest then
            InitializeProtocol();

        if (TimeoutMillies = 0) then
            TimeoutMillies := 15000;

        StartWorkShiftRequest.TimeoutMillies := TimeoutMillies;
    end;

    procedure SetReceiptEncoding(PepperEncodingName: Code[20]; NavisionEncodingName: Code[20])
    begin

        if not InitializedRequest then
            InitializeProtocol();

        // Default value is UTF-8
        if (PepperEncodingName <> '') then
            StartWorkShiftRequest.PepperReceiptEncoding := PepperEncodingName;

        // Default value is ISO-8859-1
        if (NavisionEncodingName <> '') then
            StartWorkShiftRequest.NavisionReceiptEncoding := NavisionEncodingName;
    end;

    procedure SetPepperFolder(Folder: Text[250])
    begin

        if not InitializedRequest then
            InitializeProtocol();

        StartWorkShiftRequest.DllPath := Folder;
    end;

    procedure SetILP_UseConfigurationInstanceId(InstanceId: Integer)
    begin

        if not InitializedRequest then
            InitializeProtocol();

        StartWorkShiftRequest.PepperConfigInstanceId := InstanceId;
    end;

    procedure SetILP_XmlConfigurationString(XmlConfigContents: Text)
    begin

        if not InitializedRequest then
            InitializeProtocol();

        StartWorkShiftRequest.XmlConfigurationString := XmlConfigContents;
    end;

    procedure SetILP_XmlLicenseString(XmlLicenseContents: Text)
    begin

        if not InitializedRequest then
            InitializeProtocol();

        StartWorkShiftRequest.XmlLicenseString := XmlLicenseContents;
    end;

    procedure SetILP_ForceGetPepperLicense(LicenseId: Code[8]; CustomerId: Code[8])
    begin

        if not InitializedRequest then
            InitializeProtocol();

        StartWorkShiftRequest.LicenseId := LicenseId;
        StartWorkShiftRequest.CustomerId := CustomerId;
    end;

    procedure SetCDP_ComPort(ComPortNumber: Integer)
    begin

        if not InitializedRequest then
            InitializeProtocol();

        ConfigDriver.ComPort := ComPortNumber;
    end;

    procedure SetCDP_IpAddressAndPort(IpAddressAndPort: Text[30])
    begin

        if not InitializedRequest then
            InitializeProtocol();

        ConfigDriver.IPAddress := IpAddressAndPort;
    end;

    procedure SetCDP_EftTerminalInformation(EftTerminalType: Integer; Language: Integer; CashRegisterNumber: Integer; ReceiptFormat: Code[2])
    begin

        if not InitializedRequest then
            InitializeProtocol();

        ConfigDriver.PayTermType := EftTerminalType;
        ConfigDriver.LanguageCode := Language;
        ConfigDriver.CashRegisterNbr := CashRegisterNumber;
        ConfigDriver.ReceiptFormat := ReceiptFormat;
    end;

    procedure SetCDP_MatchboxInformation(FileOutputOption: Integer; CompanyId: Code[10]; ShopId: Code[10]; PosId: Code[10]; FileName: Text)
    begin

        if not InitializedRequest then
            InitializeProtocol();

        ConfigDriver.MbxFileSw := FileOutputOption;

        ConfigDriver.MbxCompanyId := CompanyId;
        ConfigDriver.MbxShopId := ShopId;
        ConfigDriver.MbxPosId := PosId;
        ConfigDriver.MbxFile := FileName
    end;

    procedure SetCDP_Filenames(OpenPrintFile: Text; ClosePrintFile: Text; TrxPrintFile: Text; CCTrxPrintFile: Text; DiffPrintFile: Text; EndOfDayPrintFile: Text; JournalPrintFile: Text; IniPrintFile: Text)
    begin

        if not InitializedRequest then
            InitializeProtocol();

        ConfigDriver.OpenPrintFile := OpenPrintFile;
        ConfigDriver.ClosePrintFile := ClosePrintFile;
        ConfigDriver.TrxPrintFile := TrxPrintFile;
        ConfigDriver.CCTrxPrintFile := CCTrxPrintFile;
        ConfigDriver.DiffPrintFile := DiffPrintFile;
        ConfigDriver.EodPrintFile := EndOfDayPrintFile;
        ConfigDriver.JourPrintFile := JournalPrintFile;
        ConfigDriver.IniPrintFile := IniPrintFile;
    end;

    procedure SetCDP_AdditionalParameters(XmlAdditionalParameters: Text)
    begin

        if not InitializedRequest then
            InitializeProtocol();

        ConfigDriver.XmlAdditionalParameters := XmlAdditionalParameters;
    end;

    procedure SetHeaderFooters(OverwriteClientFiles: Boolean; ConfigurationFolder: Text; TrxHeaderContents: Text; TrxFooterContents: Text; CcTrxHeaderContents: Text; CcTrxFooterContents: Text; AdmHeaderContents: Text; AdmFooterContents: Text)
    begin

        if not InitializedRequest then
            InitializeProtocol();

        StartWorkShiftRequest.OverwriteClientHeaderAndFooterFiles := OverwriteClientFiles;
        StartWorkShiftRequest.ConfigurationFileFolder := ConfigurationFolder;

        StartWorkShiftRequest.TrxHeaderData := TrxHeaderContents;
        StartWorkShiftRequest.TrxFooterData := TrxFooterContents;

        StartWorkShiftRequest.CcTrxHeaderData := CcTrxHeaderContents;
        StartWorkShiftRequest.CcTrxFooterData := CcTrxFooterContents;

        StartWorkShiftRequest.AdministrationHeaderData := AdmHeaderContents;
        StartWorkShiftRequest.AdministrationFooterData := AdmFooterContents;
    end;

    procedure SetPOP_Operator(OperatorNumber: Integer)
    begin

        if not InitializedRequest then
            InitializeProtocol();

        PepperOpen.OperatorNbr := OperatorNumber;
    end;

    procedure SetPOP_AdditionalParameters(XmlAdditionalParameters: Text)
    begin
    end;

    procedure GetILP_XmlLicenseString(var XmlLicenseContents: Text) HaveLicenseText: Boolean
    begin

        if (not InitializedRequest) then
            exit(false);

        XmlLicenseContents := StartWorkShiftResponse.XmlLicenseString;
        exit(XmlLicenseContents <> '');
    end;

    procedure GetCDP_RecoveryRequired() RecoveryRequired: Boolean
    begin

        if (not InitializedRequest) then
            exit(false);

        exit(StartWorkShiftResponse.RecoveryRequired);
    end;

    procedure GetPOP_ResultCode() ResultCode: Integer
    begin

        if (not InitializedRequest) then
            exit(-999999);

        exit(LastRestCode);
    end;

    procedure GetPOP_OpenReceipt() OpenReceipt: Text
    begin

        if (not InitializedRequest) then
            exit('');

        exit(StartWorkShiftResponse.OpenReceipt());
    end;
}

