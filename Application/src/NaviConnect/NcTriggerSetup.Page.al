page 6151521 "NPR Nc Trigger Setup"
{
    Extensible = False;
    Caption = 'Nc Trigger Setup';
    PageType = Card;
    SourceTable = "NPR Nc Trigger Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRNaviConnect;

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

