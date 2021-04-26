page 6151520 "NPR Nc Triggers"
{
    Caption = 'Nc Triggers';
    PageType = List;
    SourceTable = "NPR Nc Trigger";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Split Trigger and Endpoint"; Rec."Split Trigger and Endpoint")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Split Trigger and Endpoint field';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enabled field';
                }
                field("Error on Empty Output"; Rec."Error on Empty Output")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Error on Empty Output field';
                }
                field("Task Processor"; Rec."Task Processor")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Task Processor field';
                }
                field("Linked Endpoints"; Rec."Linked Endpoints")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Linked Endpoints field';
                }
                field("Subscriber Codeunit ID"; Rec."Subscriber Codeunit ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Subscriber Codeunit ID field';
                }
                field("Subscriber Codeunit Name"; Rec."Subscriber Codeunit Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Subscriber Codeunit Name field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Task Queue Entry action';

                trigger OnAction()
                begin
                    RunTaskQueuePage;
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
                ApplicationArea = All;
                ToolTip = 'Executes the Endpoint Links action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Task List action';
            }
        }
    }

    trigger OnOpenPage()
    begin
        NcTriggerTaskMgt.OnSetupNcTriggers;
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

