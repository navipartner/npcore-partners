#pragma warning disable AA0139
codeunit 6060147 "NPR MM NPR Membership"
{
    var
        InvalidXml: Label 'An invalid XML was returned:\%1';
        MemberCardValidation: Label 'Service %1 at %2 could not validate membercard %3.';

    [EventSubscriber(ObjectType::Codeunit, 6060145, 'OnDiscoverExternalMembershipMgr', '', true, true)]
    local procedure OnDiscover(var Sender: Record "NPR MM Foreign Members. Setup")
    begin
        Sender.RegisterManager(GetManagerCode(), 'NaviPartner Foreign NPR Membership Management');
    end;

    local procedure GetManagerCode(): Code[20]
    begin
        exit('NPR_MEMBER');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060145, 'OnDispatchToReplicateForeignMemberCard', '', true, true)]
    local procedure OnValidateAndReplicateForeignMemberCardSubscriber(CommunityCode: Code[20]; ManagerCode: Code[20];
        ForeignMemberCardNumber: Text[100]; var IsValid: Boolean; var NotValidReason: Text; var IsHandled: Boolean)
    var
        ForeignMembershipSetup: Record "NPR MM Foreign Members. Setup";
        NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup";
        NoPrefixForeignMemberCardNumber: Text[100];
    begin
        if (ManagerCode <> GetManagerCode()) then
            exit;

        NPRRemoteEndpointSetup.SetFilter("Community Code", '=%1', CommunityCode);
        NPRRemoteEndpointSetup.SetFilter(Type, '=%1', NPRRemoteEndpointSetup.Type::MemberServices);
        NPRRemoteEndpointSetup.SetFilter(Disabled, '=%1', false);
        if (not NPRRemoteEndpointSetup.FindFirst()) then
            exit;

        IsHandled := true;

        ForeignMembershipSetup.Get(CommunityCode, ManagerCode);

        //ForeignMembercardNumber := RemoveLocalPrefix (ForeignMembershipSetup."Remove Local Prefix", ForeignMembercardNumber);
        NoPrefixForeignMemberCardNumber := RemoveLocalPrefix(ForeignMembershipSetup."Remove Local Prefix", ForeignMemberCardNumber);

        ValidateForeignMemberCard(NPRRemoteEndpointSetup, NoPrefixForeignMemberCardNumber, IsValid, NotValidReason);
        if (IsValid) then
            ReplicateMembership(NPRRemoteEndpointSetup, NoPrefixForeignMemberCardNumber, IsValid, NotValidReason);

        if (not IsValid) then
            if (NoPrefixForeignMemberCardNumber <> ForeignMemberCardNumber) then
                Error(NotValidReason);

        if (IsValid) then
            NotValidReason := '';
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060145, 'OnFormatForeignCardnumberFromScan', '', true, true)]
    local procedure OnFormatScannedCardNumberSubscriber(CommunityCode: Code[20]; ManagerCode: Code[20]; ScannedCardNumber: Text[100]; var FormattedCardNumber: Text[100]; var IsHandled: Boolean)
    var
        ForeignMembershipSetup: Record "NPR MM Foreign Members. Setup";
    begin

        if (ManagerCode <> GetManagerCode()) then
            exit;

        IsHandled := true;

        ForeignMembershipSetup.Get(CommunityCode, ManagerCode);
        FormattedCardNumber := AddLocalPrefix(ForeignMembershipSetup."Append Local Prefix", RemoveLocalPrefix(ForeignMembershipSetup."Remove Local Prefix", ScannedCardNumber));
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060145, 'OnShowSetup', '', true, true)]
    local procedure OnShowSetupSubscriber(CommunityCode: Code[20]; ManagerCode: Code[20])
    var
        NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup";
        ForeignMembershipSetup: Record "NPR MM Foreign Members. Setup";
        NPREndpointSetupPage: Page "NPR MM NPR Endpoint Setup";
        Choice: Integer;
        NPRLoyaltyWizard: Codeunit "NPR MM NRP Loyalty Wizard";
    begin

        if (ManagerCode <> GetManagerCode()) then
            exit;

        Choice := StrMenu('View Endpoints,Cross Company Loyalty Client Setup', 1, 'Make your selection:');

        case Choice of
            1:
                begin
                    NPRRemoteEndpointSetup.SetFilter("Community Code", '=%1', CommunityCode);
                    NPREndpointSetupPage.SetTableView(NPRRemoteEndpointSetup);
                    NPREndpointSetupPage.Run();
                end;

            2:
                begin
                    ForeignMembershipSetup.Get(CommunityCode, GetManagerCode());
                    NPRLoyaltyWizard.SetCommunityCode(CommunityCode, ForeignMembershipSetup."Append Local Prefix");
                    NPRLoyaltyWizard.Run();
                end;
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, 6060145, 'OnShowDashboard', '', true, true)]
    local procedure OnShowDashboardSubscriber(CommunityCode: Code[20]; ManagerCode: Code[20])
    begin

        if (ManagerCode <> GetManagerCode()) then
            exit;

        // No dashboard yet
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060145, 'OnSynchronizeLoyaltyPoints', '', true, true)]
    local procedure OnSynchronizeLoyaltyPointsSubscriber(CommunityCode: Code[20]; ManagerCode: Code[20]; MembershipEntryNo: Integer; ScannedCardNumber: Text[100])
    var
        IsValid: Boolean;
        NotValidReason: Text;
    begin

        if (ManagerCode <> GetManagerCode()) then
            exit;

        SynchronizeLoyaltyPointsWorker(CommunityCode, MembershipEntryNo, ScannedCardNumber, IsValid, NotValidReason);

    end;

    local procedure SynchronizeLoyaltyPointsWorker(CommunityCode: Code[20]; MembershipEntryNo: Integer; ForeignMemberCardNumber: Text[100]; var IsValid: Boolean; var NotValidReason: Text)
    var
        ForeignMembershipSetup: Record "NPR MM Foreign Members. Setup";
        NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup";
    begin

        NPRRemoteEndpointSetup.SetFilter("Community Code", '=%1', CommunityCode);
        NPRRemoteEndpointSetup.SetFilter(Type, '=%1', NPRRemoteEndpointSetup.Type::LoyaltyServices);
        NPRRemoteEndpointSetup.SetFilter(Disabled, '=%1', false);
        if (not NPRRemoteEndpointSetup.FindFirst()) then
            exit;

        ForeignMembershipSetup.Get(CommunityCode, GetManagerCode());
        ForeignMemberCardNumber := RemoveLocalPrefix(ForeignMembershipSetup."Remove Local Prefix", ForeignMemberCardNumber);

        IsValid := UpdateLocalMembershipPoints(NPRRemoteEndpointSetup, MembershipEntryNo, ForeignMembershipSetup."Append Local Prefix",
            ForeignMemberCardNumber, NotValidReason);
    end;

    procedure IsForeignMembershipCommunity(MembershipCode: Code[20]): Boolean
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup";
    begin

        if (not MembershipSetup.Get(MembershipCode)) then
            exit(false);

        NPRRemoteEndpointSetup.SetFilter("Community Code", '=%1', MembershipSetup."Community Code");
        NPRRemoteEndpointSetup.SetFilter(Type, '=%1', NPRRemoteEndpointSetup.Type::MemberServices);
        NPRRemoteEndpointSetup.SetFilter(Disabled, '=%1', false);

        exit(NPRRemoteEndpointSetup.FindFirst());

    end;

    procedure CreateRemoteMembership(CommunityCode: Code[20]; var MemberInfoCapture: Record "NPR MM Member Info Capture"; var NotValidReason: Text) IsValid: Boolean
    var
        NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup";
    begin

        NPRRemoteEndpointSetup.SetFilter("Community Code", '=%1', CommunityCode);
        NPRRemoteEndpointSetup.SetFilter(Type, '=%1', NPRRemoteEndpointSetup.Type::MemberServices);
        NPRRemoteEndpointSetup.SetFilter(Disabled, '=%1', false);
        if (not NPRRemoteEndpointSetup.FindFirst()) then
            exit(false);

        IsValid := CreateRemoteMembershipWorker(NPRRemoteEndpointSetup, MemberInfoCapture, NotValidReason);

    end;

    procedure CreateRemoteMember(CommunityCode: Code[20]; var MemberInfoCapture: Record "NPR MM Member Info Capture"; var NotValidReason: Text) IsValid: Boolean
    var
        NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup";
    begin

        NPRRemoteEndpointSetup.SetFilter("Community Code", '=%1', CommunityCode);
        NPRRemoteEndpointSetup.SetFilter(Type, '=%1', NPRRemoteEndpointSetup.Type::MemberServices);
        NPRRemoteEndpointSetup.SetFilter(Disabled, '=%1', false);
        if (not NPRRemoteEndpointSetup.FindFirst()) then
            exit(false);

        IsValid := CreateRemoteMemberWorker(NPRRemoteEndpointSetup, MemberInfoCapture, NotValidReason);

    end;


    local procedure AddLocalPrefix(Prefix: Text; String: Text): Text
    begin

        exit(StrSubstNo('%1%2', Prefix, String));
    end;

    local procedure RemoveLocalPrefix(Prefix: Text; String: Text) NewString: Text
    begin

        NewString := String;

        if (StrLen(Prefix) = 0) then
            exit(NewString);

        if (StrLen(Prefix) > StrLen(String)) then
            exit(NewString);

        if (CopyStr(String, 1, StrLen(Prefix)) = Prefix) then
            NewString := CopyStr(String, StrLen(Prefix) + 1);

        exit(NewString);
    end;

    local procedure ValidateForeignMemberCard(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; ForeignMemberCardNumber: Text[100]; var IsValid: Boolean; var NotValidReason: Text)
    var
        ForeignMembershipSetup: Record "NPR MM Foreign Members. Setup";
        RemoteInfoCapture: Record "NPR MM Member Info Capture";
        Prefix: Code[10];
    begin

        if (not ForeignMembershipSetup.Get(NPRRemoteEndpointSetup."Community Code", GetManagerCode())) then
            exit;

        if (ForeignMembershipSetup.Disabled) then
            exit;

        IsValid := false;
        Prefix := ForeignMembershipSetup."Append Local Prefix";

        IsValid := ValidateRemoteCardNumber(NPRRemoteEndpointSetup, Prefix, ForeignMemberCardNumber, RemoteInfoCapture, NotValidReason);
        if (not IsValid) then
            exit;
    end;

    local procedure ReplicateMembership(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; ForeignMemberCardNumber: Text[100]; var IsValid: Boolean; var NotValidReason: Text)
    var
        ForeignMembershipNumber: Code[20];
        ForeignMembershipSetup: Record "NPR MM Foreign Members. Setup";
        RemoteInfoCapture: Record "NPR MM Member Info Capture";
        MembershipSetup: Record "NPR MM Membership Setup";
        Prefix: Code[10];
    begin

        if (not ForeignMembershipSetup.Get(NPRRemoteEndpointSetup."Community Code", GetManagerCode())) then
            exit;

        if (ForeignMembershipSetup.Disabled) then
            exit;

        IsValid := false;
        Prefix := ForeignMembershipSetup."Append Local Prefix";

        if (not GetRemoteMembership(NPRRemoteEndpointSetup, Prefix, ForeignMemberCardNumber, ForeignMembershipNumber, RemoteInfoCapture, NotValidReason)) then
            exit;

        RemoteInfoCapture."External Card No." := Prefix + ForeignMemberCardNumber;
        if (StrLen(ForeignMemberCardNumber) >= 4) then
            RemoteInfoCapture."External Card No. Last 4" := CopyStr(ForeignMemberCardNumber, StrLen(ForeignMemberCardNumber) - 4 + 1);

        MembershipSetup.Get(RemoteInfoCapture."Membership Code");
        if (MembershipSetup."Member Information" = MembershipSetup."Member Information"::NAMED) then
            if (not (GetRemoteMember(NPRRemoteEndpointSetup, ForeignMemberCardNumber, ForeignMembershipNumber, RemoteInfoCapture, NotValidReason))) then
                exit;

        //CreateMembership (RemoteInfoCapture, NotValidReason);
        IsValid := CreateLocalMembership(RemoteInfoCapture);

    end;

    local procedure ValidateRemoteCardNumber(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; Prefix: Code[10]; ForeignMemberCardNumber: Text[100]; var RemoteInfoCapture: Record "NPR MM Member Info Capture"; var NotValidReason: Text) IsValid: Boolean
    var
        SoapAction: Text;
        XmlDocRequest: XmlDocument;
        XmlDocResponse: XmlDocument;
    begin

        MemberCardNumberValidationRequest(ForeignMemberCardNumber, '', SoapAction, XmlDocRequest);
        if (not WebServiceApi(NPRRemoteEndpointSetup, SoapAction, NotValidReason, XmlDocRequest, XmlDocResponse)) then
            exit(false);

        IsValid := MemberCardNumberValidationResponse(Prefix, ForeignMemberCardNumber, XmlDocResponse, NotValidReason, RemoteInfoCapture);

        if (not IsValid) then
            if (NotValidReason = '') then
                NotValidReason := StrSubstNo(MemberCardValidation, SoapAction, NPRRemoteEndpointSetup."Endpoint URI", ForeignMemberCardNumber);

        exit(IsValid);
    end;

    local procedure GetRemoteMembership(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; Prefix: Code[10]; ForeignMemberCardNumber: Text[100]; var ForeignMembershipNumber: Code[20]; var RemoteInfoCapture: Record "NPR MM Member Info Capture"; var NotValidReason: Text) IsValid: Boolean
    var
        SoapAction: Text;
        XmlDocRequest: XmlDocument;
        XmlDocResponse: XmlDocument;
    begin
        GetMembershipRequest(ForeignMemberCardNumber, '', SoapAction, XmlDocRequest);
        if (not WebServiceApi(NPRRemoteEndpointSetup, SoapAction, NotValidReason, XmlDocRequest, XmlDocResponse)) then
            exit(false);

        IsValid := GetMembershipResponse(Prefix, ForeignMembershipNumber, XmlDocResponse, NotValidReason, RemoteInfoCapture);

        if (StrLen(RemoteInfoCapture."External Card No.") >= 4) then
            RemoteInfoCapture."External Card No. Last 4" := CopyStr(RemoteInfoCapture."External Card No.", StrLen(RemoteInfoCapture."External Card No.") - 4 + 1);

        exit(IsValid);
    end;

    local procedure GetRemoteMember(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; ForeignMemberCardNumber: Text[100]; ForeignMembershipNumber: Code[20]; var RemoteInfoCapture: Record "NPR MM Member Info Capture"; var NotValidReason: Text) IsValid: Boolean
    var
        SoapAction: Text;
        XmlDocRequest: XmlDocument;
        XmlDocResponse: XmlDocument;
    begin
        GetMembershipMemberRequest(ForeignMembershipNumber, ForeignMemberCardNumber, '', SoapAction, XmlDocRequest);
        if (not WebServiceApi(NPRRemoteEndpointSetup, SoapAction, NotValidReason, XmlDocRequest, XmlDocResponse)) then
            exit(false);

        IsValid := GetMembershipMemberResponse(XmlDocResponse, NotValidReason, RemoteInfoCapture);

        exit(IsValid);
    end;

    local procedure CreateLocalMembership(MemberInfoCapture: Record "NPR MM Member Info Capture"): Boolean
    var
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
    begin

        MembershipSalesSetup."Membership Code" := MemberInfoCapture."Membership Code";

        MembershipSalesSetup."Valid From Base" := MembershipSalesSetup."Valid From Base"::SALESDATE;
        MemberInfoCapture."Document Date" := Today();
        MemberInfoCapture."Valid Until" := Today();
        MembershipSalesSetup."Valid Until Calculation" := MembershipSalesSetup."Valid Until Calculation"::DATEFORMULA;
        Evaluate(MembershipSalesSetup."Duration Formula", '<+0D>');

        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::FOREIGN;
        exit(0 <> MembershipManagement.CreateMembershipAll(MembershipSalesSetup, MemberInfoCapture, true));
    end;

    local procedure UpdateLocalMembershipPoints(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; MembershipEntryNo: Integer; Prefix: Code[10]; ForeignMemberCardNumber: Text[100]; var NotValidReason: Text) IsValid: Boolean
    var
        SoapAction: Text;
        XmlDocRequest: XmlDocument;
        XmlDocResponse: XmlDocument;
        ForeignMembershipNumber: Code[20];
        RemoteInfoCapture: Record "NPR MM Member Info Capture";
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
    begin

        if (MembershipEntryNo = 0) then
            exit(false);

        GetLoyaltyPointRequest(ForeignMemberCardNumber, SoapAction, XmlDocRequest);
        if (not WebServiceApi(NPRRemoteEndpointSetup, SoapAction, NotValidReason, XmlDocRequest, XmlDocResponse)) then
            exit(false);

        IsValid := GetLoyaltyPointResponse(Prefix, ForeignMembershipNumber, XmlDocResponse, NotValidReason, RemoteInfoCapture);

        if (IsValid) then
            LoyaltyPointManagement.SynchronizePointsAbsolute(MembershipEntryNo, Round(RemoteInfoCapture."Initial Loyalty Point Count", 1, '<'), Today);

        exit(IsValid);
    end;

    local procedure CreateRemoteMembershipWorker(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; var MembershipInfo: Record "NPR MM Member Info Capture"; var NotValidReason: Text) IsValid: Boolean
    var
        ScannerStationId: Text;
        SoapAction: Text;
        XmlDocRequest: XmlDocument;
        XmlDocResponse: XmlDocument;
    begin

        ScannerStationId := '';

        CreateMembershipSoapXmlRequest(MembershipInfo, ScannerStationId, SoapAction, XmlDocRequest);
        if (not WebServiceApi(NPRRemoteEndpointSetup, SoapAction, NotValidReason, XmlDocRequest, XmlDocResponse)) then
            exit(false);

        IsValid := EvaluateCreateMembershipSoapXmlResponse(MembershipInfo, NotValidReason, XmlDocResponse);
        exit(IsValid);

    end;

    local procedure CreateRemoteMemberWorker(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; var MembershipInfo: Record "NPR MM Member Info Capture"; var NotValidReason: Text) IsValid: Boolean
    var
        ScannerStationId: Text;
        SoapAction: Text;
        XmlDocRequest: XmlDocument;
        XmlDocResponse: XmlDocument;
    begin
        ScannerStationId := '';
        CreateMemberSoapXmlRequest(MembershipInfo, ScannerStationId, SoapAction, XmlDocRequest);
        if (not WebServiceApi(NPRRemoteEndpointSetup, SoapAction, NotValidReason, XmlDocRequest, XmlDocResponse)) then
            exit(false);

        IsValid := EvaluateCreateMemberSoapXmlResponse(MembershipInfo, NotValidReason, XmlDocResponse);
        exit(IsValid);

    end;


    procedure WebServiceApi(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; SoapAction: Text; var ReasonText: Text; var XmlDocIn: XmlDocument; var XmlDocOut: XmlDocument): Boolean
    begin

        ReasonText := '';
        if (TryWebServiceApi(NPRRemoteEndpointSetup, SoapAction, ReasonText, XmlDocIn, XmlDocOut)) then
            exit(true);

        if (ReasonText = '') then
            ReasonText := GetLastErrorText();
        exit(false);

    end;

    [TryFunction]
    internal procedure TryWebServiceApi(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; SoapAction: Text; var ReasonText: Text; var XmlDocIn: XmlDocument; var XmlDocOut: XmlDocument)
    var
        WebRequest: HttpRequestMessage;
        WebResponse: HttpResponseMessage;
        WebClient: HttpClient;
        Headers: HttpHeaders;
        ResponseText: Text;
        B64Credential: Text;
        Base64Convert: Codeunit "Base64 Convert";
    begin
        ReasonText := '';
        WebRequest.SetRequestUri(NPRRemoteEndpointSetup."Endpoint URI");
        WebClient.Timeout := NPRRemoteEndpointSetup."Connection Timeout (ms)";
        WebRequest.GetHeaders(Headers);

        case NPRRemoteEndpointSetup."Credentials Type" of
            NPRRemoteEndpointSetup."Credentials Type"::NAMED:
                begin
                    if (NPRRemoteEndpointSetup."User Domain" <> '') then
                        WebClient.UseWindowsAuthentication(NPRRemoteEndpointSetup."User Account", NPRRemoteEndpointSetup."User Password", NPRRemoteEndpointSetup."User Domain")
                    else
                        WebClient.UseWindowsAuthentication(NPRRemoteEndpointSetup."User Account", NPRRemoteEndpointSetup."User Password");
                end;

            NPRRemoteEndpointSetup."Credentials Type"::BASIC:
                begin
                    B64Credential := Base64Convert.ToBase64(StrSubstNo('%1:%2', NPRRemoteEndpointSetup."User Account", NPRRemoteEndpointSetup."User Password"));
                    if Headers.Contains('Authorization') then
                        Headers.Remove('Authorization');
                    Headers.Add('Authorization', StrSubstNo('Basic %1', B64Credential));
                end;
        end;

        WebRequest.Method := 'POST';
        if Headers.Contains('Content-Type') then
            Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'text/xml; charset=utf-8');
        if Headers.Contains('SOAPAction') then
            Headers.Remove('SOAPAction');
        Headers.Add('SOAPAction', SoapAction);

        WebClient.Send(WebRequest, WebResponse);
        if WebResponse.IsSuccessStatusCode then begin
            WebResponse.Content.ReadAs(ResponseText);
            XmlDocument.ReadFrom(ResponseText, XmlDocOut);
            exit;
        end;

        ReasonText := WebResponse.ReasonPhrase;
        Error('%1', ReasonText);
    end;

    procedure MemberCardNumberValidationRequest(ExternalMemberCardNumber: Text[100]; ScannerStationId: Text; var SoapAction: Text[50]; var XmlDoc: XmlDocument)
    var
        XmlRequest: Text;
    begin
        SoapAction := 'MemberCardNumberValidation';
        XmlRequest :=
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:mem="urn:microsoft-dynamics-schemas/codeunit/member_services">' +
          '   <soapenv:Header/>' +
          '   <soapenv:Body>' +
          '      <mem:MemberCardNumberValidation>' +
          '         <mem:externalMemberCardNo>%1</mem:externalMemberCardNo>' +
          '         <mem:scannerStationId>%2</mem:scannerStationId>' +
          '      </mem:MemberCardNumberValidation>' +
          '   </soapenv:Body>' +
          '</soapenv:Envelope>';
        XmlRequest := StrSubstNo(XmlRequest, ExternalMemberCardNumber, ScannerStationId);
        XmlDocument.ReadFrom(XmlRequest, XmlDoc);
    end;

    local procedure MemberCardNumberValidationResponse(Prefix: Code[10]; ForeignMemberCardNumber: Text[100]; var XmlDoc: XmlDocument; var ResponseText: Text; var MemberInfoCapture: Record "NPR MM Member Info Capture"): Boolean
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        Element: XmlElement;
        TextOk: Text;
        XmlText: Text;
        XmlDomMgt: Codeunit "XML DOM Management";
    begin
        XmlDoc.WriteTo(XmlText);
        XmlDomMgt.RemoveNameSpaces(XmlText);
        XmlDocument.ReadFrom(XmlText, XmlDoc);

        if not XmlDoc.GetRoot(Element) then begin
            ResponseText := StrSubstNo(InvalidXml, NpXmlDomMgt.PrettyPrintXml(XmlText));
            exit(false);
        end;

        TextOk := NpXmlDomMgt.GetXmlText(Element, '//MemberCardNumberValidation_Result/return_value', 5, false);
        MemberInfoCapture."External Card No." := Prefix + ForeignMemberCardNumber;
        if (StrLen(ForeignMemberCardNumber) >= 4) then
            MemberInfoCapture."External Card No. Last 4" := CopyStr(ForeignMemberCardNumber, StrLen(ForeignMemberCardNumber) - 4 + 1);

        exit(UpperCase(TextOk) = 'TRUE');
    end;

    local procedure GetMembershipRequest(ExternalMemberCardNumber: Text[100]; ScannerStationId: Text; var SoapAction: Text[50]; var XmlDoc: XmlDocument)
    var
        XmlRequest: Text;
    begin

        SoapAction := 'GetMembership';
        XmlRequest :=
         '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:mem="urn:microsoft-dynamics-schemas/codeunit/member_services">' +
         '   <soapenv:Header/>' +
         '   <soapenv:Body>' +
         '      <mem:GetMembership>' +
         '         <mem:membership>' +
         '            <getmembership>' +
         '               <request>' +
         '                  <membernumber></membernumber>' +
         '                  <cardnumber>%1</cardnumber>' +
         '                  <membershipnumber></membershipnumber>' +
         '                  <username></username>' +
         '                  <password></password>' +
         '                  <customernumber></customernumber>' +
         '               </request>' +
         '            </getmembership>' +
         '          </mem:membership>' +
         '         <mem:scannerStationId>%2</mem:scannerStationId>' +
         '      </mem:GetMembership>' +
         '   </soapenv:Body>' +
         '</soapenv:Envelope>';
        XmlRequest := StrSubstNo(XmlRequest, ExternalMemberCardNumber, ScannerStationId);
        XmlDocument.ReadFrom(XmlRequest, XmlDoc);
    end;

    local procedure GetMembershipResponse(Prefix: Code[10]; var ForeignMembershipNumber: Code[20]; var XmlDoc: XmlDocument; var ResponseText: Text; var MemberInfoCapture: Record "NPR MM Member Info Capture"): Boolean
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        Element: XmlElement;
        TextOk: Text;
        ElementPath: Text;
        XmlText: Text;
        XmlDomMgt: Codeunit "XML DOM Management";
    begin

        // <GetMembership_Result xmlns="urn:microsoft-dynamics-schemas/codeunit/member_services">
        //    <membership>
        //      <getmembership xmlns="urn:microsoft-dynamics-nav/xmlports/x6060129">
        // ...
        // <response>
        //  <status>1</status>
        //  <errordescription/>
        //  <membership>
        //      <communitycode>RIVERLAND</communitycode>
        //      <membershipcode>GOLD</membershipcode>
        //      <membershipnumber>MS-DEMO-00001</membershipnumber>
        //      <issuedate>2017-03-27</issuedate>
        //      <validfromdate>2017-03-27</validfromdate>
        //      <validuntildate>2019-03-26</validuntildate>
        //      <membercardinality>2</membercardinality>
        //      <membercount named="1" anonymous="0">1</membercount>
        //  </membership>
        // </response>

        XmlDoc.WriteTo(XmlText);
        XmlDomMgt.RemoveNameSpaces(XmlText);
        XmlDocument.ReadFrom(XmlText, XmlDoc);

        if not XmlDoc.GetRoot(Element) then begin
            ResponseText := StrSubstNo(InvalidXml, NpXmlDomMgt.PrettyPrintXml(XmlText));
            exit(false);
        end;

        ElementPath := '//GetMembership_Result/membership/getmembership/response/';
        TextOk := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'status', 5, false);
        ResponseText := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'errordescription', 1000, false);
        if (TextOk = '0') then
            exit(false);

        ElementPath := '//GetMembership_Result/membership/getmembership/response/membership/';

        MemberInfoCapture."Membership Code" := Prefix + NpXmlDomMgt.GetXmlText(Element, ElementPath + '/membershipcode', MaxStrLen(MemberInfoCapture."Membership Code"), false);
        ForeignMembershipNumber := NpXmlDomMgt.GetXmlText(Element, ElementPath + '/membershipnumber', MaxStrLen(MemberInfoCapture."External Membership No."), false);
        MemberInfoCapture."External Membership No." := Prefix + ForeignMembershipNumber;

        exit(true);
    end;

    local procedure GetMembershipMemberRequest(ExternalMembershipNumber: Code[20]; ExternalMemberCardNumber: Text[100]; ScannerStationId: Text; var SoapAction: Text[50]; var XmlDoc: XmlDocument)
    var
        XmlRequest: Text;
    begin

        SoapAction := 'GetMembershipMembers';
        XmlRequest :=
         '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:mem="urn:microsoft-dynamics-schemas/codeunit/member_services">' +
         '   <soapenv:Header/>' +
         '   <soapenv:Body>' +
         '      <mem:GetMembershipMembers>' +
         '         <mem:member>' +
         '            <getmembers>' +
         '               <request>' +
         '                  <membershipnumber>%1</membershipnumber>' +
         '                  <membernumber></membernumber>' +
         '                  <cardnumber>%2</cardnumber>' +
         '               </request>' +
         '            </getmembers>' +
         '         </mem:member>' +
         '         <mem:scannerStationId>%3</mem:scannerStationId>' +
         '      </mem:GetMembershipMembers>' +
         '   </soapenv:Body>' +
         '</soapenv:Envelope>';

        XmlRequest := StrSubstNo(XmlRequest, ExternalMembershipNumber, ExternalMemberCardNumber, ScannerStationId);
        XmlDocument.ReadFrom(XmlRequest, XmlDoc);
    end;

    local procedure GetMembershipMemberResponse(var XmlDoc: XmlDocument; var ResponseText: Text; var MemberInfoCapture: Record "NPR MM Member Info Capture"): Boolean
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        Element: XmlElement;
        TextOk: Text;
        ElementPath: Text;
        XmlText: Text;
        XmlDomMgt: Codeunit "XML DOM Management";
    begin
        // <GetMembershipMembers_Result xmlns="urn:microsoft-dynamics-schemas/codeunit/member_services">
        //    <member>
        //      <getmembers xmlns="urn:microsoft-dynamics-nav/xmlports/x6060130">
        //          <request>
        //
        // <response>
        //  <status>1</status>
        //  <errordescription/>
        //  <member role="Membership Admin">
        //      <membernumber>MM-DEMO-00001</membernumber>
        //      <firstname>Tim</firstname>
        //      <middlename/>
        //      <lastname>Sannes</lastname>
        //      <address/>
        //      <postcode/>
        //      <city/>
        //      <country/>
        //      <birthday/>
        //      <gender>0</gender>
        //      <newsletter>0</newsletter>
        //      <phoneno/>
        //      <email>test0227@test.se</email>
        //  </member>
        // </response>

        XmlDoc.WriteTo(XmlText);
        XmlDomMgt.RemoveNameSpaces(XmlText);
        XmlDocument.ReadFrom(XmlText, XmlDoc);

        if not XmlDoc.GetRoot(Element) then begin
            ResponseText := StrSubstNo(InvalidXml, NpXmlDomMgt.PrettyPrintXml(XmlText));
            exit(false);
        end;

        ElementPath := '//GetMembershipMembers_Result/member/getmembers/response/';
        TextOk := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'status', 5, false);
        ResponseText := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'errordescription', 1000, false);
        if (TextOk = '0') then
            exit(false);

        ElementPath := '//GetMembershipMembers_Result/member/getmembers/response/member/';
        MemberInfoCapture."First Name" := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'firstname', MaxStrLen(MemberInfoCapture."First Name"), false);
        MemberInfoCapture."Middle Name" := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'middlename', MaxStrLen(MemberInfoCapture."Middle Name"), false);
        MemberInfoCapture."Last Name" := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'lastname', MaxStrLen(MemberInfoCapture."Last Name"), false);
        MemberInfoCapture.Address := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'address', MaxStrLen(MemberInfoCapture.Address), false);
        MemberInfoCapture."Post Code Code" := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'postcode', MaxStrLen(MemberInfoCapture."Post Code Code"), false);
        MemberInfoCapture.City := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'city', MaxStrLen(MemberInfoCapture.City), false);
        MemberInfoCapture."Country Code" := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'country', MaxStrLen(MemberInfoCapture."Country Code"), false);

        if (Evaluate(MemberInfoCapture.Birthday, NpXmlDomMgt.GetXmlText(Element, ElementPath + 'birthday', 10, false))) then;
        if (Evaluate(MemberInfoCapture.Gender, NpXmlDomMgt.GetXmlText(Element, ElementPath + 'gender', 1, false))) then;
        if (Evaluate(MemberInfoCapture."News Letter", NpXmlDomMgt.GetXmlText(Element, ElementPath + 'newsletter', 1, false))) then;

        MemberInfoCapture."Phone No." := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'phoneno', MaxStrLen(MemberInfoCapture."Phone No."), false);
        MemberInfoCapture."E-Mail Address" := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'email', MaxStrLen(MemberInfoCapture."E-Mail Address"), false);

        exit(true);
    end;

    local procedure GetLoyaltyPointRequest(ExternalMemberCardNumber: Text[100]; var SoapAction: Text[50]; var XmlDoc: XmlDocument)
    var
        XmlRequest: Text;
    begin
        SoapAction := 'GetLoyaltyPoints';
        XmlRequest :=
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:loy="urn:microsoft-dynamics-schemas/codeunit/loyalty_services" xmlns:x60="urn:microsoft-dynamics-nav/xmlports/x6060141">' +
            '   <soapenv:Header/>' +
            '   <soapenv:Body>' +
            '      <loy:GetLoyaltyPoints>' +
            '         <loy:getLoyaltyPoints>' +
            '            <x60:getloyaltypoints>' +
            '               <x60:request>' +
            '                  <x60:cardnumber>%1</x60:cardnumber>' +
            '                  <x60:membershipnumber></x60:membershipnumber>' +
            '                  <x60:customernumber></x60:customernumber>' +
            '               </x60:request>' +
            '             </x60:getloyaltypoints>' +
            '          </loy:getLoyaltyPoints>' +
            '      </loy:GetLoyaltyPoints>' +
            '   </soapenv:Body>' +
            '</soapenv:Envelope>';
        XmlRequest := StrSubstNo(XmlRequest, ExternalMemberCardNumber);
        XmlDocument.ReadFrom(XmlRequest, XmlDoc);
    end;

    local procedure GetLoyaltyPointResponse(Prefix: Code[10]; var ForeignMembershipNumber: Code[20]; var XmlDoc: XmlDocument; var ResponseText: Text; var MemberInfoCapture: Record "NPR MM Member Info Capture"): Boolean
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        Element: XmlElement;
        TextOk: Text;
        ElementPath: Text;
        Points: Text;
        XmlText: Text;
        XmlDomMgt: Codeunit "XML DOM Management";
    begin

        //  <GetLoyaltyPoints_Result xmlns="urn:microsoft-dynamics-schemas/codeunit/loyalty_services">
        //      <getLoyaltyPoints>
        //        <getloyaltypoints xmlns="urn:microsoft-dynamics-nav/xmlports/x6060141">
        // ...
        // </response>
        //  <status>
        //      <responsecode>OK</responsecode>
        //      <responsemessage/>
        //  </status>
        //  <membership>
        //      <communitycode>LOYALTY_CC</communitycode>
        //      <membershipcode>CC01</membershipcode>
        //      <membershipnumber>MS-DEMO-00027</membershipnumber>
        //      <issuedate>2019-05-22</issuedate>
        //      <validfromdate>2019-05-22</validfromdate>
        //      <validuntildate>2020-05-21</validuntildate>
        //      <pointsummary>
        //        <awarded>
        //            <sales>3196</sales>
        //            <refund>0</refund>
        //        </awarded>
        //        <redeemed>
        //            <withdrawl>0</withdrawl>
        //            <deposit>0</deposit>
        //        </redeemed>
        //        <expired>0</expired>
        //        <remaining>3196</remaining>
        //      </pointsummary>
        //  </membership>
        // </response>

        XmlDoc.WriteTo(XmlText);
        XmlDomMgt.RemoveNameSpaces(XmlText);
        XmlDocument.ReadFrom(XmlText, XmlDoc);

        if not XmlDoc.GetRoot(Element) then begin
            ResponseText := StrSubstNo(InvalidXml, NpXmlDomMgt.PrettyPrintXml(XmlText));
            exit(false);
        end;

        ElementPath := '//GetLoyaltyPoints_Result/getLoyaltyPoints/getloyaltypoints/response/status/';
        TextOk := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'responsecode', 5, false);
        ResponseText := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'responsemessage', 1000, false);
        if (TextOk = '0') then
            exit(false);

        ElementPath := '//GetLoyaltyPoints_Result/getLoyaltyPoints/getloyaltypoints/response/membership';

        MemberInfoCapture."Membership Code" := Prefix + NpXmlDomMgt.GetXmlText(Element, ElementPath + '/membershipcode', MaxStrLen(MemberInfoCapture."Membership Code"), false);
        ForeignMembershipNumber := NpXmlDomMgt.GetXmlText(Element, ElementPath + '/membershipnumber', MaxStrLen(MemberInfoCapture."External Membership No."), false);
        MemberInfoCapture."External Membership No." := Prefix + ForeignMembershipNumber;
        Points := NpXmlDomMgt.GetXmlText(Element, ElementPath + '/pointsummary/remaining', 10, false);
        if (not Evaluate(MemberInfoCapture."Initial Loyalty Point Count", Points)) then
            MemberInfoCapture."Initial Loyalty Point Count" := 0;

        exit(true);
    end;

    procedure CreateMembershipSoapXmlRequest(MemberInfoCapture: Record "NPR MM Member Info Capture"; var ScannerStationId: Text; var SoapAction: Text[50]; var XmlDoc: XmlDocument)
    var
        XmlText: Text;
    begin
        XmlText :=
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:mem="urn:microsoft-dynamics-schemas/codeunit/member_services">' +
            '<soapenv:Header/>' +
            '<soapenv:Body>' +
                '<mem:CreateMembership>' +
                    '<mem:membership>' +
                    CreateMembershipRequest(MemberInfoCapture) +
                    '</mem:membership>' +
                    StrSubstNo('<mem:scannerStationId>%1</mem:scannerStationId>', ScannerStationId) +
                '</mem:CreateMembership>' +
            '</soapenv:Body>' +
            '</soapenv:Envelope>';
        XmlDocument.ReadFrom(XmlText, XmlDoc);
        SoapAction := 'CreateMembership';
    end;

    procedure CreateMembershipXmlPortRequest(MemberInfoCapture: Record "NPR MM Member Info Capture") XmlText: Text
    begin
        XmlText :=
            '<membership xmlns="urn:microsoft-dynamics-nav/xmlports/x6060127">' +
            CreateMembershipRequest(MemberInfoCapture) +
            '</membership>';
    end;

    local procedure CreateMembershipRequest(MemberInfoCapture: Record "NPR MM Member Info Capture") XmlText: Text
    var
        ActivationDateText: Text;
    begin
        ActivationDateText := '';
        if (MemberInfoCapture."Document Date" > 0D) then
            ActivationDateText := Format(MemberInfoCapture."Document Date", 0, 9);

        XmlText :=
            '<createmembership>' +
            '<request>' +
                StrSubstNo('<membershipsalesitem>%1</membershipsalesitem>', MemberInfoCapture."Item No.") +
                StrSubstNo('<activationdate>%1</activationdate>', ActivationDateText) +
            '</request>' +
            '</createmembership>';
    end;

    local procedure EvaluateCreateMembershipSoapXmlResponse(var MemberInfoCapture: Record "NPR MM Member Info Capture"; var NotValidReason: Text; var XmlDoc: XmlDocument): Boolean
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        Element: XmlElement;
        ResponseText: Text;
        TextOk: Text;
        ElementPath: Text;
        XmlText: Text;
        XmlDomMgt: Codeunit "XML DOM Management";
    begin

        // <response>
        //  <status>1</status>
        //  <errordescription/>
        //  <membership>
        //      <communitycode>RIVERLAND</communitycode>
        //      <membershipcode>BRONZE</membershipcode>
        //      <membershipnumber>MS-DEMO-00251</membershipnumber>
        //      <issuedate>2019-06-10</issuedate>
        //      <validfromdate/>
        //      <validuntildate/>
        //      <documentid>407F7427BF0046DB87A13F2CBE8EEE20</documentid>
        //  </membership>
        // </response>

        XmlDoc.WriteTo(XmlText);
        XmlDomMgt.RemoveNameSpaces(XmlText);
        XmlDocument.ReadFrom(XmlText, XmlDoc);

        if not XmlDoc.GetRoot(Element) then begin
            ResponseText := StrSubstNo(InvalidXml, NpXmlDomMgt.PrettyPrintXml(XmlText));
            exit(false);
        end;

        ElementPath := '//CreateMembership_Result/membership/createmembership/response/';
        TextOk := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'status', 5, true);
        NotValidReason := StrSubstNo('Message from Server: %1', NpXmlDomMgt.GetXmlText(Element, ElementPath + 'errordescription', 1000, true));
        if (TextOk = '0') then
            exit(false);

        ElementPath := '//CreateMembership_Result/membership/createmembership/response/membership/';

        MemberInfoCapture."Membership Code" := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'membershipcode',
            MaxStrLen(MemberInfoCapture."Membership Code"), false);
        MemberInfoCapture."External Membership No." := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'membershipnumber',
            MaxStrLen(MemberInfoCapture."External Membership No."), false);

        NotValidReason := '';
        exit(true);
    end;

    local procedure CreateMemberSoapXmlRequest(MemberInfoCapture: Record "NPR MM Member Info Capture"; var ScannerStationId: Text; var SoapAction: Text[50]; var XmlDoc: XmlDocument)
    var
        XmlText: Text;
    begin
        XmlText :=
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:mem="urn:microsoft-dynamics-schemas/codeunit/member_services">' +
            '<soapenv:Header/>' +
            '<soapenv:Body>' +
                '<mem:AddMembershipMember>' +
                    '<mem:member>' +
                        CreateMemberRequest(MemberInfoCapture) +
                    '</mem:member>' +
                    StrSubstNo('<mem:scannerStationId>%1</mem:scannerStationId>', ScannerStationId) +
                '</mem:AddMembershipMember>' +
            '</soapenv:Body>' +
            '</soapenv:Envelope>';

        SoapAction := 'AddMembershipMember';
        XmlDocument.ReadFrom(XmlText, XmlDoc);
    end;

    local procedure CreateMemberRequest(MemberInfoCapture: Record "NPR MM Member Info Capture") XmlText: Text
    var
        MemberCardXml: Text;
        GuardianXml: Text;
        DateText: Text;
    begin

        MemberCardXml := '';
        DateText := '1754-01-01';
        if (MemberInfoCapture."Valid Until" > 0D) then
            DateText := Format(MemberInfoCapture."Valid Until", 0, 9);

        if (MemberInfoCapture."External Card No." <> '') then
            MemberCardXml :=
              '<membercard>' +
                  StrSubstNo('<cardnumber>%1</cardnumber>', XmlSafe(MemberInfoCapture."External Card No.")) +
                  StrSubstNo('<is_permanent>%1</is_permanent>', Format(MemberInfoCapture."Temporary Member Card", 0, 9)) +
                  StrSubstNo('<valid_until>%1</valid_until>', DateText) +
              '</membercard>';

        GuardianXml := '';
        if (MemberInfoCapture."Guardian External Member No." <> '') then
            GuardianXml :=
              '<guardian>' +
                StrSubstNo('<membernumber>%1</membernumber>', XmlSafe(MemberInfoCapture."Guardian External Member No.")) +
                StrSubstNo('<email>%1</email>', MemberInfoCapture."E-Mail Address") +
              '</guardian>';

        DateText := '1754-01-01';
        if (MemberInfoCapture.Birthday > 0D) then
            DateText := Format(MemberInfoCapture.Birthday, 0, 9);

        XmlText :=
        '<addmember>' +
          '<request>' +
            StrSubstNo('<membershipnumber>%1</membershipnumber>', XmlSafe(MemberInfoCapture."External Membership No.")) +
            StrSubstNo('<firstname>%1</firstname>', XmlSafe(MemberInfoCapture."First Name")) +
            StrSubstNo('<middlename>%1</middlename>', XmlSafe(MemberInfoCapture."Middle Name")) +
            StrSubstNo('<lastname>%1</lastname>', XmlSafe(MemberInfoCapture."Last Name")) +
            StrSubstNo('<address>%1</address>', XmlSafe(MemberInfoCapture.Address)) +
            StrSubstNo('<postcode>%1</postcode>', XmlSafe(MemberInfoCapture."Post Code Code")) +
            StrSubstNo('<city>%1</city>', XmlSafe(MemberInfoCapture.City)) +
            StrSubstNo('<country>%1</country>', XmlSafe(MemberInfoCapture."Country Code")) +
            StrSubstNo('<phoneno>%1</phoneno>', XmlSafe(MemberInfoCapture."Phone No.")) +
            StrSubstNo('<email>%1</email>', XmlSafe(MemberInfoCapture."E-Mail Address")) +
            StrSubstNo('<birthday>%1</birthday>', DateText) +
            StrSubstNo('<gender>%1</gender>', Format(MemberInfoCapture.Gender, 0, 9)) +
            StrSubstNo('<newsletter>%1</newsletter>', Format(MemberInfoCapture."News Letter", 0, 0)) +
            StrSubstNo('<username>%1</username>', XmlSafe(MemberInfoCapture."User Logon ID")) +
            StrSubstNo('<password>%1</password>', XmlSafe(MemberInfoCapture."Password SHA1")) +
            MemberCardXml +
            GuardianXml +
            StrSubstNo('<gdpr_approval>%1</gdpr_approval>', Format(MemberInfoCapture."GDPR Approval", 0, 9)) +
          '</request>' +
        '</addmember>';

    end;

    local procedure EvaluateCreateMemberSoapXmlResponse(var MemberInfoCapture: Record "NPR MM Member Info Capture"; var NotValidReason: Text; var XmlDoc: XmlDocument): Boolean
    var
        DateText: Text;
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        Element: XmlElement;
        ResponseText: Text;
        TextOk: Text;
        ElementPath: Text;
        XmlText: Text;
        XmlDomMgt: Codeunit "XML DOM Management";
    begin

        // <AddMembershipMember_Result xmlns="urn:microsoft-dynamics-schemas/codeunit/member_services">
        //   <member>
        //     <addmember xmlns="urn:microsoft-dynamics-nav/xmlports/x6060128">
        //
        // <response>
        //   <status>1</status>
        //   <errordescription/>
        //   <member>
        //      <membernumber>MM-DEMO-00025</membernumber>
        //      <email>0830.04@test.se</email>
        //      <card>
        //        <cardnumber>XC000005</cardnumber>
        //        <expirydate>2020-06-10</expirydate>
        //      </card>
        //   </member>
        // </response>

        XmlDoc.WriteTo(XmlText);
        XmlDomMgt.RemoveNameSpaces(XmlText);
        XmlDocument.ReadFrom(XmlText, XmlDoc);

        if not XmlDoc.GetRoot(Element) then begin
            ResponseText := StrSubstNo(InvalidXml, NpXmlDomMgt.PrettyPrintXml(XmlText));
            exit(false);
        end;

        ElementPath := '//AddMembershipMember_Result/member/addmember/response/';
        TextOk := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'status', 5, true);
        NotValidReason := StrSubstNo('Message from Server: %1', NpXmlDomMgt.GetXmlText(Element, ElementPath + 'errordescription', 1000, true));
        if (TextOk = '0') then
            exit(false);

        ElementPath := '//AddMembershipMember_Result/member/addmember/response/member/';
        MemberInfoCapture."External Member No" := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'membernumber', MaxStrLen(MemberInfoCapture."External Member No"), false);
        MemberInfoCapture."External Card No." := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'cardnumber', MaxStrLen(MemberInfoCapture."External Card No."), false);
        DateText := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'expirydate', 10, false);
        if (not Evaluate(MemberInfoCapture."Valid Until", DateText, 9)) then
            MemberInfoCapture."Valid Until" := 0D;

        NotValidReason := '';
        exit(true);
    end;

    procedure XmlSafe(InText: Text): Text
    begin
        exit(DelChr(InText, '<=>', '<>&/'));
    end;
}
#pragma warning restore