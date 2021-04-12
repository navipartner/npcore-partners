codeunit 6059965 "NPR MPOS Webservice"
{
    trigger OnRun()
    var
        WebService: Record "Web Service";
    begin
        Clear(WebService);

        if not WebService.Get(WebService."Object Type"::Codeunit, 'mpos_service') then begin
            WebService.Init();
            WebService."Object Type" := WebService."Object Type"::Codeunit;
            WebService."Service Name" := 'mpos_service';
            WebService."Object ID" := Codeunit::"NPR MPOS Webservice";
            WebService.Published := true;
            WebService.Insert();
        end;
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

