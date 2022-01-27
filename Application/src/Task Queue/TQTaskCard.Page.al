page 6059903 "NPR TQ Task Card"
{
    Extensible = False;
    // TQ1.17/JDH/20141008 CASE 179044 If task is executed manually, the record filter was applied +
    //                                 call other function in order to log the execution of the task
    // TQ1.18.01/JDH/20141124 CASE 198851 Task Line not set correctly when running task manually (printer not found correct)
    // TQ1.24/JDH/20150320 CASE 209090 Possible to set the language on the task line
    // TQ1.28/MHA/20151216  CASE 229609 Task Queue
    // TQ1.29/JDH /20161101 CASE 242044 Added Images + Promoted category

    Caption = 'Task Card';
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR Task Line";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
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
                field("Call Object With Task Record"; Rec."Call Object With Task Record")
                {

                    ToolTip = 'Specifies the value of the Call Object With Task Record field';
                    ApplicationArea = NPRRetail;
                }
                field(Enabled; Rec.Enabled)
                {

                    ToolTip = 'Specifies the value of the Enabled field';
                    ApplicationArea = NPRRetail;
                }
                field(Priority; Rec.Priority)
                {

                    ToolTip = 'Specifies the value of the Priority field';
                    ApplicationArea = NPRRetail;
                }
                field("Task Worker Group"; Rec."Task Worker Group")
                {

                    ToolTip = 'Specifies the value of the Task Worker Group field';
                    ApplicationArea = NPRRetail;
                }
                field(Indentation; Rec.Indentation)
                {

                    ToolTip = 'Specifies the value of the Indentation field';
                    ApplicationArea = NPRRetail;
                }
                field("Dependence Type"; Rec."Dependence Type")
                {

                    ToolTip = 'Specifies the value of the Dependence Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Type Of Output"; Rec."Type Of Output")
                {

                    ToolTip = 'Specifies the value of the Type Of Output field';
                    ApplicationArea = NPRRetail;
                }
                field("Printer Name"; Rec."Printer Name")
                {

                    ToolTip = 'Specifies the value of the Printer Name field';
                    ApplicationArea = NPRRetail;
                }
                field("File Path"; Rec."File Path")
                {

                    ToolTip = 'Specifies the value of the File Path field';
                    ApplicationArea = NPRRetail;
                }
                field("File Name"; Rec."File Name")
                {

                    ToolTip = 'Specifies the value of the File Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Language ID"; Rec."Language ID")
                {

                    ToolTip = 'Specifies the value of the Language ID field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Abbreviated Name"; Rec."Abbreviated Name")
                {

                    ToolTip = 'Specifies the value of the Abbreviated Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Delete Log After"; Rec."Delete Log After")
                {

                    ToolTip = 'Specifies the value of the Delete Log After field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Repetition)
            {
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
                field("Run on Monday"; Rec."Run on Monday")
                {

                    ToolTip = 'Specifies the value of the Run on Monday field';
                    ApplicationArea = NPRRetail;
                }
                field("Run on Tuesday"; Rec."Run on Tuesday")
                {

                    ToolTip = 'Specifies the value of the Run on Tuesday field';
                    ApplicationArea = NPRRetail;
                }
                field("Run on Wednesday"; Rec."Run on Wednesday")
                {

                    ToolTip = 'Specifies the value of the Run on Wednesday field';
                    ApplicationArea = NPRRetail;
                }
                field("Run on Thursday"; Rec."Run on Thursday")
                {

                    ToolTip = 'Specifies the value of the Run on Thursday field';
                    ApplicationArea = NPRRetail;
                }
                field("Run on Friday"; Rec."Run on Friday")
                {

                    ToolTip = 'Specifies the value of the Run on Friday field';
                    ApplicationArea = NPRRetail;
                }
                field("Run on Saturday"; Rec."Run on Saturday")
                {

                    ToolTip = 'Specifies the value of the Run on Saturday field';
                    ApplicationArea = NPRRetail;
                }
                field("Run on Sunday"; Rec."Run on Sunday")
                {

                    ToolTip = 'Specifies the value of the Run on Sunday field';
                    ApplicationArea = NPRRetail;
                }
                field("Valid After"; Rec."Valid After")
                {

                    ToolTip = 'Specifies the value of the Valid After field';
                    ApplicationArea = NPRRetail;
                }
                field("Valid Until"; Rec."Valid Until")
                {

                    ToolTip = 'Specifies the value of the Valid Until field';
                    ApplicationArea = NPRRetail;
                }
                field("Recurrence Method"; Rec."Recurrence Method")
                {

                    ToolTip = 'Specifies the value of the Recurrence Method field';
                    ApplicationArea = NPRRetail;
                }
                field("Recurrence Calc. Interval"; Rec."Recurrence Calc. Interval")
                {

                    ToolTip = 'Specifies the value of the Recurrence Calculation Interval field';
                    ApplicationArea = NPRRetail;
                }
                field("Recurrence Formula"; Rec."Recurrence Formula")
                {

                    ToolTip = 'Specifies the value of the Recurrence Formula field';
                    ApplicationArea = NPRRetail;
                }
                field("Recurrence Time"; Rec."Recurrence Time")
                {

                    ToolTip = 'Specifies the value of the Recurrence Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Retry Interval (On Error)"; Rec."Retry Interval (On Error)")
                {

                    ToolTip = 'Specifies the value of the Retry Interval (On Error) field';
                    ApplicationArea = NPRRetail;
                }
                field("Max No. Of Retries (On Error)"; Rec."Max No. Of Retries (On Error)")
                {

                    ToolTip = 'Specifies the value of the Max No. Of Retries (On Error) field';
                    ApplicationArea = NPRRetail;
                }
                field("Action After Max. No. of Retri"; Rec."Action After Max. No. of Retri")
                {

                    ToolTip = 'Specifies the value of the Action After Max. No. of Retri field';
                    ApplicationArea = NPRRetail;
                }
            }
            group("E-Mail")
            {
                field("Send E-Mail (On Start)"; Rec."Send E-Mail (On Start)")
                {

                    ToolTip = 'Specifies the value of the Send Email On Start field';
                    ApplicationArea = NPRRetail;
                }
                field("No. of E-Mail (On Start)"; Rec."No. of E-Mail (On Start)")
                {

                    ToolTip = 'Specifies the value of the No. of Email On Start field';
                    ApplicationArea = NPRRetail;
                }
                field("Send E-Mail (On Error)"; Rec."Send E-Mail (On Error)")
                {

                    ToolTip = 'Specifies the value of the Send Email On Error field';
                    ApplicationArea = NPRRetail;
                }
                field("No. of E-Mail (On Error)"; Rec."No. of E-Mail (On Error)")
                {

                    ToolTip = 'Specifies the value of the No. of Email On Error field';
                    ApplicationArea = NPRRetail;
                }
                field("First E-Mail After Error No."; Rec."First E-Mail After Error No.")
                {

                    ToolTip = 'Specifies the value of the First E-Mail After Error No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Last E-Mail After Error No."; Rec."Last E-Mail After Error No.")
                {

                    ToolTip = 'Specifies the value of the Last E-Mail After Error No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Send E-Mail (On Success)"; Rec."Send E-Mail (On Success)")
                {

                    ToolTip = 'Specifies the value of the Send Email On Success field';
                    ApplicationArea = NPRRetail;
                }
                field("No. of E-Mail (On Success)"; Rec."No. of E-Mail (On Success)")
                {

                    ToolTip = 'Specifies the value of the No. of Email On Success field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Parameters)
            {
                field("Table 1 No."; Rec."Table 1 No.")
                {

                    ToolTip = 'Specifies the value of the Table 1 No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Table 1 Filter"; Rec."Table 1 Filter")
                {

                    ToolTip = 'Specifies the value of the Table 1 Filter field';
                    ApplicationArea = NPRRetail;
                }
                field("Task Parameters"; Rec."Task Parameters")
                {

                    ToolTip = 'Specifies the value of the Task Parameters field';
                    ApplicationArea = NPRRetail;
                }
                field("No. of E-Mail (On Run)"; Rec."No. of E-Mail (On Run)")
                {

                    ToolTip = 'Specifies the value of the No. of E-Mail (On Run) field';
                    ApplicationArea = NPRRetail;
                }
                field("No. of E-Mail CC (On Run)"; Rec."No. of E-Mail CC (On Run)")
                {

                    ToolTip = 'Specifies the value of the No. of E-Mail CC (On Run) field';
                    ApplicationArea = NPRRetail;
                }
                field("No. of E-Mail BCC (On Run)"; Rec."No. of E-Mail BCC (On Run)")
                {

                    ToolTip = 'Specifies the value of the No. of E-Mail BCC (On Run) field';
                    ApplicationArea = NPRRetail;
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

                    ToolTip = 'Executes the Task Log action';
                    ApplicationArea = NPRRetail;
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

                    ToolTip = 'Executes the Run Task action';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Executes the Report Request Page action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.RunReportRequestPage();
                    end;
                }
            }
        }
    }
}

