codeunit 6059915 "NPR Create Person Group"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Refractored to old code MCS Face Recognition';

    var
        FacialRecognitionSetup: Record "NPR Facial Recogn. Setup";
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;

    procedure CreatePersonGroup(var Contact: Record Contact; CalledFromSubscriber: Boolean)
    begin
        FacialRecognitionSetup.FindFirst();

        if CheckIfGroupExists(Contact) then
            exit;

        CreateRequest(Contact);
        SendRequest();
        ParseResponse(CalledFromSubscriber);
    end;

    local procedure CheckIfGroupExists(var Contact: Record Contact): Boolean
    var
        FacialRecognition: Record "NPR Facial Recognition";
        Req: HttpRequestMessage;
        Resp: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        ResponseHeaders: HttpHeaders;
        Uri: Text;
    begin
        FacialRecognition.SetRange("Person Group", Contact."Company No.");
        if not FacialRecognition.FindFirst() then
            exit;

        Req.GetHeaders(RequestHeaders);
        RequestHeaders.Add('Ocp-Apim-Subscription-Key', FacialRecognitionSetup.APIKey);
        Req.Method('GET');

        Uri := FacialRecognitionSetup.BaseURL + FacialRecognitionSetup.PersonGroupURI + LowerCase(Contact."Company No.");
        Client.SetBaseAddress(Uri);
        Client.Send(Req, Resp);

        ResponseHeaders := Resp.Headers;
        exit(Resp.IsSuccessStatusCode);
    end;

    local procedure CreateRequest(var Contact: Record Contact)
    var
        JsonObj: JsonObject;
        CompanyContact: Record Contact;
        InStr: InStream;
        RequestHeaders: HttpHeaders;
        RequestContent: HttpContent;
        ContentHeader: HttpHeaders;
        GroupID: Text;
        PersonParameters: Text;
        Uri: Text;
    begin

        if CompanyContact.Get(Contact."Company No.") then
            GroupID := LowerCase(CompanyContact."No.")
        else
            GroupID := 'person';

        Uri := FacialRecognitionSetup.BaseURL + FacialRecognitionSetup.PersonGroupURI + GroupID;

        Request.GetHeaders(RequestHeaders);
        RequestHeaders.Add('Ocp-Apim-Subscription-Key', FacialRecognitionSetup.APIKey);
        Request.Method('PUT');

        Request.SetRequestUri(Uri);

        JsonObj.Add('name', CompanyContact.Name);
        JsonObj.WriteTo(PersonParameters);

        RequestContent.WriteFrom(PersonParameters);

        RequestContent.GetHeaders(ContentHeader);
        ContentHeader.Clear();
        ContentHeader.Add('Content-Type', 'application/json');

        Request.Content := RequestContent;
    end;

    local procedure SendRequest()
    begin
        Client.Send(Request, Response);
    end;

    local procedure ParseResponse(CalledFromSubscriber: Boolean)
    var
        ResponseMsg: Text;
    begin
        if CalledFromSubscriber then
            exit;

        if not Response.IsSuccessStatusCode then begin
            Response.Content.ReadAs(ResponseMsg);
            Error('%1 - %2', Response.ReasonPhrase, ResponseMsg);
        end;
    end;

    procedure GetPersonGroups(): Boolean
    var
        Req: HttpRequestMessage;
        Resp: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        ResponseHeaders: HttpHeaders;
        Client2: HttpClient;
        Uri: Text;
    begin
        FacialRecognitionSetup.FindFirst();

        Req.GetHeaders(RequestHeaders);
        RequestHeaders.Add('Ocp-Apim-Subscription-Key', FacialRecognitionSetup.APIKey);
        Req.Method('GET');

        Uri := FacialRecognitionSetup.BaseURL + FacialRecognitionSetup.PersonGroupURI;
        Client2.SetBaseAddress(Uri);
        Client2.Send(Req, Resp);

        ResponseHeaders := Resp.Headers;
        exit(Resp.IsSuccessStatusCode);
    end;
}