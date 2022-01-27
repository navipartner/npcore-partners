codeunit 6151553 "NPR NpXml Trigger Mgt."
{
    Access = Internal;
    var
        NpXmlMgt: Codeunit "NPR NpXml Mgt.";
        NpXmlValueMgt: Codeunit "NPR NpXml Value Mgt.";
        ProcessComplete: Boolean;

    procedure RunTemplate(NpXmlTemplate: Record "NPR NpXml Template"; RecRef: RecordRef)
    var
        RecRef2: RecordRef;
    begin
        RecRef2 := RecRef.Duplicate();
        RecRef2.SetRecFilter();
        NpXmlMgt.Initialize(NpXmlTemplate, RecRef2, NpXmlValueMgt.GetPrimaryKeyValue(RecRef2), true);
        ClearLastError();
        ProcessComplete := NpXmlMgt.Run() and ProcessComplete;

        Commit();
    end;

    local procedure RunTrigger(TaskProcessor: Record "NPR Nc Task Processor"; NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger"; PrevRecRef: RecordRef; RecRef: RecordRef; Insert: Boolean; Modify: Boolean; Delete: Boolean; var UniqueTaskBuffer: Record "NPR Nc Unique Task Buffer" temporary)
    var
        NpXmlTemplateTrigger2: Record "NPR NpXml Template Trigger";
        NpXmlTemplate: Record "NPR NpXml Template";
        TempUniqueTaskBuffer: Record "NPR Nc Unique Task Buffer" temporary;
        NcTaskMgt: Codeunit "NPR Nc Task Mgt.";
        RecRef2: RecordRef;
    begin
        if not TriggerToTemplate(TaskProcessor, Insert, Modify, Delete, NpXmlTemplateTrigger, NpXmlTemplate) then
            exit;
        if not SetLinkFilter(NpXmlTemplateTrigger, PrevRecRef, RecRef, Delete, RecRef2) then
            exit;

        if NpXmlTemplateTrigger."Parent Line No." = 0 then begin
            repeat
                TempUniqueTaskBuffer.Init();
                TempUniqueTaskBuffer."Table No." := RecRef2.Number;
                TempUniqueTaskBuffer."Task Processor Code" := TaskProcessor.Code;
                TempUniqueTaskBuffer."Record Position" := RecRef2.GetPosition(false);
                TempUniqueTaskBuffer."Codeunit ID" := CODEUNIT::"NPR NpXml Task Mgt.";
                TempUniqueTaskBuffer."Processing Code" := NpXmlTemplateTrigger."Xml Template Code";
                if NcTaskMgt.ReqisterUniqueTask(TempUniqueTaskBuffer, UniqueTaskBuffer) then
                    RunTemplate(NpXmlTemplate, RecRef2);
            until RecRef2.Next() = 0;
            exit;
        end;

        if NpXmlTemplateTrigger2.Get(NpXmlTemplateTrigger."Xml Template Code", NpXmlTemplateTrigger."Parent Line No.") then
            repeat
                if TriggerToTemplate(TaskProcessor, false, false, false, NpXmlTemplateTrigger2, NpXmlTemplate) then begin
                    RecRef := RecRef2.Duplicate();
                    PrevRecRef := RecRef2.Duplicate();
                    RunTrigger(TaskProcessor, NpXmlTemplateTrigger2, PrevRecRef, RecRef, false, false, false, UniqueTaskBuffer);
                end;
            until RecRef2.Next() = 0;
    end;

    procedure RunTriggers(TaskProcessor: Record "NPR Nc Task Processor"; PrevRecRef: RecordRef; RecRef: RecordRef; Task: Record "NPR Nc Task"; Insert: Boolean; Modify: Boolean; Delete: Boolean; var UniqueTaskBuffer: Record "NPR Nc Unique Task Buffer" temporary)
    var
        NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger";
    begin
        ProcessComplete := true;
        Clear(NpXmlTemplateTrigger);
        NpXmlTemplateTrigger.SetRange("Table No.", RecRef.Number);
        if NpXmlTemplateTrigger.FindSet() then
            repeat
                RunTrigger(TaskProcessor, NpXmlTemplateTrigger, PrevRecRef, RecRef, Insert, Modify, Delete, UniqueTaskBuffer);
            until NpXmlTemplateTrigger.Next() = 0;
    end;

    procedure TriggerToTemplate(TaskProcessor: Record "NPR Nc Task Processor"; Insert: Boolean; Modify: Boolean; Delete: Boolean; NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger"; var NpXmlTemplate: Record "NPR NpXml Template"): Boolean
    begin
        if not NpXmlTemplate.Get(NpXmlTemplateTrigger."Xml Template Code") then
            exit(false);
        if not NpXmlTemplate."Transaction Task" then
            exit(false);
        if (TaskProcessor.Code <> '') and (NpXmlTemplate."Task Processor Code" <> TaskProcessor.Code) then
            exit(false);

        if not (Insert or Modify or Delete) then
            exit(true);
        exit((Insert and NpXmlTemplateTrigger."Insert Trigger") or
             (Modify and NpXmlTemplateTrigger."Modify Trigger") or
             (Delete and NpXmlTemplateTrigger."Delete Trigger"));
    end;

    procedure InTemplateTrigger(NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger"; PrevRecRef: RecordRef; RecRef: RecordRef): Boolean
    var
        NpXmlTemplateTriggerLink: Record "NPR NpXml Templ.Trigger Link";
        RecRef2: RecordRef;
        FieldRef: FieldRef;
        PrevFieldRef: FieldRef;
        BoolBuffer: Boolean;
        i: Integer;
    begin
        if NpXmlTemplateTrigger."Table No." <> RecRef.Number then
            exit(false);

        Clear(NpXmlTemplateTriggerLink);
        NpXmlTemplateTriggerLink.SetRange("Xml Template Code", NpXmlTemplateTrigger."Xml Template Code");
        NpXmlTemplateTriggerLink.SetRange("Xml Template Trigger Line No.", NpXmlTemplateTrigger."Line No.");
        NpXmlTemplateTriggerLink.SetRange("Link Type", NpXmlTemplateTriggerLink."Link Type"::Constant);
        if NpXmlTemplateTriggerLink.FindSet() then
            repeat
                FieldRef := RecRef.Field(NpXmlTemplateTriggerLink."Field No.");
                if LowerCase(Format(FieldRef.Class)) = 'flowfield' then
                    FieldRef.CalcField();
                case LowerCase(Format(FieldRef.Type)) of
                    'boolean':
                        begin
                            Evaluate(BoolBuffer, Format(FieldRef.Value, 0, 9), 9);
                            if BoolBuffer <> (LowerCase(NpXmlTemplateTriggerLink."Filter Value") in ['1', 'yes', 'ja', 'true']) then
                                exit(false);
                        end;
                    'option':
                        begin
                            if (Format(FieldRef.Value, 0, 2) <> NpXmlTemplateTriggerLink."Filter Value") and
                                (LowerCase(Format(FieldRef.Value, 0, 9)) <> LowerCase(NpXmlTemplateTriggerLink."Filter Value")) then
                                exit(false);
                        end;
                    else
                        if Format(FieldRef.Value, 0, 9) <> NpXmlTemplateTriggerLink."Filter Value" then
                            exit(false);
                end;
            until NpXmlTemplateTriggerLink.Next() = 0;

        NpXmlTemplateTriggerLink.SetRange("Link Type", NpXmlTemplateTriggerLink."Link Type"::PreviousConstant);
        if NpXmlTemplateTriggerLink.FindSet() then
            repeat
                PrevFieldRef := PrevRecRef.Field(NpXmlTemplateTriggerLink."Field No.");
                if LowerCase(Format(PrevFieldRef.Class)) = 'flowfield' then
                    PrevFieldRef.CalcField();
                case LowerCase(Format(PrevFieldRef.Type)) of
                    'boolean':
                        begin
                            Evaluate(BoolBuffer, Format(PrevFieldRef.Value, 0, 9), 9);
                            if BoolBuffer <> (LowerCase(NpXmlTemplateTriggerLink."Previous Filter Value") in ['1', 'yes', 'ja', 'true']) then
                                exit(false);
                        end;
                    'option':
                        begin
                            if (Format(PrevFieldRef.Value, 0, 2) <> NpXmlTemplateTriggerLink."Previous Filter Value") and
                                (LowerCase(Format(PrevFieldRef.Value, 0, 9)) <> LowerCase(NpXmlTemplateTriggerLink."Previous Filter Value")) then
                                exit(false);
                        end;
                    else
                        if Format(PrevFieldRef.Value, 0, 9) <> NpXmlTemplateTriggerLink."Previous Filter Value" then
                            exit(false);
                end;
            until NpXmlTemplateTriggerLink.Next() = 0;

        NpXmlTemplateTriggerLink.SetRange("Link Type", NpXmlTemplateTriggerLink."Link Type"::Filter);
        if NpXmlTemplateTriggerLink.FindSet() then begin
            RecRef2 := RecRef.Duplicate();
            RecRef2.SetRecFilter();

            i := 40;
            repeat
                i += 1;
                RecRef2.FilterGroup(i);
                FieldRef := RecRef2.Field(NpXmlTemplateTriggerLink."Field No.");
                FieldRef.SetFilter(NpXmlTemplateTriggerLink."Filter Value");
            until NpXmlTemplateTriggerLink.Next() = 0;

            if not RecRef2.FindFirst() then
                exit(false);
        end;

        exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetupGenericParentTable(NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger"; ChildLinkRecRef: RecordRef; var ParentRecRef: RecordRef; var Handled: Boolean)
    begin
    end;

    procedure SetLinkFilter(NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger"; PrevRecRef: RecordRef; RecRef: RecordRef; Delete: Boolean; var RecRef2: RecordRef) HasLinkedRecords: Boolean
    begin
        if not InTemplateTrigger(NpXmlTemplateTrigger, PrevRecRef, RecRef) then
            exit(false);

        SetParentFilter(NpXmlTemplateTrigger, PrevRecRef, RecRef, RecRef2);
        if Delete and (RecRef.Number = RecRef2.Number) then
            exit(true);

        exit(RecRef2.FindSet());
    end;

    procedure SetParentFilter(NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger"; PrevRecRef: RecordRef; RecRef: RecordRef; var RecRef2: RecordRef)
    var
        NpXmlTemplateTriggerLink: Record "NPR NpXml Templ.Trigger Link";
        FieldRef: FieldRef;
        FieldRef2: FieldRef;
        BufferDecimal: Decimal;
        BufferInteger: Integer;
        Handled: Boolean;
    begin
        Clear(RecRef2);
        if NpXmlTemplateTrigger."Generic Parent Codeunit ID" <> 0 then
            OnSetupGenericParentTable(NpXmlTemplateTrigger, RecRef, RecRef2, Handled);
        if (not Handled) or (NpXmlTemplateTrigger."Generic Parent Codeunit ID" = 0) then begin
            RecRef2.Open(NpXmlTemplateTrigger."Parent Table No.");
            if RecRef.Number = NpXmlTemplateTrigger."Parent Table No." then
                RecRef2 := RecRef.Duplicate();
        end;
        if RecRef.Number = NpXmlTemplateTrigger."Parent Table No." then
            RecRef2.SetRecFilter();
        NpXmlTemplateTriggerLink.SetRange("Xml Template Code", NpXmlTemplateTrigger."Xml Template Code");
        NpXmlTemplateTriggerLink.SetRange("Xml Template Trigger Line No.", NpXmlTemplateTrigger."Line No.");
        NpXmlTemplateTriggerLink.SetFilter("Link Type", '%1|%2|%3|%4', NpXmlTemplateTriggerLink."Link Type"::TableLink,
          NpXmlTemplateTriggerLink."Link Type"::ParentConstant, NpXmlTemplateTriggerLink."Link Type"::ParentFilter,
          NpXmlTemplateTriggerLink."Link Type"::PreviousTableLink);
        if NpXmlTemplateTriggerLink.FindSet() then
            repeat
                FieldRef2 := RecRef2.Field(NpXmlTemplateTriggerLink."Parent Field No.");
                case NpXmlTemplateTriggerLink."Link Type" of
                    NpXmlTemplateTriggerLink."Link Type"::TableLink:
                        begin
                            FieldRef := RecRef.Field(NpXmlTemplateTriggerLink."Field No.");
                            if LowerCase(Format(FieldRef.Class)) = 'flowfield' then
                                FieldRef.CalcField();
                            FieldRef2.SetFilter('=%1', FieldRef.Value);
                        end;
                    NpXmlTemplateTriggerLink."Link Type"::ParentConstant:
                        begin
                            if NpXmlTemplateTriggerLink."Parent Filter Value" <> '' then begin
                                case LowerCase(Format(FieldRef2.Type)) of
                                    'boolean':
                                        FieldRef2.SetFilter('=%1', LowerCase(NpXmlTemplateTriggerLink."Parent Filter Value") in ['1', 'yes', 'ja', 'true']);
                                    'integer', 'option':
                                        begin
                                            if Evaluate(BufferDecimal, NpXmlTemplateTriggerLink."Parent Filter Value") then
                                                FieldRef2.SetFilter('=%1', BufferDecimal);
                                        end;
                                    'decimal':
                                        begin
                                            if Evaluate(BufferInteger, NpXmlTemplateTriggerLink."Parent Filter Value") then
                                                FieldRef2.SetFilter('=%1', BufferInteger);
                                        end;
                                    else
                                        FieldRef2.SetFilter('=%1', NpXmlTemplateTriggerLink."Parent Filter Value");
                                end;
                            end;
                        end;
                    NpXmlTemplateTriggerLink."Link Type"::ParentFilter:
                        begin
                            FieldRef2.SetFilter(NpXmlTemplateTriggerLink."Parent Filter Value");
                        end;
                    NpXmlTemplateTriggerLink."Link Type"::PreviousTableLink:
                        begin
                            FieldRef := PrevRecRef.Field(NpXmlTemplateTriggerLink."Field No.");
                            if LowerCase(Format(FieldRef.Class)) = 'flowfield' then
                                FieldRef.CalcField();
                            FieldRef2.SetFilter('=%1', FieldRef.Value);
                        end;
                end;
            until NpXmlTemplateTriggerLink.Next() = 0;
    end;

    procedure IsUniqueTask(TaskProcessor: Record "NPR Nc Task Processor"; Insert: Boolean; Modify: Boolean; Delete: Boolean; PrevRecRef: RecordRef; RecRef: RecordRef; var UniqueTaskBuffer: Record "NPR Nc Unique Task Buffer" temporary) IsUnique: Boolean
    var
        TempUniqueTaskBuffer: Record "NPR Nc Unique Task Buffer" temporary;
        NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger";
        NpXmlTemplate: Record "NPR NpXml Template";
        NcTaskMgt: Codeunit "NPR Nc Task Mgt.";
        RecRef2: RecordRef;
    begin
        Clear(NpXmlTemplateTrigger);
        NpXmlTemplateTrigger.SetRange("Table No.", RecRef.Number);

        if not NpXmlTemplateTrigger.FindSet() then
            exit(false);

        repeat
            if TriggerToTemplate(TaskProcessor, Insert, Modify, Delete, NpXmlTemplateTrigger, NpXmlTemplate) and
              SetLinkFilter(NpXmlTemplateTrigger, PrevRecRef, RecRef, Delete, RecRef2)
            then
                repeat
                    TempUniqueTaskBuffer.Init();
                    TempUniqueTaskBuffer."Table No." := RecRef2.Number;
                    TempUniqueTaskBuffer."Task Processor Code" := TaskProcessor.Code;
                    TempUniqueTaskBuffer."Record Position" := RecRef2.GetPosition(false);
                    TempUniqueTaskBuffer."Codeunit ID" := CODEUNIT::"NPR NpXml Task Mgt.";
                    TempUniqueTaskBuffer."Processing Code" := NpXmlTemplateTrigger."Xml Template Code";
                    if NcTaskMgt.ReqisterUniqueTask(TempUniqueTaskBuffer, UniqueTaskBuffer) then
                        IsUnique := true;
                until RecRef2.Next() = 0;
        until NpXmlTemplateTrigger.Next() = 0;

        exit(IsUnique);
    end;

    procedure GetProcessComplete(): Boolean
    begin
        exit(ProcessComplete);
    end;

    procedure GetOutput(var TempBlob: Codeunit "Temp Blob"): Boolean
    begin
        exit(NpXmlMgt.GetOutput(TempBlob));
    end;

    procedure GetResponse(var TempBlob: Codeunit "Temp Blob"): Boolean
    begin
        exit(NpXmlMgt.GetResponse(TempBlob));
    end;

    procedure ResetOutput()
    begin
        Clear(NpXmlMgt);
    end;
}

