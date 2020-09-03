page 6059966 "NPR MPOS Nets Trx List"
{
    // NPR5.33/NPKNAV/20170630  CASE 267203 Transport NPR5.33 - 30 June 2017
    // NPR5.34/CLVA/20170703 CASE 280444 Upgrading MPOS functionality to transcendence
    // NPR5.51/CLVA/20190819 CASE 364011 Added field "EFT Transaction Entry No."

    Caption = 'MPOS Nets Transactions List';
    CardPageID = "NPR MPOS Nets Trans. Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR MPOS Nets Transactions";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Transaction No."; "Transaction No.")
                {
                    ApplicationArea = All;
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                }
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                }
                field("Sales Line No."; "Sales Line No.")
                {
                    ApplicationArea = All;
                }
                field("Session Id"; "Session Id")
                {
                    ApplicationArea = All;
                }
                field("Merchant Reference"; "Merchant Reference")
                {
                    ApplicationArea = All;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                }
                field("Callback Result"; "Callback Result")
                {
                    ApplicationArea = All;
                }
                field("Callback StatusDescription"; "Callback StatusDescription")
                {
                    ApplicationArea = All;
                }
                field("Created Date"; "Created Date")
                {
                    ApplicationArea = All;
                }
                field("EFT Transaction Entry No."; "EFT Transaction Entry No.")
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

