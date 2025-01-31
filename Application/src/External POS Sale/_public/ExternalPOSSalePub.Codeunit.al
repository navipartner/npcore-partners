codeunit 6248222 "NPR External POS Sale Pub"
{
    Access = Public;

    [IntegrationEvent(false, false)]
    procedure OnExternalPOSSaleCustomerLookupByPhoneNo(phoneNo: Text[50]; var CustomerNo: Code[20]; var Handled: Boolean)
    begin
    end;
}