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
    value(4; DIGITAL_ORDER_NOTIFICATION)
    {
        Caption = 'Digital Order Notification';
        Implementation = "NPR IDynamicTemplateDataProvider" = "NPR NPEmailDigNotifDataProv";
    }
    value(5; POS_RECEIPT_EMAIL)
    {
        Caption = 'POS Receipt email';
        Implementation = "NPR IDynamicTemplateDataProvider" = "NPR NPEmailPOSRcptDataProv";
    }
    value(6; POST_SALES_DOC_NOTIFICATION)
    {
        Caption = 'Posted Sales Document Notification';
        Implementation = "NPR IDynamicTemplateDataProvider" = "NPR NPEmailPostSalesDataProv";
    }
}
