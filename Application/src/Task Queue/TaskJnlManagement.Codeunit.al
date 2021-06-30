codeunit 6059900 "NPR Task Jnl. Management"
{
    // TQ1.19/JDH/20141203 CASE 199066 Multicompany handling extended
    // TQ1.27/JDH/20150701 CASE 217903 Deleted unused Variables and fields
    // TQ1.28/MHA/20151216  CASE 229609 Task Queue

    Permissions = TableData "Job Journal Template" = imd,
                  TableData "Job Journal Batch" = imd;

    trigger OnRun()
    begin
    end;

    var
        Text001: Label '%1 Journal';
        Text004: Label 'DEFAULT';
        Text005: Label 'Default Journal';
        OpenFromBatch: Boolean;
        Text006: Label 'Do you wish to Syncronize %1 to all companies?';
        Text007: Label 'There is no %1 set for this Task';
        Text008: Label 'Syncronizing Company #1#################';

    procedure TemplateSelection(PageID: Integer; PageTemplate: Option General,NaviPartner; var TaskJnlLine: Record "NPR Task Line"; var JnlSelected: Boolean)
    var
        TaskJnlTemplate: Record "NPR Task Template";
    begin
        JnlSelected := true;

        TaskJnlTemplate.Reset();
        TaskJnlTemplate.SetRange("Page ID", PageID);
        TaskJnlTemplate.SetRange(Type, PageTemplate);

        case TaskJnlTemplate.Count() of
            0:
                begin
                    TaskJnlTemplate.Init();
                    TaskJnlTemplate.Type := PageTemplate;
                    TaskJnlTemplate.Name := Format(TaskJnlTemplate.Type, MaxStrLen(TaskJnlTemplate.Name));
                    TaskJnlTemplate.Description := StrSubstNo(Text001, TaskJnlTemplate.Type);
                    TaskJnlTemplate.Validate("Page ID");
                    TaskJnlTemplate.Insert();
                    Commit();
                end;
            1:
                TaskJnlTemplate.Find('-');
            else
                JnlSelected := PAGE.RunModal(0, TaskJnlTemplate) = ACTION::LookupOK;
        end;
        if JnlSelected then begin
            TaskJnlLine.FilterGroup := 2;
            TaskJnlLine.SetRange("Journal Template Name", TaskJnlTemplate.Name);
            TaskJnlLine.FilterGroup := 0;
            if OpenFromBatch then begin
                TaskJnlLine."Journal Template Name" := '';
                PAGE.Run(TaskJnlTemplate."Page ID", TaskJnlLine);
            end;
        end;
    end;

    procedure OpenJnl(var CurrentJnlBatchName: Code[10]; var TaskJnlLine: Record "NPR Task Line")
    begin
        CheckTemplateName(TaskJnlLine.GetRangeMax("Journal Template Name"), CurrentJnlBatchName);
        TaskJnlLine.FilterGroup := 2;
        TaskJnlLine.SetRange("Journal Batch Name", CurrentJnlBatchName);
        TaskJnlLine.FilterGroup := 0;
    end;

    procedure CheckTemplateName(CurrentJnlTemplateName: Code[10]; var CurrentJnlBatchName: Code[10])
    var
        TaskJnlBatch: Record "NPR Task Batch";
    begin
        TaskJnlBatch.SetRange("Journal Template Name", CurrentJnlTemplateName);
        if not TaskJnlBatch.Get(CurrentJnlTemplateName, CurrentJnlBatchName) then begin
            if not TaskJnlBatch.Find('-') then begin
                TaskJnlBatch.Init();
                TaskJnlBatch."Journal Template Name" := CurrentJnlTemplateName;
                TaskJnlBatch.SetupNewBatch();
                TaskJnlBatch.Name := Text004;
                TaskJnlBatch.Description := Text005;
                TaskJnlBatch.Insert(true);
                Commit();
            end;
            CurrentJnlBatchName := TaskJnlBatch.Name;
        end;
    end;

    procedure CheckName(CurrentJnlBatchName: Code[10]; var TaskJnlLine: Record "NPR Task Line")
    var
        TaskJnlBatch: Record "NPR Task Batch";
    begin
        TaskJnlBatch.Get(TaskJnlLine.GetRangeMax("Journal Template Name"), CurrentJnlBatchName);
    end;

    procedure SetName(CurrentJnlBatchName: Code[10]; var TaskJnlLine: Record "NPR Task Line")
    begin
        TaskJnlLine.FilterGroup := 2;
        TaskJnlLine.SetRange("Journal Batch Name", CurrentJnlBatchName);
        TaskJnlLine.FilterGroup := 0;
        if TaskJnlLine.Find('-') then;
    end;

    procedure LookupName(var CurrentJnlBatchName: Code[10]; var TaskJnlLine: Record "NPR Task Line"): Boolean
    var
        TaskJnlBatch: Record "NPR Task Batch";
    begin
        Commit();
        TaskJnlBatch."Journal Template Name" := TaskJnlLine.GetRangeMax("Journal Template Name");
        TaskJnlBatch.Name := TaskJnlLine.GetRangeMax("Journal Batch Name");
        TaskJnlBatch.FilterGroup(2);
        TaskJnlBatch.SetRange("Journal Template Name", TaskJnlBatch."Journal Template Name");
        TaskJnlBatch.FilterGroup(0);
        if PAGE.RunModal(0, TaskJnlBatch) = ACTION::LookupOK then begin
            CurrentJnlBatchName := TaskJnlBatch.Name;
            SetName(CurrentJnlBatchName, TaskJnlLine);
        end;
    end;

    procedure SyncroniseCompanies(TaskLine: Record "NPR Task Line"; ChangeType: Option Insert,Modify,Delete,Rename)
    var
        TaskBatch: Record "NPR Task Batch";
        Comp: Record Company;
        TaskBatch2: Record "NPR Task Batch";
        TaskLine2: Record "NPR Task Line";
        SyncNextExecuteTime: Boolean;
        SyncParms: Boolean;
        TaskQueue: Record "NPR Task Queue";
        TaskQueue2: Record "NPR Task Queue";
        TaskLog2: Record "NPR Task Log (Task)";
        TaskOutputLog2: Record "NPR Task Output Log";
        TaskLineParm2: Record "NPR Task Line Parameters";
        TaskLineParm: Record "NPR Task Line Parameters";
        Dia: Dialog;
    begin
        //TQ1.06-
        TaskBatch.Get(TaskLine."Journal Template Name", TaskLine."Journal Batch Name");
        if not TaskBatch."Common Companies" then
            exit;

        TaskBatch.TestField("Master Company", CompanyName);

        //-TQ1.19
        if GuiAllowed then begin
            SyncNextExecuteTime := Confirm(Text006, false, TaskQueue.FieldCaption("Next Run time"));
            if SyncNextExecuteTime then begin
                if not TaskQueue.Get(CompanyName, TaskLine."Journal Template Name", TaskLine."Journal Batch Name", TaskLine."Line No.") then
                    Error(Text007, TaskQueue.FieldCaption("Next Run time"));
            end;
            SyncParms := Confirm(Text006, false, TaskLineParm.TableCaption);
            Dia.Open(Text008);
        end;
        //+TQ1.19

        Comp.SetFilter(Name, '<>%1', CompanyName);
        if Comp.FindSet() then
            repeat
                //-TQ1.19
                if GuiAllowed then
                    Dia.Update(1, Comp.Name);
                //+TQ1.19
                TaskBatch2.ChangeCompany(Comp.Name);
                if TaskBatch2.Get(TaskBatch."Journal Template Name", TaskBatch.Name) then begin
                    case ChangeType of
                        ChangeType::Insert:
                            begin
                                TaskLine2.ChangeCompany(Comp.Name);
                                TaskLine2 := TaskLine;
                                if not TaskLine2.Insert(false) then
                                    TaskLine2.Modify(false);
                            end;
                        ChangeType::Modify:
                            begin
                                TaskLine2.ChangeCompany(Comp.Name);
                                //-TQ1.19
                                //TaskLine2 := TaskLine;
                                //IF NOT TaskLine2.MODIFY(FALSE) THEN
                                //  TaskLine2.INSERT(FALSE);
                                if TaskLine2.Get(TaskLine."Journal Template Name", TaskLine."Journal Batch Name", TaskLine."Line No.") then begin
                                    TaskLine2.TransferFields(TaskLine, false);
                                    TaskLine2.Modify();
                                end else begin
                                    TaskLine2.TransferFields(TaskLine, true);
                                    TaskLine2.Insert();
                                end;

                                if SyncNextExecuteTime then begin
                                    if not TaskQueue2.Get(Comp.Name, TaskQueue."Task Template", TaskQueue."Task Batch", TaskQueue."Task Line No.") then begin
                                        TaskQueue2 := TaskQueue;
                                        TaskQueue2.Company := Comp.Name;
                                        TaskQueue2.Insert();
                                    end else begin
                                        TaskQueue2.TransferFields(TaskQueue, false);
                                        TaskQueue2.Modify();
                                    end;
                                end;

                                if SyncParms then begin
                                    TaskLineParm2.ChangeCompany(Comp.Name);
                                    TaskLineParm.SetRange("Journal Template Name", TaskLine."Journal Template Name");
                                    TaskLineParm.SetRange("Journal Batch Name", TaskLine."Journal Batch Name");
                                    TaskLineParm.SetRange("Journal Line No.", TaskLine."Line No.");
                                    if TaskLineParm.FindSet() then
                                        repeat
                                            if TaskLineParm2.Get(TaskLineParm."Journal Template Name", TaskLineParm."Journal Batch Name",
                                                                 TaskLineParm."Journal Line No.", TaskLineParm."Field No.",
                                                                 TaskLineParm."Line No.") then begin
                                                TaskLineParm2.TransferFields(TaskLineParm, false);
                                                TaskLineParm2.Modify();
                                            end else begin
                                                TaskLineParm2.TransferFields(TaskLineParm, true);
                                                TaskLineParm2.Insert();
                                            end;

                                        until TaskLineParm.Next() = 0;

                                end;

                                //+TQ1.19
                            end;
                        ChangeType::Delete:
                            begin
                                TaskLine2.ChangeCompany(Comp.Name);
                                TaskLine2.TestField(Enabled, false);
                                if TaskLine2.Get(TaskLine."Journal Template Name", TaskLine."Journal Batch Name", TaskLine."Line No.") then
                                    TaskLine2.Delete(false);
                                //-TQ1.19
                                TaskQueue2.LockTable();
                                TaskQueue2.SetRange(Company, CompanyName);
                                TaskQueue2.SetRange("Task Template", TaskLine."Journal Template Name");
                                TaskQueue2.SetRange("Task Batch", TaskLine."Journal Batch Name");
                                TaskQueue2.SetRange("Task Line No.", TaskLine."Line No.");
                                if TaskQueue2.FindFirst() then begin
                                    TaskQueue2.TestField(Status, TaskQueue.Status::Awaiting);
                                    TaskQueue2.Delete(false);
                                end;

                                TaskLog2.ChangeCompany(Comp.Name);
                                TaskLog2.SetRange("Journal Template Name", TaskLine."Journal Template Name");
                                TaskLog2.SetRange("Journal Batch Name", TaskLine."Journal Batch Name");
                                TaskLog2.SetRange("Line No.", TaskLine."Line No.");
                                if TaskLog2.FindSet(true, true) then
                                    repeat
                                        TaskLog2."Journal Template Name" := '';
                                        TaskLog2."Journal Batch Name" := '';
                                        TaskLog2."Line No." := 0;
                                        TaskLog2.Modify();
                                    until TaskLog2.Next() = 0;

                                TaskOutputLog2.ChangeCompany(Comp.Name);
                                TaskOutputLog2.SetRange("Journal Template Name", TaskLine."Journal Template Name");
                                TaskOutputLog2.SetRange("Journal Batch Name", TaskLine."Journal Batch Name");
                                TaskOutputLog2.SetRange("Journal Line No.", TaskLine."Line No.");
                                if TaskOutputLog2.FindSet(true, true) then
                                    repeat
                                        TaskOutputLog2."Journal Template Name" := '';
                                        TaskOutputLog2."Journal Batch Name" := '';
                                        TaskOutputLog2."Journal Line No." := 0;
                                        TaskOutputLog2.Modify();
                                    until TaskOutputLog2.Next() = 0;

                                TaskLineParm2.ChangeCompany(Comp.Name);
                                TaskLineParm2.SetRange("Journal Template Name", TaskLine."Journal Template Name");
                                TaskLineParm2.SetRange("Journal Batch Name", TaskLine."Journal Batch Name");
                                TaskLineParm2.SetRange("Journal Line No.", TaskLine."Line No.");
                                TaskLineParm2.DeleteAll();
                                //+TQ1.19
                            end;
                        ChangeType::Rename:
                            begin
                                Error('Rename Not supported');
                            end;
                    end;
                end;
            until Comp.Next() = 0;
        //TQ1.06+
        //-TQ1.19
        if GuiAllowed then
            Dia.Close();
        //+TQ1.19
    end;

    procedure SetupCommonBatch(TaskBatch: Record "NPR Task Batch")
    var
        TempConfigSel: Record "Config. Selection" temporary;
        Comp: Record Company;
        TaskBatch2: Record "NPR Task Batch";
        TaskTemplate2: Record "NPR Task Template";
        NASGroup2: Record "NPR Task Worker Group";
        NASGroup: Record "NPR Task Worker Group";
        TaskTemplate: Record "NPR Task Template";
        TaskLine: Record "NPR Task Line";
        TaskLine2: Record "NPR Task Line";
    begin
        if not TaskBatch."Common Companies" then
            exit;

        TaskBatch.TestField("Master Company", CompanyName);

        if Comp.FindSet() then
            repeat
                if Comp.Name <> CompanyName then begin
                    TempConfigSel.Init();
                    TempConfigSel.Name := Comp.Name;
                    TempConfigSel.Insert();
                end;
            until Comp.Next() = 0;

        if not (PAGE.RunModal(PAGE::"Config. Selection", TempConfigSel) = ACTION::LookupOK) then
            exit;

        TempConfigSel.SetRange(Selected, true);
        if TempConfigSel.FindSet() then
            repeat
                NASGroup2.ChangeCompany(TempConfigSel.Name);
                TaskTemplate2.ChangeCompany(TempConfigSel.Name);
                TaskBatch2.ChangeCompany(TempConfigSel.Name);
                TaskLine2.ChangeCompany(TempConfigSel.Name);

                case NASGroup2.Count() of
                    0:
                        begin
                            NASGroup.Get(TaskBatch."Task Worker Group");
                            NASGroup2 := NASGroup;
                            NASGroup2.Insert();
                        end;
                    1:
                        NASGroup2.FindFirst();
                    else begin
                            if not NASGroup2.Get(TaskBatch."Task Worker Group") then begin
                                NASGroup2.SetRange(Default, true);
                                NASGroup2.FindFirst();
                            end;
                        end;
                end;

                if not TaskTemplate2.Get(TaskBatch."Journal Template Name") then begin
                    TaskTemplate.Get(TaskBatch."Journal Template Name");
                    TaskTemplate2 := TaskTemplate;
                    TaskTemplate2."Task Worker Group" := NASGroup2.Code;
                    TaskTemplate2.Insert();
                end;

                if not TaskBatch2.Get(TaskBatch."Journal Template Name", TaskBatch.Name) then begin
                    TaskBatch2 := TaskBatch;
                    TaskBatch2."Task Worker Group" := NASGroup2.Code;
                    if (TaskTemplate2."Mail Program" <> TaskTemplate2."Mail Program"::" ") then
                        TaskBatch2."Mail Program" := TaskTemplate2."Mail Program";
                    if TaskTemplate2."Mail From Address" <> '' then
                        TaskBatch2."Mail From Address" := TaskTemplate2."Mail From Address";
                    if TaskTemplate2."Mail From Name" <> '' then
                        TaskBatch2."Mail From Name" := TaskTemplate2."Mail From Name";
                    TaskBatch2.Insert();
                end;

                TaskLine.SetRange("Journal Template Name", TaskBatch."Journal Template Name");
                TaskLine.SetRange("Journal Batch Name", TaskBatch.Name);
                if TaskLine.FindSet(false, false) then
                    repeat
                        if not TaskLine2.Get(TaskLine."Journal Template Name", TaskLine."Journal Batch Name", TaskLine."Line No.") then begin
                            TaskLine2.TransferFields(TaskLine, true);
                            TaskLine2.Insert();
                        end else begin
                            TaskLine2.TransferFields(TaskLine, false);
                            TaskLine2.Modify();
                        end;
                    until TaskLine.Next() = 0;
            until TempConfigSel.Next() = 0;
    end;
}

