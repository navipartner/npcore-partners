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
}