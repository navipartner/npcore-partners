codeunit 6151164 "NPR MM Loy. Point WS (Client)"
{
    procedure WebServiceApi(LoyaltyEndpointClient: Record "NPR MM NPR Remote Endp. Setup"; SoapAction: Text;
        var ReasonText: Text; var XmlDocIn: XmlDocument; var XmlDocOut: XmlDocument): Boolean
    var
        NPRMembership: Codeunit "NPR MM NPR Membership";
    begin
        exit(NPRMembership.WebServiceApi(LoyaltyEndpointClient, SoapAction, ReasonText, XmlDocIn, XmlDocOut));
    end;

    procedure XmlSafe(InText: Text): Text
    begin
        exit(DelChr(InText, '<=>', DelChr(InText, '<=>', '1234567890 abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-+*')));
    end;
}

