codeunit 6151151 "NPR M2 Account Manager"
{
    trigger OnRun()
    begin
        case SelectedAccountFunction of
            AccountFunctions::AUTHENTICATE:
                AuthenticatePasswordWorker(TempGlobalOneTimePassword, TempGlobalContact, true);
            AccountFunctions::CHANGE_PASSWORD:
                ChangePasswordWorker(TempGlobalOneTimePassword, TempGlobalContact);
            AccountFunctions::CREATE_ACCOUNT:
                CreateAccountWorker(TempGlobalContact, TempGlobalCustomer1, TempGlobalAccount);
            AccountFunctions::UPDATE_ACCOUNT:
                UpdateAccountWorker(TempGlobalContact, TempGlobalCustomer1, TempGlobalAccount);
            AccountFunctions::ADD_ACCOUNT:
                AddAccountWorker(TempGlobalContact, TempGlobalAccount);
            AccountFunctions::DELETE_ACCOUNT:
                DeleteAccountWorker(TempGlobalContact);

            AccountFunctions::CREATE_SHIPTO:
                CreateShiptoAddressWorker(TempGlobalAccount, TempGlobsalShiptoAddressRequest, TempGlobalShiptoAddressResponse);
            AccountFunctions::UPDATE_SHIPTO:
                UpdateShiptoAddressWorker(TempGlobalAccount, TempGlobsalShiptoAddressRequest, TempGlobalShiptoAddressResponse);
            AccountFunctions::DELETE_SHIPTO:
                DeleteShiptoAddressWorker(TempGlobalAccount, TempGlobsalShiptoAddressRequest);
        end;
    end;

    var
        LogEntry: Record "NPR Authentication Log";
        RESET_EMAIL_SENT: Label 'An email with reset instructions was sent to %1';
        AccountFunctions: Option AUTHENTICATE,CHANGE_PASSWORD,CREATE_ACCOUNT,DELETE_ACCOUNT,ADD_ACCOUNT,UPDATE_ACCOUNT,CREATE_SHIPTO,UPDATE_SHIPTO,DELETE_SHIPTO;
        SelectedAccountFunction: Option;
        AccountManager: Codeunit "NPR M2 Account Manager";
        TempGlobalContact: Record Contact temporary;
        TempGlobalAccount: Record Contact temporary;
        TempGlobalCustomer1: Record Customer temporary;
        TempGlobalOneTimePassword: Record "NPR M2 One Time Password" temporary;
        TempGlobsalShiptoAddressRequest: Record "Ship-to Address" temporary;
        TempGlobalShiptoAddressResponse: Record "Ship-to Address" temporary;
        CONFIRM_GLOBAL_RESET_PASSWORD: Label 'Are you sure that you want to send an email to %1 Magento contacts?';
        IdLbl: Label ',{"id":"%1","storecode":"%2"}', Locked = true;
        AccountLbl: Label '{"account": {"email":"%1", "accounts":[%2]}}', Locked = true;

    procedure SetFunction(FunctionIn: Option)
    begin
        SelectedAccountFunction := FunctionIn;
    end;

    procedure AuthenticatePassword(var TmpOneTimePassword: Record "NPR M2 One Time Password" temporary; var TmpContact: Record Contact temporary; var ReasonText: Text): Boolean
    begin
        if (TryAuthenticatePassword(TmpOneTimePassword, TmpContact)) then begin
            ReasonText := '';
            AddLogEntry(LogEntry.Type::AUTHENTICATE, LogEntry.Status::OK, TmpOneTimePassword."E-Mail", ReasonText);

        end else begin
            ReasonText := GetLastErrorText();
            AddLogEntry(LogEntry.Type::AUTHENTICATE, LogEntry.Status::FAIL, TmpOneTimePassword."E-Mail", ReasonText);
        end;

        exit(ReasonText = '');
    end;

    procedure ChangePassword(var TmpOneTimePassword: Record "NPR M2 One Time Password" temporary; var TmpContact: Record Contact temporary; var ReasonText: Text): Boolean
    begin
        if (TryAuthenticatePassword(TmpOneTimePassword, TmpContact)) then begin
            if (TryChangePassword(TmpOneTimePassword, TmpContact)) then begin
                ReasonText := '';
                AddLogEntry(LogEntry.Type::PASSWORD_CHANGE, LogEntry.Status::OK, TmpOneTimePassword."E-Mail", ReasonText);
                exit(true);
            end;
        end;

        ReasonText := GetLastErrorText();

        AddLogEntry(LogEntry.Type::PASSWORD_CHANGE, LogEntry.Status::FAIL, TmpOneTimePassword."E-Mail", ReasonText);
        exit(false);
    end;

    procedure ResetPassword(var TmpOneTimePassword: Record "NPR M2 One Time Password" temporary; var ReasonText: Text): Boolean
    begin

        if (not TmpOneTimePassword.FindFirst()) then;

        if (TryResetPassword(TmpOneTimePassword."E-Mail")) then begin
            ReasonText := '';
            AddLogEntry(LogEntry.Type::RESET_PASSWORD_REQUEST, LogEntry.Status::OK, TmpOneTimePassword."E-Mail", ReasonText);

        end else begin
            ReasonText := GetLastErrorText();
            AddLogEntry(LogEntry.Type::RESET_PASSWORD_REQUEST, LogEntry.Status::FAIL, TmpOneTimePassword."E-Mail", ReasonText);

        end;

        exit(ReasonText = '');
    end;

    procedure GetAccount(ContactNo: Code[20]; var TmpContact: Record Contact temporary; var TmpSellToCustomer: Record Customer temporary; var TmpBillToCustomer: Record Customer temporary; var TmpShipToAddress: Record "Ship-to Address" temporary): Boolean
    begin
        ClearLastError();
        exit(GetAccountWorker(ContactNo, TmpContact, TmpSellToCustomer, TmpBillToCustomer, TmpShipToAddress));
    end;

    procedure CreateAccount(var TmpContact: Record Contact temporary; var TmpCustomer: Record Customer temporary; var TmpAccount: Record Contact temporary; var ReasonText: Text): Boolean
    begin
        if (TryCreateAccount(TmpContact, TmpCustomer, TmpAccount)) then begin
            ReasonText := '';
            exit(true);

        end else begin
            ReasonText := GetLastErrorText();
            exit(false);
        end;
    end;

    procedure UpdateAccount(var TmpContact: Record Contact temporary; var TmpCustomer: Record Customer temporary; var TmpAccount: Record Contact temporary; var ReasonText: Text): Boolean
    begin
        if (TryUpdateAccount(TmpContact, TmpCustomer, TmpAccount)) then begin
            ReasonText := '';
            exit(true);
        end else begin
            ReasonText := GetLastErrorText();
            exit(false);
        end;
    end;

    procedure AddAccount(var TmpAccount: Record Contact temporary; var TmpAccountResponse: Record Contact temporary; var ReasonText: Text): Boolean
    begin
        if (TryAddAccount(TmpAccount, TmpAccountResponse)) then begin
            ReasonText := '';

            if (TmpAccountResponse.FindFirst()) then begin
                if (not TryResetPassword(LowerCase(TmpAccount."E-Mail 2"))) then begin
                    //-NPR5.51 [356090]
                    // New Account has been commit, exit false will signal that the whole process failed.
                    // ReasonText := GETLASTERRORTEXT ();
                    // EXIT (FALSE);
                    //+NPR5.51 [356090]
                end;
                exit(true);
            end;
        end else begin
            ReasonText := GetLastErrorText();
            exit(false);
        end;
    end;

    procedure DeleteAccount(ContactNo: Code[20]; var ReasonText: Text): Boolean
    begin
        if (TryDeleteAccount(ContactNo)) then begin
            ReasonText := '';
            exit(true);
        end else begin
            ReasonText := GetLastErrorText();
            exit(false);
        end;
    end;

    procedure CreateShiptoAddress(var TmpAccount: Record Contact temporary; var TmpShiptoAddressRequest: Record "Ship-to Address" temporary; var TmpShiptoAddressResponse: Record "Ship-to Address" temporary; var ReasonText: Text): Boolean
    begin
        if (TryAddShiptoAddress(TmpAccount, TmpShiptoAddressRequest, TmpShiptoAddressResponse)) then begin
            ReasonText := '';
            exit(true);
        end;
        ReasonText := GetLastErrorText;
        exit(false);
    end;

    procedure UpdateShiptoAddress(var TmpAccount: Record Contact temporary; var TmpShiptoAddressRequest: Record "Ship-to Address" temporary; var TmpShiptoAddressResponse: Record "Ship-to Address" temporary; var ReasonText: Text): Boolean
    begin
        if (TryUpdateShiptoAddress(TmpAccount, TmpShiptoAddressRequest, TmpShiptoAddressResponse)) then begin
            ReasonText := '';
            exit(true);
        end;
        ReasonText := GetLastErrorText;
        exit(false);
    end;

    procedure DeleteShiptoAddress(var TmpAccount: Record Contact temporary; var TmpShiptoAddressRequest: Record "Ship-to Address" temporary; var ReasonText: Text): Boolean
    begin
        if (TryDeleteShiptoAddress(TmpAccount, TmpShiptoAddressRequest)) then begin
            ReasonText := '';
            exit(true);
        end;
        ReasonText := GetLastErrorText;
        exit(false);
    end;

    procedure ShowMagentoContacts()
    var
        Customer: Record Customer;
        Contact: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
        TempMagentoContactBuffer: Record "NPR M2 Contact Buffer" temporary;
    begin
        // Filter requirements
        Contact.SetFilter("NPR Magento Contact", '%1', true);
        Customer.SetFilter("NPR Magento Store Code", '<>%1', '');
        ContactBusinessRelation.SetFilter("Link to Table", '%1', ContactBusinessRelation."Link to Table"::Customer);

        if Contact.FindSet() then
            repeat
                ContactBusinessRelation.SetFilter("Contact No.", '%1', Contact."No.");
                if ContactBusinessRelation.FindFirst() then begin
                    Customer.SetFilter("No.", '%1', ContactBusinessRelation."No.");
                    if Customer.FindFirst() then begin
                        TempMagentoContactBuffer."Entry No." += 1;
                        TempMagentoContactBuffer."Customer No." := Customer."No.";
                        TempMagentoContactBuffer."Customer Name" := Customer.Name;
                        TempMagentoContactBuffer."Contact No." := Contact."No.";
                        TempMagentoContactBuffer."Contact Name" := Contact.Name;
                        TempMagentoContactBuffer."Contact Email" := Contact."E-Mail";
                        TempMagentoContactBuffer."Magento Contact" := Contact."NPR Magento Contact";
                        TempMagentoContactBuffer."Magento Store Code" := Customer."NPR Magento Store Code";
                        TempMagentoContactBuffer.Insert();
                    end;
                end;
            until Contact.Next() = 0;

        // Design choice, in case that we need to run reset password again
        TempMagentoContactBuffer.SetFilter("Password Reset", '%1', false);

        Page.Run(Page::"NPR M2 Contact List", TempMagentoContactBuffer);
    end;

    procedure ResetPasswordAllMagentoContacts(var MagentoContactBuffer: Record "NPR M2 Contact Buffer")
    begin
        if Dialog.Confirm(CONFIRM_GLOBAL_RESET_PASSWORD, false, MagentoContactBuffer.Count) then begin
            if MagentoContactBuffer.FindSet() then
                repeat
                    if TryResetPassword(MagentoContactBuffer."Contact Email") then begin
                        MagentoContactBuffer."Password Reset" := true;
                        MagentoContactBuffer."Error Message" := '';
                    end else begin
                        MagentoContactBuffer."Error Message" := CopyStr(GetLastErrorText(), 1, 250);
                    end;
                    MagentoContactBuffer.Modify();
                until MagentoContactBuffer.Next() = 0;
        end;
    end;

    procedure TransferSetContact(var TmpContact: Record Contact temporary)
    begin
        TmpContact.Reset();
        if (TmpContact.FindSet()) then begin
            repeat
                TempGlobalContact.TransferFields(TmpContact, true);
                TempGlobalContact.Insert();
            until (TmpContact.Next() = 0);
        end;
    end;

    procedure TransferGetContact(var TmpContact: Record Contact temporary)
    begin
        if (TmpContact.IsTemporary()) then
            TmpContact.DeleteAll();

        TempGlobalContact.Reset();
        if (TempGlobalContact.FindSet()) then begin
            repeat
                TmpContact.TransferFields(TempGlobalContact, true);
                TmpContact.Insert();
            until (TempGlobalContact.Next() = 0);
        end;
    end;

    procedure TransferSetAccount(var TmpContact: Record Contact temporary)
    begin
        TmpContact.Reset();
        if (TmpContact.FindSet()) then begin
            repeat
                TempGlobalAccount.TransferFields(TmpContact, true);
                TempGlobalAccount.Insert();
            until (TmpContact.Next() = 0);
        end;
    end;

    procedure TransferGetAccount(var TmpContact: Record Contact temporary)
    begin
        if (TmpContact.IsTemporary()) then
            TmpContact.DeleteAll();

        TempGlobalAccount.Reset();
        if (TempGlobalAccount.FindSet()) then begin
            repeat
                TmpContact.TransferFields(TempGlobalAccount, true);
                TmpContact.Insert();
            until (TempGlobalAccount.Next() = 0);
        end;
    end;

    procedure TransferSetCustomer1(var TmpCustomer: Record Customer temporary)
    begin
        TmpCustomer.Reset();
        if (TmpCustomer.FindSet()) then begin
            repeat
                TempGlobalCustomer1.TransferFields(TmpCustomer, true);
                TempGlobalCustomer1.Insert();
            until (TmpCustomer.Next() = 0);
        end;
    end;

    procedure TransferGetCustomer1(var TmpCustomer: Record Customer temporary)
    begin
        if (TmpCustomer.IsTemporary) then
            TmpCustomer.DeleteAll();

        TempGlobalCustomer1.Reset();
        if (TempGlobalCustomer1.FindSet()) then begin
            repeat
                TmpCustomer.TransferFields(TempGlobalCustomer1, true);
                TmpCustomer.Insert();
            until (TempGlobalCustomer1.Next() = 0);
        end;
    end;

    procedure TransferSetShiptoAddress(var TmpShiptoAddress: Record "Ship-to Address" temporary)
    begin
        TmpShiptoAddress.Reset();
        if (TmpShiptoAddress.FindSet()) then begin
            repeat
                TempGlobsalShiptoAddressRequest.TransferFields(TmpShiptoAddress, true);
                TempGlobsalShiptoAddressRequest.Insert();
            until (TmpShiptoAddress.Next() = 0);
        end;
    end;

    procedure TransferGetShiptoAddress(var TmpShiptoAddress: Record "Ship-to Address" temporary)
    begin
        if (TmpShiptoAddress.IsTemporary()) then
            TmpShiptoAddress.DeleteAll();
        if (TempGlobalShiptoAddressResponse.FindSet()) then begin
            repeat
                TmpShiptoAddress.TransferFields(TempGlobalShiptoAddressResponse, true);
                TmpShiptoAddress.Insert();
            until (TempGlobalShiptoAddressResponse.Next() = 0);
        end;
    end;

    procedure TransferSetOTP(var TmpOneTimePassword: Record "NPR M2 One Time Password" temporary)
    begin
        TmpOneTimePassword.Reset();
        if (TmpOneTimePassword.FindSet()) then begin
            repeat
                TempGlobalOneTimePassword.TransferFields(TmpOneTimePassword, true);
                TempGlobalOneTimePassword.Insert();
            until (TempGlobalOneTimePassword.Next() = 0);
        end;
    end;

    #region Try Function - by invoking self

    local procedure TryAuthenticatePassword(var TmpOneTimePassword: Record "NPR M2 One Time Password" temporary; var TmpContact: Record Contact temporary) bOk: Boolean
    begin
        Clear(AccountManager);
        AccountManager.SetFunction(AccountFunctions::AUTHENTICATE);
        AccountManager.TransferSetOTP(TmpOneTimePassword);
        AccountManager.TransferSetContact(TmpContact);

        bOk := AccountManager.Run();

        AccountManager.TransferGetContact(TmpContact);
        exit(bOk);
    end;

    local procedure TryChangePassword(var TmpOneTimePassword: Record "NPR M2 One Time Password" temporary; var TmpContact: Record Contact temporary) bOk: Boolean
    begin
        Clear(AccountManager);
        AccountManager.SetFunction(AccountFunctions::CHANGE_PASSWORD);
        AccountManager.TransferSetOTP(TmpOneTimePassword);
        AccountManager.TransferSetContact(TmpContact);

        bOk := AccountManager.Run();

        AccountManager.TransferGetContact(TmpContact);
        exit(bOk);
    end;

    [TryFunction]
    local procedure TryResetPassword(Email: Text)
    var
        Contact: Record Contact;
        Customer: Record Customer;
        ContactBusinessRelation: Record "Contact Business Relation";
        MarketingSetup: Record "Marketing Setup";
        Body: JsonToken;
        Result: JsonToken;
        msg: Text;
    begin
        if (Email = '') then
            Error('No account to reset.');

        Contact.Reset();
        Contact.SetFilter("E-Mail", '=%1', LowerCase(Email));
        Contact.SetFilter("NPR Magento Contact", '=%1', true);
        if (Contact.IsEmpty()) then
            Error('E-Mail does not identify a magento contact.');

        Contact.FindSet();
        repeat

            if (Contact."Company No." = '') then
                Contact."Company No." := Contact."No.";

            if (MarketingSetup.Get()) then
                if (ContactBusinessRelation.Get(Contact."Company No.", MarketingSetup."Bus. Rel. Code for Customers")) then
                    if (Customer.Get(ContactBusinessRelation."No.")) then
                        ;

            Customer.TestField("NPR Magento Store Code");
            msg := msg + StrSubstNo(IdLbl, Contact."No.", Customer."NPR Magento Store Code");

        until (Contact.Next() = 0);

        Body.ReadFrom(StrSubstNo(AccountLbl, Email, CopyStr(msg, 2)));

        MagentoApiPost('passwordreset', Body, Result);
    end;

    local procedure TryCreateAccount(var TmpContact: Record Contact temporary; var TmpCustomer: Record Customer temporary; var TmpAccount: Record Contact temporary) bOk: Boolean
    var
        TempOneTimePassword: Record "NPR M2 One Time Password" temporary;
    begin
        Clear(AccountManager);
        AccountManager.SetFunction(AccountFunctions::CREATE_ACCOUNT);
        AccountManager.TransferSetOTP(TempOneTimePassword);
        AccountManager.TransferSetContact(TmpContact);
        AccountManager.TransferSetCustomer1(TmpCustomer);
        AccountManager.TransferSetAccount(TmpAccount);

        bOk := AccountManager.Run();

        AccountManager.TransferGetContact(TmpContact);
        AccountManager.TransferGetCustomer1(TmpCustomer);
        AccountManager.TransferGetAccount(TmpAccount);

        exit(bOk);
    end;

    local procedure TryUpdateAccount(var TmpAccount: Record Contact temporary; var TmpCustomer: Record Customer temporary; var TmpAccountResponse: Record Contact temporary) bOK: Boolean
    begin
        Clear(AccountManager);
        AccountManager.SetFunction(AccountFunctions::UPDATE_ACCOUNT);
        AccountManager.TransferSetContact(TmpAccount);
        AccountManager.TransferSetCustomer1(TmpCustomer);
        AccountManager.TransferSetAccount(TmpAccountResponse);

        bOK := AccountManager.Run();

        AccountManager.TransferGetContact(TmpAccount);
        AccountManager.TransferGetCustomer1(TmpCustomer);
        AccountManager.TransferGetAccount(TmpAccountResponse);

        exit(bOK);
    end;

    local procedure TryAddAccount(var TmpAccount: Record Contact temporary; var TmpAccountResponse: Record Contact temporary) bOk: Boolean
    begin
        Clear(AccountManager);
        AccountManager.SetFunction(AccountFunctions::ADD_ACCOUNT);
        AccountManager.TransferSetContact(TmpAccount);

        bOk := AccountManager.Run();

        AccountManager.TransferGetAccount(TmpAccountResponse);

        exit(bOk);
    end;

    local procedure TryDeleteAccount(ContactNo: Code[20]) bOk: Boolean
    var
        Account: Record Contact;
        TempContact: Record Contact temporary;
    begin

        Account.Get(ContactNo);
        TempContact.TransferFields(Account, true);
        TempContact.Insert();

        Clear(AccountManager);
        AccountManager.SetFunction(AccountFunctions::DELETE_ACCOUNT);
        AccountManager.TransferSetContact(TempContact);

        bOk := AccountManager.Run();

        exit(bOk);
    end;

    local procedure TryAddShiptoAddress(var TmpAccount: Record Contact temporary; var TmpShiptoAddressRequest: Record "Ship-to Address" temporary; var TmpShiptoAddressResponse: Record "Ship-to Address" temporary) bOk: Boolean
    begin
        Clear(AccountManager);
        AccountManager.SetFunction(AccountFunctions::CREATE_SHIPTO);
        AccountManager.TransferSetAccount(TmpAccount);
        AccountManager.TransferSetShiptoAddress(TmpShiptoAddressRequest);

        bOk := AccountManager.Run();

        AccountManager.TransferGetShiptoAddress(TmpShiptoAddressResponse);

        exit(bOk);
    end;

    local procedure TryUpdateShiptoAddress(var TmpAccount: Record Contact temporary; var TmpShiptoAddressRequest: Record "Ship-to Address" temporary; var TmpShiptoAddressResponse: Record "Ship-to Address" temporary) bOk: Boolean
    begin
        Clear(AccountManager);
        AccountManager.SetFunction(AccountFunctions::UPDATE_SHIPTO);
        AccountManager.TransferSetAccount(TmpAccount);
        AccountManager.TransferSetShiptoAddress(TmpShiptoAddressRequest);

        bOk := AccountManager.Run();

        AccountManager.TransferGetShiptoAddress(TmpShiptoAddressResponse);

        exit(bOk);
    end;

    local procedure TryDeleteShiptoAddress(var TmpAccount: Record Contact temporary; var TmpShiptoAddressRequest: Record "Ship-to Address" temporary) bOk: Boolean
    begin
        Clear(AccountManager);
        AccountManager.SetFunction(AccountFunctions::DELETE_SHIPTO);
        AccountManager.TransferSetAccount(TmpAccount);
        AccountManager.TransferSetShiptoAddress(TmpShiptoAddressRequest);

        bOk := AccountManager.Run();

        exit(bOk);
    end;

    #endregion

    #region Workers

    local procedure AuthenticatePasswordWorker(var TmpOneTimePassword: Record "NPR M2 One Time Password" temporary; var TmpContact: Record Contact temporary; AllowBlankPassword: Boolean)
    var
        Contact: Record Contact;
        OneTimePassword: Record "NPR M2 One Time Password";
        OTPAuthentication: Boolean;
    begin
        if (TmpContact.IsTemporary()) then
            TmpContact.DeleteAll();

        TmpOneTimePassword.Reset();
        if (not TmpOneTimePassword.FindFirst()) then
            Error('No account to validate.');

        if (TmpOneTimePassword."E-Mail" = '') then
            Error('E-Mail must not be blank.');

        if (TmpOneTimePassword."Password (Hash)" = '') and (not AllowBlankPassword) then
            Error('Password must not be blank.');

        OneTimePassword.SetFilter("E-Mail", '=%1', LowerCase(TmpOneTimePassword."E-Mail"));
        OneTimePassword.SetFilter("Password (Hash)", '=%1', TmpOneTimePassword."Password (Hash)");
        OTPAuthentication := OneTimePassword.FindFirst();

        if (OTPAuthentication) then begin
            if (TmpOneTimePassword."Password (Hash)" = '') then
                Error('Password must not be blank.'); // OTP must never be blank

            if (OneTimePassword."Used At" <> 0DT) then
                Error('The security token %1 has already been used.', TmpOneTimePassword."Password (Hash)");

            if (OneTimePassword."Valid Until" < CurrentDateTime) then
                Error('The security token %1 has expired.', TmpOneTimePassword."Password (Hash)");

            OneTimePassword."Used At" := CurrentDateTime;
            OneTimePassword.Modify();
        end;

        Contact.SetFilter("E-Mail", '=%1', LowerCase(TmpOneTimePassword."E-Mail"));
        Contact.SetFilter("NPR Magento Contact", '=%1', true);

        if (not OTPAuthentication) then
            Contact.SetFilter("NPR Magento Password (Md5)", '=%1', TmpOneTimePassword."Password (Hash)");

        if (not OTPAuthentication) and (AllowBlankPassword) and (TmpOneTimePassword."Password (Hash)" = '') then
            Contact.SetFilter("NPR Magento Password (Md5)", '');

        if (Contact.IsEmpty()) then begin
            Contact.Reset();
            Contact.SetFilter("E-Mail", '=%1', LowerCase(TmpOneTimePassword."E-Mail"));
            Contact.SetFilter("NPR Magento Contact", '=%1', true);
            Contact.SetFilter("NPR Magento Password (Md5)", '<>%1', '');
            if (not Contact.IsEmpty()) then
                Error('E-Mail and password does not identify a valid magento contact.');
            Error('Contact not found.');
        end;

        Contact.Reset();
        Contact.SetFilter("E-Mail", '=%1', LowerCase(TmpOneTimePassword."E-Mail"));
        Contact.SetFilter("NPR Magento Contact", '=%1', true);
        if (Contact.FindSet()) then begin
            repeat
                TmpContact.TransferFields(Contact, true);
                TmpContact.Insert();
            until (Contact.Next() = 0);
        end;
    end;

    local procedure ChangePasswordWorker(var TmpOneTimePassword: Record "NPR M2 One Time Password" temporary; var TmpContact: Record Contact temporary)
    var
        Contact: Record Contact;
    begin

        TmpContact.Reset();
        if (TmpContact.IsEmpty()) then
            Error('E-Mail and password does not identify a magento contact.');

        if (TmpOneTimePassword."Password2 (Hash)" = '') then
            Error('New password must not be blank.');

        TmpOneTimePassword.FindFirst();
        TmpContact.FindSet();
        repeat
            Contact.Get(TmpContact."No.");
            Contact."NPR Magento Password (Md5)" := TmpOneTimePassword."Password2 (Hash)";
            Contact.Modify();
        until (TmpContact.Next() = 0);
    end;

    procedure ResetMagentoPassword(Contact: Record Contact; var ReasonText: Text): Boolean
    begin
        Contact.TestField("E-Mail");

        if (TryResetPassword(Contact."E-Mail")) then begin
            ReasonText := '';
            AddLogEntry(LogEntry.Type::RESET_PASSWORD_REQUEST, LogEntry.Status::OK, Contact."E-Mail", ReasonText);
            Message(RESET_EMAIL_SENT, Contact."E-Mail");

        end else begin
            ReasonText := GetLastErrorText();
            AddLogEntry(LogEntry.Type::RESET_PASSWORD_REQUEST, LogEntry.Status::FAIL, Contact."E-Mail", ReasonText);

        end;

        exit(ReasonText = '');
    end;

    local procedure CreateAccountWorker(var TmpContact: Record Contact temporary; var TmpCustomer: Record Customer temporary; var TmpAccount: Record Contact temporary)
    var
        Contact: Record Contact;
        Customer: Record Customer;
        MarketingSetup: Record "Marketing Setup";
        ContactBusinessRelation: Record "Contact Business Relation";
        ConfigTemplateHeader: Record "Config. Template Header";
        MagentoSetup: Record "NPR Magento Setup";
        CustContUpdate: Codeunit "CustCont-Update";
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        RecRef: RecordRef;
    begin

        if (not MarketingSetup.Get()) then
            Error('Marketing Setup not found.');

        if (MarketingSetup."Bus. Rel. Code for Customers" = '') then
            Error('Business Relation Code for Customers in Marketing Setup must not be blank.');

        if (TmpContact."E-Mail" = '') then
            Error('E-Mail can not be empty.');

        TmpContact.FindFirst();
        TmpCustomer.FindFirst();

        Customer."No." := '';

        if (not CreateMembership(TmpContact, Customer)) then
            Customer.Insert(true);

        if (MagentoSetup.Get()) then begin
            if (MagentoSetup."Customer Config. Template Code" <> '') then begin
                ConfigTemplateHeader.Get(MagentoSetup."Customer Config. Template Code");
                RecRef.GetTable(Customer);
                ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader, RecRef);
                RecRef.SetTable(Customer);
            end;
        end;

        if (TmpContact."Company Name" = '') then
            TmpContact."Company Name" := CalculatedName(TmpContact."First Name", TmpContact."Middle Name", TmpContact.Surname);

        Customer.Validate(Name, TmpContact."Company Name");
        Customer.Validate("Name 2", TmpContact."Name 2");

        Customer.Validate(Address, TmpContact.Address);
        Customer.Validate("Address 2", TmpContact."Address 2");

        if (TmpContact."Country/Region Code" <> '') then
            Customer.Validate("Country/Region Code", TmpContact."Country/Region Code");
        if (TmpContact."Post Code" <> '') then
            Customer.Validate("Post Code", TmpContact."Post Code");
        if (TmpContact.City <> '') then
            Customer.Validate(City, TmpContact.City);

        if (TmpContact."Currency Code" <> '') then
            Customer.Validate("Currency Code", TmpContact."Currency Code");

        if (TmpContact."VAT Registration No." <> '') then
            Customer.Validate("VAT Registration No.", TmpContact."VAT Registration No.");

        if (TmpContact."E-Mail" <> '') then
            Customer.Validate("E-Mail", LowerCase(TmpContact."E-Mail"));

        if (TmpContact."Phone No." <> '') then
            Customer.Validate("Phone No.", TmpContact."Phone No.");

        Customer."NPR Magento Display Group" := TmpCustomer."NPR Magento Display Group";
        Customer."NPR Magento Payment Group" := TmpCustomer."NPR Magento Payment Group";
        Customer."NPR Magento Shipping Group" := TmpCustomer."NPR Magento Shipping Group";
        Customer."NPR Magento Store Code" := TmpCustomer."NPR Magento Store Code";
        Customer.Modify(true);

        // Contact Type Company
        ContactBusinessRelation.SetFilter("No.", '=%1', Customer."No.");
        ContactBusinessRelation.SetFilter("Link to Table", '=%1', ContactBusinessRelation."Link to Table"::Customer);
        if (ContactBusinessRelation.FindFirst()) then begin

            // TODO Apply contact template

            CustContUpdate.OnModify(Customer);

            Contact.Get(ContactBusinessRelation."Contact No.");

            Contact."NPR Magento Customer Group" := TmpContact."NPR Magento Customer Group";
            Contact."NPR Magento Contact" := (Contact."E-Mail" <> '');
            Contact."NPR Magento Password (Md5)" := TmpContact."NPR Magento Password (Md5)";

            Contact."First Name" := TmpContact."First Name";
            Contact.Surname := TmpContact.Surname;

            Contact.Modify();

            // Company Result
            TmpAccount.TransferFields(Contact, true);
            TmpAccount.Insert();

            // Contact Type Person
            Contact.Reset();
            Contact.SetFilter(Contact.Type, '=%1', Contact.Type::Person);
            Contact.SetFilter("Company No.", '=%1', ContactBusinessRelation."Contact No.");
            if (Contact.FindFirst()) then begin
                Contact."NPR Magento Customer Group" := TmpContact."NPR Magento Customer Group";
                Contact."NPR Magento Contact" := (Contact."E-Mail" <> '');
                Contact."NPR Magento Password (Md5)" := TmpContact."NPR Magento Password (Md5)";

                Contact.Modify();

                // Person Result
                TmpAccount.TransferFields(Contact, true);
                TmpAccount.Insert();
            end;
        end;
    end;

    local procedure UpdateAccountWorker(var TmpAccount: Record Contact temporary; var TmpCustomer: Record Customer temporary; var TmpAccountResponse: Record Contact temporary)
    var
        Account: Record Contact;
        Contact: Record Contact;
        ContactXrec: Record Contact;
        Customer: Record Customer;
        MarketingSetup: Record "Marketing Setup";
        ContactBusinessRelation: Record "Contact Business Relation";
        UpdateCustomerData: Boolean;
    begin

        TmpAccount.FindFirst();
        UpdateCustomerData := TmpCustomer.FindFirst();

        Account.Get(TmpAccount."No.");
        if (not Account."NPR Magento Contact") then
            Error('Not a valid Magento contact.');

        if (UpdateMember(TmpAccount)) then
            Account.Get(TmpAccount."No.");

        if (Account.Type = Account.Type::Company) then begin
            ContactXrec.Get(Account."No.");
            Contact.TransferFields(Account, true);

            MarketingSetup.Get();
            ContactBusinessRelation.Get(Contact."No.", MarketingSetup."Bus. Rel. Code for Customers");

            Customer.Get(ContactBusinessRelation."No.");
            if (UpdateCustomerData) then begin
                Customer."NPR Magento Display Group" := TmpCustomer."NPR Magento Display Group";
                Customer."NPR Magento Payment Group" := TmpCustomer."NPR Magento Payment Group";
                Customer."NPR Magento Shipping Group" := TmpCustomer."NPR Magento Shipping Group";
                Customer."NPR Magento Store Code" := TmpCustomer."NPR Magento Store Code";
                Customer.Modify();
            end;

            Account.Validate(Name, TmpAccount."Company Name");
            Account.Validate("VAT Registration No.", TmpAccount."VAT Registration No.");
            Account.Validate("Currency Code", TmpAccount."Currency Code");

            Account."First Name" := TmpAccount."First Name";
            Account.Surname := TmpAccount.Surname;

        end;

        if (Account.Type = Account.Type::Person) then begin
            Account.Validate("First Name", TmpAccount."First Name");
            Account.Validate(Surname, TmpAccount.Surname);
        end;

        Account.Validate("Name 2", TmpAccount."Name 2");
        Account.Validate(Address, TmpAccount.Address);
        Account.Validate("Address 2", TmpAccount."Address 2");
        Account.Validate("Post Code", TmpAccount."Post Code");
        Account.Validate(City, TmpAccount.City);
        Account.Validate("Country/Region Code", TmpAccount."Country/Region Code");

        if (TmpAccount."E-Mail" <> '') then begin
            if (LowerCase(TmpAccount."E-Mail") <> LowerCase(Account."E-Mail")) then begin
                Contact.Reset();
                Contact.SetFilter("E-Mail", '=%1', LowerCase(TmpAccount."E-Mail"));
                if (not Contact.IsEmpty()) then
                    Error('Merging this account with an existing account is not possible.');
            end;

            Account.Validate("E-Mail", LowerCase(TmpAccount."E-Mail"));
        end;

        Account.Validate("Phone No.", TmpAccount."Phone No.");
        Account.Modify();
        Account.DoModify(ContactXrec);

        TmpAccountResponse.TransferFields(Account, true);
        TmpAccountResponse.Insert();
    end;

    local procedure GetAccountWorker(ContactNo: Code[20]; var TmpContact: Record Contact temporary; var TmpSellToCustomer: Record Customer temporary; var TmpBillToCustomer: Record Customer temporary; var TmpShipToAddress: Record "Ship-to Address" temporary): Boolean
    var
        Contact: Record Contact;
        SellToCustomer: Record Customer;
        BillToCustomer: Record Customer;
        ShipToAddress: Record "Ship-to Address";
        MarketingSetup: Record "Marketing Setup";
        ContactBusinessRelation: Record "Contact Business Relation";
        MagentoContactShiptoAdrs: Record "NPR Magento Contact ShipToAdr.";
    begin

        Contact.Get(ContactNo);
        if (not Contact."NPR Magento Contact") then
            Error('Not a valid Magento contact.');

        TmpContact.TransferFields(Contact, true);
        TmpContact.Insert();

        if (not MarketingSetup.Get()) then
            exit;

        if (MarketingSetup."Bus. Rel. Code for Customers" = '') then
            exit;

        if (Contact."Company No." = '') then
            exit;

        ContactBusinessRelation.SetFilter("Contact No.", '=%1', Contact."Company No.");
        ContactBusinessRelation.SetFilter("Business Relation Code", '=%1', MarketingSetup."Bus. Rel. Code for Customers");
        if (not ContactBusinessRelation.FindFirst()) then
            exit;

        if (not SellToCustomer.Get(ContactBusinessRelation."No.")) then
            exit;
        TmpSellToCustomer.TransferFields(SellToCustomer, true);
        TmpSellToCustomer.Insert();

        BillToCustomer.Get(TmpSellToCustomer.GetBillToCustomerNo());
        TmpBillToCustomer.TransferFields(BillToCustomer, true);
        TmpBillToCustomer.Insert();

        ShipToAddress.SetFilter("Customer No.", '=%1', TmpSellToCustomer."No.");
        if (ShipToAddress.FindSet()) then begin
            repeat
                TmpShipToAddress.TransferFields(ShipToAddress, true);

                MagentoContactShiptoAdrs.SetFilter("Customer No.", '=%1', ShipToAddress."Customer No.");
                MagentoContactShiptoAdrs.SetFilter("Ship-to Code", '=%1', ShipToAddress.Code);
                if (MagentoContactShiptoAdrs.FindFirst()) then begin

                    if (MagentoContactShiptoAdrs.Visibility = MagentoContactShiptoAdrs.Visibility::PUBLIC) then
                        TmpShipToAddress.Insert();

                    if ((MagentoContactShiptoAdrs."Created By Contact No." = ContactNo) and (MagentoContactShiptoAdrs.Visibility = MagentoContactShiptoAdrs.Visibility::PRIVATE)) then
                        TmpShipToAddress.Insert();

                end else begin
                    // No visibility rules defined for this address
                    TmpShipToAddress.Insert();
                end;

            until (ShipToAddress.Next() = 0);
        end;

        exit(true);
    end;

    local procedure AddAccountWorker(var TmpAccount: Record Contact temporary; var TmpAccountResponse: Record Contact temporary)
    var
        TempOneTimePassword: Record "NPR M2 One Time Password" temporary;
        TempCorporateAccount: Record Contact temporary;
        Contact: Record Contact;
        ReasonText: Text;
    begin

        if (TmpAccount."E-Mail" = '') then
            Error('E-Mail can not be empty.');

        if (TmpAccount."NPR Magento Password (Md5)" = '') then
            Error('Password must not be blank.');

        TempOneTimePassword."Password (Hash)" := TmpAccount."NPR Magento Password (Md5)";
        TempOneTimePassword."E-Mail" := LowerCase(TmpAccount."E-Mail");
        TempOneTimePassword.Insert();

        if (not AuthenticatePassword(TempOneTimePassword, TempCorporateAccount, ReasonText)) then
            Error('Invalid account, password combination.');

        TempCorporateAccount.SetFilter("Company No.", '=%1', TmpAccount."Company No.");
        if (not TempCorporateAccount.FindFirst()) then
            Error('Invalid corporate id %1 for account, password combination.', TmpAccount."Company No.");



        Contact."No." := '';
        Contact.Type := Contact.Type::Person;
        Contact."Company No." := TempCorporateAccount."No.";

        if (not AddMembershipMember(TmpAccount, Contact, TempCorporateAccount."No.")) then
            Contact.Insert(true);

        Contact.InheritCompanyToPersonData(TempCorporateAccount);

        Contact.Validate(Name, TmpAccount."Company Name");
        Contact.Validate("Name 2", TmpAccount."Name 2");

        Contact.Validate(Address, TmpAccount.Address);
        Contact.Validate("Address 2", TmpAccount."Address 2");

        if (TmpAccount."Post Code" <> '') then
            Contact.Validate("Post Code", TmpAccount."Post Code");
        if (TmpAccount.City <> '') then
            Contact.Validate(City, TmpAccount.City);
        if (TmpAccount."Country/Region Code" <> '') then
            Contact.Validate("Country/Region Code", TmpAccount."Country/Region Code");

        if (TmpAccount."Currency Code" <> '') then
            Contact.Validate("Currency Code", TmpAccount."Currency Code");

        if (TmpAccount."VAT Registration No." <> '') then
            Contact.Validate("VAT Registration No.", TmpAccount."VAT Registration No.");

        if (TmpAccount."E-Mail 2" <> '') then
            Contact.Validate("E-Mail", LowerCase(TmpAccount."E-Mail 2"));

        if (TmpAccount."Phone No." <> '') then
            Contact.Validate("Phone No.", TmpAccount."Phone No.");

        if (TmpAccount."First Name" <> '') then
            Contact.Validate("First Name", TmpAccount."First Name");

        if (TmpAccount.Surname <> '') then
            Contact.Validate(Surname, TmpAccount.Surname);

        Contact."NPR Magento Contact" := true;
        Contact.Modify();

        TmpAccountResponse.TransferFields(Contact, true);
        TmpAccountResponse.Insert();
    end;

    local procedure DeleteAccountWorker(var TmpContact: Record Contact)
    var
        Account: Record Contact;
    begin

        TmpContact.FindFirst();
        Account.Get(TmpContact."No.");

        if (Account.Type = Account.Type::Company) then begin
            Account.SetFilter("Company No.", ' =%1', TmpContact."No.");
            Account.ModifyAll("NPR Magento Contact", false);
        end else begin
            Account."NPR Magento Contact" := false;
            Account.Modify();
        end;

        BlockMember(Account);
    end;

    local procedure CreateShiptoAddressWorker(var TmpAccount: Record Contact temporary; var TmpShiptoAddressRequest: Record "Ship-to Address" temporary; var TmpShiptoAddressResponse: Record "Ship-to Address" temporary)
    var
        AccountSetup: Record "NPR M2 Account Setup";
        Account: Record Contact;
        Contact: Record Contact;
        ShiptoAddress: Record "Ship-to Address";
        MarketingSetup: Record "Marketing Setup";
        ContactBusinessRelation: Record "Contact Business Relation";
        MagentoContactShiptoAdrs: Record "NPR Magento Contact ShipToAdr.";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        if (not AccountSetup.Get()) then begin
            AccountSetup.Init();
            AccountSetup.Insert();
        end;

        if (AccountSetup."No. Series Ship-to Address" = '') then begin
            AccountSetup."No. Series Ship-to Address" := CreateNoSerie('NPR-SHIPTO', 'CA00000000', 'Auto assigned ship-to codes.');
            AccountSetup.Modify();
        end;


        if (not MarketingSetup.Get()) then
            Error('Marketing Setup not found.');

        if (MarketingSetup."Bus. Rel. Code for Customers" = '') then
            Error('Business Relation Code for Customers in Marketing Setup must not be blank.');

        TmpAccount.FindFirst();
        Account.Get(TmpAccount."No.");

        if (Account.Type = Account.Type::Person) then
            Contact.Get(Account."Company No.");

        if (Account.Type = Account.Type::Company) then
            Contact.TransferFields(Account, true);

        ContactBusinessRelation.Get(Contact."No.", MarketingSetup."Bus. Rel. Code for Customers");

        TmpShiptoAddressRequest.FindSet();
        repeat
            ShiptoAddress."Customer No." := ContactBusinessRelation."No.";
