codeunit 6184600 "NPR EFT Adyen Cloud Protocol"
{
    Access = Internal;

    var
        _RequestResponseBuffer: Text;

    [TryFunction]
    procedure InvokeAPI(Request: Text; APIKey: Text; URL: Text; TimeoutMs: Integer; var Response: Text; var ResponseStatusCode: Integer)
    var
        Http: HttpClient;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        Headers: HttpHeaders;
        ErrorInvokeLbl: Label 'Error: Service endpoint %1 responded with HTTP status %2';
        ReqRespLbl: Label '(%1) \\%2', Locked = true;
    begin
        ClearLogBuffers();

        AppendRequestResponseBuffer(Request, 'REQUEST');

        HttpRequest.SetRequestUri(URL);
        HttpRequest.Method := 'POST';
        HttpRequest.GetHeaders(Headers);
        Headers.Add('x-api-key', APIKey);
        Http.Timeout := TimeoutMs;

        HttpRequest.Content.WriteFrom(Request);
        HttpRequest.Content.GetHeaders(Headers);
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'application/json');

        Http.Send(HttpRequest, HttpResponse);
        ResponseStatusCode := HttpResponse.HttpStatusCode;

        if not (HttpResponse.IsSuccessStatusCode) then begin
            HttpResponse.Content.ReadAs(Response);
            AppendRequestResponseBuffer(StrSubstNo(ReqRespLbl, ResponseStatusCode, Response), 'Error Response');
            Error(ErrorInvokeLbl, URL, Format(ResponseStatusCode));
        end;

        HttpResponse.Content.ReadAs(Response);
        AppendRequestResponseBuffer(StrSubstNo(ReqRespLbl, ResponseStatusCode, Response), 'Response');
    end;

    local procedure AppendRequestResponseBuffer(Text: Text; Header: Text)
    var
        LF: Char;
        CR: Char;
    begin
        CR := 13;
        LF := 10;

        _RequestResponseBuffer += (Format(CR) + Format(LF) + Format(CR) + Format(LF) + '===' + Header + ' (' + Format(CreateDateTime(Today, Time), 0, 9) + ')===' + Format(CR) + Format(LF) + Text);
    end;

    procedure ClearLogBuffers()
    begin
        Clear(_RequestResponseBuffer);
    end;

    procedure GetLogBuffer(): Text
    begin
        exit(_RequestResponseBuffer);
    end;

    procedure GetTerminalURL(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
    begin
        exit(GetTerminalURL(EFTTransactionRequest.Mode));
    end;

    internal procedure GetTerminalURL(Mode: Option Production,"TEST Local","TEST Remote"): Text
    var
        InvalidModeErr: Label 'Mode must not be TEST Local.';
    begin
        case Mode of
            Mode::Production:
                exit('https://terminal-api-live.adyen.com/sync');
            Mode::"TEST Remote":
                exit('https://terminal-api-test.adyen.com/sync');
            Mode::"TEST Local":
                Error(InvalidModeErr);
        end;
    end;

    procedure GetDisableRecurringURL(EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"): Text
    begin
        exit(GetRecurringURL(EFTTransactionRequest, EFTSetup, 'disable'));
    end;

    procedure GetRecurringURL(EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; Endpoint: Text): Text
    var
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        UriLiveLbl: Label 'https://%1-pal-live.adyenpayments.com/pal/servlet/Recurring/v49/%2', Locked = true;
        UriTestRemoteLbl: Label 'https://pal-test.adyen.com/pal/servlet/Recurring/v49/%1', Locked = true;
    begin
        case EFTTransactionRequest.Mode of
            EFTTransactionRequest.Mode::Production:
                exit(StrSubstNo(UriLiveLbl, EFTAdyenIntegration.GetRecurringURLPrefix(EFTSetup), Endpoint));
            EFTTransactionRequest.Mode::"TEST Remote":
                exit(StrSubstNo(UriTestRemoteLbl, Endpoint));
            EFTTransactionRequest.Mode::"TEST Local":
                EFTTransactionRequest.FieldError(Mode);
        end;
    end;
}