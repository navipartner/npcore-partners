table 6184494 "NPR Pepper Version"
{
    Access = Internal;

    Caption = 'Pepper Version';
    DataClassification = CustomerContent;
    DataCaptionFields = "Code", Description;
    DrillDownPageID = "NPR Pepper Version List";
    LookupPageID = "NPR Pepper Version List";

    fields
    {
        field(10; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(20; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(100; "XMLport Configuration"; Integer)
        {
            Caption = 'XMLport Configuration';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = CONST(XMLport));
            InitValue = 6184490;
        }
        field(105; "XMLport Configuration Name"; Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = Field("XMLport Configuration")));
            Caption = 'XMLport Configuration Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(200; "Codeunit Begin Workshift"; Integer)
        {
            ObsoleteReason = 'Not used.';
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';

            Caption = 'Codeunit Begin Workshift';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = CONST(Codeunit));
        }
        field(205; "Codeunit Begin Workshift Name"; Text[30])
        {
            ObsoleteReason = 'Not used.';
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';

            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = Field("Codeunit Begin Workshift")));
            Caption = 'Codeunit Begin Workshift Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(210; "Codeunit Transaction"; Integer)
        {
            ObsoleteReason = 'Not used.';
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';

            Caption = 'Codeunit Transaction';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = CONST(Codeunit));
        }
        field(215; "Codeunit Transaction Name"; Text[30])
        {
            ObsoleteReason = 'Not used.';
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';

            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = Field("Codeunit Transaction")));
            Caption = 'Codeunit Transaction Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(220; "Codeunit End Workshift"; Integer)
        {
            ObsoleteReason = 'Not used.';
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';

            Caption = 'Codeunit End Workshift';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = CONST(Codeunit));
        }
        field(225; "Codeunit End Workshift Name"; Text[30])
        {
            ObsoleteReason = 'Not used.';
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';

            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Codeunit),
                                                             "Object ID" = Field("Codeunit End Workshift")));
            Caption = 'Codeunit End Workshift Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(230; "Codeunit Auxiliary Functions"; Integer)
        {
            ObsoleteReason = 'Not used.';
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';

            Caption = 'Codeunit Auxiliary Functions';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = CONST(Codeunit));
        }
        field(235; "Codeunit Auxiliary Name"; Text[30])
        {
            ObsoleteReason = 'Not used.';
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';

            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = Field("Codeunit Auxiliary Functions")));
            Caption = 'Codeunit Auxiliary Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(240; "Codeunit Install"; Integer)
        {
            ObsoleteReason = 'Not used.';
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';

            Caption = 'Codeunit Install';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = CONST(Codeunit));
        }
        field(245; "Codeunit Install Name"; Text[30])
        {
            ObsoleteReason = 'Not used.';
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';

            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = Field("Codeunit Install")));
            Caption = 'Codeunit Install Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(300; "Install Directory"; Text[250])
        {
            Caption = 'Install Directory';
            DataClassification = CustomerContent;
        }
        field(310; "Install Zip File"; BLOB)
        {
            Caption = 'Install Zip File';
            DataClassification = CustomerContent;
            Compressed = false;
        }
        field(320; "Pepper DLL Version"; Text[50])
        {
            Caption = 'Pepper DLL Version';
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

    trigger OnDelete()
    var
        PepperConfiguration: Record "NPR Pepper Config.";
        TextConfigsFound: Label 'There is at least one Pepper Configuration linked to this version. Remove the link on the Pepper Configuration Card before deleteing this record.';
    begin
        PepperConfiguration.SetRange(Version, Code);
        if (not PepperConfiguration.IsEmpty) then
            Error(TextConfigsFound);
    end;

    procedure UploadZipFile(FileType: Option InstallFile)
    var
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        UploadResult: Text;
        TxtNotUploaded: Label 'File was not uploaded.';
        TxtSuccess: Label 'File %1 was uploaded.';
        TxtNotStored: Label 'File was not stored.';
        TxtCaption: Label 'Pepper installation .zip file';
        TxtZipfilefilter: Label '*.zip';
        TxtZipfileDescription: Label 'ZIP Files (*.zip)|*.zip';
        RecRef: RecordRef;
    begin

        UploadResult := FileManagement.BLOBImportWithFilter(TempBlob, TxtCaption, '', TxtZipfileDescription, TxtZipfilefilter);
        if (UploadResult = '') then
            Error(TxtNotUploaded);
        Message(StrSubstNo(TxtSuccess, UploadResult));
        case FileType of
            FileType::InstallFile:
                begin
                    CalcFields("Install Zip File");
                    Clear("Install Zip File");
                    Modify();
                    CalcFields("Install Zip File");

                    RecRef.GetTable(Rec);
                    TempBlob.ToRecordRef(RecRef, FieldNo("Install Zip File"));
                    RecRef.SetTable(Rec);

                    "Pepper DLL Version" := '';
                    Modify();
                    if (not "Install Zip File".HasValue()) then
                        Error(TxtNotStored);
                end;
        end;

    end;

    procedure ClearZipFile(FileType: Option InstallFile)
    var
        TxtNoFile: Label 'No file is present.';
        TxtConfirmClearFile: Label 'Are you sure you want to delete the file?';
        TxtFileCleared: Label 'File deleted.';
    begin

        case FileType of
            FileType::InstallFile:
                begin
                    CalcFields("Install Zip File");
                    if (not "Install Zip File".HasValue()) then
                        Error(TxtNoFile);
                    if (not Confirm(TxtConfirmClearFile)) then
                        exit;
                    Clear("Install Zip File");
                    "Pepper DLL Version" := '';
                    Modify();
                    Message(TxtFileCleared);
                end;
        end;

    end;

    procedure ExportZipFile(FileType: Option InstallFile)
    var
        TxtNoFile: Label 'No file is present.';
        StreamIn: InStream;
        ExportName: Text;
        TxtFileName: Label 'Pepper.zip';
        TxtTitle: Label 'ZIP File Export';
        TxtZIPFileFilter: Label 'ZIP Files (*.zip)|*.zip';
    begin

        case FileType of
            FileType::InstallFile:
                begin
                    CalcFields("Install Zip File");
                    if (not "Install Zip File".HasValue()) then
                        Error(TxtNoFile);
                    ExportName := TxtFileName;
                    "Install Zip File".CreateInStream(StreamIn);
                    DownloadFromStream(StreamIn, TxtTitle, '', TxtZIPFileFilter, ExportName);
                end;
        end;

    end;
}


