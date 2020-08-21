page 6059903 "TQ Task Card"
{
    // TQ1.17/JDH/20141008 CASE 179044 If task is executed manually, the record filter was applied +
    //                                 call other function in order to log the execution of the task
    // TQ1.18.01/JDH/20141124 CASE 198851 Task Line not set correctly when running task manually (printer not found correct)
    // TQ1.24/JDH/20150320 CASE 209090 Possible to set the language on the task line
    // TQ1.28/MHA/20151216  CASE 229609 Task Queue
    // TQ1.29/JDH /20161101 CASE 242044 Added Images + Promoted category

    Caption = 'Task Card';
    PageType = Card;
    SourceTable = "Task Line";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Object Type"; "Object Type")
                {
                    ApplicationArea = All;
                }
                field("Object No."; "Object No.")
                {
                    ApplicationArea = All;
                }
                field("Call Object With Task Record"; "Call Object With Task Record")
                {
                    ApplicationArea = All;
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                }
                field(Priority; Priority)
                {
                    ApplicationArea = All;
                }
                field("Task Worker Group"; "Task Worker Group")
                {
                    ApplicationArea = All;
                }
                field(Indentation; Indentation)
                {
                    ApplicationArea = All;
                }
                field("Dependence Type"; "Dependence Type")
                {
                    ApplicationArea = All;
                }
                field("Type Of Output"; "Type Of Output")
                {
                    ApplicationArea = All;
                }
                field("Printer Name"; "Printer Name")
                {
                    ApplicationArea = All;
                }
                field("File Path"; "File Path")
                {
                    ApplicationArea = All;
                }
                field("File Name"; "File Name")
                {
                    ApplicationArea = All;
                }
                field("Language ID"; "Language ID")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Abbreviated Name"; "Abbreviated Name")
                {
                    ApplicationArea = All;
                }
                field("Delete Log After"; "Delete Log After")
                {
                    ApplicationArea = All;
                }
            }
            group(Repetition)
            {
                field(Recurrence; Recurrence)
                {
                    ApplicationArea = All;
                }
                field("Recurrence Interval"; "Recurrence Interval")
                {
                    ApplicationArea = All;
                }
                field("Run on Monday"; "Run on Monday")
                {
                    ApplicationArea = All;
                }
                field("Run on Tuesday"; "Run on Tuesday")
                {
                    ApplicationArea = All;
                }
                field("Run on Wednesday"; "Run on Wednesday")
                {
                    ApplicationArea = All;
                }
                field("Run on Thursday"; "Run on Thursday")
                {
                    ApplicationArea = All;
                }
                field("Run on Friday"; "Run on Friday")
                {
                    ApplicationArea = All;
                }
                field("Run on Saturday"; "Run on Saturday")
                {
                    ApplicationArea = All;
                }
                field("Run on Sunday"; "Run on Sunday")
                {
                    ApplicationArea = All;
                }
                field("Valid After"; "Valid After")
                {
                    ApplicationArea = All;
                }
                field("Valid Until"; "Valid Until")
                {
                    ApplicationArea = All;
                }
                field("Recurrence Method"; "Recurrence Method")
                {
                    ApplicationArea = All;
                }
                field("Recurrence Calc. Interval"; "Recurrence Calc. Interval")
                {
                    ApplicationArea = All;
                }
                field("Recurrence Formula"; "Recurrence Formula")
                {
                    ApplicationArea = All;
                }
                field("Recurrence Time"; "Recurrence Time")
                {
                    ApplicationArea = All;
                }
                field("Retry Interval (On Error)"; "Retry Interval (On Error)")
                {
                    ApplicationArea = All;
                }
                field("Max No. Of Retries (On Error)"; "Max No. Of Retries (On Error)")
                {
                    ApplicationArea = All;
                }
                field("Action After Max. No. of Retri"; "Action After Max. No. of Retri")
                {
                    ApplicationArea = All;
                }
            }
            group("E-Mail")
            {
                field("Send E-Mail (On Start)"; "Send E-Mail (On Start)")
                {
                    ApplicationArea = All;
                }
                field("No. of E-Mail (On Start)"; "No. of E-Mail (On Start)")
                {
                    ApplicationArea = All;
                }
                field("Send E-Mail (On Error)"; "Send E-Mail (On Error)")
                {
                    ApplicationArea = All;
                }
                field("No. of E-Mail (On Error)"; "No. of E-Mail (On Error)")
                {
                    ApplicationArea = All;
                }
                field("First E-Mail After Error No."; "First E-Mail After Error No.")
                {
                    ApplicationArea = All;
                }
                field("Last E-Mail After Error No."; "Last E-Mail After Error No.")
                {
                    ApplicationArea = All;
                }
                field("Send E-Mail (On Success)"; "Send E-Mail (On Success)")
                {
                    ApplicationArea = All;
                }
                field("No. of E-Mail (On Success)"; "No. of E-Mail (On Success)")
                {
                    ApplicationArea = All;
                }
            }
            group(Parameters)
            {
                field("Table 1 No."; "Table 1 No.")
                {
                    ApplicationArea = All;
                }
                field("Table 1 Filter"; "Table 1 Filter")
                {
                    ApplicationArea = All;
                }
                field("Task Parameters"; "Task Parameters")
                {
                    ApplicationArea = All;
                }
                field("No. of E-Mail (On Run)"; "No. of E-Mail (On Run)")
                {
                    ApplicationArea = All;
                }
                field("No. of E-Mail CC (On Run)"; "No. of E-Mail CC (On Run)")
                {
                    ApplicationArea = All;
                }
                field("No. of E-Mail BCC (On Run)"; "No. of E-Mail BCC (On Run)")
                {
                    ApplicationArea = All;
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
                    PromotedCategory = Process;
                    RunObject = Page "Task Log (Task)";
                    RunPageLink = "Journal Template Name" = FIELD("Journal Template Name"),
                                  "Journal Batch Name" = FIELD("Journal Batch Name"),
                                  "Line No." = FIELD("Line No.");
                    RunPageView = SORTING("Journal Template Name", "Journal Batch Name", "Line No.")
                                  ORDER(Descending);
                    ShortCutKey = 'Ctrl+F7';
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
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    var
                        TaskQueueManager: Codeunit "Task Queue Manager";
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
                    PromotedCategory = "Report";

                    trigger OnAction()
                    begin
                        RunReportRequestPage;
                    end;
                }
            }
        }
    }
}

