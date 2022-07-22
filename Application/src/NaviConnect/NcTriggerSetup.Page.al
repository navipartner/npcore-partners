page 6151521 "NPR Nc Trigger Setup"
{
    Extensible = False;
    Caption = 'Nc Trigger Setup';
    PageType = Card;
    SourceTable = "NPR Nc Trigger Setup";
    UsageCategory = None;

    ObsoleteState = Pending;
    ObsoleteReason = 'Task Queue module is about to be removed from NpCore so NC Trigger is also going to be removed.';
    ObsoleteTag = 'BC 20 - Task Queue deprecating starting from 28/06/2022';

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Task Template Name"; Rec."Task Template Name")
                {

                    ToolTip = 'Specifies the value of the Task Template Name field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Task Batch Name"; Rec."Task Batch Name")
                {

                    ToolTip = 'Specifies the value of the Task Batch Name field';
                    ApplicationArea = NPRNaviConnect;
                }
            }
        }
    }
}

