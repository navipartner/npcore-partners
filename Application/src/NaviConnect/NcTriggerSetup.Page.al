page 6151521 "NPR Nc Trigger Setup"
{
    Caption = 'Nc Trigger Setup';
    PageType = Card;
    SourceTable = "NPR Nc Trigger Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Task Template Name"; Rec."Task Template Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Task Template Name field';
                }
                field("Task Batch Name"; Rec."Task Batch Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Task Batch Name field';
                }
            }
        }
    }
}

