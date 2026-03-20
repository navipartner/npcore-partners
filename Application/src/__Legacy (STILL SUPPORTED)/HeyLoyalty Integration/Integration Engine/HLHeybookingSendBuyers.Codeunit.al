codeunit 6151090 "NPR HL Heybooking Send Buyers"
{
    Access = Internal;
    TableNo = "NPR TM Ticket Notif. Entry";
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';

    var
        HLIntegrationSetup: Record "NPR HL Integration Setup";

    trigger OnRun()
    begin
        SendTicketBuyerInfoToHL(Rec);
    end;

    local procedure SendTicketBuyerInfoToHL(var TicketNotifEntry: Record "NPR TM Ticket Notif. Entry")
    var
        HLMember: Record "NPR HL HeyLoyalty Member";
        HLIntegrationMgt: Codeunit "NPR HL Integration Mgt.";
        HLMemberMgt: Codeunit "NPR HL Member Mgt. Impl.";
        ProcessedAddresses: List of [Text];
    begin
        if not HLIntegrationMgt.IsEnabled("NPR HL Integration Area"::Members) then
            exit;
        if not TicketNotifEntry.FindSet() then
            exit;
        HLIntegrationSetup.GetRecordOnce(false);
        repeat
            if (TicketNotifEntry."Notification Method" = TicketNotifEntry."Notification Method"::EMAIL) and (TicketNotifEntry."Notification Address" = '') then
                TicketNotifEntry."Notification Address" := TicketNotifEntry."Ticket Holder E-Mail";

            if (TicketNotifEntry."Notification Address" <> '') and not ProcessedAddresses.Contains(StrSubstNo('%1_%2', TicketNotifEntry."Notification Method", TicketNotifEntry."Notification Address")) then begin
                ProcessedAddresses.Add(StrSubstNo('%1_%2', TicketNotifEntry."Notification Method", TicketNotifEntry."Notification Address"));
                Clear(HLMember);
                if GetOrCreateHLMemberForBuyer(TicketNotifEntry, HLMember) then begin
                    EnsureNotifListSubscription(HLMember);
                    HLMemberMgt.ScheduleHLMemberProcessing(HLMember, CurrentDateTime(), false);
                    Commit();
                end;
            end;
        until TicketNotifEntry.Next() = 0;
    end;

    local procedure GetOrCreateHLMemberForBuyer(TicketNotifEntry: Record "NPR TM Ticket Notif. Entry"; var HLMember: Record "NPR HL HeyLoyalty Member"): Boolean
    var
        HLMemberMgt: Codeunit "NPR HL Member Mgt. Impl.";
        EmailAddress: Text[80];
        PhoneNo: Text[30];
        FirstName: Text[50];
        LastName: Text[50];
    begin
        if TicketNotifEntry."Notification Address" = '' then
            exit(false);

        case TicketNotifEntry."Notification Method" of
            TicketNotifEntry."Notification Method"::EMAIL:
                EmailAddress := CopyStr(TicketNotifEntry."Notification Address", 1, MaxStrLen(EmailAddress));
            TicketNotifEntry."Notification Method"::SMS:
                begin
                    EmailAddress := CopyStr(TicketNotifEntry."Ticket Holder E-Mail", 1, MaxStrLen(EmailAddress));
                    PhoneNo := CopyStr(TicketNotifEntry."Notification Address", 1, MaxStrLen(PhoneNo));
                end;
        end;

        Clear(HLMember);
        if HLMemberMgt.FindHLMemberByContactInfo(EmailAddress, PhoneNo, false, HLMember) then
            exit(true);

        HLMember.Reset();
        SplitHolderName(TicketNotifEntry."Ticket Holder Name", FirstName, LastName);
        HLMember.Init();
        HLMember."Entry No." := 0;
        HLMember."First Name" := FirstName;
        HLMember."Last Name" := LastName;
        HLMember."E-Mail Address" := EmailAddress;
        HLMember."Phone No." := PhoneNo;
        HLMember."E-Mail News Letter" := HLMember."E-Mail News Letter"::YES;
        HLMember.Insert(true);
        exit(true);
    end;

    local procedure EnsureNotifListSubscription(var HLMember: Record "NPR HL HeyLoyalty Member")
    var
        Member: Record "NPR MM Member";
        HLMultiChoiceFieldMgt: Codeunit "NPR HL MultiChoice Field Mgt.";
    begin
        if (HLIntegrationSetup."Member of MCF Code" = '') or (HLIntegrationSetup."Notification List Opt. ID" = 0) then
            exit;

        if HLMultiChoiceFieldMgt.MCFOptionIsAssigned(HLMember.RecordId(), HLIntegrationSetup."Member of MCF Code", HLIntegrationSetup."Notification List Opt. ID") then
            exit;
        HLMultiChoiceFieldMgt.AssignMCFOption(HLMember.RecordId(), HLIntegrationSetup."Member of MCF Code", HLIntegrationSetup."Notification List Opt. ID");

        if HLMember."Member Entry No." <> 0 then begin
            Member.Get(HLMember."Member Entry No.");
            if HLMultiChoiceFieldMgt.MCFOptionIsAssigned(Member.RecordId(), HLIntegrationSetup."Member of MCF Code", HLIntegrationSetup."Notification List Opt. ID") then
                exit;
            HLMultiChoiceFieldMgt.AssignMCFOption(Member.RecordId(), HLIntegrationSetup."Member of MCF Code", HLIntegrationSetup."Notification List Opt. ID");
        end;
    end;

    local procedure SplitHolderName(FullName: Text; var FirstName: Text[50]; var LastName: Text[50])
    var
        LastSpacePosition: Integer;
    begin
        FullName := FullName.Trim();
        LastSpacePosition := FullName.LastIndexOf(' ');
        if LastSpacePosition > 1 then begin
            FirstName := CopyStr(FullName.Substring(1, LastSpacePosition - 1), 1, MaxStrLen(FirstName));
            LastName := CopyStr(FullName.Substring(LastSpacePosition + 1), 1, MaxStrLen(LastName));
        end else begin
            FirstName := CopyStr(FullName, 1, MaxStrLen(FirstName));
            LastName := CopyStr(FullName, MaxStrLen(FirstName) + 1, MaxStrLen(LastName));
        end;
    end;
}