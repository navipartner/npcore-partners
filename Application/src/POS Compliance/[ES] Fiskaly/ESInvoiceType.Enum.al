enum 6059777 "NPR ES Invoice Type"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    value(1; SIMPLIFIED)
    {
        Caption = 'Simplified';
    }
    value(2; COMPLETE)
    {
        Caption = 'Complete';
    }
    value(3; CORRECTING)
    {
        Caption = 'Correcting';
    }
    value(4; ENRICHMENT)
    {
        Caption = 'Enrichment';
    }
    value(5; REMEDY)
    {
        Caption = 'Remedy';
    }
    value(6; EXTERNAL)
    {
        Caption = 'External';
    }
}
