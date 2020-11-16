codeunit 6059915 "NPR Create Person Group"
{
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
        CompanyContact: Record Contact;
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        InStr: InStream;
        RequestHeaders: HttpHeaders;
        RequestContent: HttpContent;
        ContentHeader: HttpHeaders;
        GroupID: Text;
        PersonParameters: Text;
        TempFilename: Text;
        Uri: Text;
    begin
        Request.GetHeaders(RequestHeaders);
        RequestHeaders.Add('Ocp-Apim-Subscription-Key', FacialRecognitionSetup.APIKey);
        Request.Method('PUT');

        if CompanyContact.Get(Contact."Company No.") then
            GroupID := LowerCase(CompanyContact."No.")
        else
            GroupID := 'person';

        Uri := FacialRecognitionSetup.BaseURL + FacialRecognitionSetup.PersonGroupURI + GroupID;
        Request.SetRequestUri(Uri);

        RequestContent.GetHeaders(ContentHeader);
        ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'application/json');

        PersonParameters := '{' +
                            '"name":' +
                            StrSubstNo('"%1"', CompanyContact.Name) +
                            '}';

        TempFilename := FileMgt.CreateAndWriteToServerFile(PersonParameters, '.txt');
        FileMgt.BLOBImportFromServerFile(TempBlob, TempFilename);
        TempBlob.CreateInStream(InStr);

        RequestContent.WriteFrom(InStr);
        Request.Content := RequestContent;
        FileMgt.DeleteServerFile(TempFilename);
    end;

    local procedure SendRequest()
    begin
        Client.Send(Request, Response);
    end;

    local procedure ParseResponse(CalledFromSubscriber: Boolean)
    begin
        if CalledFromSubscriber then
            exit;

        if not Response.IsSuccessStatusCode then begin
            Error(Response.ReasonPhrase);
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