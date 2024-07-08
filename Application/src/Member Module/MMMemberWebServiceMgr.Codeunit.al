﻿codeunit 6060129 "NPR MM Member WebService Mgr" implements "NPR Nc Import List IProcess"
{
    Access = Internal;
    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    begin
    end;

    internal procedure RunProcessImportEntry(ImportEntry: Record "NPR Nc Import Entry")
    var
        XmlDoc: XmlDocument;
        FunctionName: Text[100];
        MemberInfoCapture: Record "NPR MM Member Info Capture";
    begin

        if (ImportEntry.LoadXmlDoc(XmlDoc)) then begin

            Commit();
            ClearNstCache(XmlDoc);

            if (not MemberInfoCapture.IsEmpty()) then begin
                MemberInfoCapture.LockTable(true);
                MemberInfoCapture.FindLast();
            end;

            FunctionName := GetWebServiceFunction(ImportEntry."Import Type");
            case FunctionName of
                'CreateMembership':
                    ImportCreateMemberships(XmlDoc, ImportEntry."Document ID");

                'ConfirmMembershipPayment':
                    ImportConfirmMemberships(XmlDoc, ImportEntry."Document ID");
                'AddMembershipMember':
                    ImportAddMembershipMembers(XmlDoc, ImportEntry."Document ID");
                'AddAnonymousMember':
                    ImportAddAnonymousMembers(XmlDoc, ImportEntry."Document ID");
                'GetMembership':
                    ImportGetMemberships(XmlDoc, ImportEntry."Document ID");

                'GetMembershipTicketList':
                    ImportGetMembershipTicketList(XmlDoc, ImportEntry."Document ID");
                'GetMembershipMembers':
                    ImportGetMembershipMembers(XmlDoc, ImportEntry."Document ID");
                'UpdateMember':
                    ImportUpdateMembers(XmlDoc, ImportEntry."Document ID");
                'AddReplaceCard':
                    ImportAddReplaceCard(XmlDoc, ImportEntry."Document ID");

                'BlockMembership':
                    ImportBlockMemberships(XmlDoc, ImportEntry."Document ID");
                'BlockMember':
                    ImportBlockMembers(XmlDoc, ImportEntry."Document ID");

                'ChangeMembership':
                    ImportChangeMemberships(XmlDoc, ImportEntry."Document ID");
                'GetMembershipChangeItemsList':
                    ImportGetChangeMembershipList(XmlDoc, ImportEntry."Document ID", 'getchangemembershiplist/request');
                'RegretMembership':
                    ImportRegretMemberships(XmlDoc, ImportEntry."Document ID");

                'GetMembershipAutoRenewProduct':
                    ImportGetChangeMembershipList(XmlDoc, ImportEntry."Document ID", 'getautorenewproduct/request'); // Same filter implementation as for GetMembershipChangeItemsList
                'ConfirmAutoRenewPayment':
                    ImportGetChangeMembershipList(XmlDoc, ImportEntry."Document ID", 'confirmautorenewpayment/request'); // Same filter implementation as for GetMembershipChangeItemsList

                'SetGDPRApproval':
                    ImportGdprApproval(XmlDoc, ImportEntry."Document ID");
                'GetMembershipRoles':
                    ImportGetMembershipMembers(XmlDoc, ImportEntry."Document ID"); // Same as GetMembershipMembers

                'CreateWalletMemberPass':
                    CreateWallet(XmlDoc, ImportEntry."Document ID");

                'GetSetAutoRenewOption':
                    ; // Do nothing, handled by xmlport
                'GetSetMemberComOption':
                    ; // Do nothing, handled by xmlport */

                'SearchMembers':
                    ; // Do nothing, handled by xmlport */
                else
                    Error(MISSING_CASE, ImportEntry."Import Type", FunctionName);
            end;

            ClearLastError();

        end;
    end;

    local procedure ClearNstCache(XmlDoc: XmlDocument)
    var
        XmlRequestNode: XmlNodeList;
        XmlCacheId: XmlNode;
        CacheId: Text;
        XPath: Label '//request[1]/@cache_instance_id', Locked = true;
    begin

        CacheId := '';
        // Select the string representation value of the 'cache_instance_id' attribute of the first 'request' element
        if (XmlDoc.SelectNodes(XPath, XmlRequestNode)) then
            if (XmlRequestNode.Get(1, XmlCacheId)) then
                CacheId := XmlCacheId.AsXmlAttribute().Value();

        if ((CacheId = 'DoNotClearCache') or (CacheId = '-1')) then
            exit;

        if (CacheId <> Format(ServiceInstanceId(), 0, 9)) then
            SelectLatestVersion();
    end;

    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        INVALID_MEMBERSHIP_NO: Label 'Membership number %1 is not valid.';
        INVALID_MEMBER_NO: Label 'Member number %1 is not valid.';
        INVALID_MEMBER_CARD_NO: Label 'Member card number %1 is not valid.';
        NOT_FOUND: Label 'Not found.';
        NOT_ACTIVE: Label 'Membership %1 is not active.';
        MISSING_CASE: Label 'No handler for %1 [%2].';
        ILLEGAL_CHANGE_TYPE: Label 'No such change type %1.';
        TEXT6060000: Label 'The %1 %2 is already in use.';
        NOT_LAST_TIMEFRAME: Label 'Document ID %1 does not specify the last non-blocked timeframe for membership.';

    local procedure ImportCreateMemberships(XmlDoc: XmlDocument; DocumentID: Text[100])
    var
        Request: XmlElement;
        NodeList: XmlNodeList;
        Node: XmlNode;
    begin

        if (not XmlDoc.GetRoot(Request)) then
            exit;

        if (not NpXmlDomMgt.FindNodes(Request.AsXmlNode(), 'createmembership/request', NodeList)) then
            exit;

        foreach Node in NodeList do
            ImportCreateMembership(Node.AsXmlElement(), DocumentID);

        Commit();
    end;

    local procedure ImportCreateMembership(CreateMembershipRequest: XmlElement; DocumentID: Text[100]): Boolean
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        VATPostingSetup: Record "VAT Posting Setup";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        Membership: Record "NPR MM Membership";
        Item: Record Item;
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        MembershipSetup: Record "NPR MM Membership Setup";
    begin

        MemberInfoCapture.Init();
        MemberInfoCapture."Import Entry Document ID" := DocumentID;
        InsertCreateMembership(CreateMembershipRequest, MemberInfoCapture);

        TransferAttributes(CreateMembershipRequest, MemberInfoCapture);

        MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, MemberInfoCapture."Item No.");
        MembershipSalesSetup.TestField(Blocked, false);

        if (MemberInfoCapture.Amount = 0) then begin
            Item.Get(MemberInfoCapture."Item No.");
            MemberInfoCapture."Unit Price" := Item."Unit Price";

            VATPostingSetup.SetFilter("VAT Bus. Posting Group", '=%1', Item."VAT Bus. Posting Gr. (Price)");
            VATPostingSetup.SetFilter("VAT Prod. Posting Group", '=%1', Item."VAT Prod. Posting Group");
            if (not VATPostingSetup.FindFirst()) then
                VATPostingSetup.Init();

            if (Item."Price Includes VAT") then begin
                MemberInfoCapture."Amount Incl VAT" := Item."Unit Price";
                MemberInfoCapture.Amount := Round(MemberInfoCapture."Amount Incl VAT" / ((100 + VATPostingSetup."VAT %") / 100.0), 0.01);
            end else begin
                MemberInfoCapture.Amount := Item."Unit Price";
                MemberInfoCapture."Amount Incl VAT" := Round(MemberInfoCapture.Amount * ((100 + VATPostingSetup."VAT %") / 100.0), 0.01);
            end;

        end;

        MemberInfoCapture."Membership Entry No." := MembershipManagement.CreateMembership(MembershipSalesSetup, MemberInfoCapture, true);

        Membership.Get(MemberInfoCapture."Membership Entry No.");
        Membership."Document ID" := DocumentID;
        Membership.Modify();

        MemberInfoCapture."External Membership No." := Membership."External Membership No.";
        MemberInfoCapture.Modify();

        MembershipSetup.Get(Membership."Membership Code");
        case MembershipSetup."Web Service Print Action" of
            MembershipSetup."Web Service Print Action"::DIRECT:
                MemberRetailIntegration.PrintMembershipSalesReceiptWorker(Membership, MembershipSetup);
            MembershipSetup."Web Service Print Action"::OFFLINE:
                MembershipManagement.PrintOffline(MemberInfoCapture."Information Context"::PRINT_MEMBERSHIP, MemberInfoCapture."Membership Entry No.");
        end;

        exit(true);
    end;

    local procedure ImportConfirmMemberships(XmlDoc: XmlDocument; DocumentID: Text[100])
    var
        Request: XmlElement;
        NodeList: XmlNodeList;
        Node: XmlNode;
    begin

        if (not XmlDoc.GetRoot(Request)) then
            exit;

        if (not NpXmlDomMgt.FindNodes(Request.AsXmlNode(), 'confirmmembership/request', NodeList)) then
            exit;

        foreach Node in NodeList do
            ImportConfirmMembership(Node.AsXmlElement(), DocumentID);

        Commit();

    end;

    local procedure ImportConfirmMembership(Request: XmlElement; DocumentID: Text[100]): Boolean
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipEntry: Record "NPR MM Membership Entry";
        SalesHeader: Record "Sales Header";
        SponsorshipTicketMgmt: Codeunit "NPR MM Sponsorship Ticket Mgt";
        TargetDocumentId: Text[100];
    begin

        MemberInfoCapture.Init();
        MemberInfoCapture."Import Entry Document ID" := DocumentID;
        MemberInfoCapture.Insert();

        TargetDocumentId := GetXmlText100(Request, 'documentid', true);
        MembershipEntry.SetFilter("Import Entry Document ID", '=%1', TargetDocumentId);
        MembershipEntry.SetFilter(Blocked, '=%1', false);
        MembershipEntry.FindFirst();

        MemberInfoCapture."Document No." := GetXmlText20(Request, 'externaldocumentnumber', false);
        Evaluate(MemberInfoCapture.Amount, GetXmlText20(Request, 'amount', false), 9);
        Evaluate(MemberInfoCapture."Amount Incl VAT", GetXmlText20(Request, 'amountinclvat', false), 9);

        MemberInfoCapture."Membership Entry No." := MembershipEntry."Membership Entry No.";
        MemberInfoCapture.Modify();

        if (MemberInfoCapture."Document No." <> '') then begin
            MembershipEntry."Source Type" := MembershipEntry."Source Type"::SALESHEADER;
            MembershipEntry."Document Type" := SalesHeader."Document Type"::Order;
            MembershipEntry."Document No." := MemberInfoCapture."Document No.";
        end;

        if (MemberInfoCapture.Amount <> 0) then
            MembershipEntry.Amount := MemberInfoCapture.Amount;

        if (MemberInfoCapture."Amount Incl VAT" <> 0) then
            MembershipEntry."Amount Incl VAT" := MemberInfoCapture."Amount Incl VAT";

        MembershipEntry.Modify();

        SponsorshipTicketMgmt.OnMembershipPayment(MembershipEntry);

        exit(true);

    end;

    local procedure ImportAddMembershipMembers(XmlDoc: XmlDocument; DocumentID: Text[100])
    var
        Request: XmlElement;
        NodeList: XmlNodeList;
        Node: XmlNode;
    begin

        if (not XmlDoc.GetRoot(Request)) then
            exit;

        if (not NpXmlDomMgt.FindNodes(Request.AsXmlNode(), 'addmember/request', NodeList)) then
            exit;

        foreach Node in NodeList do
            ImportAddMembershipMember(Node.AsXmlElement(), DocumentID);

        Commit();
    end;

    local procedure ImportAddMembershipMember(Request: XmlElement; DocumentID: Text[100]): Boolean
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        MembershipEntryNo: Integer;
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberCard: Record "NPR MM Member Card";
        ResponseMessage: Text;
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        MembershipEntry: Record "NPR MM Membership Entry";
    begin

        MemberInfoCapture.Init();
        MemberInfoCapture."Import Entry Document ID" := DocumentID;
        GetXmlMembershipMemberInfo(Request, MemberInfoCapture);

        MemberInfoCapture.TestField("External Membership No.");

        if (MembershipManagement.GetMembershipFromExtCardNo(MemberInfoCapture."External Card No.", Today, ResponseMessage) <> 0) then
            Error(TEXT6060000, MemberInfoCapture.FieldCaption("External Card No."), MemberInfoCapture."External Card No.");

        MembershipEntryNo := MembershipManagement.GetMembershipFromExtMembershipNo(MemberInfoCapture."External Membership No.");
        if (MembershipEntryNo = 0) then
            Error(INVALID_MEMBERSHIP_NO, MemberInfoCapture."External Membership No.");

        Membership.Get(MembershipEntryNo);

        // There should probably be date constraints here to figure out exactly which item controls the age constrains. 
        MembershipEntry.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipEntry.SetFilter("Membership Code", '=%1', Membership."Membership Code");
        MembershipEntry.SetFilter(Blocked, '=%1', false);
        MembershipEntry.SetFilter(Context, '%1|%2|%3|%4|%5', MembershipEntry.Context::NEW, MembershipEntry.Context::RENEW, MembershipEntry.Context::UPGRADE, MembershipEntry.Context::EXTEND, MembershipEntry.Context::AUTORENEW);
        if (MembershipEntry.FindLast()) then
            MemberInfoCapture."Item No." := MembershipEntry."Item No.";

        TransferAttributes(Request, MemberInfoCapture);

        if (not (MembershipManagement.AddMemberAndCard(MembershipEntryNo, MemberInfoCapture, true, MemberInfoCapture."Member Entry No", ResponseMessage))) then
            Error(ResponseMessage);

        MemberInfoCapture.Modify();

        Member.Get(MemberInfoCapture."Member Entry No");
        Member."Document ID" := DocumentID;
        Member.Modify();

        MembershipSetup.Get(Membership."Membership Code");
        MemberCard.Get(MemberInfoCapture."Card Entry No.");
        MemberCard.SetRecFilter();
        case MembershipSetup."Web Service Print Action" of
            MembershipSetup."Web Service Print Action"::DIRECT:
                MemberRetailIntegration.PrintMemberCardWorker(MemberCard, MembershipSetup);
            MembershipSetup."Web Service Print Action"::OFFLINE:
                MembershipManagement.PrintOffline(MemberInfoCapture."Information Context"::PRINT_CARD, MemberInfoCapture."Card Entry No.");
        end;

        exit(true);
    end;

    local procedure ImportAddAnonymousMembers(XmlDoc: XmlDocument; DocumentID: Text[100])
    var
        Request: XmlElement;
        NodeList: XmlNodeList;
        Node: XmlNode;
    begin

        XmlDoc.GetRoot(Request);

        if (not NpXmlDomMgt.FindNodes(Request.AsXmlNode(), 'addmember/request', NodeList)) then
            exit;

        foreach Node in NodeList do
            ImportAddAnonymousMember(Node.AsXmlElement(), DocumentID);

        Commit();
    end;

    local procedure ImportAddAnonymousMember(Request: XmlElement; DocumentID: Text[100]): Boolean
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        MembershipEntryNo: Integer;
    begin

        MemberInfoCapture.Init();
        MemberInfoCapture."Import Entry Document ID" := DocumentID;
        GetAnonymousMemberArgs(Request, MemberInfoCapture);

        MemberInfoCapture.TestField("External Membership No.");

        MembershipEntryNo := MembershipManagement.GetMembershipFromExtMembershipNo(MemberInfoCapture."External Membership No.");
        if (MembershipEntryNo = 0) then
            Error(INVALID_MEMBERSHIP_NO, MemberInfoCapture."External Membership No.");

        MemberInfoCapture."Membership Entry No." := MembershipEntryNo;
        MemberInfoCapture.Modify();

        MembershipManagement.AddAnonymousMember(MemberInfoCapture, MemberInfoCapture.Quantity);

        exit(true);
    end;

    local procedure ImportGetMemberships(XmlDoc: XmlDocument; DocumentID: Text[100])
    var
        Request: XmlElement;
        NodeList: XmlNodeList;
        Node: XmlNode;
    begin

        XmlDoc.GetRoot(Request);

        if (not NpXmlDomMgt.FindNodes(Request.AsXmlNode(), 'getmembership/request', NodeList)) then
            exit;

        foreach Node in NodeList do
            ImportGetMemberQuery(Node.AsXmlElement(), DocumentID);

        Commit();
    end;

    local procedure ImportGetMembershipTicketList(XmlDoc: XmlDocument; DocumentID: Text[100])
    var
        Request: XmlElement;
        NodeList: XmlNodeList;
        Node: XmlNode;
    begin

        XmlDoc.GetRoot(Request);

        if (not NpXmlDomMgt.FindNodes(Request.AsXmlNode(), 'getmembershiptickets/request', NodeList)) then
            exit;

        foreach Node in NodeList do
            ImportGetMemberQuery(Node.AsXmlElement(), DocumentID);

        Commit();
    end;

    local procedure ImportGetMembershipMembers(XmlDoc: XmlDocument; DocumentID: Text[100])
    var
        Request: XmlElement;
        NodeList: XmlNodeList;
        Node: XmlNode;
    begin

        XmlDoc.GetRoot(Request);

        if (not NpXmlDomMgt.FindNodes(Request.AsXmlNode(), 'getmembers/request', NodeList)) then
            exit;

        foreach Node in NodeList do
            ImportGetMemberQuery(Node.AsXmlElement(), DocumentID);

        Commit();

    end;

    local procedure ImportGetMemberQuery(Request: XmlElement; DocumentID: Text[100]): Boolean
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        MembershipEntryNo: Integer;
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";
        Member: Record "NPR MM Member";
        NotFoundReason: Text;
        IsValid: Boolean;
    begin

        MemberInfoCapture.Init();
        MemberInfoCapture."Import Entry Document ID" := DocumentID;
        InsertGetMemberQuery(Request, MemberInfoCapture);

        MembershipEntryNo := MembershipManagement.FindMembershipUsing('EXT-MEMBERSHIP-NO', MemberInfoCapture."External Membership No.", '');

        if (MemberInfoCapture."External Membership No." = '') then begin
            if (MembershipEntryNo = 0) then
                MembershipEntryNo := MembershipManagement.FindMembershipUsing('EXT-MEMBER-NO', MemberInfoCapture."External Member No", '');

            if (MembershipEntryNo = 0) then
                MembershipEntryNo := MembershipManagement.FindMembershipUsing('EXT-CARD-NO', MemberInfoCapture."External Card No.", '');

            if (MembershipEntryNo = 0) then begin
                MembershipEntryNo := MembershipManagement.FindMembershipUsing('USER-PW', MemberInfoCapture."User Logon ID", MemberInfoCapture."Password SHA1");
                if (MembershipEntryNo <> 0) then begin
                    MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
                    MembershipRole.SetFilter("User Logon ID", '=%1', UpperCase(MemberInfoCapture."User Logon ID"));
                    MembershipRole.FindFirst();
                    Member.Get(MembershipRole."Member Entry No.");
                    MemberInfoCapture."Member Entry No" := Member."Entry No.";
                    MemberInfoCapture."External Member No" := Member."External Member No.";
                end;
            end;
        end;

        if (MembershipEntryNo = 0) then
            Error(NOT_FOUND);

        if (not Membership.Get(MembershipEntryNo)) then
            Error(NOT_FOUND);

        IsValid := MembershipManagement.IsMembershipActive(MembershipEntryNo, WorkDate(), false);
        if (not IsValid) then
            IsValid := MembershipManagement.MembershipNeedsActivation(MembershipEntryNo);

        MemberInfoCapture."Membership Entry No." := MembershipEntryNo;

        if (MemberInfoCapture."External Member No" <> '') then begin
            if (MemberInfoCapture."Member Entry No" = 0) then
                MemberInfoCapture."Member Entry No" := MembershipManagement.GetMemberFromExtMemberNo(MemberInfoCapture."External Member No");
        end;

        if (MemberInfoCapture."External Card No." <> '') then begin
            if (MemberInfoCapture."Member Entry No" = 0) then
                MemberInfoCapture."Member Entry No" := MembershipManagement.GetMemberFromExtCardNo(MemberInfoCapture."External Card No.", WorkDate(), NotFoundReason);
        end;

        MemberInfoCapture.Modify();

        exit(true);
    end;

    local procedure ImportUpdateMembers(XmlDoc: XmlDocument; DocumentID: Text[100])
    var
        Request: XmlElement;
        NodeList: XmlNodeList;
        Node: XmlNode;
    begin

        XmlDoc.GetRoot(Request);

        if (not NpXmlDomMgt.FindNodes(Request.AsXmlNode(), 'updatemember/request', NodeList)) then
            exit;

        foreach Node in NodeList do
            ImportUpdateMember(Node.AsXmlElement(), DocumentID);

        Commit();
    end;

    local procedure ImportUpdateMember(Request: XmlElement; DocumentID: Text[100]): Boolean
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        Member: Record "NPR MM Member";
    begin

        MemberInfoCapture.Init();
        MemberInfoCapture."Import Entry Document ID" := DocumentID;
        GetXmlMembershipMemberInfo(Request, MemberInfoCapture);

        MemberInfoCapture.TestField("External Member No");
        MemberInfoCapture."Member Entry No" := MembershipManagement.GetMemberFromExtMemberNo(MemberInfoCapture."External Member No");
        if (MemberInfoCapture."Member Entry No" = 0) then
            Error(INVALID_MEMBER_NO, MemberInfoCapture."External Member No");

        MemberInfoCapture."Membership Entry No." := MembershipManagement.GetMembershipFromExtMemberNo(MemberInfoCapture."External Member No");
        if (MemberInfoCapture."Membership Entry No." = 0) then
            Error(INVALID_MEMBERSHIP_NO, MemberInfoCapture."External Member No");

        TransferAttributes(Request, MemberInfoCapture);

        MembershipManagement.UpdateMember(MemberInfoCapture."Membership Entry No.", MemberInfoCapture."Member Entry No", MemberInfoCapture);
        MemberInfoCapture.Modify();

        Member.Get(MemberInfoCapture."Member Entry No");
        Member."Document ID" := DocumentID;
        Member.Modify();

        exit(true);
    end;

    local procedure ImportAddReplaceCard(XmlDoc: XmlDocument; DocumentID: Text[100])
    var
        Request: XmlElement;
        NodeList: XmlNodeList;
        Node: XmlNode;
    begin

        XmlDoc.GetRoot(Request);

        if (not NpXmlDomMgt.FindNodes(Request.AsXmlNode(), 'addreplacecard/request', NodeList)) then
            exit;

        foreach Node in NodeList do
            ImportAddReplaceCardWorker(Node.AsXmlElement(), DocumentID);

        Commit();
    end;

    local procedure ImportAddReplaceCardWorker(Element: XmlElement; DocumentID: Text[100])
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MemberManagement: Codeunit "NPR MM MembershipMgtInternal";
        MemberNotification: Codeunit "NPR MM Member Notification";
        ReasonText: Text;
    begin

        MemberInfoCapture.Init();
        MemberInfoCapture."Import Entry Document ID" := DocumentID;
        InsertAddReplaceCardRequest(Element, MemberInfoCapture);

        if (MemberInfoCapture."Replace External Card No." <> '') then begin
            MemberInfoCapture."Membership Entry No." := MemberManagement.GetMembershipFromExtCardNo(MemberInfoCapture."Replace External Card No.", Today, ReasonText);
            if (MemberInfoCapture."Membership Entry No." = 0) then
                Error(ReasonText);

            MemberInfoCapture."Member Entry No" := MemberManagement.GetMemberFromExtCardNo(MemberInfoCapture."Replace External Card No.", Today, ReasonText);
            if (MemberInfoCapture."Member Entry No" = 0) then
                Error(ReasonText);

            MemberManagement.BlockMemberCard(MemberManagement.GetCardEntryNoFromExtCardNo(MemberInfoCapture."Replace External Card No."), true);
        end;

        if (MemberInfoCapture."Replace External Card No." = '') then begin
            MemberInfoCapture."Membership Entry No." := MemberManagement.GetMembershipFromExtMembershipNo(MemberInfoCapture."External Membership No.");
            if (MemberInfoCapture."Membership Entry No." = 0) then
                Error(INVALID_MEMBERSHIP_NO, MemberInfoCapture."External Membership No.");

            MemberInfoCapture."Member Entry No" := MemberManagement.GetMemberFromExtMemberNo(MemberInfoCapture."External Member No");
            if (MemberInfoCapture."Member Entry No" = 0) then
                Error(INVALID_MEMBER_NO, MemberInfoCapture."External Member No");
        end;
        MemberInfoCapture.Modify();

        if (not MemberManagement.IssueMemberCard(MemberInfoCapture, MemberInfoCapture."Card Entry No.", ReasonText)) then
            Error(ReasonText);

        MemberInfoCapture.Modify();

        if (MemberInfoCapture."Member Card Type" in [MemberInfoCapture."Member Card Type"::CARD_PASSSERVER, MemberInfoCapture."Member Card Type"::PASSSERVER]) then
            MemberNotification.CreateWalletSendNotification(MemberInfoCapture."Membership Entry No.", MemberInfoCapture."Member Entry No", MemberInfoCapture."Card Entry No.", Today);

    end;

    local procedure InsertAddReplaceCardRequest(Element: XmlElement; var MemberInfoCapture: Record "NPR MM Member Info Capture")
    var
        Node: XmlNode;
        CardRequestElement: XmlElement;
    begin
        MemberInfoCapture."Entry No." := 0;

        if (NpXmlDomMgt.FindNode(Element.AsXmlNode(), 'add_card', Node)) then begin
            CardRequestElement := Node.AsXmlElement();
            MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::NEW;

            MemberInfoCapture."External Membership No." := GetXmlAttributeText20(CardRequestElement, 'membershipnumber', false);
            if (MemberInfoCapture."External Membership No." <> '') then begin
                MemberInfoCapture."External Member No" := GetXmlAttributeText20(CardRequestElement, 'membernumber', true);
                MemberInfoCapture."External Card No." := GetXmlAttributeText100(CardRequestElement, 'new_cardnumber', false);
            end;
        end;

        if (MemberInfoCapture."External Membership No." = '') and (NpXmlDomMgt.FindNode(Element.AsXmlNode(), 'replace_card', Node)) then begin
            CardRequestElement := Node.AsXmlElement();
            MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::NEW;

            MemberInfoCapture."Replace External Card No." := CopyStr(NpXmlDomMgt.GetXmlAttributeText(CardRequestElement, 'old_cardnumber', true), 1, MaxStrLen(MemberInfoCapture."Replace External Card No."));
            MemberInfoCapture."External Card No." := CopyStr(NpXmlDomMgt.GetXmlAttributeText(CardRequestElement, 'new_cardnumber', false), 1, MaxStrLen(MemberInfoCapture."External Card No."));
        end;

        if ((MemberInfoCapture."External Membership No." = '') and (MemberInfoCapture."Replace External Card No." = '')) then
            Error('Invalid Request. Required attributes for either add_card or replace_card is missing and action could not be determined.');

        if (MemberInfoCapture."External Card No." <> '') then
            MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::FOREIGN;

        MemberInfoCapture.Insert();
    end;

    local procedure ImportBlockMemberships(XmlDoc: XmlDocument; DocumentID: Text[100])
    var
        Request: XmlElement;
        NodeList: XmlNodeList;
        Node: XmlNode;
    begin

        XmlDoc.GetRoot(Request);

        if (not NpXmlDomMgt.FindNodes(Request.AsXmlNode(), 'blockmembers/request', NodeList)) then
            exit;

        foreach Node in NodeList do
            ImportBlockMembership(Node.AsXmlElement(), DocumentID);

        Commit();
    end;

    local procedure ImportBlockMembership(Request: XmlElement; DocumentID: Text[100]): Boolean
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        Membership: Record "NPR MM Membership";
    begin

        MemberInfoCapture.Init();
        MemberInfoCapture."Import Entry Document ID" := DocumentID;
        InsertGetMemberQuery(Request, MemberInfoCapture);

        if (MemberInfoCapture."External Membership No." <> '') then begin
            MemberInfoCapture."Membership Entry No." := MembershipManagement.GetMembershipFromExtMembershipNo(MemberInfoCapture."External Membership No.");
            if (MemberInfoCapture."Membership Entry No." = 0) then
                Error(INVALID_MEMBERSHIP_NO, MemberInfoCapture."External Membership No.");
        end;

        if (MemberInfoCapture."External Member No" <> '') then begin
            MemberInfoCapture."Membership Entry No." := MembershipManagement.GetMembershipFromExtMemberNo(MemberInfoCapture."External Member No");
            if (MemberInfoCapture."Membership Entry No." = 0) then
                Error(INVALID_MEMBER_NO, MemberInfoCapture."External Member No");
        end;

        if (MemberInfoCapture."Membership Entry No." = 0) then
            Error(NOT_FOUND);

        MemberInfoCapture.Modify();

        MembershipManagement.BlockMembership(MemberInfoCapture."Membership Entry No.", true);

        Membership.Get(MemberInfoCapture."Membership Entry No.");
        Membership."Document ID" := DocumentID;
        Membership.Modify();

        exit(true);
    end;

    local procedure ImportBlockMembers(XmlDoc: XmlDocument; DocumentID: Text[100])
    var
        Request: XmlElement;
        NodeList: XmlNodeList;
        Node: XmlNode;
    begin

        XmlDoc.GetRoot(Request);

        if (not NpXmlDomMgt.FindNodes(Request.AsXmlNode(), 'blockmember/request', NodeList)) then
            exit;

        foreach Node in NodeList do
            ImportBlockMember(Node.AsXmlElement(), DocumentID);

        Commit();

    end;

    local procedure ImportBlockMember(Request: XmlElement; DocumentID: Text[100]): Boolean
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";
        Member: Record "NPR MM Member";
    begin

        MemberInfoCapture.Init();
        MemberInfoCapture."Import Entry Document ID" := DocumentID;
        InsertGetMemberQuery(Request, MemberInfoCapture);

        if (MemberInfoCapture."External Member No" <> '') then begin
            MemberInfoCapture."Member Entry No" := MembershipManagement.GetMemberFromExtMemberNo(MemberInfoCapture."External Member No");
            if (MemberInfoCapture."Member Entry No" = 0) then
                Error(INVALID_MEMBER_NO, MemberInfoCapture."External Member No");
        end;

        if (MemberInfoCapture."External Membership No." <> '') then begin
            MemberInfoCapture."Membership Entry No." := MembershipManagement.GetMembershipFromExtMembershipNo(MemberInfoCapture."External Membership No.");
            if (MemberInfoCapture."Membership Entry No." = 0) then
                Error(INVALID_MEMBERSHIP_NO, MemberInfoCapture."External Membership No.");
        end;

        if (MemberInfoCapture."Member Entry No" = 0) then
            Error(NOT_FOUND);

        MemberInfoCapture.Modify();

        MembershipRole.SetFilter("Member Entry No.", '=%1', MemberInfoCapture."Member Entry No");
        if (MemberInfoCapture."Membership Entry No." <> 0) then
            MembershipRole.SetFilter("Membership Entry No.", '=%1', MemberInfoCapture."Membership Entry No.");
        if (not MembershipRole.FindSet()) then
            Error(NOT_FOUND);

        repeat
            MembershipManagement.BlockMember(MembershipRole."Membership Entry No.", MembershipRole."Member Entry No.", true);

            Member.Get(MembershipRole."Member Entry No.");
            Member."Document ID" := DocumentID;
            Member.Modify();

            Membership.Get(MembershipRole."Membership Entry No.");
            Membership."Document ID" := DocumentID;
            Membership.Modify();

        until (MembershipRole.Next() = 0);

        exit(true);

    end;

    local procedure ImportChangeMemberships(XmlDoc: XmlDocument; DocumentID: Text[100])
    var
        Request: XmlElement;
        NodeList: XmlNodeList;
        Node: XmlNode;
    begin

        XmlDoc.GetRoot(Request);

        if (not NpXmlDomMgt.FindNodes(Request.AsXmlNode(), 'changemembership/request', NodeList)) then
            exit;

        foreach Node in NodeList do
            ImportChangeMembership(Node.AsXmlElement(), DocumentID);

        Commit();
    end;

    local procedure ImportChangeMembership(Request: XmlElement; DocumentID: Text[100]): Boolean
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        Membership: Record "NPR MM Membership";
        MembershipStartDate: Date;
        MembershipUntilDate: Date;
        UnitPrice: Decimal;
        NotFoundReasonText: Text;
    begin

        MemberInfoCapture.Init();
        MemberInfoCapture."Import Entry Document ID" := DocumentID;
        InsertGetMemberQuery(Request, MemberInfoCapture);

        if (MemberInfoCapture."External Member No" <> '') then begin
            MemberInfoCapture."Membership Entry No." := MembershipManagement.GetMembershipFromExtMemberNo(MemberInfoCapture."External Member No");
            if (MemberInfoCapture."Membership Entry No." = 0) then
                Error(INVALID_MEMBER_NO, MemberInfoCapture."External Member No");
        end;

        if (MemberInfoCapture."External Card No." <> '') then begin
            MemberInfoCapture."Membership Entry No." := MembershipManagement.GetMembershipFromExtCardNo(MemberInfoCapture."External Card No.", Today, NotFoundReasonText);
            if (MemberInfoCapture."Membership Entry No." = 0) then
                Error(INVALID_MEMBER_CARD_NO, MemberInfoCapture."External Card No.");
        end;

        if (MemberInfoCapture."External Membership No." <> '') then begin
            MemberInfoCapture."Membership Entry No." := MembershipManagement.GetMembershipFromExtMembershipNo(MemberInfoCapture."External Membership No.");
            if (MemberInfoCapture."Membership Entry No." = 0) then
                Error(INVALID_MEMBERSHIP_NO, MemberInfoCapture."External Membership No.");
        end;

        AppendChangeMembership(Request, MemberInfoCapture);

        if (MemberInfoCapture."Membership Entry No." = 0) then
            Error(NOT_FOUND);

        MemberInfoCapture."Import Entry Document ID" := DocumentID;
        MemberInfoCapture.Modify();

        Membership.Get(MemberInfoCapture."Membership Entry No.");

        case MemberInfoCapture."Information Context" of

            MemberInfoCapture."Information Context"::REGRET:
                begin
                    MembershipManagement.RegretMembership(MemberInfoCapture, true, true, MembershipStartDate, MembershipUntilDate, UnitPrice);
                end;

            MemberInfoCapture."Information Context"::RENEW:
                begin
                    MembershipManagement.RenewMembership(MemberInfoCapture, true, true, MembershipStartDate, MembershipUntilDate, UnitPrice);
                end;

            MemberInfoCapture."Information Context"::UPGRADE:
                begin
                    MembershipManagement.UpgradeMembership(MemberInfoCapture, true, true, MembershipStartDate, MembershipUntilDate, UnitPrice);
                end;

            MemberInfoCapture."Information Context"::EXTEND:
                begin
                    MembershipManagement.ExtendMembership(MemberInfoCapture, true, true, MembershipStartDate, MembershipUntilDate, UnitPrice);
                end;

            MemberInfoCapture."Information Context"::LIST:
                begin
                    ; // Dont need to to anything here
                end;

            MemberInfoCapture."Information Context"::CANCEL:
                begin
                    MembershipManagement.CancelMembership(MemberInfoCapture, true, true, MembershipStartDate, MembershipUntilDate, UnitPrice);
                end;

        end;

        exit(true);
    end;

    local procedure ImportGetChangeMembershipList(XmlDoc: XmlDocument; DocumentID: Text[100]; NodePath: Text[250])
    var
        Request: XmlElement;
        NodeList: XmlNodeList;
        Node: XmlNode;
    begin

        XmlDoc.GetRoot(Request);

        if (not NpXmlDomMgt.FindNodes(Request.AsXmlNode(), NodePath, NodeList)) then
            exit;

        foreach Node in NodeList do
            ImportGetChangeMembershipItems(Node.AsXmlElement(), DocumentID);

        Commit();
    end;

    local procedure ImportGetChangeMembershipItems(Request: XmlElement; DocumentID: Text[100]): Boolean
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin

        MemberInfoCapture.Init();
        MemberInfoCapture."Import Entry Document ID" := DocumentID;
        InsertGetMemberQuery(Request, MemberInfoCapture);

        if (MemberInfoCapture."External Membership No." <> '') then begin
            MemberInfoCapture."Membership Entry No." := MembershipManagement.GetMembershipFromExtMembershipNo(MemberInfoCapture."External Membership No.");
            if (MemberInfoCapture."Membership Entry No." = 0) then
                Error(INVALID_MEMBERSHIP_NO, MemberInfoCapture."External Membership No.");
        end;

        if (MemberInfoCapture."Membership Entry No." = 0) then
            Error(NOT_FOUND);

        if (not MembershipManagement.IsMembershipActive(MemberInfoCapture."Membership Entry No.", Today, false)) then
            if (MembershipManagement.MembershipNeedsActivation(MemberInfoCapture."Membership Entry No.")) then
                Error(NOT_ACTIVE, MemberInfoCapture."External Membership No.");

        MemberInfoCapture."Import Entry Document ID" := DocumentID;
        MemberInfoCapture.Modify();

        exit(true);
    end;

    local procedure ImportRegretMemberships(XmlDoc: XmlDocument; DocumentID: Text[100])
    var
        Request: XmlElement;
        NodeList: XmlNodeList;
        Node: XmlNode;
    begin

        XmlDoc.GetRoot(Request);

        if (not NpXmlDomMgt.FindNodes(Request.AsXmlNode(), 'regretmembershiptimeframe/request', NodeList)) then
            exit;

        foreach Node in NodeList do
            ImportRegretMembership(Node.AsXmlElement(), DocumentID);

        Commit();
    end;

    local procedure ImportRegretMembership(Request: XmlElement; DocumentID: Text[100]): Boolean
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipEntry: Record "NPR MM Membership Entry";
        TargetDocumentId: Text[100];
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin

        MemberInfoCapture.Init();
        MemberInfoCapture."Import Entry Document ID" := DocumentID;
        MemberInfoCapture.Insert();

        TargetDocumentId := GetXmlText100(Request, 'documentid', true);
        MembershipEntry.SetFilter("Import Entry Document ID", '=%1', TargetDocumentId);
        MembershipEntry.SetFilter(Blocked, '=%1', false);
        MembershipEntry.FindFirst();

        MemberInfoCapture."Membership Entry No." := MembershipEntry."Membership Entry No.";
        MemberInfoCapture.Modify();

        MembershipEntry.Reset();
        MembershipEntry.SetFilter("Membership Entry No.", '=%1', MemberInfoCapture."Membership Entry No.");
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
        MembershipEntry.SetFilter(Blocked, '=%1', false);
        MembershipEntry.FindLast();

        if (MembershipEntry."Import Entry Document ID" <> TargetDocumentId) then
            Error(NOT_LAST_TIMEFRAME, TargetDocumentId);

        MembershipManagement.DoRegretTimeframe(MembershipEntry);

        exit(true);
    end;

    local procedure ImportGdprApproval(XmlDoc: XmlDocument; DocumentID: Text[100])
    var
        Request: XmlElement;
        NodeList: XmlNodeList;
        Node: XmlNode;
    begin

        XmlDoc.GetRoot(Request);

        if (not NpXmlDomMgt.FindNodes(Request.AsXmlNode(), 'getsegdprtapproval/request', NodeList)) then
            exit;

        foreach Node in NodeList do
            ImportGdprApprovalRequest(Node.AsXmlElement(), DocumentID);

        Commit();

    end;

    local procedure ImportGdprApprovalRequest(Request: XmlElement; DocumentID: Text[100]): Boolean
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        MembershipRole: Record "NPR MM Membership Role";
        GDPRManagement: Codeunit "NPR MM GDPR Management";
        ResponseMessage: Text;
        DataSubjectId: Text[40];
    begin

        MemberInfoCapture.Init();
        MemberInfoCapture."Import Entry Document ID" := DocumentID;
        GetGdprArgs(Request, MemberInfoCapture, DataSubjectId);

        if (DataSubjectId = '') then begin
            MemberInfoCapture.TestField("External Card No.");

            MemberInfoCapture."Membership Entry No." := MembershipManagement.GetMembershipFromExtCardNo(MemberInfoCapture."External Card No.", Today, ResponseMessage);
            if (MemberInfoCapture."Membership Entry No." = 0) then
                Error(ResponseMessage);

            MemberInfoCapture."Member Entry No" := MembershipManagement.GetMemberFromExtCardNo(MemberInfoCapture."External Card No.", Today, ResponseMessage);
            if (MemberInfoCapture."Member Entry No" = 0) then
                Error(ResponseMessage);

            MembershipRole.Get(MemberInfoCapture."Membership Entry No.", MemberInfoCapture."Member Entry No");
        end;

        if (DataSubjectId <> '') then begin
            MembershipRole.SetFilter("GDPR Data Subject Id", '=%1', DataSubjectId);
            MembershipRole.FindFirst();

            MemberInfoCapture."Membership Entry No." := MembershipRole."Membership Entry No.";
            MemberInfoCapture."Member Entry No" := MembershipRole."Member Entry No.";
        end;

        MemberInfoCapture.Modify();

        if (MemberInfoCapture."GDPR Approval" <> MemberInfoCapture."GDPR Approval"::NA) then
            GDPRManagement.SetApprovalState(MembershipRole."GDPR Agreement No.", MembershipRole."GDPR Data Subject Id", MemberInfoCapture."GDPR Approval");

        exit(true);

    end;

    local procedure CreateWallet(XmlDoc: XmlDocument; DocumentID: Text[100])
    var
        Request: XmlElement;
        NodeList: XmlNodeList;
        Node: XmlNode;
    begin

        XmlDoc.GetRoot(Request);

        if (not NpXmlDomMgt.FindNodes(Request.AsXmlNode(), 'createwalletpass/request', NodeList)) then
            exit;

        foreach Node in NodeList do
            ProcessCreateWalletRequest(Node.AsXmlElement(), DocumentID);


        Commit();

    end;

    local procedure ProcessCreateWalletRequest(Request: XmlElement; DocumentID: Text[100]): Boolean
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MemberCard: Record "NPR MM Member Card";
        MembershipNotification: Record "NPR MM Membership Notific.";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        MemberNotification: Codeunit "NPR MM Member Notification";
        ResponseMessage: Text;
        NotificationEntryNo: Integer;
    begin

        MemberInfoCapture.Init();
        MemberInfoCapture."Import Entry Document ID" := DocumentID;
        GetCreateWalletRequest(Request, MemberInfoCapture);

        MemberInfoCapture."Membership Entry No." := MembershipManagement.GetMembershipFromExtCardNo(MemberInfoCapture."External Card No.", Today, ResponseMessage);
        if (MemberInfoCapture."Membership Entry No." = 0) then
            Error(ResponseMessage);

        MemberInfoCapture."Member Entry No" := MembershipManagement.GetMemberFromExtCardNo(MemberInfoCapture."External Card No.", Today, ResponseMessage);
        if (MemberInfoCapture."Member Entry No" = 0) then
            Error(ResponseMessage);

        MemberCard.SetFilter("External Card No.", '=%1', MemberInfoCapture."External Card No.");
        MemberCard.SetFilter("Membership Entry No.", '=%1', MemberInfoCapture."Membership Entry No.");
        MemberCard.SetFilter("Member Entry No.", '=%1', MemberInfoCapture."Member Entry No");
        if (not MemberCard.FindFirst()) then
            Error(INVALID_MEMBER_CARD_NO, MemberInfoCapture."External Card No.");

        MemberInfoCapture."Card Entry No." := MemberCard."Entry No.";
        MemberInfoCapture.Modify();

        NotificationEntryNo := MemberNotification.CreateWalletWithoutSendingNotification(MemberInfoCapture."Membership Entry No.", MemberInfoCapture."Member Entry No", MemberInfoCapture."Card Entry No.", Today);

        if (NotificationEntryNo = 0) then
            Error('eMemberCard is missing setup.');

        if (MembershipNotification.Get(NotificationEntryNo)) then
            MemberNotification.HandleMembershipNotification(MembershipNotification);

        exit(true);

    end;

    local procedure InsertCreateMembership(CreateMembershipRequest: XmlElement; var MemberInfoCapture: Record "NPR MM Member Info Capture")
    begin

        MemberInfoCapture."Entry No." := 0;
        MemberInfoCapture."Item No." := GetXmlText20(CreateMembershipRequest, 'membershipsalesitem', true);

        Evaluate(MemberInfoCapture."Document Date", GetXmlText20(CreateMembershipRequest, 'activationdate', false), 9);
        MemberInfoCapture.Insert();

        MemberInfoCapture."Company Name" := GetXmlText50(CreateMembershipRequest, 'companyname', false);
        MemberInfoCapture."Customer No." := GetXmlText20(CreateMembershipRequest, 'preassigned_customer_number', false);
        MemberInfoCapture."Document No." := GetXmlText20(CreateMembershipRequest, 'documentno', false);

    end;

    local procedure GetXmlMembershipMemberInfo(MemberRequest: XmlElement; var MemberInfoCapture: Record "NPR MM Member Info Capture")
    var
        Language: Record "NPR MM Language";
        GenderText: Text[30];
        CrmText: Text[30];
        GdprText: Text[30];
        BooleanTextField: Text[20];
        DateTextField: Text[20];
        isPermanent: Boolean;
        NotificationMethodText: Text[30];
    begin

        MemberInfoCapture."Entry No." := 0;
        MemberInfoCapture."External Membership No." := GetXmlText20(MemberRequest, 'membershipnumber', false);
        MemberInfoCapture."External Member No" := GetXmlText20(MemberRequest, 'membernumber', false);

        MemberInfoCapture."First Name" := GetXmlText50(MemberRequest, 'firstname', true);
        MemberInfoCapture."E-Mail Address" := LowerCase(GetXmlText80(MemberRequest, 'email', true));

        MemberInfoCapture."Guardian External Member No." := GetXmlText20(MemberRequest, 'guardian/membernumber', false);
        if (MemberInfoCapture."Guardian External Member No." <> '') then
            if (MemberInfoCapture."E-Mail Address" = '') then
                MemberInfoCapture."E-Mail Address" := LowerCase(GetXmlText80(MemberRequest, 'guardian/email', true));

        MemberInfoCapture."Middle Name" := GetXmlText50(MemberRequest, 'middlename', false);
        MemberInfoCapture."Last Name" := GetXmlText50(MemberRequest, 'lastname', true);
        MemberInfoCapture.Address := GetXmlText100(MemberRequest, 'address', false);

        MemberInfoCapture."Post Code Code" := GetXmlText20(MemberRequest, 'postcode', false);
        MemberInfoCapture.City := GetXmlText50(MemberRequest, 'city', false);
        MemberInfoCapture.Country := GetXmlText50(MemberRequest, 'country', false);
        MemberInfoCapture."Phone No." := GetXmlText30(MemberRequest, 'phoneno', false);

        if (MemberInfoCapture."E-Mail Address" = '') and (MemberInfoCapture."Phone No." <> '') then
            MemberInfoCapture."Notification Method" := MemberInfoCapture."Notification Method"::SMS;

        if (MemberInfoCapture."E-Mail Address" <> '') and (MemberInfoCapture."Phone No." = '') then
            MemberInfoCapture."Notification Method" := MemberInfoCapture."Notification Method"::EMAIL;

        if (MemberInfoCapture."E-Mail Address" <> '') and (MemberInfoCapture."Phone No." <> '') then
            MemberInfoCapture."Notification Method" := MemberInfoCapture."Notification Method"::EMAIL;

        NotificationMethodText := GetXmlText30(MemberRequest, 'notificationmethod', false);
        case UpperCase(NotificationMethodText) of
            'NO_THANKYOU', '0':
                MemberInfoCapture."Notification Method" := MemberInfoCapture."Notification Method"::NO_THANKYOU;
            'EMAIL', '1', Format(MemberInfoCapture."Notification Method"::EMAIL, 0, 9):
                MemberInfoCapture."Notification Method" := MemberInfoCapture."Notification Method"::EMAIL;
            'MANUAL', '2', Format(MemberInfoCapture."Notification Method"::MANUAL, 0, 9):
                MemberInfoCapture."Notification Method" := MemberInfoCapture."Notification Method"::MANUAL;
            'SMS', '3', Format(MemberInfoCapture."Notification Method"::SMS, 0, 9):
                MemberInfoCapture."Notification Method" := MemberInfoCapture."Notification Method"::SMS;
            'DEFAULT', '4', Format(MemberInfoCapture."Notification Method"::DEFAULT, 0, 9):
                ; // Do nothing
        end;

        Evaluate(MemberInfoCapture.Birthday, GetXmlText20(MemberRequest, 'birthday', false), 9);
        if (MemberInfoCapture.Birthday < DMY2Date(1, 1, 1900)) then
            MemberInfoCapture.Birthday := 0D;

        GenderText := GetXmlText30(MemberRequest, 'gender', false);
        case UpperCase(GenderText) of
            'MALE', '1', Format(MemberInfoCapture.Gender::MALE, 0, 9):
                MemberInfoCapture.Gender := MemberInfoCapture.Gender::MALE;
            'FEMALE', '2', Format(MemberInfoCapture.Gender::FEMALE, 0, 9):
                MemberInfoCapture.Gender := MemberInfoCapture.Gender::FEMALE;
            'OTHER', '3', Format(MemberInfoCapture.Gender::OTHER, 0, 9):
                MemberInfoCapture.Gender := MemberInfoCapture.Gender::OTHER;
            else
                MemberInfoCapture.Gender := MemberInfoCapture.Gender::NOT_SPECIFIED;
        end;

        CrmText := GetXmlText30(MemberRequest, 'newsletter', false);
        case UpperCase(CrmText) of
            'YES', '1', Format(MemberInfoCapture."News Letter"::YES, 0, 9):
                MemberInfoCapture."News Letter" := MemberInfoCapture."News Letter"::YES;
            'NO', '2', Format(MemberInfoCapture."News Letter"::NO, 0, 9):
                MemberInfoCapture."News Letter" := MemberInfoCapture."News Letter"::NO;
            else
                MemberInfoCapture."News Letter" := MemberInfoCapture."News Letter"::NOT_SPECIFIED;
        end;

        MemberInfoCapture.PreferredLanguageCode := GetXmlText10(MemberRequest, 'preferred_language', false);
        if (MemberInfoCapture.PreferredLanguageCode <> '') then begin
            if (not Language.Get(MemberInfoCapture.PreferredLanguageCode)) then
                MemberInfoCapture.PreferredLanguageCode := '';
        end;

        MemberInfoCapture."User Logon ID" := UpperCase(GetXmlText80(MemberRequest, 'username', false));
        MemberInfoCapture."Password SHA1" := GetXmlText50(MemberRequest, 'password', false);

        GdprText := GetXmlText30(MemberRequest, 'gdpr_approval', false);
        case UpperCase(GdprText) of
            'PENDING', '1', UpperCase(Format(MemberInfoCapture."GDPR Approval"::PENDING, 0, 9)):
                MemberInfoCapture."GDPR Approval" := MemberInfoCapture."GDPR Approval"::PENDING;
            'ACCEPT', 'ACCEPTED', '2', UpperCase(Format(MemberInfoCapture."GDPR Approval"::ACCEPTED, 0, 9)):
                MemberInfoCapture."GDPR Approval" := MemberInfoCapture."GDPR Approval"::ACCEPTED;
            'REJECT', 'REJECTED', '3', UpperCase(Format(MemberInfoCapture."GDPR Approval"::REJECTED, 0, 9)):
                MemberInfoCapture."GDPR Approval" := MemberInfoCapture."GDPR Approval"::REJECTED;
            else
                MemberInfoCapture."GDPR Approval" := MemberInfoCapture."GDPR Approval"::NA;
        end;

        MemberInfoCapture."External Card No." := GetXmlText100(MemberRequest, 'membercard/cardnumber', false);
        if (MemberInfoCapture."External Card No." <> '') then begin

            if (StrLen(MemberInfoCapture."External Card No.") >= 4) then
