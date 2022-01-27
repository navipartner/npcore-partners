page 6151520 "NPR Nc Triggers"
{
    Extensible = False;
    Caption = 'Nc Triggers';
    PageType = List;
    SourceTable = "NPR Nc Trigger";
    UsageCategory = Lists;
    ApplicationArea = NPRNaviConnect;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Split Trigger and Endpoint"; Rec."Split Trigger and Endpoint")
                {

                    ToolTip = 'Specifies the value of the Split Trigger and Endpoint field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Enabled; Rec.Enabled)
                {

                    ToolTip = 'Specifies the value of the Enabled field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Error on Empty Output"; Rec."Error on Empty Output")
                {

                    ToolTip = 'Specifies the value of the Error on Empty Output field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Task Processor"; Rec."Task Processor")
                {

                    ToolTip = 'Specifies the value of the Task Processor field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Linked Endpoints"; Rec."Linked Endpoints")
                {

                    ToolTip = 'Specifies the value of the Linked Endpoints field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Subscriber Codeunit ID"; Rec."Subscriber Codeunit ID")
                {

                    ToolTip = 'Specifies the value of the Subscriber Codeunit ID field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Subscriber Codeunit Name"; Rec."Subscriber Codeunit Name")
                {

                    ToolTip = 'Specifies the value of the Subscriber Codeunit Name field';
                    ApplicationArea = NPRNaviConnect;
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

                ToolTip = 'Executes the Task Queue Entry action';
                ApplicationArea = NPRNaviConnect;

                trigger OnAction()
                begin
                    RunTaskQueuePage();
                end;
            }
            action("Endpoint Links")
            {
                Caption = 'Endpoint Links';
                Image = Links;
                RunObject = Page "NPR Nc Endpoint Trigger Links";
                RunPageLink = "Trigger Code" = FIELD(Code);
                RunPageView = SORTING("Trigger Code")
                              ORDER(Ascending);

                ToolTip = 'Executes the Endpoint Links action';
                ApplicationArea = NPRNaviConnect;
            }
            action("Task List")
            {
                Caption = 'Task List';
                Image = TaskList;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR Nc Task List";
                RunPageLink = "Record Value" = FIELD(Code);
                RunPageView = WHERE(Type = CONST(Insert),
                                    "Table No." = CONST(6151520));

                ToolTip = 'Executes the Task List action';
                ApplicationArea = NPRNaviConnect;
            }
        }
    }

    trigger OnOpenPage()
    begin
        NcTriggerTaskMgt.OnSetupNcTriggers();
    end;

    var
        NcTriggerTaskMgt: Codeunit "NPR Nc Trigger Task Mgt.";

    local procedure RunTaskQueuePage()
    var
        TaskLine: Record "NPR Task Line";
        TaskLineParameters: Record "NPR Task Line Parameters";
        TaskCard: Page "NPR TQ Task Card";
        NcTriggerScheduler: Codeunit "NPR Nc Trigger Scheduler";
    begin
        if NcTriggerScheduler.FindTaskLine(Rec, TaskLine, TaskLineParameters) then begin
            TaskCard.SetRecord(TaskLine);
            TaskCard.RunModal();
            Clear(TaskCard);
        end;
    end;
}

