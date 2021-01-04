page 6014408 "NPR Credit card Trx List"
{
    // NPR5.40/TS  /20180307 CASE 307425 Deleted Field 101 ( "Sales Ticket amount" )
    // NPR5.40/TS  /20180320 CASE 308381 Removed Text Constants as not beuing used.
    // NPR5.43/JDH /20180702 CASE 321012 Reintroduces Field 101 (Sales Ticket amount) - some customers was using it
    // NPR5.46/MMV /20181001 CASE 290734 EFT Framework refactoring.

    Caption = 'Credit Card Transaction List';
    CardPageID = "NPR Credit Card Trx Receipt";
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR EFT Receipt";
    SourceTableView = WHERE(Type = FILTER(0 | 3 | 10));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Date"; Date)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date field';
                }
                field("Text"; Text)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Text field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Transaction Time"; "Transaction Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction Time field';
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
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                }
                field("Sales Ticket amount"; "Sales Ticket amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Ticket amount field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Print)
            {
                Caption = 'Print';
                action("&Print")
                {
                    Caption = 'Print';
                    Image = Print;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Print action';

                    trigger OnAction()
                    var
                        trans: Record "NPR EFT Receipt";
                    begin

                        trans.SetRange(trans."Register No.", "Register No.");
                        trans.SetRange("Sales Ticket No.", "Sales Ticket No.");
                        trans.SetRange(Type, 0);
                        //-NPR5.46 [290734]
                        //trans.PrintTerminalReceipt(FALSE);
                        trans.PrintTerminalReceipt();
                        //+NPR5.46 [290734]
                        CurrPage.Close();
                    end;
                }
            }
        }
    }
}

