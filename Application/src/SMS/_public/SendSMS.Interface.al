interface "NPR Send SMS"
{
#IF NOT BC17
    Access = Public;
#ENDIF
    procedure SendSMS(PhoneNo: Text; SenderNo: Text; Message: Text)

}
