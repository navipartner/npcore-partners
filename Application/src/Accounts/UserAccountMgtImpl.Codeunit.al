codeunit 6248404 "NPR UserAccountMgtImpl"
{
    Access = Internal;

    internal procedure CreateAccount(var UserAccount: Record "NPR UserAccount") AccountId: Guid
    begin
        CheckUniqueness(UserAccount);

        UserAccount.SystemId := CreateGuid();
        UserAccount.Insert(true, false);

        AccountId := UserAccount.SystemId;
    end;

    internal procedure UpdateAccount(var AccountToUpdate: Record "NPR UserAccount"; TempUserAccount: Record "NPR UserAccount" temporary) IsModified: Boolean
    begin
        TempUserAccount.TestField(SystemId, AccountToUpdate.SystemId);

        CheckUniqueness(TempUserAccount);

        if (AccountToUpdate.FirstName <> TempUserAccount.FirstName) then begin
            AccountToUpdate.Validate(FirstName, TempUserAccount.FirstName);
            IsModified := true;
        end;

        if (AccountToUpdate.LastName <> TempUserAccount.LastName) then begin
            AccountToUpdate.Validate(LastName, TempUserAccount.LastName);
            IsModified := true;
        end;

        if (AccountToUpdate.EmailAddress <> TempUserAccount.EmailAddress) then begin
            AccountToUpdate.EmailAddress := TempUserAccount.EmailAddress;
            IsModified := true;
        end;

        if (AccountToUpdate.PhoneNo <> TempUserAccount.PhoneNo) then begin
            AccountToUpdate.PhoneNo := TempUserAccount.PhoneNo;
            IsModified := true;
        end;
    end;

    internal procedure UpdateAccountEmail(FromEmail: Text[80]; ToEmail: Text[80])
    var
        UserAccount: Record "NPR UserAccount";
        TempUserAccount: Record "NPR UserAccount" temporary;
    begin
#pragma warning disable AA0139
        if (not FindAccountByEmail(FromEmail.ToLower().Trim(), UserAccount)) then
#pragma warning restore AA0139
            exit;

        TempUserAccount := UserAccount;
#pragma warning disable AA0139
        TempUserAccount.EmailAddress := ToEmail.ToLower().Trim();
#pragma warning restore AA0139

        if (UpdateAccount(UserAccount, TempUserAccount)) then
            UserAccount.Modify();
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

    local procedure CheckUniqueness(UserAccount: Record "NPR UserAccount")
    var
        UserAccount2: Record "NPR UserAccount";
        Setup: Record "NPR UserAccountSetup";
    begin
        if (UserAccount.EmailAddress = '') and ((UserAccount.PhoneNo = '') or (not Setup.RequireUniquePhoneNo)) then
            exit;

        if (not Setup.Get()) then
            Setup.Init();

        // If we are checking uniqueness on an existing account, don't include self
        if (not IsNullGuid(UserAccount.SystemId)) then
            UserAccount2.SetFilter(SystemId, '<>%1', UserAccount.SystemId);

        UserAccount2.FilterGroup := -1;
        if (UserAccount.EmailAddress <> '') then
            UserAccount2.SetRange(EmailAddress, UserAccount.EmailAddress.Trim().ToLower());
        if (Setup.RequireUniquePhoneNo and (UserAccount.PhoneNo <> '')) then
            UserAccount2.SetRange(PhoneNo, UserAccount.PhoneNo);

        if (not UserAccount2.IsEmpty()) then
            Error('Account is not unique. Either phone number or e-mail address is already in use.');
    end;
}