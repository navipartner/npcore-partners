codeunit 6151512 "NPR NpXml Batch Processing"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        NpXmlTemplate: Record "NPR NpXml Template";
    begin
        if FindNpXmlTemplate(Rec, NpXmlTemplate) then
            ProcessNpXmlBatch(NpXmlTemplate)
        else
            ProcessNpXmlBatches();
    end;

    var
        Text000: Label 'Process NpXml Batches';
        Text001: Label 'All';

    local procedure ProcessNpXmlBatches()
    var
        NpXmlTemplate: Record "NPR NpXml Template";
    begin
        NpXmlTemplate.SetRange("Batch Task", true);
        NpXmlTemplate.SetFilter("Next Batch Run", '<=%1', CurrentDateTime);
        if NpXmlTemplate.FindSet() then
            repeat
                ProcessNpXmlBatch(NpXmlTemplate);
            until NpXmlTemplate.Next() = 0;
    end;

    local procedure ProcessNpXmlBatch(var NpXmlTemplate: Record "NPR NpXml Template")
    begin
        if not Codeunit.run(Codeunit::"NPR NpXml Process Single Batch", NpXmlTemplate) then begin
            NpXmlTemplate."Runtime Error" := true;
            NpXmlTemplate."Last Error Message" := CopyStr(GetLastErrorText, 1, MaxStrLen(NpXmlTemplate.Code));
            NpXmlTemplate.Modify(true);
        end;
        Commit();
    end;

    local procedure FindNpXmlTemplate(JobQueueEntry: Record "Job Queue Entry"; var NpXmlTemplate: Record "NPR NpXml Template"): Boolean
    var
        TemplateCode: Text;
    begin
        Clear(NpXmlTemplate);

        TemplateCode := GetParameterValue(JobQueueEntry, ParamTemplateCode());
        if StrLen(TemplateCode) > MaxStrLen(NpXmlTemplate.Code) then
            exit(false);

        exit(NpXmlTemplate.Get(UpperCase(TemplateCode)));
    end;

    local procedure GetParameterValue(JobQueueEntry: Record "Job Queue Entry"; ParameterName: Text) ParameterValue: Text
    var
        Position: Integer;
    begin
        if ParameterName = '' then
            exit('');

        ParameterValue := JobQueueEntry."Parameter String";
        Position := StrPos(LowerCase(ParameterValue), LowerCase(ParameterName));
        if Position = 0 then
            exit('');

        if Position > 1 then
            ParameterValue := DelStr(ParameterValue, 1, Position - 1);

        ParameterValue := DelStr(ParameterValue, 1, StrLen(ParameterName));
        if ParameterValue = '' then
            exit('');
        if ParameterValue[1] = '=' then
            ParameterValue := DelStr(ParameterValue, 1, 1);

        Position := FindDelimiterPosition(ParameterValue);
        if Position > 0 then
            ParameterValue := DelStr(ParameterValue, Position);

        exit(ParameterValue);
    end;

    local procedure FindDelimiterPosition(ParameterString: Text) Position: Integer
    var
        NewPosition: Integer;
    begin
        if ParameterString = '' then
            exit(0);

        Position := StrPos(ParameterString, ',');

        NewPosition := StrPos(ParameterString, ';');
        if (NewPosition > 0) and ((Position = 0) or (NewPosition < Position)) then
            Position := NewPosition;

        NewPosition := StrPos(ParameterString, '|');
        if (NewPosition > 0) and ((Position = 0) or (NewPosition < Position)) then
            Position := NewPosition;

        exit(Position);
    end;

    [EventSubscriber(ObjectType::Table, 472, 'OnAfterValidateEvent', 'Object ID to Run', true, true)]
    local procedure OnValidateJobQueueEntryObjectIDtoRun(var Rec: Record "Job Queue Entry"; var xRec: Record "Job Queue Entry"; CurrFieldNo: Integer)
    var
        ParameterString: Text;
    begin
        if Rec."Object Type to Run" <> Rec."Object Type to Run"::Codeunit then
            exit;
        if Rec."Object ID to Run" <> CurrCodeunitId() then
            exit;

        ParameterString := ParamTemplateCode() + '=';

        Rec.Validate("Parameter String", CopyStr(ParameterString, 1, MaxStrLen(Rec."Parameter String")));
    end;

    [EventSubscriber(ObjectType::Table, 472, 'OnAfterValidateEvent', 'Parameter String', true, true)]
    local procedure OnValidateJobQueueEntryParameterString(var Rec: Record "Job Queue Entry"; var xRec: Record "Job Queue Entry"; CurrFieldNo: Integer)
    var
        NpXmlTemplate: Record "NPR NpXml Template";
        Description: Text;
    begin
        if Rec."Object Type to Run" <> Rec."Object Type to Run"::Codeunit then
            exit;
        if Rec."Object ID to Run" <> CurrCodeunitId() then
            exit;

        Description := Text000;
        if FindNpXmlTemplate(Rec, NpXmlTemplate) then
            Description += ' | ' + NpXmlTemplate.Code
        else
            Description += ' | {' + Text001 + '}';

        Rec.Description := CopyStr(Description, 1, MaxStrLen(Rec.Description));
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpXml Batch Processing");
    end;

    local procedure ParamTemplateCode(): Text
    begin
        exit('template_code');
    end;

    procedure ScheduleBatchTask(NpXmlTemplate: Record "NPR NpXml Template"; var JobQueueEntry: Record "Job Queue Entry")
    begin
        JobQueueEntry.Init();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := CurrCodeunitId();
        JobQueueEntry.Validate("Parameter String", ParamTemplateCode() + '=' + NpXmlTemplate.Code);
        JobQueueEntry.Status := JobQueueEntry.Status::"On Hold";
        JobQueueEntry.Insert(true);
    end;
}