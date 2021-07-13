page 6059902 "NPR Task Journal"
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
    SourceTable = "NPR Task Line";
    UsageCategory = Tasks;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            field(CurrentJnlBatchName; CurrentJnlBatchName)
            {

                Caption = 'Batch Name';
                Lookup = true;
                ToolTip = 'Specifies the value of the Batch Name field';
                ApplicationArea = NPRRetail;

                trigger OnLookup(var Text: Text): Boolean
                begin
                    CurrPage.SaveRecord();
                    JobJnlManagement.LookupName(CurrentJnlBatchName, Rec);
                    CurrPage.Update(false);
                end;

                trigger OnValidate()
                begin
                    JobJnlManagement.CheckName(CurrentJnlBatchName, Rec);
                    CurrentJnlBatchNameOnAfterVali();
                end;
            }
            repeater(Control1)
            {
                IndentationColumn = NameIndent;
                IndentationControls = Description;
                ShowCaption = false;
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Object Type"; Rec."Object Type")
                {

                    ToolTip = 'Specifies the value of the Object Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Object No."; Rec."Object No.")
                {

                    ToolTip = 'Specifies the value of the Object No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Report Name"; Rec."Report Name")
                {

                    ToolTip = 'Specifies the value of the Report Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Enabled; Rec.Enabled)
                {

                    ToolTip = 'Specifies the value of the Enabled field';
                    ApplicationArea = NPRRetail;
                }
                field(NextExecutionTime; NextExecutionTime)
                {

                    Caption = 'Next Execution Time';
                    ToolTip = 'Specifies the value of the NextExecutionTime field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        //-TQ1.25
                        //SetNextRuntime(NextExecutionTime);
                        Rec.SetNextRuntime(NextExecutionTime, false);
                        //+TQ1.25
                    end;
                }
                field("Call Object With Task Record"; Rec."Call Object With Task Record")
                {

                    ToolTip = 'Specifies the value of the Call Object With Task Record field';
                    ApplicationArea = NPRRetail;
                }
                field(Recurrence; Rec.Recurrence)
                {

                    ToolTip = 'Specifies the value of the Recurrence field';
                    ApplicationArea = NPRRetail;
                }
                field("Recurrence Interval"; Rec."Recurrence Interval")
                {

                    ToolTip = 'Specifies the value of the Recurrence Interval field';
                    ApplicationArea = NPRRetail;
                }
                field("Dependence Type"; Rec."Dependence Type")
                {

                    ToolTip = 'Specifies the value of the Dependence Type field';
                    ApplicationArea = NPRRetail;
                }
                field(LastStatus; LastStatus)
                {

                    Caption = 'Last Status';
                    Editable = false;
                    OptionCaption = ' ,Started,Error,Succes,Message';
                    ToolTip = 'Specifies the value of the Last Status field';
                    ApplicationArea = NPRRetail;
                }
                field(LastExecutionTime; LastExecutionTime)
                {

                    Caption = 'Last Execution Time';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Last Execution Time field';
                    ApplicationArea = NPRRetail;
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
                        field(JobDescription; JobDescription)
                        {

                            Editable = false;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the JobDescription field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    group("Account Name")
                    {
                        Caption = 'Account Name';
                        field(AccName; AccName)
                        {

                            Caption = 'Account Name';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Account Name field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                Visible = false;
                ApplicationArea = NPRRetail;

            }
            systempart(Control1905767507; Notes)
            {
                Visible = false;
                ApplicationArea = NPRRetail;

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
                    PromotedOnly = true;
                    RunObject = Page "NPR TQ Task Card";
                    RunPageLink = "Journal Template Name" = FIELD("Journal Template Name"),
                                  "Journal Batch Name" = FIELD("Journal Batch Name"),
                                  "Line No." = FIELD("Line No.");
                    ShortCutKey = 'Shift+F7';

                    ToolTip = 'Executes the Card action';
                    ApplicationArea = NPRRetail;
                }
                action("Task Log")
                {
                    Caption = 'Task Log';
                    Image = Log;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "NPR Task Log (Task)";
                    RunPageLink = "Journal Template Name" = FIELD("Journal Template Name"),
                                  "Journal Batch Name" = FIELD("Journal Batch Name"),
                                  "Line No." = FIELD("Line No.");
                    RunPageView = SORTING("Journal Template Name", "Journal Batch Name", "Line No.");
                    ShortCutKey = 'Ctrl+F7';

                    ToolTip = 'Executes the Task Log action';
                    ApplicationArea = NPRRetail;
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
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    ToolTip = 'Executes the Decrease action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        CurrPage.SaveRecord();
                        Rec.DecreaseIndentation();
                        CurrPage.Update(true);
                    end;
                }
                action(Increase)
                {
                    Caption = 'Increase';
                    Image = NextRecord;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    ToolTip = 'Executes the Increase action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        CurrPage.SaveRecord();
                        Rec.IncreaseIndentation();
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
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    ToolTip = 'Executes the Run Task action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        TaskQueueManager: Codeunit "NPR Task Queue Manager";
                    begin
                        TaskQueueManager.CodeManualRun(Rec);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        NextExecutionTime := Rec.LookupNextRunTime();
        NameIndent := Rec.Indentation;

        //-TQ1.31 [302644]
        GetLastLogInfo();
        //+TQ1.31 [302644]
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.SetUpNewLine(xRec);
    end;

    trigger OnOpenPage()
    var
        JnlSelected: Boolean;
    begin
        OpenedFromBatch := (Rec."Journal Batch Name" <> '') and (Rec."Journal Template Name" = '');
        if OpenedFromBatch then begin
            CurrentJnlBatchName := Rec."Journal Batch Name";
            JobJnlManagement.OpenJnl(CurrentJnlBatchName, Rec);
            exit;
        end;
        JobJnlManagement.TemplateSelection(PAGE::"NPR Task Journal", 0, Rec, JnlSelected);

        if not JnlSelected then
            Error('');
        JobJnlManagement.OpenJnl(CurrentJnlBatchName, Rec);
    end;

    var
        JobJnlManagement: Codeunit "NPR Task Jnl. Management";
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
        TaskLogTask: Record "NPR Task Log (Task)";
    begin
        LastStatus := LastStatus::" ";
        LastExecutionTime := 0DT;
        TaskLogTask.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Line No.");
        TaskLogTask.SetRange("Journal Template Name", Rec."Journal Template Name");
        TaskLogTask.SetRange("Journal Batch Name", Rec."Journal Batch Name");
        TaskLogTask.SetRange("Line No.", Rec."Line No.");
        if TaskLogTask.FindLast() then begin
            if (TaskLogTask."Object Type" <> Rec."Object Type") or
               (TaskLogTask."Object No." <> Rec."Object No.") then
                exit;
            LastStatus := TaskLogTask.Status;
            LastExecutionTime := TaskLogTask."Ending Time";
        end;
    end;
}

