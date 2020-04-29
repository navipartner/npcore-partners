codeunit 6151552 "NpXml Batch Mgt."
{
    // NC1.00/MH/20150113  CASE 199932 Refactored object from Web - XML
    // NC1.01/MH/20150115  CASE 199932 Removed Timer functionality
    // NC1.13/MH/20150414  CASE 211360 Restructured NpXml Codeunits. Independent functions moved to new codeunits
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect

    SingleInstance = true;

    trigger OnRun()
    begin
        RunBatches();
    end;

    var
        NpXmlMgt: Codeunit "NpXml Mgt.";
        BatchStarted: Boolean;
        Error001: Label 'Custom Value has not been set\The Custom Codeunit should invoke SetCustomValue in Codeunit 6151552 NpXml Batch Management';

    procedure CheckRunBatch(NPXmlTemplate: Record "NpXml Template"): Boolean
    var
        RunDatetime: DateTime;
    begin
        //-NC1.13
        if not NPXmlTemplate."Batch Task" then
          exit(false);
        if NPXmlTemplate."Batch Active From" = 0DT then
          exit(false);
        if NPXmlTemplate."Batch Active From" > CurrentDateTime then
          exit(false);
        if NPXmlTemplate."Next Batch Run" > CurrentDateTime then
          exit(false);
        if NPXmlTemplate."Batch Start Time" > Time then
          exit(false);
        if (NPXmlTemplate."Batch End Time" < Time) and (NPXmlTemplate."Batch End Time" <> 0T) then
          exit(false);

        exit(true);
        //+NC1.13
    end;

    procedure RunBatch(var NPXmlTemplate: Record "NpXml Template")
    var
        RecRef: RecordRef;
    begin
        //-NC1.13
        NPXmlTemplate.Get(NPXmlTemplate.Code);
        NPXmlTemplate."Batch Last Run" := CurrentDateTime();
        NPXmlTemplate."Next Batch Run" := CalcNextBatchDatetime(NPXmlTemplate);
        NPXmlTemplate."Runtime Error" := true;
        NPXmlTemplate."Last Error Message" := '';
        NPXmlTemplate.Modify(true);
        Commit;

        Clear(NpXmlMgt);
        SetRecRefXmlTemplateFilter(NPXmlTemplate,RecRef);
        NpXmlMgt.Initialize(NPXmlTemplate,RecRef,'',false);
        NpXmlMgt.CreateXml();
        RecRef.Close;

        NPXmlTemplate.Get(NPXmlTemplate.Code);
        NPXmlTemplate."Runtime Error" := false;
        NPXmlTemplate.Modify(true);
        //+NC1.13
    end;

    procedure RunBatches()
    var
        NpXmlTemplate: Record "NpXml Template";
    begin
        //-NC1.13
        //CLEAR(XMLTemplate);
        //IF XMLTemplate.FINDSET THEN
        //  REPEAT
        //    BatchStarted := TRUE;
        //    IF XMLMgt.CheckRunBatch(XMLTemplate) THEN
        //      XMLMgt.RunBatch(XMLTemplate);
        //    BatchStarted := FALSE;
        //  UNTIL XMLTemplate.NEXT = 0;
        Clear(NpXmlTemplate);
        if NpXmlTemplate.FindSet then
          repeat
            BatchStarted := true;
            if CheckRunBatch(NpXmlTemplate) then
              RunBatch(NpXmlTemplate);
            BatchStarted := false;
          until NpXmlTemplate.Next = 0;
        //+NC1.13
    end;

    local procedure "--- Filter"()
    begin
    end;

    local procedure SetRecRefXmlTemplateFilter(NpXmlTemplate: Record "NpXml Template";var RecRef: RecordRef)
    var
        NpXmlFilter: Record "NpXml Filter";
        FieldRef: FieldRef;
        BufferDecimal: Decimal;
        BufferInteger: Integer;
    begin
        Clear(RecRef);
        RecRef.Open(NpXmlTemplate."Table No.");
        Clear(NpXmlFilter."Xml Template Code");
        NpXmlFilter.SetRange("Xml Template Code",NpXmlTemplate.Code);
        NpXmlFilter.SetFilter("Xml Element Line No.",'=%1',-1);
        NpXmlFilter.SetRange("Filter Type",NpXmlFilter."Filter Type"::Constant);
        NpXmlFilter.SetFilter("Filter Value",'<>%1','');
        if NpXmlFilter.FindSet then
          repeat
            FieldRef := RecRef.Field(NpXmlFilter."Parent Field No.");
            //-NC1.11
            case LowerCase(Format(FieldRef.Type)) of
              'boolean': FieldRef.SetFilter('=%1',LowerCase(NpXmlFilter."Filter Value") in ['1','yes','ja','true']);
              'integer','option':
                begin
                  if Evaluate(BufferDecimal,NpXmlFilter."Filter Value") then
                    FieldRef.SetRange(BufferDecimal);
                end;
              'decimal':
                begin
                  if Evaluate(BufferInteger,NpXmlFilter."Filter Value") then
                    FieldRef.SetRange(BufferInteger);
                end;
              else
                FieldRef.SetRange(NpXmlFilter."Filter Value");
            end;
            //+NC1.11
          until NpXmlFilter.Next = 0;

        NpXmlFilter.SetRange("Filter Type",NpXmlFilter."Filter Type"::Filter);
        if NpXmlFilter.FindSet then
          repeat
            FieldRef := RecRef.Field(NpXmlFilter."Parent Field No.");
            FieldRef.SetFilter(NpXmlFilter."Filter Value");
          until NpXmlFilter.Next = 0;
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure CalcNextBatchDatetime(NPXmlTemplate: Record "NpXml Template"): DateTime
    var
        NextDate: Date;
        NextTime: Time;
    begin
        if NPXmlTemplate."Batch Interval (Days)" + NPXmlTemplate."Batch Interval (Minutes)" = 0 then
          exit(0DT);

        NextDate := CalcDate('<' + Format(NPXmlTemplate."Batch Interval (Days)") + 'D>',Today);
        if NPXmlTemplate."Batch Start Time" <> 0T then
          NextTime := NPXmlTemplate."Batch Start Time"
        else
          NextTime := Time + NPXmlTemplate."Batch Interval (Minutes)" * 60 * 1000;
        exit(CreateDateTime(NextDate,NextTime));
    end;
}

