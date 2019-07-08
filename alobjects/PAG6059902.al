page 6059902 "Task Journal"
{
    // TQ1.17/JDH/20141008 CASE 179044 If task is executed manually, the record filter was applied +
    //                                 call other function in order to log the execution of the task
    // TQ1.18.01/JDH/20141124 CASE 198851 Task Line not set correctly when running task manually (printer not found correct)
    // TQ1.25/JDH/20150504 CASE 210797 parameter changed for function "setnextruntime"
    // TQ1.28/MHA/20151216  CASE 229609 Task Queue
    // TQ1.29/JDH /20161101 CASE 242044 Removed unused fields. Added images
    // TQ1.31/JDH /20180122 CASE 302644 Added Status of last task to the page

    AutoSplitKey = true;
    Caption = 'Task Journal';
    DataCaptionFields = "Journal Batch Name";
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Task Line";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            field(CurrentJnlBatchName;CurrentJnlBatchName)
            {
                Caption = 'Batch Name';
                Lookup = true;

                trigger OnLookup(var Text: Text): Boolean
                begin
                    CurrPage.SaveRecord;
                    JobJnlManagement.LookupName(CurrentJnlBatchName,Rec);
                    CurrPage.Update(false);
                end;

                trigger OnValidate()
                begin
                    JobJnlManagement.CheckName(CurrentJnlBatchName,Rec);
                    CurrentJnlBatchNameOnAfterVali;
                end;
            }
            repeater(Control1)
            {
                IndentationColumn = NameIndent;
                IndentationControls = Description;
                ShowCaption = false;
                field(Description;Description)
                {
                }
                field("Object Type";"Object Type")
                {
                }
                field("Object No.";"Object No.")
                {
                }
                field("Report Name";"Report Name")
                {
                }
                field(Enabled;Enabled)
                {
                }
                field(NextExecutionTime;NextExecutionTime)
                {

                    trigger OnValidate()
                    begin
                        //-TQ1.25
                        //SetNextRuntime(NextExecutionTime);
                        SetNextRuntime(NextExecutionTime, false);
                        //+TQ1.25
                    end;
                }
                field("Call Object With Task Record";"Call Object With Task Record")
                {
                }
                field(Recurrence;Recurrence)
                {
                }
                field("Recurrence Interval";"Recurrence Interval")
                {
                }
                field("Dependence Type";"Dependence Type")
                {
                }
                field(LastStatus;LastStatus)
                {
                    Caption = 'Last Status';
                    Editable = false;
                }
                field(LastExecutionTime;LastExecutionTime)
                {
                    Caption = 'Last Execution Time';
                    Editable = false;
                }
            }
            group(Control73)
            {
                ShowCaption = false;
                fixed(Control1902114901)
                {
                    ShowCaption = false;
                    group("Job Description")
                    {
                        Caption = 'Job Description';
                        field(JobDescription;JobDescription)
                        {
                            Editable = false;
                            ShowCaption = false;
                        }
                    }
                    group("Account Name")
                    {
                        Caption = 'Account Name';
                        field(AccName;AccName)
                        {
                            Caption = 'Account Name';
                            Editable = false;
                        }
                    }
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207;Links)
            {
                Visible = false;
            }
            systempart(Control1905767507;Notes)
            {
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Task")
            {
                Caption = '&Task';
                Image = Job;
                action(Card)
                {
                    Caption = 'Card';
                    Image = EditLines;
                    Promoted = true;
                    RunObject = Page "TQ Task Card";
                    RunPageLink = "Journal Template Name"=FIELD("Journal Template Name"),
                                  "Journal Batch Name"=FIELD("Journal Batch Name"),
                                  "Line No."=FIELD("Line No.");
                    ShortCutKey = 'Shift+F7';
                }
                action("Task Log")
                {
                    Caption = 'Task Log';
                    Image = Log;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "Task Log (Task)";
                    RunPageLink = "Journal Template Name"=FIELD("Journal Template Name"),
                                  "Journal Batch Name"=FIELD("Journal Batch Name"),
                                  "Line No."=FIELD("Line No.");
                    RunPageView = SORTING("Journal Template Name","Journal Batch Name","Line No.");
                    ShortCutKey = 'Ctrl+F7';
                }
            }
        }
        area(processing)
        {
            group(Indentation)
            {
                Caption = 'Indentation';
                action(Decrease)
                {
                    Caption = 'Decrease';
                    Image = PreviousRecord;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        CurrPage.SaveRecord;
                        DecreaseIndentation;
                        CurrPage.Update(true);
                    end;
                }
                action(Increase)
                {
                    Caption = 'Increase';
                    Image = NextRecord;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        CurrPage.SaveRecord;
                        IncreaseIndentation;
                        CurrPage.Update(true);
                    end;
                }
            }
            group(Task)
            {
                Caption = 'Task';
                action("Run Task")
                {
                    Caption = 'Run Task';
                    Image = Migration;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        TaskQueueManager: Codeunit "Task Queue Manager";
                    begin
                        TaskQueueManager.CodeManualRun(Rec);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        JobJnlManagement.GetNames(Rec,JobDescription,AccName);
    end;

    trigger OnAfterGetRecord()
    begin
        NextExecutionTime := LookupNextRunTime;
        NameIndent := Indentation;

        //-TQ1.31 [302644]
        GetLastLogInfo;
        //+TQ1.31 [302644]
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetUpNewLine(xRec);
    end;

    trigger OnOpenPage()
    var
        JnlSelected: Boolean;
    begin
        OpenedFromBatch := ("Journal Batch Name" <> '') and ("Journal Template Name" = '');
        if OpenedFromBatch then begin
          CurrentJnlBatchName := "Journal Batch Name";
          JobJnlManagement.OpenJnl(CurrentJnlBatchName,Rec);
          exit;
        end;
        JobJnlManagement.TemplateSelection(PAGE::"Task Journal",0, Rec,JnlSelected);

        if not JnlSelected then
          Error('');
        JobJnlManagement.OpenJnl(CurrentJnlBatchName,Rec);
    end;

    var
        JobJnlManagement: Codeunit "Task Jnl. Management";
        JobDescription: Text[50];
        AccName: Text[50];
        CurrentJnlBatchName: Code[10];
        OpenedFromBatch: Boolean;
        NextExecutionTime: DateTime;
        NameIndent: Integer;
        LastStatus: Option " ",Started,Error,Succes,Message;
        LastExecutionTime: DateTime;

    local procedure CurrentJnlBatchNameOnAfterVali()
    begin
        //CurrPage.SAVERECORD;
        //JobJnlManagement.SetName(CurrentJnlBatchName,Rec);
        //CurrPage.UPDATE(FALSE);
    end;

    local procedure GetLastLogInfo()
    var
        TaskLogTask: Record "Task Log (Task)";
    begin
        LastStatus := LastStatus::" ";
        LastExecutionTime := 0DT;
        TaskLogTask.SetCurrentKey("Journal Template Name","Journal Batch Name","Line No.");
        TaskLogTask.SetRange("Journal Template Name", "Journal Template Name");
        TaskLogTask.SetRange("Journal Batch Name", "Journal Batch Name");
        TaskLogTask.SetRange("Line No.", "Line No.");
        if TaskLogTask.FindLast then begin
          if (TaskLogTask."Object Type" <> "Object Type") or
             (TaskLogTask."Object No." <> "Object No.") then
            exit;
          LastStatus := TaskLogTask.Status;
          LastExecutionTime := TaskLogTask."Ending Time";
        end;
    end;
}

