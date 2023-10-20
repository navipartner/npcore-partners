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

        if (HLMember."Member Entry No." = 0) and ((HLMember."E-Mail Address" <> '') or (HLMember."Phone No." <> '')) then
            if HLWSMgt.GetMemberByContactInfo(HLMember."E-Mail Address", HLMember."Phone No.", Member) then begin
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
        HLIntegrationMgt: Codeunit "NPR HL Integration Mgt.";
    begin
        HLMember.TestField("HeyLoyalty Id");
        case HLIntegrationMgt.RequiredContactInfo() of
            "NPR HL Required Contact Method"::Email:
                HLMember.TestField("E-Mail Address");
            "NPR HL Required Contact Method"::Phone:
                HLMember.TestField("Phone No.");
            "NPR HL Required Contact Method"::Email_and_Phone:
                begin
                    HLMember.TestField("E-Mail Address");
                    HLMember.TestField("Phone No.");
                end;
            else
                if HLMember."Phone No." = '' then
                    HLMember.TestField("E-Mail Address");
        end;

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
        MemberInfoCapture."Customer No." := FindReusableCustomerNo(MemberInfoCapture);

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

    local procedure FindReusableCustomerNo(MemberInfoCapture: Record "NPR MM Member Info Capture"): Code[20]
    var
        Customer: Record Customer;
    begin
        if MemberInfoCapture."E-Mail Address" <> '' then begin
            Customer.SetRange("E-Mail", MemberInfoCapture."E-Mail Address");
            if Customer.IsEmpty() then
                Customer.SetFilter("E-Mail", '@' + ConvertStr(MemberInfoCapture."E-Mail Address", '@', '?'));
        end;
        if MemberInfoCapture."Phone No." <> '' then
            Customer.SetRange("Phone No.", MemberInfoCapture."Phone No.");
        if FindReusableCustomerNo(Customer) then
            exit(Customer."No.");

        if (MemberInfoCapture."E-Mail Address" <> '') and (MemberInfoCapture."Phone No." <> '') then begin
            Customer.SetRange("Phone No.");
            if FindReusableCustomerNo(Customer) then
                exit(Customer."No.");

            Customer.SetRange("Phone No.", MemberInfoCapture."Phone No.");
            Customer.SetRange("E-Mail", '');
            if FindReusableCustomerNo(Customer) then
                exit(Customer."No.");
        end;

        exit('');
    end;

    local procedure FindReusableCustomerNo(var Customer: Record Customer): Boolean
    var
        Membership: Record "NPR MM Membership";
        MembershipMgt: Codeunit "NPR MM Membership Mgt.";
    begin
        if Customer.Find('-') then
            repeat
                if not Customer.Mark() then begin
                    Customer.Mark(true);
                    Membership.SetRange("Customer No.", Customer."No.");
                    Membership.SetRange(Blocked, false);
                    if Membership.IsEmpty() then
                        exit(true);

                    Membership.FindFirst();
                    if not MembershipMgt.IsMembershipActive(Membership."Entry No.", Today, false) then
                        exit(true);
                end;
            until Customer.Next() = 0;
        exit(false);
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