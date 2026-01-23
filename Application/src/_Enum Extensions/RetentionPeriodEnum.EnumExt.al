#if (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
enumextension 6014401 "NPR Retention Period Enum" extends "Retention Period Enum"
{
    value(6014400; "NPR 14 Days")
    {
        Caption = '14 Days';
        Implementation = "Retention Period" = "NPR Retention Period Impl.";
    }
    value(6014401; "NPR 2 Years")
    {
        Caption = '2 Years';
        Implementation = "Retention Period" = "NPR Retention Period Impl.";
    }
    value(6014402; "NPR 6 Years")
    {
        Caption = '6 Years';
        Implementation = "Retention Period" = "NPR Retention Period Impl.";
    }
}
#endif