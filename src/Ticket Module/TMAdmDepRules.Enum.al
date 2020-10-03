enum 6014400 "NPR TM Adm. Dep. Rules"
{
    Extensible = true;

    value(0; REQUIRED)
    {
        Caption = 'Required';
    }
    value(1; TIMEFRAME)
    {
        Caption = 'Timeframe';
    }

    value(2; EXCLUDE_OTHER)
    {
        Caption = 'Exclude (Not Self)';
    }

    value(3; STOP_ON_ADMISSION)
    {
        Caption = 'Break on Admission';
    }

    value(4; EXCLUDE_SELF)
    {
        Caption = 'Exclude (Self)';
    }

}