enum 6014546 "NPR NPRE Ord.ID Assign. Method"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = true;

    value(0; Default)
    {
        Caption = '<Default>';
    }
    value(1; "Same for Source Document")
    {
        Caption = 'Same for Source Document';
    }
    value(2; "New Each Time")
    {
        Caption = 'New Each Time';
    }
}