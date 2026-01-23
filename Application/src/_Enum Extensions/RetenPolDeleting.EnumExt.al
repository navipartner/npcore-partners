#if (BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
enumextension 6014404 "NPR Reten. Pol. Deleting" extends "Reten. Pol. Deleting"
{
    value(6014400; "NPR Data Archive")
    {
        Caption = 'Data Archive';
        Implementation = "Reten. Pol. Deleting" = "NPR Reten. Pol. Delete. Impl.";
    }
    value(6014401; "NPR Reten. Pol. Deleting")
    {
        Caption = 'NPR Custom Reten. Pol. Del.';
        Implementation = "Reten. Pol. Deleting" = "NPR Reten. Pol. Deleting Impl.";
    }
}
#endif