#pragma warning disable AA0139,
                MemberInfoCapture."External Card No. Last 4" := CopyStr(MemberInfoCapture."External Card No.", StrLen(MemberInfoCapture."External Card No.") - 3);
#pragma warning restore

            BooleanTextField := GetXmlText20(MemberRequest, 'membercard/is_permanent', true);
            if (BooleanTextField = '') then
                BooleanTextField := Format(false, 0, 9);

            Evaluate(isPermanent, BooleanTextField, 9);
            MemberInfoCapture."Temporary Member Card" := not isPermanent;

            DateTextField := GetXmlText20(MemberRequest, 'membercard/valid_until', true);
            if ((DateTextField = '') or (DateTextField = '1754-01-01')) then
                DateTextField := Format(CalcDate('<+10D>', Today), 0, 9); // Default valid for 10 days
            Evaluate(MemberInfoCapture."Valid Until", DateTextField, 9);

        end;

        MemberInfoCapture."Member Card Type" := MemberInfoCapture."Member Card Type"::NONE;

        MemberInfoCapture."Customer No." := GetXmlText20(MemberRequest, 'preassigned_customer_number', false);
        MemberInfoCapture."Contact No." := GetXmlText20(MemberRequest, 'preassigned_contact_number', false);
        MemberInfoCapture."Store Code" := GetXmlText20(MemberRequest, 'store_code', false);

        MemberInfoCapture.Insert();
    end;

    local procedure InsertGetMemberQuery(Request: XmlElement; var MemberInfoCapture: Record "NPR MM Member Info Capture")
    var
        CustomerNo: Code[20];
        Membership: Record "NPR MM Membership";
    begin

        MemberInfoCapture."Entry No." := 0;
        MemberInfoCapture."External Member No" := GetXmlText20(Request, 'membernumber', false);
        MemberInfoCapture."External Card No." := GetXmlText100(Request, 'cardnumber', false);
        MemberInfoCapture."External Membership No." := GetXmlText20(Request, 'membershipnumber', false);
        MemberInfoCapture."User Logon ID" := UpperCase(GetXmlText80(Request, 'username', false));
        MemberInfoCapture."Password SHA1" := GetXmlText50(Request, 'password', false);

        CustomerNo := GetXmlText20(Request, 'customernumber', false);
        if (CustomerNo <> '') then begin
            Membership.SetFilter("Customer No.", '=%1', CustomerNo);
            Membership.SetFilter(Blocked, '=%1', false);
            if (Membership.FindFirst()) then
                if (MemberInfoCapture."External Membership No." = '') then
                    MemberInfoCapture."External Membership No." := Membership."External Membership No.";

            if (MemberInfoCapture."External Membership No." <> Membership."External Membership No.") then
                MemberInfoCapture."External Membership No." := '';

        end;

        MemberInfoCapture."Document No." := UpperCase(GetXmlText20(Request, 'externaldocumentnumber', false));

        MemberInfoCapture.Insert();
    end;

    local procedure GetCreateWalletRequest(Request: XmlElement; var MemberInfoCapture: Record "NPR MM Member Info Capture"): Boolean
    begin

        MemberInfoCapture."Entry No." := 0;
        MemberInfoCapture."External Card No." := GetXmlText100(Request, 'cardnumber', false);
        MemberInfoCapture.Insert();

    end;

    local procedure AppendChangeMembership(Request: XmlElement; var MemberInfoCapture: Record "NPR MM Member Info Capture")
    var
        ChangeType: Text[100];
    begin

        MemberInfoCapture."Item No." := GetXmlText20(Request, 'membershipchangeitem', true);

        ChangeType := GetXmlText100(Request, 'changetype', true);
        case UpperCase(ChangeType) of
            'CANCEL', '1', Format(MemberInfoCapture."Information Context"::REGRET, 0, 9):
                MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::REGRET;
            'RENEW', '2', Format(MemberInfoCapture."Information Context"::RENEW, 0, 9):
                MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::RENEW;
            'UPGRADE', '3', Format(MemberInfoCapture."Information Context"::UPGRADE, 0, 9):
                MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::UPGRADE;
            'EXTEND', '4', Format(MemberInfoCapture."Information Context"::EXTEND, 0, 9):
                MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::EXTEND;
            'LIST', '5', Format(MemberInfoCapture."Information Context"::LIST, 0, 9):
                MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::LIST;
            else
                Error(ILLEGAL_CHANGE_TYPE, ChangeType);
        end;
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

    local procedure GetAnonymousMemberArgs(Request: XmlElement; var MemberInfoCapture: Record "NPR MM Member Info Capture")
    begin

        MemberInfoCapture."Entry No." := 0;
        MemberInfoCapture."External Membership No." := GetXmlText20(Request, 'membershipnumber', false);
        Evaluate(MemberInfoCapture.Quantity, GetXmlText20(Request, 'addmembercount', false), 9);

        MemberInfoCapture.Insert();

    end;

    local procedure GetGdprArgs(Request: XmlElement; var MemberInfoCapture: Record "NPR MM Member Info Capture"; var DataSubjectId: Text[40])
    var
        GdprText: Text[20];
    begin

        MemberInfoCapture."Entry No." := 0;
        MemberInfoCapture."External Card No." := GetXmlText100(Request, 'cardnumber', false);
        DataSubjectId := GetXmlText40(Request, 'datasubjectid', false);

        GdprText := GetXmlText20(Request, 'gdpr_approval', false);
        case UpperCase(GdprText) of
            'PENDING', '1', UpperCase(Format(MemberInfoCapture."GDPR Approval"::PENDING, 0, 9)):
                MemberInfoCapture."GDPR Approval" := MemberInfoCapture."GDPR Approval"::PENDING;
            'ACCEPT', 'ACCEPTED', '2', UpperCase(Format(MemberInfoCapture."GDPR Approval"::ACCEPTED, 0, 9)):
                MemberInfoCapture."GDPR Approval" := MemberInfoCapture."GDPR Approval"::ACCEPTED;
            'REJECT', 'REJECTED', '3', UpperCase(Format(MemberInfoCapture."GDPR Approval"::REJECTED, 0, 9)):
                MemberInfoCapture."GDPR Approval" := MemberInfoCapture."GDPR Approval"::REJECTED;
            else
                MemberInfoCapture."GDPR Approval" := MemberInfoCapture."GDPR Approval"::NA;
        end;

        MemberInfoCapture.Insert();

    end;

    local procedure TransferAttributes(RequestAttributes: XmlElement; var MemberInfoCapture: Record "NPR MM Member Info Capture")
    var
        MembershipEvents: Codeunit "NPR MM Membership Events";
        AttributeCode: Text;
        AttributeValue: Text;
        NodeList: XmlNodeList;
        Node: XmlNode;
        Handled: Boolean;
    begin

        if (not NpXmlDomMgt.FindNodes(RequestAttributes.AsXmlNode(), 'request/attributes/attribute', NodeList)) then
            exit;

        foreach Node in NodeList do begin
            AttributeCode := NpXmlDomMgt.GetXmlAttributeText(Node.AsXmlElement(), 'code', true);
            AttributeValue := NpXmlDomMgt.GetXmlAttributeText(Node.AsXmlElement(), 'value', false);

            Handled := false;
            MembershipEvents.OnBeforeApplyAttributeToMemberInfoCapture(MemberInfoCapture, AttributeCode, AttributeValue, Handled);
            if not Handled then
                ApplyAttributesToMemberInfoCapture(MemberInfoCapture."Entry No.", CopyStr(UpperCase(AttributeCode), 1, 20), CopyStr(AttributeValue, 1, 250));
        end;

    end;

    local procedure ApplyAttributesToMemberInfoCapture(MemberInfoCaptureEntryNo: Integer; AttributeCode: Code[20]; AttributeValue: Text[250])
    var
        NPRAttribute: Record "NPR Attribute";
        NPRAttributeID: Record "NPR Attribute ID";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        TableId: Integer;
        NPRAttributeManagement: Codeunit "NPR Attribute Management";
    begin

        TableId := Database::"NPR MM Member Info Capture";

        if (not NPRAttribute.Get(AttributeCode)) then
            Error('Attribute %1 is not valid.', AttributeCode);

        if (not NPRAttributeID.Get(TableId, AttributeCode)) then
            Error('Attribute %1 is not defined for table with id %2.', AttributeCode, TableId);

        if (not MemberInfoCapture.Get(MemberInfoCaptureEntryNo)) then
            Error('The MemberInfoCapture EntryNo %1 is not valid.', MemberInfoCaptureEntryNo);

        NPRAttributeManagement.SetEntryAttributeValue(TableId, NPRAttributeID."Shortcut Attribute ID", MemberInfoCaptureEntryNo, AttributeValue);

    end;

    internal procedure InitMMMemberWebService()
    var
        WebService: Record "Web Service Aggregate";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        if not WebService.ReadPermission then
            exit;

        if not WebService.WritePermission then
            exit;

        WebServiceManagement.CreateTenantWebService(WebService."Object Type"::Codeunit, Codeunit::"NPR MM Member WebService", 'member_services', true);
    end;
