enum 6059939 "NPR MM Memb. Points Doc. Type"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-04-06';
    ObsoleteReason = 'The Document Type field cannot always have 100% correct value. At the moment it is being used in receiptList API only. (Which is still in BETA phase)';
    Extensible = false;

    value(0; NA)
    {
        Caption = '';
    }
    value(1; SALES_INVOICE)
    {
        Caption = 'Sales Invoice';
    }
    value(2; POS_ENTRY)
    {
        Caption = 'POS Entry';
    }
    value(3; SALES_CR_MEMO)
    {
        Caption = 'Sales Cr.Memo';
    }
}
