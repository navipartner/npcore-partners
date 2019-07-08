page 6059966 "MPOS Nets Transactions List"
{
    // NPR5.33/NPKNAV/20170630  CASE 267203 Transport NPR5.33 - 30 June 2017
    // NPR5.34/CLVA/20170703 CASE 280444 Upgrading MPOS functionality to transcendence

    Caption = 'MPOS Nets Transactions List';
    CardPageID = "MPOS Nets Transactions Card";
    Editable = false;
    PageType = List;
    SourceTable = "MPOS Nets Transactions";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Transaction No.";"Transaction No.")
                {
                }
                field("Register No.";"Register No.")
                {
                }
                field("Sales Ticket No.";"Sales Ticket No.")
                {
                }
                field("Sales Line No.";"Sales Line No.")
                {
                }
                field("Session Id";"Session Id")
                {
                }
                field("Merchant Reference";"Merchant Reference")
                {
                }
                field(Amount;Amount)
                {
                }
                field("Callback Result";"Callback Result")
                {
                }
                field("Callback StatusDescription";"Callback StatusDescription")
                {
                }
                field("Created Date";"Created Date")
                {
                }
            }
        }
    }

    actions
    {
    }
}

