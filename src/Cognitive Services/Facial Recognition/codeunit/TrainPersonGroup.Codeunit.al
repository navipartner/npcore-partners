codeunit 6059919 "NPR Train Person Group"
{
    var
        FacialRecognitionSetup: Record "NPR Facial Recogn. Setup";
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;

    procedure TrainPersonGroup(var Contact: Record Contact; CalledFromSubscriber: Boolean)
    begin
        FacialRecognitionSetup.FindFirst();

        CreateRequest(Contact);
        SendRequest();
        ParseResponse(CalledFromSubscriber);
    end;

    local procedure CreateRequest(var Contact: Record Contact)
    var
        RequestHeaders: HttpHeaders;
        GroupID: Text;
        Uri: Text;
    begin
        Request.GetHeaders(RequestHeaders);
        RequestHeaders.Add('Ocp-Apim-Subscription-Key', FacialRecognitionSetup.APIKey);
        Request.Method('POST');

        GroupID := LowerCase(Contact."Company No.");

        Uri := FacialRecognitionSetup.BaseURL + FacialRecognitionSetup.PersonGroupURI + GroupID + FacialRecognitionSetup.TrainPersonGroupURI;
        Request.SetRequestUri(Uri);
    end;

    local procedure SendRequest()
    begin
        Client.Send(Request, Response);
    end;

    local procedure ParseResponse(CalledFromSubscriber: Boolean)
    var
        ImageImported: Label 'Image successfully imported.';
    begin
        if CalledFromSubscriber then
            exit;

        if not Response.IsSuccessStatusCode then begin
            Error(Response.ReasonPhrase);
        end else
            Message(ImageImported);
    end;
}