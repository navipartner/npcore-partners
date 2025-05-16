enum 6059900 "NPR TM NotificationMethod"
{
    Caption = 'Notification Method';
    Extensible = false;

    value(0; NA)
    {
        Caption = ' ', Locked = true;
    }
    value(1; EMAIL)
    {
        Caption = 'E-Mail';
    }
    value(2; SMS)
    {
        Caption = 'SMS';
    }
}