codeunit 6150678 "NPR NpGp POS Sales Setup"
{
    procedure ServiceUrl(NpGpPOSSalesSetupCode: Code[10]): Text[250]
    var
        NpGpPOSSalesSetup: Record "NPR NpGp POS Sales Setup";
    begin
        if NpGpPOSSalesSetup.Get(NpGpPOSSalesSetupCode) then
            exit(NpGpPOSSalesSetup."Service Url");
    end;
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
    procedure ODataBaseUrl(NpGpPOSSalesSetupCode: Code[10]): Text[250]
    var
        NpGpPOSSalesSetup: Record "NPR NpGp POS Sales Setup";
    begin
        if NpGpPOSSalesSetup.Get(NpGpPOSSalesSetupCode) then
            exit(NpGpPOSSalesSetup."OData Base Url");
    end;

    procedure UseApi(NpGpPOSSalesSetupCode: Code[10]): Boolean
    var
        NpGpPOSSalesSetup: Record "NPR NpGp POS Sales Setup";
    begin
        if NpGpPOSSalesSetup.Get(NpGpPOSSalesSetupCode) then
            exit(NpGpPOSSalesSetup."Use API");
    end;
#endif

    procedure SetRequestHeadersAuthorization(NpGpPOSSalesSetupCode: Code[10]; var RequestHeaders: HttpHeaders)
    var
        NpGpPOSSalesSetup: Record "NPR NpGp POS Sales Setup";
    begin
        if NpGpPOSSalesSetup.Get(NpGpPOSSalesSetupCode) then
            NpGpPOSSalesSetup.SetRequestHeadersAuthorization(RequestHeaders);
    end;
}
