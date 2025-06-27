codeunit 6248480 "NPR HL MCF Subscription Mgt."
{
    Access = Internal;

    var
        HLIntegrationSetup: Record "NPR HL Integration Setup";

    procedure UpgradeMembersToUseMCFSubscription(var Count: Integer)
    var
        Member: Record "NPR MM Member";
        HLMultiChoiceFieldMgt: Codeunit "NPR HL MultiChoice Field Mgt.";
    begin
        Clear(Count);
        HLIntegrationSetup.GetRecordOnce(false);
        if not HLIntegrationSetup."Enable MC Subscription" then
            exit;
        if HLIntegrationSetup."Member of MCF Code" = '' then
            exit;
        HLIntegrationSetup.TestField("Notification List Opt. ID");
        HLIntegrationSetup.TestField("Newsletter List Opt. ID");

        if Member.FindSet(true) then
            repeat
                HLMultiChoiceFieldMgt.AssignMCFOption(Member.RecordId(), HLIntegrationSetup."Member of MCF Code", HLIntegrationSetup."Notification List Opt. ID");
                if Member."E-Mail News Letter" = Member."E-Mail News Letter"::YES then
                    HLMultiChoiceFieldMgt.AssignMCFOption(Member.RecordId(), HLIntegrationSetup."Member of MCF Code", HLIntegrationSetup."Newsletter List Opt. ID")
                else begin
                    Member."E-Mail News Letter" := Member."E-Mail News Letter"::YES;
                    Member.Modify();
                    HLMultiChoiceFieldMgt.RemoveAssignedMCFOption(Member.RecordId(), HLIntegrationSetup."Member of MCF Code", HLIntegrationSetup."Newsletter List Opt. ID");
                end;
                Count += 1;
            until Member.Next() = 0;
    end;

    procedure GetMCFMemberOfVisible(): Boolean
    begin
        if not HLIntegrationSetup.Get() then
            Clear(HLIntegrationSetup);
        exit(HLIntegrationSetup."Enable MC Subscription" and (HLIntegrationSetup."Member of MCF Code" <> ''));
    end;

    #region Subscribers
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR HL Integration Events", 'OnAfterManuallyModifyAssignedHLMCFOptionValues', '', false, false)]
    local procedure UpdateNewsletterStatus(AppliesToRecID: RecordId; MultiChoiceFieldCode: Code[20])
    var
        Member: Record "NPR MM Member";
        xMember: Record "NPR MM Member";
        HLMultiChoiceFieldMgt: Codeunit "NPR HL MultiChoice Field Mgt.";
        RecRef: RecordRef;
        MemberOfNotifList: Boolean;
        NotifListAutoSelectedMsg: Label 'A member cannot be included in HL Newsletter list and at the same time excluded from Notification list. System selected the Notification list automatically for the member.';
    begin
        if (AppliesToRecID.TableNo <> Database::"NPR MM Member") or (MultiChoiceFieldCode = '') then
            exit;
        HLIntegrationSetup.GetRecordOnce(false);
        if MultiChoiceFieldCode <> HLIntegrationSetup."Member of MCF Code" then
            exit;
        HLIntegrationSetup.TestField("Notification List Opt. ID");
        HLIntegrationSetup.TestField("Newsletter List Opt. ID");

        MemberOfNotifList := HLMultiChoiceFieldMgt.MCFOptionIsAssigned(AppliesToRecID, MultiChoiceFieldCode, HLIntegrationSetup."Notification List Opt. ID");
        if not MemberOfNotifList then
            if HLMultiChoiceFieldMgt.MCFOptionIsAssigned(AppliesToRecID, MultiChoiceFieldCode, HLIntegrationSetup."Newsletter List Opt. ID") then begin
                HLMultiChoiceFieldMgt.AssignMCFOption(AppliesToRecID, HLIntegrationSetup."Member of MCF Code", HLIntegrationSetup."Notification List Opt. ID");
                Message(NotifListAutoSelectedMsg);
                MemberOfNotifList := true;
            end;

        if not RecRef.Get(AppliesToRecID) then
            exit;
        RecRef.SetTable(Member);
        xMember := Member;
        if MemberOfNotifList then
            Member."E-Mail News Letter" := Member."E-Mail News Letter"::YES
        else
            if Member."E-Mail News Letter" = Member."E-Mail News Letter"::YES then
                Member."E-Mail News Letter" := Member."E-Mail News Letter"::NO;
        if xMember."E-Mail News Letter" <> Member."E-Mail News Letter" then
            Member.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR HL Integration Events", 'OnUpdateHLMemberWithDataFromHeyLoyalty', '', false, false)]
    local procedure UpdateMemberOfMCFOptions(var HLMember: Record "NPR HL HeyLoyalty Member"; var HLMemberRelatedDataUpdated: Boolean)
    var
        HLMultiChoiceFieldMgt: Codeunit "NPR HL MultiChoice Field Mgt.";
        MemberOfNotifList: Boolean;
    begin
        HLIntegrationSetup.GetRecordOnce(false);
        if HLIntegrationSetup."Member of MCF Code" = '' then
            exit;
        HLIntegrationSetup.TestField("Notification List Opt. ID");
        HLIntegrationSetup.TestField("Newsletter List Opt. ID");

        MemberOfNotifList := HLMultiChoiceFieldMgt.MCFOptionIsAssigned(HLMember.RecordId(), HLIntegrationSetup."Member of MCF Code", HLIntegrationSetup."Notification List Opt. ID");
        if HLMember."E-Mail News Letter" = HLMember."E-Mail News Letter"::YES then begin
            if not MemberOfNotifList then begin
                HLMultiChoiceFieldMgt.AssignMCFOption(HLMember.RecordId(), HLIntegrationSetup."Member of MCF Code", HLIntegrationSetup."Notification List Opt. ID");
                HLMemberRelatedDataUpdated := true;
            end;
            exit;
        end;

        if MemberOfNotifList then begin
            HLMultiChoiceFieldMgt.RemoveAssignedMCFOption(HLMember.RecordId(), HLIntegrationSetup."Member of MCF Code", HLIntegrationSetup."Notification List Opt. ID");
            HLMemberRelatedDataUpdated := true;
        end;
        if HLMultiChoiceFieldMgt.MCFOptionIsAssigned(HLMember.RecordId(), HLIntegrationSetup."Member of MCF Code", HLIntegrationSetup."Newsletter List Opt. ID") then begin
            HLMultiChoiceFieldMgt.RemoveAssignedMCFOption(HLMember.RecordId(), HLIntegrationSetup."Member of MCF Code", HLIntegrationSetup."Newsletter List Opt. ID");
            HLMemberRelatedDataUpdated := true;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR MM Member", 'OnAfterValidateEvent', 'E-Mail News Letter', false, false)]
    local procedure UpdateMemberOfMCFOptions_OnAfterEmailNewsLetterValidate(var Rec: Record "NPR MM Member")
    var
        HLMultiChoiceFieldMgt: Codeunit "NPR HL MultiChoice Field Mgt.";
        MemberOfNotifList: Boolean;
    begin
        if Rec.IsTemporary() or (Rec."Entry No." = 0) then
            exit;
        HLIntegrationSetup.GetRecordOnce(false);
        if HLIntegrationSetup."Member of MCF Code" = '' then
            exit;
        HLIntegrationSetup.TestField("Notification List Opt. ID");
        HLIntegrationSetup.TestField("Newsletter List Opt. ID");

        MemberOfNotifList := HLMultiChoiceFieldMgt.MCFOptionIsAssigned(Rec.RecordId(), HLIntegrationSetup."Member of MCF Code", HLIntegrationSetup."Notification List Opt. ID");
        if Rec."E-Mail News Letter" = Rec."E-Mail News Letter"::YES then begin
            if not MemberOfNotifList then
                HLMultiChoiceFieldMgt.AssignMCFOption(Rec.RecordId(), HLIntegrationSetup."Member of MCF Code", HLIntegrationSetup."Notification List Opt. ID");
            exit;
        end;

        if MemberOfNotifList then
            HLMultiChoiceFieldMgt.RemoveAssignedMCFOption(Rec.RecordId(), HLIntegrationSetup."Member of MCF Code", HLIntegrationSetup."Notification List Opt. ID");
        if HLMultiChoiceFieldMgt.MCFOptionIsAssigned(Rec.RecordId(), HLIntegrationSetup."Member of MCF Code", HLIntegrationSetup."Newsletter List Opt. ID") then
            HLMultiChoiceFieldMgt.RemoveAssignedMCFOption(Rec.RecordId(), HLIntegrationSetup."Member of MCF Code", HLIntegrationSetup."Newsletter List Opt. ID");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR MM Membership Events", 'OnAfterSetMemberFields', '', false, false)]
    local procedure UpdateMemberOfMCFOptionsFromMemberInfoCapture(var Member: Record "NPR MM Member")
    var
        HLMultiChoiceFieldMgt: Codeunit "NPR HL MultiChoice Field Mgt.";
    begin
        if Member."Entry No." = 0 then
            exit;

        HLIntegrationSetup.GetRecordOnce(false);
        if HLIntegrationSetup."Member of MCF Code" = '' then
            exit;
        HLIntegrationSetup.TestField("Notification List Opt. ID");
        HLIntegrationSetup.TestField("Newsletter List Opt. ID");

        HLMultiChoiceFieldMgt.AssignMCFOption(Member.RecordId(), HLIntegrationSetup."Member of MCF Code", HLIntegrationSetup."Notification List Opt. ID");
        if Member."E-Mail News Letter" = Member."E-Mail News Letter"::YES then begin
            HLMultiChoiceFieldMgt.AssignMCFOption(Member.RecordId(), HLIntegrationSetup."Member of MCF Code", HLIntegrationSetup."Newsletter List Opt. ID");
            exit;
        end;

        Member."E-Mail News Letter" := Member."E-Mail News Letter"::YES;
        HLMultiChoiceFieldMgt.RemoveAssignedMCFOption(Member.RecordId(), HLIntegrationSetup."Member of MCF Code", HLIntegrationSetup."Newsletter List Opt. ID");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR MM Membership Events", 'OnAfterMemberCreateEvent', '', false, false)]
    local procedure UpdateMemberOfMCFOptionsFromMemberInfoCaptureOnMemberCreate(var Member: Record "NPR MM Member")
    var
        HLMultiChoiceFieldMgt: Codeunit "NPR HL MultiChoice Field Mgt.";
    begin
        HLIntegrationSetup.GetRecordOnce(false);
        if HLIntegrationSetup."Member of MCF Code" = '' then
            exit;
        HLIntegrationSetup.TestField("Notification List Opt. ID");
        HLIntegrationSetup.TestField("Newsletter List Opt. ID");

        HLMultiChoiceFieldMgt.AssignMCFOption(Member.RecordId(), HLIntegrationSetup."Member of MCF Code", HLIntegrationSetup."Notification List Opt. ID");
        if Member."E-Mail News Letter" = Member."E-Mail News Letter"::YES then begin
            HLMultiChoiceFieldMgt.AssignMCFOption(Member.RecordId(), HLIntegrationSetup."Member of MCF Code", HLIntegrationSetup."Newsletter List Opt. ID");
            exit;
        end;

        Member."E-Mail News Letter" := Member."E-Mail News Letter"::YES;
        Member.Modify();
        HLMultiChoiceFieldMgt.RemoveAssignedMCFOption(Member.RecordId(), HLIntegrationSetup."Member of MCF Code", HLIntegrationSetup."Newsletter List Opt. ID");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR MM Membership Events", 'OnGetMembershipMembers_OnBeforeTempMemberInfoResponseInsert', '', false, false)]
    local procedure OverrideSubscriptionStatusSentToMagento(var TempMemberInfoResponse: Record "NPR MM Member Info Capture")
    var
        Member: Record "NPR MM Member";
        HLMultiChoiceFieldMgt: Codeunit "NPR HL MultiChoice Field Mgt.";
        NewsletterSubscriptionEnabled: Boolean;
    begin
        HLIntegrationSetup.GetRecordOnce(false);
        if HLIntegrationSetup."Member of MCF Code" = '' then
            exit;
        HLIntegrationSetup.TestField("Newsletter List Opt. ID");
        Member."Entry No." := TempMemberInfoResponse."Member Entry No";

        NewsletterSubscriptionEnabled := HLMultiChoiceFieldMgt.MCFOptionIsAssigned(Member.RecordId(), HLIntegrationSetup."Member of MCF Code", HLIntegrationSetup."Newsletter List Opt. ID");
        if NewsletterSubscriptionEnabled then
            TempMemberInfoResponse."News Letter" := TempMemberInfoResponse."News Letter"::YES
        else
            TempMemberInfoResponse."News Letter" := TempMemberInfoResponse."News Letter"::NO;
    end;
    #endregion Subscribers
}
