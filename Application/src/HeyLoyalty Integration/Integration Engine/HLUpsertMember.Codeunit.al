codeunit 6060000 "NPR HL Upsert Member"
{
    Access = Internal;
    TableNo = "NPR HL HeyLoyalty Member";

    trigger OnRun()
    begin
        CheckIntegrationIsEnabled();
        ProcessIncomingMemberUpdateRequest(Rec);
    end;

    local procedure ProcessIncomingMemberUpdateRequest(HLMember: Record "NPR HL HeyLoyalty Member")
    var
        Member: Record "NPR MM Member";
        MembershipRole: Record "NPR MM Membership Role";
        HLWSMgt: Codeunit "NPR HL Member Webhook Handler";
        MemberMgt: Codeunit "NPR HL Member Mgt. Impl.";
    begin
        if not HLMember.Find() or HLMember.Deleted then
            exit;

        if (HLMember."Member Entry No." = 0) and (HLMember."E-Mail Address" <> '') then
            if HLWSMgt.GetMemberByEmailAddress(HLMember."E-Mail Address", Member) then begin
                HLMember."Member Entry No." := Member."Entry No.";
                if MemberMgt.FindMembershipRole(Member, MembershipRole) then
                    HLMember."Membership Entry No." := MembershipRole."Membership Entry No.";
                HLMember.Modify();
            end;

        if HLMember."Member Entry No." <> 0 then
            Member.Get(HLMember."Member Entry No.")
        else
            CreateNewMemberFromHL(HLMember, Member);
        UpdateMemberFromHL(HLMember, Member);
    end;

    local procedure CreateNewMemberFromHL(var HLMember: Record "NPR HL HeyLoyalty Member"; var Member: Record "NPR MM Member")
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        DataLogMgt: Codeunit "NPR Data Log Management";
    begin
        HLMember.TestField("HeyLoyalty Id");
        HLMember.TestField("E-Mail Address");

        MembershipSalesSetup.SetRange("Business Flow Type", MembershipSalesSetup."Business Flow Type"::MEMBERSHIP);
        MembershipSalesSetup.SetRange(Blocked, false);
        if HLMember."Membership Code" <> '' then
            MembershipSalesSetup.SetRange("Membership Code", HLMember."Membership Code");
        MembershipSalesSetup.FindFirst();
        MembershipSalesSetup.TestField("Membership Code");

        MemberInfoCapture.Init();
        MemberInfoCapture."Entry No." := 0;
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::NEW;
        MemberInfoCapture."Source Type" := MemberInfoCapture."Source Type"::FILE_IMPORT;
        MemberInfoCapture."Item No." := MembershipSalesSetup."No.";
        MemberInfoCapture."Membership Code" := MembershipSalesSetup."Membership Code";

        MemberInfoCapture."First Name" := HLMember."First Name";
        MemberInfoCapture."Middle Name" := HLMember."Middle Name";
        MemberInfoCapture."Last Name" := HLMember."Last Name";
        MemberInfoCapture.Gender := HLMember.Gender;
        MemberInfoCapture.Birthday := HLMember.Birthday;
        MemberInfoCapture."E-Mail Address" := HLMember."E-Mail Address";
        MemberInfoCapture."Phone No." := HLMember."Phone No.";
        MemberInfoCapture.Address := HLMember.Address;
        MemberInfoCapture.City := HLMember.City;
        MemberInfoCapture."Post Code Code" := HLMember."Post Code Code";
        MemberInfoCapture."GDPR Approval" := MemberInfoCapture."GDPR Approval"::ACCEPTED;
        MemberInfoCapture."News Letter" := HLMember."E-Mail News Letter";
        if HLMember."Country Code" <> '' then
            MemberInfoCapture."Country Code" := HLMember."Country Code"
        else
            MemberInfoCapture.Country := HLMember."HL Country Name";
        MemberInfoCapture."Store Code" := HLMember."Store Code";

        DataLogMgt.DisableDataLog(true);
        CreateMember(MembershipSalesSetup, MemberInfoCapture, MembershipEntry);
        Member.Get(MemberInfoCapture."Member Entry No");
        if HLMember."Member Created Datetime" <> 0DT then begin
            Member."Created Datetime" := HLMember."Member Created Datetime";
            Member.Modify();
        end;
        HLMember."Member Entry No." := Member."Entry No.";
        HLMember."Membership Entry No." := MembershipEntry."Entry No.";
        HLMember.Validate("Membership Code", MembershipEntry."Membership Code");
        HLMember.Modify();
        DataLogMgt.DisableDataLog(false);
    end;

    local procedure CreateMember(MembershipSalesSetup: Record "NPR MM Members. Sales Setup"; var MemberInfoCapture: Record "NPR MM Member Info Capture"; var MembershipEntry: Record "NPR MM Membership Entry")
    var
        MemberComunity: Record "NPR MM Member Community";
        MembershipNotification: Record "NPR MM Membership Notific.";
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberNotification: Codeunit "NPR MM Member Notification";
        MembershipMgt: Codeunit "NPR MM Membership Mgt.";
        MembershipEntryNo: Integer;
    begin
        clear(MembershipEntry);
        MembershipSetup.get(MembershipSalesSetup."Membership Code");
        MemberComunity.Get(MembershipSetup."Community Code");
        MemberComunity.CalcFields("Foreign Membership");
        MemberComunity.TestField("Foreign Membership", false);

        MembershipEntryNo := MembershipMgt.CreateMembershipAll(MembershipSalesSetup, MemberInfoCapture, true);
        if MembershipEntryNo <> 0 then begin
            MembershipNotification.SetRange("Membership Entry No.", MembershipEntryNo);
            MembershipNotification.SetRange("Notification Trigger", MembershipNotification."Notification Trigger"::RENEWAL);
            MembershipNotification.SetRange("Notification Status", MembershipNotification."Notification Status"::PENDING);
            MembershipNotification.ModifyAll("Notification Status", MembershipNotification."Notification Status"::CANCELED);

            MembershipEntry.SetRange("Membership Entry No.", MembershipEntryNo);
            if MembershipEntry.FindFirst() then begin
                MembershipEntry."Activate On First Use" := false;
                MembershipEntry.Modify();
                MemberNotification.AddMembershipRenewalNotification(MembershipEntry);
            end;
        end;
    end;

    local procedure UpdateMemberFromHL(var HLMember: Record "NPR HL HeyLoyalty Member"; var Member: Record "NPR MM Member")
    var
        xMember: Record "NPR MM Member";
        AttributeMgt: Codeunit "NPR HL Attribute Mgt.";
        DataLogMgt: Codeunit "NPR Data Log Management";
        HLIntegrationEvents: Codeunit "NPR HL Integration Events";
        HLMultiChoiceFieldMgt: Codeunit "NPR HL MultiChoice Field Mgt.";
    begin
        xMember := Member;

        Member."First Name" := HLMember."First Name";
        Member."Middle Name" := HLMember."Middle Name";
        Member."Last Name" := HLMember."Last Name";
        Member.Gender := HLMember.Gender;
        Member.Birthday := HLMember.Birthday;
        Member."E-Mail Address" := HLMember."E-Mail Address";
        Member."Phone No." := HLMember."Phone No.";
        Member.Address := HLMember.Address;
        Member.City := HLMember.City;
        Member."Post Code Code" := HLMember."Post Code Code";
        Member."Country Code" := HLMember."Country Code";
        if HLMember."Country Code" = '' then
            Member.Country := HLMember."HL Country Name";
        Member."Store Code" := HLMember."Store Code";
        Member."E-Mail News Letter" := HLMember."E-Mail News Letter";

        AttributeMgt.UpdateMemberAttributesFromHLMember(HLMember);
        HLMultiChoiceFieldMgt.UpdateMemberMCFOptionsFromHLMember(HLMember);
        HLIntegrationEvents.OnUpdateMemberFromHL(HLMember, Member);

        if Format(xMember) <> Format(Member) then begin
            DataLogMgt.DisableDataLog(true);
            Member.Modify(true);
            DataLogMgt.DisableDataLog(false);
        end;

        HLIntegrationEvents.OnAfterUpdateMemberFromHL(HLMember, Member);
    end;

    procedure CheckIntegrationIsEnabled()
    var
        HLIntegrationMgt: Codeunit "NPR HL Integration Mgt.";
        MemberIntegrIsNotEnabledErr: Label 'Member integration is not enabled. Please make sure both field "Enable Integration" and "Member Integration" are checked on "HeyLoyalty Integration Setup" page.';
    begin
        if not HLIntegrationMgt.IsEnabled("NPR HL Integration Area"::Members) then
            Error(MemberIntegrIsNotEnabledErr);
    end;
}