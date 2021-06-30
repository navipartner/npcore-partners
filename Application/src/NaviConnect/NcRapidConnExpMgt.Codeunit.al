codeunit 6151091 "NPR Nc RapidConn. Exp. Mgt."
{
    TableNo = "NPR Nc Task";

    trigger OnRun()
    begin
        ProcessTask(Rec);
    end;

    local procedure ProcessTask(var NcTask: Record "NPR Nc Task")
    var
        NcTaskOutput: Record "NPR Nc Task Output";
        NcRapidConnectSetup: Record "NPR Nc RapidConnect Setup";
        TempExportTrigger: Record "NPR Nc RapidConnect Trig.Table" temporary;
        NcTaskMgt: Codeunit "NPR Nc Task Mgt.";
        PrevRecRef: RecordRef;
        RecRef: RecordRef;
        OutputName: Text;
        Response: Text;
        Success: Boolean;
        XmlDoc: XmlDocument;
    begin
        if not NcTaskMgt.GetRecRef(NcTask, RecRef) then
            exit;
        if not NcTaskMgt.RestoreRecord(NcTask."Entry No.", PrevRecRef) then
            PrevRecRef := RecRef.Duplicate();
        if not FindExportTriggers(NcTask, PrevRecRef, RecRef, TempExportTrigger) then
            exit;

        Success := true;
        NcTask.CalcFields("Table Name");
        OutputName := 'RapCo-' + CopyStr(DelChr(ConvertStr(Format(CurrentDateTime, 0, 9), ':', '.'), '=', '.,- TZ'), 1, 16) + '-';
        OutputName += Format(NcTask."Table No.") + '-' + NcTask."Table Name" + '-' + NcTask."Record Value";
        OutputName := DelChr(OutputName, '=', ':?|<>"^`�*/\"#�%&/''');

        TempExportTrigger.FindSet();
        repeat
            NcRapidConnectSetup.Get(TempExportTrigger."Setup Code");
            case NcRapidConnectSetup."Export File Type" of
                NcRapidConnectSetup."Export File Type"::".xml":
                    begin
                        OutputName := CopyStr(OutputName, 1, 100 - StrLen('.xml'));
                        OutputName += '.xml';

                        ExportToXml(NcRapidConnectSetup, NcTask, XmlDoc);
                        CommitXmlToOutput(NcTask, XmlDoc, OutputName, NcTaskOutput);
                    end;
            end;

            Success := Success and RunEndpoints(NcRapidConnectSetup, NcTaskOutput, Response);
            CommitResponse(Response, NcTask, NcTaskOutput);
        until TempExportTrigger.Next() = 0;

        if not Success then
            Error(GetLastErrorText);
    end;

    local procedure ExportToXml(NcRapidConnectSetup: Record "NPR Nc RapidConnect Setup"; NcTask: Record "NPR Nc Task"; var Document: XmlDocument)
    var
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageField: Record "Config. Package Field";
        NcRapidConnectSetupMgt: Codeunit "NPR Nc RapidConnect Setup Mgt.";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        NcTaskMgt: Codeunit "NPR Nc Task Mgt.";
        CDATA: XmlCData;
        DocumentElement: XmlElement;
        DocumentNode: XmlNode;
        Element: XmlElement;
        Element2: XmlElement;
        RecRef: RecordRef;
        FieldReference: FieldRef;
    begin
        NcRapidConnectSetupMgt.SetConfigPackageTableFilter(NcRapidConnectSetup, ConfigPackageTable);
        ConfigPackageTable.SetRange("Table ID", NcTask."Table No.");
        if not ConfigPackageTable.FindSet() then
            exit;

        if not NcTaskMgt.GetRecRef(NcTask, RecRef) then
            exit;

        NpXmlDomMgt.InitDoc(Document, DocumentNode, 'rapid_connect', '');
        DocumentElement := DocumentNode.AsXmlElement();
        repeat
            NpXmlDomMgt.AddElement(DocumentElement, 'record', Element);
            NpXmlDomMgt.AddAttribute(Element, 'table_id', Format(ConfigPackageTable."Table ID"));
            NpXmlDomMgt.AddAttribute(Element, 'position', Format(RecRef.GetPosition(false)));
            NpXmlDomMgt.AddAttribute(Element, 'record_id', Format(RecRef.RecordId));

            ConfigPackageField.SetRange("Package Code", ConfigPackageTable."Package Code");
            ConfigPackageField.SetRange("Table ID", ConfigPackageTable."Table ID");
            ConfigPackageField.SetRange("Include Field", true);
            if ConfigPackageField.FindSet() then
                repeat
                    if ConfigPackageField2FieldRef(ConfigPackageField, RecRef, FieldReference) then begin
                        NpXmlDomMgt.AddElement(Element, 'field', Element2);
                        NpXmlDomMgt.AddAttribute(Element2, 'field_no', Format(FieldReference.Number));

                        CDATA := XmlCData.Create(GetFieldValue(FieldReference));
                        Element2.Add(CDATA);
                    end;
                until ConfigPackageField.Next() = 0;
        until ConfigPackageTable.Next() = 0;
    end;

    local procedure ConfigPackageField2FieldRef(ConfigPackageField: Record "Config. Package Field"; RecRef: RecordRef; var FieldRef: FieldRef): Boolean
    var
        "Field": Record "Field";
    begin
        if not Field.Get(ConfigPackageField."Table ID", ConfigPackageField."Field ID") then
            exit(false);

        FieldRef := RecRef.Field(Field."No.");
        if Format(FieldRef.Class) = 'flowfield' then
            exit(false);

        exit(true);
    end;

    local procedure GetFieldValue(var FieldRef: FieldRef) FieldValue: Text
    begin
        FieldValue := Format(FieldRef.Value, 0, 9);
        exit(FieldValue);
    end;

    local procedure CommitXmlToOutput(NcTask: Record "NPR Nc Task"; XmlDoc: XmlDocument; OutputName: Text; var NcTaskOutput: Record "NPR Nc Task Output")
    var
        OutStr: OutStream;
    begin
        NcTaskOutput.Init();
        NcTaskOutput."Entry No." := 0;
        NcTaskOutput."Task Entry No." := NcTask."Entry No.";
        NcTaskOutput.Data.CreateOutStream(OutStr);
        XmlDoc.WriteTo(OutStr);
        NcTaskOutput.Name := OutputName;
        NcTaskOutput.Insert(true);
        Commit();
    end;

    local procedure RunEndpoints(NcRapidConnectSetup: Record "NPR Nc RapidConnect Setup"; var NcTaskOutput: Record "NPR Nc Task Output"; var Response: Text) Success: Boolean
    var
        NcRapidConnectEndpoint: Record "NPR Nc RapidConn. Endpoint";
        EndpointResponse: Text;
    begin
        Response := '';
        NcRapidConnectEndpoint.SetRange("Setup Code", NcRapidConnectSetup.Code);
        if NcRapidConnectEndpoint.IsEmpty then
            exit;

        Success := true;
        NcRapidConnectEndpoint.FindSet();
        repeat
            Success := Success and RunEndpoint(NcTaskOutput, NcRapidConnectEndpoint, EndpointResponse);

            if Response <> '' then
                Response += NewLine();
            Response += EndpointResponse;
        until NcRapidConnectEndpoint.Next() = 0;

        exit(Success);
    end;

    local procedure RunEndpoint(NcTaskOutput: Record "NPR Nc Task Output"; NcRapidConnectEndpoint: Record "NPR Nc RapidConn. Endpoint"; var Response: Text) Success: Boolean
    var
        NcEndpoint: Record "NPR Nc Endpoint";
        NcEndpointMgt: Codeunit "NPR Nc Endpoint Mgt.";
    begin
        NcEndpoint.Get(NcRapidConnectEndpoint."Endpoint Code");
        Success := NcEndpointMgt.RunEndpoint(NcTaskOutput, NcEndpoint, Response);
        exit(Success);
    end;

    local procedure CommitResponse(Response: Text; var NcTask: Record "NPR Nc Task"; var NcTaskOutput: Record "NPR Nc Task Output")
    var
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
        RecRef: RecordRef;
    begin
        TempBlob.CreateOutStream(OutStream);
        OutStream.WriteText(Response);

        NcTask.Get(NcTask."Entry No.");
        if NcTask.Response.HasValue() then begin
            NcTask.CalcFields(Response);
            NcTask.Response.CreateInStream(InStream);
            CopyStream(OutStream, InStream);
        end;

        RecRef.GetTable(NcTask);
        TempBlob.ToRecordRef(RecRef, NcTask.FieldNo(Response));
        RecRef.SetTable(NcTask);

        NcTask.Modify(true);

        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStream);
        OutStream.WriteText(Response);

        NcTaskOutput.Find();

        RecRef.GetTable(NcTaskOutput);
        TempBlob.ToRecordRef(RecRef, NcTaskOutput.FieldNo(Response));
        RecRef.SetTable(NcTaskOutput);

        NcTaskOutput.Modify(true);
        Commit();
    end;

    local procedure FindExportTriggers(NcTask: Record "NPR Nc Task"; var PrevRecRef: RecordRef; var RecRef: RecordRef; var TempExportTrigger: Record "NPR Nc RapidConnect Trig.Table" temporary): Boolean
    var
        NcRapidConnectSetup: Record "NPR Nc RapidConnect Setup";
        ExportTrigger: Record "NPR Nc RapidConnect Trig.Table";
    begin
        case NcTask.Type of
            NcTask.Type::Insert, NcTask.Type::Rename:
                ExportTrigger.SetRange("Insert Trigger", ExportTrigger."Insert Trigger"::Full);
            NcTask.Type::Modify:
                ExportTrigger.SetFilter("Modify Trigger", '%1|%2', ExportTrigger."Modify Trigger"::Full, ExportTrigger."Modify Trigger"::Partial);
            NcTask.Type::Delete:
                exit(false);
        end;

        ExportTrigger.SetRange("Table ID", NcTask."Table No.");
        ExportTrigger.SetFilter("Package Code", '<>%1', '');
        ExportTrigger.SetRange("Export Enabled", true);
        ExportTrigger.SetFilter("Task Processor Code", '<>%1', '');
        if ExportTrigger.IsEmpty then
            exit(false);

        ExportTrigger.FindSet();
        repeat
            if RecRefWithinPackage(NcTask, PrevRecRef, RecRef, ExportTrigger) then begin
                NcRapidConnectSetup.Get(ExportTrigger."Setup Code");
                TempExportTrigger.Init();
                TempExportTrigger := ExportTrigger;
                TempExportTrigger.Insert();
            end;
        until ExportTrigger.Next() = 0;

        exit(TempExportTrigger.FindSet());
    end;

    local procedure IsPartialModifyTrigger(var PrevRecRef: RecordRef; var RecRef: RecordRef; var TempExportTrigger: Record "NPR Nc RapidConnect Trig.Table" temporary): Boolean
    var
        "Field": Record "Field";
        TriggerField: Record "NPR Nc RapidConnect Trig.Field";
        FieldRef: FieldRef;
        PrevFieldRef: FieldRef;
    begin
        TriggerField.SetRange("Setup Code", TempExportTrigger."Setup Code");
        TriggerField.SetRange("Table ID", TempExportTrigger."Table ID");
        if not TriggerField.FindSet() then
            exit(false);

        if Format(PrevRecRef) = Format(RecRef) then
            exit(false);

        repeat
            if Field.Get(TriggerField."Table ID", TriggerField."Field No.") then begin
                PrevFieldRef := PrevRecRef.Field(TriggerField."Field No.");
                FieldRef := RecRef.Field(TriggerField."Field No.");
                if PrevFieldRef.Value <> FieldRef.Value then
                    exit(true);
            end;
        until TriggerField.Next() = 0;

        exit(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151501, 'IsUniqueTask', '', true, true)]
    local procedure IsUniqueTask(TaskProcessor: Record "NPR Nc Task Processor"; var TempTask: Record "NPR Nc Task" temporary; var UniqueTaskBuffer: Record "NPR Nc Unique Task Buffer" temporary; var IsUnique: Boolean; var Checked: Boolean)
    var
        TempUniqueTaskBuffer: Record "NPR Nc Unique Task Buffer" temporary;
        TempExportTrigger: Record "NPR Nc RapidConnect Trig.Table" temporary;
        NcTaskMgt: Codeunit "NPR Nc Task Mgt.";
        PrevRecRef: RecordRef;
        RecRef: RecordRef;
    begin
        if not TempTask.IsTemporary then
            exit;
        if not IsRapidConnectTask(TaskProcessor, TempTask) then
            exit;

        Checked := true;

        if not NcTaskMgt.GetRecRef(TempTask, RecRef) then
            exit;
        if not NcTaskMgt.RestoreRecordFromDataLog(TempTask."Entry No.", TempTask."Company Name", PrevRecRef) then
            PrevRecRef := RecRef.Duplicate();
        if not FindExportTriggers(TempTask, PrevRecRef, RecRef, TempExportTrigger) then
            exit;

        TempExportTrigger.FindSet();
        repeat
            TempUniqueTaskBuffer.Init();
            TempUniqueTaskBuffer."Table No." := RecRef.Number;
            TempUniqueTaskBuffer."Task Processor Code" := TaskProcessor.Code;
            TempUniqueTaskBuffer."Record Position" := RecRef.GetPosition(false);
            TempUniqueTaskBuffer."Codeunit ID" := CurrCodeunitId();
            TempUniqueTaskBuffer."Processing Code" := TempExportTrigger."Setup Code";
            if NcTaskMgt.ReqisterUniqueTask(TempUniqueTaskBuffer, UniqueTaskBuffer) then
                IsUnique := true;
        until TempExportTrigger.Next() = 0;
    end;

    local procedure IsRapidConnectTask(TaskProcessor: Record "NPR Nc Task Processor"; Task: Record "NPR Nc Task"): Boolean
    var
        NcTaskSetup: Record "NPR Nc Task Setup";
        NpXmlSetup: Record "NPR NpXml Setup";
    begin
        if not (NpXmlSetup.Get() and NpXmlSetup."NpXml Enabled") then
            exit(false);

        NcTaskSetup.SetRange("Task Processor Code", TaskProcessor.Code);
        NcTaskSetup.SetRange("Table No.", Task."Table No.");
        NcTaskSetup.SetRange("Codeunit ID", CurrCodeunitId());
        exit(NcTaskSetup.FindFirst());
    end;

    procedure RecRefWithinPackage(var TempTask: Record "NPR Nc Task" temporary; var PrevRecRef: RecordRef; var RecRef: RecordRef; var TempExportTrigger: Record "NPR Nc RapidConnect Trig.Table" temporary): Boolean
    var
        ConfigPackageTable: Record "Config. Package Table";
        ConfigXMLExchange: Codeunit "Config. XML Exchange";
        PrevRecRef2: RecordRef;
        RecRef2: RecordRef;
    begin
        TempExportTrigger.CalcFields("Package Code");
        if not ConfigPackageTable.Get(TempExportTrigger."Package Code", RecRef.Number) then
            exit(false);

        if (TempTask.Type in [TempTask.Type::Modify, TempTask.Type::Rename]) and (TempExportTrigger."Modify Trigger" = TempExportTrigger."Modify Trigger"::Partial) then begin
            RecRef2 := RecRef.Duplicate();
            PrevRecRef2 := PrevRecRef.Duplicate();
            if not IsPartialModifyTrigger(PrevRecRef2, RecRef2, TempExportTrigger) then
                exit(false);
        end;
        RecRef2 := RecRef.Duplicate();
        RecRef2.SetRecFilter();
        RecRef2.FilterGroup(40);
        ConfigXMLExchange.ApplyPackageFilter(ConfigPackageTable, RecRef2);
        exit(RecRef2.FindFirst());
    end;

    local procedure NewLine() CRLF: Text[2]
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        exit(CRLF);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR Nc RapidConn. Exp. Mgt.");
    end;
}

