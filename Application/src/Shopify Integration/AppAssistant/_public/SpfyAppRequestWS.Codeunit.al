#if not BC17
codeunit 6248241 "NPR Spfy App Request WS"
{
    Access = Public;

    procedure UpsertShopifyStore(json: Text): Text
    var
        SpfyAppRequest: Record "NPR Spfy App Request";
        SpfyAppRequestParser: Codeunit "NPR Spfy App Request Parser";
        SuccessMsg: Label 'Shopify store upserted successfully.';
    begin
        SpfyAppRequestParser.SetRequest(Enum::"NPR Spfy App Request Type"::UpsertShopifyStore, json);
        SpfyAppRequestParser.Run(SpfyAppRequest);

        ProcessAppRequest(SpfyAppRequest);

        exit(SuccessMsg);
    end;

    internal procedure ProcessAppRequest(var SpfyAppRequest: Record "NPR Spfy App Request")
    begin
        ClearLastError();
        SpfyAppRequest.SetRecFilter();
        if not Codeunit.Run(Codeunit::"NPR Spfy App Request Handler", SpfyAppRequest) then begin
            SpfyAppRequest.Find();
            if SpfyAppRequest.Status = SpfyAppRequest.Status::New then begin
                SpfyAppRequest.Status := SpfyAppRequest.Status::Error;
                SpfyAppRequest.SetErrorMessage(GetLastErrorText());
                SpfyAppRequest.Modify(true);
                Commit();
            end;
            if SpfyAppRequest.Status = SpfyAppRequest.Status::Error then
                Error(SpfyAppRequest.GetErrorMessage());
        end;
    end;

    internal procedure RegisterShopifyAppRequestListenerWebservice()
    var
        TenantWebService: Record "Tenant Web Service";
        WebServiceManagement: Codeunit "Web Service Management";
        ServiceNameTok: Label 'ShopifyAppRequest', Locked = true, MaxLength = 240;
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Codeunit, Codeunit::"NPR Spfy App Request WS", ServiceNameTok, true);
    end;
}
#endif