#pragma warning disable AA0139
    local procedure GetXmlText10(Element: XmlElement; NodePath: Text; Required: Boolean): Text[10]
    begin
        exit(NpXmlDomMgt.GetXmlText(Element, NodePath, 10, Required));
    end;

    local procedure GetXmlText20(Element: XmlElement; NodePath: Text; Required: Boolean): Text[20]
    begin
        exit(NpXmlDomMgt.GetXmlText(Element, NodePath, 20, Required));
    end;

    local procedure GetXmlText30(Element: XmlElement; NodePath: Text; Required: Boolean): Text[30]
    begin
        exit(NpXmlDomMgt.GetXmlText(Element, NodePath, 30, Required));
    end;

    local procedure GetXmlText40(Element: XmlElement; NodePath: Text; Required: Boolean): Text[40]
    begin
        exit(NpXmlDomMgt.GetXmlText(Element, NodePath, 40, Required));
    end;

    local procedure GetXmlText50(Element: XmlElement; NodePath: Text; Required: Boolean): Text[50]
    begin
        exit(NpXmlDomMgt.GetXmlText(Element, NodePath, 50, Required));
    end;

    local procedure GetXmlText80(Element: XmlElement; NodePath: Text; Required: Boolean): Text[80]
    begin
        exit(NpXmlDomMgt.GetXmlText(Element, NodePath, 80, Required));
    end;

    local procedure GetXmlText100(Element: XmlElement; NodePath: Text; Required: Boolean): Text[100]
    begin
        exit(NpXmlDomMgt.GetXmlText(Element, NodePath, 100, Required));
    end;

    local procedure GetXmlAttributeText20(Element: XmlElement; AttributeName: Text; Required: Boolean): Text[20]
    begin
        exit(CopyStr(NpXmlDomMgt.GetXmlAttributeText(Element, AttributeName, Required), 1, 20));
    end;

    local procedure GetXmlAttributeText100(Element: XmlElement; AttributeName: Text; Required: Boolean): Text[100]
    begin
        exit(CopyStr(NpXmlDomMgt.GetXmlAttributeText(Element, AttributeName, Required), 1, 100));
    end;

}

