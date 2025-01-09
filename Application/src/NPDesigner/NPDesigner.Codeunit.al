codeunit 6248190 "NPR NPDesigner"
{
    Access = Internal;
    internal procedure LookupDesignLayouts(var AdmissionBom: Record "NPR TM Ticket Admission BOM")
    var
        TemporaryNPDesignerTemplates: Record "NPR NPDesignerTemplates" temporary;
        SelectDesignLayouts: Page "NPR NPDesignerTemplateList";
    begin

        GetDesignerTemplates(TemporaryNPDesignerTemplates);
        if (TemporaryNPDesignerTemplates.FindFirst()) then;
        if (TemporaryNPDesignerTemplates.Get(AdmissionBom.NPDesignerTemplateId)) then;

        SelectDesignLayouts.SetData(TemporaryNPDesignerTemplates);
        SelectDesignLayouts.SetCaption(AdmissionBom.FieldCaption(NPDesignerTemplateLabel));
        SelectDesignLayouts.LookupMode(true);
        if (SelectDesignLayouts.RunModal() <> Action::LookupOK) then
            exit;

        SelectDesignLayouts.GetRecord(TemporaryNPDesignerTemplates);
        AdmissionBom.NPDesignerTemplateId := TemporaryNPDesignerTemplates.ExternalId;
        AdmissionBom.NPDesignerTemplateLabel := CopyStr(TemporaryNPDesignerTemplates.Description, 1, MaxStrLen(AdmissionBom.NPDesignerTemplateLabel));
    end;

    internal procedure ValidateDesignLayouts(var AdmissionBom: Record "NPR TM Ticket Admission BOM")
    var
        TemporaryNPDesignerTemplates: Record "NPR NPDesignerTemplates" temporary;
    begin

        if (AdmissionBom.NPDesignerTemplateLabel = '') then begin
            AdmissionBom.NPDesignerTemplateId := '';
            exit;
        end;

        GetDesignerTemplates(TemporaryNPDesignerTemplates);
        TemporaryNPDesignerTemplates.SetFilter(Description, '%1', '@' + AdmissionBom.NPDesignerTemplateLabel + '*');
        if (not TemporaryNPDesignerTemplates.FindFirst()) then
            Error('Design Layout %1 not found', AdmissionBom.NPDesignerTemplateLabel);

        AdmissionBom.NPDesignerTemplateId := TemporaryNPDesignerTemplates.ExternalId;
        AdmissionBom.NPDesignerTemplateLabel := CopyStr(TemporaryNPDesignerTemplates.Description, 1, MaxStrLen(AdmissionBom.NPDesignerTemplateLabel));
    end;


    local procedure GetDesignerTemplates(var DesignerTemplates: Record "NPR NPDesignerTemplates" temporary)
    var
        Layouts: JsonObject;
        DesignLayouts: JsonArray;
        Result, Design, Designs : JsonToken;
    begin
        Result := DesignerTemplateApi();

        if (Result.IsObject()) then begin
            Layouts := Result.AsObject();
            Layouts.Get('designs', Designs);
            if (Designs.IsArray()) then
                DesignLayouts := Designs.AsArray();
        end;

        if (Result.IsArray()) then
            DesignLayouts := Result.AsArray();

        foreach Design in DesignLayouts do begin
            DesignerTemplates.ExternalId := CopyStr(AsText(Design, 'value'), 1, MaxStrLen(DesignerTemplates.ExternalId));
            DesignerTemplates.Description := CopyStr(AsText(Design, 'label'), 1, MaxStrLen(DesignerTemplates.Description));
            DesignerTemplates.Insert(true);
        end;

    end;

    procedure DesignerTemplateApi() Result: JsonToken
    var
        HttpWebRequest: HttpRequestMessage;
        HttpWebResponse: HttpResponseMessage;
        Client: HttpClient;
        Headers: HttpHeaders;
        Response: Text;
        Setup: Record "NPR NPDesignerSetup";
    begin
        Clear(Response);
        Setup.Get();
        Setup.TestField(DesignerURL);
        Setup.TestField(ApiAuthorization);

        // For testing purposes
        // HttpWebRequest.SetRequestUri('https://bc-designer-api.npretail-prelive.app');
        // Headers.Add('Authorization', 'Bearer 213');
        HttpWebRequest.SetRequestUri(Setup.DesignerURL);
        HttpWebRequest.Method('GET');
        HttpWebRequest.GetHeaders(Headers);
        Headers.Add('Authorization', StrSubstNo('Bearer %1', Setup.ApiAuthorization));

        Client.Timeout := 60000;
        Client.Send(HttpWebRequest, HttpWebResponse);
        HttpWebResponse.Content.ReadAs(Response);
        if not HttpWebResponse.IsSuccessStatusCode() then
            Error('%1 - %2  \%3', HttpWebResponse.HttpStatusCode, HttpWebResponse.ReasonPhrase, Response);

        Result.ReadFrom(Response);
    end;


    local procedure AsText(JToken: JsonToken; JPath: Text) Value: Text
    var
        JToken2: JsonToken;
    begin
        if not JToken.SelectToken(JPath, JToken2) then
            exit('');

        Value := JToken2.AsValue().AsText();
        exit(Value);
    end;
}