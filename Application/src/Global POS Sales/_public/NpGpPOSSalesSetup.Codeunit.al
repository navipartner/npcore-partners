codeunit 6150678 "NPR NpGp POS Sales Setup"
{
    procedure ServiceUrl(NpGpPOSSalesSetupCode: Code[10]): Text[250]
    var
        NpGpPOSSalesSetup: Record "NPR NpGp POS Sales Setup";
    begin
        if NpGpPOSSalesSetup.Get(NpGpPOSSalesSetupCode) then
            exit(NpGpPOSSalesSetup."Service Url");
    end;

    procedure SetRequestHeadersAuthorization(NpGpPOSSalesSetupCode: Code[10]; var RequestHeaders: HttpHeaders)
    var
        NpGpPOSSalesSetup: Record "NPR NpGp POS Sales Setup";
    begin
        if NpGpPOSSalesSetup.Get(NpGpPOSSalesSetupCode) then
            NpGpPOSSalesSetup.SetRequestHeadersAuthorization(RequestHeaders);
    end;
}
