codeunit 6060142 "NPR MM Loyalty WebService Mgr"
{

    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    var
        XmlDoc: DotNet "NPRNetXmlDocument";
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

    local procedure GetLoyaltyPoints(XmlDoc: DotNet "NPRNetXmlDocument"; DocumentID: Text[100])
    var
        XmlElement: DotNet NPRNetXmlElement;
        XmlElementNode: DotNet NPRNetXmlElement;
        XmlNodeList: DotNet NPRNetXmlNodeList;
        i: Integer;
    begin

        if IsNull(XmlDoc) then
            exit;

        XmlElement := XmlDoc.DocumentElement;

        if IsNull(XmlElement) then
            exit;

        if (not NpXmlDomMgt.FindNodes(XmlElement, 'request', XmlNodeList)) then
            Error('request node not found.');

        XmlElementNode := XmlNodeList.ItemOf(0);
        DecodeLoyaltyPointsQuery(XmlElementNode, DocumentID);

    end;

    local procedure "--Handlers"()
    begin
    end;

    local procedure DecodeLoyaltyPointsQuery(XmlElement: DotNet NPRNetXmlElement; DocumentID: Text[100]) Imported: Boolean
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

        if IsNull(XmlElement) then
            exit(false);

        MemberInfoCapture.Init();
        MemberInfoCapture."Import Entry Document ID" := DocumentID;
        DeserializeMembershipQuery(XmlElement, MemberInfoCapture);

        if (MemberInfoCapture."External Membership No." <> '') then
            MemberInfoCapture."Membership Entry No." := MembershipManagement.GetMembershipFromExtMembershipNo(MemberInfoCapture."External Membership No.");

        if (MemberInfoCapture."External Card No." <> '') then begin

            //IF (MemberInfoCapture."Member Entry No" = 0) THEN
            //  MemberInfoCapture."Membership Entry No." := MembershipManagement.GetMembershipFromExtCardNo(MemberInfoCapture."External Card No.", WORKDATE, NotFoundReason);
            if (MemberInfoCapture."Membership Entry No." = 0) then
                MemberInfoCapture."Membership Entry No." := MembershipManagement.GetMembershipFromExtCardNo(MemberInfoCapture."External Card No.", WorkDate, NotFoundReason);

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

    local procedure DeserializeMembershipQuery(XmlElement: DotNet NPRNetXmlElement; var MemberInfoCapture: Record "NPR MM Member Info Capture")
    var
        CustomerNo: Code[20];
        Membership: Record "NPR MM Membership";
    begin

        MemberInfoCapture."Entry No." := 0;
        MemberInfoCapture."External Member No" := NpXmlDomMgt.GetXmlText(XmlElement, 'membernumber', MaxStrLen(MemberInfoCapture."External Member No"), false);
        MemberInfoCapture."External Card No." := NpXmlDomMgt.GetXmlText(XmlElement, 'cardnumber', MaxStrLen(MemberInfoCapture."External Card No."), false);
        MemberInfoCapture."External Membership No." := NpXmlDomMgt.GetXmlText(XmlElement, 'membershipnumber', MaxStrLen(MemberInfoCapture."External Membership No."), false);

        CustomerNo := NpXmlDomMgt.GetXmlText(XmlElement, 'customernumber', 20, false);
        if (CustomerNo <> '') then begin
            Membership.SetFilter("Customer No.", '=%1', CustomerNo);
            Membership.SetFilter(Blocked, '=%1', false);
            if (Membership.FindFirst()) then

                //MemberInfoCapture."External Member No" := Membership."External Membership No.";
                //MemberInfoCapture."External Membership No." := Membership."External Membership No.";

                if (MemberInfoCapture."External Membership No." = '') then 
                    MemberInfoCapture."External Membership No." := Membership."External Membership No.";
            if (MemberInfoCapture."External Membership No." <> Membership."External Membership No.") then
                MemberInfoCapture."External Membership No." := '';

        end;

        MemberInfoCapture.Insert
    end;

    local procedure GetWebserviceFunction(ImportTypeCode: Code[20]) FunctionName: Text[100]
    var
        ImportType: Record "NPR Nc Import Type";
    begin

        Clear(ImportType);
        ImportType.SetFilter(Code, '=%1', ImportTypeCode);
        if (ImportType.FindFirst()) then;

        exit(ImportType."Webservice Function");
    end;
}

