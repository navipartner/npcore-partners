codeunit 6151493 "Raptor API"
{
    // NPR5.51/CLVA/20190710  CASE 355871 Object created


    trigger OnRun()
    begin
    end;

    procedure GetUserIdOrderHistory(UserIdentifier: Text;var ErrorMsg: Text): Text
    var
        RaptorManagement: Codeunit "Raptor Management";
        RaptorSetup: Record "Raptor Setup";
        Parameters: DotNet npNetDictionary_Of_T_U;
        Baseurl: Text;
        Path: Text;
        HttpResponseMessage: DotNet npNetHttpResponseMessage;
        RequestStatus: Boolean;
        Result: Text;
        RaptorHelperFunctions: Codeunit "Raptor Helper Functions";
        JArray: DotNet npNetJArray;
        JObject: DotNet npNetJObject;
    begin
        if not IsEnabled then
          exit;

        if UserIdentifier = '' then
          exit;

        RaptorSetup.Get;
        RaptorSetup.TestField("API Key");
        RaptorSetup.TestField("Base Url");

        Baseurl := RaptorSetup."Base Url";
        Path := '/v1/6184/GetUserIdOrderHistory/100/'+RaptorSetup."API Key"+'?UserIdentifier='+UserIdentifier;

        Parameters := Parameters.Dictionary();
        Parameters.Add('baseurl',Baseurl);
        Parameters.Add('restmethod','GET');
        Parameters.Add('path',Path);

        RequestStatus := RaptorManagement.CallRaptorAPI(Parameters,HttpResponseMessage);
        Result := HttpResponseMessage.Content.ReadAsStringAsync.Result;

        if not RequestStatus then begin
          ErrorMsg := Result;
          Result := '';
        end;

        exit(Result);

        // Sample for reading result from Raptor
        // RaptorHelperFunctions.TryParse(result,JArray);
        //
        // FOREACH JObject IN JArray DO BEGIN
        //  MESSAGE(RaptorHelperFunctions.GetValueAsText(JObject,'ProductId'));
        //  MESSAGE(RaptorHelperFunctions.GetValueAsText(JObject,'Orderdate'));
        // END;
    end;

    local procedure IsEnabled(): Boolean
    var
        RaptorSetup: Record "Raptor Setup";
    begin
        if RaptorSetup.Get() then
          exit(RaptorSetup."Enable Raptor Functions");

        exit(false);
    end;
}

