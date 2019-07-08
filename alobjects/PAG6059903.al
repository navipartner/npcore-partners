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
                field(Description;Description)
                {
                }
                field("Object Type";"Object Type")
                {
                }
                field("Object No.";"Object No.")
                {
                }
                field("Call Object With Task Record";"Call Object With Task Record")
                {
                }
                field(Enabled;Enabled)
                {
                }
                field(Priority;Priority)
                {
                }
                field("Task Worker Group";"Task Worker Group")
                {
                }
                field(Indentation;Indentation)
                {
                }
                field("Dependence Type";"Dependence Type")
                {
                }
                field("Type Of Output";"Type Of Output")
                {
                }
                field("Printer Name";"Printer Name")
                {
                }
                field("File Path";"File Path")
                {
                }
                field("File Name";"File Name")
                {
                }
                field("Language ID";"Language ID")
                {

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Abbreviated Name";"Abbreviated Name")
                {
                }
                field("Delete Log After";"Delete Log After")
                {
                }
            }
            group(Repetition)
            {
                field(Recurrence;Recurrence)
                {
                }
                field("Recurrence Interval";"Recurrence Interval")
                {
                }
                field("Run on Monday";"Run on Monday")
                {
                }
                field("Run on Tuesday";"Run on Tuesday")
                {
                }
                field("Run on Wednesday";"Run on Wednesday")
                {
                }
                field("Run on Thursday";"Run on Thursday")
                {
                }
                field("Run on Friday";"Run on Friday")
                {
                }
                field("Run on Saturday";"Run on Saturday")
                {
                }
                field("Run on Sunday";"Run on Sunday")
                {
                }
                field("Valid After";"Valid After")
                {
                }
                field("Valid Until";"Valid Until")
                {
                }
                field("Recurrence Method";"Recurrence Method")
                {
                }
                field("Recurrence Calc. Interval";"Recurrence Calc. Interval")
                {
                }
                field("Recurrence Formula";"Recurrence Formula")
                {
                }
                field("Recurrence Time";"Recurrence Time")
                {
                }
                field("Retry Interval (On Error)";"Retry Interval (On Error)")
                {
                }
                field("Max No. Of Retries (On Error)";"Max No. Of Retries (On Error)")
                {
                }
                field("Action After Max. No. of Retri";"Action After Max. No. of Retri")
                {
                }
            }
            group("E-Mail")
            {
                field("Send E-Mail (On Start)";"Send E-Mail (On Start)")
                {
                }
                field("No. of E-Mail (On Start)";"No. of E-Mail (On Start)")
                {
                }
                field("Send E-Mail (On Error)";"Send E-Mail (On Error)")
                {
                }
                field("No. of E-Mail (On Error)";"No. of E-Mail (On Error)")
                {
                }
                field("First E-Mail After Error No.";"First E-Mail After Error No.")
                {
                }
                field("Last E-Mail After Error No.";"Last E-Mail After Error No.")
                {
                }
                field("Send E-Mail (On Success)";"Send E-Mail (On Success)")
                {
                }
                field("No. of E-Mail (On Success)";"No. of E-Mail (On Success)")
                {
                }
            }
            group(Parameters)
            {
                field("Table 1 No.";"Table 1 No.")
                {
                }
                field("Table 1 Filter";"Table 1 Filter")
                {
                }
                field("Task Parameters";"Task Parameters")
                {
                }
                field("No. of E-Mail (On Run)";"No. of E-Mail (On Run)")
                {
                }
                field("No. of E-Mail CC (On Run)";"No. of E-Mail CC (On Run)")
                {
                }
                field("No. of E-Mail BCC (On Run)";"No. of E-Mail BCC (On Run)")
                {
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
                    RunPageLink = "Journal Template Name"=FIELD("Journal Template Name"),
                                  "Journal Batch Name"=FIELD("Journal Batch Name"),
                                  "Line No."=FIELD("Line No.");
                    RunPageView = SORTING("Journal Template Name","Journal Batch Name","Line No.")
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

