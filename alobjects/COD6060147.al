codeunit 6060147 "MM NPR Membership"
{
    // MM1.23/TSA /20171002 CASE 257011 NPR implementation of foreign memberships and loyalty
    // MM1.37/TSA /20190301 CASE 343053 Checking that type is used form NPR Remote Endpoint
    // MM1.38/TSA /20190522 CASE 338215 Corrected the return code from CreateMembership
    // MM1.38/TSA /20190523 CASE 338215 Added the wizard on setup subscriber


    trigger OnRun()
    begin
    end;

    var
        NotSupportedVersion: Label 'A request for %1 was made for %2, %3 with message version %4. That version is not handled in %5 %6.';
        InvalidXml: Label 'An invalid XML was returned:\%1';

    [EventSubscriber(ObjectType::Codeunit, 6060145, 'OnDiscoverExternalMembershipMgr', '', true, true)]
    local procedure OnDiscover(var Sender: Record "MM Foreign Membership Setup")
    begin

        Sender.RegisterManager (GetManagerCode(), 'NaviPartner Foreign NPR Membership Management');
    end;

    local procedure GetManagerCode(): Code[20]
    begin
        exit ('NPR_MEMBER');
    end;

    local procedure "--Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060145, 'OnDispatchToReplicateForeignMemberCard', '', true, true)]
    local procedure OnValidateAndReplicateForeignMemberCardSubscriber(CommunityCode: Code[20];ManagerCode: Code[20];ForeignMembercardNumber: Text[100];var IsValid: Boolean;var NotValidReason: Text;var IsHandled: Boolean)
    var
        ForeignMembershipSetup: Record "MM Foreign Membership Setup";
        NPRRemoteEndpointSetup: Record "MM NPR Remote Endpoint Setup";
        SoapAction: Text;
        XmlDocRequest: DotNet XmlDocument;
        XmlDocResponse: DotNet XmlDocument;
    begin

        if (ManagerCode <> GetManagerCode ()) then
          exit;

        NPRRemoteEndpointSetup.SetFilter ("Community Code", '=%1', CommunityCode);
        NPRRemoteEndpointSetup.SetFilter (Type, '=%1', NPRRemoteEndpointSetup.Type::MemberServices);
        NPRRemoteEndpointSetup.SetFilter (Disabled, '=%1', false);
        if (not NPRRemoteEndpointSetup.FindFirst ()) then
          exit;

        IsHandled := true;

        ForeignMembershipSetup.Get (CommunityCode, ManagerCode);
        ForeignMembercardNumber := RemoveLocalPrefix (ForeignMembershipSetup."Remove Local Prefix", ForeignMembercardNumber);

        ValidateForeignMemberCard (NPRRemoteEndpointSetup, ForeignMembercardNumber, IsValid, NotValidReason);
        if (IsValid) then
          ReplicateMembership (NPRRemoteEndpointSetup, ForeignMembercardNumber, IsValid, NotValidReason);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060145, 'OnFormatForeignCardnumberFromScan', '', true, true)]
    local procedure OnFormatScannedCardnumberSubscriber(CommunityCode: Code[20];ManagerCode: Code[20];ScannedCardNumber: Text[100];var FormattedCardNumber: Text[50];var IsHandled: Boolean)
    var
        ForeignMembershipSetup: Record "MM Foreign Membership Setup";
    begin

        if (ManagerCode <> GetManagerCode ()) then
          exit;

        IsHandled := true;

        ForeignMembershipSetup.Get (CommunityCode, ManagerCode);

        FormattedCardNumber := AddLocalPrefix (ForeignMembershipSetup."Append Local Prefix",
                                 RemoveLocalPrefix (ForeignMembershipSetup."Remove Local Prefix", ScannedCardNumber));
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060145, 'OnShowSetup', '', true, true)]
    local procedure OnShowSetupSubscriber(CommunityCode: Code[20];ManagerCode: Code[20])
    var
        NPRRemoteEndpointSetup: Record "MM NPR Remote Endpoint Setup";
        ForeignMembershipSetup: Record "MM Foreign Membership Setup";
        NPREndpointSetupPage: Page "MM NPR Endpoint Setup";
        Choice: Integer;
        NPRLoyaltyWizard: Codeunit "MM NRP Loyalty Wizard";
    begin

        if (ManagerCode <> GetManagerCode ()) then
          exit;

        //-MM1.38 [338215]
        Choice := StrMenu ('View Endpoints,Cross Company Loyalty Client Setup',1,'Make your selection:');

        case Choice of
          1 : begin
            NPRRemoteEndpointSetup.SetFilter ("Community Code", '=%1', CommunityCode);
            NPREndpointSetupPage.SetTableView (NPRRemoteEndpointSetup);
            NPREndpointSetupPage.Run ();
          end;

          2: begin
            ForeignMembershipSetup.Get (CommunityCode, GetManagerCode());
            NPRLoyaltyWizard.SetCommunityCode (CommunityCode, ForeignMembershipSetup."Append Local Prefix");
            NPRLoyaltyWizard.Run ();
          end;
        end;
        //+MM1.38 [338215]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060145, 'OnShowDashboard', '', true, true)]
    local procedure OnShowDashboardSubscriber(CommunityCode: Code[20];ManagerCode: Code[20])
    begin

        if (ManagerCode <> GetManagerCode ()) then
          exit;

        // No dashboard yet
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060145, 'OnSynchronizeLoyaltyPoints', '', true, true)]
    local procedure OnSynchronizeLoyaltyPointsSubscriber(CommunityCode: Code[20];ManagerCode: Code[20];MembershipEntryNo: Integer;ScannedCardNumber: Text[100])
    var
        IsValid: Boolean;
        NotValidReason: Text;
    begin

        //-MM1.38 [338215]
        if (ManagerCode <> GetManagerCode ()) then
          exit;

        SynchronizeLoyaltyPointsWorker (CommunityCode, MembershipEntryNo, ScannedCardNumber, IsValid, NotValidReason);
        //+MM1.38 [338215]
    end;

    local procedure SynchronizeLoyaltyPointsWorker(CommunityCode: Code[20];MembershipEntryNo: Integer;ForeignMembercardNumber: Text[100];var IsValid: Boolean;var NotValidReason: Text)
    var
        ForeignMembershipSetup: Record "MM Foreign Membership Setup";
        NPRRemoteEndpointSetup: Record "MM NPR Remote Endpoint Setup";
        SoapAction: Text;
        XmlDocRequest: DotNet XmlDocument;
        XmlDocResponse: DotNet XmlDocument;
        CustomerNumber: Text[30];
        CardNumber: Text[30];
        CustomerName: Text[50];
    begin

        //-MM1.38 [338215]
        NPRRemoteEndpointSetup.SetFilter ("Community Code", '=%1', CommunityCode);
        NPRRemoteEndpointSetup.SetFilter (Type, '=%1', NPRRemoteEndpointSetup.Type::LoyaltyServices);
        NPRRemoteEndpointSetup.SetFilter (Disabled, '=%1', false);
        if (not NPRRemoteEndpointSetup.FindFirst ()) then
          exit;

        ForeignMembershipSetup.Get (CommunityCode, GetManagerCode());
        ForeignMembercardNumber := RemoveLocalPrefix (ForeignMembershipSetup."Remove Local Prefix", ForeignMembercardNumber);

        IsValid := UpdateMembershipPoints (NPRRemoteEndpointSetup, MembershipEntryNo, ForeignMembershipSetup."Append Local Prefix", ForeignMembercardNumber, NotValidReason);
        //+MM1.38 [338215]
    end;

    local procedure "--Internal API"()
    begin
    end;

    local procedure AddLocalPrefix(Prefix: Text;String: Text): Text
    begin

        exit (StrSubstNo ('%1%2', Prefix, String));
    end;

    local procedure RemoveLocalPrefix(Prefix: Text;String: Text) NewString: Text
    begin

        NewString := String;

        if (StrLen (Prefix) = 0) then
          exit (NewString);

        if (StrLen (Prefix) > StrLen (String)) then
          exit (NewString);

        if (CopyStr (String, 1, StrLen (Prefix)) = Prefix) then
          NewString := CopyStr (String, StrLen (Prefix)+1);

        exit (NewString);
    end;

    local procedure ValidateForeignMemberCard(NPRRemoteEndpointSetup: Record "MM NPR Remote Endpoint Setup";ForeignMembercardNumber: Text[100];var IsValid: Boolean;var NotValidReason: Text)
    var
        ForeignMembershipNumber: Code[20];
        ForeignMembershipSetup: Record "MM Foreign Membership Setup";
        RemoteInfoCapture: Record "MM Member Info Capture";
        MembershipSetup: Record "MM Membership Setup";
        Prefix: Code[10];
    begin

        if (not ForeignMembershipSetup.Get (NPRRemoteEndpointSetup."Community Code", GetManagerCode())) then
          exit;

        if (ForeignMembershipSetup.Disabled) then
          exit;

        IsValid := false;
        Prefix := ForeignMembershipSetup."Append Local Prefix";

        IsValid := ValidateCardNumber (NPRRemoteEndpointSetup, Prefix, ForeignMembercardNumber, RemoteInfoCapture, NotValidReason);
        if (not IsValid) then
          exit;
    end;

    local procedure ReplicateMembership(NPRRemoteEndpointSetup: Record "MM NPR Remote Endpoint Setup";ForeignMembercardNumber: Text[100];var IsValid: Boolean;var NotValidReason: Text)
    var
        ForeignMembershipNumber: Code[20];
        ForeignMembershipSetup: Record "MM Foreign Membership Setup";
        RemoteInfoCapture: Record "MM Member Info Capture";
        MembershipSetup: Record "MM Membership Setup";
        Prefix: Code[10];
    begin

        if (not ForeignMembershipSetup.Get (NPRRemoteEndpointSetup."Community Code", GetManagerCode())) then
          exit;

        if (ForeignMembershipSetup.Disabled) then
          exit;

        IsValid := false;
        Prefix := ForeignMembershipSetup."Append Local Prefix";

        if (not GetMembership (NPRRemoteEndpointSetup, Prefix, ForeignMembercardNumber, ForeignMembershipNumber, RemoteInfoCapture, NotValidReason)) then
          exit;

        RemoteInfoCapture."External Card No." := Prefix + ForeignMembercardNumber;
        if (StrLen (ForeignMembercardNumber) >= 4) then
          RemoteInfoCapture."External Card No. Last 4" := CopyStr (ForeignMembercardNumber, StrLen (ForeignMembercardNumber)-4+1);

        MembershipSetup.Get (RemoteInfoCapture."Membership Code");
        if (MembershipSetup."Member Information" = MembershipSetup."Member Information"::NAMED) then
          if (not (GetMember (NPRRemoteEndpointSetup, Prefix, ForeignMembercardNumber, ForeignMembershipNumber, RemoteInfoCapture, NotValidReason))) then
            exit;

        //-MM1.38 [338215]
        //CreateMembership (RemoteInfoCapture, NotValidReason);
        IsValid := CreateMembership (RemoteInfoCapture, NotValidReason);
        //+MM1.38 [338215]
    end;

    local procedure ValidateCardNumber(NPRRemoteEndpointSetup: Record "MM NPR Remote Endpoint Setup";Prefix: Code[10];ForeignMembercardNumber: Text[50];var RemoteInfoCapture: Record "MM Member Info Capture";var NotValidReason: Text) IsValid: Boolean
    var
        SoapAction: Text;
        XmlDocRequest: DotNet XmlDocument;
        XmlDocResponse: DotNet XmlDocument;
    begin

        MemberCardNumberValidationRequest (ForeignMembercardNumber, '', SoapAction, XmlDocRequest);
        if (not WebServiceApi (NPRRemoteEndpointSetup, SoapAction, NotValidReason, XmlDocRequest, XmlDocResponse)) then
          exit (false);

        IsValid := MemberCardNumberValidationResponse (Prefix, ForeignMembercardNumber, XmlDocResponse, NotValidReason, RemoteInfoCapture);
        exit (IsValid);
    end;

    local procedure GetMembership(NPRRemoteEndpointSetup: Record "MM NPR Remote Endpoint Setup";Prefix: Code[10];ForeignMembercardNumber: Text[50];var ForeignMembershipNumber: Code[20];var RemoteInfoCapture: Record "MM Member Info Capture";var NotValidReason: Text) IsValid: Boolean
    var
        SoapAction: Text;
        XmlDocRequest: DotNet XmlDocument;
        XmlDocResponse: DotNet XmlDocument;
    begin

        GetMembershipRequest (ForeignMembercardNumber, '', SoapAction, XmlDocRequest);
        if (not WebServiceApi (NPRRemoteEndpointSetup, SoapAction, NotValidReason, XmlDocRequest, XmlDocResponse)) then
          exit (false);

        IsValid := GetMembershipResponse (Prefix, ForeignMembershipNumber, XmlDocResponse, NotValidReason, RemoteInfoCapture);

        if (StrLen (RemoteInfoCapture."External Card No.") >= 4) then
          RemoteInfoCapture."External Card No. Last 4" := CopyStr (RemoteInfoCapture."External Card No.", StrLen (RemoteInfoCapture."External Card No.")-4+1);

        exit (IsValid);
    end;

    local procedure GetMember(NPRRemoteEndpointSetup: Record "MM NPR Remote Endpoint Setup";Prefix: Code[10];ForeignMembercardNumber: Text[50];ForeignMembershipNumber: Code[20];var RemoteInfoCapture: Record "MM Member Info Capture";var NotValidReason: Text) IsValid: Boolean
    var
        SoapAction: Text;
        XmlDocRequest: DotNet XmlDocument;
        XmlDocResponse: DotNet XmlDocument;
    begin

        GetMembershipMemberRequest (ForeignMembershipNumber, ForeignMembercardNumber, '', SoapAction, XmlDocRequest);
        if (not WebServiceApi (NPRRemoteEndpointSetup, SoapAction, NotValidReason, XmlDocRequest, XmlDocResponse)) then
          exit (false);

        IsValid := GetMembershipMemberResponse (Prefix, XmlDocResponse, NotValidReason, RemoteInfoCapture);

        exit (IsValid);
    end;

    local procedure CreateMembership(MemberInfoCapture: Record "MM Member Info Capture";NotValidReason: Text) Success: Boolean
    var
        MembershipManagement: Codeunit "MM Membership Management";
        MembershipSalesSetup: Record "MM Membership Sales Setup";
    begin

        MembershipSalesSetup."Membership Code" := MemberInfoCapture."Membership Code";

        // NPR integration default setup
        MembershipSalesSetup."Valid From Base"  := MembershipSalesSetup."Valid From Base"::SALESDATE;
        MemberInfoCapture."Document Date" := Today;
        MemberInfoCapture."Valid Until" := Today;
        MembershipSalesSetup."Valid Until Calculation" := MembershipSalesSetup."Valid Until Calculation"::DATEFORMULA;
        Evaluate (MembershipSalesSetup."Duration Formula", '<+0D>');

        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::FOREIGN;
        exit (0 <> MembershipManagement.CreateMembershipAll (MembershipSalesSetup, MemberInfoCapture, true));
    end;

    local procedure UpdateMembershipPoints(NPRRemoteEndpointSetup: Record "MM NPR Remote Endpoint Setup";MembershipEntryNo: Integer;Prefix: Code[10];ForeignMembercardNumber: Text[50];var NotValidReason: Text) IsValid: Boolean
    var
        SoapAction: Text;
        XmlDocRequest: DotNet XmlDocument;
        XmlDocResponse: DotNet XmlDocument;
        ForeignMembershipNumber: Code[20];
        RemoteInfoCapture: Record "MM Member Info Capture";
        LoyaltyPointManagement: Codeunit "MM Loyalty Point Management";
    begin

        //-MM1.38 [338215]
        if (MembershipEntryNo = 0) then
          exit (false);

        GetLoyaltyPointRequest (ForeignMembercardNumber, '', SoapAction, XmlDocRequest);
        if (not WebServiceApi (NPRRemoteEndpointSetup, SoapAction, NotValidReason, XmlDocRequest, XmlDocResponse)) then
          exit (false);

        IsValid := GetLoyaltyPointResponse (Prefix, ForeignMembershipNumber, XmlDocResponse, NotValidReason, RemoteInfoCapture);

        if (IsValid) then
          LoyaltyPointManagement.SynchronizePointsAbsolute (MembershipEntryNo, Round (RemoteInfoCapture."Initial Loyalty Point Count", 1, '<'), Today);

        exit (IsValid);
    end;

    local procedure "--WSSupport"()
    begin
    end;

    procedure WebServiceApi(NPRRemoteEndpointSetup: Record "MM NPR Remote Endpoint Setup";SoapAction: Text;var ReasonText: Text;var XmlDocIn: DotNet XmlDocument;var XmlDocOut: DotNet XmlDocument): Boolean
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        Credential: DotNet NetworkCredential;
        HttpWebRequest: DotNet HttpWebRequest;
        HttpWebResponse: DotNet HttpWebResponse;
        WebException: DotNet WebException;
        WebInnerException: DotNet WebException;
        Url: Text;
        ErrorMessage: Text;
        ResponseText: Text;
        Exception: DotNet Exception;
        StatusCode: Code[10];
        StatusDescription: Text[50];
    begin

        ReasonText := '';
        HttpWebRequest := HttpWebRequest.Create (NPRRemoteEndpointSetup."Endpoint URI");
        HttpWebRequest.Timeout := NPRRemoteEndpointSetup."Connection Timeout (ms)";

        case NPRRemoteEndpointSetup."Credentials Type" of
          NPRRemoteEndpointSetup."Credentials Type"::NAMED :
            begin
              HttpWebRequest.UseDefaultCredentials (false);
              if (NPRRemoteEndpointSetup."User Domain" <> '') then
                Credential := Credential.NetworkCredential (StrSubstNo ('%1/%2',NPRRemoteEndpointSetup."User Domain",NPRRemoteEndpointSetup."User Account"), NPRRemoteEndpointSetup."User Password")
              else
                Credential := Credential.NetworkCredential (NPRRemoteEndpointSetup."User Account", NPRRemoteEndpointSetup."User Password");

              HttpWebRequest.Credentials (Credential);
            end;
          else
            HttpWebRequest.UseDefaultCredentials (true);
        end;

        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'text/xml; charset=utf-8';
        HttpWebRequest.Headers.Add ('SOAPAction', SoapAction);

        NpXmlDomMgt.SetTrustedCertificateValidation (HttpWebRequest);

        if (TrySendWebRequest (XmlDocIn, HttpWebRequest, HttpWebResponse)) then begin
          TryReadResponseText (HttpWebResponse, ResponseText);
          XmlDocOut := XmlDocOut.XmlDocument;
          XmlDocOut.LoadXml (ResponseText);
          exit (true);
        end;

        Exception := GetLastErrorObject();
        ReasonText := StrSubstNo ('Error from WebServiceApi %1\\%2\\%3', GetLastErrorText, SoapAction, Exception.ToString());

        if (Format (GetDotNetType (Exception.GetBaseException ())) <> 'System.Net.WebException') then
          Error (ReasonText);

        WebException := Exception.GetBaseException ();
        TryReadExceptionResponseText (WebException, StatusCode, StatusDescription, ResponseText);

        XmlDocOut := XmlDocOut.XmlDocument;
        if (StrLen (ResponseText) > 0) then
          XmlDocOut.LoadXml (ResponseText);

        if (StrLen (ResponseText) = 0) then
          XmlDocOut.LoadXml (StrSubstNo (
            '<Fault>'+
              '<faultstatus>%1</faultstatus>'+
              '<faultstring>%2</faultstring>'+
            '</Fault>',
            StatusCode,
            StatusDescription));

        Message ('Remote service %4 returned:\\%1 %2 %3', StatusCode, StatusDescription, ResponseText, NPRRemoteEndpointSetup."Endpoint URI");
        exit (false);
    end;

    local procedure "--SoapRequest and Response"()
    begin
    end;

    procedure MemberCardNumberValidationRequest(ExternalMembercardNumber: Text[100];ScannerStationId: Text;var SoapAction: Text[50];var XmlDoc: DotNet XmlDocument)
    var
        XmlRequest: Text;
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
    begin

        SoapAction := 'MemberCardNumberValidation';
        XmlRequest :=
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:mem="urn:microsoft-dynamics-schemas/codeunit/member_services">'+
          '   <soapenv:Header/>'+
          '   <soapenv:Body>'+
          '      <mem:MemberCardNumberValidation>'+
          '         <mem:externalMemberCardNo>%1</mem:externalMemberCardNo>'+
          '         <mem:scannerStationId>%2</mem:scannerStationId>'+
          '      </mem:MemberCardNumberValidation>'+
          '   </soapenv:Body>'+
          '</soapenv:Envelope>';

        XmlRequest := StrSubstNo (XmlRequest, ExternalMembercardNumber, ScannerStationId);

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml (XmlRequest);
    end;

    local procedure MemberCardNumberValidationResponse(Prefix: Code[10];ForeignMembercardNumber: Text[50];var XmlDoc: DotNet XmlDocument;var ResponseText: Text;var MemberInfoCapture: Record "MM Member Info Capture") ValidResponse: Boolean
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlElement: DotNet XmlElement;
        PayloadBody: Text;
        TextOk: Text;
    begin

        NpXmlDomMgt.RemoveNameSpaces (XmlDoc);
        XmlElement := XmlDoc.DocumentElement;
        if (IsNull(XmlElement)) then begin
          ResponseText := StrSubstNo (InvalidXml, NpXmlDomMgt.PrettyPrintXml (XmlDoc.InnerXml()));
          exit (false);
        end;

        TextOk := NpXmlDomMgt.GetXmlText (XmlElement, '//MemberCardNumberValidation_Result/return_value', 5, false);
        MemberInfoCapture."External Card No." := Prefix + ForeignMembercardNumber;
        if (StrLen (ForeignMembercardNumber) >= 4) then
          MemberInfoCapture."External Card No. Last 4" := CopyStr (ForeignMembercardNumber, StrLen (ForeignMembercardNumber)-4+1);

        exit (UpperCase (TextOk) = 'TRUE');
    end;

    local procedure GetMembershipRequest(ExternalMembercardNumber: Text[50];ScannerStationId: Text;var SoapAction: Text[50];var XmlDoc: DotNet XmlDocument)
    var
        XmlRequest: Text;
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
    begin

        SoapAction := 'GetMembership';
        XmlRequest :=
         '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:mem="urn:microsoft-dynamics-schemas/codeunit/member_services">'+
         '   <soapenv:Header/>'+
         '   <soapenv:Body>'+
         '      <mem:GetMembership>'+
         '         <mem:membership>'+
         '            <getmembership>'+
         '               <request>'+
         '                  <membernumber></membernumber>'+
         '                  <cardnumber>%1</cardnumber>'+
         '                  <membershipnumber></membershipnumber>'+
         '                  <username></username>'+
         '                  <password></password>'+
         '                  <customernumber></customernumber>'+
         '               </request>'+
         '            </getmembership>'+
         '          </mem:membership>'+
         '         <mem:scannerStationId>%2</mem:scannerStationId>'+
         '      </mem:GetMembership>'+
         '   </soapenv:Body>'+
         '</soapenv:Envelope>';

        XmlRequest := StrSubstNo (XmlRequest, ExternalMembercardNumber, ScannerStationId);

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml (XmlRequest);
    end;

    local procedure GetMembershipResponse(Prefix: Code[10];var ForeignMembershipNumber: Code[20];var XmlDoc: DotNet XmlDocument;var ResponseText: Text;var MemberInfoCapture: Record "MM Member Info Capture") ValidResponse: Boolean
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlElement: DotNet XmlElement;
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

        NpXmlDomMgt.RemoveNameSpaces (XmlDoc);
        XmlElement := XmlDoc.DocumentElement;
        if (IsNull(XmlElement)) then begin
          ResponseText := StrSubstNo (InvalidXml, NpXmlDomMgt.PrettyPrintXml (XmlDoc.InnerXml()));
          exit (false);
        end;

        ElementPath := '//GetMembership_Result/membership/getmembership/response/';
        TextOk := NpXmlDomMgt.GetXmlText (XmlElement, ElementPath + 'status', 5, false);
        ResponseText := NpXmlDomMgt.GetXmlText (XmlElement, ElementPath + 'errordescription', 1000, false);
        if (TextOk = '0') then
          exit (false);

        ElementPath := '//GetMembership_Result/membership/getmembership/response/membership/';

        with MemberInfoCapture do begin
          "Membership Code" := Prefix + NpXmlDomMgt.GetXmlText (XmlElement, ElementPath+'/membershipcode', MaxStrLen ("Membership Code"), false);
          ForeignMembershipNumber := NpXmlDomMgt.GetXmlText (XmlElement, ElementPath+'/membershipnumber', MaxStrLen ("External Membership No."), false);
          "External Membership No." := Prefix + ForeignMembershipNumber;
        end;

        exit (true);
    end;

    local procedure GetMembershipMemberRequest(ExternalMembershipNumber: Code[20];ExternalMembercardNumber: Text[50];ScannerStationId: Text;var SoapAction: Text[50];var XmlDoc: DotNet XmlDocument)
    var
        XmlRequest: Text;
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
    begin

        SoapAction := 'GetMembershipMembers';
        XmlRequest :=
         '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:mem="urn:microsoft-dynamics-schemas/codeunit/member_services">'+
         '   <soapenv:Header/>'+
         '   <soapenv:Body>'+
         '      <mem:GetMembershipMembers>'+
         '         <mem:member>'+
         '            <getmembers>'+
         '               <request>'+
         '                  <membershipnumber>%1</membershipnumber>'+
         '                  <membernumber></membernumber>'+
         '                  <cardnumber>%2</cardnumber>'+
         '               </request>'+
         '            </getmembers>'+
         '         </mem:member>'+
         '         <mem:scannerStationId>%3</mem:scannerStationId>'+
         '      </mem:GetMembershipMembers>'+
         '   </soapenv:Body>'+
         '</soapenv:Envelope>';

        XmlRequest := StrSubstNo (XmlRequest, ExternalMembershipNumber, ExternalMembercardNumber, ScannerStationId);

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml (XmlRequest);
    end;

    local procedure GetMembershipMemberResponse(Prefix: Code[10];var XmlDoc: DotNet XmlDocument;var ResponseText: Text;var MemberInfoCapture: Record "MM Member Info Capture"): Boolean
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlElement: DotNet XmlElement;
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

        NpXmlDomMgt.RemoveNameSpaces (XmlDoc);
        XmlElement := XmlDoc.DocumentElement;
        if (IsNull(XmlElement)) then begin
          ResponseText := StrSubstNo (InvalidXml, NpXmlDomMgt.PrettyPrintXml (XmlDoc.InnerXml()));
          exit (false);
        end;

        ElementPath := '//GetMembershipMembers_Result/member/getmembers/response/';
        TextOk := NpXmlDomMgt.GetXmlText (XmlElement, ElementPath + 'status', 5, false);
        ResponseText := NpXmlDomMgt.GetXmlText (XmlElement, ElementPath + 'errordescription', 1000, false);
        if (TextOk = '0') then
          exit (false);

        ElementPath := '//GetMembershipMembers_Result/member/getmembers/response/member/';
        with MemberInfoCapture do begin
          "First Name" := NpXmlDomMgt.GetXmlText (XmlElement, ElementPath + 'firstname', MaxStrLen ("First Name"), false);
          "Middle Name" := NpXmlDomMgt.GetXmlText (XmlElement, ElementPath + 'middlename', MaxStrLen ("Middle Name"), false);
          "Last Name" := NpXmlDomMgt.GetXmlText (XmlElement, ElementPath + 'lastname', MaxStrLen ("Last Name"), false);
          Address := NpXmlDomMgt.GetXmlText (XmlElement, ElementPath + 'address', MaxStrLen (Address), false);
          "Post Code Code" := NpXmlDomMgt.GetXmlText (XmlElement, ElementPath + 'postcode', MaxStrLen ("Post Code Code"), false);
          City := NpXmlDomMgt.GetXmlText (XmlElement, ElementPath + 'city', MaxStrLen (City), false);
          "Country Code" := NpXmlDomMgt.GetXmlText (XmlElement, ElementPath + 'country', MaxStrLen ("Country Code"), false);

          if (Evaluate (Birthday, NpXmlDomMgt.GetXmlText (XmlElement, ElementPath + 'birthday', 10, false))) then ;
          if (Evaluate (Gender, NpXmlDomMgt.GetXmlText (XmlElement, ElementPath + 'gender', 1, false))) then ;
          if (Evaluate ("News Letter", NpXmlDomMgt.GetXmlText (XmlElement, ElementPath + 'newsletter', 1, false))) then ;

          "Phone No." := NpXmlDomMgt.GetXmlText (XmlElement, ElementPath + 'phoneno', MaxStrLen ("Phone No."), false);
          "E-Mail Address" := NpXmlDomMgt.GetXmlText (XmlElement, ElementPath + 'email', MaxStrLen ("E-Mail Address" ), false);
        end;

        exit (true);
    end;

    local procedure GetLoyaltyPointRequest(ExternalMembercardNumber: Text[50];ScannerStationId: Text;var SoapAction: Text[50];var XmlDoc: DotNet XmlDocument)
    var
        XmlRequest: Text;
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
    begin

        SoapAction := 'GetLoyaltyPoints';
        XmlRequest :=
        '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:loy="urn:microsoft-dynamics-schemas/codeunit/loyalty_services" xmlns:x60="urn:microsoft-dynamics-nav/xmlports/x6060141">'+
        '   <soapenv:Header/>'+
        '   <soapenv:Body>'+
        '      <loy:GetLoyaltyPoints>'+
        '         <loy:getLoyaltyPoints>'+
        '            <x60:getloyaltypoints>'+
        '               <x60:request>'+
        '                  <x60:cardnumber>%1</x60:cardnumber>'+
        '                  <x60:membershipnumber></x60:membershipnumber>'+
        '                  <x60:customernumber></x60:customernumber>'+
        '               </x60:request>'+
        '             </x60:getloyaltypoints>'+
        '          </loy:getLoyaltyPoints>'+
        '      </loy:GetLoyaltyPoints>'+
        '   </soapenv:Body>'+
        '</soapenv:Envelope>';

        XmlRequest := StrSubstNo (XmlRequest, ExternalMembercardNumber);

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml (XmlRequest);
    end;

    local procedure GetLoyaltyPointResponse(Prefix: Code[10];var ForeignMembershipNumber: Code[20];var XmlDoc: DotNet XmlDocument;var ResponseText: Text;var MemberInfoCapture: Record "MM Member Info Capture") ValidResponse: Boolean
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlElement: DotNet XmlElement;
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


        NpXmlDomMgt.RemoveNameSpaces (XmlDoc);
        XmlElement := XmlDoc.DocumentElement;
        if (IsNull(XmlElement)) then begin
          ResponseText := StrSubstNo (InvalidXml, NpXmlDomMgt.PrettyPrintXml (XmlDoc.InnerXml()));
          exit (false);
        end;

        ElementPath := '//GetLoyaltyPoints_Result/getLoyaltyPoints/getloyaltypoints/response/status';
        TextOk := NpXmlDomMgt.GetXmlText (XmlElement, ElementPath + 'responsecode', 5, false);
        ResponseText := NpXmlDomMgt.GetXmlText (XmlElement, ElementPath + 'responsemessage', 1000, false);
        if (TextOk = '0') then
          exit (false);

        ElementPath := '//GetLoyaltyPoints_Result/getLoyaltyPoints/getloyaltypoints/response/membership';

        with MemberInfoCapture do begin
          "Membership Code" := Prefix + NpXmlDomMgt.GetXmlText (XmlElement, ElementPath+'/membershipcode', MaxStrLen ("Membership Code"), false);
          ForeignMembershipNumber := NpXmlDomMgt.GetXmlText (XmlElement, ElementPath+'/membershipnumber', MaxStrLen ("External Membership No."), false);
          "External Membership No." := Prefix + ForeignMembershipNumber;
          Points := NpXmlDomMgt.GetXmlText (XmlElement, ElementPath+'/pointsummary/remaining', 10, false);
          if (not Evaluate ("Initial Loyalty Point Count", Points)) then
            "Initial Loyalty Point Count" := 0;
        end;

        exit (true);
        //+MM1.38 [338215]
    end;

    [TryFunction]
    local procedure TrySendWebRequest(var XmlDoc: DotNet XmlDocument;HttpWebRequest: DotNet HttpWebRequest;var HttpWebResponse: DotNet HttpWebResponse)
    var
        MemoryStream: DotNet MemoryStream;
    begin

        MemoryStream := HttpWebRequest.GetRequestStream;
        XmlDoc.Save(MemoryStream);
        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);
        HttpWebResponse := HttpWebRequest.GetResponse;
    end;

    [TryFunction]
    local procedure TryReadResponseText(var HttpWebResponse: DotNet HttpWebResponse;var ResponseText: Text)
    var
        Stream: DotNet Stream;
        StreamReader: DotNet StreamReader;
    begin

        Stream := HttpWebResponse.GetResponseStream;
        StreamReader := StreamReader.StreamReader(Stream);
        ResponseText := StreamReader.ReadToEnd;
        Stream.Flush;
        Stream.Close;
        Clear(Stream);
    end;

    [TryFunction]
    local procedure TryReadExceptionResponseText(var WebException: DotNet WebException;var StatusCode: Code[10];var StatusDescription: Text;var ResponseXml: Text)
    var
        Stream: DotNet Stream;
        StreamReader: DotNet StreamReader;
        WebResponse: DotNet WebResponse;
        HttpWebResponse: DotNet HttpWebResponse;
        WebExceptionStatus: DotNet WebExceptionStatus;
        SystemConvert: DotNet Convert;
        StatusCodeInt: Integer;
    begin

        ResponseXml := '';

        // No respone body on time out
        if (WebException.Status.Equals (WebExceptionStatus.Timeout)) then  begin
          StatusCodeInt := SystemConvert.ChangeType (WebExceptionStatus.Timeout, GetDotNetType (StatusCodeInt));
          StatusCode := Format (StatusCodeInt);
          StatusDescription := WebExceptionStatus.Timeout.ToString();
          exit;
        end;

        // This happens for unauthorized and server side faults (4xx and 5xx)
        // The response stream in unauthorized fails in XML transformation later
        if (WebException.Status.Equals (WebExceptionStatus.ProtocolError)) then begin
          HttpWebResponse := WebException.Response ();
          StatusCodeInt := SystemConvert.ChangeType (HttpWebResponse.StatusCode, GetDotNetType (StatusCodeInt));
          StatusCode := Format (StatusCodeInt);
          StatusDescription := HttpWebResponse.StatusDescription;
          if (StatusCode[1] = '4') then // 4xx messages
            exit;
        end;

        StreamReader := StreamReader.StreamReader(WebException.Response().GetResponseStream());
        ResponseXml := StreamReader.ReadToEnd;

        StreamReader.Close;
        Clear (StreamReader);
    end;

    [TryFunction]
    local procedure TryGetWebExceptionResponse(var WebException: DotNet WebException;var HttpWebResponse: DotNet HttpWebResponse)
    begin

        HttpWebResponse := WebException.Response;
    end;

    [TryFunction]
    local procedure TryGetInnerWebException(var WebException: DotNet WebException;var InnerWebException: DotNet WebException)
    begin

        InnerWebException := WebException.InnerException;
    end;
}

