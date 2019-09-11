codeunit 6151150 "M2 Account WebService"
{
    // MAG2.20/TSA /20181210 CASE 320424 Initial Version
    // MAG2.20/JAVA/20190205  CASE 320425 Transport NPR5.48 - 5 February 2019
    // MAG2.21/TSA /20190306 CASE 320425 Changed response message when contact was not found
    // MAG2.21/JAKUBV/20190402  CASE 320424-01 Transport NPR5.49 - 1 April 2019
    // MAG2.21.01/TSA /20190426 CASE 350001 Added GetExtendedAccountDetails
    // MAG2.21.01/TSA /20190506 CASE 353964 Refactored to not use try functions
    // NPR5.51/TSA /20190724 CASE 362020 Adding actions for contact / mail group management


    trigger OnRun()
    begin
    end;

    [Scope('Personalization')]
    procedure AuthenticateAccountPassword(var M2Authenticate: XMLport "M2 Authenticate")
    var
        TmpOneTimePassword: Record "M2 One Time Password" temporary;
        TmpContact: Record Contact temporary;
    begin

        SelectLatestVersion ();

        M2Authenticate.Import;
        M2Authenticate.GetRequest (TmpOneTimePassword);

        if (DoAuthenticatePassword (TmpOneTimePassword, TmpContact)) then begin
          M2Authenticate.SetResponse (TmpContact);

        end else begin
          M2Authenticate.SetErrorResponse (GetLastErrorText);

        end;
    end;

    [Scope('Personalization')]
    procedure RequestPasswordReset(var M2ResetAccountPassword: XMLport "M2 Reset Account Password")
    var
        TmpOneTimePassword: Record "M2 One Time Password" temporary;
    begin

        SelectLatestVersion;

        M2ResetAccountPassword.Import;
        M2ResetAccountPassword.GetRequest (TmpOneTimePassword);
        if (DoResetPassword (TmpOneTimePassword)) then begin
          M2ResetAccountPassword.SetResponse ();
        end else begin
          M2ResetAccountPassword.SetErrorResponse (GetLastErrorText);
        end;
    end;

    [Scope('Personalization')]
    procedure ChangeAccountPassword(var M2ChangeAccountPassword: XMLport "M2 Change Account Password")
    var
        TmpOneTimePassword: Record "M2 One Time Password" temporary;
        TmpContact: Record Contact temporary;
    begin

        SelectLatestVersion ();

        M2ChangeAccountPassword.Import;
        M2ChangeAccountPassword.GetRequest (TmpOneTimePassword);

        if (DoChangePassword (TmpOneTimePassword, TmpContact)) then begin
          M2ChangeAccountPassword.SetResponse (TmpContact);

        end else begin
          M2ChangeAccountPassword.SetErrorResponse (GetLastErrorText);

        end;
    end;

    [Scope('Personalization')]
    procedure GetAccountDetails(var M2GetAccount: XMLport "M2 Get Account")
    var
        ContactNo: Code[20];
        TmpContact: Record Contact temporary;
        TmpSellToCustomer: Record Customer temporary;
        TmpBillToCustomer: Record Customer temporary;
        TmpShipToAddress: Record "Ship-to Address" temporary;
    begin

        SelectLatestVersion;

        M2GetAccount.Import;
        ContactNo := M2GetAccount.GetRequest ();

        if (DoGetAccount (ContactNo, TmpContact, TmpSellToCustomer, TmpBillToCustomer, TmpShipToAddress)) then begin
          M2GetAccount.SetResponse (TmpContact, TmpSellToCustomer, TmpBillToCustomer, TmpShipToAddress);

        end else begin
          M2GetAccount.SetErrorResponse (GetLastErrorText ());

        end;
    end;

    [Scope('Personalization')]
    procedure UpdateAccount(var M2UpdateAccount: XMLport "M2 Update Account")
    var
        TmpContact: Record Contact temporary;
        TmpCustomer: Record Customer temporary;
        TmpAccount: Record Contact temporary;
    begin

        SelectLatestVersion;

        M2UpdateAccount.Import;
        M2UpdateAccount.GetRequest (TmpContact, TmpCustomer);

        if (DoUpdateAccount (TmpContact, TmpCustomer, TmpAccount)) then begin
          M2UpdateAccount.SetResponse (TmpAccount);

        end else begin
          M2UpdateAccount.SetErrorResponse (GetLastErrorText ());

        end;
    end;

    [Scope('Personalization')]
    procedure CreateCorporateAccount(var M2CreateCorporateAccount: XMLport "M2 Create Corporate Account")
    var
        TmpContact: Record Contact temporary;
        TmpCustomer: Record Customer temporary;
        TmpAccount: Record Contact temporary;
    begin

        SelectLatestVersion;

        M2CreateCorporateAccount.Import;
        M2CreateCorporateAccount.GetRequest (TmpContact, TmpCustomer);

        if (DoCreateAccount (TmpContact, TmpCustomer, TmpAccount)) then begin
          M2CreateCorporateAccount.SetResponse (TmpAccount);

        end else begin
          M2CreateCorporateAccount.SetErrorResponse (GetLastErrorText ());

        end;
    end;

    [Scope('Personalization')]
    procedure AddPersonAccount(var M2AddAccount: XMLport "M2 Add Account")
    var
        TmpContact: Record Contact temporary;
        TmpCustomer: Record Customer temporary;
        TmpAccount: Record Contact temporary;
    begin

        SelectLatestVersion;

        M2AddAccount.Import;
        M2AddAccount.GetRequest (TmpContact);

        if (DoAddAccount (TmpContact, TmpAccount)) then begin
          M2AddAccount.SetResponse (TmpAccount);

        end else begin
          M2AddAccount.SetErrorResponse (GetLastErrorText ());

        end;
    end;

    [Scope('Personalization')]
    procedure DeleteAccount(var M2DeleteAccount: XMLport "M2 Delete Account")
    var
        ContactNo: Code[20];
        TmpContact: Record Contact temporary;
        TmpSellToCustomer: Record Customer temporary;
        TmpBillToCustomer: Record Customer temporary;
        TmpShipToAddress: Record "Ship-to Address" temporary;
    begin

        SelectLatestVersion;

        M2DeleteAccount.Import;
        ContactNo := M2DeleteAccount.GetRequest ();

        if (DoDeleteAccount (ContactNo)) then begin
          M2DeleteAccount.SetResponse ();

        end else begin
          M2DeleteAccount.SetErrorResponse (GetLastErrorText ());

        end;
    end;

    [Scope('Personalization')]
    procedure AddShiptoAddress(var M2AddShiptoAddress: XMLport "M2 Add Shipto Address")
    var
        TmpAccount: Record Contact temporary;
        TmpShiptoAddressRequest: Record "Ship-to Address" temporary;
        TmpShiptoAddressResponse: Record "Ship-to Address" temporary;
    begin

        SelectLatestVersion;

        M2AddShiptoAddress.Import;
        M2AddShiptoAddress.GetRequest (TmpAccount, TmpShiptoAddressRequest);

        if (DoAddShiptoAddress (TmpAccount, TmpShiptoAddressRequest, TmpShiptoAddressResponse)) then begin
          M2AddShiptoAddress.SetResponse (TmpShiptoAddressResponse);

        end else begin
          M2AddShiptoAddress.SetErrorResponse (GetLastErrorText ());

        end;
    end;

    [Scope('Personalization')]
    procedure UpdateShiptoAddress(var M2UpdateShiptoAddress: XMLport "M2 Update Shipto Address")
    var
        TmpAccount: Record Contact temporary;
        TmpShiptoAddressRequest: Record "Ship-to Address" temporary;
        TmpShiptoAddressResponse: Record "Ship-to Address" temporary;
    begin

        SelectLatestVersion;

        M2UpdateShiptoAddress.Import;
        M2UpdateShiptoAddress.GetRequest (TmpAccount, TmpShiptoAddressRequest);

        if (DoUpdateShiptoAddress (TmpAccount, TmpShiptoAddressRequest, TmpShiptoAddressResponse)) then begin
          M2UpdateShiptoAddress.SetResponse (TmpShiptoAddressResponse);

        end else begin
          M2UpdateShiptoAddress.SetErrorResponse (GetLastErrorText ());

        end;
    end;

    [Scope('Personalization')]
    procedure DeleteShiptoAddress(var M2DeleteShiptoAddress: XMLport "M2 Delete Shipto Address")
    var
        TmpAccount: Record Contact temporary;
        TmpShiptoAddressRequest: Record "Ship-to Address" temporary;
        TmpShiptoAddressResponse: Record "Ship-to Address" temporary;
    begin

        SelectLatestVersion;

        M2DeleteShiptoAddress.Import;
        M2DeleteShiptoAddress.GetRequest (TmpAccount, TmpShiptoAddressRequest);

        if (DoDeleteShiptoAddress (TmpAccount, TmpShiptoAddressRequest)) then begin
          M2DeleteShiptoAddress.SetResponse ();

        end else begin
          M2DeleteShiptoAddress.SetErrorResponse (GetLastErrorText ());

        end;
    end;

    procedure GetExtendedAccountDetails(var GetExtendedAccount: XMLport "M2 Get Extended Account")
    var
        ContactNo: Code[20];
        TmpContact: Record Contact temporary;
        TmpSellToCustomer: Record Customer temporary;
        TmpBillToCustomer: Record Customer temporary;
        TmpShipToAddress: Record "Ship-to Address" temporary;
    begin

        //-NPR5.51 [350001]
        SelectLatestVersion;

        GetExtendedAccount.Import;
        ContactNo := GetExtendedAccount.GetRequest ();

        if (DoGetAccount (ContactNo, TmpContact, TmpSellToCustomer, TmpBillToCustomer, TmpShipToAddress)) then begin
          GetExtendedAccount.SetResponse (TmpContact, TmpSellToCustomer, TmpBillToCustomer);

        end else begin
          GetExtendedAccount.SetErrorResponse (GetLastErrorText ());

        end;
        //+NPR5.51 [350001]
    end;

    procedure ListAllMailGroups(var ListMailingGroups: XMLport "M2 List Mailing Groups")
    begin

        //-NPR5.51 [362020]
        // Implicit export
        //+NPR5.51 [362020]
    end;

    procedure ListMailGroupsForAccount(ContactNo: Code[20];var ListMailingGroups: XMLport "M2 List Mailing Groups")
    begin

        //-NPR5.51 [362020]
        SelectLatestVersion;
        ListMailingGroups.CreateListForContact (ContactNo);
        // Implicit export

        //+NPR5.51 [362020]
    end;

    procedure AddAccountToMailGroup(ContactNo: Code[20];MailGroupCode: Code[10];var ListMailingGroups: XMLport "M2 List Mailing Groups")
    var
        ContactMailingGroup: Record "Contact Mailing Group";
    begin

        //-NPR5.51 [362020]
        SelectLatestVersion;

        if (not ContactMailingGroup.Get (ContactNo, MailGroupCode)) then begin
          ContactMailingGroup.Validate ("Contact No.", ContactNo);
          ContactMailingGroup.Validate ("Mailing Group Code", MailGroupCode);
          ContactMailingGroup.Insert (true);
        end;

        ListMailingGroups.CreateListForContact (ContactNo);
        // Implicit export

        //+NPR5.51 [362020]
    end;

    procedure RemoveAccountFromMailGroup(ContactNo: Code[20];MailGroupCode: Code[10];var ListMailingGroups: XMLport "M2 List Mailing Groups")
    var
        ContactMailingGroup: Record "Contact Mailing Group";
    begin

        //-NPR5.51 [362020]
        SelectLatestVersion;

        if (ContactMailingGroup.Get (ContactNo, MailGroupCode)) then begin
          ContactMailingGroup.Delete (true);
        end;

        ListMailingGroups.CreateListForContact (ContactNo);
        // Implicit export

        //+NPR5.51 [362020]
    end;

    local procedure "--"()
    begin
    end;

    local procedure DoAuthenticatePassword(var TmpOneTimePassword: Record "M2 One Time Password" temporary;var TmpContact: Record Contact temporary): Boolean
    var
        AccountManager: Codeunit "M2 Account Manager";
        ReasonText: Text;
    begin

        exit (AccountManager.AuthenticatePassword (TmpOneTimePassword, TmpContact, ReasonText));
    end;

    [Scope('Personalization')]
    procedure DoChangePassword(var TmpOneTimePassword: Record "M2 One Time Password" temporary;var TmpContact: Record Contact temporary): Boolean
    var
        AccountManager: Codeunit "M2 Account Manager";
        ReasonText: Text;
    begin

        exit (AccountManager.ChangePassword (TmpOneTimePassword, TmpContact, ReasonText));
    end;

    local procedure DoResetPassword(var TmpOneTimePassword: Record "M2 One Time Password" temporary): Boolean
    var
        AccountManager: Codeunit "M2 Account Manager";
        ReasonText: Text;
    begin

        exit (AccountManager.ResetPassword (TmpOneTimePassword, ReasonText));
    end;

    local procedure DoGetAccount(ContactNo: Code[20];var TmpContact: Record Contact temporary;var TmpSellToCustomer: Record Customer temporary;var TmpBillToCustomer: Record Customer temporary;var TmpShipToAddress: Record "Ship-to Address" temporary): Boolean
    var
        AccountManager: Codeunit "M2 Account Manager";
    begin

        exit (AccountManager.GetAccount (ContactNo, TmpContact, TmpSellToCustomer, TmpBillToCustomer, TmpShipToAddress));
    end;

    local procedure DoCreateAccount(var TmpContact: Record Contact temporary;var TmpCustomer: Record Customer temporary;var TmpAccount: Record Contact temporary): Boolean
    var
        AccountManager: Codeunit "M2 Account Manager";
        ReasonText: Text;
    begin

        exit (AccountManager.CreateAccount (TmpContact, TmpCustomer, TmpAccount, ReasonText));
    end;

    local procedure DoAddAccount(var TmpContact: Record Contact temporary;var TmpAccount: Record Contact temporary): Boolean
    var
        AccountManager: Codeunit "M2 Account Manager";
        ReasonText: Text;
    begin

        exit (AccountManager.AddAccount (TmpContact, TmpAccount, ReasonText));
    end;

    local procedure DoUpdateAccount(var TmpContact: Record Contact temporary;var TmpCustomer: Record Customer temporary;var TmpAccount: Record Contact temporary): Boolean
    var
        AccountManager: Codeunit "M2 Account Manager";
        ReasonText: Text;
    begin

        exit (AccountManager.UpdateAccount (TmpContact, TmpCustomer, TmpAccount, ReasonText));
    end;

    local procedure DoDeleteAccount(var ContactNo: Code[20]): Boolean
    var
        AccountManager: Codeunit "M2 Account Manager";
        ReasonText: Text;
    begin

        exit (AccountManager.DeleteAccount (ContactNo, ReasonText));
    end;

    local procedure DoAddShiptoAddress(var TmpAccount: Record Contact temporary;var TmpShiptoAddressRequest: Record "Ship-to Address" temporary;var TmpShiptoAddressResponse: Record "Ship-to Address" temporary): Boolean
    var
        AccountManager: Codeunit "M2 Account Manager";
        ReasonText: Text;
    begin

        exit (AccountManager.CreateShiptoAddress (TmpAccount, TmpShiptoAddressRequest, TmpShiptoAddressResponse, ReasonText));
    end;

    local procedure DoUpdateShiptoAddress(var TmpAccount: Record Contact temporary;var TmpShiptoAddressRequest: Record "Ship-to Address" temporary;var TmpShiptoAddressResponse: Record "Ship-to Address" temporary): Boolean
    var
        AccountManager: Codeunit "M2 Account Manager";
        ReasonText: Text;
    begin

        exit (AccountManager.UpdateShiptoAddress (TmpAccount, TmpShiptoAddressRequest, TmpShiptoAddressResponse, ReasonText));
    end;

    local procedure DoDeleteShiptoAddress(var TmpAccount: Record Contact temporary;var TmpShiptoAddressRequest: Record "Ship-to Address" temporary): Boolean
    var
        AccountManager: Codeunit "M2 Account Manager";
        ReasonText: Text;
    begin

        exit (AccountManager.DeleteShiptoAddress (TmpAccount, TmpShiptoAddressRequest, ReasonText));
    end;

    local procedure "--Testers"()
    begin
    end;

    local procedure TestAuthenticate(EMail: Text[80];PasswordMD5: Text[40])
    var
        M2Authenticate: XMLport "M2 Authenticate";
        TmpOneTimePassword: Record "M2 One Time Password" temporary;
        TmpContact: Record Contact temporary;
        xmltext: Text;
        TmpBLOBbuffer: Record "BLOB buffer" temporary;
        iStream: InStream;
        oStream: OutStream;
    begin

        xmltext :=
          '<?xml version="1.0" encoding="UTF-8" standalone="no"?>'+
          '<Authenticate xmlns="urn:microsoft-dynamics-nav/xmlports/x6151150">'+
            '<Request>'+
              StrSubstNo ('<EMail>%1</EMail>', EMail) +
              StrSubstNo ('<PasswordMd5>%1</PasswordMd5>', PasswordMD5) +
            '</Request>'+
          '</Authenticate>';

        // Request
        TmpBLOBbuffer.Insert ();
        TmpBLOBbuffer."Buffer 1".CreateOutStream (oStream);
        oStream.WriteText (xmltext);
        TmpBLOBbuffer.Modify ();

        TmpBLOBbuffer."Buffer 1".CreateInStream (iStream);
        M2Authenticate.SetSource (iStream);
        M2Authenticate.Import ();

        // Process
        M2Authenticate.GetRequest (TmpOneTimePassword);
        DoAuthenticatePassword (TmpOneTimePassword, TmpContact);
        M2Authenticate.SetResponse (TmpContact);

        // Reponse
        TmpBLOBbuffer."Buffer 1".CreateOutStream (oStream);
        M2Authenticate.SetDestination (oStream);
        M2Authenticate.Export ();
        TmpBLOBbuffer.Modify ();

        TmpBLOBbuffer."Buffer 1".CreateInStream (iStream);
        M2Authenticate.SetSource (iStream);
        iStream.Read (xmltext);

        Message (xmltext);
    end;

    local procedure TestChangeAccountPassword(EMail: Text[80];CurrentPasswordMd5: Text[40];NewPasswordMd5: Text[40])
    var
        M2ChangeAccountPassword: XMLport "M2 Change Account Password";
        TmpOneTimePassword: Record "M2 One Time Password" temporary;
        TmpContact: Record Contact temporary;
        xmltext: Text;
        TmpBLOBbuffer: Record "BLOB buffer" temporary;
        iStream: InStream;
        oStream: OutStream;
    begin

        xmltext :=
          '<?xml version="1.0" encoding="UTF-8" standalone="no"?>'+
          '<ChangeAccountPassword xmlns="urn:microsoft-dynamics-nav/xmlports/x6151149">'+
            '<Request>'+
              StrSubstNo ('<EMail>%1</EMail>', EMail) +
              StrSubstNo ('<PasswordMd5>%1</PasswordMd5>', CurrentPasswordMd5) +
              StrSubstNo ('<NewPasswordMd5>%1</NewPasswordMd5>', NewPasswordMd5) +
            '</Request>'+
          '</ChangeAccountPassword>';

        // Request
        TmpBLOBbuffer.Insert ();
        TmpBLOBbuffer."Buffer 1".CreateOutStream (oStream);
        oStream.WriteText (xmltext);
        TmpBLOBbuffer.Modify ();

        TmpBLOBbuffer."Buffer 1".CreateInStream (iStream);
        M2ChangeAccountPassword.SetSource (iStream);
        M2ChangeAccountPassword.Import ();

        // Process
        M2ChangeAccountPassword.GetRequest (TmpOneTimePassword);
        DoChangePassword (TmpOneTimePassword, TmpContact);
        M2ChangeAccountPassword.SetResponse (TmpContact);

        // Reponse
        TmpBLOBbuffer."Buffer 1".CreateOutStream (oStream);
        M2ChangeAccountPassword.SetDestination (oStream);
        M2ChangeAccountPassword.Export ();
        TmpBLOBbuffer.Modify ();

        TmpBLOBbuffer."Buffer 1".CreateInStream (iStream);
        M2ChangeAccountPassword.SetSource (iStream);
        iStream.Read (xmltext);

        Message (xmltext);
    end;

    local procedure TestResetPassword(EMail: Text[80])
    var
        M2ResetAccountPassword: XMLport "M2 Reset Account Password";
        TmpOneTimePassword: Record "M2 One Time Password" temporary;
        TmpContact: Record Contact temporary;
        xmltext: Text;
        TmpBLOBbuffer: Record "BLOB buffer" temporary;
        iStream: InStream;
        oStream: OutStream;
    begin

        xmltext :=
          '<?xml version="1.0" encoding="UTF-8" standalone="no"?>'+
          '<ResetAccountPassword xmlns="urn:microsoft-dynamics-nav/xmlports/x6151151">'+
            '<Request>'+
              StrSubstNo ('<EMail>%1</EMail>', EMail) +
            '</Request>'+
          '</ResetAccountPassword>';

        // Request
        TmpBLOBbuffer.Insert ();
        TmpBLOBbuffer."Buffer 1".CreateOutStream (oStream);
        oStream.WriteText (xmltext);
        TmpBLOBbuffer.Modify ();

        TmpBLOBbuffer."Buffer 1".CreateInStream (iStream);
        M2ResetAccountPassword.SetSource (iStream);
        M2ResetAccountPassword.Import ();

        // Process
        M2ResetAccountPassword.GetRequest (TmpOneTimePassword);
        DoResetPassword (TmpOneTimePassword);
        M2ResetAccountPassword.SetResponse ();

        // Reponse
        TmpBLOBbuffer."Buffer 1".CreateOutStream (oStream);
        M2ResetAccountPassword.SetDestination (oStream);
        M2ResetAccountPassword.Export ();
        TmpBLOBbuffer.Modify ();

        TmpBLOBbuffer."Buffer 1".CreateInStream (iStream);
        M2ResetAccountPassword.SetSource (iStream);
        iStream.Read (xmltext);

        Message (xmltext);
    end;
}

