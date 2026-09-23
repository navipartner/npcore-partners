page 6150973 "NPR Spfy Task List"
{
    ApplicationArea = NPRShopify;
    Caption = 'Shopify Task List';
    PageType = List;
    SourceTable = "NPR Spfy Task";
    SourceTableView = sorting("Entry No.") order(descending);
    UsageCategory = Lists;
    Extensible = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the entry number of the task.';
                }
                field(State; Rec.State)
                {
                    ApplicationArea = NPRShopify;
                    StyleExpr = _StateStyle;
                    ToolTip = 'Specifies where the task is in its lifecycle: Pending (ready to be sent, or failed and awaiting another attempt), Waiting (deferred until a related update has reached Shopify), In Flight (claimed by a processing session right now), Quarantined (all attempts failed and the update will not be sent without manual action), or Completed (sent, or established to no longer be applicable).';
                }
                field(ProcessingEnabled; _ProcessingEnabled)
                {
                    ApplicationArea = NPRShopify;
                    Caption = 'Integration Enabled';
                    ToolTip = 'Specifies whether the Shopify integration is currently enabled for this task''s store. When it is not, the task is left untouched by the processing cycle by design, which is not the same as being stuck.';
                }
                field(Attempts; Rec.Attempts)
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies how many times the task has been dispatched to Shopify. A pending task with attempts above zero has failed at least once and will be retried.';
                }
                field(ResponsePreview; _ResponsePreview)
                {
                    ApplicationArea = NPRShopify;
                    Caption = 'Last Response';
                    ToolTip = 'Specifies the beginning of the last response or error text received for this task. Use Show Response to see the full text.';
                }
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the Business Central table the record to send belongs to.';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the name of the Business Central table the record to send belongs to.';
                }
                field("Record Value"; Rec."Record Value")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the key values of the record to send, such as the item number and variant code.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies whether the task creates, updates or deletes the corresponding object in Shopify.';
                }
                field("Store Code"; Rec."Store Code")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the Shopify store the task sends the update to.';
                }
                field("Log Date"; Rec."Log Date")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies when the change was detected and the task was created.';
                }
                field("Not Before Date-Time"; Rec."Not Before Date-Time")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the earliest point in time at which the task may be sent to Shopify.';
                }
                field("Waiting Reason"; Rec."Waiting Reason")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies why the task has been deferred, when it is waiting for another update to reach Shopify first.';
                }
                field("Waiting Since"; Rec."Waiting Since")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the point that this task''s waiting time is measured from. Time when the processing engine was stopped does not count, so this value moves forward after an outage and is not necessarily when the task first started waiting.';
                }
                field("Claimed At"; Rec."Claimed At")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies when the processing session currently sending this task claimed it.';
                }
                field("Last Processing Started at"; Rec."Last Processing Started at")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies when the most recent attempt to send the task began.';
                }
                field("Last Processing Completed at"; Rec."Last Processing Completed at")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies when the most recent attempt to send the task ended, whether it succeeded or failed.';
                }
                field("Completed At"; Rec."Completed At")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies when the task reached the Completed state. Completed tasks are removed by the retention policy for this table.';
                }
                field("Migrated From NC Entry No."; Rec."Migrated From NC Entry No.")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the NaviConnect task this task was created from, when it originates from the migration of the old queue.';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ProcessNow)
            {
                ApplicationArea = NPRShopify;
                Caption = 'Process Now';
                Enabled = _ProcessingEnabled;
                Image = Start;
                ShortCutKey = 'Ctrl+F9';
                ToolTip = 'Sends the selected tasks to Shopify now instead of waiting for the next scheduled processing cycle. A task is skipped if another session has already claimed it or if it still has to wait for a related update to reach Shopify first; a task whose source record is gone is completed without sending.';

                trigger OnAction()
                begin
                    ProcessTaskNow();
                end;
            }
            action(Requeue)
            {
                ApplicationArea = NPRShopify;
                Caption = 'Requeue';
                Image = ResetStatus;
                ToolTip = 'Resets the attempt counter of the selected failed or quarantined tasks so that the next processing cycle picks them up again. Use this after the cause of the failure has been resolved.';

                trigger OnAction()
                begin
                    RequeueTask();
                end;
            }
            action(Resend)
            {
                ApplicationArea = NPRShopify;
                Caption = 'Send Again';
                Image = Restore;
                ToolTip = 'Queues the selected completed tasks to be sent to Shopify once more. Repeating an update is undesirable for some kinds of tasks and can lead to duplicate data in Shopify, so you are asked to confirm.';

                trigger OnAction()
                begin
                    ResendTask();
                end;
            }
            action(DoNotSend)
            {
                ApplicationArea = NPRShopify;
                Caption = 'Do Not Send';
                Image = Cancel;
                ToolTip = 'Closes the selected unsent tasks without sending them. The updates they carry never reach Shopify, and no new task is created unless the source record changes again. A closed task can be reopened with Send Again while it remains on the list.';

                trigger OnAction()
                begin
                    DoNotSendSelectedTasks();
                end;
            }
            action(DeleteTasks)
            {
                ApplicationArea = NPRShopify;
                Caption = 'Delete';
                Image = Delete;
                ToolTip = 'Deletes the selected tasks, so that the updates they carry are never sent to Shopify. Tasks that a processing session is sending right now are skipped. No new task is created unless the source record changes again.';

                trigger OnAction()
                begin
                    DeleteSelectedTasks();
                end;
            }
        }
        area(Navigation)
        {
            action(ShowRequest)
            {
                ApplicationArea = NPRShopify;
                Caption = 'Show Request';
                Image = XMLFile;
                ToolTip = 'Downloads this task''s part of the request that was last sent to Shopify.';

                trigger OnAction()
                begin
                    ShowRequestContent();
                end;
            }
            action(ShowResponse)
            {
                ApplicationArea = NPRShopify;
                Caption = 'Show Response';
                Image = ViewDetails;
                ToolTip = 'Shows the full response or error text that Shopify last returned for this task.';

                trigger OnAction()
                begin
                    ShowResponseContent();
                end;
            }
            action(OpenSourceRecord)
            {
                ApplicationArea = NPRShopify;
                Caption = 'Source Record';
                Image = Item;
                ShortCutKey = 'Shift+F7';
                ToolTip = 'Opens the Business Central record that the task sends to Shopify.';

                trigger OnAction()
                begin
                    RunSourceRecord();
                end;
            }
            action(ShowCompleted)
            {
                ApplicationArea = NPRShopify;
                Caption = 'Show Completed';
                Image = ShowSelected;
                ToolTip = 'Also shows completed tasks. The list hides them by default so it only shows work that is pending, waiting, in flight or quarantined.';
                Visible = not _ShowCompleted;

                trigger OnAction()
                begin
                    _ShowCompleted := true;
                    SetPresetFilters();
                end;
            }
            action(HideCompleted)
            {
                ApplicationArea = NPRShopify;
                Caption = 'Hide Completed';
                Image = RemoveFilterLines;
                ToolTip = 'Hides completed tasks again, so the list only shows work that is pending, waiting, in flight or quarantined.';
                Visible = _ShowCompleted;

                trigger OnAction()
                begin
                    _ShowCompleted := false;
                    SetPresetFilters();
                end;
            }
        }
        area(Promoted)
        {
            actionref(ShowCompleted_Promoted; ShowCompleted) { }
            actionref(HideCompleted_Promoted; HideCompleted) { }
        }
    }

    views
    {
        view(Failed)
        {
            Caption = 'Failed';
            Filters = where(State = const(Pending), Attempts = filter(> 0));
        }
        view(Quarantined)
        {
            Caption = 'Quarantined';
            Filters = where(State = const(Quarantined));
        }
    }

    trigger OnOpenPage()
    begin
        SetPresetFilters();
    end;

    trigger OnAfterGetRecord()
    begin
        _StateStyle := StateStyleExpr();
        _ResponsePreview := CalcResponsePreview();
        _ProcessingEnabled := ProcessingIsEnabled();
    end;

    var
        _SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        _SpfyTaskProcessor: Codeunit "NPR Spfy Task Processor";
        _SpfyTaskQueue: Codeunit "NPR Spfy Task Queue";
        _ProcessingEnabled: Boolean;
        _ShowCompleted: Boolean;
        _ResponsePreview: Text[250];
        _StateStyle: Text;

    local procedure SetPresetFilters()
    var
        CurrentEntryNo: BigInteger;
    begin
        CurrentEntryNo := Rec."Entry No.";
        Rec.FilterGroup(2);
        if _ShowCompleted then
            Rec.SetRange(State)
        else
            Rec.SetFilter(State, '<>%1', Rec.State::Completed);
        Rec.FilterGroup(0);
        if Rec.Get(CurrentEntryNo) then;
        CurrPage.Update(false);
    end;

    local procedure StateStyleExpr(): Text
    begin
        case Rec.State of
            Rec.State::Pending:
                if Rec.Attempts > 0 then
                    exit('Attention');
            Rec.State::Waiting:
                exit('Ambiguous');
            Rec.State::"In Flight":
                exit('StrongAccent');
            Rec.State::Quarantined:
                exit('Unfavorable');
            Rec.State::Completed:
                exit('Favorable');
        end;
        exit('Standard');
    end;

    local procedure CalcResponsePreview(): Text[250]
    var
        TypeHelper: Codeunit "Type Helper";
        IStream: InStream;
        ResponseText: Text;
    begin
        Rec.CalcFields(Response);
        if not Rec.Response.HasValue() then
            exit('');
        Rec.Response.CreateInStream(IStream, TextEncoding::UTF8);
        ResponseText := TypeHelper.ReadAsTextWithSeparator(IStream, ' ');
        exit(CopyStr(ResponseText, 1, 250));
    end;

    local procedure ProcessingIsEnabled(): Boolean
    begin
        if Rec."Store Code" = '' then
            exit(false);
        exit(_SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::" ", Rec."Store Code"));
    end;

    local procedure ProcessTaskNow()
    var
        SelectedTask: Record "NPR Spfy Task";
        SpfyTask: Record "NPR Spfy Task";
        ShowWaitingMessage: Boolean;
        ExecutePostponedTasksQst: Label 'You have selected one or more tasks that should be executed later.\Are you sure you want to execute them now?';
        NoneProcessableMsg: Label 'None of the selected tasks can be processed manually. Only a task in state %1 or %2 can.', Comment = '%1 = the Pending state, %2 = the Waiting state';
        ProcessingSuspendedMsg: Label 'Tasks cannot be processed while the migration to the Shopify task list has not completed on this environment. Check the migration status on the Shopify Integration Setup page.';
    begin
        if not _SpfyTaskProcessor.ProcessingIsAllowed() then begin
            Message(ProcessingSuspendedMsg);
            exit;
        end;
        CurrPage.SetSelectionFilter(SelectedTask);
        SelectedTask.SetFilter(State, '%1|%2', SelectedTask.State::Pending, SelectedTask.State::Waiting);
        // Probed in a spare filter group so clearing it cannot drop the operator's own filter on the same field.
        SelectedTask.FilterGroup(10);
        SelectedTask.SetFilter("Not Before Date-Time", '>%1', CurrentDateTime());
        if not SelectedTask.IsEmpty() then
            if not Confirm(ExecutePostponedTasksQst) then
                exit;
        SelectedTask.SetRange("Not Before Date-Time");
        SelectedTask.FilterGroup(0);
        // Sent in creation order: SetSelectionFilter copies the page's descending view, which would send a delete before the modify it precedes.
        SelectedTask.SetCurrentKey("Entry No.");
        SelectedTask.Ascending(true);
        if not SelectedTask.FindSet() then begin
            Message(NoneProcessableMsg, SelectedTask.State::Pending, SelectedTask.State::Waiting);
            exit;
        end;
        ShowWaitingMessage := SelectedTask.Count() = 1;
        repeat
            SpfyTask := SelectedTask;
            _SpfyTaskProcessor.ProcessTaskManually(SpfyTask, ShowWaitingMessage);
        until SelectedTask.Next() = 0;
        CurrPage.Update(false);
    end;

    local procedure RequeueTask()
    var
        SelectedTask: Record "NPR Spfy Task";
        SpfyTask: Record "NPR Spfy Task";
        RequeuedCount: Integer;
        NoneRequeueableMsg: Label 'None of the selected tasks can be requeued. Only a failed task awaiting another attempt, or a quarantined task, can be.';
    begin
        CurrPage.SetSelectionFilter(SelectedTask);
        if SelectedTask.FindSet() then
            repeat
                if (SelectedTask.State = SelectedTask.State::Quarantined) or
                   ((SelectedTask.State = SelectedTask.State::Pending) and (SelectedTask.Attempts > 0))
                then begin
                    SpfyTask := SelectedTask;
                    if _SpfyTaskQueue.Requeue(SpfyTask) then
                        RequeuedCount += 1;
                end;
            until SelectedTask.Next() = 0;
        if RequeuedCount = 0 then begin
            Message(NoneRequeueableMsg);
            exit;
        end;
        CurrPage.Update(false);
    end;

    local procedure ResendTask()
    var
        SelectedTask: Record "NPR Spfy Task";
        SpfyTask: Record "NPR Spfy Task";
        SpfyDeletionLogMgt: Codeunit "NPR Spfy Deletion Log Mgt";
        Reopened: Boolean;
        ReopenedCount: Integer;
        SelectedCount: Integer;
        NotResentMsg: Label '%1 of the selected task(s) could not be sent again because they were reopened or picked up for processing in the meantime.', Comment = '%1 = number of tasks that could not be sent again';
        NoneCompletedMsg: Label 'None of the selected tasks can be sent again. Only a completed task can be.';
        ResendQst: Label '%1 selected task(s) have already been sent to Shopify. Sending them again repeats the same updates, which is undesirable for some kinds of tasks and can lead to duplicate data in Shopify.\Are you sure you want to continue?', Comment = '%1 = the number of completed tasks selected';
    begin
        CurrPage.SetSelectionFilter(SelectedTask);
        SelectedTask.SetRange(State, SelectedTask.State::Completed);
        if SelectedTask.IsEmpty() then begin
            Message(NoneCompletedMsg);
            exit;
        end;
        SelectedCount := SelectedTask.Count();
        if not Confirm(ResendQst, false, SelectedCount) then
            exit;
        if SelectedTask.FindSet() then
            repeat
                SpfyTask := SelectedTask;
                // Delete tasks go through the deletion log so its rows are locked before the task, never the other way round.
                if SelectedTask.Type = SelectedTask.Type::Delete then
                    Reopened := SpfyDeletionLogMgt.ReopenTaskAndRestoreDelete(SpfyTask)
                else
                    Reopened := _SpfyTaskQueue.Resend(SpfyTask);
                if Reopened then
                    ReopenedCount += 1;
            until SelectedTask.Next() = 0;
        if ReopenedCount < SelectedCount then
            Message(NotResentMsg, SelectedCount - ReopenedCount);
        CurrPage.Update(false);
    end;

    local procedure DoNotSendSelectedTasks()
    var
        SelectedTask: Record "NPR Spfy Task";
        SpfyDeletionLogMgt: Codeunit "NPR Spfy Deletion Log Mgt";
        ClosedCount: Integer;
        SelectedCount: Integer;
        TaskWasClosed: Boolean;
        ClosedByUserLbl: Label 'Closed manually by %1 without sending.', Comment = '%1 = the id of the user who closed the task';
        DoNotSendQst: Label '%1 selected task(s) will be closed without sending. The updates they carry will not reach Shopify, and no new task is created unless the source record changes again. A closed task can be reopened with Send Again while it remains on the list; completed tasks are removed by the retention policy.\Are you sure you want to continue?', Comment = '%1 = the number of tasks that will be closed';
        NoneClosableMsg: Label 'None of the selected tasks can be closed. Only a task that has not been sent yet — pending, waiting or quarantined — can be.';
        NotClosedMsg: Label '%1 of the selected task(s) could not be closed because they were picked up for processing or completed in the meantime. They have NOT been suppressed.', Comment = '%1 = number of tasks that could not be closed';
    begin
        CurrPage.SetSelectionFilter(SelectedTask);
        SelectedTask.SetFilter(State, '%1|%2|%3', SelectedTask.State::Pending, SelectedTask.State::Waiting, SelectedTask.State::Quarantined);
        if SelectedTask.IsEmpty() then begin
            Message(NoneClosableMsg);
            exit;
        end;
        SelectedCount := SelectedTask.Count();
        if not Confirm(DoNotSendQst, false, SelectedCount) then
            exit;
        // A row claimed after the confirmation leaves the filter rather than returning false, so count what closed.
        if SelectedTask.FindSet() then
            repeat
                // Delete tasks go through the deletion log so its rows are locked before the task, never the other way round.
                if SelectedTask.Type = SelectedTask.Type::Delete then
                    TaskWasClosed := SpfyDeletionLogMgt.CloseTaskAndCancelDelete(SelectedTask."Entry No.", StrSubstNo(ClosedByUserLbl, UserId()))
                else
                    TaskWasClosed := _SpfyTaskQueue.CancelUnsentTask(SelectedTask."Entry No.", StrSubstNo(ClosedByUserLbl, UserId()));
                if TaskWasClosed then
                    ClosedCount += 1;
            until SelectedTask.Next() = 0;
        if ClosedCount < SelectedCount then
            Message(NotClosedMsg, SelectedCount - ClosedCount);
        CurrPage.Update(false);
    end;

    local procedure DeleteSelectedTasks()
    var
        SpfyTask: Record "NPR Spfy Task";
        SpfyDeletionLogMgt: Codeunit "NPR Spfy Deletion Log Mgt";
        Deleted: Boolean;
        DeletedCount: Integer;
        SelectedCount: Integer;
        DeleteTasksQst: Label 'Delete %1 task(s)? The updates they carry will never be sent to Shopify.', Comment = '%1 = the number of tasks that will be deleted';
        NotDeletedMsg: Label '%1 of the selected task(s) could not be deleted because they were picked up for processing in the meantime. They are still on the list and will be sent.', Comment = '%1 = number of tasks that could not be deleted';
        NothingToDeleteMsg: Label 'None of the selected tasks can be deleted. A task that is being sent to Shopify right now has to finish first.';
    begin
        CurrPage.SetSelectionFilter(SpfyTask);
        SpfyTask.SetFilter(State, '<>%1', SpfyTask.State::"In Flight");
        if SpfyTask.IsEmpty() then begin
            Message(NothingToDeleteMsg);
            exit;
        end;
        SelectedCount := SpfyTask.Count();
        if not Confirm(DeleteTasksQst, false, SelectedCount) then
            exit;
        // Per row under a lock, never scan-then-DeleteAll: a task claimed between the passes would be recorded wrongly.
        if SpfyTask.FindSet() then
            repeat
                // Only a Delete task can own a delete intent, so only it pays for the deletion-log lookup.
                if SpfyTask.Type = SpfyTask.Type::Delete then
                    Deleted := SpfyDeletionLogMgt.DeleteTaskAndCancelDelete(SpfyTask."Entry No.")
                else
                    Deleted := _SpfyTaskQueue.DeleteUnsentTask(SpfyTask."Entry No.");
                if Deleted then
                    DeletedCount += 1;
            until SpfyTask.Next() = 0;
        if DeletedCount < SelectedCount then
            Message(NotDeletedMsg, SelectedCount - DeletedCount);
        CurrPage.Update(false);
    end;

    local procedure ShowRequestContent()
    var
        IStream: InStream;
        FileName: Text;
        NoRequestMsg: Label 'No request has been sent to Shopify for this task yet.';
        RequestFileNameLbl: Label 'Shopify Task %1 Request.json', Comment = '%1 = the task entry number';
    begin
        Rec.CalcFields("Data Output");
        if not Rec."Data Output".HasValue() then begin
            Message(NoRequestMsg);
            exit;
        end;
        Rec."Data Output".CreateInStream(IStream, TextEncoding::UTF8);
        FileName := StrSubstNo(RequestFileNameLbl, Rec."Entry No.");
        DownloadFromStream(IStream, '', '', '', FileName);
    end;

    local procedure ShowResponseContent()
    var
        TypeHelper: Codeunit "Type Helper";
        IStream: InStream;
        ResponseText: Text;
        NoResponseMsg: Label 'No response has been received from Shopify for this task yet.';
        ResponseLbl: Label '%1', Locked = true;
    begin
        Rec.CalcFields(Response);
        if not Rec.Response.HasValue() then begin
            Message(NoResponseMsg);
            exit;
        end;
        Rec.Response.CreateInStream(IStream, TextEncoding::UTF8);
        ResponseText := TypeHelper.ReadAsTextWithSeparator(IStream, TypeHelper.LFSeparator());
        Message(ResponseLbl, ResponseText);
    end;

    local procedure RunSourceRecord()
    var
        PageMgt: Codeunit "Page Management";
        RecRef: RecordRef;
        SourceFound: Boolean;
        SourceGoneMsg: Label 'The record this task refers to no longer exists.';
    begin
        if Format(Rec."Record ID") <> '' then
            SourceFound := RecRef.Get(Rec."Record ID");
        if not SourceFound then begin
            Message(SourceGoneMsg);
            exit;
        end;
        RecRef.SetRecFilter();
        PageMgt.PageRun(RecRef);
    end;
}
