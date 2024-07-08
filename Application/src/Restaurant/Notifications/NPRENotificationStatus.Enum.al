enum 6014652 "NPR NPRE Notification Status"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = true;

    value(0; PENDING) { Caption = 'Pending'; }
    value(1; QUEUED) { Caption = 'Queued'; }
    value(2; SENT) { Caption = 'Sent'; }
    value(3; CANCELED) { Caption = 'Canceled'; }
    value(4; FAILED) { Caption = 'Failed'; }
    value(5; NOT_SENT) { Caption = 'Not Sent'; }
}
