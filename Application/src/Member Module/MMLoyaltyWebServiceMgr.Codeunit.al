codeunit 6060142 "NPR MM Loyalty WebService Mgr"
{

    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    var
        XmlDoc: XmlDocument;
        FunctionName: Text[100];
    begin

        if LoadXmlDoc(XmlDoc) then begin
            FunctionName := GetWebserviceFunction("Import Type");
            case FunctionName of
                'GetLoyaltyPoints':
                    GetLoyaltyPoints(XmlDoc, Rec."Document ID");
                'GetLoyaltyPointEntries':
                    GetLoyaltyPoints(XmlDoc, Rec."Document ID");
                'GetLoyaltyReceiptList':
                    GetLoyaltyPoints(XmlDoc, Rec."Document ID");

                else
                    Error('Implementation for %1 %2 missing in codeunit 6060142', "Import Type", FunctionName);
            end;

        end;
    end;

    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        MEMBERSHIP_NOT_FOUND: Label 'The membership could not be found using the provided search criteria.';

    local procedure GetLoyaltyPoints(XmlDoc: XmlDocument; DocumentID: Text[100])
    var
        Request: XmlElement;
        NodeList: XmlNodeList;
        Node: XmlNode;
    begin

        XmlDoc.GetRoot(Request);

        if (not NpXmlDomMgt.FindNodes(Request.AsXmlNode(), 'request', NodeList)) then
            Error('request node not found.');

        foreach Node in NodeList do
            DecodeLoyaltyPointsQuery(Node.AsXmlElement(), DocumentID);

    end;

    local procedure "--Handlers"()
    begin
    end;

    local procedure DecodeLoyaltyPointsQuery(Request: XmlElement; DocumentID: Text[100]): Boolean
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        Membership: Record "NPR MM Membership";
        NotFoundReason: Text;
    begin

        MemberInfoCapture.Init();
        MemberInfoCapture."Import Entry Document ID" := DocumentID;
        DeserializeMembershipQuery(Request, MemberInfoCapture);

        if (MemberInfoCapture."External Membership No." <> '') then
            MemberInfoCapture."Membership Entry No." := MembershipManagement.GetMembershipFromExtMembershipNo(MemberInfoCapture."External Membership No.");

        if (MemberInfoCapture."External Card No." <> '') then begin

            if (MemberInfoCapture."Membership Entry No." = 0) then
                MemberInfoCapture."Membership Entry No." := MembershipManagement.GetMembershipFromExtCardNo(MemberInfoCapture."External Card No.", WorkDate(), NotFoundReason);

        end;

        if (MemberInfoCapture."Membership Entry No." = 0) then
            Error(MEMBERSHIP_NOT_FOUND);

        if (not Membership.Get(MemberInfoCapture."Membership Entry No.")) then
            Error(MEMBERSHIP_NOT_FOUND);

        MemberInfoCapture.Modify();

        exit(true);
    end;

    local procedure "--"()
    begin
    end;

    local procedure DeserializeMembershipQuery(Request: XmlElement; var MemberInfoCapture: Record "NPR MM Member Info Capture")
    var
        CustomerNo: Code[20];
        Membership: Record "NPR MM Membership";
    begin

        MemberInfoCapture."Entry No." := 0;
        MemberInfoCapture."External Member No" := NpXmlDomMgt.GetXmlText(Request, 'membernumber', MaxStrLen(MemberInfoCapture."External Member No"), false);
        MemberInfoCapture."External Card No." := NpXmlDomMgt.GetXmlText(Request, 'cardnumber', MaxStrLen(MemberInfoCapture."External Card No."), false);
        MemberInfoCapture."External Membership No." := NpXmlDomMgt.GetXmlText(Request, 'membershipnumber', MaxStrLen(MemberInfoCapture."External Membership No."), false);

        CustomerNo := NpXmlDomMgt.GetXmlText(Request, 'customernumber', 20, false);
        if (CustomerNo <> '') then begin
            Membership.SetFilter("Customer No.", '=%1', CustomerNo);
            Membership.SetFilter(Blocked, '=%1', false);
            if (Membership.FindFirst()) then
                if (MemberInfoCapture."External Membership No." = '') then
                    MemberInfoCapture."External Membership No." := Membership."External Membership No.";

            if (MemberInfoCapture."External Membership No." <> Membership."External Membership No.") then
                MemberInfoCapture."External Membership No." := '';

        end;

        MemberInfoCapture.Insert()
    end;

    local procedure GetWebserviceFunction(ImportTypeCode: Code[20]): Text[100]
    var
        ImportType: Record "NPR Nc Import Type";
    begin

        Clear(ImportType);
        ImportType.SetFilter(Code, '=%1', ImportTypeCode);
        if (ImportType.FindFirst()) then;

        exit(ImportType."Webservice Function");
    end;
}

