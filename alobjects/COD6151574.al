codeunit 6151574 "AF API - Notification Hub"
{
    // NPR5.36/CLVA/20170710 CASE 269792 AF API - NotificationHub


    trigger OnRun()
    begin
    end;

    var
        ConnectionFailError: Label 'Uable to connect to Azure Function';

    procedure SendPushNotification(var AFArgumentsNotificationHub: Record "AF Arguments - NotificationHub" temporary): Boolean
    var
        AFAPINotificationHub: Codeunit "AF API - Notification Hub";
        AFSetup: Record "AF Setup";
    begin
        if AFArgumentsNotificationHub.Body = '' then
            exit;

        if AFArgumentsNotificationHub."Action Type" <> AFArgumentsNotificationHub."Action Type"::Message then
            if AFArgumentsNotificationHub."Action Value" = '' then
                exit;

        if not IsAFEnabled then
            exit;

        AFSetup.Get;
        AFSetup.TestField("Notification - API Key");
        AFSetup.TestField("Notification - Base Url");
        AFSetup.TestField("Notification - API Routing");
        AFSetup.TestField("Notification - Conn. String");
        AFSetup.TestField("Customer Tag");

        AFArgumentsNotificationHub."API Key" := AFSetup."Notification - API Key";
        AFArgumentsNotificationHub."Base Url" := AFSetup."Notification - Base Url";
        AFArgumentsNotificationHub."API Routing" := AFSetup."Notification - API Routing";
        AFArgumentsNotificationHub."Hub Connection String" := AFSetup."Notification - Conn. String";
        AFArgumentsNotificationHub."Notification Hub Path" := AFSetup."Notification - Hub Path";
        AFArgumentsNotificationHub."Customer Tag" := AFSetup."Customer Tag";

        exit(BuildRequest(AFArgumentsNotificationHub));
    end;

    procedure ReSendPushNotification(AFNotificationHub: Record "AF Notification Hub")
    var
        NewAFNotificationHub: Record "AF Notification Hub";
    begin
        NewAFNotificationHub.TransferFields(AFNotificationHub, false);
        NewAFNotificationHub.Insert(true);
    end;

    local procedure BuildRequest(var AFArgumentsNotificationHub: Record "AF Arguments - NotificationHub"): Boolean
    var
        Parameters: DotNet npNetDictionary_Of_T_U;
        AFManagement: Codeunit "AF Management";
        AFHelperFunctions: Codeunit "AF Helper Functions";
        HttpResponseMessage: DotNet npNetHttpResponseMessage;
        Path: Text;
        Window: Dialog;
        WebUtility: DotNet npNetWebUtility;
        ImageStream: DotNet npNetMemoryStream;
        OutStr: OutStream;
        JObject: DotNet JObject;
        JTokenWriter: DotNet npNetJTokenWriter;
        StringContent: DotNet npNetStringContent;
        Encoding: DotNet npNetEncoding;
        Request: BigText;
        Response: BigText;
        Ostream: OutStream;
        TextString: Text;
    begin
        JTokenWriter := JTokenWriter.JTokenWriter;
        with JTokenWriter do begin
            WriteStartObject;
            WritePropertyName('connectionString');
            WriteValue(AFArgumentsNotificationHub."Hub Connection String");
            WritePropertyName('notificationHubPath');
            WriteValue(AFArgumentsNotificationHub."Notification Hub Path");
            WritePropertyName('platform');
            WriteValue(AFHelperFunctions.GetOptionStringValue(AFArgumentsNotificationHub.Platform, AFArgumentsNotificationHub.FieldNo(Platform), AFArgumentsNotificationHub));
            WritePropertyName('title');
            WriteValue(AFArgumentsNotificationHub.Title);
            WritePropertyName('message');
            WriteValue(AFArgumentsNotificationHub.Body);
            WritePropertyName('notificationColor');
            WriteValue(AFHelperFunctions.GetOptionStringValue(AFArgumentsNotificationHub."Notification Color", AFArgumentsNotificationHub.FieldNo("Notification Color"), AFArgumentsNotificationHub));
            WritePropertyName('customerTag');
            WriteValue(AFArgumentsNotificationHub."Customer Tag");
            WritePropertyName('registerToTag');
            WriteValue(AFArgumentsNotificationHub."To Register No.");
            WritePropertyName('actionType');
            WriteValue(AFHelperFunctions.GetOptionStringValue(AFArgumentsNotificationHub."Action Type", AFArgumentsNotificationHub.FieldNo("Action Type"), AFArgumentsNotificationHub));
            WritePropertyName('actionValue');
            WriteValue(AFArgumentsNotificationHub."Action Value");
            WritePropertyName('notificationKey');
            WriteValue(AFArgumentsNotificationHub."Notification Key");
            WritePropertyName('registerFromTag');
            WriteValue(AFArgumentsNotificationHub."From Register No.");
            WritePropertyName('createdBy');
            WriteValue(AFArgumentsNotificationHub."Created By");
            WriteEndObject;
            JObject := Token;
        end;

        TextString := JObject.ToString;
        Request.AddText(TextString);
        AFArgumentsNotificationHub."Request Data".CreateOutStream(Ostream);
        Request.Write(Ostream);

        StringContent := StringContent.StringContent(JObject.ToString, Encoding.UTF8, 'application/json');

        Parameters := Parameters.Dictionary();
        Parameters.Add('baseurl', AFArgumentsNotificationHub."Base Url");
        Parameters.Add('restmethod', 'POST');
        Parameters.Add('path', AFRequestUrl(AFArgumentsNotificationHub."API Routing", AFArgumentsNotificationHub."API Key"));
        Parameters.Add('httpcontent', StringContent);

        AFArgumentsNotificationHub."Notification Delivered to Hub" := AFManagement.CallRESTWebService(Parameters, HttpResponseMessage);

        Clear(Ostream);
        if AFArgumentsNotificationHub."Notification Delivered to Hub" then begin
            TextString := HttpResponseMessage.Content.ReadAsStringAsync.Result;
            Response.AddText(TextString);
        end else begin
            Response.AddText(ConnectionFailError);
        end;

        AFArgumentsNotificationHub."Response Data".CreateOutStream(Ostream);
        Response.Write(Ostream);

        exit(AFArgumentsNotificationHub."Notification Delivered to Hub");
    end;

    local procedure AFRequestUrl(APIRouting: Text; APIKey: Text): Text
    begin
        exit(APIRouting + '?code=' + APIKey);
    end;

    local procedure IsAFEnabled(): Boolean
    var
        AFSetup: Record "AF Setup";
    begin
        if AFSetup.Get() then
            exit(AFSetup."Enable Azure Functions");

        exit(false);
    end;

    procedure SendIOSPushNotification(Title: Text[30]; Message: Text[250]; NotificationColor: Option Red,Green,Blue,Yellow,Dark; FromRegisterNo: Code[10]; ToRegisterNo: Code[10]; ActionType: Option Message,"Phone Call","Facetime Video","Facetime Audio"; ActionValue: Text[100]): Boolean
    var
        AFArgumentsNotificationHub: Record "AF Arguments - NotificationHub";
        AFAPINotificationHub: Codeunit "AF API - Notification Hub";
        AFSetup: Record "AF Setup";
    begin
        if Message = '' then
            exit;

        if ActionType <> ActionType::Message then
            if ActionValue = '' then
                exit;

        if not IsAFEnabled then
            exit;

        AFSetup.Get;
        AFSetup.TestField("Notification - API Key");
        AFSetup.TestField("Notification - Base Url");
        AFSetup.TestField("Notification - API Routing");
        AFSetup.TestField("Notification - Conn. String");
        AFSetup.TestField("Customer Tag");

        AFArgumentsNotificationHub.Init;
        AFArgumentsNotificationHub.Title := Title;
        AFArgumentsNotificationHub.Body := Message;
        AFArgumentsNotificationHub."Action Type" := ActionType;
        AFArgumentsNotificationHub."Action Value" := ActionValue;
        AFArgumentsNotificationHub."Notification Color" := NotificationColor;
        AFArgumentsNotificationHub."API Key" := AFSetup."Notification - API Key";
        AFArgumentsNotificationHub."Base Url" := AFSetup."Notification - Base Url";
        AFArgumentsNotificationHub."API Routing" := AFSetup."Notification - API Routing";
        AFArgumentsNotificationHub."Hub Connection String" := AFSetup."Notification - Conn. String";
        AFArgumentsNotificationHub."Notification Hub Path" := AFSetup."Notification - Hub Path";
        AFArgumentsNotificationHub."Customer Tag" := AFSetup."Customer Tag";

        exit(AFAPINotificationHub.SendPushNotification(AFArgumentsNotificationHub));
    end;
}

