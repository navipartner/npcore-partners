page 6151520 "Nc Triggers"
{
    // NC2.01/BR /20160809  CASE 247479 NaviConnect
    // NC2.01/BR /20161219 CASE 261431 Added fields Subscriber Codeunit ID and - Name, added Naviagtion to Tasks
    // NC2.03/BR /20170103  CASE 271242 Added field Error on Empty Output

    Caption = 'Nc Triggers';
    PageType = List;
    SourceTable = "Nc Trigger";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("Split Trigger and Endpoint";"Split Trigger and Endpoint")
                {
                }
                field(Enabled;Enabled)
                {
                }
                field("Error on Empty Output";"Error on Empty Output")
                {
                }
                field("Task Processor";"Task Processor")
                {
                }
                field("Linked Endpoints";"Linked Endpoints")
                {
                }
                field("Subscriber Codeunit ID";"Subscriber Codeunit ID")
                {
                }
                field("Subscriber Codeunit Name";"Subscriber Codeunit Name")
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Task Queue Entry")
            {
                Caption = 'Task Queue Entry';
                Image = JobTimeSheet;

                trigger OnAction()
                begin
                    RunTaskQueuePage;
                end;
            }
            action("Endpoint Links")
            {
                Caption = 'Endpoint Links';
                Image = Links;
                RunObject = Page "Nc Endpoint Trigger Links";
                RunPageLink = "Trigger Code"=FIELD(Code);
                RunPageView = SORTING("Trigger Code")
                              ORDER(Ascending);
            }
            action("Task List")
            {
                Caption = 'Task List';
                Image = TaskList;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Nc Task List";
                RunPageLink = "Record Value"=FIELD(Code);
                RunPageView = WHERE(Type=CONST(Insert),
                                    "Table No."=CONST(6151520));
            }
        }
    }

    trigger OnOpenPage()
    begin
        NcTriggerTaskMgt.OnSetupNcTriggers;
    end;

    var
        NcTriggerTaskMgt: Codeunit "Nc Trigger Task Mgt.";

    local procedure RunTaskQueuePage()
    var
        TaskLine: Record "Task Line";
        TaskLineParameters: Record "Task Line Parameters";
        TaskCard: Page "TQ Task Card";
        NcTriggerScheduler: Codeunit "Nc Trigger Scheduler";
    begin
        if NcTriggerScheduler.FindTaskLine(Rec,TaskLine,TaskLineParameters) then begin
          TaskCard.SetRecord(TaskLine);
          TaskCard.RunModal;
          Clear(TaskCard);
        end;
    end;
}

