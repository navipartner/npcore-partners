codeunit 6059965 "NPR MPOS Webservice"
{
    trigger OnRun()
    var
        WebServiceMgt: Codeunit "Web Service Management";
    begin
        WebServiceMgt.CreateTenantWebService(5, Codeunit::"NPR MPOS Webservice", 'mpos_service', true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Web Service Aggregate", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWebServiceAggregate(var Rec: Record "Web Service Aggregate"; RunTrigger: Boolean)
    var
    begin
        if Rec."Object Type" <> Rec."Object Type"::Codeunit then
            exit;
        if Rec."Service Name" <> 'mpos_service' then
            exit;

        Rec."All Tenants" := false;
    end;

    procedure GetCompanyLogo() PictureBase64: Text
    var
        CompanyInformation: Record "Company Information";
        Base64Convert: Codeunit "Base64 Convert";
        InStr: InStream;
    begin
        CompanyInformation.Get();

        CompanyInformation.CalcFields(Picture);
        if CompanyInformation.Picture.HasValue() then begin
            CompanyInformation.Picture.CreateInStream(InStr);
            PictureBase64 := Base64Convert.ToBase64(InStr);
        end;

        exit(PictureBase64);
    end;

    procedure GetCompanyInfo(): Text
    var
        CompanyInformation: Record "Company Information";
        InStr: InStream;
        JObject: JsonObject;
        Base64String: Text;
        MPOSHelperFunctions: Codeunit "NPR MPOS Helper Functions";
        Base64Convert: Codeunit "Base64 Convert";
        Result: Text;
    begin
        CompanyInformation.Get();

        CompanyInformation.CalcFields(Picture);
        if CompanyInformation.Picture.HasValue() then begin
            CompanyInformation.Picture.CreateInStream(InStr);
            Base64String := Base64Convert.ToBase64(InStr);
        end;

        JObject.Add('Base64Image', Base64String);
        JObject.Add('Username', MPOSHelperFunctions.GetUsername());
        JObject.Add('DatabaseName', MPOSHelperFunctions.GetDatabaseName());
        JObject.Add('TenantID', MPOSHelperFunctions.GetTenantID());
        JObject.Add('CompanyName', CompanyName);
        JObject.WriteTo(Result);
        exit(Result);
    end;

}

