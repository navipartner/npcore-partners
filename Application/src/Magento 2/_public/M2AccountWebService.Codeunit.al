codeunit 6151150 "NPR M2 Account WebService"
{
    procedure AuthenticateAccountPassword(var M2Authenticate: XMLport "NPR M2 Authenticate")
    var
        TempOneTimePassword: Record "NPR M2 One Time Password" temporary;
        TempContact: Record Contact temporary;
        ImportEntry: Record "NPR Nc Import Entry";
        BlobOutStream: OutStream;
    begin
        SelectLatestVersion();
        M2Authenticate.Import();

        InitializeImportEntry('Authenticate', ImportEntry, BlobOutStream);
        M2Authenticate.SetDestination(BlobOutStream);
        M2Authenticate.Export();
        ImportEntry.Modify();
        Commit();

        M2Authenticate.GetRequest(TempOneTimePassword);
        if (DoAuthenticatePassword(TempOneTimePassword, TempContact)) then begin
            M2Authenticate.SetResponse(TempContact);
            SetSuccess(ImportEntry, BlobOutStream);
        end else begin
            M2Authenticate.SetErrorResponse(GetLastErrorText);
            SetFail(ImportEntry, GetLastErrorText(), BlobOutStream);
        end;

        M2Authenticate.SetDestination(BlobOutStream);
        M2Authenticate.Export();
        ImportEntry.Modify();
        Commit();
    end;

    procedure RequestPasswordReset(var M2ResetAccountPassword: XMLport "NPR M2 Reset Account Password")
    var
        TempOneTimePassword: Record "NPR M2 One Time Password" temporary;
        ImportEntry: Record "NPR Nc Import Entry";
        BlobOutStream: OutStream;
    begin
        SelectLatestVersion();
        M2ResetAccountPassword.Import();

        InitializeImportEntry('ResetAccountPassword', ImportEntry, BlobOutStream);
        M2ResetAccountPassword.SetDestination(BlobOutStream);
        M2ResetAccountPassword.Export();
        ImportEntry.Modify();
        Commit();

        M2ResetAccountPassword.GetRequest(TempOneTimePassword);
        if (DoResetPassword(TempOneTimePassword)) then begin
            M2ResetAccountPassword.SetResponse();
            SetSuccess(ImportEntry, BlobOutStream);
        end else begin
            M2ResetAccountPassword.SetErrorResponse(GetLastErrorText);
            SetFail(ImportEntry, GetLastErrorText(), BlobOutStream);
        end;

        M2ResetAccountPassword.SetDestination(BlobOutStream);
        M2ResetAccountPassword.Export();
        ImportEntry.Modify();
        Commit();
    end;

    procedure ChangeAccountPassword(var M2ChangeAccountPassword: XMLport "NPR M2 Change Account Password")
    var
        TempOneTimePassword: Record "NPR M2 One Time Password" temporary;
        TempContact: Record Contact temporary;
        ImportEntry: Record "NPR Nc Import Entry";
        BlobOutStream: OutStream;
    begin
        SelectLatestVersion();
        M2ChangeAccountPassword.Import();

        InitializeImportEntry('ChangeAccountPassword', ImportEntry, BlobOutStream);
        M2ChangeAccountPassword.SetDestination(BlobOutStream);
        M2ChangeAccountPassword.Export();
        ImportEntry.Modify();
        Commit();

        M2ChangeAccountPassword.GetRequest(TempOneTimePassword);
        if (DoChangePassword(TempOneTimePassword, TempContact)) then begin
            M2ChangeAccountPassword.SetResponse(TempContact);
            SetSuccess(ImportEntry, BlobOutStream);
        end else begin
            M2ChangeAccountPassword.SetErrorResponse(GetLastErrorText);
            SetFail(ImportEntry, GetLastErrorText(), BlobOutStream);
        end;

        M2ChangeAccountPassword.SetDestination(BlobOutStream);
        M2ChangeAccountPassword.Export();
        ImportEntry.Modify();
        Commit();
    end;

    procedure GetAccountDetails(var M2GetAccount: XMLport "NPR M2 Get Account")
    var
        ContactNo: Code[20];
        TempContact: Record Contact temporary;
        TempSellToCustomer: Record Customer temporary;
        TempBillToCustomer: Record Customer temporary;
        TempShipToAddress: Record "Ship-to Address" temporary;
        ImportEntry: Record "NPR Nc Import Entry";
        BlobOutStream: OutStream;
    begin
        SelectLatestVersion();
        M2GetAccount.Import();

        InitializeImportEntry('GetAccount', ImportEntry, BlobOutStream);
        M2GetAccount.SetDestination(BlobOutStream);
        M2GetAccount.Export();
        ImportEntry.Modify();
        Commit();

        ContactNo := M2GetAccount.GetRequest();
        if (DoGetAccount(ContactNo, TempContact, TempSellToCustomer, TempBillToCustomer, TempShipToAddress)) then begin
            M2GetAccount.SetResponse(TempContact, TempSellToCustomer, TempBillToCustomer, TempShipToAddress);
            SetSuccess(ImportEntry, BlobOutStream);
        end else begin
            M2GetAccount.SetErrorResponse(GetLastErrorText());
            SetFail(ImportEntry, GetLastErrorText(), BlobOutStream);
        end;

        M2GetAccount.SetDestination(BlobOutStream);
        M2GetAccount.Export();
        ImportEntry.Modify();
        Commit();
    end;

    procedure UpdateAccount(var M2UpdateAccount: XMLport "NPR M2 Update Account")
    var
        TempContact: Record Contact temporary;
        TempCustomer: Record Customer temporary;
        TempAccount: Record Contact temporary;
        ImportEntry: Record "NPR Nc Import Entry";
        BlobOutStream: OutStream;
    begin
        SelectLatestVersion();
        M2UpdateAccount.Import();

        InitializeImportEntry('UpdateAccount', ImportEntry, BlobOutStream);
        M2UpdateAccount.SetDestination(BlobOutStream);
        M2UpdateAccount.Export();
        ImportEntry.Modify();
        Commit();

        M2UpdateAccount.GetRequest(TempContact, TempCustomer);
        if (DoUpdateAccount(TempContact, TempCustomer, TempAccount)) then begin
            M2UpdateAccount.SetResponse(TempAccount);
            SetSuccess(ImportEntry, BlobOutStream);
        end else begin
            M2UpdateAccount.SetErrorResponse(GetLastErrorText());
            SetFail(ImportEntry, GetLastErrorText(), BlobOutStream);
        end;

        M2UpdateAccount.SetDestination(BlobOutStream);
        M2UpdateAccount.Export();
        ImportEntry.Modify();
        Commit();
    end;

    procedure CreateCorporateAccount(var M2CreateCorporateAccount: XMLport "NPR M2 Create Corporate Acc.")
    var
        TempContact: Record Contact temporary;
        TempCustomer: Record Customer temporary;
        TempAccount: Record Contact temporary;
        ImportEntry: Record "NPR Nc Import Entry";
        BlobOutStream: OutStream;
    begin
        SelectLatestVersion();
        M2CreateCorporateAccount.Import();

        InitializeImportEntry('CreateCorporateAccount', ImportEntry, BlobOutStream);
        M2CreateCorporateAccount.SetDestination(BlobOutStream);
        M2CreateCorporateAccount.Export();
        ImportEntry.Modify();
        Commit();

        M2CreateCorporateAccount.GetRequest(TempContact, TempCustomer);
        if (DoCreateAccount(TempContact, TempCustomer, TempAccount)) then begin
            M2CreateCorporateAccount.SetResponse(TempAccount);
            SetSuccess(ImportEntry, BlobOutStream);
        end else begin
            M2CreateCorporateAccount.SetErrorResponse(GetLastErrorText());
            SetFail(ImportEntry, GetLastErrorText(), BlobOutStream);
        end;

        M2CreateCorporateAccount.SetDestination(BlobOutStream);
        M2CreateCorporateAccount.Export();
        ImportEntry.Modify();
        Commit();
    end;

    procedure AddPersonAccount(var M2AddAccount: XMLport "NPR M2 Add Account")
    var
        TempContact: Record Contact temporary;
        TempAccount: Record Contact temporary;
        ImportEntry: Record "NPR Nc Import Entry";
        BlobOutStream: OutStream;
    begin
        SelectLatestVersion();
        M2AddAccount.Import();

        InitializeImportEntry('AddAccount', ImportEntry, BlobOutStream);
        M2AddAccount.SetDestination(BlobOutStream);
        M2AddAccount.Export();
        ImportEntry.Modify();
        Commit();

        M2AddAccount.GetRequest(TempContact);
        if (DoAddAccount(TempContact, TempAccount)) then begin
            M2AddAccount.SetResponse(TempAccount);
            SetSuccess(ImportEntry, BlobOutStream);
        end else begin
            M2AddAccount.SetErrorResponse(GetLastErrorText());
            SetFail(ImportEntry, GetLastErrorText(), BlobOutStream);
        end;

        M2AddAccount.SetDestination(BlobOutStream);
        M2AddAccount.Export();
        ImportEntry.Modify();
        Commit();
    end;

    procedure DeleteAccount(var M2DeleteAccount: XMLport "NPR M2 Delete Account")
    var
        ContactNo: Code[20];
        ImportEntry: Record "NPR Nc Import Entry";
        BlobOutStream: OutStream;
    begin
        SelectLatestVersion();
        M2DeleteAccount.Import();

        InitializeImportEntry('DeleteAccount', ImportEntry, BlobOutStream);
        M2DeleteAccount.SetDestination(BlobOutStream);
        M2DeleteAccount.Export();
        ImportEntry.Modify();
        Commit();

        ContactNo := M2DeleteAccount.GetRequest();
        if (DoDeleteAccount(ContactNo)) then begin
            M2DeleteAccount.SetResponse();
            SetSuccess(ImportEntry, BlobOutStream);
        end else begin
            M2DeleteAccount.SetErrorResponse(GetLastErrorText());
            SetFail(ImportEntry, GetLastErrorText(), BlobOutStream);
        end;

        M2DeleteAccount.SetDestination(BlobOutStream);
        M2DeleteAccount.Export();
        ImportEntry.Modify();
        Commit();
    end;

    procedure AddShiptoAddress(var M2AddShiptoAddress: XMLport "NPR M2 Add Shipto Address")
    var
        TempAccount: Record Contact temporary;
        TempShiptoAddressRequest: Record "Ship-to Address" temporary;
        TempShiptoAddressResponse: Record "Ship-to Address" temporary;
        ImportEntry: Record "NPR Nc Import Entry";
        BlobOutStream: OutStream;
    begin
        SelectLatestVersion();
        M2AddShiptoAddress.Import();

        InitializeImportEntry('AddShiptoAddress', ImportEntry, BlobOutStream);
        M2AddShiptoAddress.SetDestination(BlobOutStream);
        M2AddShiptoAddress.Export();
        ImportEntry.Modify();
        Commit();

        M2AddShiptoAddress.GetRequest(TempAccount, TempShiptoAddressRequest);
        if (DoAddShiptoAddress(TempAccount, TempShiptoAddressRequest, TempShiptoAddressResponse)) then begin
            M2AddShiptoAddress.SetResponse(TempShiptoAddressResponse);
            SetSuccess(ImportEntry, BlobOutStream);
        end else begin
            M2AddShiptoAddress.SetErrorResponse(GetLastErrorText());
            SetFail(ImportEntry, GetLastErrorText(), BlobOutStream);
        end;

        M2AddShiptoAddress.SetDestination(BlobOutStream);
        M2AddShiptoAddress.Export();
        ImportEntry.Modify();
        Commit();
    end;

    procedure UpdateShiptoAddress(var M2UpdateShiptoAddress: XMLport "NPR M2 Update Shipto Address")
    var
        TempAccount: Record Contact temporary;
        TempShiptoAddressRequest: Record "Ship-to Address" temporary;
        TempShiptoAddressResponse: Record "Ship-to Address" temporary;
        ImportEntry: Record "NPR Nc Import Entry";
        BlobOutStream: OutStream;
    begin
        SelectLatestVersion();
        M2UpdateShiptoAddress.Import();

        InitializeImportEntry('UpdateShiptoAddress', ImportEntry, BlobOutStream);
        M2UpdateShiptoAddress.SetDestination(BlobOutStream);
        M2UpdateShiptoAddress.Export();
        ImportEntry.Modify();
        Commit();

        M2UpdateShiptoAddress.GetRequest(TempAccount, TempShiptoAddressRequest);
        if (DoUpdateShiptoAddress(TempAccount, TempShiptoAddressRequest, TempShiptoAddressResponse)) then begin
            M2UpdateShiptoAddress.SetResponse(TempShiptoAddressResponse);
            SetSuccess(ImportEntry, BlobOutStream);
        end else begin
            M2UpdateShiptoAddress.SetErrorResponse(GetLastErrorText());
            SetFail(ImportEntry, GetLastErrorText(), BlobOutStream);
        end;

        M2UpdateShiptoAddress.SetDestination(BlobOutStream);
        M2UpdateShiptoAddress.Export();
        ImportEntry.Modify();
        Commit();
    end;

    procedure DeleteShiptoAddress(var M2DeleteShiptoAddress: XMLport "NPR M2 Delete Shipto Address")
    var
        TempAccount: Record Contact temporary;
        TempShiptoAddressRequest: Record "Ship-to Address" temporary;
        ImportEntry: Record "NPR Nc Import Entry";
        BlobOutStream: OutStream;
    begin
        SelectLatestVersion();
        M2DeleteShiptoAddress.Import();

        InitializeImportEntry('DeleteShiptoAddress', ImportEntry, BlobOutStream);
        M2DeleteShiptoAddress.SetDestination(BlobOutStream);
        M2DeleteShiptoAddress.Export();
        ImportEntry.Modify();
        Commit();

        M2DeleteShiptoAddress.GetRequest(TempAccount, TempShiptoAddressRequest);

        if (DoDeleteShiptoAddress(TempAccount, TempShiptoAddressRequest)) then begin
            M2DeleteShiptoAddress.SetResponse();
            SetSuccess(ImportEntry, BlobOutStream);
        end else begin
            M2DeleteShiptoAddress.SetErrorResponse(GetLastErrorText());
            SetFail(ImportEntry, GetLastErrorText(), BlobOutStream);
        end;

        M2DeleteShiptoAddress.SetDestination(BlobOutStream);
        M2DeleteShiptoAddress.Export();
        ImportEntry.Modify();
        Commit();
    end;

    procedure GetExtendedAccountDetails(var GetExtendedAccount: XMLport "NPR M2 Get Extended Account")
    var
        ContactNo: Code[20];
        TempContact: Record Contact temporary;
        TempSellToCustomer: Record Customer temporary;
        TempBillToCustomer: Record Customer temporary;
        TempShipToAddress: Record "Ship-to Address" temporary;
        ImportEntry: Record "NPR Nc Import Entry";
        BlobOutStream: OutStream;
    begin
        SelectLatestVersion();
        GetExtendedAccount.Import();

        InitializeImportEntry('GetExtendedAccount', ImportEntry, BlobOutStream);
        GetExtendedAccount.SetDestination(BlobOutStream);
        GetExtendedAccount.Export();
        ImportEntry.Modify();
        Commit();

        ContactNo := GetExtendedAccount.GetRequest();

        if (DoGetAccount(ContactNo, TempContact, TempSellToCustomer, TempBillToCustomer, TempShipToAddress)) then begin
            GetExtendedAccount.SetResponse(TempContact, TempSellToCustomer, TempBillToCustomer);
            SetSuccess(ImportEntry, BlobOutStream);
        end else begin
            GetExtendedAccount.SetErrorResponse(GetLastErrorText());
            SetFail(ImportEntry, GetLastErrorText(), BlobOutStream);
        end;
        GetExtendedAccount.SetDestination(BlobOutStream);
        GetExtendedAccount.Export();
        ImportEntry.Modify();
        Commit();
    end;

    procedure ListMailGroupsForAccount(ContactNo: Code[20]; var ListMailingGroups: XMLport "NPR M2 List Mailing Groups")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        BlobOutStream: OutStream;
    begin
        SelectLatestVersion();

        InitializeImportEntry('ListMailGroupsForAccount', ImportEntry);
        Commit();

        ListMailingGroups.CreateListForContact(ContactNo);

        SetSuccess(ImportEntry, BlobOutStream);
        ListMailingGroups.SetDestination(BlobOutStream);
        ListMailingGroups.Export();
        ImportEntry.Modify();
        Commit();
    end;

    procedure AddAccountToMailGroup(ContactNo: Code[20]; MailGroupCode: Code[10]; var ListMailingGroups: XMLport "NPR M2 List Mailing Groups")
    var
        ContactMailingGroup: Record "Contact Mailing Group";
        Contact: Record "Contact";
        MailGroup: Record "Mailing Group";
        ImportEntry: Record "NPR Nc Import Entry";
        BlobOutStream: OutStream;
    begin
        SelectLatestVersion();

        InitializeImportEntry('AddAccountToMailGroup', ImportEntry);
        Commit();

        if (not ContactMailingGroup.Get(ContactNo, MailGroupCode)) then begin
            if (Contact.Get(ContactNo)) then begin
                if (MailGroup.Get(MailGroupCode)) then begin
                    ContactMailingGroup.Validate("Contact No.", ContactNo);
                    ContactMailingGroup.Validate("Mailing Group Code", MailGroupCode);
                    ContactMailingGroup.Insert(true);
                end;
            end
        end;

        ListMailingGroups.CreateListForContact(ContactNo);

        SetSuccess(ImportEntry, BlobOutStream);
        ListMailingGroups.SetDestination(BlobOutStream);
        ListMailingGroups.Export();
        ImportEntry.Modify();
        Commit();
    end;

    procedure RemoveAccountFromMailGroup(ContactNo: Code[20]; MailGroupCode: Code[10]; var ListMailingGroups: XMLport "NPR M2 List Mailing Groups")
    var
        ContactMailingGroup: Record "Contact Mailing Group";
        ImportEntry: Record "NPR Nc Import Entry";
        BlobOutStream: OutStream;
    begin
        SelectLatestVersion();

        InitializeImportEntry('RemoveAccountFromMailGroup', ImportEntry);
        Commit();

        if (ContactMailingGroup.Get(ContactNo, MailGroupCode)) then begin
            ContactMailingGroup.Delete(true);
        end;

        ListMailingGroups.CreateListForContact(ContactNo);

        SetSuccess(ImportEntry, BlobOutStream);
        ListMailingGroups.SetDestination(BlobOutStream);
        ListMailingGroups.Export();
        ImportEntry.Modify();
        Commit();
    end;

    procedure GetShopperRecognition(var ShopperRecognition: XMLport "NPR M2 Shopper Recognition")
    var
        TempEFTShopperRecognition: Record "NPR EFT Shopper Recognition" temporary;
        EFTShopperRecognition: Codeunit "NPR EFT Shopper Recognition";
        IntegrationTypeLbl: Label 'Integration Type "%1" exist with different Shopper Reference value for "%2" "%3", replace is not supported.', Locked = true;
        ImportEntry: Record "NPR Nc Import Entry";
        BlobOutStream: OutStream;
    begin
        SelectLatestVersion();
        ShopperRecognition.Import();

        InitializeImportEntry('ShopperRecognition', ImportEntry, BlobOutStream);
        ShopperRecognition.SetDestination(BlobOutStream);
        ShopperRecognition.Export();
        ImportEntry.Modify();
        Commit();

        ShopperRecognition.GetRequest(TempEFTShopperRecognition);
        if (not EFTShopperRecognition.GetShopperReference(TempEFTShopperRecognition)) then
            if (not EFTShopperRecognition.CreateShopperReference(TempEFTShopperRecognition)) then
                ShopperRecognition.SetErrorResponse(
                  StrSubstNo(IntegrationTypeLbl,
                    TempEFTShopperRecognition."Integration Type", Format(TempEFTShopperRecognition."Entity Type"), TempEFTShopperRecognition."Entity Key"));

        ShopperRecognition.SetResponse(TempEFTShopperRecognition);

        SetSuccess(ImportEntry, BlobOutStream);
        ShopperRecognition.SetDestination(BlobOutStream);
        ShopperRecognition.Export();
        ImportEntry.Modify();
        Commit();
    end;

    local procedure DoAuthenticatePassword(var TmpOneTimePassword: Record "NPR M2 One Time Password" temporary; var TmpContact: Record Contact temporary): Boolean
    var
        AccountManager: Codeunit "NPR M2 Account Manager";
        ReasonText: Text;
    begin
        exit(AccountManager.AuthenticatePassword(TmpOneTimePassword, TmpContact, ReasonText));
    end;

    internal procedure DoChangePassword(var TmpOneTimePassword: Record "NPR M2 One Time Password" temporary; var TmpContact: Record Contact temporary): Boolean
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

    local procedure InitializeImportEntry(ServiceName: Text[80]; var ImportEntry: Record "NPR Nc Import Entry"; var DocumentSourceOutStream: OutStream)
    begin
        InitializeImportEntry(ServiceName, ImportEntry);
        ImportEntry."Document Source".CreateOutStream(DocumentSourceOutStream);
    end;

    local procedure InitializeImportEntry(ServiceName: Text[80]; var ImportEntry: Record "NPR Nc Import Entry")
    var
        FileNameLbl: Label '%1-%2.xml', Locked = true;
        SETUP_MISSING: Label 'Automatic setup for service name %1 failed.';
    begin

        ImportEntry.Init();
        ImportEntry."Entry No." := 0;
        GetImportTypeCode(ImportEntry."Import Type", CODEUNIT::"NPR M2 Account WebService", ServiceName);
        if (ImportEntry."Import Type" = '') then begin
            CreateDefaultServiceSetup();
            GetImportTypeCode(ImportEntry."Import Type", CODEUNIT::"NPR M2 Account WebService", ServiceName);
            if (ImportEntry."Import Type" = '') then
                Error(SETUP_MISSING, ServiceName);
        end;

        ImportEntry.Date := CurrentDateTime;
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, ServiceName, Format(ImportEntry.Date, 0, 9));
        ImportEntry.Imported := false;
        ImportEntry."Runtime Error" := false;
        ImportEntry.Insert(true);
    end;

    local procedure CreateDefaultServiceSetup()
    begin
        CreateImportType('M2-ACCOUNT-01', 'M2 Account Service', 'CreateCorporateAccount');
        CreateImportType('M2-ACCOUNT-02', 'M2 Account Service', 'Authenticate');
        CreateImportType('M2-ACCOUNT-03', 'M2 Account Service', 'ResetAccountPassword');
        CreateImportType('M2-ACCOUNT-04', 'M2 Account Service', 'ChangeAccountPassword');
        CreateImportType('M2-ACCOUNT-05', 'M2 Account Service', 'GetAccount');
        CreateImportType('M2-ACCOUNT-06', 'M2 Account Service', 'UpdateAccount');
        CreateImportType('M2-ACCOUNT-07', 'M2 Account Service', 'AddAccount');
        CreateImportType('M2-ACCOUNT-08', 'M2 Account Service', 'DeleteAccount');
        CreateImportType('M2-ACCOUNT-09', 'M2 Account Service', 'AddShiptoAddress');
        CreateImportType('M2-ACCOUNT-10', 'M2 Account Service', 'UpdateShiptoAddress');
        CreateImportType('M2-ACCOUNT-11', 'M2 Account Service', 'DeleteShiptoAddress');
        CreateImportType('M2-ACCOUNT-12', 'M2 Account Service', 'GetExtendedAccount');
        CreateImportType('M2-ACCOUNT-13', 'M2 Account Service', 'ListMailGroupsForAccount');
        CreateImportType('M2-ACCOUNT-14', 'M2 Account Service', 'AddAccountToMailGroup');
        CreateImportType('M2-ACCOUNT-15', 'M2 Account Service', 'RemoveAccountFromMailGroup');
        CreateImportType('M2-ACCOUNT-16', 'M2 Account Service', 'ShopperRecognition');

        Commit();
    end;

    local procedure CreateImportType(ImportTypeCode: Code[20]; Description: Text[50]; FunctionName: Text[80])
    var
        ImportType: Record "NPR Nc Import Type";
    begin
        if (ImportType.Get(ImportTypeCode)) then
            exit;

        ImportType.Code := ImportTypeCode;
        ImportType.Description := Description;
        ImportType."Webservice Function" := FunctionName;

        ImportType."Webservice Enabled" := true;
        ImportType."Webservice Codeunit ID" := CODEUNIT::"NPR M2 Account WebService";
        ImportType."Max. Retry Count" := -1;
        ImportType.Actionable := false;
        ImportType.Insert();
    end;

    local procedure SetSuccess(var ImportEntry: Record "NPR Nc Import Entry"; var DocumentSourceOutStream: OutStream)
    var
        ImportHandler: Codeunit "NPR Nc Import Processor";
    begin
        ImportEntry.Get(ImportEntry."Entry No.");
        ImportEntry.Imported := true;
        ImportEntry."Runtime Error" := false;
        ImportEntry.Modify();
        ImportHandler.EmitTelemetryData(ImportEntry, ' ');

        ImportEntry."Document Source".CreateOutStream(DocumentSourceOutStream);
    end;

    local procedure SetFail(var ImportEntry: Record "NPR Nc Import Entry"; FailMessage: Text; var DocumentSourceOutStream: OutStream)
    var
        ImportHandler: Codeunit "NPR Nc Import Processor";
        OutStr: OutStream;
    begin
        ImportEntry.Get(ImportEntry."Entry No.");
        ImportEntry.Imported := false;
        ImportEntry."Runtime Error" := true;
        ImportEntry."Error Message" := CopyStr(FailMessage, 1, MaxStrLen(ImportEntry."Error Message"));
        ImportEntry."Last Error Message".CreateOutStream(OutStr, TEXTENCODING::UTF8);
        OutStr.WriteText(FailMessage);
        ImportEntry.Modify();
        ImportHandler.EmitTelemetryData(ImportEntry, FailMessage);

        ImportEntry."Document Source".CreateOutStream(DocumentSourceOutStream);
    end;

    local procedure GetImportTypeCode(var ImportTypeCode: Code[20]; ServiceCodeunitID: Integer; ServiceName: Text[80])
    var
        ImportType: Record "NPR Nc Import Type";
    begin
        ImportTypeCode := '';

        ImportType.SetFilter("Webservice Codeunit ID", '=%1', ServiceCodeunitID);
        ImportType.SetFilter("Webservice Function", '%1', ServiceName);

        if (ImportType.FindFirst()) then
            ImportTypeCode := ImportType.Code;
    end;
}
