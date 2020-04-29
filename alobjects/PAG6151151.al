page 6151151 "Customer GDPR Log Entries"
{
    // NPR5.52/JAKUBV/20191022  CASE 358656 Transport NPR5.52 - 22 October 2019

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

