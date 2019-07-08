codeunit 6151553 "NpXml Trigger Mgt."
{
    // NC1.13 /MHA /20150414  CASE 211360 Object Created - Restructured NpXml Codeunits. Independent functions moved to new codeunits
    // NC1.14 /MHA /20150424  CASE 212415 Moved Clear of NpXml Mgt. in order to enable multiple template output
    // NC1.17 /MHA /20150603  CASE 215533 Corrections of multi level triggers
    // NC1.18 /MHA /20150707  CASE 218282 Renamed functions:
    //                                     - SetRecRefXmlTemplateTriggerFilter ~ SetParentFilter
    //                                     - RunNpXmlTemplate ~ RunTemplate
    //                                     - RunNpXmlTemplateTrigger ~ RunTrigger
    //                                     - RunNpXmlTemplateTriggers ~ RunTriggers
    //                                     - GetXmlTemplate ~ TriggerToTemplate
    // NC1.20 /MHA /20150821  CASE 2212229 Trigger filters changed to enable triggering if at least one trigger is true
    // NC1.21 /MHA /20151117  CASE 227150 Removed Unused Variable to NpRetail in IsDuplicate()
    // NC1.22 /MHA /20160415  CASE 231214 Added multi company Task Processing
    // NC2.00 /MHA /20160525  CASE 240005 NaviConnect
    // NC2.01 /MHA /20160914  CASE 242551 Changed InTemplateTrigger() to set filter on all fields before FINDFIRST for "Link Type"::Filter
    // NC2.01 /MHA /20161018  CASE 242550 Added function OnSetupGenericParentTable() for enabling Temporary Table Exports
    // NC2.03 /MHA /20170327  CASE 267094 COMMIT added after RunTemplate() to enable execution of multiple templates
    // NC2.07 /MHA /20171027  CASE 294737 Added FILTERGROUP in InTemplateTrigger() to enable multiple filters on fields
    // NC2.12 /MHA /20180418  CASE 308107 Deleted functions IsDuplicate(),IsDuplicateRecord() and added IsUniqueTask()
    // NC2.14/MHA /20180629  CASE 320762 Deleted function GetRecRef()


    trigger OnRun()
    var
        NpXmlTemplate: Record "NpXml Template";
        TempDataLogRecord: Record "Data Log Record" temporary;
        RecRef: RecordRef;
        PrevRecRef: RecordRef;
        DataLogEntryNo: Integer;
    begin
    end;

    var
        NpXmlMgt: Codeunit "NpXml Mgt.";
        NpXmlValueMgt: Codeunit "NpXml Value Mgt.";
        ProcessComplete: Boolean;

    procedure RunTemplate(NpXmlTemplate: Record "NpXml Template";RecRef: RecordRef)
    var
        RecRef2: RecordRef;
    begin
        RecRef2 := RecRef.Duplicate;
        RecRef2.SetRecFilter;
        NpXmlMgt.Initialize(NpXmlTemplate,RecRef2,NpXmlValueMgt.GetPrimaryKeyValue(RecRef2),true);
        ClearLastError;
        ProcessComplete := NpXmlMgt.Run() and ProcessComplete;
        //-NC2.03 [267094]
        Commit;
        //+NC2.03 [267094]
    end;

    local procedure RunTrigger(TaskProcessor: Record "Nc Task Processor";NpXmlTemplateTrigger: Record "NpXml Template Trigger";PrevRecRef: RecordRef;RecRef: RecordRef;Insert: Boolean;Modify: Boolean;Delete: Boolean;var UniqueTaskBuffer: Record "Nc Unique Task Buffer" temporary)
    var
        NpXmlTemplateTrigger2: Record "NpXml Template Trigger";
        NpXmlTemplate: Record "NpXml Template";
        NewUniqueTaskBuffer: Record "Nc Unique Task Buffer" temporary;
        NcTaskMgt: Codeunit "Nc Task Mgt.";
        RecRef2: RecordRef;
    begin
        //-NC2.01 [242550]
        if not TriggerToTemplate(TaskProcessor,Insert,Modify,Delete,NpXmlTemplateTrigger,NpXmlTemplate) then
          exit;
        //+NC2.01 [242550]
        if not SetLinkFilter(NpXmlTemplateTrigger,PrevRecRef,RecRef,Delete,RecRef2) then
          exit;

        //-NC2.01 [242550]
        //IF NOT TriggerToTemplate(TaskProcessor,Insert,Modify,Delete,NpXmlTemplateTrigger,NpXmlTemplate) THEN
        //  EXIT;
        //+NC2.01 [242550]

        if NpXmlTemplateTrigger."Parent Line No." = 0 then begin
          repeat
            //-NC2.12 [308107]
            //IF NOT IsDuplicateRecord(NpXmlTemplateTrigger,RecRef2,DataLogEntryNo,TempDataLogRecord) THEN
            //  RunTemplate(NpXmlTemplate,RecRef2);
            NewUniqueTaskBuffer.Init;
            NewUniqueTaskBuffer."Table No." := RecRef2.Number;
            NewUniqueTaskBuffer."Task Processor Code" := TaskProcessor.Code;
            NewUniqueTaskBuffer."Record Position" := RecRef2.GetPosition(false);
            NewUniqueTaskBuffer."Codeunit ID" := CODEUNIT::"NpXml Task Mgt.";
            NewUniqueTaskBuffer."Processing Code" := NpXmlTemplateTrigger."Xml Template Code";
            if NcTaskMgt.ReqisterUniqueTask(NewUniqueTaskBuffer,UniqueTaskBuffer) then
              RunTemplate(NpXmlTemplate,RecRef2);
            //+NC2.12 [308107]
          until RecRef2.Next = 0;
          exit;
        end;

        if NpXmlTemplateTrigger2.Get(NpXmlTemplateTrigger."Xml Template Code",NpXmlTemplateTrigger."Parent Line No.") then
          repeat
            if TriggerToTemplate(TaskProcessor,false,false,false,NpXmlTemplateTrigger2,NpXmlTemplate) then begin
              RecRef := RecRef2.Duplicate;
              PrevRecRef := RecRef2.Duplicate;
              //-NC2.12 [308107]
              //RunTrigger(TaskProcessor,NpXmlTemplateTrigger2,PrevRecRef,RecRef,FALSE,FALSE,FALSE,DataLogEntryNo,TempDataLogRecord);
              RunTrigger(TaskProcessor,NpXmlTemplateTrigger2,PrevRecRef,RecRef,false,false,false,UniqueTaskBuffer);
              //+NC2.12 [308107]
            end;
          until RecRef2.Next = 0;
    end;

    procedure RunTriggers(TaskProcessor: Record "Nc Task Processor";PrevRecRef: RecordRef;RecRef: RecordRef;Task: Record "Nc Task";Insert: Boolean;Modify: Boolean;Delete: Boolean;var UniqueTaskBuffer: Record "Nc Unique Task Buffer" temporary)
    var
        NpXmlTemplateTrigger: Record "NpXml Template Trigger";
    begin
        ProcessComplete := true;
        Clear(NpXmlTemplateTrigger);
        NpXmlTemplateTrigger.SetRange("Table No.",RecRef.Number);
        if NpXmlTemplateTrigger.FindSet then
          repeat
            //-NC2.12 [308107]
            //RunTrigger(TaskProcessor,NpXmlTemplateTrigger,PrevRecRef,RecRef,Insert,Modify,Delete,DataLogEntryNo,TempDataLogRecord);
            RunTrigger(TaskProcessor,NpXmlTemplateTrigger,PrevRecRef,RecRef,Insert,Modify,Delete,UniqueTaskBuffer);
            //+NC2.12 [308107]
          until NpXmlTemplateTrigger.Next = 0;
    end;

    procedure "--- Get"()
    begin
    end;

    procedure TriggerToTemplate(TaskProcessor: Record "Nc Task Processor";Insert: Boolean;Modify: Boolean;Delete: Boolean;NpXmlTemplateTrigger: Record "NpXml Template Trigger";var NpXmlTemplate: Record "NpXml Template"): Boolean
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

    local procedure "--- Filter"()
    begin
    end;

    procedure InTemplateTrigger(NpXmlTemplateTrigger: Record "NpXml Template Trigger";PrevRecRef: RecordRef;RecRef: RecordRef): Boolean
    var
        NpXmlTemplateTriggerLink: Record "NpXml Template Trigger Link";
        RecRef2: RecordRef;
        FieldRef: FieldRef;
        PrevFieldRef: FieldRef;
        IntBuffer: Integer;
        BoolBuffer: Boolean;
        i: Integer;
    begin
        if NpXmlTemplateTrigger."Table No." <> RecRef.Number then
          exit(false);

        //-NC2.01 [242551]
        Clear(NpXmlTemplateTriggerLink);
        NpXmlTemplateTriggerLink.SetRange("Xml Template Code",NpXmlTemplateTrigger."Xml Template Code");
        NpXmlTemplateTriggerLink.SetRange("Xml Template Trigger Line No.",NpXmlTemplateTrigger."Line No.");
        NpXmlTemplateTriggerLink.SetRange("Link Type",NpXmlTemplateTriggerLink."Link Type"::Constant);
        if NpXmlTemplateTriggerLink.FindSet then
          repeat
            FieldRef := RecRef.Field(NpXmlTemplateTriggerLink."Field No.");
            if LowerCase(Format(FieldRef.Class)) = 'flowfield' then
              FieldRef.CalcField;
            case LowerCase(Format(FieldRef.Type)) of
              'boolean':
                begin
                  Evaluate(BoolBuffer,Format(FieldRef.Value,0,9),9);
                  if BoolBuffer <> (LowerCase(NpXmlTemplateTriggerLink."Filter Value") in ['1','yes','ja','true']) then
                    exit(false);
                end;
              'option':
                begin
                  if (Format(FieldRef.Value,0,2) <> NpXmlTemplateTriggerLink."Filter Value") and
                      (LowerCase(Format(FieldRef.Value,0,9)) <> LowerCase(NpXmlTemplateTriggerLink."Filter Value")) then
                    exit(false);
                end;
              else
                if Format(FieldRef.Value,0,9) <> NpXmlTemplateTriggerLink."Filter Value" then
                  exit(false);
            end;
          until NpXmlTemplateTriggerLink.Next = 0;

        NpXmlTemplateTriggerLink.SetRange("Link Type",NpXmlTemplateTriggerLink."Link Type"::PreviousConstant);
        if NpXmlTemplateTriggerLink.FindSet then
          repeat
            PrevFieldRef := PrevRecRef.Field(NpXmlTemplateTriggerLink."Field No.");
            if LowerCase(Format(PrevFieldRef.Class)) = 'flowfield' then
              PrevFieldRef.CalcField;
            case LowerCase(Format(PrevFieldRef.Type)) of
              'boolean':
                begin
                  Evaluate(BoolBuffer,Format(PrevFieldRef.Value,0,9),9);
                  if BoolBuffer <> (LowerCase(NpXmlTemplateTriggerLink."Previous Filter Value") in ['1','yes','ja','true']) then
                    exit(false);
                end;
              'option':
                begin
                  if (Format(PrevFieldRef.Value,0,2) <> NpXmlTemplateTriggerLink."Previous Filter Value") and
                      (LowerCase(Format(PrevFieldRef.Value,0,9)) <> LowerCase(NpXmlTemplateTriggerLink."Previous Filter Value")) then
                    exit(false);
                end;
              else
                if Format(PrevFieldRef.Value,0,9) <> NpXmlTemplateTriggerLink."Previous Filter Value" then
                  exit(false);
            end;
          until NpXmlTemplateTriggerLink.Next = 0;

        NpXmlTemplateTriggerLink.SetRange("Link Type",NpXmlTemplateTriggerLink."Link Type"::Filter);
        if NpXmlTemplateTriggerLink.FindSet then begin
          RecRef2 := RecRef.Duplicate;
          RecRef2.SetRecFilter;

          //-NC2.07 [294737]
          i := 40;
          //+NC2.07 [294737]
          repeat
            //-NC2.07 [294737]
            i += 1;
            RecRef2.FilterGroup(i);
            //+NC2.07 [294737]
            FieldRef := RecRef2.Field(NpXmlTemplateTriggerLink."Field No.");
            FieldRef.SetFilter(NpXmlTemplateTriggerLink."Filter Value");
          until NpXmlTemplateTriggerLink.Next = 0;

          if not RecRef2.FindFirst then
            exit(false);
        end;
        //+NC2.01 [242551]

        exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetupGenericParentTable(NpXmlTemplateTrigger: Record "NpXml Template Trigger";ChildLinkRecRef: RecordRef;var ParentRecRef: RecordRef;var Handled: Boolean)
    begin
        //-NC2.01 [242550]
        //+NC2.01 [242550]
    end;

    procedure SetLinkFilter(NpXmlTemplateTrigger: Record "NpXml Template Trigger";PrevRecRef: RecordRef;RecRef: RecordRef;Delete: Boolean;var RecRef2: RecordRef) HasLinkedRecords: Boolean
    begin
        if not InTemplateTrigger(NpXmlTemplateTrigger,PrevRecRef,RecRef) then
          exit(false);

        SetParentFilter(NpXmlTemplateTrigger,PrevRecRef,RecRef,RecRef2);
        if Delete and (RecRef.Number = RecRef2.Number) then
          exit(true);

        exit(RecRef2.FindSet);
    end;

    procedure SetParentFilter(NpXmlTemplateTrigger: Record "NpXml Template Trigger";PrevRecRef: RecordRef;RecRef: RecordRef;var RecRef2: RecordRef)
    var
        NpXmlTemplateTriggerLink: Record "NpXml Template Trigger Link";
        FieldRef: FieldRef;
        FieldRef2: FieldRef;
        BufferDecimal: Decimal;
        BufferInteger: Integer;
        Handled: Boolean;
    begin
        Clear(RecRef2);
        //-NC2.01 [242550]
        //RecRef2.OPEN(NpXmlTemplateTrigger."Parent Table No.");
        //IF (RecRef.NUMBER = NpXmlTemplateTrigger."Parent Table No.") THEN BEGIN
        //  RecRef2 := RecRef.DUPLICATE;
        //  RecRef2.SETRECFILTER;
        //END;
        if NpXmlTemplateTrigger."Generic Parent Codeunit ID" <> 0 then
          OnSetupGenericParentTable(NpXmlTemplateTrigger,RecRef,RecRef2,Handled);
        if (not Handled) or (NpXmlTemplateTrigger."Generic Parent Codeunit ID" = 0) then begin
          RecRef2.Open(NpXmlTemplateTrigger."Parent Table No.");
          if RecRef.Number = NpXmlTemplateTrigger."Parent Table No." then
            RecRef2 := RecRef.Duplicate;
        end;
        if RecRef.Number = NpXmlTemplateTrigger."Parent Table No." then
          RecRef2.SetRecFilter;
        //+NC2.01 [242550]
        NpXmlTemplateTriggerLink.SetRange("Xml Template Code",NpXmlTemplateTrigger."Xml Template Code");
        NpXmlTemplateTriggerLink.SetRange("Xml Template Trigger Line No.",NpXmlTemplateTrigger."Line No.");
        NpXmlTemplateTriggerLink.SetFilter("Link Type",'%1|%2|%3|%4',NpXmlTemplateTriggerLink."Link Type"::TableLink,
          NpXmlTemplateTriggerLink."Link Type"::ParentConstant,NpXmlTemplateTriggerLink."Link Type"::ParentFilter,
          NpXmlTemplateTriggerLink."Link Type"::PreviousTableLink);
        if NpXmlTemplateTriggerLink.FindSet then
          repeat
            FieldRef2 := RecRef2.Field(NpXmlTemplateTriggerLink."Parent Field No.");
            case NpXmlTemplateTriggerLink."Link Type" of
              NpXmlTemplateTriggerLink."Link Type"::TableLink:
                begin
                  FieldRef := RecRef.Field(NpXmlTemplateTriggerLink."Field No.");
                  if LowerCase(Format(FieldRef.Class)) = 'flowfield' then
                    FieldRef.CalcField;
                  FieldRef2.SetFilter('=%1',FieldRef.Value);
                end;
              NpXmlTemplateTriggerLink."Link Type"::ParentConstant:
                begin
                  if NpXmlTemplateTriggerLink."Parent Filter Value" <> '' then begin
                    case LowerCase(Format(FieldRef2.Type)) of
                      'boolean': FieldRef2.SetFilter('=%1',LowerCase(NpXmlTemplateTriggerLink."Parent Filter Value") in ['1','yes','ja','true']);
                      'integer','option':
                        begin
                          if Evaluate(BufferDecimal,NpXmlTemplateTriggerLink."Parent Filter Value") then
                            FieldRef2.SetFilter('=%1',BufferDecimal);
                        end;
                      'decimal':
                        begin
                          if Evaluate(BufferInteger,NpXmlTemplateTriggerLink."Parent Filter Value") then
                            FieldRef2.SetFilter('=%1',BufferInteger);
                        end;
                      else
                        FieldRef2.SetFilter('=%1',NpXmlTemplateTriggerLink."Parent Filter Value");
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
                    FieldRef.CalcField;
                  FieldRef2.SetFilter('=%1',FieldRef.Value);
                end;
            end;
          until NpXmlTemplateTriggerLink.Next = 0;
    end;

    procedure "--- Unique Task"()
    begin
    end;

    procedure IsUniqueTask(TaskProcessor: Record "Nc Task Processor";Insert: Boolean;Modify: Boolean;Delete: Boolean;PrevRecRef: RecordRef;RecRef: RecordRef;var UniqueTaskBuffer: Record "Nc Unique Task Buffer" temporary) IsUnique: Boolean
    var
        Item: Record Item;
        NewUniqueTaskBuffer: Record "Nc Unique Task Buffer" temporary;
        NpXmlTemplateTrigger: Record "NpXml Template Trigger";
        NpXmlTemplate: Record "NpXml Template";
        NcTaskMgt: Codeunit "Nc Task Mgt.";
        RecRef2: RecordRef;
    begin
        Clear(NpXmlTemplateTrigger);
        NpXmlTemplateTrigger.SetRange("Table No.",RecRef.Number);

        if not NpXmlTemplateTrigger.FindSet then
          exit(false);

        repeat
          if TriggerToTemplate(TaskProcessor,Insert,Modify,Delete,NpXmlTemplateTrigger,NpXmlTemplate) and
            SetLinkFilter(NpXmlTemplateTrigger,PrevRecRef,RecRef,Delete,RecRef2)
          then
            repeat
              NewUniqueTaskBuffer.Init;
              NewUniqueTaskBuffer."Table No." := RecRef2.Number;
              NewUniqueTaskBuffer."Task Processor Code" := TaskProcessor.Code;
              NewUniqueTaskBuffer."Record Position" := RecRef2.GetPosition(false);
              NewUniqueTaskBuffer."Codeunit ID" := CODEUNIT::"NpXml Task Mgt.";
              NewUniqueTaskBuffer."Processing Code" := NpXmlTemplateTrigger."Xml Template Code";
              if NcTaskMgt.ReqisterUniqueTask(NewUniqueTaskBuffer,UniqueTaskBuffer) then
                IsUnique := true;
            until RecRef2.Next = 0;
        until NpXmlTemplateTrigger.Next = 0;

        exit(IsUnique);
    end;

    procedure "--- Output"()
    begin
    end;

    procedure GetProcessComplete(): Boolean
    begin
        exit(ProcessComplete);
    end;

    procedure GetOutput(var TempBlob: Record TempBlob temporary): Boolean
    begin
        exit(NpXmlMgt.GetOutput(TempBlob));
    end;

    procedure GetResponse(var TempBlob: Record TempBlob temporary): Boolean
    begin
        exit(NpXmlMgt.GetResponse(TempBlob));
    end;

    procedure ResetOutput()
    begin
        Clear(NpXmlMgt);
    end;
}

