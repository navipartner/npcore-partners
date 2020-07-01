codeunit 6060147 "MM NPR Membership"
{
    // MM1.23/TSA /20171002 CASE 257011 NPR implementation of foreign memberships and loyalty
    // MM1.37/TSA /20190301 CASE 343053 Checking that type is used form NPR Remote Endpoint
    // MM1.38/TSA /20190522 CASE 338215 Corrected the return code from CreateMembership
    // MM1.38/TSA /20190523 CASE 338215 Added the wizard on setup subscriber
    // MM1.40/TSA /20190604 CASE 357360 Reused of the WebServiceAPI() - Added the BASIC authentication for compatibility, improved error handling
    // MM1.40/TSA /20190610 CASE 357360 Added CreateRemoteMembership() and subfunctions


    trigger OnRun()
    begin
    end;

    var
        NotSupportedVersion: Label 'A request for %1 was made for %2, %3 with message version %4. That version is not handled in %5 %6.';
        InvalidXml: Label 'An invalid XML was returned:\%1';
        MemberCardValidation: Label 'Service %1 at %2 could not validate membercard %3.';

    [EventSubscriber(ObjectType::Codeunit, 6060145, 'OnDiscoverExternalMembershipMgr', '', true, true)]
    local procedure OnDiscover(var Sender: Record "MM Foreign Membership Setup")
    begin

        Sender.RegisterManager(GetManagerCode(), 'NaviPartner Foreign NPR Membership Management');
    end;

    local procedure GetManagerCode(): Code[20]
    begin
        exit('NPR_MEMBER');
    end;

    local procedure "--Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060145, 'OnDispatchToReplicateForeignMemberCard', '', true, true)]
    local procedure OnValidateAndReplicateForeignMemberCardSubscriber(CommunityCode: Code[20]; ManagerCode: Code[20]; ForeignMembercardNumber: Text[100]; var IsValid: Boolean; var NotValidReason: Text; var IsHandled: Boolean)
    var
        ForeignMembershipSetup: Record "MM Foreign Membership Setup";
        NPRRemoteEndpointSetup: Record "MM NPR Remote Endpoint Setup";
        SoapAction: Text;
        NoPrefixForeignMembercardNumber: Text[100];
        XmlDocRequest: DotNet npNetXmlDocument;
        XmlDocResponse: DotNet npNetXmlDocument;
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
        //-MM1.40 [357360]
        //ForeignMembercardNumber := RemoveLocalPrefix (ForeignMembershipSetup."Remove Local Prefix", ForeignMembercardNumber);
        NoPrefixForeignMembercardNumber := RemoveLocalPrefix(ForeignMembershipSetup."Remove Local Prefix", ForeignMembercardNumber);
        //+MM1.40 [357360]

        ValidateForeignMemberCard(NPRRemoteEndpointSetup, NoPrefixForeignMembercardNumber, IsValid, NotValidReason);
        if (IsValid) then
            ReplicateMembership(NPRRemoteEndpointSetup, NoPrefixForeignMembercardNumber, IsValid, NotValidReason);

        //-MM1.40 [357360]
        if (not IsValid) then
            if (NoPrefixForeignMembercardNumber <> ForeignMembercardNumber) then
                Error(NotValidReason);

        if (IsValid) then
            NotValidReason := '';
        //+MM1.40 [357360]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060145, 'OnFormatForeignCardnumberFromScan', '', true, true)]
    local procedure OnFormatScannedCardnumberSubscriber(CommunityCode: Code[20]; ManagerCode: Code[20]; ScannedCardNumber: Text[100]; var FormattedCardNumber: Text[50]; var IsHandled: Boolean)
    var
        ForeignMembershipSetup: Record "MM Foreign Membership Setup";
    begin

        if (ManagerCode <> GetManagerCode()) then
            exit;

        IsHandled := true;

        ForeignMembershipSetup.Get(CommunityCode, ManagerCode);

        FormattedCardNumber := AddLocalPrefix(ForeignMembershipSetup."Append Local Prefix",
                                 RemoveLocalPrefix(ForeignMembershipSetup."Remove Local Prefix", ScannedCardNumber));
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060145, 'OnShowSetup', '', true, true)]
    local procedure OnShowSetupSubscriber(CommunityCode: Code[20]; ManagerCode: Code[20])
    var
        NPRRemoteEndpointSetup: Record "MM NPR Remote Endpoint Setup";
        ForeignMembershipSetup: Record "MM Foreign Membership Setup";
        NPREndpointSetupPage: Page "MM NPR Endpoint Setup";
        Choice: Integer;
        NPRLoyaltyWizard: Codeunit "MM NRP Loyalty Wizard";
    begin

        if (ManagerCode <> GetManagerCode()) then
            exit;

        //-MM1.38 [338215]
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
        //+MM1.38 [338215]
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

        //-MM1.38 [338215]
        if (ManagerCode <> GetManagerCode()) then
            exit;

        SynchronizeLoyaltyPointsWorker(CommunityCode, MembershipEntryNo, ScannedCardNumber, IsValid, NotValidReason);
        //+MM1.38 [338215]
    end;

    local procedure SynchronizeLoyaltyPointsWorker(CommunityCode: Code[20]; MembershipEntryNo: Integer; ForeignMembercardNumber: Text[100]; var IsValid: Boolean; var NotValidReason: Text)
    var
        ForeignMembershipSetup: Record "MM Foreign Membership Setup";
        NPRRemoteEndpointSetup: Record "MM NPR Remote Endpoint Setup";
        SoapAction: Text;
        XmlDocRequest: DotNet npNetXmlDocument;
        XmlDocResponse: DotNet npNetXmlDocument;
        CustomerNumber: Text[30];
        CardNumber: Text[30];
        CustomerName: Text[50];
    begin

        //-MM1.38 [338215]
        NPRRemoteEndpointSetup.SetFilter("Community Code", '=%1', CommunityCode);
        NPRRemoteEndpointSetup.SetFilter(Type, '=%1', NPRRemoteEndpointSetup.Type::LoyaltyServices);
        NPRRemoteEndpointSetup.SetFilter(Disabled, '=%1', false);
        if (not NPRRemoteEndpointSetup.FindFirst()) then
            exit;

        ForeignMembershipSetup.Get(CommunityCode, GetManagerCode());
        ForeignMembercardNumber := RemoveLocalPrefix(ForeignMembershipSetup."Remove Local Prefix", ForeignMembercardNumber);

        IsValid := UpdateLocalMembershipPoints(NPRRemoteEndpointSetup, MembershipEntryNo, ForeignMembershipSetup."Append Local Prefix", ForeignMembercardNumber, NotValidReason);
        //+MM1.38 [338215]
    end;

    procedure IsForeignMembershipCommunity(MembershipCode: Code[20]): Boolean
    var
        MembershipSetup: Record "MM Membership Setup";
        MemberCommunity: Record "MM Member Community";
        NPRRemoteEndpointSetup: Record "MM NPR Remote Endpoint Setup";
    begin

        //-MM1.40 [357360]
        if (not MembershipSetup.Get(MembershipCode)) then
            exit(false);

        NPRRemoteEndpointSetup.SetFilter("Community Code", '=%1', MembershipSetup."Community Code");
        NPRRemoteEndpointSetup.SetFilter(Type, '=%1', NPRRemoteEndpointSetup.Type::MemberServices);
        NPRRemoteEndpointSetup.SetFilter(Disabled, '=%1', false);

        exit(NPRRemoteEndpointSetup.FindFirst());
        //+MM1.40 [357360]
    end;

    procedure CreateRemoteMembership(CommunityCode: Code[20]; var MemberInfoCapture: Record "MM Member Info Capture"; var NotValidReason: Text) IsValid: Boolean
    var
        NPRRemoteEndpointSetup: Record "MM NPR Remote Endpoint Setup";
    begin

        //-MM1.40 [357360]
        NPRRemoteEndpointSetup.SetFilter("Community Code", '=%1', CommunityCode);
        NPRRemoteEndpointSetup.SetFilter(Type, '=%1', NPRRemoteEndpointSetup.Type::MemberServices);
        NPRRemoteEndpointSetup.SetFilter(Disabled, '=%1', false);
        if (not NPRRemoteEndpointSetup.FindFirst()) then
            exit(false);

        IsValid := CreateRemoteMembershipWorker(NPRRemoteEndpointSetup, MemberInfoCapture, NotValidReason);
        //+MM1.40 [357360]
    end;

    procedure CreateRemoteMember(CommunityCode: Code[20]; var MemberInfoCapture: Record "MM Member Info Capture"; var NotValidReason: Text) IsValid: Boolean
    var
        NPRRemoteEndpointSetup: Record "MM NPR Remote Endpoint Setup";
    begin

        //-MM1.40 [357360]
        NPRRemoteEndpointSetup.SetFilter("Community Code", '=%1', CommunityCode);
        NPRRemoteEndpointSetup.SetFilter(Type, '=%1', NPRRemoteEndpointSetup.Type::MemberServices);
        NPRRemoteEndpointSetup.SetFilter(Disabled, '=%1', false);
        if (not NPRRemoteEndpointSetup.FindFirst()) then
            exit(false);

        IsValid := CreateRemoteMemberWorker(NPRRemoteEndpointSetup, MemberInfoCapture, NotValidReason);
        //+MM1.40 [357360]
    end;

    local procedure "--Internal API"()
    begin
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

    local procedure ValidateForeignMemberCard(NPRRemoteEndpointSetup: Record "MM NPR Remote Endpoint Setup"; ForeignMembercardNumber: Text[100]; var IsValid: Boolean; var NotValidReason: Text)
    var
        ForeignMembershipNumber: Code[20];
        ForeignMembershipSetup: Record "MM Foreign Membership Setup";
        RemoteInfoCapture: Record "MM Member Info Capture";
        MembershipSetup: Record "MM Membership Setup";
        Prefix: Code[10];
    begin

        if (not ForeignMembershipSetup.Get(NPRRemoteEndpointSetup."Community Code", GetManagerCode())) then
            exit;

        if (ForeignMembershipSetup.Disabled) then
            exit;

        IsValid := false;
        Prefix := ForeignMembershipSetup."Append Local Prefix";

        IsValid := ValidateRemoteCardNumber(NPRRemoteEndpointSetup, Prefix, ForeignMembercardNumber, RemoteInfoCapture, NotValidReason);
        if (not IsValid) then
            exit;
    end;

    local procedure ReplicateMembership(NPRRemoteEndpointSetup: Record "MM NPR Remote Endpoint Setup"; ForeignMembercardNumber: Text[100]; var IsValid: Boolean; var NotValidReason: Text)
    var
        ForeignMembershipNumber: Code[20];
        ForeignMembershipSetup: Record "MM Foreign Membership Setup";
        RemoteInfoCapture: Record "MM Member Info Capture";
        MembershipSetup: Record "MM Membership Setup";
        Prefix: Code[10];
    begin

        if (not ForeignMembershipSetup.Get(NPRRemoteEndpointSetup."Community Code", GetManagerCode())) then
            exit;

        if (ForeignMembershipSetup.Disabled) then
            exit;

        IsValid := false;
        Prefix := ForeignMembershipSetup."Append Local Prefix";

        if (not GetRemoteMembership(NPRRemoteEndpointSetup, Prefix, ForeignMembercardNumber, ForeignMembershipNumber, RemoteInfoCapture, NotValidReason)) then
            exit;

        RemoteInfoCapture."External Card No." := Prefix + ForeignMembercardNumber;
        if (StrLen(ForeignMembercardNumber) >= 4) then
            RemoteInfoCapture."External Card No. Last 4" := CopyStr(ForeignMembercardNumber, StrLen(ForeignMembercardNumber) - 4 + 1);

        MembershipSetup.Get(RemoteInfoCapture."Membership Code");
        if (MembershipSetup."Member Information" = MembershipSetup."Member Information"::NAMED) then
            if (not (GetRemoteMember(NPRRemoteEndpointSetup, Prefix, ForeignMembercardNumber, ForeignMembershipNumber, RemoteInfoCapture, NotValidReason))) then
                exit;

        //-MM1.38 [338215]
        //CreateMembership (RemoteInfoCapture, NotValidReason);
        IsValid := CreateLocalMembership(RemoteInfoCapture, NotValidReason);
        //+MM1.38 [338215]
    end;

    local procedure ValidateRemoteCardNumber(NPRRemoteEndpointSetup: Record "MM NPR Remote Endpoint Setup"; Prefix: Code[10]; ForeignMembercardNumber: Text[50]; var RemoteInfoCapture: Record "MM Member Info Capture"; var NotValidReason: Text) IsValid: Boolean
    var
        SoapAction: Text;
        XmlDocRequest: DotNet npNetXmlDocument;
        XmlDocResponse: DotNet npNetXmlDocument;
    begin

        MemberCardNumberValidationRequest(ForeignMembercardNumber, '', SoapAction, XmlDocRequest);
        if (not WebServiceApi(NPRRemoteEndpointSetup, SoapAction, NotValidReason, XmlDocRequest, XmlDocResponse)) then
            exit(false);

        IsValid := MemberCardNumberValidationResponse(Prefix, ForeignMembercardNumber, XmlDocResponse, NotValidReason, RemoteInfoCapture);

        //-MM1.40 [357360]
        if (not IsValid) then
            if (NotValidReason = '') then
                NotValidReason := StrSubstNo(MemberCardValidation, SoapAction, NPRRemoteEndpointSetup."Endpoint URI", ForeignMembercardNumber);
        //+MM1.40 [357360]

        exit(IsValid);
    end;

    local procedure GetRemoteMembership(NPRRemoteEndpointSetup: Record "MM NPR Remote Endpoint Setup"; Prefix: Code[10]; ForeignMembercardNumber: Text[50]; var ForeignMembershipNumber: Code[20]; var RemoteInfoCapture: Record "MM Member Info Capture"; var NotValidReason: Text) IsValid: Boolean
    var
        SoapAction: Text;
        XmlDocRequest: DotNet npNetXmlDocument;
        XmlDocResponse: DotNet npNetXmlDocument;
    begin

        GetMembershipRequest(ForeignMembercardNumber, '', SoapAction, XmlDocRequest);
        if (not WebServiceApi(NPRRemoteEndpointSetup, SoapAction, NotValidReason, XmlDocRequest, XmlDocResponse)) then
            exit(false);

        IsValid := GetMembershipResponse(Prefix, ForeignMembershipNumber, XmlDocResponse, NotValidReason, RemoteInfoCapture);

        if (StrLen(RemoteInfoCapture."External Card No.") >= 4) then
            RemoteInfoCapture."External Card No. Last 4" := CopyStr(RemoteInfoCapture."External Card No.", StrLen(RemoteInfoCapture."External Card No.") - 4 + 1);

        exit(IsValid);
    end;

    local procedure GetRemoteMember(NPRRemoteEndpointSetup: Record "MM NPR Remote Endpoint Setup"; Prefix: Code[10]; ForeignMembercardNumber: Text[50]; ForeignMembershipNumber: Code[20]; var RemoteInfoCapture: Record "MM Member Info Capture"; var NotValidReason: Text) IsValid: Boolean
    var
        SoapAction: Text;
        XmlDocRequest: DotNet npNetXmlDocument;
        XmlDocResponse: DotNet npNetXmlDocument;
    begin

        GetMembershipMemberRequest(ForeignMembershipNumber, ForeignMembercardNumber, '', SoapAction, XmlDocRequest);
        if (not WebServiceApi(NPRRemoteEndpointSetup, SoapAction, NotValidReason, XmlDocRequest, XmlDocResponse)) then
            exit(false);

        IsValid := GetMembershipMemberResponse(Prefix, XmlDocResponse, NotValidReason, RemoteInfoCapture);

        exit(IsValid);
    end;

    local procedure CreateLocalMembership(MemberInfoCapture: Record "MM Member Info Capture"; NotValidReason: Text) Success: Boolean
    var
        MembershipManagement: Codeunit "MM Membership Management";
        MembershipSalesSetup: Record "MM Membership Sales Setup";
    begin

        MembershipSalesSetup."Membership Code" := MemberInfoCapture."Membership Code";

        // NPR integration default setup
        MembershipSalesSetup."Valid From Base" := MembershipSalesSetup."Valid From Base"::SALESDATE;
        MemberInfoCapture."Document Date" := Today;
        MemberInfoCapture."Valid Until" := Today;
        MembershipSalesSetup."Valid Until Calculation" := MembershipSalesSetup."Valid Until Calculation"::DATEFORMULA;
        Evaluate(MembershipSalesSetup."Duration Formula", '<+0D>');

        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::FOREIGN;
        exit(0 <> MembershipManagement.CreateMembershipAll(MembershipSalesSetup, MemberInfoCapture, true));
    end;

    local procedure UpdateLocalMembershipPoints(NPRRemoteEndpointSetup: Record "MM NPR Remote Endpoint Setup"; MembershipEntryNo: Integer; Prefix: Code[10]; ForeignMembercardNumber: Text[50]; var NotValidReason: Text) IsValid: Boolean
    var
        SoapAction: Text;
        XmlDocRequest: DotNet npNetXmlDocument;
        XmlDocResponse: DotNet npNetXmlDocument;
        ForeignMembershipNumber: Code[20];
        RemoteInfoCapture: Record "MM Member Info Capture";
        LoyaltyPointManagement: Codeunit "MM Loyalty Point Management";
    begin

        //-MM1.38 [338215]
        if (MembershipEntryNo = 0) then
            exit(false);

        GetLoyaltyPointRequest(ForeignMembercardNumber, '', SoapAction, XmlDocRequest);
        if (not WebServiceApi(NPRRemoteEndpointSetup, SoapAction, NotValidReason, XmlDocRequest, XmlDocResponse)) then
            exit(false);

        IsValid := GetLoyaltyPointResponse(Prefix, ForeignMembershipNumber, XmlDocResponse, NotValidReason, RemoteInfoCapture);

        if (IsValid) then
            LoyaltyPointManagement.SynchronizePointsAbsolute(MembershipEntryNo, Round(RemoteInfoCapture."Initial Loyalty Point Count", 1, '<'), Today);

        exit(IsValid);
    end;

    local procedure CreateRemoteMembershipWorker(NPRRemoteEndpointSetup: Record "MM NPR Remote Endpoint Setup"; var MembershipInfo: Record "MM Member Info Capture"; var NotValidReason: Text) IsValid: Boolean
    var
        ScannerStationId: Text;
        SoapAction: Text;
        XmlDocRequest: DotNet npNetXmlDocument;
        XmlDocResponse: DotNet npNetXmlDocument;
    begin

        //-MM1.40 [357360]
        ScannerStationId := '';

        CreateMembershipSoapXmlRequest(MembershipInfo, ScannerStationId, SoapAction, XmlDocRequest);
        if (not WebServiceApi(NPRRemoteEndpointSetup, SoapAction, NotValidReason, XmlDocRequest, XmlDocResponse)) then
            exit(false);

        IsValid := EvaluateCreateMembershipSoapXmlResponse(MembershipInfo, NotValidReason, XmlDocResponse);
        exit(IsValid);
        //+MM1.40 [357360]
    end;

    local procedure CreateRemoteMemberWorker(NPRRemoteEndpointSetup: Record "MM NPR Remote Endpoint Setup"; var MembershipInfo: Record "MM Member Info Capture"; var NotValidReason: Text) IsValid: Boolean
    var
        ScannerStationId: Text;
        SoapAction: Text;
        XmlDocRequest: DotNet npNetXmlDocument;
        XmlDocResponse: DotNet npNetXmlDocument;
    begin

        //-MM1.40 [357360]
        ScannerStationId := '';

        CreateMemberSoapXmlRequest(MembershipInfo, ScannerStationId, SoapAction, XmlDocRequest);
        if (not WebServiceApi(NPRRemoteEndpointSetup, SoapAction, NotValidReason, XmlDocRequest, XmlDocResponse)) then
            exit(false);


        IsValid := EvaluateCreateMemberSoapXmlResponse(MembershipInfo, NotValidReason, XmlDocResponse);
        exit(IsValid);
        //+MM1.40 [357360]
    end;

    local procedure "--WSSupport"()
    begin
    end;

    procedure WebServiceApi(NPRRemoteEndpointSetup: Record "MM NPR Remote Endpoint Setup"; SoapAction: Text; var ReasonText: Text; var XmlDocIn: DotNet npNetXmlDocument; var XmlDocOut: DotNet npNetXmlDocument): Boolean
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        Credential: DotNet npNetNetworkCredential;
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        WebException: DotNet npNetWebException;
        WebInnerException: DotNet npNetWebException;
        Url: Text;
        ErrorMessage: Text;
        ResponseText: Text;
        Exception: DotNet npNetException;
        StatusCode: Code[10];
        StatusDescription: Text[50];
        B64Credential: Text;
    begin

        ReasonText := '';
        HttpWebRequest := HttpWebRequest.Create(NPRRemoteEndpointSetup."Endpoint URI");
        HttpWebRequest.Timeout := NPRRemoteEndpointSetup."Connection Timeout (ms)";

        case NPRRemoteEndpointSetup."Credentials Type" of
            NPRRemoteEndpointSetup."Credentials Type"::NAMED:
                begin
                    HttpWebRequest.UseDefaultCredentials(false);
                    if (NPRRemoteEndpointSetup."User Domain" <> '') then
                        Credential := Credential.NetworkCredential(StrSubstNo('%1/%2', NPRRemoteEndpointSetup."User Domain", NPRRemoteEndpointSetup."User Account"), NPRRemoteEndpointSetup."User Password")
                    else
                        Credential := Credential.NetworkCredential(NPRRemoteEndpointSetup."User Account", NPRRemoteEndpointSetup."User Password");

                    HttpWebRequest.Credentials(Credential);
                end;

            NPRRemoteEndpointSetup."Credentials Type"::BASIC:
                begin
                    B64Credential := ToBase64(StrSubstNo('%1:%2', NPRRemoteEndpointSetup."User Account", NPRRemoteEndpointSetup."User Password"));
                    HttpWebRequest.Headers.Add('Authorization', StrSubstNo('Basic %1', B64Credential));
                end;

            else
                HttpWebRequest.UseDefaultCredentials(true);
        end;

        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'text/xml; charset=utf-8';
        HttpWebRequest.Headers.Add('SOAPAction', SoapAction);

        NpXmlDomMgt.SetTrustedCertificateValidation(HttpWebRequest);

        if (TrySendWebRequest(XmlDocIn, HttpWebRequest, HttpWebResponse)) then begin
            TryReadResponseText(HttpWebResponse, ResponseText);
            //-MM1.40 [357360]
            // XmlDocOut := XmlDocOut.XmlDocument;
            // XmlDocOut.LoadXml (ResponseText);
            // EXIT (TRUE);
            if (TryParseResponseText(ResponseText)) then begin
                XmlDocOut := XmlDocOut.XmlDocument;
                XmlDocOut.LoadXml(ResponseText);
                exit(true);
            end;
            //+MM1.40 [357360]
        end;

        //-MM1.40 [357360]
        XmlDocOut := XmlDocOut.XmlDocument;
        GetExceptionDescription(XmlDocOut, SoapAction, NPRRemoteEndpointSetup."Endpoint URI");

        ReasonText := NpXmlDomMgt.PrettyPrintXml(XmlDocOut.InnerXml());

        exit(false);

        // Exception := GETLASTERROROBJECT();
        // ReasonText := STRSUBSTNO ('Error from WebServiceApi %1\\%2\\%3', GETLASTERRORTEXT, SoapAction, Exception.ToString());
        //
        // IF (FORMAT (GETDOTNETTYPE (Exception.GetBaseException ())) <> 'System.Net.WebException') THEN
        //  ERROR (ReasonText);
        //
        // WebException := Exception.GetBaseException ();
        // TryReadExceptionResponseText (WebException, StatusCode, StatusDescription, ResponseText);
        //
        // XmlDocOut := XmlDocOut.XmlDocument;
        // IF (STRLEN (ResponseText) > 0) THEN
        //  XmlDocOut.LoadXml (ResponseText);
        //
        // IF (STRLEN (ResponseText) = 0) THEN
        //  XmlDocOut.LoadXml (STRSUBSTNO (
        //    '<Fault>'+
        //      '<faultstatus>%1</faultstatus>'+
        //      '<faultstring>%2</faultstring>'+
        //    '</Fault>',
        //    StatusCode,
        //    StatusDescription));
        //
        // MESSAGE ('Remote service %4 returned:\\%1 %2 %3', StatusCode, StatusDescription, ResponseText, NPRRemoteEndpointSetup."Endpoint URI");
        // EXIT (FALSE);
        //+MM1.40 [357360]
    end;

    local procedure "--SoapRequest and Response"()
    begin
    end;

    procedure MemberCardNumberValidationRequest(ExternalMembercardNumber: Text[100]; ScannerStationId: Text; var SoapAction: Text[50]; var XmlDoc: DotNet npNetXmlDocument)
    var
        XmlRequest: Text;
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
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

        XmlRequest := StrSubstNo(XmlRequest, ExternalMembercardNumber, ScannerStationId);

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(XmlRequest);
    end;

    local procedure MemberCardNumberValidationResponse(Prefix: Code[10]; ForeignMembercardNumber: Text[50]; var XmlDoc: DotNet npNetXmlDocument; var ResponseText: Text; var MemberInfoCapture: Record "MM Member Info Capture") ValidResponse: Boolean
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlElement: DotNet npNetXmlElement;
        PayloadBody: Text;
        TextOk: Text;
    begin

        NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
        XmlElement := XmlDoc.DocumentElement;
        if (IsNull(XmlElement)) then begin
            ResponseText := StrSubstNo(InvalidXml, NpXmlDomMgt.PrettyPrintXml(XmlDoc.InnerXml()));
            exit(false);
        end;

        TextOk := NpXmlDomMgt.GetXmlText(XmlElement, '//MemberCardNumberValidation_Result/return_value', 5, false);
        MemberInfoCapture."External Card No." := Prefix + ForeignMembercardNumber;
        if (StrLen(ForeignMembercardNumber) >= 4) then
            MemberInfoCapture."External Card No. Last 4" := CopyStr(ForeignMembercardNumber, StrLen(ForeignMembercardNumber) - 4 + 1);

        exit(UpperCase(TextOk) = 'TRUE');
    end;

    local procedure GetMembershipRequest(ExternalMembercardNumber: Text[50]; ScannerStationId: Text; var SoapAction: Text[50]; var XmlDoc: DotNet npNetXmlDocument)
    var
        XmlRequest: Text;
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
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

        XmlRequest := StrSubstNo(XmlRequest, ExternalMembercardNumber, ScannerStationId);

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(XmlRequest);
    end;

    local procedure GetMembershipResponse(Prefix: Code[10]; var ForeignMembershipNumber: Code[20]; var XmlDoc: DotNet npNetXmlDocument; var ResponseText: Text; var MemberInfoCapture: Record "MM Member Info Capture") ValidResponse: Boolean
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlElement: DotNet npNetXmlElement;
        PayloadBody: Text;
        TextOk: Text;
        ElementPath: Text;
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

        NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
        XmlElement := XmlDoc.DocumentElement;
        if (IsNull(XmlElement)) then begin
            ResponseText := StrSubstNo(InvalidXml, NpXmlDomMgt.PrettyPrintXml(XmlDoc.InnerXml()));
            exit(false);
        end;

        ElementPath := '//GetMembership_Result/membership/getmembership/response/';
        TextOk := NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + 'status', 5, false);
        ResponseText := NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + 'errordescription', 1000, false);
        if (TextOk = '0') then
            exit(false);

        ElementPath := '//GetMembership_Result/membership/getmembership/response/membership/';

        with MemberInfoCapture do begin
            "Membership Code" := Prefix + NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + '/membershipcode', MaxStrLen("Membership Code"), false);
            ForeignMembershipNumber := NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + '/membershipnumber', MaxStrLen("External Membership No."), false);
            "External Membership No." := Prefix + ForeignMembershipNumber;
        end;

        exit(true);
    end;

    local procedure GetMembershipMemberRequest(ExternalMembershipNumber: Code[20]; ExternalMembercardNumber: Text[50]; ScannerStationId: Text; var SoapAction: Text[50]; var XmlDoc: DotNet npNetXmlDocument)
    var
        XmlRequest: Text;
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
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

        XmlRequest := StrSubstNo(XmlRequest, ExternalMembershipNumber, ExternalMembercardNumber, ScannerStationId);

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(XmlRequest);
    end;

    local procedure GetMembershipMemberResponse(Prefix: Code[10]; var XmlDoc: DotNet npNetXmlDocument; var ResponseText: Text; var MemberInfoCapture: Record "MM Member Info Capture"): Boolean
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlElement: DotNet npNetXmlElement;
        PayloadBody: Text;
        TextOk: Text;
        ElementPath: Text;
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

        NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
        XmlElement := XmlDoc.DocumentElement;
        if (IsNull(XmlElement)) then begin
            ResponseText := StrSubstNo(InvalidXml, NpXmlDomMgt.PrettyPrintXml(XmlDoc.InnerXml()));
            exit(false);
        end;

        ElementPath := '//GetMembershipMembers_Result/member/getmembers/response/';
        TextOk := NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + 'status', 5, false);
        ResponseText := NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + 'errordescription', 1000, false);
        if (TextOk = '0') then
            exit(false);

        ElementPath := '//GetMembershipMembers_Result/member/getmembers/response/member/';
        with MemberInfoCapture do begin
            "First Name" := NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + 'firstname', MaxStrLen("First Name"), false);
            "Middle Name" := NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + 'middlename', MaxStrLen("Middle Name"), false);
            "Last Name" := NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + 'lastname', MaxStrLen("Last Name"), false);
            Address := NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + 'address', MaxStrLen(Address), false);
            "Post Code Code" := NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + 'postcode', MaxStrLen("Post Code Code"), false);
            City := NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + 'city', MaxStrLen(City), false);
            "Country Code" := NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + 'country', MaxStrLen("Country Code"), false);

            if (Evaluate(Birthday, NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + 'birthday', 10, false))) then;
            if (Evaluate(Gender, NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + 'gender', 1, false))) then;
            if (Evaluate("News Letter", NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + 'newsletter', 1, false))) then;

            "Phone No." := NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + 'phoneno', MaxStrLen("Phone No."), false);
            "E-Mail Address" := NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + 'email', MaxStrLen("E-Mail Address"), false);
        end;

        exit(true);
    end;

    local procedure GetLoyaltyPointRequest(ExternalMembercardNumber: Text[50]; ScannerStationId: Text; var SoapAction: Text[50]; var XmlDoc: DotNet npNetXmlDocument)
    var
        XmlRequest: Text;
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
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

        XmlRequest := StrSubstNo(XmlRequest, ExternalMembercardNumber);

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(XmlRequest);
    end;

    local procedure GetLoyaltyPointResponse(Prefix: Code[10]; var ForeignMembershipNumber: Code[20]; var XmlDoc: DotNet npNetXmlDocument; var ResponseText: Text; var MemberInfoCapture: Record "MM Member Info Capture") ValidResponse: Boolean
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlElement: DotNet npNetXmlElement;
        PayloadBody: Text;
        TextOk: Text;
        ElementPath: Text;
        Points: Text;
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


        NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
        XmlElement := XmlDoc.DocumentElement;
        if (IsNull(XmlElement)) then begin
            ResponseText := StrSubstNo(InvalidXml, NpXmlDomMgt.PrettyPrintXml(XmlDoc.InnerXml()));
            exit(false);
        end;

        ElementPath := '//GetLoyaltyPoints_Result/getLoyaltyPoints/getloyaltypoints/response/status/';
        TextOk := NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + 'responsecode', 5, false);
        ResponseText := NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + 'responsemessage', 1000, false);
        if (TextOk = '0') then
            exit(false);

        ElementPath := '//GetLoyaltyPoints_Result/getLoyaltyPoints/getloyaltypoints/response/membership';

        with MemberInfoCapture do begin
            "Membership Code" := Prefix + NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + '/membershipcode', MaxStrLen("Membership Code"), false);
            ForeignMembershipNumber := NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + '/membershipnumber', MaxStrLen("External Membership No."), false);
            "External Membership No." := Prefix + ForeignMembershipNumber;
            Points := NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + '/pointsummary/remaining', 10, false);
            if (not Evaluate("Initial Loyalty Point Count", Points)) then
                "Initial Loyalty Point Count" := 0;
        end;

        exit(true);
        //+MM1.38 [338215]
    end;

    procedure CreateMembershipSoapXmlRequest(MemberInfoCapture: Record "MM Member Info Capture"; var ScannerStationId: Text; var SoapAction: Text[50]; var XmlDoc: DotNet npNetXmlDocument)
    var
        XmlText: Text;
    begin

        //-MM1.40 [357360]
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

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(XmlText);

        SoapAction := 'CreateMembership';
        //+MM1.40 [357360]
    end;

    procedure CreateMembershipXmlPortRequest(MemberInfoCapture: Record "MM Member Info Capture") XmlText: Text
    begin

        //-MM1.40 [357360]
        XmlText :=
        '<membership xmlns="urn:microsoft-dynamics-nav/xmlports/x6060127">' +
        CreateMembershipRequest(MemberInfoCapture) +
        '</membership>';
        //+MM1.40 [357360]
    end;

    local procedure CreateMembershipRequest(MemberInfoCapture: Record "MM Member Info Capture") XmlText: Text
    var
        ActivationDateText: Text;
    begin

        //-MM1.40 [357360]
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
        //+MM1.40 [357360]
    end;

    local procedure EvaluateCreateMembershipSoapXmlResponse(var MemberInfoCapture: Record "MM Member Info Capture"; var NotValidReason: Text; var XmlDoc: DotNet npNetXmlDocument) IsValid: Boolean
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlElement: DotNet npNetXmlElement;
        ResponseText: Text;
        TextOk: Text;
        ElementPath: Text;
    begin

        //-MM1.40 [357360]
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


        NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
        XmlElement := XmlDoc.DocumentElement;
        if (IsNull(XmlElement)) then begin
            ResponseText := StrSubstNo(InvalidXml, NpXmlDomMgt.PrettyPrintXml(XmlDoc.InnerXml()));
            exit(false);
        end;

        ElementPath := '//CreateMembership_Result/membership/createmembership/response/';
        TextOk := NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + 'status', 5, true);
        NotValidReason := StrSubstNo('Message from Server: %1', NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + 'errordescription', 1000, true));
        if (TextOk = '0') then
            exit(false);

        ElementPath := '//CreateMembership_Result/membership/createmembership/response/membership/';

        with MemberInfoCapture do begin
            "Membership Code" := NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + 'membershipcode', MaxStrLen("Membership Code"), false);
            "External Membership No." := NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + 'membershipnumber', MaxStrLen("External Membership No."), false);
        end;

        NotValidReason := '';
        exit(true);
        //+MM1.40 [357360]
    end;

    local procedure CreateMemberSoapXmlRequest(MemberInfoCapture: Record "MM Member Info Capture"; var ScannerStationId: Text; var SoapAction: Text[50]; var XmlDoc: DotNet npNetXmlDocument)
    var
        XmlText: Text;
    begin

        //-MM1.40 [357360]
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

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(XmlText);
        //+MM1.40 [357360]
    end;

    local procedure CreateMemberRequest(MemberInfoCapture: Record "MM Member Info Capture") XmlText: Text
    var
        MemberCardXml: Text;
        GuardianXml: Text;
        DateText: Text;
    begin

        //-MM1.40 [357360]
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
        //+MM1.40 [357360]
    end;

    local procedure EvaluateCreateMemberSoapXmlResponse(var MemberInfoCapture: Record "MM Member Info Capture"; var NotValidReason: Text; var XmlDoc: DotNet npNetXmlDocument): Boolean
    var
        DateText: Text;
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlElement: DotNet npNetXmlElement;
        ResponseText: Text;
        TextOk: Text;
        ElementPath: Text;
    begin

        //-MM1.40 [357360]

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

        NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
        XmlElement := XmlDoc.DocumentElement;
        if (IsNull(XmlElement)) then begin
            ResponseText := StrSubstNo(InvalidXml, NpXmlDomMgt.PrettyPrintXml(XmlDoc.InnerXml()));
            exit(false);
        end;

        ElementPath := '//AddMembershipMember_Result/member/addmember/response/';
        TextOk := NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + 'status', 5, true);
        NotValidReason := StrSubstNo('Message from Server: %1', NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + 'errordescription', 1000, true));
        if (TextOk = '0') then
            exit(false);

        ElementPath := '//AddMembershipMember_Result/member/addmember/response/member/';
        with MemberInfoCapture do begin
            "External Member No" := NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + 'membernumber', MaxStrLen("External Member No"), false);
            "External Card No." := NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + 'cardnumber', MaxStrLen("External Card No."), false);
            DateText := NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + 'expirydate', 10, false);
            if (not Evaluate("Valid Until", DateText, 9)) then
                "Valid Until" := 0D;
        end;

        NotValidReason := '';
        exit(true);
        //+MM1.40 [357360]
    end;

    local procedure "--"()
    begin
    end;

    local procedure GetExceptionDescription(var XmlDocOut: DotNet npNetXmlDocument; SoapAction: Text; Endpoint: Text)
    var
        ReasonText: Text;
        WebException: DotNet npNetWebException;
        Url: Text;
        ErrorMessage: Text;
        ResponseText: Text;
        Exception: DotNet npNetException;
        StatusCode: Code[10];
        StatusDescription: Text[50];
    begin

        ReasonText := StrSubstNo('Error from WebServiceApi %1\\%2', GetLastErrorText, SoapAction);

        Exception := GetLastErrorObject();
        if ((Format(GetDotNetType(Exception.GetBaseException()))) <> (Format(GetDotNetType(WebException)))) then begin
            //ERROR (Exception.ToString ());
            XmlDocOut.LoadXml(StrSubstNo(
              '<Fault>' +
                '<faultstatus>%1</faultstatus>' +
                '<faultstring>%2 - %3</faultstring>' +
              '</Fault>',
              998,
              ReasonText,
              Endpoint));
            exit;
        end;

        WebException := Exception.GetBaseException();
        TryReadExceptionResponseText(WebException, StatusCode, StatusDescription, ResponseText);

        if (StrLen(ResponseText) > 0) then
            XmlDocOut.LoadXml(ResponseText);

        if (StrLen(ResponseText) = 0) then
            XmlDocOut.LoadXml(StrSubstNo(
              '<Fault>' +
                '<faultstatus>%1</faultstatus>' +
                '<faultstring>%2 - %3</faultstring>' +
              '</Fault>',
              StatusCode,
              StatusDescription,
              Endpoint));
    end;

    [TryFunction]
    local procedure TrySendWebRequest(var XmlDoc: DotNet npNetXmlDocument; HttpWebRequest: DotNet npNetHttpWebRequest; var HttpWebResponse: DotNet npNetHttpWebResponse)
    var
        MemoryStream: DotNet npNetMemoryStream;
    begin

        MemoryStream := HttpWebRequest.GetRequestStream;
        XmlDoc.Save(MemoryStream);
        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);
        HttpWebResponse := HttpWebRequest.GetResponse;
    end;

    [TryFunction]
    local procedure TryReadResponseText(var HttpWebResponse: DotNet npNetHttpWebResponse; var ResponseText: Text)
    var
        Stream: DotNet npNetStream;
        StreamReader: DotNet npNetStreamReader;
    begin

        Stream := HttpWebResponse.GetResponseStream;
        StreamReader := StreamReader.StreamReader(Stream);
        ResponseText := StreamReader.ReadToEnd;
        Stream.Flush;
        Stream.Close;
        Clear(Stream);
    end;

    [TryFunction]
    local procedure TryReadExceptionResponseText(var WebException: DotNet npNetWebException; var StatusCode: Code[10]; var StatusDescription: Text; var ResponseXml: Text)
    var
        Stream: DotNet npNetStream;
        StreamReader: DotNet npNetStreamReader;
        WebResponse: DotNet npNetWebResponse;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        WebExceptionStatus: DotNet npNetWebExceptionStatus;
        SystemConvert: DotNet npNetConvert;
        StatusCodeInt: Integer;
        DotNetType: DotNet npNetType;
    begin

        ResponseXml := '';

        // No respone body on time out
        if (WebException.Status.Equals(WebExceptionStatus.Timeout)) then begin
            DotNetType := GetDotNetType(StatusCodeInt);
            StatusCodeInt := SystemConvert.ChangeType(WebExceptionStatus.Timeout, DotNetType);
            StatusCode := Format(StatusCodeInt);
            StatusDescription := WebExceptionStatus.Timeout.ToString();
            exit;
        end;

        // This happens for unauthorized and server side faults (4xx and 5xx)
        // The response stream in unauthorized fails in XML transformation later
        if (WebException.Status.Equals(WebExceptionStatus.ProtocolError)) then begin
            HttpWebResponse := WebException.Response();
            DotNetType := GetDotNetType(StatusCodeInt);
            StatusCodeInt := SystemConvert.ChangeType(HttpWebResponse.StatusCode, DotNetType);
            StatusCode := Format(StatusCodeInt);
            StatusDescription := HttpWebResponse.StatusDescription;
            if (StatusCode[1] = '4') then // 4xx messages
                exit;
        end;

        StreamReader := StreamReader.StreamReader(WebException.Response().GetResponseStream());
        ResponseXml := StreamReader.ReadToEnd;

        StreamReader.Close;
        Clear(StreamReader);
    end;

    [TryFunction]
    local procedure TryGetWebExceptionResponse(var WebException: DotNet npNetWebException; var HttpWebResponse: DotNet npNetHttpWebResponse)
    begin

        HttpWebResponse := WebException.Response;
    end;

    [TryFunction]
    local procedure TryGetInnerWebException(var WebException: DotNet npNetWebException; var InnerWebException: DotNet npNetWebException)
    begin

        InnerWebException := WebException.InnerException;
    end;

    [TryFunction]
    local procedure TryParseResponseText(XmlText: Text)
    var
        XmlDocOut: DotNet npNetXmlDocument;
    begin
        //-MM1.40 [357360]
        XmlDocOut := XmlDocOut.XmlDocument;
        XmlDocOut.LoadXml(XmlText);
        //+MM1.40 [357360]
    end;

    local procedure ToBase64(StringToEncode: Text) B64String: Text
    var
        TempBlob: Codeunit "Temp Blob";
        BinaryReader: DotNet npNetBinaryReader;
        MemoryStream: DotNet npNetMemoryStream;
        Convert: DotNet npNetConvert;
        InStr: InStream;
        Outstr: OutStream;
    begin

        //-MM1.40 [357360]
        Clear(TempBlob);
        TempBlob.CreateOutStream(Outstr);
        Outstr.WriteText(StringToEncode);

        TempBlob.CreateInStream(InStr);
        MemoryStream := InStr;
        BinaryReader := BinaryReader.BinaryReader(InStr);

        B64String := Convert.ToBase64String(BinaryReader.ReadBytes(MemoryStream.Length));

        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);
        //+MM1.40 [357360]
    end;

    procedure XmlSafe(InText: Text): Text
    begin

        //-MM1.40 [357360]
        exit(DelChr(InText, '<=>', '<>&/'));
        //+MM1.40 [357360]
    end;
}

