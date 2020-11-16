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
                }
                field("Text"; Text)
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("Transaction Time"; "Transaction Time")
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
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                }
                field("Sales Ticket amount"; "Sales Ticket amount")
                {
                    ApplicationArea = All;
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

