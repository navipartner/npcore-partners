report 6014498 "NPR Cash Summary"
{
#IF NOT BC17
    Extensible = False; 
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/CashSummary.rdlc';
    Caption = 'Cash Summary';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    PreviewMode = PrintLayout;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(POS_Unit; "NPR POS Unit")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.";
            dataitem(POSPaymentMethod; "NPR POS Payment Method")
            {
                DataItemTableView = sorting(Code) where("Processing Type" = filter(CASH));
                RequestFilterFields = Code;
                dataitem(POSBinEntry; "NPR POS Bin Entry")
                {
                    DataItemTableView = SORTING("Entry No.") where(Type = filter('OUTPAYMENT' | 'INPAYMENT' | 'FLOAT' | 'BANK_TRANSFER_OUT' | 'BANK_TRANSFER_IN' | 'BIN_TRANSFER_OUT' | 'BIN_TRANSFER_IN'));
                    DataItemLink = "Payment Method Code" = field(Code);
                    column(POS_Unit_No_; "POS Unit No.")
                    {
                        IncludeCaption = true;
                    }
                    column(Status; POS_Unit.Status)
                    {
                        IncludeCaption = true;
                    }
                    column(Payment_Method_Code; "Payment Method Code")
                    {
                        IncludeCaption = true;
                    }
                    column(Payment_Bin_No_; "Payment Bin No.")
                    {
                        IncludeCaption = true;
                    }
                    column(Transaction_Amount; "Transaction Amount")
                    {
                        IncludeCaption = true;
                    }
                    column(Transaction_Amount_LCY; "Transaction Amount (LCY)")
                    {
                        IncludeCaption = true;
                    }

                    trigger OnPreDataItem()
                    begin
                        FirstEntry := 0;
                        FirstEntry := FindLastFloat(POS_Unit."Default POS Payment Bin", POSPaymentMethod.Code);
                        if FirstEntry <> 0 then
                            SetFilter("Entry No.", '>=%1', FirstEntry);
                        SetRange("POS Unit No.", POS_Unit."No.");
                        SetRange("Payment Bin No.", POS_Unit."Default POS Payment Bin");
                    end;
                }

            }
        }
    }
    labels
    {
        Total_Caption = 'Total:';
    }
    var
        FirstEntry: Integer;

    local procedure FindLastFloat(BinNo: Code[10]; PaymentMethod: Code[10]): Integer
    var
        BinEntry: Record "NPR POS Bin Entry";
    begin
        BinEntry.SetCurrentKey("Entry No.");
        BinEntry.SetRange("Payment Bin No.", BinNo);
        BinEntry.SetRange("Payment Method Code", PaymentMethod);
        BinEntry.SetRange(Type, BinEntry.Type::FLOAT);
        if BinEntry.FindLast() then
            exit(BinEntry."Entry No.")
        else
            exit(0);
    end;
}