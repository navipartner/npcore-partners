#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
enum 6014633 "NPR Retention Period Type"
{
    Extensible = true;

    value(0; "Period 1")
    {
        Caption = 'Period 1';
    }
    value(1; "Period 2")
    {
        Caption = 'Period 2';
    }
    value(2; "Period 3")
    {
        Caption = 'Period 3';
    }
}
#endif