codeunit 6060142 "NPR MM Loyalty WebService Mgr"
{

    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    var
        XmlDoc: XmlDocument;
        ImportType: Record "NPR Nc Import Type";
        FunctionName: Text[100];
    begin

        if LoadXmlDoc(XmlDoc) then begin
            FunctionName := GetWebserviceFunction("Import Type");
            case FunctionName of
                'GetLoyaltyPoints':
                    GetLoyaltyPoints(XmlDoc, "Document ID");
                'GetLoyaltyPointEntries':
                    GetLoyaltyPoints(XmlDoc, "Document ID");
                'GetLoyaltyReceiptList':
                    GetLoyaltyPoints(XmlDoc, "Document ID");

                else
                    Error('Implementation for %1 %2 missing in codeunit 6060142', "Import Type", FunctionName);
            end;

        end;
    end;

    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        MEMBERSHIP_NOT_FOUND: Label 'The membership could not be found using the provided search criteria.';
        RequestNotFoundErr: Label 'Request node not found.';

    local procedure GetLoyaltyPoints(XmlDoc: XmlDocument; DocumentID: Text[100])
    var
        Element: XmlElement;
        ElementNode: XmlNode;
        NodeList: XmlNodeList;
        i: Integer;
    begin
        XmlDoc.GetRoot(Element);

        if Element.IsEmpty then
            exit;

        if (not Element.SelectNodes('request', NodeList)) then
            Error(RequestNotFoundErr);

        NodeList.Get(0, ElementNode);
        DecodeLoyaltyPointsQuery(ElementNode.AsXmlElement(), DocumentID);
    end;

    local procedure DecodeLoyaltyPointsQuery(Element: XmlElement; DocumentID: Text[100]) Imported: Boolean
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MembershipEntryNo: Integer;
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";
        Member: Record "NPR MM Member";
        NotFoundReason: Text;
        IsValid: Boolean;
    begin
        if Element.IsEmpty then
            exit(false);

        MemberInfoCapture.Init();
        MemberInfoCapture."Import Entry Document ID" := DocumentID;
        DeserializeMembershipQuery(Element, MemberInfoCapture);

        if (MemberInfoCapture."External Membership No." <> '') then
            MemberInfoCapture."Membership Entry No." :=
                MembershipManagement.GetMembershipFromExtMembershipNo(MemberInfoCapture."External Membership No.");

        if (MemberInfoCapture."External Card No." <> '') then begin
            if (MemberInfoCapture."Membership Entry No." = 0) then
                MemberInfoCapture."Membership Entry No." :=
                    MembershipManagement.GetMembershipFromExtCardNo(MemberInfoCapture."External Card No.", WorkDate, NotFoundReason);
        end;

        if (MemberInfoCapture."Membership Entry No." = 0) then
            Error(MEMBERSHIP_NOT_FOUND);

        if (not Membership.Get(MemberInfoCapture."Membership Entry No.")) then
            Error(MEMBERSHIP_NOT_FOUND);

        MemberInfoCapture.Modify();

        exit(true);
    end;

    local procedure DeserializeMembershipQuery(Element: XmlElement; var MemberInfoCapture: Record "NPR MM Member Info Capture")
    var
        CustomerNo: Code[20];
        Membership: Record "NPR MM Membership";
    begin

        MemberInfoCapture."Entry No." := 0;
        MemberInfoCapture."External Member No" := NpXmlDomMgt.GetXmlText(Element, 'membernumber', MaxStrLen(MemberInfoCapture."External Member No"), false);
        MemberInfoCapture."External Card No." := NpXmlDomMgt.GetXmlText(Element, 'cardnumber', MaxStrLen(MemberInfoCapture."External Card No."), false);
        MemberInfoCapture."External Membership No." := NpXmlDomMgt.GetXmlText(Element, 'membershipnumber', MaxStrLen(MemberInfoCapture."External Membership No."), false);

        CustomerNo := NpXmlDomMgt.GetXmlText(Element, 'customernumber', 20, false);
        if (CustomerNo <> '') then begin
            Membership.SetFilter("Customer No.", '=%1', CustomerNo);
            Membership.SetFilter(Blocked, '=%1', false);
            if (Membership.FindFirst()) then
                if (MemberInfoCapture."External Membership No." = '') then
                    MemberInfoCapture."External Membership No." := Membership."External Membership No.";
            if (MemberInfoCapture."External Membership No." <> Membership."External Membership No.") then
                MemberInfoCapture."External Membership No." := '';
        end;
        MemberInfoCapture.Insert;
    end;

    local procedure GetWebserviceFunction(ImportTypeCode: Code[20]) FunctionName: Text[100]
    var
        ImportType: Record "NPR Nc Import Type";
    begin
        Clear(ImportType);
        ImportType.SetFilter(Code, '=%1', ImportTypeCode);
        if not ImportType.FindFirst() then
            ImportType.Init;

        exit(ImportType."Webservice Function");
    end;
}

