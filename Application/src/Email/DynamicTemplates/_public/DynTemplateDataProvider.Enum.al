#if not (BC17 or BC18 or BC19 or BC20 or BC21)
enum 6059867 "NPR DynTemplateDataProvider" implements "NPR IDynamicTemplateDataProvider"
{
    Access = public;
    Extensible = true;

    value(0; UNDEFINED)
    {
        Caption = ' ', Locked = true;
        Implementation = "NPR IDynamicTemplateDataProvider" = "NPR NPEmailUndefDataProvider";
    }
    value(1; MEMBER_NOTIFICATION)
    {
        Caption = 'Member Notification';
        Implementation = "NPR IDynamicTemplateDataProvider" = "NPR NPEmailMemberDataProvider";
    }
    value(2; TICKET_NOTIFICATION)
    {
        Caption = 'Ticket Notification';
        Implementation = "NPR IDynamicTemplateDataProvider" = "NPR NPEmailTicketDataProvider";
    }
    value(3; VOUCHER_EMAIL)
    {
        Caption = 'Voucher email';
        Implementation = "NPR IDynamicTemplateDataProvider" = "NPR NPEmailVoucherDataProvider";
    }
}
#endif