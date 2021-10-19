codeunit 6151521 "NPR Nc Trigger Scheduler"
{
    [EventSubscriber(ObjectType::Table, Database::"NPR Nc Trigger", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertNcTriggerInsertTaskLine(var Rec: Record "NPR Nc Trigger"; RunTrigger: Boolean)
    begin
        InsertTaskLine(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Nc Trigger", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDeleteNcTriggerDeleteTaskLine(var Rec: Record "NPR Nc Trigger"; RunTrigger: Boolean)
    begin
        DeleteTaskLine(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Nc Trigger", 'OnBeforeRenameEvent', '', false, false)]
    local procedure OnBeforeRenameNcTriggerRenameTaskLine(var Rec: Record "NPR Nc Trigger"; var xRec: Record "NPR Nc Trigger"; RunTrigger: Boolean)
    begin
        RenameTriggerLine(xRec, Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Nc Trigger", 'OnBeforeModifyEvent', '', false, false)]
    local procedure OnBeforeModifyNcTriggerModifyTaskLine(var Rec: Record "NPR Nc Trigger"; var xRec: Record "NPR Nc Trigger"; RunTrigger: Boolean)
    begin
        ModfiyTriggerLine(xRec, Rec);
    end;

    local procedure InsertTaskLine(NcTrigger: Record "NPR Nc Trigger")
    var
        NcTriggerSetup: Record "NPR Nc Trigger Setup";
        NcSetup: Record "NPR Nc Setup";
        TaskLine: Record "NPR Task Line";
        LineNo: Integer;
    begin
        GetAndCheckNcTriggerSetup(NcTriggerSetup);
        FilterTaskLines(TaskLine, NcTriggerSetup);
        TaskLine.SetRange("Journal Template Name", NcTriggerSetup."Task Template Name");
        TaskLine.SetRange("Journal Batch Name", NcTriggerSetup."Task Batch Name");

        if TaskLine.FindLast() then
            LineNo := TaskLine."Line No." + 10000
        else
            LineNo := 10000;
        TaskLine.Init();
        TaskLine.Validate("Journal Template Name", NcTriggerSetup."Task Template Name");
        TaskLine.Validate("Journal Batch Name", NcTriggerSetup."Task Batch Name");
        TaskLine.Validate("Line No.", LineNo);
        TaskLine.Validate(Description, CopyStr(NcTrigger.Description, 1, MaxStrLen(TaskLine.Description)));
        NcSetup.Get();
        NcSetup.TestField("Task Worker Group");
        TaskLine."Task Worker Group" := NcSetup."Task Worker Group";
        TaskLine.Validate("Call Object With Task Record", true);
        TaskLine.Validate(Enabled, NcTrigger.Enabled);
        TaskLine.Validate("Object Type", TaskLine."Object Type"::Codeunit);
        TaskLine.Validate("Object No.", CODEUNIT::"NPR Nc Trigger Sync. Mgt.");
        TaskLine.SetNextRuntime(CurrentDateTime, false);
        TaskLine.Insert(true);
        TaskLine.InsertParameter(GetParamName(), 0);
        TaskLine.SetParameterText(GetParamName(), NcTrigger.Code);
    end;

    local procedure DeleteTaskLine(NcTrigger: Record "NPR Nc Trigger")
    var
        NcTriggerSetup: Record "NPR Nc Trigger Setup";
        TaskLine: Record "NPR Task Line";
        TaskLineParam: Record "NPR Task Line Parameters";
    begin
        NcTriggerSetup.Get();
        if not FindTaskLine(NcTrigger, TaskLine, TaskLineParam) then
            exit;
        TaskLine.Delete(true);
    end;

    local procedure RenameTriggerLine(xRecNcTrigger: Record "NPR Nc Trigger"; NcTrigger: Record "NPR Nc Trigger")
    var
        NcTriggerSetup: Record "NPR Nc Trigger Setup";
        TaskLine: Record "NPR Task Line";
        TaskLineParam: Record "NPR Task Line Parameters";
    begin
        NcTriggerSetup.Get();
        if not FindTaskLine(xRecNcTrigger, TaskLine, TaskLineParam) then
            exit;
        TaskLineParam.Value := NcTrigger.Code;
        TaskLineParam.Modify(true);
    end;

    local procedure ModfiyTriggerLine(xRecNcTrigger: Record "NPR Nc Trigger"; NcTrigger: Record "NPR Nc Trigger")
    var
        NcTriggerSetup: Record "NPR Nc Trigger Setup";
        TaskLine: Record "NPR Task Line";
        TaskLineParam: Record "NPR Task Line Parameters";
    begin
        NcTriggerSetup.Get();
        if not FindTaskLine(xRecNcTrigger, TaskLine, TaskLineParam) then
            exit;
        TaskLine.Description := NcTrigger.Description;
        TaskLine.Validate(Enabled, NcTrigger.Enabled);
        TaskLine.Modify(true);
    end;

    local procedure GetAndCheckNcTriggerSetup(var NcTriggerSetup: Record "NPR Nc Trigger Setup")
    var
        NcSetup: Record "NPR Nc Setup";
        NcSetupMgt: Codeunit "NPR Nc Setup Mgt.";
    begin
        if not NcTriggerSetup.Get() then begin
            NcSetup.Get();
            if not NcSetup."Task Queue Enabled" then
                exit;
            NcSetupMgt.SetupTaskQueue();
            NcTriggerSetup.Validate("Task Template Name", NcSetup."Task Worker Group");
            NcTriggerSetup.Validate("Task Batch Name", NcSetup."Task Worker Group");
            NcTriggerSetup.Insert(true);
        end;
        NcTriggerSetup.TestField("Task Template Name");
        NcTriggerSetup.TestField("Task Batch Name");
    end;

    local procedure FilterTaskLines(var TaskLine: Record "NPR Task Line"; NcTriggerSetup: Record "NPR Nc Trigger Setup")
    begin
        TaskLine.Reset();
        TaskLine.SetRange("Journal Template Name", NcTriggerSetup."Task Template Name");
        TaskLine.SetRange("Journal Batch Name", NcTriggerSetup."Task Batch Name");
    end;

    procedure FindTaskLine(NcTrigger: Record "NPR Nc Trigger"; var TaskLine: Record "NPR Task Line"; var TaskLineParam: Record "NPR Task Line Parameters"): Boolean
    var
        NcTriggerSetup: Record "NPR Nc Trigger Setup";
    begin
        NcTriggerSetup.Get();
        FilterTaskLines(TaskLine, NcTriggerSetup);
        if TaskLine.FindSet() then
            repeat
                TaskLineParam.SetRange("Journal Template Name", TaskLine."Journal Template Name");
                TaskLineParam.SetRange("Journal Batch Name", TaskLine."Journal Batch Name");
                TaskLineParam.SetRange("Journal Line No.", TaskLine."Line No.");
                TaskLineParam.SetRange("Field Code", GetParamName());
                TaskLineParam.SetRange(Value, NcTrigger.Code);
                if TaskLineParam.FindFirst() then
                    exit(true);
            until TaskLine.Next() = 0;
        exit(false);
    end;

    procedure GetParamName(): Text
    begin
        exit('NCTRIG');
    end;
}

