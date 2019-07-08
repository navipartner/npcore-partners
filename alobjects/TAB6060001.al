table 6060001 "GIM - Import Document"
{
    // GIM1.00/MH/20150814  CASE 210725 Added xml to ParseFile()

    Caption = 'GIM - Import Document';
    LookupPageID = "GIM - Import Document List";

    fields
    {
        field(1;"No.";Code[20])
        {
            Caption = 'No.';
        }
        field(10;"Document Type";Code[10])
        {
            Caption = 'Document Type';
            TableRelation = "GIM - Document Type".Code;
        }
        field(11;"Sender ID";Code[20])
        {
            Caption = 'Sender ID';
            TableRelation = "GIM - Document Type"."Sender ID";
        }
        field(20;Process;Option)
        {
            Caption = 'Process';
            OptionCaption = ' ,Error,Finished,Paused,Cancelled';
            OptionMembers = " ",Error,Finished,Paused,Cancelled;
        }
        field(30;"User ID";Code[20])
        {
            Caption = 'User ID';
        }
        field(40;"Created At";DateTime)
        {
            Caption = 'Created At';
        }
        field(50;"File Container";BLOB)
        {
            Caption = 'File Container';
        }
        field(55;"File Path";Text[250])
        {
            Caption = 'File Path';
        }
        field(60;"File Name";Text[250])
        {
            Caption = 'File Name';
        }
        field(70;"File Extension";Text[30])
        {
            Caption = 'File Extension';
        }
        field(80;"Data Source";Option)
        {
            Caption = 'Data Source';
            OptionCaption = 'File upload,FTP,Web service,Mail';
            OptionMembers = "File upload",FTP,"Web service",Mail;
        }
        field(90;"Paused at Process Code";Code[20])
        {
            Caption = 'Paused at Process Code';
            TableRelation = "GIM - Process Flow";
        }
        field(91;"Process Name";Text[50])
        {
            CalcFormula = Lookup("GIM - Process Flow".Description WHERE (Code=FIELD("Paused at Process Code")));
            Caption = 'Process Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(100;"Data Format Code";Code[20])
        {
            Caption = 'Data Format Code';
            TableRelation = "GIM - Data Format".Code;
        }
    }

    keys
    {
        key(Key1;"No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        GIMSetup.Get;

        if "No." = '' then begin
          TestNoSeries();
          NoSeriesMgt.InitSeries(GIMSetup."Import Document Nos.",GIMSetup."Import Document Nos.",WorkDate,"No.",NoSeriesCode);
        end;

        "User ID" := UserId;
        "Created At" := CurrentDateTime;
    end;

    var
        GIMSetup: Record "GIM - Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        NoSeriesCode: Code[10];
        ImportDoc: Record "GIM - Import Document";
        Text001: Label 'Import Document %1 allready exists.';
        FileMgt: Codeunit "File Management";
        TempBLOB: Record TempBlob;
        GIMDocLog: Record "GIM - Document Log";
        StartingAt: DateTime;
        Text002: Label 'Stage successfully processed.';
        Text003: Label 'Fields not properly delimited by set field delimiter.';
        GIMDocType: Record "GIM - Document Type";
        GIMProcess: Record "GIM - Process Flow";
        Text004: Label 'Import process reset.';
        Text005: Label 'Import process has allready finished.';
        GIMMappingTable: Record "GIM - Mapping Table";
        GIMImpBuffer: Record "GIM - Import Buffer";
        Text006: Label 'Mapping is allready fully/partially defined. Do you want to delete it and start over?';
        Text007: Label 'You need to process at least data validation in order to have some buffer data.';
        Text008: Label 'You''re on first stage of import process and can''t go to previous step.';
        GIMParser: Codeunit "GIM - Parser";
        GIMMapTableField: Record "GIM - Mapping Table Field";
        Text009: Label 'This will remove all buffer data. Do you want to continue?';
        Text010: Label 'Not available in this process stage.';
        Text011: Label 'No Preview Type set for Document Type, Sender combination.';

    procedure AssistEdit(OldImportDoc: Record "GIM - Import Document"): Boolean
    var
        ImportDoc2: Record "GIM - Import Document";
    begin
        with ImportDoc do begin
          Copy(Rec);
          GIMSetup.Get;
          TestNoSeries();
          if NoSeriesMgt.SelectSeries(GIMSetup."Import Document Nos.",GIMSetup."Import Document Nos.",NoSeriesCode) then begin
            NoSeriesMgt.SetSeries("No.");
            if ImportDoc2.Get("No.") then
              Error(Text001,"No.");
            Rec := ImportDoc;
            exit(true);
          end;
        end;
    end;

    procedure TestNoSeries()
    begin
        GIMSetup.TestField("Import Document Nos.");
    end;

    procedure FetchFile(FilePath: Text[1024])
    var
        WorkingText: Text[250];
        Continue: Boolean;
    begin
        StartingAt := CurrentDateTime;
        case "Data Source" of
          "Data Source"::"File upload":
            WorkingText := FileMgt.BLOBImport(TempBLOB,'');
          "Data Source"::FTP:
            WorkingText := FilePath;
        end;
        if WorkingText <> '' then begin
          "File Container".Import(WorkingText);
          while StrPos(WorkingText,'\') > 0 do begin
            WorkingText := CopyStr(WorkingText,StrPos(WorkingText,'\') + 1)
          end;
          "File Name" := WorkingText;
          WorkingText := "File Name";
          while StrPos(WorkingText,'.') > 0 do begin
            WorkingText := CopyStr(WorkingText,StrPos(WorkingText,'.') + 1)
          end;
          "File Extension" := WorkingText;
          Modify;
        end;
    end;

    procedure ExportFileAndView(View: Boolean) FileName: Text[250]
    begin
        CalcFields("File Container");
        if "File Container".HasValue then begin
          FileName := FileMgt.DownloadTempFile("File Container".Export("File Name"));

          if View then
            HyperLink(FileName)
          else
            exit(FileName);
        end;
    end;

    procedure DefineMapping()
    var
        MappingTable: Record "GIM - Mapping Table";
    begin
        StartingAt := CurrentDateTime;
        MappingTable.SetRange("Document No.","No.");
        if MappingTable.Count <> 0 then
          if not Confirm(Text006) then
            exit
          else
            MappingTable.DeleteAll(true);

        GIMParser.ParseFile(Rec,true,0,0,0);

        Commit;
        PAGE.RunModal(0,MappingTable);
    end;

    procedure DefineMapping2()
    var
        MappingTableLine: Record "GIM - Mapping Table Line";
        DocTypeVersion: Record "GIM - Document Type Version";
    begin
        GIMMappingTable.SetRange("Document No.","No.");
        if GIMMappingTable.Count = 0 then
          GIMParser.ParseFile(Rec,true,0,0,0);

        MappingTableLine.SetRange("Document No.","No.");
        MappingTableLine.SetRange("Doc. Type Code","Document Type");
        MappingTableLine.SetRange("Sender ID","Sender ID");
        PAGE.Run(6060027,MappingTableLine);
    end;

    procedure StartProcess()
    begin
        "Paused at Process Code" := '';
        RunCodeunit(0);
    end;

    procedure ContinueProcess()
    begin
        GIMProcess.Get("Paused at Process Code");
        case Process of
          Process::Error: RunCodeunit(GIMProcess.Stage);
          Process::Paused: RunCodeunit(GIMProcess.Stage + 1);
          Process::Finished: Error(Text005);
        end;
    end;

    procedure ResetProcess()
    begin
        if Process = Process::Finished then
          Error(Text005);
        StartingAt := CurrentDateTime;
        Process := Process::" ";
        "Paused at Process Code" := '';
        GIMDocLog.InsertLine("No.",GIMDocLog.Type::Message,StartingAt,
                             CurrentDateTime,Text004,GIMDocLog.Status::Success,GIMProcess.Code);
        GIMMappingTable.SetRange("Document No.","No.");
        GIMMappingTable.DeleteAll(true);
        Modify;
    end;

    procedure RunCodeunit(StageID: Integer)
    var
        CodeunitID: Integer;
        LastStage: Integer;
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        GIMDocType.Get("Document Type","Sender ID");
        RecRef.GetTable(GIMDocType);
        GIMProcess.Reset;
        GIMProcess.SetCurrentKey(Stage);
        if GIMProcess.FindLast then
          LastStage := GIMProcess.Stage;
        if StageID <> 0 then
          GIMProcess.SetFilter(Stage,'%1..',StageID);
        if GIMProcess.FindSet then
          repeat
            FldRef := RecRef.Field(GIMProcess."Doc. Type Field ID");
            CodeunitID := FldRef.Value;
            if CodeunitID <> 0 then begin
              StartingAt := CurrentDateTime;
              if CODEUNIT.Run(CodeunitID,Rec) then
                if LastStage = GIMProcess.Stage then begin
                  GIMDocLog.InsertLine("No.",GIMDocLog.Type::Message,StartingAt,
                                       CurrentDateTime,Text002,GIMDocLog.Status::Finished,GIMProcess.Code);
                  "Paused at Process Code" := '';
                  Process := Process::Finished;
                end else if GIMProcess.Pause = GIMProcess.Pause::Allways then begin
                  GIMDocLog.InsertLine("No.",GIMDocLog.Type::Message,StartingAt,
                                       CurrentDateTime,Text002,GIMDocLog.Status::Paused,GIMProcess.Code);
                  "Paused at Process Code" := GIMProcess.Code;
                  Process := Process::Paused;
                end else begin
                  GIMDocLog.InsertLine("No.",GIMDocLog.Type::Message,StartingAt,
                                       CurrentDateTime,Text002,GIMDocLog.Status::Success,GIMProcess.Code);
                  "Paused at Process Code" := '';
                  Process := Process::" ";
                end
              else begin
                GIMDocLog.InsertLine("No.",GIMDocLog.Type::Error,StartingAt,
                                     CurrentDateTime,GetLastErrorText,GIMDocLog.Status::Error,GIMProcess.Code);
                ClearLastError;
                "Paused at Process Code" := GIMProcess.Code;
                Process := Process::Error;
              end;
              Modify;
              Commit;
            end;
            if Process in [Process::Paused,Process::Error] then
              exit;
          until GIMProcess.Next = 0;
    end;

    procedure OpenBufferMatrix()
    var
        ImpBuffer: Record "GIM - Import Buffer";
        ImpBufferByColumns: Page "GIM - Import Buffer by Columns";
    begin
        ImpBuffer.SetCurrentKey("Row No.");
        ImpBuffer.SetRange("Document No.","No.");
        if ImpBuffer.FindLast then begin
          ImpBufferByColumns.SetDocNo("No.");
          ImpBufferByColumns.RunModal;
        end else
          Error(Text007);
    end;

    procedure RepeatProcess()
    begin
        Process := Process::Error;
        ContinueProcess();
    end;

    procedure GoToPreviousProcess()
    var
        CurrentStage: Integer;
    begin
        GIMProcess.Get("Paused at Process Code");
        CurrentStage := GIMProcess.Stage;
        GIMProcess.SetCurrentKey(Stage);
        GIMProcess.SetFilter(Stage,'<%1',CurrentStage);
        if GIMProcess.FindLast then begin
          Process := Process::Error;
          "Paused at Process Code" := GIMProcess.Code;
          Modify;
        end else
          Error(Text008);
    end;

    procedure ResetCurrentProcessStage()
    begin
        GIMProcess.Get("Paused at Process Code");
        if GIMProcess.Stage > 1 then begin
          if not Confirm(Text009) then
            exit;
          GIMMapTableField.DeleteBufferData("No.");
          Process := Process::Error;
          GIMProcess.SetRange(Stage,2);
          if GIMProcess.FindFirst then
            Validate("Paused at Process Code",GIMProcess.Code);
          Modify;
        end else
          Error(Text010);
    end;

    procedure PreviewData()
    var
        TestRunner: Codeunit "GIM - Data Create Test Runner";
    begin
        GIMDocType.Get("Document Type","Sender ID");
        case GIMDocType."Preview Type" of
          GIMDocType."Preview Type"::" ": Error(Text011);
          GIMDocType."Preview Type"::Item:
            TestRunner.SetEntity2(true,DATABASE::Item);
          GIMDocType."Preview Type"::"Sales Order":
            TestRunner.SetEntity2(true,DATABASE::"Sales Header");
          GIMDocType."Preview Type"::"Purchase Order":
            TestRunner.SetEntity2(true,DATABASE::"Purchase Header");
        end;
        TestRunner.Run(Rec);
    end;

    procedure PreviewFileData()
    var
        ListTemplate: Page "GIM - List Template";
    begin
        GIMDocType.Get("Document Type","Sender ID");
        case GIMDocType."Preview Type" of
          GIMDocType."Preview Type"::" ": Error(Text011);
          GIMDocType."Preview Type"::Item:
            ListTemplate.SetEntity(Rec,DATABASE::Item);
          GIMDocType."Preview Type"::"Sales Order":
            ListTemplate.SetEntity(Rec,DATABASE::"Sales Header");
          GIMDocType."Preview Type"::"Purchase Order":
            ListTemplate.SetEntity(Rec,DATABASE::"Purchase Header");
        end;
        ListTemplate.RunModal;
    end;
}

