page 6059903 "NPR TQ Task Card"
{
    // TQ1.17/JDH/20141008 CASE 179044 If task is executed manually, the record filter was applied +
    //                                 call other function in order to log the execution of the task
    // TQ1.18.01/JDH/20141124 CASE 198851 Task Line not set correctly when running task manually (printer not found correct)
    // TQ1.24/JDH/20150320 CASE 209090 Possible to set the language on the task line
    // TQ1.28/MHA/20151216  CASE 229609 Task Queue
    // TQ1.29/JDH /20161101 CASE 242044 Added Images + Promoted category

    Caption = 'Task Card';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Task Line";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Object Type"; "Object Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Object Type field';
                }
                field("Object No."; "Object No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Object No. field';
                }
                field("Call Object With Task Record"; "Call Object With Task Record")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Call Object With Task Record field';
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enabled field';
                }
                field(Priority; Priority)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Priority field';
                }
                field("Task Worker Group"; "Task Worker Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Task Worker Group field';
                }
                field(Indentation; Indentation)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Indentation field';
                }
                field("Dependence Type"; "Dependence Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dependence Type field';
                }
                field("Type Of Output"; "Type Of Output")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type Of Output field';
                }
                field("Printer Name"; "Printer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Printer Name field';
                }
                field("File Path"; "File Path")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the File Path field';
                }
                field("File Name"; "File Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the File Name field';
                }
                field("Language ID"; "Language ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Language ID field';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Abbreviated Name"; "Abbreviated Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Abbreviated Name field';
                }
                field("Delete Log After"; "Delete Log After")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delete Log After field';
                }
            }
            group(Repetition)
            {
                field(Recurrence; Recurrence)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Recurrence field';
                }
                field("Recurrence Interval"; "Recurrence Interval")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Recurrence Interval field';
                }
                field("Run on Monday"; "Run on Monday")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Run on Monday field';
                }
                field("Run on Tuesday"; "Run on Tuesday")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Run on Tuesday field';
                }
                field("Run on Wednesday"; "Run on Wednesday")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Run on Wednesday field';
                }
                field("Run on Thursday"; "Run on Thursday")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Run on Thursday field';
                }
                field("Run on Friday"; "Run on Friday")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Run on Friday field';
                }
                field("Run on Saturday"; "Run on Saturday")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Run on Saturday field';
                }
                field("Run on Sunday"; "Run on Sunday")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Run on Sunday field';
                }
                field("Valid After"; "Valid After")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Valid After field';
                }
                field("Valid Until"; "Valid Until")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Valid Until field';
                }
                field("Recurrence Method"; "Recurrence Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Recurrence Method field';
                }
                field("Recurrence Calc. Interval"; "Recurrence Calc. Interval")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Recurrence Calculation Interval field';
                }
                field("Recurrence Formula"; "Recurrence Formula")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Recurrence Formula field';
                }
                field("Recurrence Time"; "Recurrence Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Recurrence Time field';
                }
                field("Retry Interval (On Error)"; "Retry Interval (On Error)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Retry Interval (On Error) field';
                }
                field("Max No. Of Retries (On Error)"; "Max No. Of Retries (On Error)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Max No. Of Retries (On Error) field';
                }
                field("Action After Max. No. of Retri"; "Action After Max. No. of Retri")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Action After Max. No. of Retri field';
                }
            }
            group("E-Mail")
            {
                field("Send E-Mail (On Start)"; "Send E-Mail (On Start)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Send Email On Start field';
                }
                field("No. of E-Mail (On Start)"; "No. of E-Mail (On Start)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. of Email On Start field';
                }
                field("Send E-Mail (On Error)"; "Send E-Mail (On Error)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Send Email On Error field';
                }
                field("No. of E-Mail (On Error)"; "No. of E-Mail (On Error)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. of Email On Error field';
                }
                field("First E-Mail After Error No."; "First E-Mail After Error No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the First E-Mail After Error No. field';
                }
                field("Last E-Mail After Error No."; "Last E-Mail After Error No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last E-Mail After Error No. field';
                }
                field("Send E-Mail (On Success)"; "Send E-Mail (On Success)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Send Email On Success field';
                }
                field("No. of E-Mail (On Success)"; "No. of E-Mail (On Success)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. of Email On Success field';
                }
            }
            group(Parameters)
            {
                field("Table 1 No."; "Table 1 No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table 1 No. field';
                }
                field("Table 1 Filter"; "Table 1 Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table 1 Filter field';
                }
                field("Task Parameters"; "Task Parameters")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Task Parameters field';
                }
                field("No. of E-Mail (On Run)"; "No. of E-Mail (On Run)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. of E-Mail (On Run) field';
                }
                field("No. of E-Mail CC (On Run)"; "No. of E-Mail CC (On Run)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. of E-Mail CC (On Run) field';
                }
                field("No. of E-Mail BCC (On Run)"; "No. of E-Mail BCC (On Run)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. of E-Mail BCC (On Run) field';
                }
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
                action("Task Log")
                {
                    Caption = 'Task Log';
                    Image = Log;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = Process;
                    RunObject = Page "NPR Task Log (Task)";
                    RunPageLink = "Journal Template Name" = FIELD("Journal Template Name"),
                                  "Journal Batch Name" = FIELD("Journal Batch Name"),
                                  "Line No." = FIELD("Line No.");
                    RunPageView = SORTING("Journal Template Name", "Journal Batch Name", "Line No.")
                                  ORDER(Descending);
                    ShortCutKey = 'Ctrl+F7';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Task Log action';
                }
            }
        }
        area(processing)
        {
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
                    ShortCutKey = 'F9';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Run Task action';

                    trigger OnAction()
                    var
                        TaskQueueManager: Codeunit "NPR Task Queue Manager";
                    begin

                        //-TQ1.18.01
                        //-TQ1.17
                        //TaskQueueExecute.RUN(Rec);
                        //TaskQueueProcessor.CodeManualRun(Rec);
                        //+TQ1.17
                        TaskQueueManager.CodeManualRun(Rec);
                        //+TQ1.18.01
                    end;
                }
                action(ReportRequestPage)
                {
                    Caption = 'Report Request Page';
                    Image = "Report";
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = "Report";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Report Request Page action';

                    trigger OnAction()
                    begin
                        RunReportRequestPage;
                    end;
                }
            }
        }
    }
}

