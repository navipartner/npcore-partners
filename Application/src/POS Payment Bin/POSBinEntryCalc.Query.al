query 6014418 "NPR POS Bin Entry Calc."
{
    Caption = 'POS Bin Entry Calc. ';
    QueryType = Normal;
    Access = Internal;

    elements
    {
        dataitem(NPRPOSBinEntry; "NPR POS Bin Entry")
        {
            filter(PBE_EntryNo_Filter; "Entry No.") { }
            filter(PBE_PaymentBinNo_Filter; "Payment Bin No.") { }
            filter(PBE_PaymentMethodCode_Filter; "Payment Method Code") { }
            filter(PBE_Type_Filter; Type) { }
            filter(PBE_POSUnitNo_Filter; "POS Unit No.") { }

            column(PBE_TransactionAmount; "Transaction Amount")
            {
                Method = Sum;
            }
            column(PBE_RecordsCount)
            {
                Method = Count;
            }
        }
    }

    trigger OnBeforeOpen()
    begin
    end;
}