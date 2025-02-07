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
        SelectLatestVersion();
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
}
#endif