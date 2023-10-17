﻿codeunit 6060142 "NPR MM Loyalty WebService Mgr" implements "NPR Nc Import List IProcess"
{
    Access = Internal;
    TableNo = "NPR Nc Import Entry";
    trigger OnRun()
    begin

    end;

    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        MEMBERSHIP_NOT_FOUND: Label 'The membership could not be found using the provided search criteria.';

    internal procedure RunProcessImportEntry(ImportEntry: Record "NPR Nc Import Entry")
    var
        XmlDoc: XmlDocument;
        FunctionName: Text[100];
    begin

        if (ImportEntry.LoadXmlDoc(XmlDoc)) then begin
            FunctionName := GetWebServiceFunction(ImportEntry."Import Type");
            case FunctionName of
                'GetLoyaltyPoints':
                    GetLoyaltyPoints(XmlDoc, ImportEntry."Document ID");
                'GetLoyaltyPointEntries':
                    GetLoyaltyPoints(XmlDoc, ImportEntry."Document ID");
                'GetLoyaltyReceiptList':
                    GetLoyaltyPoints(XmlDoc, ImportEntry."Document ID");

                else
                    Error('Implementation for %1 %2 missing in codeunit 6060142', ImportEntry."Import Type", FunctionName);
            end;

            ClearLastError();

        end;
    end;


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

    local procedure DeserializeMembershipQuery(Request: XmlElement; var MemberInfoCapture: Record "NPR MM Member Info Capture")
    var
        CustomerNo: Code[20];
        Membership: Record "NPR MM Membership";
    begin

        MemberInfoCapture."Entry No." := 0;
        MemberInfoCapture."External Member No" := GetXmlText20(Request, 'membernumber', MaxStrLen(MemberInfoCapture."External Member No"), false);
        MemberInfoCapture."External Card No." := GetXmlText100(Request, 'cardnumber', MaxStrLen(MemberInfoCapture."External Card No."), false);
        MemberInfoCapture."External Membership No." := GetXmlText20(Request, 'membershipnumber', MaxStrLen(MemberInfoCapture."External Membership No."), false);

        CustomerNo := GetXmlText20(Request, 'customernumber', MaxStrLen(CustomerNo), false);
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

    local procedure GetWebServiceFunction(ImportTypeCode: Code[20]): Text[100]
    var
        ImportType: Record "NPR Nc Import Type";
    begin

        Clear(ImportType);
        ImportType.SetFilter(Code, '=%1', ImportTypeCode);
        if (ImportType.FindFirst()) then;

        exit(ImportType."Webservice Function");
    end;

#pragma warning disable AA0139
    local procedure GetXmlText20(Element: XmlElement; NodePath: Text; MaxLength: Integer; Required: Boolean): Text[20]
    begin
        exit(NpXmlDomMgt.GetXmlText(Element, NodePath, MaxLength, Required));
    end;

    local procedure GetXmlText100(Element: XmlElement; NodePath: Text; MaxLength: Integer; Required: Boolean): Text[100]
    begin
        exit(NpXmlDomMgt.GetXmlText(Element, NodePath, MaxLength, Required));
    end;
#pragma warning restore
}
