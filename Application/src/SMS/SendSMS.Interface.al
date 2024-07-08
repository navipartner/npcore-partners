interface "NPR Send SMS"
{
    #IF NOT BC17 
    Access = Internal;      
    #ENDIF
    procedure SendSMS(PhoneNo: Text; SenderNo: Text; Message: Text)

}
