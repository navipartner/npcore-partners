page 6151501 "NPR Nc Task Setup"
{
    Extensible = False;
    Caption = 'NaviConnect Task Setup';
    PageType = List;
    SourceTable = "NPR Nc Task Setup";
    SourceTableView = SORTING("Table No.");
    UsageCategory = Administration;
    ApplicationArea = NPRNaviConnect;

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Task Processor Code"; Rec."Task Processor Code")
                {

                    ToolTip = 'Specifies the value of the Task Processor Code field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Table No."; Rec."Table No.")
                {

                    ToolTip = 'Specifies the value of the Table No. field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Table Name"; Rec."Table Name")
                {

                    ToolTip = 'Specifies the value of the Table Name field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Codeunit ID"; Rec."Codeunit ID")
                {

                    ToolTip = 'Specifies the value of the Codeunit ID field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Codeunit Name"; Rec."Codeunit Name")
                {

                    ToolTip = 'Specifies the value of the Codeunit Name field';
                    ApplicationArea = NPRNaviConnect;
                }
            }
        }
    }
}

