page 6151151 "NPR Customer GDPR Log Entries"
{
    // NPR5.52/JAKUBV/20191022  CASE 358656 Transport NPR5.52 - 22 October 2019
    // NPR5.55/ZESO/20200427 CASE Added field Open Journal Entries/Statement

    Caption = 'Customer GDPR Log Entries';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR Customer GDPR Log Entries";
    UsageCategory = History;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No"; Rec."Entry No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No field';
                }
                field("Customer No"; Rec."Customer No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No field';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Open Sales Documents"; Rec."Open Sales Documents")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Open Sales Documents field';
                }
                field("Open Cust. Ledger Entry"; Rec."Open Cust. Ledger Entry")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Open Cust. Ledger Entry field';
                }
                field("Has transactions"; Rec."Has transactions")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Has transactions field';
                }
                field("Customer is a Member"; Rec."Customer is a Member")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer is a Member field';
                }
                field("Open Journal Entries/Statement"; Rec."Open Journal Entries/Statement")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Open Journal Entries/Statement field';
                }
                field("Log Entry Date Time"; Rec."Log Entry Date Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Log Entry Date Time field';
                }
            }
        }
    }

    actions
    {
    }
}

