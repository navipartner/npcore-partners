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
                field("Entry No";"Entry No")
                {
                }
                field("Customer No";"Customer No")
                {
                }
                field(Status;Status)
                {
                }
                field("Open Sales Documents";"Open Sales Documents")
                {
                }
                field("Open Cust. Ledger Entry";"Open Cust. Ledger Entry")
                {
                }
                field("Has transactions";"Has transactions")
                {
                }
                field("Customer is a Member";"Customer is a Member")
                {
                }
                field("Open Journal Entries/Statement";"Open Journal Entries/Statement")
                {
                }
                field("Log Entry Date Time";"Log Entry Date Time")
                {
                }
            }
        }
    }

    actions
    {
    }
}

