codeunit 6151500 "Nc Setup Mgt."
{
    // NC1.17/MH/20150619  CASE 216851 Object created - Connects Magento with NaviConnect and NpXml
    // NC1.19/MH/20150729  CASE 217576 NAV Version omitted from Addins in SetupClientAddIns()
    // NC1.20/TS/20150804 CASE 219614 Added Function CutVersionNo() and GetVersionNo()
    // NC1.20/MH/20150810  CASE 220153 DragDropPicture 1.02 update
    // NC1.20/MH/20151008  CASE 224793 Added missing interval parameters to setup of Task Queue Daily tasks
    // NC1.20/MH/20151009  CASE 218525 NaviConnect Webservices added
    // NC1.21/MHA/20151118 CASE 223835 Type deleted from Picture Link
    // NC1.22/MHA/20160107 CASE 230240 DragDropPicture 1.03 update - Resize removed
    // NC1.22/MHA/20160427 CASE 240212 SetupNaviConnect() function deleted as functionality as been split into individual Actions
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect
    // NC2.10/TS /20180122  CASE 303070 Added Setup Clean up DataLog
    // NC2.13/TS  /20180510  CASE 314527 Always check for Line No before inserting.
    // NC2.14/MHA /20180702  CASE 321096 Increased Length of return value from 10 to 20 in GetImportTypeCode()


    trigger OnRun()
    begin
    end;

    var
        Text001: Label 'Source Card has not been activated for Table %1';
        NaviConnectSetup: Record "Nc Setup";
        Text10000: Label 'Check Payment Mapping?';
        Text10010: Label 'Check Shipment Mapping?';
        Text10020: Label 'Check VAT Business Posting Groups?';
        Text10030: Label 'Check VAT Product Posting Groups?';

    procedure InitNaviConnectSetup()
    begin
        if not NaviConnectSetup.Get then begin
          NaviConnectSetup.Init;
          NaviConnectSetup.Insert;
        end;

        NaviConnectSetup."Keep Tasks for" := CreateDateTime(Today,000000T) - CreateDateTime(CalcDate('<-7D>',Today),000000T);
        NaviConnectSetup."Task Worker Group" := 'NC';
        //-NC2.00
        //NaviConnectSetup."Default Import Codeunit Id" := CODEUNIT::"NaviConnect Sales Order Mgt.";
        //NaviConnectSetup."Default Lookup Codeunit Id" := CODEUNIT::"NaviConnect Lookup Sales Order";
        //+NC2.00
        NaviConnectSetup.Modify(true);
    end;

    procedure SetupTaskQueue()
    var
        SyncMgt: Codeunit "Nc Sync. Mgt.";
        TaskCode: Code[10];
        TaskDescription: Text[50];
        TaskLineNo: Integer;
        DeleteOldEntries: Codeunit "Delete Old Entries";
        TaskLine: Record "Task Line";
    begin
        NaviConnectSetup.Get;
        if not NaviConnectSetup."Task Queue Enabled" then
          exit;
        TaskCode := NaviConnectSetup."Task Worker Group";
        TaskDescription := 'NaviConnect';

        SetupTaskWorkerGroup(TaskCode,TaskDescription);
        SetupTaskTemplate(TaskCode,TaskDescription,TaskCode);
        SetupTaskBatch(TaskCode,TaskCode,TaskDescription,TaskCode);

        //-NC2.13 [314527]
        //TaskLineNo := 20000;
        FindLineNo(TaskCode,TaskCode,TaskDescription + ' Process Tasks',TaskLineNo);
        //+NC2.13 [314527]
        SetupTaskLineMinute(TaskCode,TaskCode,TaskLineNo,TaskDescription + ' Process Tasks',TaskCode);
        SetupTaskLineParameterBool(TaskCode,TaskCode,TaskLineNo,SyncMgt."Parameter.ProcessTasks",true);
        SetupTaskLineParameterInt(TaskCode,TaskCode,TaskLineNo,SyncMgt."Parameter.TaskRetryCount",3);
        SetupTaskLineParameterBool(TaskCode,TaskCode,TaskLineNo,SyncMgt."Parameter.ImportNewTasks",true);
        SetTaskLineEnabled(TaskCode,TaskCode,TaskLineNo,NaviConnectSetup."Task Queue Enabled");

        //-NC2.13 [314527]
        //TaskLineNo := 40000;
        FindLineNo(TaskCode,TaskCode,TaskDescription + ' Reset Task Count',TaskLineNo);
        //+NC2.13 [314527]
        SetupTaskLineDay(TaskCode,TaskCode,TaskLineNo,TaskDescription + ' Reset Task Count',TaskCode);
        SetupTaskLineParameterBool(TaskCode,TaskCode,TaskLineNo,SyncMgt."Parameter.ResetTaskCount",true);
        SetTaskLineEnabled(TaskCode,TaskCode,TaskLineNo,NaviConnectSetup."Task Queue Enabled");

        //-NC2.10 [303070]
        //-NC2.13 [314527]
        //TaskLineNo := 60000;
        FindLineNo(TaskCode,TaskCode,TaskDescription + ' Delete Old Entries',TaskLineNo);
        //+NC2.13 [314527]
        SetupCleanUpTask(TaskCode,TaskCode,TaskLineNo,TaskDescription + ' Delete Old Entries',TaskCode);
        SetupTaskLineParameterBool(TaskCode,TaskCode,TaskLineNo,'DEL DATA LOG',true);
        SetTaskLineEnabled(TaskCode,TaskCode,TaskLineNo,NaviConnectSetup."Task Queue Enabled");
        //+NC2.10 [303070]
    end;

    local procedure "--- Task Queue Setup"()
    begin
    end;

    local procedure SetTaskLineEnabled(TemplateName: Code[10];BatchName: Code[10];LineNo: Integer;Enabled: Boolean)
    var
        TaskLine: Record "Task Line";
        TaskQueue: Record "Task Queue";
    begin
        if TaskLine.Get(TemplateName,BatchName,LineNo) and (TaskLine.Enabled <> Enabled) then begin
          if Enabled then
            if not TaskQueue.Get(CompanyName,TemplateName,BatchName,LineNo) then begin
              TaskQueue.SetupNewLine(TaskLine,false);
              TaskQueue."Next Run time" := CurrentDateTime;
              TaskQueue.Insert;
            end else begin
              TaskQueue."Next Run time" := CurrentDateTime;
              TaskQueue.Modify;
            end;
          TaskLine.Validate(Enabled,Enabled);
          TaskLine.Modify(true);
        end;
    end;

    local procedure SetupTaskWorkerGroup(GroupCode: Code[10];GroupDescription: Text[50])
    var
        TaskWorkerGroup: Record "Task Worker Group";
    begin
        if not TaskWorkerGroup.Get(GroupCode) then begin
          TaskWorkerGroup.Init;
          TaskWorkerGroup.Code := GroupCode;
          TaskWorkerGroup.Description := GroupDescription;
          TaskWorkerGroup.Validate("Language ID",1033);
          TaskWorkerGroup."Min Interval Between Check" := 10 * 1000;
          TaskWorkerGroup."Max Interval Between Check" := 60 * 1000;
          TaskWorkerGroup."Max. Concurrent Threads" := 1;
          TaskWorkerGroup.Insert(true);
        end;
    end;

    local procedure SetupTaskTemplate(TemplateName: Code[10];TemplateDescription: Text[50];GroupCode: Code[10])
    var
        TaskTemplate: Record "Task Template";
    begin
        if not TaskTemplate.Get(TemplateName) then begin
          TaskTemplate.Init;
          TaskTemplate.Name := TemplateName;
          TaskTemplate.Description := TemplateDescription;
          TaskTemplate."Page ID" := PAGE::"Task Journal";
          TaskTemplate.Type := TaskTemplate.Type::General;
          TaskTemplate."Task Worker Group" := GroupCode;
          TaskTemplate.Insert(true);
        end;
    end;

    local procedure SetupTaskBatch(TemplateName: Code[10];BatchName: Code[10];BatchDescription: Text[50];GroupCode: Code[10])
    var
        TaskBatch: Record "Task Batch";
    begin
        if not TaskBatch.Get(TemplateName,BatchName) then begin
          TaskBatch.Init;
          TaskBatch."Journal Template Name" := TemplateName;
          TaskBatch.Name := BatchName;
          TaskBatch.Description := BatchDescription;
          TaskBatch."Task Worker Group" := GroupCode;
          TaskBatch."Template Type" := TaskBatch."Template Type"::General;
          TaskBatch.Insert(true);
        end;
    end;

    local procedure SetupTaskLineMinute(TemplateName: Code[10];BatchName: Code[10];LineNo: Integer;TaskDescription: Text[50];GroupCode: Code[10])
    var
        TaskLine: Record "Task Line";
    begin
        if not TaskLine.Get(TemplateName,BatchName,LineNo) then begin
          TaskLine.Init;
          TaskLine."Journal Template Name" := TemplateName;
          TaskLine."Journal Batch Name" := BatchName;
          TaskLine."Line No." := LineNo;
          TaskLine.Description := TaskDescription;
          TaskLine.Enabled := false;
          TaskLine."Object Type" := TaskLine."Object Type"::Codeunit;
          //-NC2.00
          //TaskLine."Object No." := CODEUNIT::"NaviConnect Sync. Mgt.";
          TaskLine."Object No." := CODEUNIT::"Nc Sync. Mgt.";
          //+NC2.00
          TaskLine."Call Object With Task Record" := true;
          TaskLine.Priority := TaskLine.Priority::Medium;
          TaskLine."Task Worker Group" := GroupCode;
          TaskLine.Recurrence := TaskLine.Recurrence::Custom;
          TaskLine."Recurrence Interval" := 60 * 1000;
          TaskLine."Recurrence Method" := TaskLine."Recurrence Method"::Static;
          TaskLine."Recurrence Calc. Interval" := 0;
          TaskLine."Run on Monday" := true;
          TaskLine."Run on Tuesday" := true;
          TaskLine."Run on Wednesday" := true;
          TaskLine."Run on Thursday" := true;
          TaskLine."Run on Friday" := true;
          TaskLine."Run on Saturday" := true;
          TaskLine."Run on Sunday" := true;
          TaskLine.Insert(true);
        end;
    end;

    local procedure SetupTaskLineDay(TemplateName: Code[10];BatchName: Code[10];LineNo: Integer;TaskDescription: Text[50];GroupCode: Code[10])
    var
        TaskLine: Record "Task Line";
    begin
        if not TaskLine.Get(TemplateName,BatchName,LineNo) then begin
          TaskLine.Init;
          TaskLine."Journal Template Name" := TemplateName;
          TaskLine."Journal Batch Name" := BatchName;
          TaskLine."Line No." := LineNo;
          TaskLine.Description := TaskDescription;
          TaskLine.Enabled := false;
          TaskLine."Object Type" := TaskLine."Object Type"::Codeunit;
          //-NC2.00
          //TaskLine."Object No." := CODEUNIT::"NaviConnect Sync. Mgt.";
          TaskLine."Object No." := CODEUNIT::"Nc Sync. Mgt.";
          //+NC2.00
          TaskLine."Call Object With Task Record" := true;
          TaskLine.Priority := TaskLine.Priority::Medium;
          TaskLine."Task Worker Group" := GroupCode;
          //-NC1.20
          //TaskLine.Recurrence := TaskLine.Recurrence::DateFormula;
          //TaskLine."Recurrence Method" := TaskLine."Recurrence Method"::Dynamic;
          //TaskLine."Recurrence Time" := 235900T;
          TaskLine.Recurrence := TaskLine.Recurrence::Daily;
          TaskLine."Recurrence Interval" := CreateDateTime(Today,000000T) - CreateDateTime(CalcDate('<-1D>',Today),000000T);
          TaskLine."Recurrence Calc. Interval" := 1000 * 60 * 60;
          TaskLine."Valid After" := 235900T;
          TaskLine."Valid Until" := 060000T;
          //+NC1.20
          TaskLine."Run on Monday" := true;
          TaskLine."Run on Tuesday" := true;
          TaskLine."Run on Wednesday" := true;
          TaskLine."Run on Thursday" := true;
          TaskLine."Run on Friday" := true;
          TaskLine."Run on Saturday" := true;
          TaskLine."Run on Sunday" := true;
          TaskLine.Insert(true);
        end;
    end;

    local procedure SetupTaskLineParameterBool(TemplateName: Code[10];BatchName: Code[10];LineNo: Integer;ParameterName: Code[20];ParameterValue: Boolean)
    var
        TaskLine: Record "Task Line";
        TaskLineParam: Record "Task Line Parameters";
    begin
        if TaskLine.Get(TemplateName,BatchName,LineNo) then begin
          TaskLine.GetParameterBool(ParameterName);
          TaskLine.SetParameterBool(ParameterName,ParameterValue);
        end;
    end;

    local procedure SetupTaskLineParameterInt(TemplateName: Code[10];BatchName: Code[10];LineNo: Integer;ParameterName: Code[20];ParameterValue: Integer)
    var
        TaskLine: Record "Task Line";
        TaskLineParam: Record "Task Line Parameters";
    begin
        if TaskLine.Get(TemplateName,BatchName,LineNo) then begin
          TaskLine.GetParameterInt(ParameterName);
          TaskLine.SetParameterInt(ParameterName,ParameterValue);
        end;
    end;

    local procedure SetupCleanUpTask(TemplateName: Code[10];BatchName: Code[10];LineNo: Integer;TaskDescription: Text[50];GroupCode: Code[10])
    var
        TaskLine: Record "Task Line";
    begin
        //-NC2.10 [303070]
        if not TaskLine.Get(TemplateName,BatchName,LineNo) then begin
          TaskLine.Init;
          TaskLine."Journal Template Name" := TemplateName;
          TaskLine."Journal Batch Name" := BatchName;
          TaskLine."Line No." := LineNo;
          TaskLine.Description := TaskDescription;
          TaskLine.Enabled := false;
          TaskLine."Object Type" := TaskLine."Object Type"::Codeunit;
          TaskLine."Object No." := CODEUNIT::"Delete Old Entries";
          TaskLine."Call Object With Task Record" := true;
          TaskLine.Priority := TaskLine.Priority::Medium;
          TaskLine."Task Worker Group" := GroupCode;
          TaskLine.Recurrence := TaskLine.Recurrence::Custom;
          TaskLine."Recurrence Interval" := CreateDateTime(Today,000000T) - CreateDateTime(CalcDate('<-7D>',Today),000000T);
          TaskLine."Recurrence Calc. Interval" := 1000 * 60 * 60;
          TaskLine."Valid After" := 235900T;
          TaskLine."Valid Until" := 060000T;
          TaskLine."Run on Monday" := true;
          TaskLine."Run on Tuesday" := true;
          TaskLine."Run on Wednesday" := true;
          TaskLine."Run on Thursday" := true;
          TaskLine."Run on Friday" := true;
          TaskLine."Run on Saturday" := true;
          TaskLine."Run on Sunday" := true;
          TaskLine.Insert(true);
        end;
        //-NC2.10 [303070]
    end;

    procedure "--- Aux"()
    begin
    end;

    procedure GetImportTypeCode(WebServiceCodeunitID: Integer;WebserviceFunction: Text): Code[20]
    var
        ImportType: Record "Nc Import Type";
        Text1: Text;
    begin
        //-NC1.21
        Clear(ImportType);
        ImportType.SetRange("Webservice Codeunit ID",WebServiceCodeunitID);
        //-NC1.22
        //ImportType.SETFILTER("Webservice Function",'@%1',COPYSTR(WebserviceFunction,1,MAXSTRLEN(ImportType."Webservice Function")));
        //IF ImportType.FINDFIRST THEN
        //  EXIT(ImportType.Code);
        //ImportType.SETRANGE("Webservice Function");
        ImportType.SetFilter("Webservice Function",'%1',CopyStr('@' + WebserviceFunction,1,MaxStrLen(ImportType."Webservice Function")));
        //+NC1.22
        if ImportType.FindFirst then
          exit(ImportType.Code);

        exit('');
        //+NC1.21
    end;

    local procedure "----"()
    begin
    end;

    local procedure FindLineNo(TemplateName: Code[10];BatchName: Code[10];TaskDescription: Text;var LineNo: Integer)
    var
        TaskLine: Record "Task Line";
    begin
        //-NC2.13 [314527]
        TaskLine.SetRange("Journal Template Name",TemplateName);
        TaskLine.SetRange("Journal Batch Name",BatchName);
        TaskLine.SetRange(Description,TaskDescription);
        if TaskLine.FindLast then;
        LineNo := TaskLine."Line No." + 10000;
        //+NC2.13 [314527]
    end;
}

