codeunit 6151552 "NPR NpXml Batch Mgt."
{
    SingleInstance = true;

    trigger OnRun()
    begin
        RunBatches();
    end;

    var
        NpXmlMgt: Codeunit "NPR NpXml Mgt.";
        BatchStarted: Boolean;
        Error001: Label 'Custom Value has not been set\The Custom Codeunit should invoke SetCustomValue in Codeunit 6151552 NpXml Batch Management';

    procedure CheckRunBatch(NPXmlTemplate: Record "NPR NpXml Template"): Boolean
    var
        RunDatetime: DateTime;
    begin
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
    end;

    [Obsolete('Replaced with Codeunit.run(Codeunit::"NPR NpXml Process Single Batch"...) or RunSingleBatch function')]
    procedure RunBatch(var NPXmlTemplate: Record "NPR NpXml Template")
    begin
        RunSingleBatch(NPXmlTemplate);
    end;

    procedure RunSingleBatch(var NPXmlTemplate: Record "NPR NpXml Template")
    var
        RecRef: RecordRef;
    begin
        NPXmlTemplate.Get(NPXmlTemplate.Code);
        NPXmlTemplate."Batch Last Run" := CurrentDateTime();
        NPXmlTemplate."Next Batch Run" := CalcNextBatchDatetime(NPXmlTemplate);
        NPXmlTemplate."Runtime Error" := true;
        NPXmlTemplate."Last Error Message" := '';
        NPXmlTemplate.Modify(true);
        Commit;

        Clear(NpXmlMgt);
        SetRecRefXmlTemplateFilter(NPXmlTemplate, RecRef);
        NpXmlMgt.Initialize(NPXmlTemplate, RecRef, '', false);
        NpXmlMgt.CreateXml();
        RecRef.Close;

        NPXmlTemplate.Get(NPXmlTemplate.Code);
        NPXmlTemplate."Runtime Error" := false;
        NPXmlTemplate.Modify(true);
    end;

    procedure RunBatches()
    var
        NpXmlTemplate: Record "NPR NpXml Template";
    begin
        Clear(NpXmlTemplate);
        if NpXmlTemplate.FindSet then
            repeat
                BatchStarted := true;
                if CheckRunBatch(NpXmlTemplate) then
                    RunSingleBatch(NpXmlTemplate);
                BatchStarted := false;
            until NpXmlTemplate.Next = 0;
    end;

    local procedure "--- Filter"()
    begin
    end;

    local procedure SetRecRefXmlTemplateFilter(NpXmlTemplate: Record "NPR NpXml Template"; var RecRef: RecordRef)
    var
        NpXmlFilter: Record "NPR NpXml Filter";
        FieldRef: FieldRef;
        BufferDecimal: Decimal;
        BufferInteger: Integer;
    begin
        Clear(RecRef);
        RecRef.Open(NpXmlTemplate."Table No.");
        Clear(NpXmlFilter."Xml Template Code");
        NpXmlFilter.SetRange("Xml Template Code", NpXmlTemplate.Code);
        NpXmlFilter.SetFilter("Xml Element Line No.", '=%1', -1);
        NpXmlFilter.SetRange("Filter Type", NpXmlFilter."Filter Type"::Constant);
        NpXmlFilter.SetFilter("Filter Value", '<>%1', '');
        if NpXmlFilter.FindSet then
            repeat
                FieldRef := RecRef.Field(NpXmlFilter."Parent Field No.");
                case LowerCase(Format(FieldRef.Type)) of
                    'boolean':
                        FieldRef.SetFilter('=%1', LowerCase(NpXmlFilter."Filter Value") in ['1', 'yes', 'ja', 'true']);
                    'integer', 'option':
                        begin
                            if Evaluate(BufferDecimal, NpXmlFilter."Filter Value") then
                                FieldRef.SetRange(BufferDecimal);
                        end;
                    'decimal':
                        begin
                            if Evaluate(BufferInteger, NpXmlFilter."Filter Value") then
                                FieldRef.SetRange(BufferInteger);
                        end;
                    else
                        FieldRef.SetRange(NpXmlFilter."Filter Value");
                end;
            until NpXmlFilter.Next = 0;

        NpXmlFilter.SetRange("Filter Type", NpXmlFilter."Filter Type"::Filter);
        if NpXmlFilter.FindSet then
            repeat
                FieldRef := RecRef.Field(NpXmlFilter."Parent Field No.");
                FieldRef.SetFilter(NpXmlFilter."Filter Value");
            until NpXmlFilter.Next = 0;
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure CalcNextBatchDatetime(NPXmlTemplate: Record "NPR NpXml Template"): DateTime
    var
        NextDate: Date;
        NextTime: Time;
    begin
        if NPXmlTemplate."Batch Interval (Days)" + NPXmlTemplate."Batch Interval (Minutes)" = 0 then
            exit(0DT);

        NextDate := CalcDate('<' + Format(NPXmlTemplate."Batch Interval (Days)") + 'D>', Today);
        if NPXmlTemplate."Batch Start Time" <> 0T then
            NextTime := NPXmlTemplate."Batch Start Time"
        else
            NextTime := Time + NPXmlTemplate."Batch Interval (Minutes)" * 60 * 1000;
        exit(CreateDateTime(NextDate, NextTime));
    end;
}