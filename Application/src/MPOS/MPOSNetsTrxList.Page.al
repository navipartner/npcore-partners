page 6059966 "NPR MPOS Nets Trx List"
{
    // NPR5.33/NPKNAV/20170630  CASE 267203 Transport NPR5.33 - 30 June 2017
    // NPR5.34/CLVA/20170703 CASE 280444 Upgrading MPOS functionality to transcendence
    // NPR5.51/CLVA/20190819 CASE 364011 Added field "EFT Transaction Entry No."

    Caption = 'MPOS Nets Transactions List';
    CardPageID = "NPR MPOS Nets Trans. Card";
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Transaction No. field';
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Register No. field';
                }
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                }
                field("Sales Line No."; "Sales Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Line No. field';
                }
                field("Session Id"; "Session Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Session Id field';
                }
                field("Merchant Reference"; "Merchant Reference")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Merchant Reference field';
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field("Callback Result"; "Callback Result")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback Result field';
                }
                field("Callback StatusDescription"; "Callback StatusDescription")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback StatusDescription field';
                }
                field("Created Date"; "Created Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created Date field';
                }
                field("EFT Transaction Entry No."; "EFT Transaction Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the EFT Transaction Entry No. field';
                }
            }
        }
    }

    actions
    {
    }
}

