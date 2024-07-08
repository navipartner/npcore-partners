codeunit 6059795 "NPR Null PaymentHandler" implements "NPR POS IPaymentWFHandler"
{
    Access = Internal;

    procedure GetPaymentHandler(): Code[20]
    begin
        Error('The NULL handler has no implementation.');
    end;
}