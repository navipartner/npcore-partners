report 6014440 "NPR POS Entry Sales & Payments"
{
#if not (BC17 or BC18 or BC19)
    ApplicationArea = NPRRetail;
    Caption = 'POS Entry Sales & Payments';
    DefaultRenderingLayout = ExcelLayout;
    Extensible = true;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(POSEntrySalePayment; "NPR POS Entry Sale & Payment")
        {
            column(POSEntryNo; "POS Entry No.")
            {
            }
            column(DocumentNo; "Document No.")
            {
            }
            column(SourceType; "Source Type")
            {
            }
            column(EntryDate; "Entry Date")
            {
            }
            column(StartingTime; "Starting Time")
            {
            }
            column(EndingTime; "Ending Time")
            {
            }
            column(POSStoode; "POS Store Code")
            {
            }
            column(POSUnitNo; "POS Unit No.")
            {
            }
            column(AmountInclVAT; "Amount Incl. VAT")
            {
            }
            column(CustomerNo; "Customer No.")
            {
            }
            column(Description; Description)
            {
            }
            column(Description2; "Description 2")
            {
            }
            column(LineDiscount; "Line Discount %")
            {
            }
            column(No; "No.")
            {
            }
            column(Quantity; Quantity)
            {
            }
            column(SalespersonCode; "Salesperson Code")
            {
            }
            column(Type; "Type")
            {
            }
            column(UnitPrice; "Unit Price")
            {
            }
            column(UnitofMeasureCode; "Unit of Measure Code")
            {
            }

        }
    }

    rendering
    {
        layout(ExcelLayout)
        {
            Caption = 'Excel layout to display and work with data from table POS Entry Sale & Payment.';
            LayoutFile = './src/_Reports/layouts/POS Entry Sales & Payments.xlsx';
            Type = Excel;
        }
    }

    trigger OnPreReport()
    var
        EntryNo: Text;
        LineNo: Integer;
    begin
        POSEntrySalePayment.FilterGroup(4);
        EntryNo := POSEntrySalePayment.GetFilter("POS Entry No.");
        POSEntrySalePayment.FilterGroup(0);
        LineNo := 1;

        AddSalesLines(EntryNo, LineNo);
        AddPaymentLines(EntryNo, LineNo);
    end;

    local procedure AddSalesLines(EntryNo: Text; var LineNo: Integer)
    var
        POSEntrySalesLine: Query "NPR POS Entry Sales Line";
    begin
        if EntryNo <> '' then
            POSEntrySalesLine.SetFilter(POS_Entry_No_, EntryNo);
        if POSEntrySalesLine.Open() then begin
            while POSEntrySalesLine.Read() do begin
                POSEntrySalePayment.Init();
                POSEntrySalePayment."POS Entry No." := POSEntrySalesLine.POS_Entry_No_;
                POSEntrySalePayment."Source Type" := POSEntrySalePayment."Source Type"::Sale;
                POSEntrySalePayment."Line No." := LineNo;
                LineNo += 1;

                POSEntrySalePayment."Document No." := POSEntrySalesLine.Document_No_;
                POSEntrySalePayment."POS Store Code" := POSEntrySalesLine.POS_Store_Code;
                POSEntrySalePayment."POS Unit No." := POSEntrySalesLine.POS_Unit_No_;
                POSEntrySalePayment."Salesperson Code" := POSEntrySalesLine.Salesperson_Code;
                POSEntrySalePayment.Type := POSEntrySalesLine.Type;
                POSEntrySalePayment."No." := POSEntrySalesLine.No_;
                POSEntrySalePayment.Description := POSEntrySalesLine.Description;
                POSEntrySalePayment."Description 2" := POSEntrySalesLine.Description_2;
                POSEntrySalePayment."Customer No." := POSEntrySalesLine.Customer_No_;
                POSEntrySalePayment.Quantity := POSEntrySalesLine.Quantity;
                POSEntrySalePayment."Unit of Measure Code" := POSEntrySalesLine.Unit_of_Measure_Code;
                POSEntrySalePayment."Unit Price" := POSEntrySalesLine.Unit_Price;
                POSEntrySalePayment."Line Discount %" := POSEntrySalesLine.Line_Discount__;
                POSEntrySalePayment."Amount Incl. VAT" := POSEntrySalesLine.Amount_Incl__VAT;
                POSEntrySalePayment.Insert();
            end;
        end;
    end;

    local procedure AddPaymentLines(EntryNo: Text; var LineNo: Integer)
    var
        POSEntryPaymentLine: Query "NPR POS Entry Payment Line";
    begin
        if EntryNo <> '' then
            POSEntryPaymentLine.SetFilter(POS_Entry_No_, EntryNo);
        if POSEntryPaymentLine.Open() then begin
            while POSEntryPaymentLine.Read() do begin
                POSEntrySalePayment.Init();
                POSEntrySalePayment."POS Entry No." := POSEntryPaymentLine.POS_Entry_No_;
                POSEntrySalePayment."Source Type" := POSEntrySalePayment."Source Type"::Payment;
                POSEntrySalePayment."Line No." := LineNo;
                LineNo += 1;

                POSEntrySalePayment."Document No." := POSEntryPaymentLine.Document_No_;
                POSEntrySalePayment."POS Store Code" := POSEntryPaymentLine.POS_Store_Code;
                POSEntrySalePayment."POS Unit No." := POSEntryPaymentLine.POS_Unit_No_;
                POSEntrySalePayment."Salesperson Code" := POSEntryPaymentLine.Salesperson_Code;
                POSEntrySalePayment.Type := POSEntrySalePayment.Type::" ";
                POSEntrySalePayment."No." := POSEntryPaymentLine.POS_Payment_Method_Code;
                POSEntrySalePayment.Description := POSEntryPaymentLine.Description;
                POSEntrySalePayment."Description 2" := '';
                POSEntrySalePayment."Customer No." := '';
                POSEntrySalePayment.Quantity := 0;
                POSEntrySalePayment."Unit of Measure Code" := '';
                POSEntrySalePayment."Unit Price" := POSEntryPaymentLine.Amount;
                POSEntrySalePayment."Line Discount %" := 0;
                POSEntrySalePayment."Amount Incl. VAT" := POSEntryPaymentLine.Amount__Sales_Currency_;
                POSEntrySalePayment.Insert();
            end;
        end;
    end;
#else
    UsageCategory = None;
#endif
}