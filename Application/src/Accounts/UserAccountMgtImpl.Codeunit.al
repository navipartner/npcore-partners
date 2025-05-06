codeunit 6248404 "NPR UserAccountMgtImpl"
{
    Access = Internal;

    internal procedure CreateAccount(var UserAccount: Record "NPR UserAccount") AccountId: Guid
    var
        Setup: Record "NPR UserAccountSetup";
    begin
        if (not Setup.Get()) then
            Setup.Init();

        CheckUniqueness(Setup, UserAccount);

        UserAccount.SystemId := CreateGuid();
        UserAccount.Insert(true, false);

        AccountId := UserAccount.SystemId;
    end;

    internal procedure FindAccountByEmail(EmailAddress: Text[80]; var UserAccount: Record "NPR UserAccount") Found: Boolean
    begin
        UserAccount.Reset();
        UserAccount.SetFilter(EmailAddress, '=%1', EmailAddress.ToLower());
        Found := UserAccount.FindSet();
    end;

    internal procedure FindAccountByPhoneNo(PhoneNo: Text[80]; var UserAccount: Record "NPR UserAccount") Found: Boolean
    begin
        UserAccount.Reset();
        UserAccount.SetFilter(PhoneNo, '=%1', PhoneNo.ToLower());
        Found := UserAccount.FindSet();
    end;

    local procedure CheckUniqueness(Setup: Record "NPR UserAccountSetup"; UserAccount: Record "NPR UserAccount")
    var
        UserAccount2: Record "NPR UserAccount";
    begin
        if (UserAccount.EmailAddress = '') and ((UserAccount.PhoneNo = '') or (not Setup.RequireUniquePhoneNo)) then
            exit;

        UserAccount2.FilterGroup := -1;
        if (UserAccount.EmailAddress <> '') then
            UserAccount2.SetRange(EmailAddress, UserAccount.EmailAddress.Trim().ToLower());
        if (Setup.RequireUniquePhoneNo and (UserAccount.PhoneNo <> '')) then
            UserAccount2.SetRange(PhoneNo, UserAccount.PhoneNo);

        if (not UserAccount2.IsEmpty()) then
            Error('Account is not unique. Either phone number or e-mail address is already in use.');
    end;
}