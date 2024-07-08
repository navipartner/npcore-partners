enum 6014457 "NPR SMS Recipient Type"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; Field)
    {
        Caption = 'Field';
    }
    value(1; Group)
    {
        Caption = 'Group';
    }

}
