page 6151501 "Nc Task Setup"
{
    // NC1.00/MH/20150113  CASE 199932 Refactored object from Web Integration
    // NC1.01/MH/20150115  CASE 199932 Changed SourceTableView to SORTING(Table No.)
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect

    Caption = 'NaviConnect Task Setup';
    PageType = List;
    SourceTable = "Nc Task Setup";
    SourceTableView = SORTING("Table No.");
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Task Processor Code"; "Task Processor Code")
                {
                    ApplicationArea = All;
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                }
                field("Codeunit ID"; "Codeunit ID")
                {
                    ApplicationArea = All;
                }
                field("Codeunit Name"; "Codeunit Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

