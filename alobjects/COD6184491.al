codeunit 6184491 "Pepper Begin Workshift TSD"
{
    // NPR5.30/TSA/20170123  CASE 263458 Refactored for Transcendence


    trigger OnRun()
    begin
    end;

    var
        InitializedRequest: Boolean;
        InitializedResponse: Boolean;
        StartWorkShiftRequest: DotNet StartWorkshiftRequest0;
        StartWorkShiftResponse: DotNet StartWorkshiftResponse0;
        ConfigDriver: DotNet ConfigDriverParam0;
        PepperOpen: DotNet OpenParam0;
        Labels: DotNet ProcessLabels0;
        PepperTerminalCaptions: Codeunit "Pepper Terminal Captions TSD";
        LastRestCode: Integer;

    procedure InitializeProtocol()
    begin

        ClearAll();

        StartWorkShiftRequest := StartWorkShiftRequest.StartWorkshiftRequest ();
        StartWorkShiftResponse := StartWorkShiftResponse.StartWorkshiftResponse ();
        StartWorkShiftRequest.ShowPinPadStatusDialog := true;

        PepperTerminalCaptions.GetLabels (Labels);
        StartWorkShiftRequest.ProcessLabels := Labels;

        ConfigDriver := ConfigDriver.ConfigDriverParam ();
        PepperOpen := PepperOpen.OpenParam ();

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

    procedure SetReceiptEncoding(PepperEncodingName: Code[20];NavisionEncodingName: Code[20])
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

    procedure SetDecodeXmlTicketToText(DecodeXmlTicket: Boolean)
    begin

        if not InitializedRequest then
          InitializeProtocol();

        StartWorkShiftRequest.DecodeXmlReceiptToText := DecodeXmlTicket;
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

    procedure SetILP_ForceGetPepperLicense(LicenseId: Code[8];CustomerId: Code[8])
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

    procedure SetCDP_EftTerminalInformation(EftTerminalType: Integer;Language: Integer;CashRegisterNumber: Integer;ReceiptFormat: Code[2])
    begin

        if not InitializedRequest then
          InitializeProtocol();

        ConfigDriver.PayTermType := EftTerminalType;
        ConfigDriver.LanguageCode := Language;
        ConfigDriver.CashRegisterNbr := CashRegisterNumber;
        ConfigDriver.ReceiptFormat := ReceiptFormat;
    end;

    procedure SetCDP_MatchboxInformation(FileOutputOption: Integer;CompanyId: Code[10];ShopId: Code[10];PosId: Code[10];FileName: Text)
    begin

        if not InitializedRequest then
          InitializeProtocol();

        ConfigDriver.MbxFileSw := FileOutputOption;

        ConfigDriver.MbxCompanyId := CompanyId;
        ConfigDriver.MbxShopId := ShopId;
        ConfigDriver.MbxPosId := PosId;
        ConfigDriver.MbxFile := FileName
    end;

    procedure SetCDP_Filenames(OpenPrintFile: Text;ClosePrintFile: Text;TrxPrintFile: Text;CCTrxPrintFile: Text;DiffPrintFile: Text;EndOfDayPrintFile: Text;JournalPrintFile: Text;IniPrintFile: Text)
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

    procedure SetHeaderFooters(OverwriteClientFiles: Boolean;ConfigurationFolder: Text;TrxHeaderContents: Text;TrxFooterContents: Text;CcTrxHeaderContents: Text;CcTrxFooterContents: Text;AdmHeaderContents: Text;AdmFooterContents: Text)
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

    local procedure "---Pepper_Get"()
    begin
    end;

    procedure GetILP_XmlLicenseString(var XmlLicenseContents: Text) HaveLicenseText: Boolean
    begin

        if (not InitializedResponse) then
          exit (false);

        XmlLicenseContents := StartWorkShiftResponse.XmlLicenseString;
        exit (XmlLicenseContents <> '');
    end;

    procedure GetCDP_RecoveryRequired() RecoveryRequired: Boolean
    begin

        if (not InitializedResponse) then
          exit (false);

        exit (StartWorkShiftResponse.RecoveryRequired);
    end;

    procedure GetPOP_ResultCode() ResultCode: Integer
    begin

        if (not InitializedResponse) then
          exit (-999999);

        exit (LastRestCode);
    end;

    procedure GetPOP_OpenReceipt() OpenReceipt: Text
    begin

        if (not InitializedResponse) then
          exit ('');

        exit (StartWorkShiftResponse.OpenReceipt ());
    end;

    local procedure "--Stargate2"()
    begin
    end;

    procedure SetTransactionEntryNo(EntryNo: Integer)
    begin

        if not InitializedRequest then
          InitializeProtocol();

        StartWorkShiftRequest.RequestEntryNo := EntryNo;
    end;

    procedure InvokeBeginWorkshift(var FrontEnd: Codeunit "POS Front End Management";var POSSession: Codeunit "POS Session")
    begin

        StartWorkShiftRequest.ConfigDriverParam := ConfigDriver;
        StartWorkShiftRequest.OpenParam := PepperOpen;

        FrontEnd.InvokeDevice (StartWorkShiftRequest, 'Pepper_EFTOpen', 'EFTOpen');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150716, 'OnDeviceResponse', '', false, false)]
    local procedure OnDeviceResponse(ActionName: Text;Step: Text;Envelope: DotNet ResponseEnvelope0;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    begin

        if (ActionName <> 'Pepper_EFTOpen') then
          exit;

        // Pepper has a VOID response. Actual Return Data is on the CloseForm Event
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150716, 'OnAppGatewayProtocol', '', false, false)]
    local procedure OnDeviceEvent(ActionName: Text;EventName: Text;Data: Text;ResponseRequired: Boolean;var ReturnData: Text;var Handled: Boolean)
    var
        EFTTransactionRequest: Record "EFT Transaction Request";
    begin

        if (ActionName <> 'Pepper_EFTOpen') then
          exit;

        Handled := true;

        case EventName of
          'CloseForm':
            begin
              StartWorkShiftResponse := StartWorkShiftResponse.Deserialize (Data);
              LastRestCode := StartWorkShiftResponse.LastResultCode();
              InitializedResponse := true;

              EFTTransactionRequest.Get (StartWorkShiftResponse.RequestEntryNo);
              OnBeginWorkshiftReponse (EFTTransactionRequest."Entry No.");
            end;
        end;
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnBeginWorkshiftReponse(EFTPaymentRequestID: Integer)
    begin
    end;
}

