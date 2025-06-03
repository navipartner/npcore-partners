#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6150690 "NPR API POS Salesperson"
{
    access = Internal;

    procedure Login(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        JsonHelper: Codeunit "NPR Json Helper";
        Body: JsonToken;
        Pin: Text;
    begin
        Body := Request.BodyJson();
        Pin := JsonHelper.GetJText(Body, 'pin', false);
        if (Pin <> '') and (StrLen(Pin) <= MaxStrLen(SalespersonPurchaser."NPR Register Password")) then begin
            SalespersonPurchaser.SetRange("NPR Register Password", Pin);
            if SalespersonPurchaser.FindFirst() then
                exit(Response.RespondOK(SalespersonAsJson(SalespersonPurchaser)));
        end;
        Response.CreateErrorResponse(Enum::"NPR API Error Code"::generic_error, 'Invalid pin', "NPR API HTTP Status Code"::Unauthorized);

    end;

    internal procedure ListSalesperson(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        FieldList: Dictionary of [Integer, Text];
        Salesperson: Record "Salesperson/Purchaser";
    begin
        FieldList.Add(Salesperson.FieldNo(SystemId), 'id');
        FieldList.Add(Salesperson.FieldNo(Code), 'code');
        FieldList.Add(Salesperson.FieldNo(Name), 'name');
        FieldList.Add(Salesperson.FieldNo(Blocked), 'blocked');
        exit(Response.RespondOK(Request.GetData(Database::"Salesperson/Purchaser", FieldList)));
    end;

    procedure GetSalesperson(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        Id: Text;
        TestGuid: Guid;
    begin
        Id := Request.Paths().Get(3);
        if Id = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: id'));
        if not Evaluate(TestGuid, Id) then
            exit(Response.RespondBadRequest('Invalid value for path parameter: id'));
        Request.SkipCacheIfNonStickyRequest(GetTableIds());
        SalespersonPurchaser.ReadIsolation := IsolationLevel::ReadCommitted;
        SalespersonPurchaser.SetLoadFields(SystemId, Code, Name);
        if not SalespersonPurchaser.GetBySystemId(Id) then
            exit(Response.RespondResourceNotFound());
        exit(Response.RespondOK(SalespersonAsJson(SalespersonPurchaser)));
    end;

    local procedure SalespersonAsJson(SalespersonPurchaser: Record "Salesperson/Purchaser") JsonBuilder: Codeunit "NPR Json Builder"
    begin
        JsonBuilder.StartObject('')
            .AddProperty('id', Format(SalespersonPurchaser.SystemId, 0, 4).ToLower())
            .AddProperty('code', SalespersonPurchaser.Code)
            .AddProperty('name', SalespersonPurchaser.Name)
        .EndObject();
    end;

    procedure BlockSalesperson(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        Id: Text;
        TestGuid: Guid;
    begin
        Id := Request.Paths().Get(3);
        if Id = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: id'));
        if not Evaluate(TestGuid, Id) then
            exit(Response.RespondBadRequest('Invalid value for path parameter: id'));
        Request.SkipCacheIfNonStickyRequest(GetTableIds());
        SalespersonPurchaser.ReadIsolation := IsolationLevel::ReadCommitted;
        SalespersonPurchaser.SetLoadFields(SystemId, Code, Name, Blocked);

        if not SalespersonPurchaser.GetBySystemId(Id) then
            exit(Response.RespondResourceNotFound());

        SalespersonPurchaser.Blocked := true;
        SalespersonPurchaser.Modify();
        exit(Response.RespondOK(SalespersonBlockedAsJson(SalespersonPurchaser)));
    end;

    procedure UnblockSalesperson(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        Id: Text;
        TestGuid: Guid;
    begin
        Id := Request.Paths().Get(3);
        if Id = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: id'));
        if not Evaluate(TestGuid, Id) then
            exit(Response.RespondBadRequest('Invalid value for path parameter: id'));
        Request.SkipCacheIfNonStickyRequest(GetTableIds());
        SalespersonPurchaser.ReadIsolation := IsolationLevel::ReadCommitted;
        SalespersonPurchaser.SetLoadFields(SystemId, Code, Name, Blocked);

        if not SalespersonPurchaser.GetBySystemId(Id) then
            exit(Response.RespondResourceNotFound());

        SalespersonPurchaser.Blocked := false;
        SalespersonPurchaser.Modify();
        exit(Response.RespondOK(SalespersonBlockedAsJson(SalespersonPurchaser)));
    end;

    procedure CreateSalesperson(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        JsonHelper: Codeunit "NPR Json Helper";
        SalesPersonCode: Code[20];
        SalesPersonName: Text[50];
        Email: Text[80];
        PhoneNo: Text[30];
        RegisterPassword: Code[20];
        SupervisorPOS, Blocked : Boolean;
        POSUnitGroup: Code[20];
        Body: JsonToken;
    begin
        Body := Request.BodyJson();
        if StrLen(JsonHelper.GetJText(Body, 'code', true)) > MaxStrLen(SalesPersonCode) then
            exit(Response.RespondBadRequest('Salesperson Code must have maximum 20 characters'));

        SalesPersonCode := CopyStr(JsonHelper.GetJText(Body, 'code', true), 1, MaxStrLen(SalesPersonCode));
        if SalespersonPurchaser.Get(SalesPersonCode) then
            exit(Response.RespondBadRequest('Salesperson ' + SalesPersonCode + ' already exists'));

        SalesPersonName := CopyStr(JsonHelper.GetJText(Body, 'name', true), 1, MaxStrLen(SalesPersonName));
        Email := CopyStr(JsonHelper.GetJText(Body, 'email', false), 1, MaxStrLen(Email));
        PhoneNo := CopyStr(JsonHelper.GetJText(Body, 'phoneNo', false), 1, MaxStrLen(PhoneNo));
        RegisterPassword := CopyStr(JsonHelper.GetJText(Body, 'registerPassword', false), 1, MaxStrLen(RegisterPassword));
        SupervisorPOS := JsonHelper.GetJBoolean(Body, 'isSupervisor', false);
        Blocked := JsonHelper.GetJBoolean(Body, 'blocked', false);
        POSUnitGroup := Copystr(JsonHelper.GetJText(Body, 'posUnitGroup', false), 1, MaxStrLen(POSUnitGroup));

        CreateSalespersonPurchaser(SalespersonPurchaser, SalesPersonCode, SalesPersonName, Email, PhoneNo, RegisterPassword, SupervisorPOS, Blocked, POSUnitGroup);
        exit(Response.RespondOK(CreateSalespersonAsJson(SalespersonPurchaser)));
    end;

    local procedure SalespersonBlockedAsJson(SalespersonPurchaser: Record "Salesperson/Purchaser") JsonBuilder: Codeunit "NPR Json Builder"
    begin
        JsonBuilder.StartObject('')
            .AddProperty('id', Format(SalespersonPurchaser.SystemId, 0, 4).ToLower())
            .AddProperty('code', SalespersonPurchaser.Code)
            .AddProperty('name', SalespersonPurchaser.Name)
            .AddProperty('blocked', SalespersonPurchaser.Blocked)
        .EndObject();
    end;

    local procedure CreateSalespersonAsJson(SalespersonPurchaser: Record "Salesperson/Purchaser") JsonBuilder: Codeunit "NPR Json Builder"
    begin
        JsonBuilder.StartObject('')
            .AddProperty('id', Format(SalespersonPurchaser.SystemId, 0, 4).ToLower())
            .AddProperty('code', SalespersonPurchaser.Code)
            .AddProperty('name', SalespersonPurchaser.Name)
            .AddProperty('email', SalespersonPurchaser."E-Mail")
            .AddProperty('phoneNo', SalespersonPurchaser."Phone No.")
            .AddProperty('isSupervisor', SalespersonPurchaser."NPR Supervisor POS")
            .AddProperty('blocked', SalespersonPurchaser.Blocked)
            .AddProperty('posUnitGroup', SalespersonPurchaser."NPR POS Unit Group")
        .EndObject();
    end;

    local procedure GetTableIds() TableIds: List of [Integer]
    begin
        TableIds.Add(Database::"Salesperson/Purchaser");
    end;

    local procedure CreateSalespersonPurchaser(var SalespersonPurchaser: Record "Salesperson/Purchaser"; SalesPersonCode: Code[20]; SalesPersonName: Text[50]; Email: Text[80]; PhoneNo: Text[30]; RegisterPassword: Code[20]; SupervisorPOS: Boolean; Blocked: Boolean; POSUnitGroup: Code[20])
    begin
        SalespersonPurchaser.Init();
        SalespersonPurchaser.Validate(Code, SalesPersonCode);
        SalespersonPurchaser.Validate(Name, SalesPersonName);
        SalespersonPurchaser.Validate("E-Mail", Email);
        SalespersonPurchaser.Validate("Phone No.", PhoneNo);
        SalespersonPurchaser.Validate("NPR Register Password", RegisterPassword);
        SalespersonPurchaser.Validate("NPR Supervisor POS", SupervisorPOS);
        SalespersonPurchaser.Blocked := Blocked;
        SalespersonPurchaser.Validate("NPR POS Unit Group", POSUnitGroup);
        SalespersonPurchaser.Insert(true);
    end;


}
#endif