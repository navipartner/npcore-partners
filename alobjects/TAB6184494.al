table 6184494 "Pepper Version"
{
    // NPR5.22\BR\20160316  CASE 231481 Object Created
    // NPR5.22\BR\20160415  CASE 231481 Added Install Zip File BLOB field, dll version
    // NPR5.22\BR\20160422  CASE 231481 Added the Installation Codeunit fields
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj -fields 100..245

    Caption = 'Pepper Version';
    DataCaptionFields = "Code", Description;
    DrillDownPageID = "Pepper Version List";
    LookupPageID = "Pepper Version List";

    fields
    {
        field(10; "Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(20; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(100; "XMLport Configuration"; Integer)
        {
            Caption = 'XMLport Configuration';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(XMLport));
        }
        field(105; "XMLport Configuration Name"; Text[30])
        {
            CalcFormula = Lookup (AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = FIELD("XMLport Configuration")));
            Caption = 'XMLport Configuration Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(200; "Codeunit Begin Workshift"; Integer)
        {
            Caption = 'Codeunit Begin Workshift';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Codeunit));
        }
        field(205; "Codeunit Begin Workshift Name"; Text[30])
        {
            CalcFormula = Lookup (AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = FIELD("Codeunit Begin Workshift")));
            Caption = 'Codeunit Begin Workshift Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(210; "Codeunit Transaction"; Integer)
        {
            Caption = 'Codeunit Transaction';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Codeunit));
        }
        field(215; "Codeunit Transaction Name"; Text[30])
        {
            CalcFormula = Lookup (AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = FIELD("Codeunit Transaction")));
            Caption = 'Codeunit Transaction Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(220; "Codeunit End Workshift"; Integer)
        {
            Caption = 'Codeunit End Workshift';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Codeunit));
        }
        field(225; "Codeunit End Workshift Name"; Text[30])
        {
            CalcFormula = Lookup (AllObj."Object Name" WHERE("Object Type" = CONST(Codeunit),
                                                             "Object ID" = FIELD("Codeunit End Workshift")));
            Caption = 'Codeunit End Workshift Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(230; "Codeunit Auxiliary Functions"; Integer)
        {
            Caption = 'Codeunit Auxiliary Functions';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Codeunit));
        }
        field(235; "Codeunit Auxiliary Name"; Text[30])
        {
            CalcFormula = Lookup (AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = FIELD("Codeunit Auxiliary Functions")));
            Caption = 'Codeunit Auxiliary Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(240; "Codeunit Install"; Integer)
        {
            Caption = 'Codeunit Install';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Codeunit));
        }
        field(245; "Codeunit Install Name"; Text[30])
        {
            CalcFormula = Lookup (AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = FIELD("Codeunit Install")));
            Caption = 'Codeunit Install Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(300; "Install Directory"; Text[250])
        {
            Caption = 'Install Directory';
        }
        field(310; "Install Zip File"; BLOB)
        {
            Caption = 'Install Zip File';
            Compressed = false;
        }
        field(320; "Pepper DLL Version"; Text[50])
        {
            Caption = 'Pepper DLL Version';
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

    trigger OnDelete()
    var
        PepperConfiguration: Record "Pepper Configuration";
        TextConfigsFound: Label 'There is at least one Pepper Configuration linked to this version. Remove the link on the Pepper Configuration Card before deleteing this record.';
    begin
        PepperConfiguration.SetRange(Version, Code);
        if not PepperConfiguration.IsEmpty then
            Error(TextConfigsFound);
    end;

    procedure UploadZipFile(FileType: Option InstallFile)
    var
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        UploadResult: Text[250];
        TxtNotUploaded: Label 'File was not uploaded.';
        TxtSuccess: Label 'File %1 was uploaded.';
        TxtNotStored: Label 'File was not stored.';
        TxtCaption: Label 'Pepper installation .zip file';
        TxtDescription: Label 'Zip File';
        TxtZipfilefilter: Label '*.zip';
        TxtZipfileDescription: Label 'ZIP Files (*.zip)|*.zip';
        RecRef: RecordRef;
    begin
        //-NPR5.22
        UploadResult := FileManagement.BLOBImportWithFilter(TempBlob, TxtCaption, '', TxtZipfileDescription, TxtZipfilefilter);
        if UploadResult = '' then
            Error(TxtNotUploaded);
        Message(StrSubstNo(TxtSuccess, UploadResult));
        case FileType of
            FileType::InstallFile:
                begin
                    CalcFields("Install Zip File");
                    Clear("Install Zip File");
                    Modify;
                    CalcFields("Install Zip File");

                    RecRef.GetTable(Rec);
                    TempBlob.ToRecordRef(RecRef, FieldNo("Install Zip File"));
                    RecRef.SetTable(Rec);

                    "Pepper DLL Version" := '';
                    Modify;
                    if not "Install Zip File".HasValue then
                        Error(TxtNotStored);
                end;
        end;
        //+NPR5.22
    end;

    procedure ClearZipFile(FileType: Option InstallFile)
    var
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        UploadResult: Text[250];
        TxtNoFile: Label 'No file is present.';
        TxtConfirmClearFile: Label 'Are you sure you want to delete the file?';
        TxtFileCleared: Label 'File deleted.';
    begin
        //-NPR5.22
        case FileType of
            FileType::InstallFile:
                begin
                    CalcFields("Install Zip File");
                    if not "Install Zip File".HasValue then
                        Error(TxtNoFile);
                    if not Confirm(TxtConfirmClearFile) then
                        exit;
                    Clear("Install Zip File");
                    "Pepper DLL Version" := '';
                    Modify;
                    Message(TxtFileCleared);
                end;
        end;
        //+NPR5.22
    end;

    procedure ExportZipFile(FileType: Option InstallFile)
    var
        TxtNoFile: Label 'No file is present.';
        PepperConfigManagement: Codeunit "Pepper Config. Management";
        PepperVersion: Record "Pepper Version";
        StreamIn: InStream;
        StreamOut: OutStream;
        ExportName: Text;
        TxtFileName: Label 'Pepper.zip';
        TxtTitle: Label 'ZIP File Export';
        TxtZIPFileFilter: Label 'ZIP Files (*.zip)|*.zip';
        TempFile: File;
    begin
        //-NPR5.22
        case FileType of
            FileType::InstallFile:
                begin
                    CalcFields("Install Zip File");
                    if not "Install Zip File".HasValue then
                        Error(TxtNoFile);
                    ExportName := TxtFileName;
                    "Install Zip File".CreateInStream(StreamIn);
                    DownloadFromStream(StreamIn, TxtTitle, '', TxtZIPFileFilter, ExportName);
                end;
        end;
        //+NPR5.22
    end;
}

