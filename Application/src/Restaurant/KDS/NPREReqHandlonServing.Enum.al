enum 6014545 "NPR NPRE Req.Handl.on Serving"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = true;

    value(0; Default)
    {
        Caption = '<Default>';
    }
    value(1; "Do Nothing")
    {
        Caption = 'Do Nothing';
    }
    value(2; "Finish Started")
    {
        Caption = 'Finish Started';
    }
    value(3; "Finish All")
    {
        Caption = 'Finish All';
    }
    value(4; "Finish Started/Cancel Not Started")
    {
        Caption = 'Finish Started/Cancel Not Started';
    }
    value(5; "Cancel All Unfinished")
    {
        Caption = 'Cancel All Unfinished';
    }
}