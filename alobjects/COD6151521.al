codeunit 6151521 "Nc Trigger Scheduler"
{
    // NC2.01/BR /20160809  CASE 247479 NaviConnect: Object created


    trigger OnRun()
    begin
    end;

    local procedure "--- Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6151520, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertNcTriggerInsertTaskLine(var Rec: Record "Nc Trigger";RunTrigger: Boolean)
    begin
        InsertTaskLine(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 6151520, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDeleteNcTriggerDeleteTaskLine(var Rec: Record "Nc Trigger";RunTrigger: Boolean)
    begin
        DeleteTaskLine(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 6151520, 'OnBeforeRenameEvent', '', false, false)]
    local procedure OnBeforeRenameNcTriggerRenameTaskLine(var Rec: Record "Nc Trigger";var xRec: Record "Nc Trigger";RunTrigger: Boolean)
    begin
        RenameTriggerLine(xRec,Rec);
    end;

    [EventSubscriber(ObjectType::Table, 6151520, 'OnBeforeModifyEvent', '', false, false)]
    local procedure OnBeforeModifyNcTriggerModifyTaskLine(var Rec: Record "Nc Trigger";var xRec: Record "Nc Trigger";RunTrigger: Boolean)
    begin
        ModfiyTriggerLine(xRec,Rec);
    end;

    local procedure "--- Database"()
    begin
    end;

    local procedure InsertTaskLine(NcTrigger: Record "Nc Trigger")
    var
        NcTriggerSetup: Record "Nc Trigger Setup";
        NcSetup: Record "Nc Setup";
        TaskLine: Record "Task Line";
        TaskLineParameters: Record "Task Line Parameters";
        LineNo: Integer;
    begin
        GetAndCheckNcTriggerSetup(NcTriggerSetup);
        FilterTaskLines(TaskLine,NcTriggerSetup);
        with TaskLine do begin
          SetRange("Journal Template Name",NcTriggerSetup."Task Template Name");
          SetRange("Journal Batch Name",NcTriggerSetup."Task Batch Name");

          if FindLast then
            LineNo := "Line No." + 10000
          else
            LineNo := 10000;
          Init;
          Validate("Journal Template Name",NcTriggerSetup."Task Template Name");
          Validate("Journal Batch Name",NcTriggerSetup."Task Batch Name");
          Validate("Line No.", LineNo );
          Validate(Description,CopyStr(NcTrigger.Description,1,MaxStrLen(Description)));
          NcSetup.Get;
          NcSetup.TestField("Task Worker Group");
          "Task Worker Group" := NcSetup."Task Worker Group";
          Validate("Call Object With Task Record",true);
          Validate(Enabled,NcTrigger.Enabled);
          Validate("Object Type","Object Type"::Codeunit);
          Validate("Object No.",CODEUNIT::"Nc Trigger Sync. Mgt.");
          SetNextRuntime(CurrentDateTime, false);
          Insert(true);
          InsertParameter(GetParamName,0);
          SetParameterText(GetParamName,NcTrigger.Code);
        end;
    end;

    local procedure DeleteTaskLine(NcTrigger: Record "Nc Trigger")
    var
        NcTriggerSetup: Record "Nc Trigger Setup";
        TaskLine: Record "Task Line";
        TaskLineParam: Record "Task Line Parameters";
    begin
        NcTriggerSetup.Get;
        if not FindTaskLine(NcTrigger,TaskLine,TaskLineParam) then
          exit;
        TaskLine.Delete(true);
    end;

    local procedure RenameTriggerLine(xRecNcTrigger: Record "Nc Trigger";NcTrigger: Record "Nc Trigger")
    var
        NcTriggerSetup: Record "Nc Trigger Setup";
        TaskLine: Record "Task Line";
        TaskLineParam: Record "Task Line Parameters";
    begin
        NcTriggerSetup.Get;
        if not FindTaskLine(xRecNcTrigger,TaskLine,TaskLineParam) then
          exit;
        TaskLineParam.Value := NcTrigger.Code;
        TaskLineParam.Modify(true);
    end;

    local procedure ModfiyTriggerLine(xRecNcTrigger: Record "Nc Trigger";NcTrigger: Record "Nc Trigger")
    var
        NcTriggerSetup: Record "Nc Trigger Setup";
        TaskLine: Record "Task Line";
        TaskLineParam: Record "Task Line Parameters";
    begin
        NcTriggerSetup.Get;
        if not FindTaskLine(xRecNcTrigger,TaskLine,TaskLineParam) then
          exit;
        TaskLine.Description := NcTrigger.Description;
        TaskLine.Validate(Enabled,NcTrigger.Enabled);
        TaskLine.Modify(true);
    end;

    local procedure "--- Helpers"()
    begin
    end;

    local procedure GetAndCheckNcTriggerSetup(var NcTriggerSetup: Record "Nc Trigger Setup")
    var
        NcSetup: Record "Nc Setup";
        NcSetupMgt: Codeunit "Nc Setup Mgt.";
    begin
        if not NcTriggerSetup.Get then begin
          NcSetup.Get;
          if not NcSetup."Task Queue Enabled" then
            exit;
          NcSetupMgt.SetupTaskQueue;
          NcTriggerSetup.Validate("Task Template Name",NcSetup."Task Worker Group");
          NcTriggerSetup.Validate("Task Batch Name",NcSetup."Task Worker Group");
          NcTriggerSetup.Insert(true);
        end;
        NcTriggerSetup.TestField("Task Template Name");
        NcTriggerSetup.TestField("Task Batch Name");
    end;

    local procedure FilterTaskLines(var TaskLine: Record "Task Line";NcTriggerSetup: Record "Nc Trigger Setup")
    begin
        TaskLine.Reset;
        TaskLine.SetRange("Journal Template Name",NcTriggerSetup."Task Template Name");
        TaskLine.SetRange("Journal Batch Name",NcTriggerSetup."Task Batch Name");
    end;

    procedure FindTaskLine(NcTrigger: Record "Nc Trigger";var TaskLine: Record "Task Line";var TaskLineParam: Record "Task Line Parameters"): Boolean
    var
        NcTriggerSetup: Record "Nc Trigger Setup";
    begin
        NcTriggerSetup.Get;
        FilterTaskLines(TaskLine,NcTriggerSetup);
        if TaskLine.FindSet then repeat
          TaskLineParam.SetRange("Journal Template Name", TaskLine."Journal Template Name");
          TaskLineParam.SetRange("Journal Batch Name", TaskLine."Journal Batch Name");
          TaskLineParam.SetRange("Journal Line No.", TaskLine."Line No.");
          TaskLineParam.SetRange("Field Code", GetParamName);
          TaskLineParam.SetRange(Value,NcTrigger.Code);
          if TaskLineParam.FindFirst then
            exit(true);
        until TaskLine.Next = 0;
        exit(false);
    end;

    local procedure "--- Constants"()
    begin
    end;

    procedure GetParamName(): Text
    begin
        exit('NCTRIG');
    end;
}