#pragma warning disable AA0139
            ShiptoAddress.Code := NoSeriesManagement.GetNextNo(AccountSetup."No. Series Ship-to Address", Today, true);
#pragma warning restore
            ShiptoAddress.Insert(true);

            ShiptoAddress.TransferFields(TmpShiptoAddressRequest, false);
            ShiptoAddress.Modify(true);

            MagentoContactShiptoAdrs."Customer No." := ShiptoAddress."Customer No.";
            MagentoContactShiptoAdrs."Ship-to Code" := ShiptoAddress.Code;
            MagentoContactShiptoAdrs."Created By Contact No." := Account."No.";
            MagentoContactShiptoAdrs."Created At" := CurrentDateTime();
            case Account.Type of
                Account.Type::Person:
                    MagentoContactShiptoAdrs.Visibility := MagentoContactShiptoAdrs.Visibility::PRIVATE;
                Account.Type::Company:
                    MagentoContactShiptoAdrs.Visibility := MagentoContactShiptoAdrs.Visibility::PUBLIC;
            end;
            MagentoContactShiptoAdrs.Insert();

            TmpShiptoAddressResponse.TransferFields(ShiptoAddress, true);
            TmpShiptoAddressResponse.Insert();

        until (TmpShiptoAddressRequest.Next() = 0);
    end;

    local procedure UpdateShiptoAddressWorker(var TmpAccount: Record Contact temporary; var TmpShiptoAddressRequest: Record "Ship-to Address" temporary; var TmpShiptoAddressResponse: Record "Ship-to Address" temporary)
    var
        Account: Record Contact;
        Contact: Record Contact;
        ShiptoAddress: Record "Ship-to Address";
        MarketingSetup: Record "Marketing Setup";
        ContactBusinessRelation: Record "Contact Business Relation";
        MagentoContactShiptoAdrs: Record "NPR Magento Contact ShipToAdr.";
        AllowAction: Boolean;
    begin

        TmpAccount.FindFirst();
        Account.Get(TmpAccount."No.");

        if (Account.Type = Account.Type::Person) then
            Contact.Get(Account."Company No.");

        if (Account.Type = Account.Type::Company) then
            Contact.TransferFields(Account, true);

        MarketingSetup.Get();
        ContactBusinessRelation.Get(Contact."No.", MarketingSetup."Bus. Rel. Code for Customers");

        TmpShiptoAddressRequest.FindSet();
        repeat

            AllowAction := false;

            MagentoContactShiptoAdrs.SetFilter("Customer No.", '=%1', ContactBusinessRelation."No.");
            MagentoContactShiptoAdrs.SetFilter("Ship-to Code", '=%1', TmpShiptoAddressRequest.Code);
            if (MagentoContactShiptoAdrs.FindFirst()) then begin

                if ((MagentoContactShiptoAdrs.Visibility = MagentoContactShiptoAdrs.Visibility::PUBLIC) and (Account.Type = Account.Type::Company)) then
                    AllowAction := true;

                if ((MagentoContactShiptoAdrs."Created By Contact No." = TmpAccount."No.") and (MagentoContactShiptoAdrs.Visibility = MagentoContactShiptoAdrs.Visibility::PRIVATE)) then
                    AllowAction := true;

            end else begin
                // No visibility rules defined for this address
                if (Account.Type = Account.Type::Company) then
                    AllowAction := true;
            end;

            if (not AllowAction) then
                Error('You are not allowed to update the ship-to address %1.', TmpShiptoAddressRequest.Code);

            ShiptoAddress.Get(ContactBusinessRelation."No.", TmpShiptoAddressRequest.Code);
            ShiptoAddress.TransferFields(TmpShiptoAddressRequest, false);
            ShiptoAddress.Modify(true);

            TmpShiptoAddressResponse.TransferFields(ShiptoAddress, true);
            TmpShiptoAddressResponse.Insert();

        until (TmpShiptoAddressRequest.Next() = 0);
    end;

    local procedure DeleteShiptoAddressWorker(var TmpAccount: Record Contact temporary; var TmpShiptoAddressRequest: Record "Ship-to Address" temporary)
    var
        Account: Record Contact;
        Contact: Record Contact;
        ShiptoAddress: Record "Ship-to Address";
        MarketingSetup: Record "Marketing Setup";
        ContactBusinessRelation: Record "Contact Business Relation";
        MagentoContactShiptoAdrs: Record "NPR Magento Contact ShipToAdr.";
        AllowAction: Boolean;
    begin

        TmpAccount.FindFirst();
        Account.Get(TmpAccount."No.");

        if (Account.Type = Account.Type::Person) then
            Contact.Get(Account."Company No.");

        if (Account.Type = Account.Type::Company) then
            Contact.TransferFields(Account, true);

        MarketingSetup.Get();
        ContactBusinessRelation.Get(Contact."No.", MarketingSetup."Bus. Rel. Code for Customers");

        TmpShiptoAddressRequest.FindSet();
        repeat

            AllowAction := false;
            MagentoContactShiptoAdrs.SetFilter("Customer No.", '=%1', ContactBusinessRelation."No.");
            MagentoContactShiptoAdrs.SetFilter("Ship-to Code", '=%1', TmpShiptoAddressRequest.Code);
            if (MagentoContactShiptoAdrs.FindFirst()) then begin

                if ((MagentoContactShiptoAdrs.Visibility = MagentoContactShiptoAdrs.Visibility::PUBLIC) and (Account.Type = Account.Type::Company)) then
                    AllowAction := true;

                if ((MagentoContactShiptoAdrs."Created By Contact No." = TmpAccount."No.") and (MagentoContactShiptoAdrs.Visibility = MagentoContactShiptoAdrs.Visibility::PRIVATE)) then
                    AllowAction := true;

            end else begin
                // No visibility rules defined for this address
                if (Account.Type = Account.Type::Company) then
                    AllowAction := true;
            end;

            if (not AllowAction) then
                Error('You are not allowed to delet the ship-to address %1.', TmpShiptoAddressRequest.Code);

            ShiptoAddress.Get(ContactBusinessRelation."No.", TmpShiptoAddressRequest.Code);
            ShiptoAddress.Delete(true);

        until (TmpShiptoAddressRequest.Next() = 0);
    end;

    #endregion

    #region Member Management

    local procedure CreateMembership(var TmpContact: Record Contact temporary; var Customer: Record Customer): Boolean
    var
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        Membership: Record "NPR MM Membership";
    begin
        if (TmpContact."Exclude from Segment") then
            exit(false);

        MembershipSalesSetup.SetFilter("Business Flow Type", '=%1', MembershipSalesSetup."Business Flow Type"::MEMBERSHIP);
        MembershipSalesSetup.SetFilter("Magento M2 Membership Sign-up", '=%1', true);
        if (not MembershipSalesSetup.FindFirst()) then
            exit(false);

        MemberInfoCapture.Init();
        MemberInfoCapture."Entry No." := 0;
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::NEW;
        TransferToInfoCapture(TmpContact, MemberInfoCapture);
        if (not MemberInfoCapture.Insert()) then
            exit(false);

        // These functions will blow-up when failing and the error message will propregate back to caller
        Membership.Get(MembershipManagement.CreateMembershipAll(MembershipSalesSetup, MemberInfoCapture, true));
        Customer.Get(Membership."Customer No.");
        MemberInfoCapture.Delete();

        exit(true);
    end;

    local procedure AddMembershipMember(var TmpContact: Record Contact temporary; var Contact: Record Contact; CorporateContactNo: Code[20]): Boolean
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MembershipRole: Record "NPR MM Membership Role";
        MemberEntryNo: Integer;
        ReasonText: Text;
    begin
        MembershipRole.SetCurrentKey("Contact No.");
        MembershipRole.SetFilter("Contact No.", '=%1', CorporateContactNo);
        if (not MembershipRole.FindFirst()) then
            exit(false);

        MemberInfoCapture.Init();
        MemberInfoCapture."Entry No." := 0;
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::NEW;
        TransferToInfoCapture(TmpContact, MemberInfoCapture);

        if (not MemberInfoCapture.Insert()) then
            exit(false);

        // These functions will blow-up when failing and the error message will propregate back to caller
        MembershipManagement.AddMemberAndCard(MembershipRole."Membership Entry No.", MemberInfoCapture, true, MemberEntryNo, ReasonText);

        MembershipRole.Get(MembershipRole."Membership Entry No.", MemberEntryNo);
        Contact.Get(MembershipRole."Contact No.");

        MemberInfoCapture.Delete();

        exit(true);
    end;

    local procedure UpdateMember(var TmpContact: Record Contact temporary): Boolean
    var
        MembershipRole: Record "NPR MM Membership Role";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        Member: Record "NPR MM Member";
    begin
        MembershipRole.SetCurrentKey("Contact No.");
        MembershipRole.SetFilter("Contact No.", '=%1', TmpContact."No.");
        if (not MembershipRole.FindFirst()) then
            exit(false);

        Member.Get(MembershipRole."Member Entry No.");
        MemberInfoCapture.Init();
        MemberInfoCapture."Entry No." := 0;
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::NEW;

        TransferMemberInfoToCapture(Member, MemberInfoCapture);
        TransferToInfoCapture(TmpContact, MemberInfoCapture);

        if (not MemberInfoCapture.Insert()) then
            exit(false);

        exit(MembershipManagement.UpdateMember(MembershipRole."Membership Entry No.", MembershipRole."Member Entry No.", MemberInfoCapture));
    end;

    local procedure BlockMember(Contact: Record Contact): Boolean
    var
        MembershipRole: Record "NPR MM Membership Role";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
    begin
        MembershipRole.SetCurrentKey("Contact No.");
        MembershipRole.SetFilter("Contact No.", '=%1', Contact."No.");
        if (not MembershipRole.FindFirst()) then
            exit(false);

        case Contact.Type of
            Contact.Type::Company:
                MembershipManagement.BlockMembership(MembershipRole."Membership Entry No.", true);
            Contact.Type::Person:
                MembershipManagement.BlockMember(MembershipRole."Membership Entry No.", MembershipRole."Member Entry No.", true)
        end;

        exit(true);
    end;

    local procedure TransferMemberInfoToCapture(Member: Record "NPR MM Member"; var MemberInfoCapture: Record "NPR MM Member Info Capture")
    begin
        MemberInfoCapture."First Name" := CopyStr(Member."First Name", 1, MaxStrLen(MemberInfoCapture."First Name"));
        MemberInfoCapture."Middle Name" := CopyStr(Member."Middle Name", 1, MaxStrLen(MemberInfoCapture."Middle Name"));
        MemberInfoCapture."Last Name" := CopyStr(Member."Last Name", 1, MaxStrLen(MemberInfoCapture."Last Name"));
        MemberInfoCapture.Address := CopyStr(Member.Address, 1, MaxStrLen(MemberInfoCapture.Address));
        MemberInfoCapture."Post Code Code" := CopyStr(Member."Post Code Code", 1, MaxStrLen(MemberInfoCapture."Post Code Code"));
        MemberInfoCapture.City := CopyStr(Member.City, 1, MaxStrLen(MemberInfoCapture.City));
        MemberInfoCapture."Country Code" := CopyStr(Member."Country Code", 1, MaxStrLen(MemberInfoCapture."Country Code"));
        MemberInfoCapture.Country := CopyStr(Member.Country, 1, MaxStrLen(MemberInfoCapture.Country));

        MemberInfoCapture."Phone No." := CopyStr(Member."Phone No.", 1, MaxStrLen(MemberInfoCapture."Phone No."));
        MemberInfoCapture."E-Mail Address" := CopyStr(Member."E-Mail Address", 1, MaxStrLen(MemberInfoCapture."E-Mail Address"));

        MemberInfoCapture."Social Security No." := CopyStr(Member."Social Security No.", 1, MaxStrLen(MemberInfoCapture."Social Security No."));
        MemberInfoCapture.Gender := Member.Gender;
        MemberInfoCapture.Birthday := Member.Birthday;
        MemberInfoCapture."News Letter" := Member."E-Mail News Letter";
        MemberInfoCapture."Notification Method" := Member."Notification Method";
        MemberInfoCapture."Store Code" := CopyStr(Member."Store Code", 1, MaxStrLen(MemberInfoCapture."Store Code"));
    end;

    local procedure TransferToInfoCapture(var TmpContact: Record Contact temporary; var MemberInfoCapture: Record "NPR MM Member Info Capture")
    begin
        MemberInfoCapture."Company Name" := CopyStr(TmpContact."Company Name", 1, MaxStrLen(MemberInfoCapture."Company Name"));
        MemberInfoCapture."First Name" := CopyStr(TmpContact."First Name", 1, MaxStrLen(MemberInfoCapture."First Name"));
        MemberInfoCapture."Middle Name" := CopyStr(TmpContact."Middle Name", 1, MaxStrLen(MemberInfoCapture."Middle Name"));
        MemberInfoCapture."Last Name" := CopyStr(TmpContact.Surname, 1, MaxStrLen(MemberInfoCapture."Last Name"));
        MemberInfoCapture.Address := CopyStr(TmpContact.Address, 1, MaxStrLen(MemberInfoCapture.Address));
        MemberInfoCapture."Post Code Code" := CopyStr(TmpContact."Post Code", 1, MaxStrLen(MemberInfoCapture."Post Code Code"));
        MemberInfoCapture.City := CopyStr(TmpContact.City, 1, MaxStrLen(MemberInfoCapture.City));
        MemberInfoCapture."Country Code" := CopyStr(TmpContact."Country/Region Code", 1, MaxStrLen(MemberInfoCapture."Country Code"));

        MemberInfoCapture."Phone No." := CopyStr(TmpContact."Phone No.", 1, MaxStrLen(MemberInfoCapture."Phone No."));
        MemberInfoCapture."E-Mail Address" := CopyStr(TmpContact."E-Mail", 1, MaxStrLen(MemberInfoCapture."E-Mail Address"));

        if (TmpContact."E-Mail 2" <> '') then
            MemberInfoCapture."E-Mail Address" := CopyStr(TmpContact."E-Mail 2", 1, MaxStrLen(MemberInfoCapture."E-Mail Address"));
    end;

    #endregion

    procedure CreateSecurityToken(EMail: Text[80]) Token: Text[40]
    var
        OneTimePassword: Record "NPR M2 One Time Password";
        AccountSetup: Record "NPR M2 Account Setup";
    begin
        if (not AccountSetup.Get()) then;

        if (AccountSetup."OTP Validity (Hours)" = 0) then
            AccountSetup."OTP Validity (Hours)" := 24;

        OneTimePassword."Password (Hash)" := UpperCase(DelChr(Format(CreateGuid()), '=', '{}-'));
        OneTimePassword."E-Mail" := LowerCase(EMail);
        OneTimePassword."Created At" := CurrentDateTime;
        OneTimePassword."Valid Until" := CurrentDateTime + AccountSetup."OTP Validity (Hours)" * 3600 * 1000;

        OneTimePassword.Insert();

        AddLogEntry(LogEntry.Type::OTP_CREATE, LogEntry.Status::OK, EMail, '');

        exit(OneTimePassword."Password (Hash)");
    end;

    procedure CreateResetPasswordCommunicationTemplate(Contact: Record Contact; Token: Text[40]) EntryNo: Integer
    var
        AccountComTemplate: Record "NPR M2 Account Com. Template";
        AccountSetup: Record "NPR M2 Account Setup";
        Base65: Codeunit "Base64 Convert";
    begin
        if (not AccountSetup.Get()) then;

        if (AccountSetup."Reset Password URL" = '') then
            AccountSetup."Reset Password URL" := 'http://test.shop.navipartner.dk/changepassword?token=%1&b64email=%2';

        AccountComTemplate.Type := AccountComTemplate.Type::PW_RESET;
        AccountComTemplate."Company Name" := Contact.Name;
        AccountComTemplate."First Name" := Contact."First Name";
        AccountComTemplate."Last Name" := Contact.Surname;
        AccountComTemplate."E-Mail" := LowerCase(Contact."E-Mail");
        AccountComTemplate."Security Token" := Token;
        AccountComTemplate."B64 Email" := Base65.ToBase64(LowerCase(Contact."E-Mail"));
        AccountComTemplate.URL1 := StrSubstNo(AccountSetup."Reset Password URL", Token, AccountComTemplate."B64 Email");

        AccountComTemplate.Insert();

        exit(AccountComTemplate."Entry No.");
    end;

    local procedure AddLogEntry(Type: Option; Status: Option; EMail: Text[80]; ReasonText: Text)
    var
        AuthenticationLog: Record "NPR Authentication Log";
    begin
        AuthenticationLog.Init();

        AuthenticationLog.Type := Type;
        AuthenticationLog."Created At" := CurrentDateTime;
        AuthenticationLog."Account Id" := EMail;
        AuthenticationLog.Status := Status;
        AuthenticationLog."Result Message" := CopyStr(ReasonText, 1, MaxStrLen(AuthenticationLog."Result Message"));
        AuthenticationLog.UserId := CopyStr(UserId, 1, MaxStrLen(AuthenticationLog."Result Message"));
        AuthenticationLog.Insert();
    end;

    local procedure CreateNoSerie(NoSerieCode: Code[20]; StartNumber: Code[20]; Description: Text[30]): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if (not NoSeries.Get(NoSerieCode)) then begin
            NoSeries.Code := NoSerieCode;
            NoSeries.Insert();
        end;

        NoSeries.Description := Description;
        NoSeries."Default Nos." := true;
        NoSeries.Modify();

        if (not NoSeriesLine.Get(NoSerieCode, 10000)) then begin
            NoSeriesLine."Series Code" := NoSerieCode;
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting Date" := CalcDate('<CY-1Y+1D>', Today);
            NoSeriesLine."Starting No." := StartNumber;
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Insert();
        end;

        exit(NoSerieCode);
    end;

    local procedure CalculatedName(FirstName: Text[30]; MiddleName: Text[30]; LastName: Text[30]) NewName: Text[50]
    var
        NewName92: Text[92];
    begin
        NewName92 := FirstName;

        if (MiddleName <> '') then
            NewName92 += ' ' + MiddleName;

        if (LastName <> '') then
            NewName92 += ' ' + LastName;

        NewName92 := DelChr(NewName92, '<', ' ');
        NewName := CopyStr(NewName92, 1, MaxStrLen(NewName));
    end;

    procedure MagentoApiPost(Method: Text; var Body: JsonToken; var Result: JsonToken)
    var
        MagentoSetup: Record "NPR Magento Setup";
        HttpWebRequest: HttpRequestMessage;
        HttpWebResponse: HttpResponseMessage;
        Headers: HttpHeaders;
        Content: HttpContent;
        Client: HttpClient;
        ContentTxt: Text;
        Response: Text;
    begin
        Clear(Response);
        if Method = '' then
            exit;

        Body.WriteTo(ContentTxt);

        MagentoSetup.Get();
        MagentoSetup.TestField("Api Url");
        if MagentoSetup."Api Url"[StrLen(MagentoSetup."Api Url")] <> '/' then
            MagentoSetup."Api Url" += '/';

        if (CopyStr(MagentoSetup."Api Url", StrLen(MagentoSetup."Api Url") - (StrLen('naviconnect/')) + 1) = 'naviconnect/') then
            MagentoSetup."Api Url" := CopyStr(MagentoSetup."Api Url", 1, StrLen(MagentoSetup."Api Url") - (StrLen('naviconnect/'))) + 'b2b_customer/';

        HttpWebRequest.SetRequestUri(MagentoSetup."Api Url" + Method);
        HttpWebRequest.Method('POST');
        Content.WriteFrom(ContentTxt);
        Content.GetHeaders(Headers);
        if Headers.Contains('Content-Type') then
            Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'naviconnect/json');

        HttpWebRequest.Content(Content);
        HttpWebRequest.GetHeaders(Headers);
        if MagentoSetup."Api Authorization" <> '' then
            Headers.Add('Authorization', MagentoSetup."Api Authorization")
        else
            Headers.Add('Authorization', 'Basic ' + MagentoSetup.GetBasicAuthInfo());

        Client.Timeout := 60000;
        Client.Send(HttpWebRequest, HttpWebResponse);
        HttpWebResponse.Content.ReadAs(Response);
        if not HttpWebResponse.IsSuccessStatusCode() then
            Error('%1 - %2  \%3', HttpWebResponse.HttpStatusCode, HttpWebResponse.ReasonPhrase, Response);

        Result.ReadFrom(Response);
    end;
}