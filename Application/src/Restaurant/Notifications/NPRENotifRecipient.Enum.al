enum 6014644 "NPR NPRE Notif. Recipient"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;
    Caption = 'Notification Recipient';

    value(0; TEMPLATE) { Caption = '<Defined in Template>'; }
    value(10; CUSTOMER) { Caption = 'Customer'; }
    value(20; WAITER) { Caption = 'Waiter/Salesperson'; }
    value(30; USER) { Caption = 'Specific User'; }
}
