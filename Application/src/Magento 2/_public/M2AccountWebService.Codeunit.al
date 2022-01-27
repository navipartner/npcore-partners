codeunit 6151150 "NPR M2 Account WebService"
{
    procedure AuthenticateAccountPassword(var M2Authenticate: XMLport "NPR M2 Authenticate")
    var
        TempOneTimePassword: Record "NPR M2 One Time Password" temporary;
        TempContact: Record Contact temporary;
    begin

        SelectLatestVersion();

        M2Authenticate.Import();
        M2Authenticate.GetRequest(TempOneTimePassword);

        if (DoAuthenticatePassword(TempOneTimePassword, TempContact)) then begin
            M2Authenticate.SetResponse(TempContact);

        end else begin
            M2Authenticate.SetErrorResponse(GetLastErrorText);

        end;
    end;

    procedure RequestPasswordReset(var M2ResetAccountPassword: XMLport "NPR M2 Reset Account Password")
    var
        TempOneTimePassword: Record "NPR M2 One Time Password" temporary;
    begin

        SelectLatestVersion();

        M2ResetAccountPassword.Import();
        M2ResetAccountPassword.GetRequest(TempOneTimePassword);
        if (DoResetPassword(TempOneTimePassword)) then begin
            M2ResetAccountPassword.SetResponse();
        end else begin
            M2ResetAccountPassword.SetErrorResponse(GetLastErrorText);
        end;
    end;

    procedure ChangeAccountPassword(var M2ChangeAccountPassword: XMLport "NPR M2 Change Account Password")
    var
        TempOneTimePassword: Record "NPR M2 One Time Password" temporary;
        TempContact: Record Contact temporary;
    begin

        SelectLatestVersion();

        M2ChangeAccountPassword.Import();
        M2ChangeAccountPassword.GetRequest(TempOneTimePassword);

        if (DoChangePassword(TempOneTimePassword, TempContact)) then begin
            M2ChangeAccountPassword.SetResponse(TempContact);

        end else begin
            M2ChangeAccountPassword.SetErrorResponse(GetLastErrorText);

        end;
    end;

    procedure GetAccountDetails(var M2GetAccount: XMLport "NPR M2 Get Account")
    var
        ContactNo: Code[20];
        TempContact: Record Contact temporary;
        TempSellToCustomer: Record Customer temporary;
        TempBillToCustomer: Record Customer temporary;
        TempShipToAddress: Record "Ship-to Address" temporary;
    begin

        SelectLatestVersion();

        M2GetAccount.Import();
        ContactNo := M2GetAccount.GetRequest();

        if (DoGetAccount(ContactNo, TempContact, TempSellToCustomer, TempBillToCustomer, TempShipToAddress)) then begin
            M2GetAccount.SetResponse(TempContact, TempSellToCustomer, TempBillToCustomer, TempShipToAddress);

        end else begin
            M2GetAccount.SetErrorResponse(GetLastErrorText());

        end;
    end;

    procedure UpdateAccount(var M2UpdateAccount: XMLport "NPR M2 Update Account")
    var
        TempContact: Record Contact temporary;
        TempCustomer: Record Customer temporary;
        TempAccount: Record Contact temporary;
    begin

        SelectLatestVersion();

        M2UpdateAccount.Import();
        M2UpdateAccount.GetRequest(TempContact, TempCustomer);

        if (DoUpdateAccount(TempContact, TempCustomer, TempAccount)) then begin
            M2UpdateAccount.SetResponse(TempAccount);

        end else begin
            M2UpdateAccount.SetErrorResponse(GetLastErrorText());

        end;
    end;

    procedure CreateCorporateAccount(var M2CreateCorporateAccount: XMLport "NPR M2 Create Corporate Acc.")
    var
        TempContact: Record Contact temporary;
        TempCustomer: Record Customer temporary;
        TempAccount: Record Contact temporary;
    begin

        SelectLatestVersion();

        M2CreateCorporateAccount.Import();
        M2CreateCorporateAccount.GetRequest(TempContact, TempCustomer);

        if (DoCreateAccount(TempContact, TempCustomer, TempAccount)) then begin
            M2CreateCorporateAccount.SetResponse(TempAccount);

        end else begin
            M2CreateCorporateAccount.SetErrorResponse(GetLastErrorText());

        end;
    end;

    procedure AddPersonAccount(var M2AddAccount: XMLport "NPR M2 Add Account")
    var
        TempContact: Record Contact temporary;
        TempAccount: Record Contact temporary;
    begin

        SelectLatestVersion();

        M2AddAccount.Import();
        M2AddAccount.GetRequest(TempContact);

        if (DoAddAccount(TempContact, TempAccount)) then begin
            M2AddAccount.SetResponse(TempAccount);

        end else begin
            M2AddAccount.SetErrorResponse(GetLastErrorText());

        end;
    end;

    procedure DeleteAccount(var M2DeleteAccount: XMLport "NPR M2 Delete Account")
    var
        ContactNo: Code[20];
    begin

        SelectLatestVersion();

        M2DeleteAccount.Import();
        ContactNo := M2DeleteAccount.GetRequest();

        if (DoDeleteAccount(ContactNo)) then begin
            M2DeleteAccount.SetResponse();

        end else begin
            M2DeleteAccount.SetErrorResponse(GetLastErrorText());

        end;
    end;

    procedure AddShiptoAddress(var M2AddShiptoAddress: XMLport "NPR M2 Add Shipto Address")
    var
        TempAccount: Record Contact temporary;
        TempShiptoAddressRequest: Record "Ship-to Address" temporary;
        TempShiptoAddressResponse: Record "Ship-to Address" temporary;
    begin

        SelectLatestVersion();

        M2AddShiptoAddress.Import();
        M2AddShiptoAddress.GetRequest(TempAccount, TempShiptoAddressRequest);

        if (DoAddShiptoAddress(TempAccount, TempShiptoAddressRequest, TempShiptoAddressResponse)) then begin
            M2AddShiptoAddress.SetResponse(TempShiptoAddressResponse);

        end else begin
            M2AddShiptoAddress.SetErrorResponse(GetLastErrorText());

        end;
    end;

    procedure UpdateShiptoAddress(var M2UpdateShiptoAddress: XMLport "NPR M2 Update Shipto Address")
    var
        TempAccount: Record Contact temporary;
        TempShiptoAddressRequest: Record "Ship-to Address" temporary;
        TempShiptoAddressResponse: Record "Ship-to Address" temporary;
    begin

        SelectLatestVersion();

        M2UpdateShiptoAddress.Import();
        M2UpdateShiptoAddress.GetRequest(TempAccount, TempShiptoAddressRequest);

        if (DoUpdateShiptoAddress(TempAccount, TempShiptoAddressRequest, TempShiptoAddressResponse)) then begin
            M2UpdateShiptoAddress.SetResponse(TempShiptoAddressResponse);

        end else begin
            M2UpdateShiptoAddress.SetErrorResponse(GetLastErrorText());

        end;
    end;

    procedure DeleteShiptoAddress(var M2DeleteShiptoAddress: XMLport "NPR M2 Delete Shipto Address")
    var
        TempAccount: Record Contact temporary;
        TempShiptoAddressRequest: Record "Ship-to Address" temporary;
    begin

        SelectLatestVersion();

        M2DeleteShiptoAddress.Import();
        M2DeleteShiptoAddress.GetRequest(TempAccount, TempShiptoAddressRequest);

        if (DoDeleteShiptoAddress(TempAccount, TempShiptoAddressRequest)) then begin
            M2DeleteShiptoAddress.SetResponse();

        end else begin
            M2DeleteShiptoAddress.SetErrorResponse(GetLastErrorText());

        end;
    end;

    procedure GetExtendedAccountDetails(var GetExtendedAccount: XMLport "NPR M2 Get Extended Account")
    var
        ContactNo: Code[20];
        TempContact: Record Contact temporary;
        TempSellToCustomer: Record Customer temporary;
        TempBillToCustomer: Record Customer temporary;
        TempShipToAddress: Record "Ship-to Address" temporary;
    begin
        SelectLatestVersion();

        GetExtendedAccount.Import();
        ContactNo := GetExtendedAccount.GetRequest();

        if (DoGetAccount(ContactNo, TempContact, TempSellToCustomer, TempBillToCustomer, TempShipToAddress)) then begin
            GetExtendedAccount.SetResponse(TempContact, TempSellToCustomer, TempBillToCustomer);

        end else begin
            GetExtendedAccount.SetErrorResponse(GetLastErrorText());

        end;
    end;

    procedure ListMailGroupsForAccount(ContactNo: Code[20]; var ListMailingGroups: XMLport "NPR M2 List Mailing Groups")
    begin
        SelectLatestVersion();
        ListMailingGroups.CreateListForContact(ContactNo);
    end;

    procedure AddAccountToMailGroup(ContactNo: Code[20]; MailGroupCode: Code[10]; var ListMailingGroups: XMLport "NPR M2 List Mailing Groups")
    var
        ContactMailingGroup: Record "Contact Mailing Group";
    begin
        SelectLatestVersion();

        if (not ContactMailingGroup.Get(ContactNo, MailGroupCode)) then begin
            ContactMailingGroup.Validate("Contact No.", ContactNo);
            ContactMailingGroup.Validate("Mailing Group Code", MailGroupCode);
            ContactMailingGroup.Insert(true);
        end;

        ListMailingGroups.CreateListForContact(ContactNo);
    end;

    procedure RemoveAccountFromMailGroup(ContactNo: Code[20]; MailGroupCode: Code[10]; var ListMailingGroups: XMLport "NPR M2 List Mailing Groups")
    var
        ContactMailingGroup: Record "Contact Mailing Group";
    begin
        SelectLatestVersion();

        if (ContactMailingGroup.Get(ContactNo, MailGroupCode)) then begin
            ContactMailingGroup.Delete(true);
        end;

        ListMailingGroups.CreateListForContact(ContactNo);
    end;

    procedure GetShopperRecognition(var ShopperRecognition: XMLport "NPR M2 Shopper Recognition")
    var
        TempEFTShopperRecognition: Record "NPR EFT Shopper Recognition" temporary;
        EFTShopperRecognition: Codeunit "NPR EFT Shopper Recognition";
        IntegrationTypeLbl: Label 'Integration Type "%1" exist with differnt Shopper Reference value for "%2" "%3", replace is not supported.', Locked = true;
    begin
        SelectLatestVersion();
        ShopperRecognition.Import();
        ShopperRecognition.GetRequest(TempEFTShopperRecognition);

        if (not EFTShopperRecognition.GetShopperReference(TempEFTShopperRecognition)) then
            if (not EFTShopperRecognition.CreateShopperReference(TempEFTShopperRecognition)) then
                ShopperRecognition.SetErrorResponse(
                  StrSubstNo(IntegrationTypeLbl,
                    TempEFTShopperRecognition."Integration Type", Format(TempEFTShopperRecognition."Entity Type"), TempEFTShopperRecognition."Entity Key"));

        ShopperRecognition.SetResponse(TempEFTShopperRecognition);
    end;

    local procedure DoAuthenticatePassword(var TmpOneTimePassword: Record "NPR M2 One Time Password" temporary; var TmpContact: Record Contact temporary): Boolean
    var
        AccountManager: Codeunit "NPR M2 Account Manager";
        ReasonText: Text;
    begin

        exit(AccountManager.AuthenticatePassword(TmpOneTimePassword, TmpContact, ReasonText));
    end;

    procedure DoChangePassword(var TmpOneTimePassword: Record "NPR M2 One Time Password" temporary; var TmpContact: Record Contact temporary): Boolean
    var
        AccountManager: Codeunit "NPR M2 Account Manager";
        ReasonText: Text;
    begin

        exit(AccountManager.ChangePassword(TmpOneTimePassword, TmpContact, ReasonText));
    end;

    local procedure DoResetPassword(var TmpOneTimePassword: Record "NPR M2 One Time Password" temporary): Boolean
    var
        AccountManager: Codeunit "NPR M2 Account Manager";
        ReasonText: Text;
    begin

        exit(AccountManager.ResetPassword(TmpOneTimePassword, ReasonText));
    end;

    local procedure DoGetAccount(ContactNo: Code[20]; var TmpContact: Record Contact temporary; var TmpSellToCustomer: Record Customer temporary; var TmpBillToCustomer: Record Customer temporary; var TmpShipToAddress: Record "Ship-to Address" temporary): Boolean
    var
        AccountManager: Codeunit "NPR M2 Account Manager";
    begin

        exit(AccountManager.GetAccount(ContactNo, TmpContact, TmpSellToCustomer, TmpBillToCustomer, TmpShipToAddress));
    end;

    local procedure DoCreateAccount(var TmpContact: Record Contact temporary; var TmpCustomer: Record Customer temporary; var TmpAccount: Record Contact temporary): Boolean
    var
        AccountManager: Codeunit "NPR M2 Account Manager";
        ReasonText: Text;
    begin

        exit(AccountManager.CreateAccount(TmpContact, TmpCustomer, TmpAccount, ReasonText));
    end;

    local procedure DoAddAccount(var TmpContact: Record Contact temporary; var TmpAccount: Record Contact temporary): Boolean
    var
        AccountManager: Codeunit "NPR M2 Account Manager";
        ReasonText: Text;
    begin

        exit(AccountManager.AddAccount(TmpContact, TmpAccount, ReasonText));
    end;

    local procedure DoUpdateAccount(var TmpContact: Record Contact temporary; var TmpCustomer: Record Customer temporary; var TmpAccount: Record Contact temporary): Boolean
    var
        AccountManager: Codeunit "NPR M2 Account Manager";
        ReasonText: Text;
    begin

        exit(AccountManager.UpdateAccount(TmpContact, TmpCustomer, TmpAccount, ReasonText));
    end;

    local procedure DoDeleteAccount(ContactNo: Code[20]): Boolean
    var
        AccountManager: Codeunit "NPR M2 Account Manager";
        ReasonText: Text;
    begin

        exit(AccountManager.DeleteAccount(ContactNo, ReasonText));
    end;

    local procedure DoAddShiptoAddress(var TmpAccount: Record Contact temporary; var TmpShiptoAddressRequest: Record "Ship-to Address" temporary; var TmpShiptoAddressResponse: Record "Ship-to Address" temporary): Boolean
    var
        AccountManager: Codeunit "NPR M2 Account Manager";
        ReasonText: Text;
    begin

        exit(AccountManager.CreateShiptoAddress(TmpAccount, TmpShiptoAddressRequest, TmpShiptoAddressResponse, ReasonText));
    end;

    local procedure DoUpdateShiptoAddress(var TmpAccount: Record Contact temporary; var TmpShiptoAddressRequest: Record "Ship-to Address" temporary; var TmpShiptoAddressResponse: Record "Ship-to Address" temporary): Boolean
    var
        AccountManager: Codeunit "NPR M2 Account Manager";
        ReasonText: Text;
    begin

        exit(AccountManager.UpdateShiptoAddress(TmpAccount, TmpShiptoAddressRequest, TmpShiptoAddressResponse, ReasonText));
    end;

    local procedure DoDeleteShiptoAddress(var TmpAccount: Record Contact temporary; var TmpShiptoAddressRequest: Record "Ship-to Address" temporary): Boolean
    var
        AccountManager: Codeunit "NPR M2 Account Manager";
        ReasonText: Text;
    begin

        exit(AccountManager.DeleteShiptoAddress(TmpAccount, TmpShiptoAddressRequest, ReasonText));
    end;

    #region Testers

    #endregion
}
