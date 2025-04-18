﻿codeunit 6151139 "NPR TM Ticket WaitingList Mgr."
{
    Access = Internal;
    trigger OnRun()
    begin

        GenerateWaitingListNotifications(true);
    end;

    var
        REF_NOT_FOUND: Label '%1 %2 not found.';
        REF_EXPIRED_AT: Label '%1 has expired.';
        SCHEDULE_NOT_FOUND: Label 'There seems to be a problem with the %1 %2 for %3. Its not found or all entries have been cancelled.';
        MULTI_REDEEM_NOT_OK: Label '%1 %2 has already been redeemed.';

    procedure GetWaitingListAdmSchEntry(WaitingListReferenceCode: Code[10]; ReferenceDateTime: DateTime; WithRedeem: Boolean; var AdmissionScheduleEntryOut: Record "NPR TM Admis. Schedule Entry"; var TicketWaitingListOut: Record "NPR TM Ticket Wait. List"; var ResponseMessage: Text): Boolean
    var
        WaitingListEntry: Record "NPR TM Waiting List Entry";
        TicketWaitingList: Record "NPR TM Ticket Wait. List";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin

        WaitingListEntry.SetFilter("Reference Code", '=%1', WaitingListReferenceCode);
        if (not WaitingListEntry.FindFirst()) then begin
            ResponseMessage := StrSubstNo(REF_NOT_FOUND, WaitingListEntry.FieldCaption("Reference Code"), WaitingListReferenceCode);
            exit(false);
        end;

        WaitingListEntry.SetFilter("Expires At", '=%1|>%2', CreateDateTime(0D, 0T), ReferenceDateTime);
        if (not WaitingListEntry.FindFirst()) then begin
            ResponseMessage := StrSubstNo(REF_EXPIRED_AT, WaitingListReferenceCode);
            exit(false);
        end;

        if (not TicketWaitingList.Get(WaitingListEntry."Ticket Waiting List Entry No.")) then begin
            ResponseMessage := StrSubstNo(REF_NOT_FOUND, TicketWaitingList.FieldCaption("Entry No."), WaitingListEntry."Ticket Waiting List Entry No.");
            exit(false);
        end;

        AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', TicketWaitingList."External Schedule Entry No.");
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if (not AdmissionScheduleEntry.FindFirst()) then begin
            ResponseMessage := StrSubstNo(SCHEDULE_NOT_FOUND, AdmissionScheduleEntry.FieldCaption("External Schedule Entry No."), TicketWaitingList."External Schedule Entry No.", WaitingListReferenceCode);
            exit(false);
        end;

        if (WithRedeem) then begin
            if (TicketWaitingList.Status <> TicketWaitingList.Status::ACTIVE) then begin
                ResponseMessage := StrSubstNo(MULTI_REDEEM_NOT_OK, WaitingListEntry.FieldCaption("Reference Code"), WaitingListReferenceCode);
                exit(false);
            end;
            TicketWaitingList.Status := TicketWaitingList.Status::REDEEMED;
            TicketWaitingList.Modify();
        end;

        AdmissionScheduleEntryOut.TransferFields(AdmissionScheduleEntry, true);
        TicketWaitingListOut.TransferFields(TicketWaitingList, true);

        exit(true);
    end;

    procedure CreateWaitingListEntry(TicketReservationRequest: Record "NPR TM Ticket Reservation Req."; NotificationAddress: Text[100])
    var
        TicketWaitingList: Record "NPR TM Ticket Wait. List";
        Admission: Record "NPR TM Admission";
        WaitingListSetup: Record "NPR TM Waiting List Setup";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        TicketReservationRequestUpdate: Record "NPR TM Ticket Reservation Req.";
        DateTimeLbl: Label '%1 - %2', Locked = true;
    begin

        TicketWaitingList."Entry No." := 0;
        TicketWaitingList."Created At" := CurrentDateTime;

        AdmissionScheduleEntry.Reset();
        AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', TicketReservationRequest."External Adm. Sch. Entry No.");
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if (AdmissionScheduleEntry.FindFirst()) then
            TicketWaitingList."Schedule Entry Description" := StrSubstNo(DateTimeLbl, AdmissionScheduleEntry."Admission Start Date", AdmissionScheduleEntry."Admission Start Time");

        if (TicketReservationRequest."Admission Code" = '') then
            TicketReservationRequest."Admission Code" := AdmissionScheduleEntry."Admission Code";

        TicketWaitingList."External Schedule Entry No." := TicketReservationRequest."External Adm. Sch. Entry No.";
        TicketWaitingList."Admission Code" := TicketReservationRequest."Admission Code";
        TicketWaitingList."Notification Address" := NotificationAddress;

        TicketWaitingList.Token := TicketReservationRequest."Session Token ID";
        TicketWaitingList."Item No." := TicketReservationRequest."Item No.";
        TicketWaitingList."Variant Code" := TicketReservationRequest."Variant Code";
        TicketWaitingList.Quantity := TicketReservationRequest.Quantity;

        TicketWaitingList.Insert();

        if (Admission.Get(TicketReservationRequest."Admission Code")) then begin
            if (WaitingListSetup.Get(Admission."Waiting List Setup Code")) then begin
                if (WaitingListSetup."Notify On Opt-In") then
                    CreateAddToListNotification(TicketWaitingList, WaitingListSetup);
            end;
        end;

        TicketReservationRequestUpdate.Get(TicketReservationRequest."Entry No.");
        TicketReservationRequestUpdate."Request Status" := TicketReservationRequestUpdate."Request Status"::WAITINGLIST;
        TicketReservationRequestUpdate."Receipt No." := '';
        TicketReservationRequestUpdate."External Order No." := '';
        TicketReservationRequestUpdate."Line No." := 0;
        TicketReservationRequestUpdate.Modify();
    end;

    procedure CreateReferenceCode(AdmissionCode: Code[20]) ReferenceCode: Code[10]
    var
        WaitingListEntry: Record "NPR TM Waiting List Entry";
    begin

        Randomize();

        repeat
            // 6 chars A-Z, 0-9 is 36^6 = 2*10^9 combinations
            ReferenceCode := GetRandomAlphaNumericDigit();
            ReferenceCode += GetRandomAlphaNumericDigit();
            ReferenceCode += GetRandomAlphaNumericDigit();
            ReferenceCode += '-';
            ReferenceCode += GetRandomAlphaNumericDigit();
            ReferenceCode += GetRandomAlphaNumericDigit();
            ReferenceCode += GetRandomAlphaNumericDigit();
            // ReferenceCode += '-';
            // ReferenceCode += GetRandomAlphaNumericDigit();
            // ReferenceCode += GetRandomAlphaNumericDigit();

            // Make sure is unique
            WaitingListEntry.SetFilter("Reference Code", '=%1', ReferenceCode);

        until (WaitingListEntry.IsEmpty());
    end;

    local procedure GetRandomAlphaNumericDigit() AlphaDigit: Text[1]
    var
        r: Integer;
    begin

        r := Random(35);

        AlphaDigit[1] := 48 + r;

        if (r >= 10) then
            AlphaDigit[1] := 65 - 10 + r;
    end;

    local procedure CreateAddToListNotification(TicketWaitingList: Record "NPR TM Ticket Wait. List"; WaitingListSetup: Record "NPR TM Waiting List Setup")
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Admission: Record "NPR TM Admission";
        NotificationEntry: Record "NPR TM Ticket Notif. Entry";
        TicketNotifyParticipant: Codeunit "NPR TM Ticket Notify Particpt.";
    begin

        AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', TicketWaitingList."External Schedule Entry No.");
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if not (AdmissionScheduleEntry.FindFirst()) then
            exit;

        if (not Admission.Get(AdmissionScheduleEntry."Admission Code")) then
            exit;

        if (not WaitingListSetup.Get(Admission."Waiting List Setup Code")) then
            exit;

        AssignGeneralNotificationData(TicketWaitingList, Admission, AdmissionScheduleEntry, NotificationEntry);

        NotificationEntry."Ticket Trigger Type" := NotificationEntry."Ticket Trigger Type"::ADDED_TO_WL;
        NotificationEntry.Insert();
        Commit();

        NotificationEntry.SetRecFilter();
        TicketNotifyParticipant.SendGeneralNotification(NotificationEntry);
    end;

    local procedure CreateWaitingListNotifications(var TmpTicketWaitingList: Record "NPR TM Ticket Wait. List" temporary; var TmpNotificationEntryOut: Record "NPR TM Ticket Notif. Entry" temporary)
    begin

        TmpTicketWaitingList.Reset();
        if (not TmpTicketWaitingList.FindSet()) then
            exit;

        repeat
            CreateWaitingListNotification(TmpTicketWaitingList, TmpNotificationEntryOut)
        until (TmpTicketWaitingList.Next() = 0);
    end;

    procedure CreateWaitingListNotification(TicketWaitingList: Record "NPR TM Ticket Wait. List"; var TmpNotificationEntryOut: Record "NPR TM Ticket Notif. Entry" temporary)
    var
        WaitingListEntry: Record "NPR TM Waiting List Entry";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Admission: Record "NPR TM Admission";
        WaitingListSetup: Record "NPR TM Waiting List Setup";
        NotificationEntry: Record "NPR TM Ticket Notif. Entry";
    begin

        if (TicketWaitingList."External Schedule Entry No." <> AdmissionScheduleEntry."External Schedule Entry No.") then begin
            AdmissionScheduleEntry.Reset();
            AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', TicketWaitingList."External Schedule Entry No.");
            AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
            if not (AdmissionScheduleEntry.FindFirst()) then
                exit;

            if (not Admission.Get(AdmissionScheduleEntry."Admission Code")) then
                exit;

            if (not WaitingListSetup.Get(Admission."Waiting List Setup Code")) then
                exit;
        end;

        WaitingListEntry."Entry No." := 0;
        WaitingListEntry."Ticket Waiting List Entry No." := TicketWaitingList."Entry No.";
        WaitingListEntry."Created At" := CurrentDateTime();
        WaitingListEntry."Expires At" := WaitingListEntry."Created At" + WaitingListSetup."Expires In (Minutes)" * 60 * 1000;
        WaitingListEntry."Reference Code" := CreateReferenceCode(TicketWaitingList."Admission Code");
        WaitingListEntry.Insert();


        AssignGeneralNotificationData(TicketWaitingList, Admission, AdmissionScheduleEntry, NotificationEntry);

        NotificationEntry."Ticket Trigger Type" := NotificationEntry."Ticket Trigger Type"::NOTIFIED_BY_WL;
        NotificationEntry."Waiting List Reference Code" := WaitingListEntry."Reference Code";
        NotificationEntry."eTicket Pass Landing URL" := WaitingListSetup.URL;
        NotificationEntry.Insert();

        TmpNotificationEntryOut.TransferFields(NotificationEntry, true);
        TmpNotificationEntryOut.Insert();
    end;

    local procedure AssignGeneralNotificationData(TicketWaitingList: Record "NPR TM Ticket Wait. List"; Admission: Record "NPR TM Admission"; AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"; var NotificationEntry: Record "NPR TM Ticket Notif. Entry")
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
    begin

        NotificationEntry."Entry No." := 0;
        NotificationEntry."Date To Notify" := Today();

        NotificationEntry."Notification Trigger" := NotificationEntry."Notification Trigger"::WAITINGLIST;
        NotificationEntry."Notification Address" := TicketWaitingList."Notification Address";

        NotificationEntry."Ticket Token" := TicketWaitingList.Token;
        NotificationEntry."Quantity To Admit" := TicketWaitingList.Quantity;
        NotificationEntry."Ticket Holder E-Mail" := TicketWaitingList."Notification Address";

        NotificationEntry."Ticket Item No." := TicketWaitingList."Item No.";
        NotificationEntry."Ticket Variant Code" := TicketWaitingList."Variant Code";
        NotificationEntry."Ticket External Item No." := TicketRequestManager.GetExternalNo(TicketWaitingList."Item No.", TicketWaitingList."Variant Code");

        NotificationEntry."Admission Code" := Admission."Admission Code";
        NotificationEntry."Adm. Event Description" := Admission.Description;

        NotificationEntry."Admission Schedule Entry No." := AdmissionScheduleEntry."Entry No.";
        NotificationEntry."Relevant Date" := AdmissionScheduleEntry."Admission Start Date";
        NotificationEntry."Relevant Time" := AdmissionScheduleEntry."Admission Start Time";
        NotificationEntry."Relevant Datetime" := CreateDateTime(NotificationEntry."Relevant Date", NotificationEntry."Relevant Time");

        NotificationEntry."Notification Method" := NotificationEntry."Notification Method"::NA;
        if (StrPos(NotificationEntry."Notification Address", '@') > 0) then
            NotificationEntry."Notification Method" := NotificationEntry."Notification Method"::EMAIL;

        if (StrLen(DelChr(NotificationEntry."Notification Address", '<=>', '+0123456789 ')) = 0) then
            NotificationEntry."Notification Method" := NotificationEntry."Notification Method"::SMS;

        NotificationEntry."Notification Process Method" := NotificationEntry."Notification Process Method"::MANUAL;
    end;

    local procedure SelectWaitingListEntries(AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"; ReferenceDate: Date; ReferenceTime: Time; var TmpTicketWaitingListSelected: Record "NPR TM Ticket Wait. List" temporary)
    var
        Admission: Record "NPR TM Admission";
        WaitingListSetup: Record "NPR TM Waiting List Setup";
        TicketWaitingList: Record "NPR TM Ticket Wait. List";
        TempTicketWaitingList: Record "NPR TM Ticket Wait. List" temporary;
        TicketManagement: Codeunit "NPR TM Ticket Management";
        ReasonCode: Enum "NPR TM Sch. Block Sales Reason";
        ReferenceDateTime: DateTime;
        RemainingQty: Integer;
        SelectCounter: Integer;
        CandidateForNotification: Boolean;
        OpenNotificationCount: Integer;
    begin

        if (not Admission.Get(AdmissionScheduleEntry."Admission Code")) then
            exit;

        if (not WaitingListSetup.Get(Admission."Waiting List Setup Code")) then
            exit;

        // Check quiet hours
        if ((WaitingListSetup."Notify Daily From Time" > 0T) and (ReferenceTime < WaitingListSetup."Notify Daily From Time")) then
            exit;

        if ((WaitingListSetup."Notify Daily Until Time" > 0T) and (ReferenceTime > WaitingListSetup."Notify Daily Until Time")) then
            exit;

        TicketWaitingList.SetCurrentKey("External Schedule Entry No.", Status);
        TicketWaitingList.SetFilter("External Schedule Entry No.", '=%1', AdmissionScheduleEntry."External Schedule Entry No.");
        TicketWaitingList.SetFilter(Status, '=%1', TicketWaitingList.Status::ACTIVE);
        if (not TicketWaitingList.FindSet()) then
            exit;

        ReferenceDateTime := CreateDateTime(ReferenceDate, ReferenceTime);

        repeat
            TicketWaitingList.CalcFields("Notification Expires At", "Notification Count", "Notified At");

            if (ReferenceDateTime >= TicketWaitingList."Notified At") and (ReferenceDateTime <= TicketWaitingList."Notification Expires At") then
                OpenNotificationCount += 1;

            if (ReferenceDateTime > TicketWaitingList."Notification Expires At") then begin

                CandidateForNotification := TicketManagement.ValidateAdmSchEntryForSales(AdmissionScheduleEntry, TicketWaitingList."Item No.", TicketWaitingList."Variant Code", ReferenceDate, ReferenceTime, ReasonCode, RemainingQty);
                CandidateForNotification := CandidateForNotification and (RemainingQty >= TicketWaitingList.Quantity);
                CandidateForNotification := CandidateForNotification and (RemainingQty >= WaitingListSetup."Remaing Capacity Threshold");
                CandidateForNotification := CandidateForNotification and (TicketWaitingList."Notification Count" < WaitingListSetup."Max Notifications per Address");

                if (TicketWaitingList."Notification Expires At" > 0DT) then
                    CandidateForNotification := CandidateForNotification and (ReferenceDateTime > TicketWaitingList."Notification Expires At" + (WaitingListSetup."Notification Delay (Minutes)" * 60 * 1000));

                if (Format(WaitingListSetup."End Notify Before (Days)") <> '') then
                    CandidateForNotification := CandidateForNotification and (CalcDate(WaitingListSetup."End Notify Before (Days)", ReferenceDate) < AdmissionScheduleEntry."Admission Start Date");

                if (WaitingListSetup."End Notify Before (Minutes)" > 0) and (AdmissionScheduleEntry."Admission Start Date" = ReferenceDate) then
                    CandidateForNotification := CandidateForNotification and ((ReferenceTime + WaitingListSetup."End Notify Before (Minutes)" * 60 * 1000) < AdmissionScheduleEntry."Admission Start Time");

                if (CandidateForNotification) then begin
                    TempTicketWaitingList.TransferFields(TicketWaitingList, true);
                    TempTicketWaitingList."Temp Count" := TicketWaitingList."Notification Count";
                    TempTicketWaitingList."Temp Notified At" := TicketWaitingList."Notified At";
                    if (TicketWaitingList."Notified At" = 0DT) then
                        TempTicketWaitingList."Temp Notified At" := TicketWaitingList."Created At" + (WaitingListSetup."Notification Delay (Minutes)" * 60 * 1000);
                    TempTicketWaitingList.Insert();
                end;

            end;
        until (TicketWaitingList.Next() = 0);

        TempTicketWaitingList.Reset();
        if (TempTicketWaitingList.IsEmpty()) then
            exit;

        if (WaitingListSetup."Simultaneous Notification Cnt." = 0) then
            WaitingListSetup."Simultaneous Notification Cnt." := 100; // Lets not go bananas!

        if (OpenNotificationCount >= WaitingListSetup."Simultaneous Notification Cnt.") then
            exit;

        // Sort entries on ascending notification datetime, and reorder them using the order of selection
        TempTicketWaitingList.SetCurrentKey("Temp Notified At");
        TempTicketWaitingList.FindSet();
        repeat
            SelectCounter += 1;
            TmpTicketWaitingListSelected.TransferFields(TempTicketWaitingList, true);
            TmpTicketWaitingListSelected.Insert();
        until (TempTicketWaitingList.Next() = 0) or (SelectCounter + OpenNotificationCount >= WaitingListSetup."Simultaneous Notification Cnt.");
    end;

    procedure ProcessAdmissionScheduleEntry(AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"; ReferenceDate: Date; ReferenceTime: Time; SendNotifications: Boolean)
    var
        TempTicketWaitingListToNotify: Record "NPR TM Ticket Wait. List" temporary;
        TempTicketNotificationEntry: Record "NPR TM Ticket Notif. Entry" temporary;
        TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry";
        TicketNotifyParticipant: Codeunit "NPR TM Ticket Notify Particpt.";
        FromEntryNo: Integer;
        ToEntryNo: Integer;
    begin

        // Fill up the temp table TmpTicketWaitingListToNotify
        SelectWaitingListEntries(AdmissionScheduleEntry, ReferenceDate, ReferenceTime, TempTicketWaitingListToNotify);
        CreateWaitingListNotifications(TempTicketWaitingListToNotify, TempTicketNotificationEntry);

        if (not SendNotifications) then
            exit;

        TempTicketNotificationEntry.Reset();
        if (TempTicketNotificationEntry.IsEmpty()) then
            exit;

        TempTicketNotificationEntry.FindFirst();
        FromEntryNo := TempTicketNotificationEntry."Entry No.";

        TempTicketNotificationEntry.FindLast();
        ToEntryNo := TempTicketNotificationEntry."Entry No.";

        TicketNotificationEntry.SetFilter("Entry No.", '%1..%2', FromEntryNo, ToEntryNo);
        TicketNotificationEntry.SetFilter("Notification Trigger", '=%1', TicketNotificationEntry."Notification Trigger"::WAITINGLIST);

        Commit();

        TicketNotifyParticipant.SendGeneralNotification(TicketNotificationEntry);
    end;

    procedure ProcessAdmission(Admission: Record "NPR TM Admission"; ReferenceDate: Date; SendNotifications: Boolean)
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin

        AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', Admission."Admission Code");
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        AdmissionScheduleEntry.SetFilter("Allocation By", '=%1', AdmissionScheduleEntry."Allocation By"::WAITINGLIST);
        AdmissionScheduleEntry.SetFilter("Admission Start Date", '%1..', ReferenceDate);
        if (not AdmissionScheduleEntry.FindSet()) then
            exit;

        repeat
            ProcessAdmissionScheduleEntry(AdmissionScheduleEntry, ReferenceDate, Time, SendNotifications);

        until (AdmissionScheduleEntry.Next() = 0);
    end;

    procedure GenerateWaitingListNotifications(SendNotifications: Boolean)
    var
        Admission: Record "NPR TM Admission";
    begin

        Admission.SetFilter("Waiting List Setup Code", '<>%1', '');
        if (not Admission.FindSet()) then
            exit;

        repeat
            ProcessAdmission(Admission, Today, SendNotifications);
        until (Admission.Next() = 0);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR TM Ticket Management", 'OnDetailedTicketEvent', '', true, true)]
    local procedure OnDetailedTicketEvent(DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry")
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Admission: Record "NPR TM Admission";
        WaitingListSetup: Record "NPR TM Waiting List Setup";
    begin

        if (DetTicketAccessEntry."External Adm. Sch. Entry No." <= 0) then
            exit;

        AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', DetTicketAccessEntry."External Adm. Sch. Entry No.");
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if (not AdmissionScheduleEntry.FindLast()) then
            exit;

        if (not Admission.Get(AdmissionScheduleEntry."Admission Code")) then
            exit;

        if (not WaitingListSetup.Get(Admission."Waiting List Setup Code")) then
            exit;

        // NOTE: this occurs during posting, so sending should be false (sending SMS requires a commit)
        if (DetTicketAccessEntry.Type = DetTicketAccessEntry.Type::CANCELED_ADMISSION) then begin
            ; // Event is not needed as we are not triggering notification directly by a revoke
        end;
    end;
}

