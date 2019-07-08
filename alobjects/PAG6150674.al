page 6150674 "POS Prepayment Invoices"
{
    // NPR5.50/MMV /20190417 CASE 300557 Created object

    Caption = 'POS Prepayment Invoices';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Sales Invoice Header";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No.";"No.")
                {

                    trigger OnDrillDown()
                    var
                        SalesInvoiceHeader: Record "Sales Invoice Header";
                    begin
                        SalesInvoiceHeader.Get("No.");
                        PAGE.RunModal(PAGE::"Posted Sales Invoice", SalesInvoiceHeader);
                    end;
                }
                field("Due Date";"Due Date")
                {
                }
                field("Amount Including VAT";"Amount Including VAT")
                {
                }
                field(FullyPaid;FullyPaid)
                {
                    Caption = 'Fully Paid';
                }
                field(RemainingAmount;RemainingAmount)
                {
                    Caption = 'Remaining Payment';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        SetPaymentStatus()
    end;

    var
        FullyPaid: Boolean;
        RemainingAmount: Decimal;

    local procedure SetPaymentStatus()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        FullyPaid := false;
        RemainingAmount := "Amount Including VAT";

        CustLedgerEntry.SetAutoCalcFields("Remaining Amt. (LCY)");
        CustLedgerEntry.SetRange("Customer No.", "Bill-to Customer No.");
        CustLedgerEntry.SetRange("Document No.", "No.");
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        if not CustLedgerEntry.FindFirst then
          exit;

        RemainingAmount := CustLedgerEntry."Remaining Amt. (LCY)";
        FullyPaid := not CustLedgerEntry.Open;
    end;
}

