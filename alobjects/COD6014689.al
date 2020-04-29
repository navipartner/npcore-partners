codeunit 6014689 "Setup NPDeploy Task"
{
    // NPR5.37/MMV /20171006 CASE 286149 Created object
    // NPR5.44/MMV /20180705 CASE 311268 Seperated code into function
    // NPR5.45/MMV /20180810 CASE 311268 Created function SetupNPDeployCredentials()


    trigger OnRun()
    begin
        if not Confirm('Setup NPDeploy callback in Task Queue for the current tenant?\\(This should only be done on the default tenant of a multi tenant database.)') then
          exit;

        SetupNPDeployTask();
        SetupNPDeployCredentials();

        Message('Task setup with template name: %1', 'NPDEPLOY');
    end;

    procedure SetupNPDeployTask()
    var
        TaskLine: Record "Task Line";
        TaskQueue: Record "Task Queue";
        TaskBatch: Record "Task Batch";
        TaskTemplate: Record "Task Template";
        TaskWorkerGroup: Record "Task Worker Group";
        NaviConnectSetup: Record "Nc Setup";
    begin
        TaskWorkerGroup.SetRange(Default, true);
        if not TaskWorkerGroup.FindFirst then begin
          TaskWorkerGroup.Reset;
          TaskWorkerGroup.InsertDefault();
        end;
        TaskWorkerGroup.SetRange(Default, true);
        TaskWorkerGroup.FindFirst;


        TaskTemplate.Init;
        TaskTemplate.Name := 'NPDEPLOY';
        TaskTemplate.Description := 'NPDeploy Callback';
        TaskTemplate."Task Worker Group" := TaskWorkerGroup.Code;
        TaskTemplate.Validate(Type, TaskTemplate.Type::General);
        if not TaskTemplate.Insert(true) then
          TaskTemplate.Modify(true);


        TaskBatch.Init;
        TaskBatch.Validate("Journal Template Name", TaskTemplate.Name);
        TaskBatch.Name := 'NPDEPLOY';
        TaskBatch."Template Type" := TaskBatch."Template Type"::General;
        TaskBatch."Task Worker Group" := TaskWorkerGroup.Code;
        TaskBatch."Delete Log After" := 1000 * 60 * 60 * 24 * 10;
        if not TaskBatch.Insert(true) then
          TaskBatch.Modify(true);


        TaskLine.Init;
        TaskLine."Journal Template Name" := TaskTemplate.Name;
        TaskLine."Journal Batch Name" := TaskBatch.Name;
        TaskLine."Line No." := 10000;
        TaskLine.Description := 'Callback to NPDeploy for dependency deployment';
        TaskLine.Enabled := false;
        TaskLine."Object Type" := TaskLine."Object Type"::Codeunit;
        TaskLine."Object No." := CODEUNIT::"Managed Dependency Mgt.";
        TaskLine."Call Object With Task Record" := false;
        TaskLine.Priority := TaskLine.Priority::Medium;
        TaskLine."Task Worker Group" := TaskWorkerGroup.Code;
        TaskLine.Validate(Recurrence, TaskLine.Recurrence::Daily);
        TaskLine."Recurrence Method" := TaskLine."Recurrence Method"::Static;
        TaskLine."Max No. Of Retries (On Error)" := 3;
        TaskLine."Action After Max. No. of Retri" := TaskLine."Action After Max. No. of Retri"::Reschedule2NextRuntime;
        TaskLine."Valid After" := 010000T;
        TaskLine."Valid Until" := 060000T;
        TaskLine."Run on Monday" := true;
        TaskLine."Run on Tuesday" := true;
        TaskLine."Run on Wednesday" := true;
        TaskLine."Run on Thursday" := true;
        TaskLine."Run on Friday" := true;
        TaskLine."Run on Saturday" := true;
        TaskLine."Run on Sunday" := true;
        if not TaskLine.Insert(true) then
          TaskLine.Modify(true);

        TaskQueue.SetupNewLine(TaskLine, true);
        if not TaskQueue.Insert(true) then
          TaskQueue.Modify(true);

        TaskLine.Validate(Enabled, true);
        TaskLine.Modify(true);
    end;

    procedure SetupNPDeployCredentials()
    var
        InstallManagedDependencies: Codeunit "Install Managed Dependencies";
    begin
        //-NPR5.45 [311268]
        InstallManagedDependencies.InsertSetup();
        //+NPR5.45 [311268]
    end;
}

