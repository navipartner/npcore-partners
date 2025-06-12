codeunit 6248476 "NPR UserAccountMgt"
{
    procedure UpdateAccountEmail(FromEmail: Text[80]; ToEmail: Text[80])
    var
        UserAccountMgtImpl: Codeunit "NPR UserAccountMgtImpl";
    begin
        UserAccountMgtImpl.UpdateAccountEmail(FromEmail, ToEmail);
    end;
}