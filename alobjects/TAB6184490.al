table 6184490 "Pepper Configuration"
{
    // NPR5.22\BR\20160316  CASE 231481 Object Created
    // NPR5.22\BR\20160412  CASE 231481 Added fields "End of Day on Close", "Unload Library on Close", "End of Day Receipt Mandatory"
    // NPR5.22\BR\20160413  CASE 231481 Added fields Offline Mode
    // NPR5.22\BR\20160422  CASE 231481 Added fields Transaction Type Install Code
    // NPR5.25/BR/20160608  CASE 231481 Added fields Customer ID, License ID,
    // NPR5.29/BR/20161230  CASE 262269 Get License Key from File
    // NPR5.34/BR/20170320  CASE 268697 Added fields Min. Length Authorisation No. and Max. Length Authorisation No.
    // NPR5.31/BR/20170502  CASE 274457 Fixed tablerelations for Pepper Transaction Types

    Caption = 'Pepper Configuration';
    DataCaptionFields = "Code",Description;
    DrillDownPageID = "Pepper Configuration List";
    LookupPageID = "Pepper Configuration List";

    fields
    {
        field(10;"Code";Code[10])
        {
            Caption = 'Code';
        }
        field(20;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(30;Version;Code[10])
        {
            Caption = 'Version';
            TableRelation = "Pepper Version";

            trigger OnValidate()
            begin
                QueryFillDefaultPaths;
            end;
        }
        field(100;"Recovery Retry Attempts";Integer)
        {
            Caption = 'Recovery Retry Attempts';
            InitValue = 3;
            MaxValue = 99;
            MinValue = 1;
        }
        field(110;Mode;Option)
        {
            Caption = 'Mode';
            OptionCaption = 'Production,TEST Local,TEST Remote';
            OptionMembers = Production,"TEST Local","TEST Remote";

            trigger OnValidate()
            begin
                if Mode <> xRec.Mode  then begin
                  case Mode of
                    Mode :: Production :
                      begin
                        if Confirm(TxtProductionmode) then
                          exit;
                      end;
                    Mode :: "TEST Local" :
                      begin
                        if Confirm(TxtLocaltestmode) then
                          exit;
                      end;
                    Mode :: "TEST Remote" :
                      begin
                        if Confirm(TxtRemotetestmode) then
                          exit;
                      end;
                  end;
                end;

                Mode := xRec.Mode;
            end;
        }
        field(120;"Default POS Timeout (Seconds)";Integer)
        {
            Caption = 'Default POS Timeout (Seconds)';
        }
        field(130;"Show Detailed Error Messages";Boolean)
        {
            Caption = 'Show Detailed Error Messages';
        }
        field(200;"Logging Target";Option)
        {
            Caption = 'Logging Target';
            OptionCaption = 'File,Syslog';
            OptionMembers = file,syslog;
        }
        field(210;"Logging Level";Option)
        {
            Caption = 'Logging Level';
            InitValue = warning;
            OptionCaption = 'Nolog,Error,Warning,Info,Debug';
            OptionMembers = nolog,error,warning,info,debug;
        }
        field(220;"Logging Max. File Size (MB)";Integer)
        {
            Caption = 'Logging Max. File Size (MB)';
            InitValue = 5;
            MaxValue = 100;
            MinValue = 1;
        }
        field(230;"Logging Directory";Text[250])
        {
            Caption = 'Logging Directory';
        }
        field(240;"Logging Archive Directory";Text[250])
        {
            Caption = 'Logging Archive Directory';
        }
        field(250;"Logging Archive Max. Age Days";Integer)
        {
            Caption = 'Logging Archive Max. Age Days';
            InitValue = 30;
            MaxValue = 100;
            MinValue = 2;
        }
        field(300;"Card Type File Full Path";Text[250])
        {
            Caption = 'Card Type File Full Path';
            InitValue = '\cardtypes.pep';
        }
        field(310;"Ticket Directory";Text[250])
        {
            Caption = 'Ticket Directory';
        }
        field(320;"Journal Directory";Text[250])
        {
            Caption = 'Journal Directory';
        }
        field(330;"Matchbox Directory";Text[250])
        {
            Caption = 'Matchbox Directory';
        }
        field(340;"Messages Directory";Text[250])
        {
            Caption = 'Messages Directory';
        }
        field(350;"Persistance Directory";Text[250])
        {
            Caption = 'Persistance Directory';
        }
        field(360;"Working Directory";Text[250])
        {
            Caption = 'Working Directory';
        }
        field(370;"License File Full Path";Text[250])
        {
            Caption = 'License File Full Path';
            InitValue = '\pepper_license.xml';
        }
        field(400;"Header and Footer Handling";Option)
        {
            Caption = 'Header and Footer Handling';
            OptionCaption = 'No Headers and Footers,Manual Headers and Footers,Send Headers and Footers to Terminal,Add Headers and Footers at Printing';
            OptionMembers = "No Headers and Footers","Manual Headers and Footers","Send Headers and Footers to Terminal","Add Headers and Footers at Printing";
        }
        field(500;"Transaction Type Open Code";Code[10])
        {
            Caption = 'Transaction Type Open Code';
            TableRelation = "Pepper EFT Transaction Type".Code WHERE ("Integration Type"=FILTER('PEPPER'),
                                                                      "Processing Type"=CONST(Open));
        }
        field(510;"Transaction Type Payment Code";Code[10])
        {
            Caption = 'Transaction Type Payment Code';
            TableRelation = "Pepper EFT Transaction Type".Code WHERE ("Processing Type"=CONST(Payment),
                                                                      "Integration Type"=FILTER('PEPPER'));
        }
        field(520;"Transaction Type Close Code";Code[10])
        {
            Caption = 'Transaction Type Close Code';
            TableRelation = "Pepper EFT Transaction Type".Code WHERE ("Integration Type"=FILTER('PEPPER'),
                                                                      "Processing Type"=CONST(Close));
        }
        field(530;"Transaction Type Refund Code";Code[10])
        {
            Caption = 'Transaction Type Refund Code';
            TableRelation = "Pepper EFT Transaction Type".Code WHERE ("Processing Type"=CONST(Refund),
                                                                      "Integration Type"=FILTER('PEPPER'));
        }
        field(540;"Transaction Type Recover Code";Code[10])
        {
            Caption = 'Transaction Type Recover Code';
            TableRelation = "Pepper EFT Transaction Type".Code WHERE ("Processing Type"=CONST(Other),
                                                                      "Integration Type"=FILTER('PEPPER'));
        }
        field(550;"Transaction Type Auxilary Code";Code[10])
        {
            Caption = 'Transaction Type Auxilary Code';
            TableRelation = "Pepper EFT Transaction Type".Code WHERE ("Processing Type"=CONST(Auxiliary),
                                                                      "Integration Type"=FILTER('PEPPER'));
        }
        field(560;"Transaction Type Install Code";Code[10])
        {
            Caption = 'Transaction Type Install Code';
            TableRelation = "Pepper EFT Transaction Type".Code WHERE ("Integration Type"=FILTER('PEPPER'),
                                                                      "Processing Type"=CONST(Other));
        }
        field(600;"End of Day on Close";Boolean)
        {
            Caption = 'End of Day on Close';
            InitValue = true;
        }
        field(601;"Unload Library on Close";Boolean)
        {
            Caption = 'Unload Library on Close';
            InitValue = true;
        }
        field(610;"End of Day Receipt Mandatory";Boolean)
        {
            Caption = 'End of Day Receipt Mandatory';
            InitValue = false;
        }
        field(650;"Offline mode";Option)
        {
            Caption = 'Offline mode';
            OptionCaption = 'Disabled,Mandatory Authorisation No.,Optional Authorisation No.';
            OptionMembers = Disabled,"Mandatory Authorisation No.","Optional Authorisation No.";
        }
        field(660;"Min. Length Authorisation No.";Integer)
        {
            Caption = 'Min. Length Authorisation No.';
            Description = 'NPR5.34';
            InitValue = 6;
            MaxValue = 6;
            MinValue = 0;

            trigger OnValidate()
            begin
                //-NPR5.34 [268697]
                CheckMinMaxLengthAuthorisationNo;
                //+NPR5.34 [268697]
            end;
        }
        field(667;"Max. Length Authorisation No.";Integer)
        {
            Caption = 'Max. Length Authorisation No.';
            Description = 'NPR5.34';
            InitValue = 16;
            MaxValue = 16;
            MinValue = 0;

            trigger OnValidate()
            begin
                //-NPR5.34 [268697]
                CheckMinMaxLengthAuthorisationNo;
                //+NPR5.34 [268697]
            end;
        }
        field(700;"Customer ID";Text[8])
        {
            Caption = 'Customer ID';
        }
        field(710;"License ID";Text[8])
        {
            Caption = 'License ID';
        }
        field(900;"License File";BLOB)
        {
            Caption = 'License File';
            SubType = UserDefined;
        }
        field(910;"Additional Parameters";BLOB)
        {
            Caption = 'Additional Parameters';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        PepperInstance: Record "Pepper Instance";
        TextInstanceFound: Label 'There is at least one Pepper Instance linked to this version. Remove the link on the Pepper Instance before deleteing this record.';
    begin
        PepperInstance.SetRange(PepperInstance."Configuration Code",Code);
        if not PepperInstance.IsEmpty then
          Error(TextInstanceFound);
    end;

    var
        TxtLocaltestmode: Label 'WARNING: switching on Local test mode will cut communication with the terminal and simulate succesful transactions. Are you sure want to continue? ';
        TxtRemotetestmode: Label 'WARNING: switching on Remote test mode process transactions to the terminal as normal but log them as test. You must set the terminal to test manually! Are you sure want to continue? ';
        TxtProductionmode: Label 'WARNING: this will mark this configuration as production and process all transactons normally.';
        Txt001: Label '%1 cannot be greater than %2.';

    procedure UploadFile(FileType: Option License,AdditionalParameters)
    var
        FileManagement: Codeunit "File Management";
        TempBlob: Record TempBlob;
        UploadResult: Text[250];
        TxtNotUploaded: Label 'File was not uploaded.';
        TxtSuccess: Label 'File %1 was uploaded.';
        TxtNotStored: Label 'File was not stored.';
        TxtCaptionLicense: Label 'Pepper License file';
        TxtCaptionAdditionalParameters: Label 'Pepper Additional Parameters';
        TxtDescription: Label 'XML File';
        TxtXMLfilefilter: Label '*.xml';
        TxtXMLfileDescription: Label 'XML Files (*.xml)|*.xml';
        PepperConfigManagement: Codeunit "Pepper Config. Management";
        PepperLibrary: Codeunit "Pepper Library";
    begin
        //-NPR5.22
        //UploadResult := FileManagement.BLOBImport(TempBlob,'');
        case FileType of
          FileType :: License :
            UploadResult := FileManagement.BLOBImportWithFilter(TempBlob,TxtCaptionLicense,'',TxtXMLfileDescription,TxtXMLfilefilter);
          FileType :: AdditionalParameters :
            UploadResult := FileManagement.BLOBImportWithFilter(TempBlob,TxtCaptionAdditionalParameters,'',TxtXMLfileDescription,TxtXMLfilefilter);
        end;
        //+NPR5.22
        if UploadResult = '' then
          Error(TxtNotUploaded);
        Message(StrSubstNo(TxtSuccess,UploadResult));
        case FileType of
          FileType :: License :
            begin
              CalcFields("License File");
              Clear("License File");
              //-NPR5.22
              //"License File" := TempBlob.Blob;
              Modify;
              CalcFields("License File");
              "License File" := TempBlob.Blob;
              //-NPR5.29 [262269]
              "License ID" := PepperLibrary.GetKeyFromLicenseText(PepperConfigManagement.GetConfigurationText(Rec,0));
              //+NPR5.29 [262269]
              Modify;
              //+NPR5.22
              if not "License File".HasValue then
                Error(TxtNotStored);
            end;
            FileType :: AdditionalParameters :
            begin
              CalcFields("Additional Parameters");
              Clear("Additional Parameters");
              //-NPR5.22
              //"Additional Parameters" := TempBlob.Blob;
              Modify;
              CalcFields("Additional Parameters");
              "Additional Parameters" := TempBlob.Blob;
              Modify;
              //+NPR5.22
              if not "Additional Parameters".HasValue then
                Error(TxtNotStored);
            end;
        end;
    end;

    procedure ClearFile(FileType: Option License,AdditionalParameters)
    var
        FileManagement: Codeunit "File Management";
        TempBlob: Record TempBlob;
        UploadResult: Text[250];
        TxtNoLicense: Label 'No license file is configured.';
        TxtNoAdditionalParameters: Label 'No addtional parameters are configured.';
        TxtConfirmClearLicense: Label 'Are you sure you want to delete the license?';
        TxtConfirmClearAdditionalParameters: Label 'Are you sure you want to delete the additional parameters?';
        TxtLicenseCleared: Label 'License deleted.';
        TxtAdditionalParametersCleared: Label 'Additional Parameters deleted.';
    begin
        case FileType of
          FileType :: License :
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
            FileType :: AdditionalParameters :
            begin
              CalcFields("Additional Parameters");
              if not "Additional Parameters".HasValue then
                Error(TxtNoAdditionalParameters);
              if not Confirm(TxtConfirmClearAdditionalParameters) then
                exit;
              Clear("Additional Parameters");
              Modify;
              Message(TxtAdditionalParametersCleared);
            end;
        end;
    end;

    procedure ExportFile(FileType: Option License,Configuration,AdditionalParameters)
    var
        TxtNoLicense: Label 'No license file is configured.';
        TxtNoAdditionalParameters: Label 'No addtional parameters are configured.';
        PepperConfigManagement: Codeunit "Pepper Config. Management";
        PepperVersion: Record "Pepper Version";
        StreamIn: InStream;
        StreamOut: OutStream;
        ExportName: Text;
        TxtFileNameLicense: Label 'PepperLicense.xml';
        TxtFilenameAddPar: Label 'ConfigAdditionalParameters.xml';
        TxtFilenameConfig: Label 'PepperConfiguration.xml';
        TxtTitle: Label 'XML File Export';
        TxtXMLFileFilter: Label 'XML Files (*.xml)|*.xml';
        TempFile: File;
    begin
        //-NPR5.22
        case FileType of
          FileType :: License :
            begin
              CalcFields("License File");
              if not "License File".HasValue then
                Error(TxtNoLicense);
              ExportName := TxtFileNameLicense;
              "License File".CreateInStream(StreamIn);
              DownloadFromStream(StreamIn,TxtTitle,'',TxtXMLFileFilter,ExportName);
            end;
          FileType :: Configuration :
            begin
              TestField(Version);
              PepperVersion.Get(Version);
              PepperVersion.TestField(PepperVersion."XMLport Configuration");
              TempFile.TextMode(true);
              TempFile.WriteMode(false);
              TempFile.CreateTempFile;
              TempFile.CreateOutStream(StreamOut);
              XMLPORT.Export(PepperVersion."XMLport Configuration",StreamOut);
              TempFile.CreateInStream(StreamIn);
              ExportName := TxtFilenameConfig;
              DownloadFromStream(StreamIn,TxtTitle,'',TxtXMLFileFilter,ExportName);
            end;
          FileType :: AdditionalParameters :
            begin
              CalcFields("Additional Parameters");
              if not "Additional Parameters".HasValue then
                Error(TxtNoAdditionalParameters);
              ExportName := TxtFilenameAddPar;
              "Additional Parameters".CreateInStream(StreamIn);
              DownloadFromStream(StreamIn,TxtTitle,'',TxtXMLFileFilter,ExportName);
            end;
        end;
        //+NPR5.22
    end;

    procedure ShowFile(OptFileType: Option License,Configuration,AdditionalParameters)
    var
        PepperConfigManagement: Codeunit "Pepper Config. Management";
    begin
        Message(PepperConfigManagement.GetConfigurationText(Rec,OptFileType));
    end;

    local procedure QueryFillDefaultPaths()
    var
        PepperVersion: Record "Pepper Version";
        TxtUseInstallAsDefault: Label 'Would you like to use the Install directory of this Pepper Version (%1) as the default directory for this Configuration?';
    begin
        if PepperVersion.Get(Version) then begin
          if PepperVersion."Install Directory" <> '' then begin
            if Confirm (StrSubstNo(TxtUseInstallAsDefault,PepperVersion."Install Directory"),false) then begin
              "Logging Directory" := PepperVersion."Install Directory";
              "Logging Archive Directory" := PepperVersion."Install Directory";
              "Ticket Directory" := PepperVersion."Install Directory";
              "Journal Directory" := PepperVersion."Install Directory";
              "Matchbox Directory" := PepperVersion."Install Directory";
              "Messages Directory" := PepperVersion."Install Directory";
              "Persistance Directory" := PepperVersion."Install Directory";
              "Working Directory" := PepperVersion."Install Directory";
              "Card Type File Full Path" := PepperVersion."Install Directory" + FindFileName("Card Type File Full Path");
              "License File Full Path" := PepperVersion."Install Directory" + FindFileName("License File Full Path");
            end;
          end;
        end;
    end;

    local procedure FindFileName(FullPath: Text): Text
    begin
        exit('\' + CopyStr(FullPath,FindFileNameStartPos(FullPath)));
    end;

    local procedure FindFileNameStartPos(FullPathText: Text): Integer
    var
        i: Integer;
    begin
        for i := 1 to StrLen(FullPathText)-1 do begin
          if FullPathText[StrLen(FullPathText)-i] = '\' then
            exit(StrLen(FullPathText) - i + 1);
        end;
        exit(1);
    end;

    local procedure CheckMinMaxLengthAuthorisationNo()
    begin
        //-NPR5.34 [268697]
        if ("Min. Length Authorisation No." <> 0) and ("Max. Length Authorisation No." <> 0) then
          if "Min. Length Authorisation No." > "Max. Length Authorisation No." then
             Error(StrSubstNo(Txt001,FieldCaption("Min. Length Authorisation No."),FieldCaption("Max. Length Authorisation No.")));
        //+NPR5.34 [268697]
    end;
}

