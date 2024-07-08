enum 6014400 "NPR TM Adm. Dep. Rules"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; REQUIRED)
    {
        Caption = 'Required';
    }
    value(1; TIMEFRAME)
    {
        Caption = 'Visit Within Timeframe';
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

    value(5; ADM_SCAN_FREQUENCY)
    {
        Caption = 'Adm. Scan Frequency (Minutes)';
    }

    value(8; DAILY_ADM_SCAN_COUNT)
    {
        Caption = 'Max Daily Admission Scans (Count)';
    }


}
