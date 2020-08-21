page 6151151 "Customer GDPR Log Entries"
{
    // NPR5.52/JAKUBV/20191022  CASE 358656 Transport NPR5.52 - 22 October 2019
    // NPR5.55/ZESO/20200427 CASE Added field Open Journal Entries/Statement

    Caption = 'Customer GDPR Log Entries';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Customer GDPR Log Entries";
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No"; "Entry No")
                {
                    ApplicationArea = All;
                }
                field("Customer No"; "Customer No")
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field("Open Sales Documents"; "Open Sales Documents")
                {
                    ApplicationArea = All;
                }
                field("Open Cust. Ledger Entry"; "Open Cust. Ledger Entry")
                {
                    ApplicationArea = All;
                }
                field("Has transactions"; "Has transactions")
                {
                    ApplicationArea = All;
                }
                field("Customer is a Member"; "Customer is a Member")
                {
                    ApplicationArea = All;
                }
                field("Open Journal Entries/Statement"; "Open Journal Entries/Statement")
                {
                    ApplicationArea = All;
                }
                field("Log Entry Date Time"; "Log Entry Date Time")
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

