#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248416 "NPR UserAccountAPI" implements "NPR API Request Handler"
{
    Access = Internal;

    procedure Handle(var Request: Codeunit "NPR API Request"): Codeunit "NPR API Response"
    var
        UserAccountPmtMethodAPI: Codeunit "NPR UserAccountPaymMethodAPI";
    begin
        case true of
            Request.Match('GET', '/account/:accountId/paymentMethod'):
                exit(UserAccountPmtMethodAPI.GetPaymentMethodsFromAccount(Request));
            Request.Match('POST', '/account/:accountId/paymentMethod'):
                exit(UserAccountPmtMethodAPI.CreatePaymentMethodForAccount(Request));
            Request.Match('GET', '/account'):
                exit(FindAccount(Request));
            Request.Match('GET', '/account/:accountId'):
                exit(GetAccountById(Request));
            Request.Match('POST', '/account'):
                exit(CreateAccount(Request));
        end;
    end;

    local procedure FindAccount(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        PhoneNumber: Text;
        EmailAddress: Text;
        UserAccount: Record "NPR UserAccount";
        Json: Codeunit "NPR Json Builder";
    begin
        Request.SkipCacheIfNonStickyRequest(GetTableIds());

        if (not Request.QueryParams().Get('phoneNumber', PhoneNumber)) then;
        if (not Request.QueryParams().Get('emailAddress', EmailAddress)) then;

        if (PhoneNumber = '') and (EmailAddress = '') then
            exit(Response.RespondBadRequest('Either "phoneNumber" or "emailAddress" must be filled out, both cannot be empty.'));

        UserAccountSetLoadFields(UserAccount);
        UserAccount.ReadIsolation := IsolationLevel::ReadCommitted;
        UserAccount.FilterGroup := -1;
        if (PhoneNumber <> '') then
            UserAccount.SetRange(PhoneNo, PhoneNumber);
        if (EmailAddress <> '') then
            UserAccount.SetRange(EmailAddress, EmailAddress);

        Json.StartArray();
        if (UserAccount.FindSet()) then
            repeat
                Json.AddObject(UserAccountDTO(UserAccount, Json));
            until UserAccount.Next() = 0;
        Json.EndArray();

        exit(Response.RespondOK(Json.BuildAsArray()));
    end;

    local procedure GetAccountById(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        AccountIdTxt: Text;
        AccountId: Guid;
        UserAccount: Record "NPR UserAccount";
        Json: Codeunit "NPR Json Builder";
    begin
        Request.SkipCacheIfNonStickyRequest(GetTableIds());

        if (not Request.Paths().Get(2, AccountIdTxt)) then
            exit(Response.RespondBadRequest('Missing required parameter: accountId'));
        if (not Evaluate(AccountId, AccountIdTxt)) then
            exit(Response.RespondBadRequest('Malformed parameter: accountId'));

        UserAccountSetLoadFields(UserAccount);
        UserAccount.ReadIsolation := IsolationLevel::ReadCommitted;
        if (not UserAccount.GetBySystemId(AccountId)) then
            exit(Response.RespondResourceNotFound());

        exit(Response.RespondOK(UserAccountDTO(UserAccount, Json)));
    end;

    local procedure CreateAccount(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        UserAccountMgt: Codeunit "NPR UserAccountMgtImpl";
        UserAccount: Record "NPR UserAccount";
        RequestJson: JsonToken;
        JHelper: Codeunit "NPR Json Helper";
        Json: Codeunit "NPR Json Builder";
        MailManagement: Codeunit "Mail Management";
        PhoneNo, EmailAddress : Text;
    begin
        Request.SkipCacheIfNonStickyRequest(GetTableIds());

        RequestJson := Request.BodyJson();

        PhoneNo := JHelper.GetJText(RequestJson, 'phoneNumber', false).Trim();
        if (PhoneNo <> '') then
            // phone number can only contain a plus and numbers
            if (DelChr(PhoneNo, '=', '+1234567890') <> '') then
                exit(Response.RespondBadRequest('Unsupported characters in phoneNumber.'));

        EmailAddress := JHelper.GetJText(RequestJson, 'emailAddress', true).Trim().ToLower();
        if (EmailAddress <> '') then
            if (not MailManagement.CheckValidEmailAddress(EmailAddress)) then
                exit(Response.RespondBadRequest('E-mail Address provided is not valid.'));

        UserAccount.Init();
        UserAccount.Validate(FirstName, JHelper.GetJText(RequestJson, 'firstName', false));
        UserAccount.Validate(LastName, JHelper.GetJText(RequestJson, 'lastName', false));
#pragma warning disable AA0139
        UserAccount.PhoneNo := PhoneNo;
        UserAccount.EmailAddress := EmailAddress;
#pragma warning restore AA0139

        UserAccountMgt.CreateAccount(UserAccount);

        exit(Response.RespondCreated(UserAccountDTO(UserAccount, Json)));
    end;

    local procedure UserAccountDTO(UserAccount: Record "NPR UserAccount"; var Json: Codeunit "NPR Json Builder"): Codeunit "NPR Json Builder"
    begin
        Json.StartObject()
                .AddProperty('id', Format(UserAccount.SystemId, 0, 4).ToLower())
                .AddProperty('firstName', UserAccount.FirstName)
                .AddProperty('lastName', UserAccount.LastName)
                .AddProperty('displayName', UserAccount.DisplayName)
                .AddProperty('phoneNumber', UserAccount.PhoneNo)
                .AddProperty('emailAddress', UserAccount.EmailAddress)
            .EndObject();

        exit(Json);
    end;

    local procedure UserAccountSetLoadFields(var UserAccount: Record "NPR UserAccount")
    begin
        UserAccount.SetLoadFields(SystemId, FirstName, LastName, PhoneNo, EmailAddress);
    end;

    local procedure GetTableIds() TableIds: List of [Integer]
    begin
        TableIds.Add(Database::"NPR UserAccount");
    end;
}
#endif