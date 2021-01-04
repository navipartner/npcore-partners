page 6151521 "NPR Nc Trigger Setup"
{
    // NC2.01/BR /20160816  CASE 247479 NaviConnect

    Caption = 'Nc Trigger Setup';
    PageType = Card;
    SourceTable = "NPR Nc Trigger Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Task Template Name"; "Task Template Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Task Template Name field';
                }
                field("Task Batch Name"; "Task Batch Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Task Batch Name field';
                }
            }
        }
    }

    actions
    {
    }
}

