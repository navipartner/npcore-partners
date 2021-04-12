page 6150674 "NPR POS Prepaym. Invoices"
{
    // NPR5.50/MMV /20190417 CASE 300557 Created object

    Caption = 'POS Prepayment Invoices';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "Sales Invoice Header";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';

                    trigger OnDrillDown()
                    var
                        SalesInvoiceHeader: Record "Sales Invoice Header";
                    begin
                        SalesInvoiceHeader.Get(Rec."No.");
                        PAGE.RunModal(PAGE::"Posted Sales Invoice", SalesInvoiceHeader);
                    end;
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Due Date field';
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Including VAT field';
                }
                field(FullyPaid; FullyPaid)
                {
                    ApplicationArea = All;
                    Caption = 'Fully Paid';
                    ToolTip = 'Specifies the value of the Fully Paid field';
                }
                field(RemainingAmount; RemainingAmount)
                {
                    ApplicationArea = All;
                    Caption = 'Remaining Payment';
                    ToolTip = 'Specifies the value of the Remaining Payment field';
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
        RemainingAmount := Rec."Amount Including VAT";

        CustLedgerEntry.SetAutoCalcFields("Remaining Amt. (LCY)");
        CustLedgerEntry.SetRange("Customer No.", Rec."Bill-to Customer No.");
        CustLedgerEntry.SetRange("Document No.", Rec."No.");
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        if not CustLedgerEntry.FindFirst() then
            exit;

        RemainingAmount := CustLedgerEntry."Remaining Amt. (LCY)";
        FullyPaid := not CustLedgerEntry.Open;
    end;
}

