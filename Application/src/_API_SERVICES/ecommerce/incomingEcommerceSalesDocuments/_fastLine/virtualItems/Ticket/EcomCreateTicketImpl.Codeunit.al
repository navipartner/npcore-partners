#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248517 "NPR EcomCreateTicketImpl"
{
    Access = Internal;
    local procedure ValidateTicketLines(var EcomSalesHeader: Record "NPR Ecom Sales Header"): Boolean
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        SetTicketLinesToProcessFilters(EcomSalesLine, EcomSalesHeader);
        if not EcomSalesLine.FindSet() then
            exit(false);

        repeat
            ValidateEcommerceTicketLine(EcomSalesHeader, EcomSalesLine);
            CheckIfLineCanBeProcessed(EcomSalesLine, EcomSalesHeader);
        until EcomSalesLine.Next() = 0;
        exit(true);
    end;

    internal procedure ValidateEcommerceTicketLine(var EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomSalesLine: Record "NPR Ecom Sales Line")
    var
        ValidationLineErr: Label 'Ticket request validation failed for Ecommerce Line No. %1', Comment = '%1=Line No.';
    begin
        if not ValidTicketRequest(EcomSalesLine, EcomSalesHeader) then
            Error(ValidationLineErr, EcomSalesLine."Line No.");
    end;

    internal procedure CreateRequestsForTicketLines(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesHeader2: Record "NPR Ecom Sales Header";
        EcomSalesHeader3: Record "NPR Ecom Sales Header";
    begin
        EcomSalesHeader2.ReadIsolation := EcomSalesHeader2.ReadIsolation::UpdLock;
        EcomSalesHeader2.Get(EcomSalesHeader.RecordId);
        if EcomSalesHeader2."Ticket Reservation Token" <> '' then
            exit; // already processed
        if not ValidateTicketLines(EcomSalesHeader2) then
            exit;
        CreateReservationRequestsForToken(EcomSalesHeader2);
        if EcomSalesHeader2."Ticket Reservation Token" = '' then
            exit; // No requests created

        EcomSalesHeader3.ReadIsolation := EcomSalesHeader3.ReadIsolation::UpdLock;
        EcomSalesHeader3.Get(EcomSalesHeader.RecordId);
        if EcomSalesHeader3."Ticket Reservation Token" <> '' then
            exit; // already processed by another session
        EcomSalesHeader3."Ticket Reservation Token" := EcomSalesHeader2."Ticket Reservation Token";
        EcomSalesHeader3.Modify(true);
        Commit();
    end;

    local procedure CreateReservationRequestsForToken(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        TicketWebServiceMgr: Codeunit "NPR TM Ticket WebService Mgr";
        LineNumbers: List of [Integer];
    begin
        SetTicketLinesToProcessFilters(EcomSalesLine, EcomSalesHeader);
        if not EcomSalesLine.FindSet(true) then
            exit;

        if EcomSalesHeader."Ticket Reservation Token" <> '' then
            exit; // Requests already created
        EcomSalesHeader."Ticket Reservation Token" := CopyStr(GenerateToken(EcomSalesHeader."Ticket Reservation Token"), 1, MaxStrLen(EcomSalesHeader."Ticket Reservation Token"));

        repeat
            if not TicketRequestExists(EcomSalesHeader, EcomSalesLine."Line No.") then begin
                EcomSalesLine."Ticket Reservation Line Id" := CreateReservationRequest(EcomSalesLine, EcomSalesHeader);
                EcomSalesLine.Modify();
            end;
            LineNumbers.Add(EcomSalesLine."Line No.");
        until EcomSalesLine.Next() = 0;

        if (LineNumbers.Count = 0) or (EcomSalesHeader."Ticket Reservation Token" = '') then
            exit;

        TicketWebServiceMgr.FinalizeTicketReservation(EcomSalesHeader."Ticket Reservation Token", LineNumbers);
        HandleFailedReservation(EcomSalesHeader."Ticket Reservation Token");
        UpdateExpiryTimeBasedOnCapturedStatus(EcomSalesHeader);
        UpdateTicketReservationAfterFinalize(EcomSalesHeader);
    end;

    local procedure HandleFailedReservation(Token: Text[100])
    var
        TicketResponse: Record "NPR TM Ticket Reserv. Resp.";
        ResponseStatusErr: Label 'Ticket reservation failed for Ext. Line Reference No. %1. Message: %2.', Comment = '%1=Ext. Line Reference No., %2=Response Message';
    begin
        TicketResponse.SetCurrentKey("Session Token ID");
        TicketResponse.SetRange("Session Token ID", Token);
        TicketResponse.SetRange(Status, false);
        if not TicketResponse.FindFirst() then
            exit;
        TicketRequestManager.DeleteReservationRequest(Token, true);
        Commit();
        Error(ResponseStatusErr, TicketResponse."Ext. Line Reference No.", TicketResponse."Response Message");
    end;

    internal procedure CheckIfLineCanBeProcessed(EcommSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
        EcomSalesHeader.SetLoadFields("Creation Status");
        EcomSalesHeader.Get(EcommSalesLine."Document Entry No.");

        if EcomSalesHeader."Creation Status" = EcomSalesHeader."Creation Status"::Created then
            EcomSalesHeader.FieldError("Creation Status");

        if EcommSalesLine.Subtype <> EcommSalesLine.Subtype::Ticket then
            EcommSalesLine.FieldError(Subtype);

        if not EcommSalesLine.Captured then
            EcommSalesLine.FieldError(Captured);

        if (EcommSalesLine.Quantity = 0) then
            EcommSalesLine.FieldError(Quantity);

        if EcommSalesLine."Document Type" = EcommSalesLine."Document Type"::"Return Order" then
            EcommSalesLine.FieldError("Document Type");

        if EcommSalesLine."Virtual Item Process Status" = EcommSalesLine."Virtual Item Process Status"::Processed then
            EcommSalesLine.FieldError(EcommSalesLine."Virtual Item Process Status");
        IsTicketItem(EcommSalesLine."No.");
    end;

    local procedure TicketRequestExists(EcomSalesHeader: Record "NPR Ecom Sales Header"; LineNo: Integer): Boolean
    var
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        TicketRequest.SetCurrentKey("Session Token ID", "Ext. Line Reference No.");
        TicketRequest.SetFilter("Session Token ID", '=%1', EcomSalesHeader."Ticket Reservation Token");
        if LineNo <> 0 then
            TicketRequest.SetFilter("Ext. Line Reference No.", '%1', LineNo);
        exit(not TicketRequest.IsEmpty());
    end;

    local procedure IsTicketItem(ItemNo: Text[50])
    var
        Item: Record Item;
        ItemNoCode: Code[20];
    begin
        Evaluate(ItemNoCode, ItemNo);
        Item.SetLoadFields("NPR Ticket Type");
        Item.Get(ItemNoCode);
        Item.TestField("NPR Ticket Type");
    end;

    local procedure CreateReservationRequest(var EcommSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header") PrimarySystemId: Guid
    var
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
        ItemNoCode: Code[20];
    begin
#pragma warning disable AA0139
        Evaluate(ItemNoCode, EcommSalesLine."No.");
#pragma warning restore AA0139
        Clear(TicketRequest);
        TicketRequest."Session Token ID" := EcomSalesHeader."Ticket Reservation Token";
        TicketRequest."Request Status" := TicketRequest."Request Status"::WIP;
        TicketRequest."Request Status Date Time" := CurrentDateTime;
        TicketRequest."Created Date Time" := CurrentDateTime();
        TicketRequest."Ext. Line Reference No." := EcommSalesLine."Line No.";
        TicketRequest."Item No." := ItemNoCode;
        TicketRequest."Variant Code" := EcommSalesLine."Variant Code";
        TicketRequest."External Item Code" := TicketRequestManager.GetExternalNo(TicketRequest."Item No.", TicketRequest."Variant Code");
        TicketRequest.Quantity := EcommSalesLine.Quantity;
        TicketRequest."Admission Code" := TicketManager.GetDefaultAdmissionCode(ItemNoCode, EcommSalesLine."Variant Code");
        TicketRequest.TicketHolderName := EcomSalesHeader."Ticket Holder Name";
        TicketRequest.TicketHolderPreferredLanguage := EcomSalesHeader."Ticket Holder Preferred Lang";
        TicketBOM.Get(TicketRequest."Item No.", TicketRequest."Variant Code", TicketRequest."Admission Code");
        Admission.Get(TicketRequest."Admission Code");

        TicketRequest.Default := TicketBOM.Default;
        TicketRequest."Admission Inclusion" := TicketBOM."Admission Inclusion"::REQUIRED;
        TicketRequest."Admission Description" := Admission.Description;
        TicketRequest."Primary Request Line" := true;
        TicketRequest.Insert();
        PrimarySystemId := TicketRequest.SystemId;
    end;

    internal procedure GenerateToken(TargetField: Text) token: text
    begin
        Token := CopyStr(UpperCase(DelChr(Format(CreateGuid()), '=', '{}-')), 1, MaxStrLen(TargetField));
    end;

    internal procedure ValidateAndUpdateRequestsWithEcommerceDocNo(EcommSalesHeader: Record "NPR Ecom Sales Header")
    begin
        ValidateTicketRequest(EcommSalesHeader);
        UpdateExpiryTimeBasedOnCapturedStatus(EcommSalesHeader);
    end;

    internal procedure ValidateTicketRequest(EcommSalesHeader: Record "NPR Ecom Sales Header")
    var
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        InvalidTicketErr: Label 'No valid ticket reservations found for the provided Token.';
    begin
        TicketRequest.SetCurrentKey("Session Token ID");
        TicketRequest.SetFilter("Session Token ID", '=%1', EcommSalesHeader."Ticket Reservation Token");
        if not TicketRequest.FindFirst() then
            Error(InvalidTicketErr);

        TicketRequest.Reset();
        TicketRequest.SetFilter("Session Token ID", '=%1', EcommSalesHeader."Ticket Reservation Token");
        TicketRequest.SetFilter("Request Status", '<>%1', TicketRequest."Request Status"::REGISTERED);
        if TicketRequest.FindSet() then
            repeat
                if (TicketRequest."Request Status" <> TicketRequest."Request Status"::Confirmed) or
                   (TicketRequest."External Order No." <> EcommSalesHeader."External No.")
                then
                    Error(InvalidTicketErr);
            until TicketRequest.Next() = 0;
    end;

    internal procedure UpdateExpiryTimeBasedOnCapturedStatus(var EcommSalesHeader: Record "NPR Ecom Sales Header")
    var
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        AllCaptured: Boolean;
        NewExpiryDateTime: DateTime;
    begin
        EcomSalesLine.SetRange("Document Entry No.", EcommSalesHeader."Entry No.");
        EcomSalesLine.SetRange(Subtype, EcomSalesLine.Subtype::Ticket);
        EcomSalesLine.SetFilter(Quantity, '<>0');
        if not EcomSalesLine.IsEmpty() then begin
            EcomSalesLine.SetLoadFields(Captured);
            EcomSalesLine.SetRange(Captured, false);
            AllCaptured := EcomSalesLine.IsEmpty();
        end;
        NewExpiryDateTime := CalcNewExpiryDate(AllCaptured);

        TicketRequest.SetCurrentKey("Session Token ID");
        TicketRequest.SetLoadFields("Ecom Sales Id", "Expires Date Time", "Session Token ID", "Request Status");
        TicketRequest.SetFilter("Session Token ID", '=%1', EcommSalesHeader."Ticket Reservation Token");
        TicketRequest.SetFilter("Request Status", '=%1', TicketRequest."Request Status"::REGISTERED);
        if TicketRequest.FindSet() then
            repeat
                if TicketRequest."Ecom Sales Id" <> EcommSalesHeader.SystemId then
                    TicketRequest."Ecom Sales Id" := EcommSalesHeader.SystemId;
                TicketRequest."Expires Date Time" := NewExpiryDateTime;
                TicketRequest.Modify();
            until TicketRequest.Next() = 0;
    end;

    local procedure CalcNewExpiryDate(AllCaptured: Boolean) NewExpiryDateTime: DateTime
    begin
        if AllCaptured then
            NewExpiryDateTime := CreateDateTime(CalcDate('<+10Y>', DT2Date(CurrentDateTime())), DT2Time(CurrentDateTime()))
        else
            NewExpiryDateTime := CreateDateTime(CalcDate('<+30D>', DT2Date(CurrentDateTime())), DT2Time(CurrentDateTime()));
    end;

    local procedure UpdateTicketReservationAfterFinalize(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        TicketResponse: Record "NPR TM Ticket Reserv. Resp.";
        Ticket: Record "NPR TM Ticket";
        AccessEntry: Record "NPR TM Ticket Access Entry";
        DetailedEntry: Record "NPR TM Det. Ticket AccessEntry";
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        TicketRequest.Reset();
        TicketRequest.ReadIsolation := TicketRequest.ReadIsolation::UpdLock;
        TicketRequest.SetCurrentKey("Session Token ID");
        TicketRequest.SetLoadFields("Admission Created", "External Adm. Sch. Entry No.", "Admission Code", "Scheduled Time Description", "Ext. Line Reference No.");
        TicketRequest.SetFilter("Session Token ID", '=%1', EcomSalesHeader."Ticket Reservation Token");
        TicketRequest.FindSet();
        repeat
            if (TicketRequest."Admission Created") then begin
                TicketResponse.SetCurrentKey("Session Token ID");
                TicketResponse.SetLoadFields("Request Entry No.");
                TicketResponse.SetFilter("Session Token ID", '=%1', EcomSalesHeader."Ticket Reservation Token");
                TicketResponse.SetFilter("Ext. Line Reference No.", '=%1', TicketRequest."Ext. Line Reference No.");
                if (TicketResponse.FindFirst()) then begin
                    Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketResponse."Request Entry No.");
                    if (Ticket.FindFirst()) then begin
                        AccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
                        AccessEntry.SetFilter("Admission Code", '=%1', TicketRequest."Admission Code");
                        if (AccessEntry.FindFirst()) then begin
                            DetailedEntry.SetCurrentKey("Ticket Access Entry No.");
                            DetailedEntry.SetLoadFields("External Adm. Sch. Entry No.");
                            DetailedEntry.SetFilter("Ticket Access Entry No.", '=%1', AccessEntry."Entry No.");
                            DetailedEntry.SetFilter(Quantity, '>%1', 0);
                            DetailedEntry.SetFilter(Type, '=%1', DetailedEntry.Type::RESERVATION);
                            if (not DetailedEntry.FindLast()) then
                                DetailedEntry.SetFilter(Type, '=%1', DetailedEntry.Type::INITIAL_ENTRY);
                            if (not DetailedEntry.FindLast()) then
                                DetailedEntry.init();
                            if (DetailedEntry."External Adm. Sch. Entry No." <> 0) then
                                TicketRequest."External Adm. Sch. Entry No." := DetailedEntry."External Adm. Sch. Entry No.";
                        end;
                    end;
                end;

                if (TicketRequest."External Adm. Sch. Entry No." > 0) then begin
                    ScheduleEntry.SetLoadFields("Admission Start Date", "Admission Start Time");
                    ScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', TicketRequest."External Adm. Sch. Entry No.");
                    ScheduleEntry.SetFilter(Cancelled, '=%1', false);
                    if (ScheduleEntry.FindFirst()) then
                        TicketRequest."Scheduled Time Description" := StrSubstNo('%1 - %2', ScheduleEntry."Admission Start Date", ScheduleEntry."Admission Start Time");
                end;
                TicketRequest.Modify();
            end;

        until (TicketRequest.Next() = 0);
    end;

    internal procedure ShowRelatedTicketsAction(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        if EcomSalesHeader."Ticket Reservation Token" = '' then
            exit;

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', EcomSalesHeader."Ticket Reservation Token");
        ShowRelatedTicketsAction(TicketReservationRequest);
    end;

    internal procedure ShowRelatedTicketsAction(EcomSalesLine: Record "NPR Ecom Sales Line")
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        if IsNullGuid(EcomSalesLine."Ticket Reservation Line Id") then
            exit;
        if not TicketReservationRequest.GetBySystemId(EcomSalesLine."Ticket Reservation Line Id") then
            exit;
        TicketReservationRequest.SetRecFilter();
        ShowRelatedTicketsAction(TicketReservationRequest);
    end;

    local procedure ShowRelatedTicketsAction(var TicketReservationRequest: Record "NPR TM Ticket Reservation Req.")
    var
        Ticket: Record "NPR TM Ticket";
        TempTickets: Record "NPR TM Ticket" temporary;
    begin
        Ticket.SetCurrentKey("Ticket Reservation Entry No.");
        if TicketReservationRequest.FindSet() then
            repeat
                Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
                if (Ticket.FindSet()) then
                    repeat
                        TempTickets.TransferFields(Ticket);
                        if TempTickets.Insert() then;
                    until (Ticket.Next() = 0);
            until (TicketReservationRequest.Next() = 0);

        if not TempTickets.IsEmpty() then
            Page.Run(Page::"NPR TM Ticket List", TempTickets);
    end;

    internal procedure ValidTicketRequest(var EcommSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header"): Boolean
    var
        Admission: Record "NPR TM Admission";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        AdmissionCode: Code[20];
    begin
        AdmissionCode := GetAdmissionCode(EcommSalesLine);
        GetAdmissionOrError(AdmissionCode, Admission);
        ValidateSupportedDefaultSchedule(Admission);
        ValidateCapacityRules(Admission);
        ValidateScheduleAvailability(Admission, AdmissionCode);
        ValidateNoDependencyRules(Admission, AdmissionCode);
        GetTicketBomOrError(EcommSalesLine, AdmissionCode, TicketBOM);
        ValidateBomRules(TicketBOM, EcommSalesLine, AdmissionCode);
        exit(true);
    end;

    local procedure GetAdmissionCode(EcommSalesLine: Record "NPR Ecom Sales Line") AdmissionCode: Code[20]
    var
        ItemNoCode: Code[20];
    begin
        Evaluate(ItemNoCode, EcommSalesLine."No.");
        AdmissionCode := TicketManager.GetDefaultAdmissionCode(ItemNoCode, EcommSalesLine."Variant Code");
    end;

    local procedure GetAdmissionOrError(AdmissionCode: Code[20]; var Admission: Record "NPR TM Admission")
    var
        InvalidAdmissionCode: Label 'Admission Code [%1] is not a valid admission code.';
    begin
        if not Admission.Get(AdmissionCode) then
            Error(InvalidAdmissionCode, AdmissionCode);
    end;

    local procedure ValidateSupportedDefaultSchedule(Admission: Record "NPR TM Admission")
    var
        AdmissionCodeErr: Label 'Ticket with Admission Code %1 cannot be created from this flow because its Default Schedule is not supported. Please use the Ticket APIs for other scheduling options.';
    begin
        if (Admission."Default Schedule" <> Admission."Default Schedule"::NEXT_AVAILABLE) and
        (Admission."Default Schedule" <> Admission."Default Schedule"::NONE) and
        (Admission."Default Schedule" <> Admission."Default Schedule"::TODAY) then
            Error(AdmissionCodeErr, Admission."Admission Code");
    end;

    local procedure ValidateCapacityRules(Admission: Record "NPR TM Admission")
    var
        CapacityControlErr: Label 'Only ticket without Capacity control can be created from here. Please use the Ticket APIs for other options.', Locked = true;
        CapacityLimitErr: Label 'Only ticket with %1 Capacity Limits can be created from here. Please use the Ticket APIs for other options.', Locked = true;
    begin
        if Admission."Capacity Control" <> Admission."Capacity Control"::NONE then
            Error(CapacityControlErr);
        if Admission."Capacity Limits By" <> Admission."Capacity Limits By"::Override then
            Error(CapacityLimitErr, Admission."Capacity Limits By"::Override);
    end;

    local procedure ValidateScheduleAvailability(Admission: Record "NPR TM Admission"; AdmissionCode: Code[20])
    var
        NoOpenScheduleErr: Label 'Admission %1 has no open schedule entry for today.';
        NoAvailableScheduleErr: Label 'Admission %1 has no open schedule entry available.';
    begin
        if Admission."Default Schedule" = Admission."Default Schedule"::TODAY then
            if not CheckOpenScheduleEntryWithStartDate(AdmissionCode) then
                Error(NoOpenScheduleErr, AdmissionCode);
        if Admission."Default Schedule" = Admission."Default Schedule"::NEXT_AVAILABLE then
            if not CheckAnyOpenScheduleEntry(AdmissionCode) then
                Error(NoAvailableScheduleErr, AdmissionCode);
    end;

    local procedure ValidateNoDependencyRules(Admission: Record "NPR TM Admission"; AdmissionCode: Code[20])
    var
        DependencyErr: Label 'Admission %1 has dependency rules which are not supported for ecommerce tickets.', Locked = true;
    begin
        if Admission."Dependency Code" <> '' then
            Error(DependencyErr, AdmissionCode);
    end;

    local procedure GetTicketBomOrError(EcommSalesLine: Record "NPR Ecom Sales Line"; AdmissionCode: Code[20]; var TicketBOM: Record "NPR TM Ticket Admission BOM")
    var
        NoBomEntryErr: Label 'Admission Code %1 is not configured for item %2.';
    begin
#pragma warning disable AA0139
        if not TicketBOM.Get(EcommSalesLine."No.", EcommSalesLine."Variant Code", AdmissionCode) then
            Error(NoBomEntryErr, AdmissionCode, EcommSalesLine."No.");
#pragma warning restore AA0139
    end;

    local procedure ValidateBomRules(TicketBOM: Record "NPR TM Ticket Admission BOM"; EcommSalesLine: Record "NPR Ecom Sales Line"; AdmissionCode: Code[20])
    var
        AdmissionInclusionErr: Label 'Admission %1 is optional and cannot be used in the ecommerce direct flow. Use the Ticket Reservation APIs instead.', Locked = true;
        ActivationMethodErr: Label 'Admission %1 has activation method %2 which is not supported for ecommerce tickets.', Locked = true;
    begin
        if TicketBOM."Admission Inclusion" <> TicketBOM."Admission Inclusion"::REQUIRED then
            Error(AdmissionInclusionErr, AdmissionCode);

        if TicketBOM."Activation Method" = TicketBOM."Activation Method"::POS then
            Error(ActivationMethodErr, AdmissionCode, TicketBOM."Activation Method");

        if TicketBOM."Activation Method" = TicketBOM."Activation Method"::NA then
            ValidateTicketTypeActivationMethod(EcommSalesLine."No.", AdmissionCode);
    end;

    local procedure CheckOpenScheduleEntryWithStartDate(AdmissionCode: Code[20]): Boolean
    begin
        exit(CheckOpenScheduleEntry(AdmissionCode, true));
    end;

    local procedure CheckAnyOpenScheduleEntry(AdmissionCode: Code[20]): Boolean
    begin
        exit(CheckOpenScheduleEntry(AdmissionCode, false));
    end;

    local procedure CheckOpenScheduleEntry(AdmissionCode: Code[20]; CheckStartDate: Boolean): Boolean
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        TicketTimeHelper: Codeunit "NPR TM TimeHelper";
        LocalDateTime: DateTime;
        LocalDate: Date;
        LocalTime: Time;
        ResponseMessage: Text;
        ResponseCode: Integer;
    begin
        LocalDateTime := TicketTimeHelper.GetLocalTimeAtAdmission(AdmissionCode);
        LocalDate := DT2Date(LocalDateTime);
        LocalTime := DT2Time(LocalDateTime);

        ScheduleEntry.SetRange("Admission Code", AdmissionCode);
        ScheduleEntry.SetRange(Cancelled, false);
        ScheduleEntry.SetRange("Admission Is", ScheduleEntry."Admission Is"::OPEN);

        if CheckStartDate then
            ScheduleEntry.SetFilter("Admission Start Date", '<=%1', LocalDate);
        ScheduleEntry.SetFilter("Admission End Date", '>=%1', LocalDate);
        if not ScheduleEntry.FindSet() then
            exit(false);
        repeat
            if not TicketManagement.IsSelectedAdmissionSchEntryExpired(ScheduleEntry, LocalDate, LocalTime, ResponseMessage, ResponseCode) then
                exit(true);
        until ScheduleEntry.Next() = 0;

        exit(false);
    end;

    local procedure ValidateTicketTypeActivationMethod(ItemNo: Text[50]; AdmissionCode: Code[20])
    var
        Item: Record Item;
        TicketType: Record "NPR TM Ticket Type";
        ItemNoCode: Code[20];
        TicketTypeActivationMethodErr: Label 'Admission %1 cannot be used for ecommerce tickets because ticket type %2 uses a POS-only activation method.', locked = true;
    begin
        Evaluate(ItemNoCode, ItemNo);
        Item.SetLoadFields("NPR Ticket Type");
        if not Item.Get(ItemNoCode) then
            exit;
        if Item."NPR Ticket Type" = '' then
            exit;
        if not TicketType.Get(Item."NPR Ticket Type") then
            exit;
        if TicketType."Activation Method" in [TicketType."Activation Method"::POS_DEFAULT, TicketType."Activation Method"::POS_ALL] then
            Error(TicketTypeActivationMethodErr, AdmissionCode, Item."NPR Ticket Type");
    end;

    local procedure SetTicketLinesToProcessFilters(var EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
        EcomSalesLine.Reset();
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetRange(Subtype, EcomSalesLine.Subtype::Ticket);
        EcomSalesLine.SetFilter("Virtual Item Process Status", '<>%1', EcomSalesLine."Virtual Item Process Status"::Processed);
        EcomSalesLine.SetRange(Captured, true);
        EcomSalesLine.SetFilter(Quantity, '<>0');
    end;

    internal procedure ConfirmTickets(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesHeader2: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        ConfirmedWithDifDoc: Boolean;
        MissingtokenErr: Label 'Processing Token must be set before confirming tickets.';
        MissingReservationErr: Label 'No ticket reservations found for the provided Token or it was already confirmed with another document.';
        MismatchedErr: Label 'Ticket reservations were already confirmed with another Ecommerce order.';
    begin
        EcomSalesHeader2.Get(EcomSalesHeader.RecordId);

        if EcomSalesHeader2."Ticket Reservation Token" = '' then
            Error(MissingtokenErr);
        if not TicketRequestExists(EcomSalesHeader2, 0) then
            Error(MissingReservationErr);
        if AlreadyConfirmed(EcomSalesHeader2, ConfirmedWithDifDoc) then begin
            if ConfirmedWithDifDoc then
                Error(MismatchedErr);
            exit;
        end;
#pragma warning disable AA0139
        TicketRequestManager.SetReservationRequestExtraInfo(EcomSalesHeader2."Ticket Reservation Token", EcomSalesHeader2."Sell-to Email", EcomSalesHeader2."External No.", EcomSalesHeader2."Ticket Holder Name", EcomSalesHeader2."Ticket Holder Preferred Lang");
#pragma warning restore
        SetTicketLinesToProcessFilters(EcomSalesLine, EcomSalesHeader2);
        if not EcomSalesLine.FindSet() then
            exit;
        repeat
            if not IsNullGuid(EcomSalesLine."Ticket Reservation Line Id") then
                if TicketRequest.GetBySystemId(EcomSalesLine."Ticket Reservation Line Id") then begin
                    TicketRequestManager.ConfirmReservationRequestWithValidate(EcomSalesHeader2."Ticket Reservation Token", TicketRequest."Ext. Line Reference No.");
                    UpdateTicketOnConfirm(EcomSalesHeader2, EcomSalesLine, TicketRequest);
                end;
        until EcomSalesLine.Next() = 0;
    end;

    local procedure UpdateTicketOnConfirm(EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomSalesLine: Record "NPR Ecom Sales Line"; TicketRequest: Record "NPR TM Ticket Reservation Req.")
    var
        Ticket: Record "NPR TM Ticket";
        AmountExclVat: Decimal;
        AmountInclVat: Decimal;
    begin
        CalculateTicketAmounts(EcomSalesHeader, EcomSalesLine, AmountExclVat, AmountInclVat);
        Ticket.Reset();
        Ticket.SetRange("Ticket Reservation Entry No.", TicketRequest."Entry No.");
        Ticket.SetLoadFields(AmountExclVat, AmountInclVat, "Sales Header No.");
        if Ticket.FindSet(true) then
            repeat
                if Ticket."Sales Header No." = '' then
                    Ticket."Sales Header No." := TicketRequest."External Order No.";
                Ticket.AmountInclVat := AmountInclVat;
                Ticket.AmountExclVat := AmountExclVat;
                Ticket.Modify();
            until Ticket.Next() = 0;
    end;

    local procedure CalculateTicketAmounts(EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomSalesLine: Record "NPR Ecom Sales Line"; var AmountExclVat: Decimal; var AmountInclVat: Decimal)
    var
        QtyZeroErr: Label 'Invalid Ecommerce ticket line %1 (Quantity=0). This is a programming bug.', Comment = '%1 = EcomSalesLine.Line No.';
    begin
        AmountExclVat := 0;
        AmountInclVat := 0;
        if EcomSalesLine.Quantity = 0 then
            Error(QtyZeroErr, Format(EcomSalesLine."Line No."));
        if EcomSalesHeader."Price Excl. VAT" then begin
            AmountExclVat := EcomSalesLine."Line Amount" / EcomSalesLine.Quantity;
            AmountInclVat := AmountExclVat * (1 + EcomSalesLine."VAT %" / 100);
        end else begin
            AmountInclVat := EcomSalesLine."Line Amount" / EcomSalesLine.Quantity;
            AmountExclVat := AmountInclVat / (1 + EcomSalesLine."VAT %" / 100);
        end;
    end;

    local procedure AlreadyConfirmed(EcomSalesHeader: Record "NPR Ecom Sales Header"; var RaiseError: Boolean): Boolean
    var
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        TicketRequest.SetCurrentKey("Session Token ID");
        TicketRequest.SetFilter("Session Token ID", '=%1', EcomSalesHeader."Ticket Reservation Token");
        TicketRequest.SetFilter("Request Status", '=%1', TicketRequest."Request Status"::Confirmed);

        If not TicketRequest.FindFirst() then
            exit(false);

        RaiseError := TicketRequest."External Order No." <> EcomSalesHeader."External No.";
        exit(true);
    end;

    internal procedure ChangeEcommerceTicketReservationToken(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomCreateTicketProcess: Codeunit "NPR EcomCreateTicketProcess";
        TicketReservationRemap: Page "NPR Ticket Reservation Remap";
        TempRemapBuffer: Record "NPR Ticket Reservation Buffer" temporary;
        EcomSalesLine: Record "NPR Ecom Sales Line";
        ConfirmManagement: Codeunit "Confirm Management";
        ConfirmMsg: Label 'This action will allow assigning a different registered Ticket reservation token to this ecommerce document.\Do you want to continue?';
        NoSelectionErr: Label 'No reservation token was selected.';
        SuccessMsg: Label 'Ticket reservation token %1 has been successfully assigned to this document.', Comment = '%1=Session Token ID';
        NewReservationToken: Text[100];
    begin
        if (not EcomSalesHeader."Tickets Exist") then
            exit;
        if not ConfirmManagement.GetResponseOrDefault(ConfirmMsg, true) then
            exit;
        TicketReservationRemap.LookupMode(true);
        TicketReservationRemap.SetDocument(EcomSalesHeader);
        if TicketReservationRemap.RunModal() <> Action::LookupOK then
            exit;

        if not TicketReservationRemap.GetApplyConfirmed() then
            exit;

        NewReservationToken := TicketReservationRemap.GetNewReservationToken();
        if NewReservationToken = '' then
            Error(NoSelectionErr);

        TicketReservationRemap.GetLineMappings(TempRemapBuffer);
        if TempRemapBuffer.FindSet() then
            repeat
                EcomSalesLine.Reset();
                EcomSalesLine.SetRange("Document Entry No.", TempRemapBuffer."Document Entry No.");
                EcomSalesLine.SetRange("Line No.", TempRemapBuffer."Sales Line No.");
                EcomSalesLine.FindFirst();
                EcomSalesLine."Ticket Reservation Line Id" := TempRemapBuffer."Ticket Reservation Line Id";
                EcomSalesLine.Modify(true);
            until TempRemapBuffer.Next() = 0;

        EcomSalesHeader."Ticket Reservation Token" := NewReservationToken;
        EcomSalesHeader."Ticket Processing Status" := EcomSalesHeader."Ticket Processing Status"::Pending;
        EcomSalesHeader."Ticket Retry Count" := 0;
        EcomCreateTicketProcess.UpdateVirtualItemDocStatus(EcomSalesHeader);
        ClearVirtualItemErrorMessagesOnLines(EcomSalesHeader);
        EcomSalesHeader.Modify(true);
        UpdateExpiryTimeBasedOnCapturedStatus(EcomSalesHeader);

        Message(SuccessMsg, NewReservationToken);
    end;

    local procedure ClearVirtualItemErrorMessagesOnLines(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetRange(Subtype, EcomSalesLine.Subtype::Ticket);
        EcomSalesLine.ModifyAll("Virtual Item Process ErrMsg", '');
        EcomSalesLine.ModifyAll("Virtual Item Process Status", EcomSalesLine."Virtual Item Process Status"::" ");
    end;

    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketManager: Codeunit "NPR TM Ticket Management";
}
#endif
