codeunit 6151151 "M2 Account Manager"
{
    // MAG2.20/TSA /20181211 CASE 320425 Initial Version
    // MAG2.20/TSA /20190306 CASE 320425 Allow blank source password for password change
    // NPR5.49/TSA /20190221 CASE 346698 - Signature change from 2016, 2017
    // MAG2.21.01/TSA /20190502 CASE 320424 Reset password request forwarded to Magento
    // MAG2.21.01/TSA /20190506 CASE 353964 Try functions cant have DML statements, refactored the try functions to .run instead


    trigger OnRun()
    begin

        //-MAG2.21.01 [353964]

        case SelectedAccountFunction of
          AccountFunctions::AUTHENTICATE :    AuthenticatePasswordWorker (TmpGlobalOneTimePassword, TmpGlobalContact, true);
          AccountFunctions::CHANGE_PASSWORD : ChangePasswordWorker (TmpGlobalOneTimePassword, TmpGlobalContact);
          AccountFunctions::CREATE_ACCOUNT :  CreateAccountWorker (TmpGlobalContact, TmpGlobalCustomer1, TmpGlobalAccount);
          AccountFunctions::UPDATE_ACCOUNT :  UpdateAccountWorker (TmpGlobalContact, TmpGlobalCustomer1, TmpGlobalAccount);
          AccountFunctions::ADD_ACCOUNT :     AddAccountWorker (TmpGlobalContact, TmpGlobalAccount);
          AccountFunctions::DELETE_ACCOUNT : DeleteAccountWorker (TmpGlobalContact);

          AccountFunctions::CREATE_SHIPTO : CreateShiptoAddressWorker (TmpGlobalAccount, TmpGlobsalShiptoAddressRequest, TmpGlobalShiptoAddressResponse);
          AccountFunctions::UPDATE_SHIPTO : UpdateShiptoAddressWorker (TmpGlobalAccount, TmpGlobsalShiptoAddressRequest, TmpGlobalShiptoAddressResponse);
          AccountFunctions::DELETE_SHIPTO : DeleteShiptoAddressWorker (TmpGlobalAccount, TmpGlobsalShiptoAddressRequest);
        end;
        //+MAG2.21.01 [353964]
    end;

    var
        LogEntry: Record "Authentication Log";
        RESET_EMAIL_SENT: Label 'An email with reset instructions was sent to %1';
        AccountFunctions: Option AUTHENTICATE,CHANGE_PASSWORD,CREATE_ACCOUNT,DELETE_ACCOUNT,ADD_ACCOUNT,UPDATE_ACCOUNT,CREATE_SHIPTO,UPDATE_SHIPTO,DELETE_SHIPTO;
        SelectedAccountFunction: Option;
        AccountManager: Codeunit "M2 Account Manager";
        TmpGlobalContact: Record Contact temporary;
        TmpGlobalAccount: Record Contact temporary;
        TmpGlobalCustomer1: Record Customer temporary;
        TmpGlobalOneTimePassword: Record "M2 One Time Password" temporary;
        TmpGlobsalShiptoAddressRequest: Record "Ship-to Address" temporary;
        TmpGlobalShiptoAddressResponse: Record "Ship-to Address" temporary;

    procedure SetFunction(FunctionIn: Option)
    begin

        //-MAG2.21.01 [353964]
        SelectedAccountFunction := FunctionIn;
        //+MAG2.21.01 [353964]
    end;

    procedure AuthenticatePassword(var TmpOneTimePassword: Record "M2 One Time Password" temporary;var TmpContact: Record Contact temporary;var ReasonText: Text): Boolean
    begin

        //-NPR5.49 [320425]
        // IF (TryAuthenticatePassword (TmpOneTimePassword, TmpContact)) THEN BEGIN
        if (TryAuthenticatePassword (TmpOneTimePassword, TmpContact, true)) then begin
        //+NPR5.49 [320425]
          ReasonText := '';
          AddLogEntry (LogEntry.Type::AUTHENTICATE, LogEntry.Status::OK, TmpOneTimePassword."E-Mail", ReasonText);

        end else begin
          ReasonText := GetLastErrorText ();
          AddLogEntry (LogEntry.Type::AUTHENTICATE, LogEntry.Status::FAIL, TmpOneTimePassword."E-Mail", ReasonText);

        end;

        exit (ReasonText = '');
    end;

    procedure ChangePassword(var TmpOneTimePassword: Record "M2 One Time Password" temporary;var TmpContact: Record Contact temporary;var ReasonText: Text): Boolean
    begin

        //-NPR5.49 [320425]a
        //IF (TryAuthenticatePassword (TmpOneTimePassword, TmpContact)) THEN BEGIN
        if (TryAuthenticatePassword (TmpOneTimePassword, TmpContact, true)) then begin
        //+NPR5.49 [320425]

          if (TryChangePassword (TmpOneTimePassword, TmpContact)) then begin
            ReasonText := '';
            AddLogEntry (LogEntry.Type::PASSWORD_CHANGE, LogEntry.Status::OK, TmpOneTimePassword."E-Mail", ReasonText);
            exit (true);
          end;
        end;

        ReasonText := GetLastErrorText ();

        AddLogEntry (LogEntry.Type::PASSWORD_CHANGE, LogEntry.Status::FAIL, TmpOneTimePassword."E-Mail", ReasonText);
        exit (false);
    end;

    procedure ResetPassword(var TmpOneTimePassword: Record "M2 One Time Password" temporary;var ReasonText: Text): Boolean
    begin

        if (not TmpOneTimePassword.FindFirst ()) then ;

        if (TryResetPassword (TmpOneTimePassword."E-Mail")) then begin
          ReasonText := '';
          AddLogEntry (LogEntry.Type::RESET_PASSWORD_REQUEST, LogEntry.Status::OK, TmpOneTimePassword."E-Mail", ReasonText);

        end else begin
          ReasonText := GetLastErrorText ();
          AddLogEntry (LogEntry.Type::RESET_PASSWORD_REQUEST, LogEntry.Status::FAIL, TmpOneTimePassword."E-Mail", ReasonText);

        end;

        exit (ReasonText = '');
    end;

    procedure GetAccount(ContactNo: Code[20];var TmpContact: Record Contact temporary;var TmpSellToCustomer: Record Customer temporary;var TmpBillToCustomer: Record Customer temporary;var TmpShipToAddress: Record "Ship-to Address" temporary): Boolean
    var
        Contact: Record Contact;
        SellToCustomer: Record Customer;
        BillToCustomer: Record Customer;
        ShipToAddress: Record "Ship-to Address";
        MarketingSetup: Record "Marketing Setup";
        ContactBusinessRelation: Record "Contact Business Relation";
        MagentoContactShiptoAdrs: Record "Magento Contact Ship-to Adrs.";
    begin
        ClearLastError ();
        exit (GetAccountWorker (ContactNo, TmpContact, TmpSellToCustomer, TmpBillToCustomer, TmpShipToAddress));
    end;

    procedure CreateAccount(var TmpContact: Record Contact temporary;var TmpCustomer: Record Customer temporary;var TmpAccount: Record Contact temporary;var ReasonText: Text): Boolean
    begin

        if (TryCreateAccount (TmpContact, TmpCustomer, TmpAccount)) then begin
          ReasonText := '';
          exit (true);

        end else begin
          ReasonText := GetLastErrorText ();
          exit (false);

        end;
    end;

    procedure UpdateAccount(var TmpContact: Record Contact temporary;var TmpCustomer: Record Customer temporary;var TmpAccount: Record Contact temporary;var ReasonText: Text): Boolean
    begin

        if (TryUpdateAccount (TmpContact, TmpCustomer, TmpAccount)) then begin
          ReasonText := '';
          exit (true);

        end else begin
          ReasonText := GetLastErrorText ();
          exit (false);

        end;
    end;

    procedure AddAccount(var TmpAccount: Record Contact temporary;var TmpAccountResponse: Record Contact temporary;var ReasonText: Text): Boolean
    var
        TmpOneTimePassword: Record "M2 One Time Password" temporary;
    begin

        if (TryAddAccount (TmpAccount, TmpAccountResponse)) then begin
          ReasonText := '';

          if (TmpAccountResponse.FindFirst()) then begin
            if (not TryResetPassword (LowerCase (TmpAccount."E-Mail 2"))) then begin
              ReasonText := GetLastErrorText ();
              exit (false);
            end;

            exit (true);

          end;

        end else begin
          ReasonText := GetLastErrorText ();
          exit (false);

        end;
    end;

    procedure DeleteAccount(var ContactNo: Code[20];var ReasonText: Text): Boolean
    begin

        if (TryDeleteAccount (ContactNo)) then begin
          ReasonText := '';
          exit (true);

        end else begin
          ReasonText := GetLastErrorText ();
          exit (false);

        end;
    end;

    procedure CreateShiptoAddress(var TmpAccount: Record Contact temporary;var TmpShiptoAddressRequest: Record "Ship-to Address" temporary;var TmpShiptoAddressResponse: Record "Ship-to Address" temporary;var ReasonText: Text): Boolean
    begin

        if (TryAddShiptoAddress (TmpAccount, TmpShiptoAddressRequest, TmpShiptoAddressResponse)) then begin
          ReasonText := '';
          exit (true);
        end;

        ReasonText := GetLastErrorText;
        exit (false);
    end;

    procedure UpdateShiptoAddress(var TmpAccount: Record Contact temporary;var TmpShiptoAddressRequest: Record "Ship-to Address" temporary;var TmpShiptoAddressResponse: Record "Ship-to Address" temporary;var ReasonText: Text): Boolean
    begin

        if (TryUpdateShiptoAddress (TmpAccount, TmpShiptoAddressRequest, TmpShiptoAddressResponse)) then begin
          ReasonText := '';
          exit (true);
        end;

        ReasonText := GetLastErrorText;
        exit (false);
    end;

    procedure DeleteShiptoAddress(var TmpAccount: Record Contact temporary;var TmpShiptoAddressRequest: Record "Ship-to Address" temporary;var ReasonText: Text): Boolean
    begin

        if (TryDeleteShiptoAddress (TmpAccount, TmpShiptoAddressRequest)) then begin
          ReasonText := '';
          exit (true);
        end;

        ReasonText := GetLastErrorText;
        exit (false);
    end;

    [EventSubscriber(ObjectType::Page, 5050, 'OnAfterActionEvent', 'ResetMagentoPassword', true, true)]
    local procedure P5050ResetMagentoPasswordSubscriber(var Rec: Record Contact)
    var
        Contact: Record Contact;
        ReasonText: Text;
    begin

        //-MAG2.21.01 [320424]
        Contact := Rec;
        if not (ResetMagentoPassword (Contact, ReasonText)) then
          Error (ReasonText);
        //+MAG2.21.01 [320424]
    end;

    local procedure "----"()
    begin
    end;

    procedure TransferSetContact(var TmpContact: Record Contact temporary)
    begin

        //-MAG2.21.01 [353964]
        TmpContact.Reset ();
        if (TmpContact.FindSet ()) then begin
          repeat
            TmpGlobalContact.TransferFields (TmpContact, true);
            TmpGlobalContact.Insert ();
          until (TmpContact.Next () = 0);
        end;
        //+MAG2.21.01 [353964]
    end;

    procedure TransferGetContact(var TmpContact: Record Contact temporary)
    begin

        //-MAG2.21.01 [353964]
        if (TmpContact.IsTemporary ()) then
          TmpContact.DeleteAll ();

        TmpGlobalContact.Reset ();
        if (TmpGlobalContact.FindSet ()) then begin
          repeat
            TmpContact.TransferFields (TmpGlobalContact, true);
            TmpContact.Insert ();
          until (TmpGlobalContact.Next () = 0);
        end;
        //+MAG2.21.01 [353964]
    end;

    procedure TransferSetAccount(var TmpContact: Record Contact temporary)
    begin

        //-MAG2.21.01 [353964]
        TmpContact.Reset ();
        if (TmpContact.FindSet ()) then begin
          repeat
            TmpGlobalAccount.TransferFields (TmpContact, true);
            TmpGlobalAccount.Insert ();
          until (TmpContact.Next () = 0);
        end;
        //+MAG2.21.01 [353964]
    end;

    procedure TransferGetAccount(var TmpContact: Record Contact temporary)
    begin

        //-MAG2.21.01 [353964]
        if (TmpContact.IsTemporary ()) then
          TmpContact.DeleteAll ();

        TmpGlobalAccount.Reset ();
        if (TmpGlobalAccount.FindSet ()) then begin
          repeat
            TmpContact.TransferFields (TmpGlobalAccount, true);
            TmpContact.Insert ();
          until (TmpGlobalAccount.Next () = 0);
        end;
        //+MAG2.21.01 [353964]
    end;

    procedure TransferSetCustomer1(var TmpCustomer: Record Customer temporary)
    begin

        //-MAG2.21.01 [353964]
        TmpCustomer.Reset ();
        if (TmpCustomer.FindSet ()) then begin
          repeat
            TmpGlobalCustomer1.TransferFields (TmpCustomer, true);
            TmpGlobalCustomer1.Insert ();
          until (TmpCustomer.Next () = 0);
        end;
        //+MAG2.21.01 [353964]
    end;

    procedure TransferGetCustomer1(var TmpCustomer: Record Customer temporary)
    begin

        //-MAG2.21.01 [353964]
        if (TmpCustomer.IsTemporary) then
          TmpCustomer.DeleteAll ();

        TmpGlobalCustomer1.Reset ();
        if (TmpGlobalCustomer1.FindSet ()) then begin
          repeat
            TmpCustomer.TransferFields (TmpGlobalCustomer1, true);
            TmpCustomer.Insert ();
          until (TmpGlobalCustomer1.Next () = 0);
        end;
        //+MAG2.21.01 [353964]
    end;

    procedure TransferSetShiptoAddress(var TmpShiptoAddress: Record "Ship-to Address" temporary)
    begin

        TmpShiptoAddress.Reset ();
        if (TmpShiptoAddress.FindSet ()) then begin
          repeat
            TmpGlobsalShiptoAddressRequest.TransferFields (TmpShiptoAddress, true);
            TmpGlobsalShiptoAddressRequest.Insert ();
          until (TmpShiptoAddress.Next () = 0);
        end;
    end;

    procedure TransferGetShiptoAddress(var TmpShiptoAddress: Record "Ship-to Address" temporary)
    begin

        if (TmpShiptoAddress.IsTemporary ()) then
          TmpShiptoAddress.DeleteAll ();

        if (TmpGlobalShiptoAddressResponse.FindSet ()) then begin
          repeat
            TmpShiptoAddress.TransferFields (TmpGlobalShiptoAddressResponse, true);
            TmpShiptoAddress.Insert ();
          until (TmpGlobalShiptoAddressResponse.Next () = 0);
        end;
    end;

    procedure TransferSetOTP(var TmpOneTimePassword: Record "M2 One Time Password" temporary)
    begin

        //-MAG2.21.01 [353964]
        TmpOneTimePassword.Reset ();
        if (TmpOneTimePassword.FindSet ()) then begin
          repeat
            TmpGlobalOneTimePassword.TransferFields (TmpOneTimePassword, true);
            TmpGlobalOneTimePassword.Insert ();
          until (TmpGlobalOneTimePassword.Next () = 0);
        end;
        //+MAG2.21.01 [353964]
    end;

    local procedure "--Try Function - by invoking self"()
    begin
    end;

    local procedure TryAuthenticatePassword(var TmpOneTimePassword: Record "M2 One Time Password" temporary;var TmpContact: Record Contact temporary;AllowBlankPassword: Boolean) bOk: Boolean
    var
        Contact: Record Contact;
        OneTimePassword: Record "M2 One Time Password";
        OTPAuthentication: Boolean;
    begin

        //-MAG2.21.01 [353964]
        Clear (AccountManager);
        AccountManager.SetFunction (AccountFunctions::AUTHENTICATE);
        AccountManager.TransferSetOTP (TmpOneTimePassword);
        AccountManager.TransferSetContact (TmpContact);

        bOk := AccountManager.Run ();

        AccountManager.TransferGetContact (TmpContact);
        exit (bOk);
        //+MAG2.21.01 [353964]
    end;

    local procedure TryChangePassword(var TmpOneTimePassword: Record "M2 One Time Password" temporary;var TmpContact: Record Contact temporary) bOk: Boolean
    var
        Contact: Record Contact;
    begin

        //-MAG2.21.01 [353964]
        // ChangePasswordWorker (TmpOneTimePassword, TmpContact);

        Clear (AccountManager);
        AccountManager.SetFunction (AccountFunctions::CHANGE_PASSWORD);
        AccountManager.TransferSetOTP (TmpOneTimePassword);
        AccountManager.TransferSetContact (TmpContact);

        bOk := AccountManager.Run ();

        AccountManager.TransferGetContact (TmpContact);
        exit (bOk);
        //+MAG2.21.01 [353964]
    end;

    [TryFunction]
    local procedure TryResetPassword(Email: Text)
    var
        Contact: Record Contact;
        AccountComTemplate: Record "M2 Account Com. Template";
        Token: Text[40];
        TemplateEntryNo: Integer;
        ReasonText: Text;
        Body: DotNet JToken;
        Result: DotNet JToken;
    begin

        if (Email = '') then
          Error ('No account to reset.');

        Contact.Reset ();
        Contact.SetFilter ("E-Mail", '=%1', LowerCase (Email));
        Contact.SetFilter ("Magento Contact", '=%1', true);
        if (Contact.IsEmpty ()) then
          Error ('E-Mail does not identify a magento contact.');

        Contact.FindFirst ();

        //-MAG2.21.01 [320424]
        // Token := CreateSecurityToken (Email);
        // TemplateEntryNo := CreateResetPasswordCommunicationTemplate (Contact, Token);
        // AccountComTemplate.GET (TemplateEntryNo);
        //
        // IF (NOT SendMail (AccountComTemplate, ReasonText)) THEN
        //  ERROR (ReasonText);

        Body := Body.Parse (StrSubstNo ('{"customer":{"email":"%1"}}', Email));
        MagentoApiPost ('passwordreset', Body, Result);
        //+MAG2.21.01 [320424]
    end;

    local procedure TryCreateAccount(var TmpContact: Record Contact temporary;var TmpCustomer: Record Customer temporary;var TmpAccount: Record Contact temporary) bOk: Boolean
    var
        Contact: Record Contact;
        Customer: Record Customer;
        MarketingSetup: Record "Marketing Setup";
        ContactBusinessRelation: Record "Contact Business Relation";
        TmpOneTimePassword: Record "M2 One Time Password" temporary;
        ConfigTemplateHeader: Record "Config. Template Header";
        MagentoSetup: Record "Magento Setup";
        CustContUpdate: Codeunit "CustCont-Update";
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        RecRef: RecordRef;
        ReasonText: Text;
    begin

        //-MAG2.21.01 [353964]
        // ChangePasswordWorker (TmpOneTimePassword, TmpContact);

        Clear (AccountManager);
        AccountManager.SetFunction (AccountFunctions::CREATE_ACCOUNT);
        AccountManager.TransferSetOTP (TmpOneTimePassword);
        AccountManager.TransferSetContact (TmpContact);
        AccountManager.TransferSetCustomer1 (TmpCustomer);
        AccountManager.TransferSetAccount (TmpAccount);

        bOk := AccountManager.Run ();

        AccountManager.TransferGetContact (TmpContact);
        AccountManager.TransferGetCustomer1 (TmpCustomer);
        AccountManager.TransferGetAccount (TmpAccount);

        exit (bOk);
        //+MAG2.21.01 [353964]
    end;

    local procedure TryUpdateAccount(var TmpAccount: Record Contact temporary;var TmpCustomer: Record Customer temporary;var TmpAccountResponse: Record Contact temporary) bOK: Boolean
    begin

        //-MAG2.21.01 [353964]
        Clear (AccountManager);
        AccountManager.SetFunction (AccountFunctions::UPDATE_ACCOUNT);
        AccountManager.TransferSetContact (TmpAccount);
        AccountManager.TransferSetCustomer1 (TmpCustomer);
        AccountManager.TransferSetAccount (TmpAccountResponse);

        bOK := AccountManager.Run ();

        AccountManager.TransferGetContact (TmpAccount);
        AccountManager.TransferGetCustomer1 (TmpCustomer);
        AccountManager.TransferGetAccount (TmpAccountResponse);

        exit (bOK);
        //+MAG2.21.01 [353964]
    end;

    local procedure TryAddAccount(var TmpAccount: Record Contact temporary;var TmpAccountResponse: Record Contact temporary) bOk: Boolean
    begin

        //-MAG2.21.01 [353964]
        Clear (AccountManager);
        AccountManager.SetFunction (AccountFunctions::ADD_ACCOUNT);
        AccountManager.TransferSetContact (TmpAccount);

        bOk := AccountManager.Run ();

        AccountManager.TransferGetAccount (TmpAccountResponse);

        exit (bOk);
        //+MAG2.21.01 [353964]
    end;

    local procedure TryDeleteAccount(var ContactNo: Code[20]) bOk: Boolean
    var
        Account: Record Contact;
        TmpContact: Record Contact temporary;
    begin

        Account.Get (ContactNo);
        TmpContact.TransferFields (Account, true);
        TmpContact.Insert ();

        //-MAG2.21.01 [353964]
        Clear (AccountManager);
        AccountManager.SetFunction (AccountFunctions::DELETE_ACCOUNT);
        AccountManager.TransferSetContact (TmpContact);

        bOk := AccountManager.Run ();

        exit (bOk);
        //+MAG2.21.01 [353964]
    end;

    local procedure TryAddShiptoAddress(var TmpAccount: Record Contact temporary;var TmpShiptoAddressRequest: Record "Ship-to Address" temporary;var TmpShiptoAddressResponse: Record "Ship-to Address" temporary) bOk: Boolean
    begin

        Clear (AccountManager);
        AccountManager.SetFunction (AccountFunctions::CREATE_SHIPTO);
        AccountManager.TransferSetAccount (TmpAccount);
        AccountManager.TransferSetShiptoAddress (TmpShiptoAddressRequest);

        bOk := AccountManager.Run ();

        AccountManager.TransferGetShiptoAddress (TmpShiptoAddressResponse);

        exit (bOk);
    end;

    local procedure TryUpdateShiptoAddress(var TmpAccount: Record Contact temporary;var TmpShiptoAddressRequest: Record "Ship-to Address" temporary;var TmpShiptoAddressResponse: Record "Ship-to Address" temporary) bOk: Boolean
    begin

        Clear (AccountManager);
        AccountManager.SetFunction (AccountFunctions::UPDATE_SHIPTO);
        AccountManager.TransferSetAccount (TmpAccount);
        AccountManager.TransferSetShiptoAddress (TmpShiptoAddressRequest);

        bOk := AccountManager.Run ();

        AccountManager.TransferGetShiptoAddress (TmpShiptoAddressResponse);

        exit (bOk);
    end;

    local procedure TryDeleteShiptoAddress(var TmpAccount: Record Contact temporary;var TmpShiptoAddressRequest: Record "Ship-to Address" temporary) bOk: Boolean
    begin

        Clear (AccountManager);
        AccountManager.SetFunction (AccountFunctions::DELETE_SHIPTO);
        AccountManager.TransferSetAccount (TmpAccount);
        AccountManager.TransferSetShiptoAddress (TmpShiptoAddressRequest);

        bOk := AccountManager.Run ();

        exit (bOk);
    end;

    local procedure "--Workers"()
    begin
    end;

    local procedure AuthenticatePasswordWorker(var TmpOneTimePassword: Record "M2 One Time Password" temporary;var TmpContact: Record Contact temporary;AllowBlankPassword: Boolean)
    var
        Contact: Record Contact;
        OneTimePassword: Record "M2 One Time Password";
        OTPAuthentication: Boolean;
    begin

        //-MAG2.21.01 [353964]
        if (TmpContact.IsTemporary ()) then
          TmpContact.DeleteAll ();

        TmpOneTimePassword.Reset ();
        if (not TmpOneTimePassword.FindFirst ()) then
          Error ('No account to validate.');

        if (TmpOneTimePassword."E-Mail" = '') then
          Error ('E-Mail must not be blank.');

        //-NPR5.49 [320425]
        // IF (TmpOneTimePassword."Password (Md5)" = '') THEN
        //  ERROR ('Password must not be blank.');
        if (TmpOneTimePassword."Password (Hash)" = '') and (not AllowBlankPassword) then
          Error ('Password must not be blank.');
        //+NPR5.49 [320425]

        OneTimePassword.SetFilter ("E-Mail", '=%1', LowerCase (TmpOneTimePassword."E-Mail"));
        OneTimePassword.SetFilter ("Password (Hash)", '=%1', TmpOneTimePassword."Password (Hash)");
        OTPAuthentication := OneTimePassword.FindFirst ();

        if (OTPAuthentication) then begin
          if (TmpOneTimePassword."Password (Hash)" = '') then
            Error ('Password must not be blank.'); // OTP must never be blank

          if (OneTimePassword."Used At" <> 0DT) then
            Error ('The security token %1 has already been used.', TmpOneTimePassword."Password (Hash)");

          if (OneTimePassword."Valid Until" < CurrentDateTime) then
            Error ('The security token %1 has expired.', TmpOneTimePassword."Password (Hash)");

          OneTimePassword."Used At" := CurrentDateTime;
          OneTimePassword.Modify ();
        end;

        Contact.SetFilter ("E-Mail", '=%1', LowerCase (TmpOneTimePassword."E-Mail"));
        Contact.SetFilter ("Magento Contact", '=%1', true);

        if (not OTPAuthentication) then
          Contact.SetFilter ("Magento Password (Md5)", '=%1', TmpOneTimePassword."Password (Hash)");

        //-NPR5.49 [320425]
        if (not OTPAuthentication) and (AllowBlankPassword) and (TmpOneTimePassword."Password (Hash)" = '') then
          Contact.SetFilter ("Magento Password (Md5)", '');
        //+NPR5.49 [320425]

        if (Contact.IsEmpty ()) then begin
          Contact.Reset ();
          Contact.SetFilter ("E-Mail", '=%1', LowerCase (TmpOneTimePassword."E-Mail"));
          Contact.SetFilter ("Magento Contact", '=%1', true);
          Contact.SetFilter ("Magento Password (Md5)", '<>%1', '');
          if (not Contact.IsEmpty ()) then
            Error ('E-Mail and password does not identify a valid magento contact.');
          Error ('Contact not found.');
        end;

        Contact.Reset ();
        Contact.SetFilter ("E-Mail", '=%1', LowerCase (TmpOneTimePassword."E-Mail"));
        Contact.SetFilter ("Magento Contact", '=%1', true);
        if (Contact.FindSet ()) then begin
          repeat
            TmpContact.TransferFields (Contact, true);
            TmpContact.Insert ();
          until (Contact.Next () = 0);
        end;
        //+MAG2.21.01 [353964]
    end;

    local procedure ChangePasswordWorker(var TmpOneTimePassword: Record "M2 One Time Password" temporary;var TmpContact: Record Contact temporary)
    var
        Contact: Record Contact;
    begin

        TmpContact.Reset ();
        if (TmpContact.IsEmpty ()) then
          Error ('E-Mail and password does not identify a magento contact.');

        if (TmpOneTimePassword."Password2 (Hash)" = '') then
          Error ('New password must not be blank.');

        TmpOneTimePassword.FindFirst ();
        TmpContact.FindSet ();
        repeat
          Contact.Get (TmpContact."No.");
          Contact."Magento Password (Md5)" := TmpOneTimePassword."Password2 (Hash)";
          Contact.Modify ();
        until (TmpContact.Next () = 0);
    end;

    procedure ResetMagentoPassword(Contact: Record Contact;var ReasonText: Text): Boolean
    begin

        //-MAG2.21.01 [320424]
        Contact.TestField ("E-Mail");

        if (TryResetPassword (Contact."E-Mail")) then begin
          ReasonText := '';
          AddLogEntry (LogEntry.Type::RESET_PASSWORD_REQUEST, LogEntry.Status::OK, Contact."E-Mail", ReasonText);
          Message (RESET_EMAIL_SENT, Contact."E-Mail");

        end else begin
          ReasonText := GetLastErrorText ();
          AddLogEntry (LogEntry.Type::RESET_PASSWORD_REQUEST, LogEntry.Status::FAIL, Contact."E-Mail", ReasonText);

        end;

        exit (ReasonText = '');
        //+MAG2.21.01 [320424]
    end;

    local procedure CreateAccountWorker(var TmpContact: Record Contact temporary;var TmpCustomer: Record Customer temporary;var TmpAccount: Record Contact temporary)
    var
        Contact: Record Contact;
        Customer: Record Customer;
        MarketingSetup: Record "Marketing Setup";
        ContactBusinessRelation: Record "Contact Business Relation";
        TmpOneTimePassword: Record "M2 One Time Password" temporary;
        ConfigTemplateHeader: Record "Config. Template Header";
        MagentoSetup: Record "Magento Setup";
        CustContUpdate: Codeunit "CustCont-Update";
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        RecRef: RecordRef;
        ReasonText: Text;
    begin

        if (not MarketingSetup.Get ()) then
          Error ('Marketing Setup not found.');

        if (MarketingSetup."Bus. Rel. Code for Customers" = '') then
          Error ('Business Relation Code for Customers in Marketing Setup must not be blank.');

        if (TmpContact."E-Mail" = '') then
          Error ('E-Mail can not be empty.');

        //-NPR5.49 [320425]
        // IF (TmpContact."Magento Password (Md5)" = '') THEN
        //  ERROR ('Password must not be blank.');

        // TmpOneTimePassword."Password (Md5)" := TmpContact."Magento Password (Md5)";
        // TmpOneTimePassword."E-Mail" := TmpContact."E-Mail";
        // TmpOneTimePassword.INSERT();

        // Contact.SETFILTER ("E-Mail", '=%1', LOWERCASE (TmpContact."E-Mail"));
        // IF (NOT Contact.ISEMPTY ()) THEN BEGIN
        //  IF (NOT AuthenticatePassword (TmpOneTimePassword, TmpAccount, ReasonText)) THEN
        //    // ERROR ('Invalid account, password combination.');
        //    ERROR (ReasonText);
        //
        //  IF (TmpAccount.ISTEMPORARY ()) THEN
        //    TmpAccount.DELETEALL ();
        // END;
        //+NPR5.49 [320425]


        TmpContact.FindFirst ();
        TmpCustomer.FindFirst ();

        Customer."No." := '';
        Customer.Insert (true);

        if (MagentoSetup.Get ()) then begin
          if (MagentoSetup."Customer Config. Template Code" <> '') then begin
            ConfigTemplateHeader.Get (MagentoSetup."Customer Config. Template Code");
            RecRef.GetTable(Customer);
            ConfigTemplateMgt.UpdateRecord (ConfigTemplateHeader, RecRef);
            RecRef.SetTable(Customer);
          end;
        end;

        Customer.Validate (Name, TmpContact."Company Name");
        Customer.Validate ("Name 2", TmpContact."Name 2");

        Customer.Validate (Address , TmpContact.Address);
        Customer.Validate ("Address 2", TmpContact."Address 2");

        if (TmpContact."Post Code" <> '') then
          Customer.Validate ("Post Code", TmpContact."Post Code");
        if (TmpContact.City <> '') then
          Customer.Validate (City, TmpContact.City);
        if (TmpContact."Country/Region Code" <> '') then
          Customer.Validate ("Country/Region Code", TmpContact."Country/Region Code");

        if (TmpContact."Currency Code" <> '') then
          Customer.Validate ("Currency Code", TmpContact."Currency Code");

        if (TmpContact."VAT Registration No." <> '') then
          Customer.Validate ("VAT Registration No.", TmpContact."VAT Registration No.");

        if (TmpContact."E-Mail" <> '') then
          Customer.Validate ("E-Mail", LowerCase (TmpContact."E-Mail"));

        if (TmpContact."Phone No." <> '') then
          Customer.Validate ("Phone No.", TmpContact."Phone No.");


        if (TmpContact.Surname = '') and (TmpContact."First Name" <> '') then
          Customer.Validate (Contact, TmpContact."First Name");

        if (TmpContact.Surname <> '') and (TmpContact."First Name" = '') then
          Customer.Validate (Contact, TmpContact.Surname);

        if (TmpContact.Surname <> '') and (TmpContact."First Name" <> '') then
          Customer.Validate (Contact, StrSubstNo ('%1 %2', TmpContact."First Name", TmpContact.Surname));

        Customer."Magento Display Group" := TmpCustomer."Magento Display Group";
        Customer."Magento Payment Group" := TmpCustomer."Magento Payment Group";
        Customer."Magento Shipping Group" := TmpCustomer."Magento Shipping Group";
        Customer."Magento Store Code" := TmpCustomer."Magento Store Code";
        Customer.Modify (true);

        // Contact Type Company
        ContactBusinessRelation.SetFilter ("No.", '=%1', Customer."No.");
        ContactBusinessRelation.SetFilter ("Link to Table", '=%1', ContactBusinessRelation."Link to Table"::Customer);
        if (ContactBusinessRelation.FindFirst ()) then begin

          // TODO Apply contact template

          CustContUpdate.OnModify (Customer);

          Contact.Get (ContactBusinessRelation."Contact No.");

          Contact."Magento Customer Group" := TmpContact."Magento Customer Group";
          Contact."Magento Contact" := (Contact."E-Mail" <> '');
          Contact."Magento Password (Md5)" := TmpContact."Magento Password (Md5)";

          Contact.Modify ();

          // Company Result
          TmpAccount.TransferFields (Contact, true);
          TmpAccount.Insert ();

          // Contact Type Person
          Contact.Reset();
          Contact.SetFilter (Contact.Type, '=%1', Contact.Type::Person);
          Contact.SetFilter ("Company No.", '=%1', ContactBusinessRelation."Contact No.");
          if (Contact.FindFirst ()) then begin
            Contact."Magento Customer Group" := TmpContact."Magento Customer Group";
            Contact."Magento Contact" := (Contact."E-Mail" <> '');
            Contact."Magento Password (Md5)" := TmpContact."Magento Password (Md5)";
            Contact.Modify ();

            // Person Result
            TmpAccount.TransferFields (Contact, true);
            TmpAccount.Insert ();
          end;

        end;
    end;

    local procedure UpdateAccountWorker(var TmpAccount: Record Contact temporary;var TmpCustomer: Record Customer temporary;var TmpAccountResponse: Record Contact temporary)
    var
        Account: Record Contact;
        Contact: Record Contact;
        ContactXrec: Record Contact;
        Customer: Record Customer;
        MarketingSetup: Record "Marketing Setup";
        ContactBusinessRelation: Record "Contact Business Relation";
        CustContUpdate: Codeunit "CustCont-Update";
        UpdateCustomerData: Boolean;
    begin

        TmpAccount.FindFirst ();
        UpdateCustomerData := TmpCustomer.FindFirst ();

        Account.Get (TmpAccount."No.");
        if (not Account."Magento Contact") then
          Error ('Not a valid Magento contact.');

        if (Account.Type = Account.Type::Company) then begin
          ContactXrec.Get (Account."No.");
          Contact.TransferFields (Account, true);

          MarketingSetup.Get ();
          ContactBusinessRelation.Get (Contact."No.", MarketingSetup."Bus. Rel. Code for Customers");

          Customer.Get (ContactBusinessRelation."No.");
          if (UpdateCustomerData) then begin
            Customer."Magento Display Group" := TmpCustomer."Magento Display Group";
            Customer."Magento Payment Group" := TmpCustomer."Magento Payment Group";
            Customer."Magento Shipping Group" := TmpCustomer."Magento Shipping Group";
            Customer."Magento Store Code" := TmpCustomer."Magento Store Code";
            Customer.Modify ();
          end;

          Account.Validate (Name, TmpAccount."Company Name");
          Account.Validate ("VAT Registration No.", TmpAccount."VAT Registration No.");
          Account.Validate ("Currency Code", TmpAccount."Currency Code");
        end;

        if (Account.Type = Account.Type::Person) then begin
          Account.Validate ("First Name", TmpAccount."First Name");
          Account.Validate (Surname, TmpAccount.Surname);
        end;

        Account.Validate ("Name 2", TmpAccount."Name 2");
        Account.Validate (Address, TmpAccount.Address);
        Account.Validate ("Address 2", TmpAccount."Address 2");
        Account.Validate ("Post Code", TmpAccount."Post Code");
        Account.Validate (City, TmpAccount.City);
        Account.Validate ("Country/Region Code", TmpAccount."Country/Region Code");

        if ( TmpAccount."E-Mail" <> '') then begin
          if (TmpAccount."E-Mail" <> Account."E-Mail") then begin
            Contact.Reset ();
            Contact.SetFilter ("E-Mail", '=%1', LowerCase (TmpAccount."E-Mail"));
            if (not Contact.IsEmpty ()) then
              Error ('Merging this account with an existing account is not possible.');
          end;

          Account.Validate ("E-Mail", LowerCase (TmpAccount."E-Mail"));
        end;

        Account.Validate ("Phone No.", TmpAccount."Phone No.");
        Account.Modify ();
        Account.OnModify (ContactXrec);

        TmpAccountResponse.TransferFields (Account, true);
        TmpAccountResponse.Insert ();
    end;

    local procedure GetAccountWorker(ContactNo: Code[20];var TmpContact: Record Contact temporary;var TmpSellToCustomer: Record Customer temporary;var TmpBillToCustomer: Record Customer temporary;var TmpShipToAddress: Record "Ship-to Address" temporary): Boolean
    var
        Contact: Record Contact;
        SellToCustomer: Record Customer;
        BillToCustomer: Record Customer;
        ShipToAddress: Record "Ship-to Address";
        MarketingSetup: Record "Marketing Setup";
        ContactBusinessRelation: Record "Contact Business Relation";
        MagentoContactShiptoAdrs: Record "Magento Contact Ship-to Adrs.";
    begin

        Contact.Get (ContactNo);
        if (not Contact."Magento Contact") then
          Error ('Not a valid Magento contact.');

        TmpContact.TransferFields (Contact, true);
        TmpContact.Insert ();

        if (not MarketingSetup.Get ()) then
          exit;

        if (MarketingSetup."Bus. Rel. Code for Customers" = '') then
          exit;

        if (Contact."Company No." = '') then
          exit;

        ContactBusinessRelation.SetFilter ("Contact No.", '=%1', Contact."Company No.");
        ContactBusinessRelation.SetFilter ("Business Relation Code", '=%1', MarketingSetup."Bus. Rel. Code for Customers");
        if (not ContactBusinessRelation.FindFirst ()) then
          exit;

        if (not SellToCustomer.Get (ContactBusinessRelation."No.")) then
          exit;
        TmpSellToCustomer.TransferFields (SellToCustomer, true);
        TmpSellToCustomer.Insert ();

        BillToCustomer.Get (TmpSellToCustomer.GetBillToCustomerNo());
        TmpBillToCustomer.TransferFields (BillToCustomer, true);
        TmpBillToCustomer.Insert ();

        ShipToAddress.SetFilter ("Customer No.", '=%1', TmpSellToCustomer."No.");
        if (ShipToAddress.FindSet ()) then begin
          repeat
            TmpShipToAddress.TransferFields (ShipToAddress, true);

            MagentoContactShiptoAdrs.SetFilter ("Customer No.", '=%1', ShipToAddress."Customer No.");
            MagentoContactShiptoAdrs.SetFilter ("Ship-to Code", '=%1', ShipToAddress.Code);
            if (MagentoContactShiptoAdrs.FindFirst ()) then begin

              if (MagentoContactShiptoAdrs.Visibility = MagentoContactShiptoAdrs.Visibility::PUBLIC) then
                  TmpShipToAddress.Insert ();

              if ((MagentoContactShiptoAdrs."Created By Contact No." = ContactNo) and (MagentoContactShiptoAdrs.Visibility = MagentoContactShiptoAdrs.Visibility::PRIVATE)) then
                TmpShipToAddress.Insert ();

            end else begin
              // No visibility rules defined for this address
              TmpShipToAddress.Insert ();
            end;

          until (ShipToAddress.Next () = 0);
        end;

        exit (true);
    end;

    local procedure AddAccountWorker(var TmpAccount: Record Contact temporary;var TmpAccountResponse: Record Contact temporary)
    var
        TmpOneTimePassword: Record "M2 One Time Password" temporary;
        tmpCorporateAccount: Record Contact temporary;
        Contact: Record Contact;
        ReasonText: Text;
    begin

        if (TmpAccount."E-Mail" = '') then
          Error ('E-Mail can not be empty.');

        if (TmpAccount."Magento Password (Md5)" = '') then
          Error ('Password must not be blank.');

        TmpOneTimePassword."Password (Hash)" := TmpAccount."Magento Password (Md5)";
        TmpOneTimePassword."E-Mail" := LowerCase (TmpAccount."E-Mail");
        TmpOneTimePassword.Insert();

        if (not AuthenticatePassword (TmpOneTimePassword, tmpCorporateAccount, ReasonText)) then
          Error ('Invalid account, password combination.');

        tmpCorporateAccount.SetFilter ("Company No.", '=%1', TmpAccount."Company No.");
        if (not tmpCorporateAccount.FindFirst ()) then
          Error ('Invalid corporate id %1 for account, password combination.', TmpAccount."Company No.");

        Contact."No." := '';
        Contact.Type := Contact.Type::Person;
        Contact."Company No." := tmpCorporateAccount."No.";
        Contact.Insert (true);

        //-NPR5.49 [346698]
        //Contact.InheritCompanyToPersonData (tmpCorporateAccount, TRUE);
        Contact.InheritCompanyToPersonData (tmpCorporateAccount);
        //+NPR5.49 [346698]

        Contact.Validate (Name, TmpAccount."Company Name");
        Contact.Validate ("Name 2", TmpAccount."Name 2");

        Contact.Validate (Address , TmpAccount.Address);
        Contact.Validate ("Address 2", TmpAccount."Address 2");

        if (TmpAccount."Post Code" <> '') then
          Contact.Validate ("Post Code", TmpAccount."Post Code");
        if (TmpAccount.City <> '') then
          Contact.Validate (City, TmpAccount.City);
        if (TmpAccount."Country/Region Code" <> '') then
          Contact.Validate ("Country/Region Code", TmpAccount."Country/Region Code");

        if (TmpAccount."Currency Code" <> '') then
          Contact.Validate ("Currency Code", TmpAccount."Currency Code");

        if (TmpAccount."VAT Registration No." <> '') then
          Contact.Validate ("VAT Registration No.", TmpAccount."VAT Registration No.");

        if (TmpAccount."E-Mail 2" <> '') then
          Contact.Validate ("E-Mail", LowerCase (TmpAccount."E-Mail 2"));

        if (TmpAccount."Phone No." <> '') then
          Contact.Validate ("Phone No.", TmpAccount."Phone No.");

        if (TmpAccount."First Name" <> '') then
          Contact.Validate ("First Name", TmpAccount."First Name");

        if (TmpAccount.Surname <> '') then
          Contact.Validate (Surname, TmpAccount.Surname);

        Contact."Magento Contact" := true;
        Contact.Modify ();

        TmpAccountResponse.TransferFields (Contact, true);
        TmpAccountResponse.Insert ();
    end;

    local procedure DeleteAccountWorker(var TmpContact: Record Contact)
    var
        Account: Record Contact;
        Contact: Record Contact;
        ContactXrec: Record Contact;
        Customer: Record Customer;
        MarketingSetup: Record "Marketing Setup";
        ContactBusinessRelation: Record "Contact Business Relation";
        CustContUpdate: Codeunit "CustCont-Update";
    begin

        TmpContact.FindFirst ();
        Account.Get (TmpContact."No.");

        if (Account.Type = Account.Type::Company) then begin
          Account.SetFilter ("Company No.",' =%1', TmpContact."No.");
          Account.ModifyAll ("Magento Contact", false);
        end else begin
          Account."Magento Contact" := false;
          Account.Modify ();
        end;
    end;

    local procedure CreateShiptoAddressWorker(var TmpAccount: Record Contact temporary;var TmpShiptoAddressRequest: Record "Ship-to Address" temporary;var TmpShiptoAddressResponse: Record "Ship-to Address" temporary)
    var
        AccountSetup: Record "M2 Account Setup";
        Account: Record Contact;
        Contact: Record Contact;
        ShiptoAddress: Record "Ship-to Address";
        MarketingSetup: Record "Marketing Setup";
        ContactBusinessRelation: Record "Contact Business Relation";
        MagentoContactShiptoAdrs: Record "Magento Contact Ship-to Adrs.";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin

        if (not AccountSetup.Get ()) then begin
          AccountSetup.Init ();
          AccountSetup.Insert ();
        end;

        if (AccountSetup."No. Series Ship-to Address" = '') then begin
          AccountSetup."No. Series Ship-to Address" := CreateNoSerie ('NPR-SHIPTO', 'CA00000000', 'Auto assigned ship-to codes.');
          AccountSetup.Modify ();
        end;


        if (not MarketingSetup.Get ()) then
          Error ('Marketing Setup not found.');

        if (MarketingSetup."Bus. Rel. Code for Customers" = '') then
          Error ('Business Relation Code for Customers in Marketing Setup must not be blank.');

        TmpAccount.FindFirst ();
        Account.Get (TmpAccount."No.");

        if (Account.Type = Account.Type::Person) then
          Contact.Get (Account."Company No.");

        if (Account.Type = Account.Type::Company) then
          Contact.TransferFields (Account, true);

        ContactBusinessRelation.Get (Contact."No.", MarketingSetup."Bus. Rel. Code for Customers");

        TmpShiptoAddressRequest.FindSet ();
        repeat
          ShiptoAddress."Customer No." := ContactBusinessRelation."No.";
          ShiptoAddress.Code := NoSeriesManagement.GetNextNo (AccountSetup."No. Series Ship-to Address", Today, true);
          ShiptoAddress.Insert (true);

          ShiptoAddress.TransferFields (TmpShiptoAddressRequest, false);
          ShiptoAddress.Modify (true);

          MagentoContactShiptoAdrs."Customer No." := ShiptoAddress."Customer No.";
          MagentoContactShiptoAdrs."Ship-to Code" := ShiptoAddress.Code;
          MagentoContactShiptoAdrs."Created By Contact No." := Account."No.";
          MagentoContactShiptoAdrs."Created At" := CurrentDateTime ();
          case Account.Type of
            Account.Type::Person : MagentoContactShiptoAdrs.Visibility := MagentoContactShiptoAdrs.Visibility::PRIVATE;
            Account.Type::Company : MagentoContactShiptoAdrs.Visibility := MagentoContactShiptoAdrs.Visibility::PUBLIC;
          end;
          MagentoContactShiptoAdrs.Insert ();

          TmpShiptoAddressResponse.TransferFields (ShiptoAddress, true);
          TmpShiptoAddressResponse.Insert ();

        until (TmpShiptoAddressRequest.Next () = 0);
    end;

    local procedure UpdateShiptoAddressWorker(var TmpAccount: Record Contact temporary;var TmpShiptoAddressRequest: Record "Ship-to Address" temporary;var TmpShiptoAddressResponse: Record "Ship-to Address" temporary)
    var
        AccountSetup: Record "M2 Account Setup";
        Account: Record Contact;
        Contact: Record Contact;
        ShiptoAddress: Record "Ship-to Address";
        MarketingSetup: Record "Marketing Setup";
        ContactBusinessRelation: Record "Contact Business Relation";
        MagentoContactShiptoAdrs: Record "Magento Contact Ship-to Adrs.";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        AllowAction: Boolean;
    begin

        TmpAccount.FindFirst ();
        Account.Get (TmpAccount."No.");

        if (Account.Type = Account.Type::Person) then
          Contact.Get (Account."Company No.");

        if (Account.Type = Account.Type::Company) then
          Contact.TransferFields (Account, true);

        MarketingSetup.Get ();
        ContactBusinessRelation.Get (Contact."No.", MarketingSetup."Bus. Rel. Code for Customers");

        TmpShiptoAddressRequest.FindSet ();
        repeat

          AllowAction := false;

          MagentoContactShiptoAdrs.SetFilter ("Customer No.", '=%1', ContactBusinessRelation."No.");
          MagentoContactShiptoAdrs.SetFilter ("Ship-to Code", '=%1', TmpShiptoAddressRequest.Code);
          if (MagentoContactShiptoAdrs.FindFirst ()) then begin

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
            Error ('You are not allowed to update the ship-to address %1.', TmpShiptoAddressRequest.Code);

          ShiptoAddress.Get (ContactBusinessRelation."No.", TmpShiptoAddressRequest.Code);
          ShiptoAddress.TransferFields (TmpShiptoAddressRequest, false);
          ShiptoAddress.Modify (true);

          TmpShiptoAddressResponse.TransferFields (ShiptoAddress, true);
          TmpShiptoAddressResponse.Insert ();

        until (TmpShiptoAddressRequest.Next () = 0);
    end;

    local procedure DeleteShiptoAddressWorker(var TmpAccount: Record Contact temporary;var TmpShiptoAddressRequest: Record "Ship-to Address" temporary)
    var
        AccountSetup: Record "M2 Account Setup";
        Account: Record Contact;
        Contact: Record Contact;
        ShiptoAddress: Record "Ship-to Address";
        MarketingSetup: Record "Marketing Setup";
        ContactBusinessRelation: Record "Contact Business Relation";
        MagentoContactShiptoAdrs: Record "Magento Contact Ship-to Adrs.";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        AllowAction: Boolean;
    begin

        TmpAccount.FindFirst ();
        Account.Get (TmpAccount."No.");

        if (Account.Type = Account.Type::Person) then
          Contact.Get (Account."Company No.");

        if (Account.Type = Account.Type::Company) then
          Contact.TransferFields (Account, true);

        MarketingSetup.Get ();
        ContactBusinessRelation.Get (Contact."No.", MarketingSetup."Bus. Rel. Code for Customers");

        TmpShiptoAddressRequest.FindSet ();
        repeat

          AllowAction := false;
          MagentoContactShiptoAdrs.SetFilter ("Customer No.", '=%1', ContactBusinessRelation."No.");
          MagentoContactShiptoAdrs.SetFilter ("Ship-to Code", '=%1', TmpShiptoAddressRequest.Code);
          if (MagentoContactShiptoAdrs.FindFirst ()) then begin

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
            Error ('You are not allowed to delet the ship-to address %1.', TmpShiptoAddressRequest.Code);

          ShiptoAddress.Get (ContactBusinessRelation."No.", TmpShiptoAddressRequest.Code);
          ShiptoAddress.Delete (true);

        until (TmpShiptoAddressRequest.Next () = 0);
    end;

    local procedure "---"()
    begin
    end;

    procedure CreateSecurityToken(EMail: Text[80]) Token: Text[40]
    var
        OneTimePassword: Record "M2 One Time Password";
        AccountSetup: Record "M2 Account Setup";
    begin
        if (not AccountSetup.Get ()) then ;

        if (AccountSetup."OTP Validity (Hours)" = 0) then
          AccountSetup."OTP Validity (Hours)" := 24;

        OneTimePassword."Password (Hash)" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));
        OneTimePassword."E-Mail" := LowerCase (EMail);
        OneTimePassword."Created At" := CurrentDateTime;
        OneTimePassword."Valid Until" := CurrentDateTime + AccountSetup."OTP Validity (Hours)" * 3600 * 1000;

        OneTimePassword.Insert ();

        AddLogEntry (LogEntry.Type::OTP_CREATE, LogEntry.Status::OK, EMail, '');

        exit (OneTimePassword."Password (Hash)");
    end;

    procedure CreateResetPasswordCommunicationTemplate(Contact: Record Contact;Token: Text[40]) EntryNo: Integer
    var
        AccountComTemplate: Record "M2 Account Com. Template";
        AccountSetup: Record "M2 Account Setup";
        AuthenticationLog: Record "Authentication Log";
    begin

        if (not AccountSetup.Get ()) then ;

        if (AccountSetup."Reset Password URL" = '') then
          AccountSetup."Reset Password URL" := 'http://test.shop.navipartner.dk/changepassword?token=%1&b64email=%2';

        AccountComTemplate.Type := AccountComTemplate.Type::PW_RESET;
        AccountComTemplate."Company Name" := Contact.Name;
        AccountComTemplate."First Name" := Contact."First Name";
        AccountComTemplate."Last Name" := Contact.Surname;
        AccountComTemplate."E-Mail" := LowerCase (Contact."E-Mail");
        AccountComTemplate."Security Token" := Token;
        AccountComTemplate."B64 Email" := ToBase64 (LowerCase (Contact."E-Mail"));
        AccountComTemplate.URL1 := StrSubstNo (AccountSetup."Reset Password URL", Token, AccountComTemplate."B64 Email");

        AccountComTemplate.Insert ();

        exit (AccountComTemplate."Entry No.");
    end;

    local procedure SendMail(AccountComTemplate: Record "M2 Account Com. Template";var ResponseMessage: Text): Boolean
    var
        RecordRef: RecordRef;
        EMailMgt: Codeunit "E-mail Management";
    begin

        RecordRef.GetTable(AccountComTemplate);

        ResponseMessage := 'E-Mail address is missing.';
        if (AccountComTemplate."E-Mail" <> '') then
          ResponseMessage := EMailMgt.SendEmail(RecordRef, AccountComTemplate."E-Mail", true);

        exit (ResponseMessage = '');
    end;

    local procedure ToBase64(StringToEncode: Text) B64String: Text
    var
        TempBlob: Record TempBlob temporary;
        BinaryReader: DotNet npNetBinaryReader;
        MemoryStream: DotNet npNetMemoryStream;
        Convert: DotNet npNetConvert;
        InStr: InStream;
        Outstr: OutStream;
    begin

        Clear(TempBlob);
        TempBlob.Blob.CreateOutStream(Outstr);
        Outstr.WriteText(StringToEncode);

        TempBlob.Blob.CreateInStream(InStr);
        MemoryStream := InStr;
        BinaryReader := BinaryReader.BinaryReader(InStr);

        B64String := Convert.ToBase64String(BinaryReader.ReadBytes(MemoryStream.Length));

        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);
    end;

    local procedure AddLogEntry(Type: Option;Status: Option;EMail: Text[80];ReasonText: Text)
    var
        AuthenticationLog: Record "Authentication Log";
    begin

        AuthenticationLog.Init;

        AuthenticationLog.Type := Type;
        AuthenticationLog."Created At" := CurrentDateTime;
        AuthenticationLog."Account Id" := EMail;
        AuthenticationLog.Status := Status;
        AuthenticationLog."Result Message" := CopyStr (ReasonText, 1, MaxStrLen (AuthenticationLog."Result Message"));
        AuthenticationLog.UserId := CopyStr (UserId, 1, MaxStrLen (AuthenticationLog."Result Message"));
        AuthenticationLog.Insert ();
    end;

    local procedure CreateNoSerie(NoSerieCode: Code[10];StartNumber: Code[20];Description: Text[30]): Code[10]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin

        if (not NoSeries.Get (NoSerieCode)) then begin
          NoSeries.Code := NoSerieCode;
          NoSeries.Insert ();
        end;

        NoSeries.Description := Description;
        NoSeries."Default Nos." := true;
        NoSeries.Modify ();

        if (not NoSeriesLine.Get (NoSerieCode, 10000)) then begin
          NoSeriesLine."Series Code" := NoSerieCode;
          NoSeriesLine."Line No." := 10000;
          NoSeriesLine."Starting Date" := CalcDate ('<CY-1Y+1D>', Today);
          NoSeriesLine."Starting No." := StartNumber;
          NoSeriesLine."Increment-by No." := 1;
          NoSeriesLine.Insert ();
        end;

        exit (NoSerieCode);
    end;

    local procedure "--"()
    begin
    end;

    procedure MagentoApiPost(Method: Text;var Body: DotNet JToken;var Result: DotNet JToken)
    var
        MagentoSetup: Record "Magento Setup";
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        StreamReader: DotNet npNetStreamReader;
        Response: Text;
        ReqStream: DotNet npNetStream;
        ReqStreamWriter: DotNet npNetStreamWriter;
    begin
        Clear(Response);
        if Method = '' then
          exit;

        MagentoSetup.Get;
        MagentoSetup.TestField("Api Url");
        if MagentoSetup."Api Url"[StrLen(MagentoSetup."Api Url")] <> '/' then
          MagentoSetup."Api Url" += '/';

        if (CopyStr (MagentoSetup."Api Url", StrLen (MagentoSetup."Api Url" ) - (StrLen ('naviconnect/')) + 1) = 'naviconnect/') then
          MagentoSetup."Api Url" := CopyStr (MagentoSetup."Api Url", 1, StrLen (MagentoSetup."Api Url" ) - (StrLen ('naviconnect/'))) + 'b2b_customer/';

        HttpWebRequest := HttpWebRequest.Create(MagentoSetup."Api Url"+ Method);
        HttpWebRequest.Timeout := 1000 * 60;

        HttpWebRequest.Method := 'POST';
        MagentoSetup.Get;
        if MagentoSetup."Api Authorization" <> '' then
          HttpWebRequest.Headers.Add('Authorization',MagentoSetup."Api Authorization")
        else
          HttpWebRequest.Headers.Add('Authorization','Basic ' + MagentoSetup.GetBasicAuthInfo());

        HttpWebRequest.ContentType ('naviconnect/json');

        ReqStream := HttpWebRequest.GetRequestStream;
        ReqStreamWriter := ReqStreamWriter.StreamWriter(ReqStream);
        ReqStreamWriter.Write (Body.ToString());
        ReqStreamWriter.Flush;
        ReqStreamWriter.Close;
        Clear (ReqStreamWriter);
        Clear (ReqStream);

        HttpWebResponse := HttpWebRequest.GetResponse();

        StreamReader := StreamReader.StreamReader(HttpWebResponse.GetResponseStream);
        Response := StreamReader.ReadToEnd;
        Result := Result.Parse(Response);
    end;
}

