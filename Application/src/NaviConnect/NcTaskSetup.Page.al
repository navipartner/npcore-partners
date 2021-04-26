page 6151501 "NPR Nc Task Setup"
{
    Caption = 'NaviConnect Task Setup';
    PageType = List;
    SourceTable = "NPR Nc Task Setup";
    SourceTableView = SORTING("Table No.");
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Task Processor Code"; Rec."Task Processor Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Task Processor Code field';
                }
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table No. field';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Name field';
                }
                field("Codeunit ID"; Rec."Codeunit ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Codeunit ID field';
                }
                field("Codeunit Name"; Rec."Codeunit Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Codeunit Name field';
                }
            }
        }
    }
}

