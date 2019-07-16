codeunit 6151091 "Nc RapidConnect Export Mgt."
{
    // NC2.12/MHA /20180418  CASE 308107 Object created - RapidStart with NaviConnect
    // NC2.12/MHA /20180502  CASE 313362 File is always server side in CommitFileToOutput() as ExportToExcel() performs Upload
    // NC2.13/MHA /20180614  CASE 318871 Added simple cleanup to OutputName
    // NC2.14/MHA /20180629  CASE 320762 Record is now restored from Record ID in GetRecRef()
    // NC2.14/MHA /20180716  CASE 322308 Added Partial Trigger functionality
    // NC2.15/MHA /20180801  CASE 306532 Added Max length to Outputname in ProcessTask()
    // NC2.15/MHA /20180829  CASE 326704 Replaced FIND with GET in CommitResponse() to ignore filters
    // NC2.17/MHA /20181116  CASE 335927 Removed green code and added Export File Type
    // NC2.22/MHA /20190621  CASE 358239 GetFieldValue() should use Xml format
    // NC14.00.2.22/MHA /20190715  CASE 361941 Excel support

    TableNo = "Nc Task";

    trigger OnRun()
    begin
        ProcessTask(Rec);
    end;

    var
        Text000: Label 'Export package %1 with %2 tables?';
        HideDialog: Boolean;

    local procedure "--- Task Processing"()
    begin
    end;

    local procedure ProcessTask(var NcTask: Record "Nc Task")
    var
        NcTaskOutput: Record "Nc Task Output";
        NcRapidConnectSetup: Record "Nc RapidConnect Setup";
        TempExportTrigger: Record "Nc RapidConnect Trigger Table" temporary;
        NcTaskMgt: Codeunit "Nc Task Mgt.";
        PrevRecRef: RecordRef;
        RecRef: RecordRef;
        Output: Text;
        OutputName: Text;
        ServerFilename: Text;
        Response: Text;
        Success: Boolean;
        XmlDoc: DotNet npNetXmlDocument;
    begin
        //-NC2.14 [320762]
        if not NcTaskMgt.GetRecRef(NcTask,RecRef) then
          exit;
        if not NcTaskMgt.RestoreRecord(NcTask."Entry No.",PrevRecRef) then
          PrevRecRef := RecRef.Duplicate;
        if not FindExportTriggers(NcTask,PrevRecRef,RecRef,TempExportTrigger) then
          exit;
        //+NC2.14 [320762]

        Success := true;
        //-NC2.15 [306532]
        NcTask.CalcFields("Table Name");
        OutputName := 'RapCo-' + CopyStr(DelChr(ConvertStr(Format(CurrentDateTime,0,9),':','.'),'=','.,- TZ'),1,16) + '-';
        OutputName += Format(NcTask."Table No.") + '-' + NcTask."Table Name" + '-' + NcTask."Record Value";
        OutputName := DelChr(OutputName,'=',':?|<>"^`�*/\"#�%&/''');
        //-NC2.17 [335927]
        //OutputName := COPYSTR(OutputName,1,100 - STRLEN('.xlsx'));
        //OutputName += '.xlsx';
        //+NC2.17 [335927]
        //+NC2.15 [306532]
        TempExportTrigger.FindSet;
        repeat
          NcRapidConnectSetup.Get(TempExportTrigger."Setup Code");
          //-NC2.17 [335927]
          //ServerFilename := TEMPORARYPATH + OutputName;
          //
          //ExportToExcel(NcRapidConnectSetup,NcTask,ServerFilename);
          //CommitFileToOutput(NcTask,ServerFilename,OutputName,NcTaskOutput);
          case NcRapidConnectSetup."Export File Type" of
            NcRapidConnectSetup."Export File Type"::".xml":
              begin
                OutputName := CopyStr(OutputName,1,100 - StrLen('.xml'));
                OutputName += '.xml';

                ExportToXml(NcRapidConnectSetup,NcTask,XmlDoc);
                CommitXmlToOutput(NcTask,XmlDoc,OutputName,NcTaskOutput);
              end;
          end;
          //+NC2.17 [335927]

          Success := Success and RunEndpoints(NcRapidConnectSetup,NcTask,NcTaskOutput,Response);
          CommitResponse(Response,NcTask,NcTaskOutput);
        until TempExportTrigger.Next = 0;

        if not Success then
          Error(GetLastErrorText);
    end;

    local procedure "--- Export to Xml"()
    begin
    end;

    local procedure ExportToXml(NcRapidConnectSetup: Record "Nc RapidConnect Setup";NcTask: Record "Nc Task";var XmlDoc: DotNet npNetXmlDocument)
    var
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageField: Record "Config. Package Field";
        "Field": Record "Field";
        NcRapidConnectSetupMgt: Codeunit "Nc RapidConnect Setup Mgt.";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        NcTaskMgt: Codeunit "Nc Task Mgt.";
        XmlCDATA: DotNet npNetXmlCDataSection;
        XmlDocElement: DotNet npNetXmlElement;
        XmlElement: DotNet npNetXmlElement;
        XmlElement2: DotNet npNetXmlElement;
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        //-NC2.17 [335927]
        NcRapidConnectSetupMgt.SetConfigPackageTableFilter(NcRapidConnectSetup,ConfigPackageTable);
        ConfigPackageTable.SetRange("Table ID",NcTask."Table No.");
        if not ConfigPackageTable.FindSet then
          exit;

        if not NcTaskMgt.GetRecRef(NcTask,RecRef) then
          exit;

        NpXmlDomMgt.InitDoc(XmlDoc,XmlDocElement,'rapid_connect');
        repeat
          NpXmlDomMgt.AddElement(XmlDocElement,'record',XmlElement);
          NpXmlDomMgt.AddAttribute(XmlElement,'table_id',Format(ConfigPackageTable."Table ID"));
          NpXmlDomMgt.AddAttribute(XmlElement,'position',Format(RecRef.GetPosition(false)));
          NpXmlDomMgt.AddAttribute(XmlElement,'record_id',Format(RecRef.RecordId));

          ConfigPackageField.SetRange("Package Code",ConfigPackageTable."Package Code");
          ConfigPackageField.SetRange("Table ID",ConfigPackageTable."Table ID");
          ConfigPackageField.SetRange("Include Field",true);
          if ConfigPackageField.FindSet then
            repeat
              if ConfigPackageField2FieldRef(ConfigPackageField,RecRef,FieldRef) then begin
                NpXmlDomMgt.AddElement(XmlElement,'field',XmlElement2);
                NpXmlDomMgt.AddAttribute(XmlElement2,'field_no',Format(FieldRef.Number));

                XmlCDATA := XmlDoc.CreateCDataSection('');
                XmlElement2.AppendChild(XmlCDATA);
                XmlCDATA.AppendData(GetFieldValue(FieldRef));
              end;
            until ConfigPackageField.Next = 0;
        until ConfigPackageTable.Next = 0;
        //+NC2.17 [335927]
    end;

    local procedure ConfigPackageField2FieldRef(ConfigPackageField: Record "Config. Package Field";RecRef: RecordRef;var FieldRef: FieldRef): Boolean
    var
        "Field": Record "Field";
    begin
        //+NC2.17 [335927]
        if not Field.Get(ConfigPackageField."Table ID",ConfigPackageField."Field ID") then
          exit(false);

        FieldRef := RecRef.Field(Field."No.");
        if Format(FieldRef.Class) = 'flowfield' then
          exit(false);

        exit(true);
        //+NC2.17 [335927]
    end;

    local procedure GetFieldValue(var FieldRef: FieldRef) FieldValue: Text
    begin
        //-NC2.17 [335927]
        //-NC2.22 [358239]
        FieldValue := Format(FieldRef.Value,0,9);
        //+NC2.22 [358239]
        exit(FieldValue);
        //+NC2.17 [335927]
    end;

    local procedure CommitXmlToOutput(NcTask: Record "Nc Task";XmlDoc: DotNet npNetXmlDocument;OutputName: Text;var NcTaskOutput: Record "Nc Task Output")
    var
        OutStr: OutStream;
    begin
        //-NC2.17 [335927]
        NcTaskOutput.Init;
        NcTaskOutput."Entry No." := 0;
        NcTaskOutput."Task Entry No." := NcTask."Entry No.";
        NcTaskOutput.Data.CreateOutStream(OutStr);
        XmlDoc.Save(OutStr);
        NcTaskOutput.Name := OutputName;
        NcTaskOutput.Insert(true);
        Commit;
        //+NC2.17 [335927]
    end;

    local procedure RunEndpoints(NcRapidConnectSetup: Record "Nc RapidConnect Setup";var NcTask: Record "Nc Task";var NcTaskOutput: Record "Nc Task Output";var Response: Text) Success: Boolean
    var
        NcRapidConnectEndpoint: Record "Nc RapidConnect Endpoint";
        EndpointResponse: Text;
    begin
        Response := '';
        NcRapidConnectEndpoint.SetRange("Setup Code",NcRapidConnectSetup.Code);
        if NcRapidConnectEndpoint.IsEmpty then
          exit;

        Success := true;
        NcRapidConnectEndpoint.FindSet;
        repeat
          Success := Success and RunEndpoint(NcTaskOutput,NcRapidConnectEndpoint,EndpointResponse);

          if Response <> '' then
            Response += NewLine();
          Response += EndpointResponse;
        until NcRapidConnectEndpoint.Next = 0;

        exit(Success);
    end;

    local procedure RunEndpoint(NcTaskOutput: Record "Nc Task Output";NcRapidConnectEndpoint: Record "Nc RapidConnect Endpoint";var Response: Text) Success: Boolean
    var
        NcEndpoint: Record "Nc Endpoint";
        NcEndpointMgt: Codeunit "Nc Endpoint Mgt.";
    begin
        NcEndpoint.Get(NcRapidConnectEndpoint."Endpoint Code");
        Success := NcEndpointMgt.RunEndpoint(NcTaskOutput,NcEndpoint,Response);
        exit(Success);
    end;

    local procedure CommitResponse(Response: Text;var NcTask: Record "Nc Task";var NcTaskOutput: Record "Nc Task Output")
    var
        TempBlob: Record TempBlob temporary;
        InStream: InStream;
        OutStream: OutStream;
    begin
        TempBlob.Blob.CreateOutStream(OutStream);
        OutStream.WriteText(Response);

        //-NC2.15 [326704]
        NcTask.Get(NcTask."Entry No.");
        //+NC2.15 [326704]
        if NcTask.Response.HasValue then begin
          NcTask.CalcFields(Response);
          NcTask.Response.CreateInStream(InStream);
          CopyStream(OutStream,InStream);
        end;

        NcTask.Response := TempBlob.Blob;
        NcTask.Modify(true);

        Clear(TempBlob.Blob);
        TempBlob.Blob.CreateOutStream(OutStream);
        OutStream.WriteText(Response);

        NcTaskOutput.Find;
        NcTaskOutput.Response := TempBlob.Blob;
        NcTaskOutput.Modify(true);
        Commit;
    end;

    local procedure "--- Find"()
    begin
    end;

    local procedure FindExportTriggers(NcTask: Record "Nc Task";var PrevRecRef: RecordRef;var RecRef: RecordRef;var TempExportTrigger: Record "Nc RapidConnect Trigger Table" temporary): Boolean
    var
        NcRapidConnectSetup: Record "Nc RapidConnect Setup";
        ExportTrigger: Record "Nc RapidConnect Trigger Table";
    begin
        case NcTask.Type of
          //-NC2.14 [322308]
          NcTask.Type::Insert,NcTask.Type::Rename:
            ExportTrigger.SetRange("Insert Trigger",ExportTrigger."Insert Trigger"::Full);
          NcTask.Type::Modify:
            ExportTrigger.SetFilter("Modify Trigger",'%1|%2',ExportTrigger."Modify Trigger"::Full,ExportTrigger."Modify Trigger"::Partial);
          //+NC2.14 [322308]
          NcTask.Type::Delete:
            exit(false);
        end;

        ExportTrigger.SetRange("Table ID",NcTask."Table No.");
        ExportTrigger.SetFilter("Package Code",'<>%1','');
        ExportTrigger.SetRange("Export Enabled",true);
        ExportTrigger.SetFilter("Task Processor Code",'<>%1','');
        if ExportTrigger.IsEmpty then
          exit(false);

        ExportTrigger.FindSet;
        repeat
          //-NC2.14 [322308]
          if RecRefWithinPackage(NcTask,PrevRecRef,RecRef,ExportTrigger) then begin
          //+NC2.14 [322308]
            NcRapidConnectSetup.Get(ExportTrigger."Setup Code");
            TempExportTrigger.Init;
            TempExportTrigger := ExportTrigger;
            TempExportTrigger.Insert;
          end;
        until ExportTrigger.Next = 0;

        exit(TempExportTrigger.FindSet);
    end;

    [EventSubscriber(ObjectType::Codeunit, 8614, 'OnAfterApplyPackageFilter', '', true, true)]
    local procedure OnAfterApplyPackageFilter(ConfigPackageTable: Record "Config. Package Table";var RecRef: RecordRef;var Handled: Boolean;NcTask: Record "Nc Task")
    begin
        if NcTask."Table No." = 0 then
          exit;

        if RecRef.Number <> NcTask."Table No." then
          exit;

        RecRef.SetPosition(NcTask."Record Position");
        RecRef.FilterGroup(40);
        RecRef.SetRecFilter;
        RecRef.FilterGroup(0);
    end;

    local procedure "--- UI"()
    begin
    end;

    local procedure DialogEnabled(): Boolean
    begin
        if not GuiAllowed then
          exit(false);

        exit(not HideDialog);
    end;

    procedure SetHideDialog(NewHideDialog: Boolean)
    begin
        HideDialog := true;
    end;

    local procedure "--- Unique Task"()
    begin
    end;

    local procedure IsPartialModifyTrigger(var PrevRecRef: RecordRef;var RecRef: RecordRef;var TempExportTrigger: Record "Nc RapidConnect Trigger Table" temporary): Boolean
    var
        "Field": Record "Field";
        TriggerField: Record "Nc RapidConnect Trigger Field";
        FieldRef: FieldRef;
        PrevFieldRef: FieldRef;
    begin
        //-NC2.14 [320762]
        TriggerField.SetRange("Setup Code",TempExportTrigger."Setup Code");
        TriggerField.SetRange("Table ID",TempExportTrigger."Table ID");
        if not TriggerField.FindSet then
          exit(false);

        if Format(PrevRecRef) = Format(RecRef) then
          exit(false);

        repeat
          if Field.Get(TriggerField."Table ID",TriggerField."Field No.") then begin
            PrevFieldRef := PrevRecRef.Field(TriggerField."Field No.");
            FieldRef := RecRef.Field(TriggerField."Field No.");
            if PrevFieldRef.Value <> FieldRef.Value then
              exit(true);
          end;
        until TriggerField.Next = 0;

        exit(false);
        //+NC2.14 [320762]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151501, 'IsUniqueTask', '', true, true)]
    local procedure IsUniqueTask(TaskProcessor: Record "Nc Task Processor";var TempTask: Record "Nc Task" temporary;var UniqueTaskBuffer: Record "Nc Unique Task Buffer" temporary;var IsUnique: Boolean;var Checked: Boolean)
    var
        NewUniqueTaskBuffer: Record "Nc Unique Task Buffer" temporary;
        TempExportTrigger: Record "Nc RapidConnect Trigger Table" temporary;
        NcTaskMgt: Codeunit "Nc Task Mgt.";
        PrevRecRef: RecordRef;
        RecRef: RecordRef;
    begin
        if not TempTask.IsTemporary then
          exit;
        if not IsRapidConnectTask(TaskProcessor,TempTask) then
          exit;

        Checked := true;

        //-NC2.14 [320762]
        if not NcTaskMgt.GetRecRef(TempTask,RecRef) then
          exit;
        if not NcTaskMgt.RestoreRecordFromDataLog(TempTask."Entry No.",TempTask."Company Name",PrevRecRef) then
          PrevRecRef := RecRef.Duplicate;
        if not FindExportTriggers(TempTask,PrevRecRef,RecRef,TempExportTrigger) then
          exit;
        //+NC2.14 [320762]

        TempExportTrigger.FindSet;
        repeat
          //-NC2.14 [320762]
          NewUniqueTaskBuffer.Init;
          NewUniqueTaskBuffer."Table No." := RecRef.Number;
          NewUniqueTaskBuffer."Task Processor Code" := TaskProcessor.Code;
          NewUniqueTaskBuffer."Record Position" := RecRef.GetPosition(false);
          NewUniqueTaskBuffer."Codeunit ID" := CurrCodeunitId();
          NewUniqueTaskBuffer."Processing Code" := TempExportTrigger."Setup Code";
          if NcTaskMgt.ReqisterUniqueTask(NewUniqueTaskBuffer,UniqueTaskBuffer) then
            IsUnique := true;
          //+NC2.14 [320762]
        until TempExportTrigger.Next = 0;
    end;

    local procedure IsRapidConnectTask(TaskProcessor: Record "Nc Task Processor";Task: Record "Nc Task"): Boolean
    var
        NcTaskSetup: Record "Nc Task Setup";
        NpXmlSetup: Record "NpXml Setup";
    begin
        if not (NpXmlSetup.Get and NpXmlSetup."NpXml Enabled") then
          exit(false);

        NcTaskSetup.SetRange("Task Processor Code",TaskProcessor.Code);
        NcTaskSetup.SetRange("Table No.",Task."Table No.");
        NcTaskSetup.SetRange("Codeunit ID",CurrCodeunitId());
        exit(NcTaskSetup.FindFirst);
    end;

    procedure RecRefWithinPackage(var TempTask: Record "Nc Task" temporary;var PrevRecRef: RecordRef;var RecRef: RecordRef;var TempExportTrigger: Record "Nc RapidConnect Trigger Table" temporary): Boolean
    var
        ConfigPackageTable: Record "Config. Package Table";
        ConfigXMLExchange: Codeunit "Config. XML Exchange";
        PrevRecRef2: RecordRef;
        RecRef2: RecordRef;
    begin
        TempExportTrigger.CalcFields("Package Code");
        if not ConfigPackageTable.Get(TempExportTrigger."Package Code",RecRef.Number) then
          exit(false);

        //-NC2.14 [322308]
        if (TempTask.Type in [TempTask.Type::Modify,TempTask.Type::Rename]) and (TempExportTrigger."Modify Trigger" = TempExportTrigger."Modify Trigger"::Partial) then begin
          RecRef2 := RecRef.Duplicate;
          PrevRecRef2 := PrevRecRef.Duplicate;
          if not IsPartialModifyTrigger(PrevRecRef2,RecRef2,TempExportTrigger) then
            exit(false);
        end;
        //+NC2.14 [322308]
        RecRef2 := RecRef.Duplicate;
        //-NC14.00.2.22 [361941]
        ConfigXMLExchange.ApplyPackageFilter(ConfigPackageTable,RecRef2);
        //+NC14.00.2.22 [361941]
        exit(RecRef2.FindFirst);
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure NewLine() CRLF: Text[2]
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        exit(CRLF);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"Nc RapidConnect Export Mgt.");
    end;
}

