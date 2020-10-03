table 6184492 "NPR Pepper Terminal"
{
    Caption = 'Pepper Terminal';
    DataClassification = CustomerContent;
    DataCaptionFields = "Code", Description;
    DrillDownPageID = "NPR Pepper Terminal List";
    LookupPageID = "NPR Pepper Terminal List";

    fields
    {
        field(10; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(20; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(30; "Instance ID"; Integer)
        {
            Caption = 'Instance ID';
            DataClassification = CustomerContent;
            TableRelation = "NPR Pepper Instance";

            trigger OnValidate()
            var
                Instance: Record "NPR Pepper Instance";
            begin
                if Instance.Get("Instance ID") then
                    Instance.TestField(Instance."Configuration Code");
            end;
        }
        field(40; "Configuration Code"; Code[10])
        {
            CalcFormula = Lookup ("NPR Pepper Instance"."Configuration Code" WHERE(ID = FIELD("Instance ID")));
            Caption = 'Configuration Code';
            Editable = false;
            FieldClass = FlowField;
            TableRelation = "NPR Pepper Config.";
        }
        field(50; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR Register";

            trigger OnValidate()
            begin
                if ("Register No." <> '') and GuiAllowed then
                    if xRec."Register No." <> "Register No." then
                        CheckDuplicateRegister;
            end;
        }
        field(60; "Open Automatically"; Boolean)
        {
            Caption = 'Open Automatically';
            DataClassification = CustomerContent;
        }
        field(70; "Close Automatically"; Boolean)
        {
            Caption = 'Close Automatically';
            DataClassification = CustomerContent;
            Description = 'CASE255131';
        }
        field(100; "Com Port"; Integer)
        {
            Caption = 'Com Port';
            DataClassification = CustomerContent;
            InitValue = 1;
            MaxValue = 10;
            MinValue = 1;
        }
        field(110; Language; Option)
        {
            Caption = 'Language';
            DataClassification = CustomerContent;
            OptionCaption = 'English,German,French,Italian,Slovene,Dutch,Czech,Spanish,Polish,Slovakian,Danish,Norwegian,Swedish,Finnish,Romanian,15,16,17,18,19,20,21,22,23,24,25';
            OptionMembers = English,German,French,Italian,Slovene,Dutch,Czech,Spanish,Polish,Slovakian,Danish,Norwegian,Swedish,Finnish,Romanian,"15","16","17","18","19","20","21","22","23","24","25";
        }
        field(120; "IP Address"; Text[30])
        {
            Caption = 'IP Address';
            DataClassification = CustomerContent;
            CharAllowed = '09::..';
        }
        field(130; "Terminal Type Code"; Integer)
        {
            Caption = 'Terminal Type Code';
            DataClassification = CustomerContent;
            MinValue = 0;
            TableRelation = "NPR Pepper Terminal Type";

            trigger OnValidate()
            var
                TerminalType: Record "NPR Pepper Terminal Type";
            begin
                if TerminalType.Get("Terminal Type Code") then
                    TerminalType.TestField(Active);
            end;
        }
        field(140; "Receipt Format"; Integer)
        {
            Caption = 'Receipt Format';
            DataClassification = CustomerContent;
            InitValue = 40;
            MaxValue = 99;
            MinValue = 20;
        }
        field(150; "Pepper Receipt Encoding"; Option)
        {
            Caption = 'Pepper Receipt Encoding';
            DataClassification = CustomerContent;
            OptionCaption = 'Default,utf-8,iso-8859-1,iso-8859-2,iso-8859-3,iso-8859-4,iso-8859-5,iso-8859-6,iso-8859-7,iso-8859-8,iso-8859-9,iso-8859-13,iso-8859-15';
            OptionMembers = Default,"utf-8","iso-8859-1","iso-8859-2","iso-8859-3","iso-8859-4","iso-8859-5","iso-8859-6","iso-8859-7","iso-8859-8","iso-8859-9","iso-8859-13","iso-8859-15";
        }
        field(151; "NAV Receipt Encoding"; Option)
        {
            Caption = 'NAV Receipt Encoding';
            DataClassification = CustomerContent;
            OptionCaption = 'Default,utf-8,iso-8859-1,iso-8859-2,iso-8859-3,iso-8859-4,iso-8859-5,iso-8859-6,iso-8859-7,iso-8859-8,iso-8859-9,iso-8859-13,iso-8859-15';
            OptionMembers = Default,"utf-8","iso-8859-1","iso-8859-2","iso-8859-3","iso-8859-4","iso-8859-5","iso-8859-6","iso-8859-7","iso-8859-8","iso-8859-9","iso-8859-13","iso-8859-15";
        }
        field(160; "Add Customer Signature Space"; Boolean)
        {
            Caption = 'Add Customer Signature Space';
            DataClassification = CustomerContent;
        }
        field(170; "Cancel at Wrong Signature"; Boolean)
        {
            Caption = 'Cancel at Wrong Signature';
            DataClassification = CustomerContent;
            Description = 'NPR5.29';
        }
        field(200; "Matchbox Files"; Option)
        {
            Caption = 'Matchbox Files';
            DataClassification = CustomerContent;
            OptionCaption = 'No Matchbox output,Succesful transactions only,All succesful operactions,All operations';
            OptionMembers = "0","1","2","3";
        }
        field(210; "Matchbox Company ID"; Code[10])
        {
            Caption = 'Matchbox Company ID';
            DataClassification = CustomerContent;
        }
        field(220; "Matchbox Shop ID"; Code[10])
        {
            Caption = 'Matchbox Shop ID';
            DataClassification = CustomerContent;
        }
        field(230; "Matchbox POS ID"; Code[10])
        {
            Caption = 'Matchbox POS ID';
            DataClassification = CustomerContent;
        }
        field(240; "Matchbox File Name"; Text[250])
        {
            Caption = 'Matchbox File Name';
            DataClassification = CustomerContent;
        }
        field(300; "Print File Open"; Text[250])
        {
            Caption = 'Print File Open';
            DataClassification = CustomerContent;
        }
        field(310; "Print File Close"; Text[250])
        {
            Caption = 'Print File Close';
            DataClassification = CustomerContent;
        }
        field(320; "Print File Transaction"; Text[250])
        {
            Caption = 'Print File Transaction';
            DataClassification = CustomerContent;
        }
        field(330; "Print File CC Transaction"; Text[250])
        {
            Caption = 'Print File CC Transaction';
            DataClassification = CustomerContent;
        }
        field(340; "Print File Difference"; Text[250])
        {
            Caption = 'Print File Difference';
            DataClassification = CustomerContent;
        }
        field(350; "Print File End of Day"; Text[250])
        {
            Caption = 'Print File End of Day';
            DataClassification = CustomerContent;
        }
        field(360; "Print File Journal"; Text[250])
        {
            Caption = 'Print File Journal';
            DataClassification = CustomerContent;
        }
        field(370; "Print File Initialisation"; Text[250])
        {
            Caption = 'Print File Initialisation';
            DataClassification = CustomerContent;
        }
        field(500; "Additional Parameters File"; BLOB)
        {
            Caption = 'Additional Parameters File';
            DataClassification = CustomerContent;
        }
        field(600; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionCaption = 'Unknown,Open,Closed,ActiveOffline';
            OptionMembers = Unknown,Open,Closed,ActiveOffline;

            trigger OnValidate()
            var
                TxtOfflineDisabled: Label 'Offline mode is disabled in the Pepper Configuration.';
            begin
                if Rec.Status = Rec.Status::ActiveOffline then
                    if not GetOfflineAllowed then
                        Error(TxtOfflineDisabled);
            end;
        }
        field(650; "Fixed Currency Code"; Code[10])
        {
            Caption = 'Fixed Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
            ValidateTableRelation = false;
        }
        field(700; "Customer ID"; Text[8])
        {
            Caption = 'Customer ID';
            DataClassification = CustomerContent;
        }
        field(710; "License ID"; Text[8])
        {
            Caption = 'License ID';
            DataClassification = CustomerContent;
        }
        field(900; "License File"; BLOB)
        {
            Caption = 'License File';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        FillDefaultPrintFileNames;
    end;

    procedure UploadFile(FileType: Option License,AdditionalParameters)
    var
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        UploadResult: Text[250];
        TxtNotUploaded: Label 'File was not uploaded.';
        TxtSuccess: Label 'File %1 was uploaded.';
        TxtNotStored: Label 'File was not stored.';
        TxtTerminalTypeNotLicensed: Label 'Warning: the license is valid for Terminal Type code %1. Please check the Terminal Type code or upload a new license.';
        TxtCaptionAdditionalParameters: Label 'Pepper Additional Parameters';
        TxtCaptionLicense: Label 'Pepper License';
        TxtDescription: Label 'XML File';
        TxtXMLfilefilter: Label '*.xml';
        TxtXMLfileDescription: Label 'XML Files (*.xml)|*.xml';
        CaptionText: Text;
        PepperLibrary: Codeunit "NPR Pepper Library TSD";
        PepperConfigManagement: Codeunit "NPR Pepper Config. Mgt.";
        LicensedTerminalType: Integer;
        RecRef: RecordRef;
    begin
        case FileType of
            FileType::AdditionalParameters:
                CaptionText := TxtCaptionAdditionalParameters;
            FileType::License:
                CaptionText := TxtCaptionLicense;
        end;
        UploadResult := FileManagement.BLOBImportWithFilter(TempBlob, CaptionText, '', TxtXMLfileDescription, TxtXMLfilefilter);
        if UploadResult = '' then
            Error(TxtNotUploaded);
        Message(StrSubstNo(TxtSuccess, UploadResult));
        case FileType of
            FileType::AdditionalParameters:
                begin
                    CalcFields("Additional Parameters File");
                    Clear("Additional Parameters File");
                    Modify;
                    CalcFields("Additional Parameters File");

                    RecRef.GetTable(Rec);
                    TempBlob.ToRecordRef(RecRef, FieldNo("Additional Parameters File"));
                    RecRef.SetTable(Rec);

                    Modify;

                    if not "Additional Parameters File".HasValue then
                        Error(TxtNotStored);
                end;

            FileType::License:
                begin
                    CalcFields("License File");
                    Clear("License File");
                    Modify;
                    CalcFields("License File");

                    RecRef.GetTable(Rec);
                    TempBlob.ToRecordRef(RecRef, FieldNo("License File"));
                    RecRef.SetTable(Rec);

                    "License ID" := PepperLibrary.GetKeyFromLicenseText(PepperConfigManagement.GetTerminalText(Rec, 0));
                    LicensedTerminalType := PepperLibrary.GetTerminalTypeFromLicenseText(PepperConfigManagement.GetTerminalText(Rec, 0));
                    if LicensedTerminalType <> 0 then begin
                        if ("Terminal Type Code" = 0) then
                            Validate("Terminal Type Code", LicensedTerminalType)
                        else
                            if GuiAllowed then
                                if LicensedTerminalType <> "Terminal Type Code" then
                                    Message(TxtTerminalTypeNotLicensed, LicensedTerminalType);
                    end;

                    Modify;
                    if not "License File".HasValue then
                        Error(TxtNotStored);
                end;

        end;
    end;

    procedure ClearFile(FileType: Option License,AdditionalParameters)
    var
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        UploadResult: Text[250];
        TxtNoLicense: Label 'Are you sure you want to delete the additional parameters?';
        TxtNoAdditionalParameters: Label 'No addtional parameters are configured.';
        TxtConfirmClearLicense: Label 'No addtional parameters are configured.';
        TxtConfirmClearAdditionalParameters: Label 'Are you sure you want to delete the additional parameters?';
        TxtLicenseCleared: Label 'License deleted.';
        TxtAdditionalParametersCleared: Label 'Additional Parameters deleted.';
    begin

        case FileType of
            FileType::License:
                begin
                    CalcFields("License File");
                    if not "License File".HasValue then
                        Error(TxtNoLicense);
                    if not Confirm(TxtConfirmClearLicense) then
                        exit;
                    Clear("License File");
                    Modify;
                    Message(TxtLicenseCleared);
                end;
            FileType::AdditionalParameters:
                begin
                    CalcFields("Additional Parameters File");
                    if not "Additional Parameters File".HasValue then
                        Error(TxtNoAdditionalParameters);
                    if not Confirm(TxtConfirmClearAdditionalParameters) then
                        exit;
                    Clear("Additional Parameters File");
                    Modify;
                    Message(TxtAdditionalParametersCleared);
                end;
        end;

    end;

    procedure ShowFile(OptFileType: Option License,AdditionalParameters)
    var
        PepperConfigManagement: Codeunit "NPR Pepper Config. Mgt.";
        TxtNoAddParam: Label 'This Pepper Terminal does not have Additional Parameters set up. The Addition Parameters will be taken from Pepper Configuration %1.';
        TxtNoLicense: Label 'This Pepper Terminal does not have License set up. The License will be taken from Pepper Configuration %1.';
    begin

        case OptFileType of
            OptFileType::AdditionalParameters:
                begin
                    CalcFields("Additional Parameters File");
                    if not "Additional Parameters File".HasValue then
                        Message(TxtNoAddParam, "Configuration Code");
                    Message(PepperConfigManagement.GetTerminalText(Rec, OptFileType));

                end;
            OptFileType::License:
                begin
                    CalcFields("License File");
                    if not "License File".HasValue then
                        Message(TxtNoLicense, "Configuration Code");
                    Message(PepperConfigManagement.GetTerminalText(Rec, OptFileType));
                end;
        end;

    end;

    procedure ExportFile(OptFileType: Option License,AdditionalParameters)
    var
        TxtNoAddParam: Label 'This Pepper Terminal does not have Additional Parameters set up. The Addition Parameters will be taken from Pepper Configuration %1.';
        TxtNoLicense: Label 'This Pepper Terminal does not have License set up. The License will be taken from Pepper Configuration %1.';
        TxtNoLicenseToExport: Label 'This Pepper Terminal does not have License set up.';
        TxtFileName: Label 'AdditionalParameters.xml';
        ExportName: Text;
        TxtFileNameLicense: Text;
        StreamIn: InStream;
        TxtTitle: Label 'XML File Export';
        TxtXMLFileFilter: Label 'XML Files (*.xml)|*.xml';
    begin

        case OptFileType of
            OptFileType::License:
                begin
                    CalcFields("License File");
                    if not "License File".HasValue then
                        Error(TxtNoLicenseToExport);

                    ExportName := TxtFileNameLicense;
                    "License File".CreateInStream(StreamIn);
                    DownloadFromStream(StreamIn, TxtTitle, '', TxtXMLFileFilter, ExportName);
                end;
            OptFileType::AdditionalParameters:
                if not "Additional Parameters File".HasValue then begin
                    Message(TxtNoAddParam, "Configuration Code");
                end else begin
                    ExportName := TxtFileName;
                    "Additional Parameters File".CreateInStream(StreamIn);
                    DownloadFromStream(StreamIn, TxtTitle, '', TxtXMLFileFilter, ExportName);
                end;
        end;

    end;

    local procedure CheckDuplicateRegister()
    var
        PepperTerminal: Record "NPR Pepper Terminal";
        NoOtherTerminalsLinkedtoRegister: Integer;
        TerminalLinked: Label 'Terminal %1 is already linked to Register %2. Are you sure you want to link this register to this terminal?';
        TerminalsLinked: Label 'There are %1 other terminals already linked to Register %2. Are you sure you want to link this register to this terminal?';
        NotLinked: Label 'Terminal not linked to Register.';
    begin
        PepperTerminal.Reset;
        PepperTerminal.SetRange("Register No.", "Register No.");
        PepperTerminal.SetFilter(Code, '<>%1', Code);
        NoOtherTerminalsLinkedtoRegister := PepperTerminal.Count;
        if NoOtherTerminalsLinkedtoRegister = 0 then
            exit;
        if NoOtherTerminalsLinkedtoRegister = 1 then begin
            PepperTerminal.FindFirst;
            if not Confirm(TerminalLinked, true, PepperTerminal.Code, "Register No.") then
                Error(NotLinked);
            exit;
        end;
        if not Confirm(TerminalsLinked, true, Format(NoOtherTerminalsLinkedtoRegister), PepperTerminal.Code, "Register No.") then
            Error(NotLinked);
    end;

    local procedure FillDefaultPrintFileNames()
    var
        DefaultPrintFileOpen: Label 'open_nav_%1.txt';
        DefaultPrintFileClose: Label 'close_nav_%1.txt';
        DefaultPrintFileTransaction: Label 'trx_nav_%1.txt';
        DefaultPrintFileCCTransaction: Label 'trxcc_nav_%1.txt';
        DefaultPrintFileDifference: Label 'diff_nav_%1.txt';
        DefaultPrintFileEOD: Label 'eod_nav_%1.txt';
        DefaultPrintFileJournal: Label 'journal_nav_%1.txt';
        DefaultPrintFileInit: Label 'ini_nav_%1.txt';
        StrippedCode: Code[20];
    begin
        StrippedCode := DelChr(Code, '=', ' ');
        if "Print File Open" = '' then
            "Print File Open" := StrSubstNo(DefaultPrintFileOpen, StrippedCode);
        if "Print File Close" = '' then
            "Print File Close" := StrSubstNo(DefaultPrintFileClose, StrippedCode);
        if "Print File Transaction" = '' then
            "Print File Transaction" := StrSubstNo(DefaultPrintFileTransaction, StrippedCode);
        if "Print File CC Transaction" = '' then
            "Print File CC Transaction" := StrSubstNo(DefaultPrintFileCCTransaction, StrippedCode);
        if "Print File Difference" = '' then
            "Print File Difference" := StrSubstNo(DefaultPrintFileDifference, StrippedCode);
        if "Print File End of Day" = '' then
            "Print File End of Day" := StrSubstNo(DefaultPrintFileEOD, StrippedCode);
        if "Print File Journal" = '' then
            "Print File Journal" := StrSubstNo(DefaultPrintFileJournal, StrippedCode);
        if "Print File Initialisation" = '' then
            "Print File Initialisation" := StrSubstNo(DefaultPrintFileInit, StrippedCode);
    end;

    local procedure GetOfflineAllowed(): Boolean
    var
        PepperInstance: Record "NPR Pepper Instance";
        PepperConfiguration: Record "NPR Pepper Config.";
    begin

        CalcFields("Configuration Code");
        PepperConfiguration.Get("Configuration Code");
        exit(PepperConfiguration."Offline mode" <> 0);

    end;

    procedure StoreLicense(LicenseString: Text): Boolean
    var
        BText: BigText;
        Ostream: OutStream;
    begin

        if (LicenseString = '') then
            exit(false);
        CalcFields("License File");
        Clear("License File");
        Modify;
        CalcFields("License File");
        BText.AddText(LicenseString);
        "License File".CreateOutStream(Ostream);
        BText.Write(Ostream);
        Modify;
        exit(true);

    end;
}

