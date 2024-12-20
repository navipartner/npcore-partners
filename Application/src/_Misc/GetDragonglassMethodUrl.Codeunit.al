codeunit 6248203 "NPR Get Dragonglass Method Url"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnCustomMethod', '', true, true)]
    local procedure OnCustomMethod(Method: Text; Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        ResponseObject: JsonObject;
    begin
        if Method = 'GetDragonglassInvokeMethodWebServiceUrl' then begin
            Handled := true;
            GetInvokeMethodWebServiceUrl(ResponseObject);
            FrontEnd.RespondToFrontEndMethod(Context, ResponseObject, FrontEnd);
        end;
    end;

    local procedure GetInvokeMethodWebServiceUrl(Response: JsonObject)
    var
        baseUrl: Text;
        companyId: Text;
    begin
        baseUrl := GetUrl(ClientType::ODataV4);
        companyId := GetCompanyID();
        if (baseUrl = '') or (companyId = '') then begin
            Response.Add('Error', 'Base Url or Company ID is invalid');
            exit;
        end;
        Response.Add('Url', StrSubstNo('%1/dragonglass_InvokeMethod?company=%2', baseUrl, companyId));
    end;

    procedure GetCompanyID(): Text
    var
        Company: Record Company;
    begin
        Company.Get(CompanyName());
        exit(LowerCase(Format(Company.Id, 0, 4)));
    end;
}