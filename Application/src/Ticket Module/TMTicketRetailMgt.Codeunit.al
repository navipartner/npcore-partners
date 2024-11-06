codeunit 6060117 "NPR TM Ticket Retail Mgt."
{
    Access = Internal;

    var
        ABORTED: Label 'Aborted.';
        SCHEDULE_ERROR: Label 'There was an error changing the reservation \\%1\\Do you want to try again?';

    procedure IssueTicket(Token: Text[100]; ExternalMemberNo: Code[20]; ResponseCode: Integer; ResponseMessage: Text; SaleLinePOS: Record "NPR POS Sale Line"; UpdateSalesLine: Boolean) Success: Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
    begin

        //-TM1.19 [266372]
        AssignSameSchedule(Token);
        AssignSameNotificationAddress(Token);

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("External Adm. Sch. Entry No.", '<=%1', 0);
        if (TicketReservationRequest.IsEmpty()) then begin
            ResponseCode := TicketRequestManager.IssueTicketFromReservationToken(Token, false, ResponseMessage);
            if (ResponseCode = 0) then begin

                Commit();
                AcquireTicketParticipant(Token, ExternalMemberNo);

                Commit();
                exit(true); // nothing to confirm;
            end;
        end;

        Commit();
        ResponseCode := -1;
        ResponseMessage := ABORTED;
        if (AcquireTicketAdmissionSchedule(Token, SaleLinePOS, UpdateSalesLine, ResponseMessage)) then begin
            ResponseMessage := '';
            ResponseCode := TicketRequestManager.IssueTicketFromReservationToken(Token, false, ResponseMessage);
        end;

        if (ResponseCode = 0) then begin

            Commit();
            AcquireTicketParticipant(Token, ExternalMemberNo);

            Commit();
            exit(true);
        end;

        exit(false);
    end;

    procedure UseFrontEndScheduleUX(): Boolean
    var
        TicketSetup: Record "NPR TM Ticket Setup";
    begin
        if (not TicketSetup.Get()) then
            exit(false);

        exit(TicketSetup.UseFrontEndScheduleUX);
    end;

    procedure AcquireTicketAdmissionSchedule(Token: Text[100]; var SaleLinePOS: Record "NPR POS Sale Line"; HaveSalesLine: Boolean; var ResponseMessage: Text) LookupOK: Boolean
    var
        PageAction: Action;
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";

        DisplayTicketReservationRequest: Page "NPR TM Ticket Make Reserv.";
        DisplayTicketReservationRequestPhone: Page "NPR TM TicketMakeReservePhone";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        AdmissionScheduleMgt: Codeunit "NPR TM Admission Sch. Mgt.";
        NewQuantity: Integer;
        TimeSlotDescription: Text[30];
        ResolvedByTable: Integer;
        ResultCode: Integer;
    begin

        TicketReservationRequest.Reset();
        TicketReservationRequest.FilterGroup(2);
        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.FilterGroup(0);

        TicketReservationRequest.FindSet();
        repeat
            if (TicketReservationRequest."Admission Code" <> '') then
                AdmissionScheduleMgt.CreateAdmissionSchedule(TicketReservationRequest."Admission Code", false, Today(), 'NPRTMTicketRetailMgt.AcquireTicketAdmissionSchedule()');
        until (TicketReservationRequest.Next() = 0);
        Commit();

        if (not HaveSalesLine) then begin
            // Get the ticket item from token line instead
            if (TicketReservationRequest.FindFirst()) then
                TicketRequestManager.TranslateBarcodeToItemVariant(TicketReservationRequest."External Item Code", SaleLinePOS."No.", SaleLinePOS."Variant Code", ResolvedByTable);
        end;

        ResultCode := 0;
        if (UseFrontEndScheduleUX()) then
            exit(false); // Schedule selection will be shown later

        if (Session.CurrentClientType = Session.CurrentClientType::Phone) then begin
            repeat
                Clear(DisplayTicketReservationRequestPhone);
                DisplayTicketReservationRequestPhone.LoadTicketRequest(Token);
                DisplayTicketReservationRequestPhone.SetTicketItem(SaleLinePOS."No.", SaleLinePOS."Variant Code");
                DisplayTicketReservationRequestPhone.AllowQuantityChange(HaveSalesLine);
                DisplayTicketReservationRequestPhone.SetAllowCustomizableTicketQtyChange(true);
                DisplayTicketReservationRequestPhone.LookupMode(false);
                DisplayTicketReservationRequestPhone.Editable(true);

                if (ResultCode <> 0) then
                    if (not Confirm(SCHEDULE_ERROR, true, ResponseMessage)) then
                        exit(false);

                PageAction := DisplayTicketReservationRequestPhone.RunModal();
                if (PageAction <> Action::OK) then begin
                    ResponseMessage := ABORTED;
                    exit(false);
                end;

                ResultCode := DisplayTicketReservationRequestPhone.FinalizeReservationRequest(false, ResponseMessage);
                if (ResultCode = 11) then begin
                    ResponseMessage := ''; // Silent error downstream
                    exit(false);
                end;

            until (ResultCode = 0);
            DisplayTicketReservationRequestPhone.GetChangedTicketQuantity(NewQuantity);
            TimeSlotDescription := DisplayTicketReservationRequestPhone.GetDefaultAdmissionScheduleDescription();

        end else begin
            repeat
                Clear(DisplayTicketReservationRequest);
                DisplayTicketReservationRequest.LoadTicketRequest(Token);
                DisplayTicketReservationRequest.SetTicketItem(SaleLinePOS."No.", SaleLinePOS."Variant Code");
                DisplayTicketReservationRequest.AllowQuantityChange(HaveSalesLine);
                DisplayTicketReservationRequest.SetAllowCustomizableTicketQtyChange(true);
                DisplayTicketReservationRequest.LookupMode(true);
                DisplayTicketReservationRequest.Editable(true);

                if (ResultCode <> 0) then
                    if (not Confirm(SCHEDULE_ERROR, true, ResponseMessage)) then
                        exit(false);

                PageAction := DisplayTicketReservationRequest.RunModal();
                if (PageAction <> Action::LookupOK) then begin
                    ResponseMessage := ABORTED;
                    exit(false);
                end;

                ResultCode := DisplayTicketReservationRequest.FinalizeReservationRequest(false, ResponseMessage);
                if (ResultCode = 11) then begin
                    ResponseMessage := ''; // Silent error downstream
                    exit(false);
                end;

            until (ResultCode = 0);
            DisplayTicketReservationRequest.GetChangedTicketQuantity(NewQuantity);
            TimeSlotDescription := DisplayTicketReservationRequest.GetDefaultAdmissionScheduleDescription();
        end;

        if (HaveSalesLine) then begin
            AdjustPriceOnSalesLine(SaleLinePOS, NewQuantity);
            SaleLinePOS."Description 2" := TimeSlotDescription;
            SaleLinePOS.Modify();
            Commit();
        end;

        exit(true);
    end;

    internal procedure AdjustPriceOnSalesLine(var SaleLinePOS: Record "NPR POS Sale Line"; NewQuantity: Integer)
    var
        Token: Text[100];
        TokenLineNumber: Integer;
    begin
        if (not GetRequestToken(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", Token, TokenLineNumber)) then
            exit;

        AdjustPriceOnSalesLine(SaleLinePOS, NewQuantity, Token, TokenLineNumber);
    end;

    internal procedure AdjustPriceOnSalesLine(var SaleLinePOS: Record "NPR POS Sale Line"; NewQuantity: Integer; Token: Text[100]; TokenLineNumber: Integer)
    var
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
        TicketPrice: Codeunit "NPR TM Dynamic Price";
        TicketUnitPrice: Decimal;
        DiscountAmount: Decimal;
        DiscountPercent: Decimal;
    begin
        DiscountAmount := 0;
        DiscountPercent := 0;

        if (SaleLinePOS.Quantity <> NewQuantity) then
            SaleLinePOS.Validate(Quantity, NewQuantity);

        if (SaleLinePOS."Discount %" <> 0) then begin
            SaleLinePOSAddOn.SetCurrentKey("Register No.", "Sales Ticket No.", "Sale Type", "Sale Date", "Sale Line No.", "Line No.");
            SaleLinePOSAddOn.SetFilter("Register No.", '=%1', SaleLinePOS."Register No.");
            SaleLinePOSAddOn.SetFilter("Sales Ticket No.", '=%1', SaleLinePOS."Sales Ticket No.");
            SaleLinePOSAddOn.SetFilter("Sale Type", '=%1', SaleLinePOSAddOn."Sale Type"::Sale);
            SaleLinePOSAddOn.SetFilter("Sale Date", '=%1', SaleLinePOS.Date);
            SaleLinePOSAddOn.SetFilter("Sale Line No.", '=%1', SaleLinePOS."Line No.");
            SaleLinePOSAddOn.SetFilter(AddToWallet, '=%1', true);
            if (SaleLinePOSAddOn.FindFirst()) then begin
                if (SaleLinePOSAddOn.DiscountAmount <> 0) then
                    DiscountAmount := SaleLinePOS."Discount Amount";
                if (SaleLinePOSAddOn.DiscountPercent <> 0) then
                    DiscountPercent := saleLinePOS."Discount %";
            end
        end;

        SaleLinePOS."Unit Price" := SaleLinePOS.FindItemSalesPrice(); // --> OnAfterFindSalesLinePrice() will not do GetTicketUnitPrice() when "Eksp. Salgspris" or "Custom Price" is set   

        if ((SaleLinePOS."Eksp. Salgspris") or (SaleLinePOS."Custom Price")) then
            if (TicketPrice.GetTicketUnitPrice(Token, TokenLineNumber, SaleLinePOS."Unit Price", SaleLinePOS."Price Includes VAT", SaleLinePOS."VAT %", TicketUnitPrice)) then
                SaleLinePOS."Unit Price" := TicketUnitPrice;

        if (DiscountAmount <> 0) then
            SaleLinePOS.Validate("Discount Amount", DiscountAmount); // Discount % is recalculated relative to new price
        if (DiscountPercent <> 0) then
            SaleLinePOS.Validate("Discount %", DiscountPercent);

        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        SaleLinePOS."Eksp. Salgspris" := false;
        SaleLinePOS."Custom Price" := false;
    end;


    procedure AcquireTicketParticipant(Token: Text[100]; ExternalMemberNo: Code[20]): Boolean
    begin
        exit(AcquireTicketParticipant(Token, ExternalMemberNo, false));
    end;

    procedure AcquireTicketParticipant(Token: Text[100]; ExternalMemberNo: Code[20]; ForceDialog: Boolean): Boolean
    var
        TicketNotifyParticipant: Codeunit "NPR TM Ticket Notify Particpt.";
        MemberManagement: Codeunit "NPR MM MembershipMgtInternal";
        Member: Record "NPR MM Member";
        SuggestMethod: Option NA,EMAIL,SMS;
        SuggestAddress: Text[100];
        SuggestName: Text[100];
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin

        if (Token = '') then
            exit(false);

        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindFirst()) then begin
            SuggestAddress := TicketReservationRequest."Notification Address";
            SuggestName := TicketReservationRequest.TicketHolderName;
            case TicketReservationRequest."Notification Method" of
                TicketReservationRequest."Notification Method"::EMAIL:
                    SuggestMethod := SuggestMethod::EMAIL;
                TicketReservationRequest."Notification Method"::SMS:
                    SuggestMethod := SuggestMethod::SMS;
                else
                    SuggestMethod := SuggestMethod::NA;
            end;
        end;

        if (ExternalMemberNo <> '') then begin
            if (Member.Get(MemberManagement.GetMemberFromExtMemberNo(ExternalMemberNo))) then begin
                SuggestName := Member."Display Name";
                case Member."Notification Method" of
                    Member."Notification Method"::EMAIL:
                        begin
                            SuggestMethod := SuggestMethod::EMAIL;
                            SuggestAddress := Member."E-Mail Address";
                        end;
                end;
            end;
        end;

        exit(TicketNotifyParticipant.AcquireTicketParticipantForce(Token, SuggestMethod, SuggestAddress, SuggestName, ForceDialog));
    end;

    procedure AssignSameSchedule(Token: Text[100])
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketReservationRequest2: Record "NPR TM Ticket Reservation Req.";
    begin

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("External Adm. Sch. Entry No.", '<=%1', 0);
        if (TicketReservationRequest.FindSet()) then begin
            repeat
                TicketReservationRequest2.Reset();
                if (TicketReservationRequest."Receipt No." <> '') then begin
                    TicketReservationRequest2.SetFilter("Receipt No.", '=%1', TicketReservationRequest."Receipt No.");
                end else begin
                    TicketReservationRequest2.SetFilter("Session Token ID", '=%1', Token);
                end;

                TicketReservationRequest2.SetFilter("Admission Code", '=%1', TicketReservationRequest."Admission Code");
                TicketReservationRequest2.SetFilter("External Adm. Sch. Entry No.", '>%1', 0);
                if (TicketReservationRequest2.FindLast()) then begin
                    TicketReservationRequest."External Adm. Sch. Entry No." := TicketReservationRequest2."External Adm. Sch. Entry No.";
                    TicketReservationRequest."Scheduled Time Description" := TicketReservationRequest2."Scheduled Time Description";
                    TicketReservationRequest.Modify();
                end;
            until (TicketReservationRequest.Next() = 0);
        end;
    end;

    procedure AssignSameNotificationAddress(Token: Text[100])
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketReservationRequest2: Record "NPR TM Ticket Reservation Req.";
    begin

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Notification Address", '=%1', '');
        if (TicketReservationRequest.FindSet()) then begin
            repeat
                TicketReservationRequest2.Reset();
                if (TicketReservationRequest."Receipt No." <> '') then begin
                    TicketReservationRequest2.SetFilter("Receipt No.", '=%1', TicketReservationRequest."Receipt No.");
                end else begin
                    TicketReservationRequest2.SetFilter("Session Token ID", '=%1', Token);
                end;

                TicketReservationRequest2.SetFilter("Admission Code", '=%1', TicketReservationRequest."Admission Code");
                TicketReservationRequest2.SetFilter("Notification Address", '<>%1', '');
                if (TicketReservationRequest2.FindLast()) then begin
                    TicketReservationRequest."Notification Method" := TicketReservationRequest2."Notification Method";
                    TicketReservationRequest."Notification Address" := TicketReservationRequest2."Notification Address";
                    TicketReservationRequest.TicketHolderName := TicketReservationRequest2.TicketHolderName;
                    TicketReservationRequest.Modify();
                end;
            until (TicketReservationRequest.Next() = 0);
        end;
    end;

    procedure AcquireAdditionalExperiences(Ticket: Record "NPR TM Ticket"; POSSession: Codeunit "NPR POS Session"; HaveSalesLine: Boolean; var ResponseMessage: Text) LookupOK: Boolean
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        PageAction: Action;
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        DisplayTicketReservationRequest: Page "NPR TM Ticket Make Reserv.";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        ResolvedByTable: Integer;
        ResultCode: Integer;
        Token: Text[100];
    begin

        TicketReservationRequest.Get(Ticket."Ticket Reservation Entry No.");
        if (not TicketRequestManager.CreateChangeRequestDynamicTicket(Ticket."External Ticket No.",
                  TicketReservationRequest."Authorization Code", Token, ResponseMessage)) then
            Error(ResponseMessage);
        Commit();

        if (not HaveSalesLine) then begin
            // Get the ticket item from token line instead
            if (TicketReservationRequest.FindFirst()) then
                TicketRequestManager.TranslateBarcodeToItemVariant(TicketReservationRequest."External Item Code", SaleLinePOS."No.", SaleLinePOS."Variant Code", ResolvedByTable);
        end;

        ResultCode := 0;
        repeat
            Clear(DisplayTicketReservationRequest);
            DisplayTicketReservationRequest.LoadTicketRequest(Token);
            DisplayTicketReservationRequest.SetTicketItem(Ticket."Item No.", Ticket."Variant Code");
            DisplayTicketReservationRequest.AllowQuantityChange(true);
            DisplayTicketReservationRequest.SetAllowCustomizableTicketQtyChange(true);
            DisplayTicketReservationRequest.LookupMode(true);
            DisplayTicketReservationRequest.Editable(true);

            if (ResultCode <> 0) then
                if (not Confirm(SCHEDULE_ERROR, true, ResponseMessage)) then
                    exit(false);

            PageAction := DisplayTicketReservationRequest.RunModal();
            if (PageAction <> Action::LookupOK) then begin
                ResponseMessage := ABORTED;
                TicketRequestManager.DeleteReservationRequest(Token, true);
                exit(false);
            end;


            ResultCode := DisplayTicketReservationRequest.FinalizeChangeRequestDynamicTicket(Ticket."No.", POSSession, true, ResponseMessage); //finalize should happen after the POS transaction is finished
            if (ResultCode = 11) then begin
                ResponseMessage := ''; // Silent error downstream
                exit(false);
            end;

        until (ResultCode = 0);

        //fetch correct quantity

        Commit();

        exit(true);
    end;

    procedure CreatePOSLinesForReservationRequest(TicketToken: Text; POSSale: Record "NPR POS Sale")
    var
        TicketReservationReq: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        Admission: Record "NPR TM Admission";
        POSSession: Codeunit "NPR POS Session";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        TicketPrice: Codeunit "NPR TM Dynamic Price";
        TicketUnitPrice: Decimal;
        AddonPrice: Decimal;
        POSSaleLineRec: Record "NPR POS Sale Line";
        LineNo: Integer;
        ExternalLineNumber: Integer;
        ListOfLines: List of [Integer];
        NewUnitPrice: Decimal;
    begin
        POSSession.GetSaleLine(POSSaleLine);

        TicketReservationReq.SetCurrentKey("Session Token ID", "Ext. Line Reference No.");
        TicketReservationReq.SetFilter("Session Token ID", '=%1', CopyStr(TicketToken, 1, MaxStrLen(TicketReservationReq."Session Token ID")));
        TicketReservationReq.SetFilter("Request Status", '=%1', TicketReservationReq."Request Status"::REGISTERED);
        if (TicketReservationReq.IsEmpty()) then
            exit;


        POSSaleLine.SetUsePresetLineNo(true);

        // Find the different orders in the request - will have different line numbers
        TicketReservationReq.Reset();
        TicketReservationReq.SetCurrentKey("Session Token ID", "Ext. Line Reference No.");
        TicketReservationReq.SetFilter("Session Token ID", '=%1', CopyStr(TicketToken, 1, MaxStrLen(TicketReservationReq."Session Token ID")));
        if (TicketReservationReq.FindSet()) then begin
            repeat
                if (not ListOfLines.Contains(TicketReservationReq."Ext. Line Reference No.")) then
                    ListOfLines.Add(TicketReservationReq."Ext. Line Reference No.");
            until (TicketReservationReq.Next() = 0);
        end;


        foreach ExternalLineNumber in ListOfLines do begin
            // Find the main ticket item line
            TicketReservationReq.Reset();
            TicketReservationReq.SetCurrentKey("Session Token ID", "Ext. Line Reference No.");
            TicketReservationReq.SetFilter("Session Token ID", '=%1', CopyStr(TicketToken, 1, MaxStrLen(TicketReservationReq."Session Token ID")));
            TicketReservationReq.SetFilter("Ext. Line Reference No.", '=%1', ExternalLineNumber);
            TicketReservationReq.SetFilter("Request Status", '=%1', TicketReservationReq."Request Status"::REGISTERED);
            TicketReservationReq.SetFilter("Primary Request Line", '=%1', true);
            TicketReservationReq.SetFilter("Admission Inclusion", '=%1', TicketReservationReq."Admission Inclusion"::REQUIRED);
            TicketReservationReq.FindFirst();

            TicketReservationReq.TestField("Admission Created");
            POSSaleLine.GetNewSaleLine(POSSaleLineRec);
            LineNo += 10000;

            POSSaleLineRec."Line Type" := POSSaleLineRec."Line Type"::Item;
            POSSaleLineRec."No." := TicketReservationReq."Item No.";
            POSSaleLineRec."Variant Code" := TicketReservationReq."Variant Code";
            POSSaleLineRec.Quantity := TicketReservationReq.Quantity;
            POSSaleLineRec."Description 2" := TicketReservationReq."Scheduled Time Description";
            POSSaleLineRec."Line No." := LineNo;

            TicketReservationReq."Line No." := LineNo;
            TicketReservationReq."Receipt No." := POSSaleLineRec."Sales Ticket No.";
            TicketReservationReq.Modify();

            Ticket.SetCurrentKey("Ticket Reservation Entry No.");
            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationReq."Entry No.");
            if (Ticket.FindSet()) then begin
                repeat
                    Ticket."Sales Receipt No." := POSSaleLineRec."Sales Ticket No.";
                    Ticket."Line No." := LineNo;
                    Ticket.Modify();
                until (Ticket.Next() = 0);
            end;

            POSSaleLine.InsertLine(POSSaleLineRec);

            // Update the remaining non-primary required admissions with same receipt number
            TicketReservationReq.SetFilter("Primary Request Line", '=%1', false);
            if (TicketReservationReq.FindSet()) then begin
                repeat
                    TicketReservationReq."Line No." := LineNo;
                    TicketReservationReq."Receipt No." := POSSaleLineRec."Sales Ticket No.";
                    TicketReservationReq.Modify();
                until TicketReservationReq.Next() = 0;
            end;

            // Each additional experience will have its own sales lines as they are charged on-top of the required experiences
            TicketReservationReq.SetFilter("Admission Inclusion", '=%1', TicketReservationReq."Admission Inclusion"::SELECTED);
            if (TicketReservationReq.FindSet()) then begin
                repeat
                    TicketReservationReq.TestField("Admission Created");

                    POSSaleLine.GetNewSaleLine(POSSaleLineRec);
                    LineNo += 10000;

                    Admission.Get(TicketReservationReq."Admission Code");
                    POSSaleLineRec."Line Type" := POSSaleLineRec."Line Type"::Item;
                    POSSaleLineRec."No." := Admission."Additional Experience Item No.";
                    POSSaleLineRec."Variant Code" := '';
                    POSSaleLineRec.Quantity := TicketReservationReq.Quantity;
                    POSSaleLineRec."Line No." := LineNo;
                    POSSaleLineRec."Description 2" := TicketReservationReq."Scheduled Time Description";
                    POSSaleLine.InsertLine(POSSaleLineRec);

                    if (TicketPrice.CalculateScheduleEntryPrice(POSSaleLineRec."No.", '', TicketReservationReq."Admission Code", TicketReservationReq."External Adm. Sch. Entry No.", POSSaleLineRec."Unit Price", POSSaleLineRec."Price Includes VAT", POSSaleLineRec."VAT %", Today(), Time(), TicketUnitPrice, AddonPrice)) then begin
                        if (TicketUnitPrice <> 0) then
                            NewUnitPrice := TicketUnitPrice + AddonPrice;
                        if (TicketUnitPrice = 0) then
                            NewUnitPrice := POSSaleLineRec."Unit Price" + AddonPrice;
                        if (NewUnitPrice < 0) then
                            NewUnitPrice := 0;
                        POSSaleLineRec.Validate("Unit Price", NewUnitPrice);
                        POSSaleLineRec.UpdateAmounts(POSSaleLineRec);
                        POSSaleLineRec."Eksp. Salgspris" := false;
                        POSSaleLineRec."Custom Price" := false;
                        POSSaleLineRec.Modify();
                    end;

                    TicketReservationReq."Line No." := LineNo;
                    TicketReservationReq."Receipt No." := POSSaleLineRec."Sales Ticket No.";
                    TicketReservationReq.Modify();

                until TicketReservationReq.Next() = 0;
            end;
        end;
    end;

    procedure UpdateTicketOnSaleLineInsert(SaleLinePOS: Record "NPR POS Sale Line")
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";

    begin
        SaleLinePOS.SetRecFilter();
        if (not SaleLinePOS.FindFirst()) then
            exit;

        if (not IsTicketSalesLine(SaleLinePOS)) then
            exit;

        // This is a ticket event
        TicketRequestManager.LockResources('UpdateTicketOnSaleLineInsert');
        TicketRequestManager.ExpireReservationRequests();

        if (SaleLinePOS.Quantity > 0) then
            NewTicketSales(SaleLinePOS);

        if (SaleLinePOS.Quantity < 0) then
            RevokeTicketSales(SaleLinePOS);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POSAction: Merg.Sml.LinesB", 'OnBeforeCollapseSaleLine', '', true, true)]
    local procedure OnBeforeCollapseSaleLine(SaleLinePOS: Record "NPR POS Sale Line"; var CollapseSupported: Boolean)
    begin
        if (not CollapseSupported) then
            exit;

        if (IsTicketSalesLine(SaleLinePOS)) then
            CollapseSupported := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale Line", 'OnBeforeDeletePOSSaleLine', '', true, true)]
    local procedure OnBeforeDeletePOSSaleLine(SaleLinePOS: Record "NPR POS Sale Line")
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        Token: Text[100];
        TokenLineNumber: Integer;
    begin
        if (not IsTicketSalesLine(SaleLinePOS)) then
            exit;

        // This is a ticket event
        if (GetRequestToken(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", Token, TokenLineNumber)) then begin
            if (TicketRequestManager.IsRequestStatusReservation(Token)) then
                exit;

            TicketRequestManager.DeleteReservationRequest(Token, true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR MM Membership Events", 'OnAssociateSaleWithMember', '', false, false)]
    local procedure OnAssociateSaleWithMember(POSSession: Codeunit "NPR POS Session"; ExternalMembershipNo: Code[20]; ExternalMemberNo: Code[20])
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        Token: Text[100];
        TokenLineNumber: Integer;
    begin
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if (not IsTicketSalesLine(SaleLinePOS)) then
            exit;

        if (GetRequestToken(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", Token, TokenLineNumber)) then
            TicketRequestManager.SetTicketMember(Token, ExternalMemberNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale Line", 'OnBeforeSetQuantity', '', true, true)]
    local procedure OnBeforeSetQuantity(SaleLinePOS: Record "NPR POS Sale Line"; var NewQuantity: Decimal)
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        POSUnit: Record "NPR POS Unit";
        Token: Text[100];
        INVALID_QTY: Label 'Invalid quantity. Old quantity %1, new quantity %2.';
        QuantityChangeNotAllowedLabel: Label 'You cannot change quantity when revoking a specific ticket.';
    begin
        if (not (TicketRequestManager.GetTokenFromReceipt(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", Token))) then
            exit;

        if ((SaleLinePOS.Quantity > 0) and (NewQuantity < 0)) or
           ((SaleLinePOS.Quantity < 0) and (NewQuantity > 0)) then
            Error(INVALID_QTY, SaleLinePOS.Quantity, NewQuantity);

        // Dont do what I dont mean!
        if (StrLen(Format(Abs(NewQuantity))) > 14) then
            Error('Is that a serial number?');
        if (StrLen(Format(Abs(NewQuantity))) in [12, 13, 14]) then
            Error('Oopsy woopsy, it looks like you scanned a barcode! Its a bit large to use as a quantity.');

        if (NewQuantity > SaleLinePOS.Quantity) then begin
            if (Abs(NewQuantity) > 20000) then
                Error('%1 is a ridiculous number of tickets! Create them in batches of 20000, if you really want that many.', NewQuantity);

            if (Abs(NewQuantity) > 100) then begin
                if (POSUnit.Get(SaleLinePOS."Register No.")) then
                    if (POSUnit."POS Type" = POSUnit."POS Type"::UNATTENDED) then
                        exit;

                if (not Confirm('Do you really want to create %1 tickets?', true, NewQuantity)) then
                    Error('');
            end;
        end;

        SaleLinePOS.Quantity := NewQuantity;

        if (SaleLinePOS.Quantity > 0) then begin
            TicketRequestManager.POS_OnModifyQuantity(SaleLinePOS);
            exit;
        end;

        if (SaleLinePOS.Quantity < 0) then begin
            if (SaleLinePOS."Return Sale Sales Ticket No." = '') then begin
                if (SaleLinePOS.Quantity = -1) then
                    exit;
                Error(QuantityChangeNotAllowedLabel);
            end;

            // when there is a return sales ticket number, there should be a revoke request
            TicketRequestManager.POS_OnModifyQuantity(SaleLinePOS);
            exit;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sales Price Calc.Mgt.W", 'OnAfterFindSalesLinePrice', '', true, true)]
    local procedure OnAfterFindSalesLinePrice(SalePOS: Record "NPR POS Sale"; var SaleLinePOS: Record "NPR POS Sale Line")
    var
        TicketPrice: Codeunit "NPR TM Dynamic Price";
        TicketUnitPrice: Decimal;
        Token: Text[100];
        TokenLineNumber: Integer;
    begin
        if ((SaleLinePOS."Eksp. Salgspris") or (SaleLinePOS."Custom Price")) then
            exit;

        if (not IsTicketSalesLine(SaleLinePOS)) then
            exit;

        if (GetRequestToken(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", Token, TokenLineNumber)) then begin

            if (TicketPrice.GetTicketUnitPrice(Token, TokenLineNumber, SaleLinePOS."Unit Price", SaleLinePOS."Price Includes VAT", SaleLinePOS."VAT %", TicketUnitPrice)) then
                if (SaleLinePOS."Unit Price" <> TicketUnitPrice) then
                    SaleLinePOS."Unit Price" := TicketUnitPrice;

        end;
    end;

    local procedure GetRequestToken(ReceiptNo: Code[20]; LineNumber: Integer; var Token: Text[100]; var TokenLineNumber: Integer): Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        Token := '';

        if (ReceiptNo = '') then
            exit(false);

        TicketReservationRequest.SetCurrentKey("Receipt No.");
        TicketReservationRequest.SetFilter("Receipt No.", '=%1', ReceiptNo);
        TicketReservationRequest.SetFilter("Line No.", '=%1', LineNumber);

        if (TicketReservationRequest.FindFirst()) then begin
            Token := TicketReservationRequest."Session Token ID";
            TokenLineNumber := TicketReservationRequest."Ext. Line Reference No.";
        end;

        exit(Token <> '');
    end;

    local procedure IsTicketSalesLine(SaleLinePOS: Record "NPR POS Sale Line"): Boolean
    var
        TicketType: Record "NPR TM Ticket Type";
        Item: Record Item;
    begin
        if (not Item.Get(SaleLinePOS."No.")) then
            exit(false);

        if (Item."NPR Ticket Type" = '') then
            exit(false);

        if (not TicketType.Get(Item."NPR Ticket Type")) then
            exit(false);

        exit(true);
    end;

    local procedure NewTicketSales(SaleLinePOS: Record "NPR POS Sale Line"): Integer
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketRetailManager: Codeunit "NPR TM Ticket Retail Mgt.";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        ResponseCode: Integer;
        ResponseMessage: Text;
        Token: Text[100];
        TokenLineNumber: Integer;
        ExternalMemberNo: Code[20];
        POSSession: Codeunit "NPR POS Session";
        FrontEnd: Codeunit "NPR POS Front End Management";
        SeatingUI: Codeunit "NPR TM Seating UI";
        RequiredAdmissionHasTimeSlots, AllAdmissionsRequired : Boolean;
    begin
        if (not GuiAllowed()) then
            exit(0); // Self Service mode over REST API.

        if (GetRequestToken(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", Token, TokenLineNumber)) then begin
            if (TicketRequestManager.IsRequestStatusReservation(Token)) then
                exit(0);

            TicketRequestManager.DeleteReservationRequest(Token, true);
        end;

        Token := TicketRequestManager.POS_CreateReservationRequest(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", SaleLinePOS."No.", SaleLinePOS."Variant Code", SaleLinePOS.Quantity, ExternalMemberNo);
        Commit();

        AssignSameSchedule(Token);
        AssignSameNotificationAddress(Token);

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("External Adm. Sch. Entry No.", '<=%1', 0);
        TicketReservationRequest.SetRange("Admission Inclusion", TicketReservationRequest."Admission Inclusion"::REQUIRED);
        RequiredAdmissionHasTimeSlots := TicketReservationRequest.IsEmpty();

        TicketReservationRequest.SetRange("External Adm. Sch. Entry No.");
        TicketReservationRequest.SetFilter("Admission Inclusion", '<>%1', TicketReservationRequest."Admission Inclusion"::REQUIRED);
        AllAdmissionsRequired := TicketReservationRequest.IsEmpty();

        if (RequiredAdmissionHasTimeSlots and AllAdmissionsRequired) then begin
            ResponseCode := TicketRequestManager.IssueTicketFromReservationToken(Token, false, ResponseMessage);
            if (ResponseCode = 0) then begin
                Commit();

                if (not TicketRetailManager.UseFrontEndScheduleUX()) then
                    AcquireTicketParticipant(Token, ExternalMemberNo, false);

                AdjustPriceOnSalesLine(SaleLinePOS, SaleLinePOS.Quantity, Token, TokenLineNumber);

                TicketReservationRequest.Reset();
                TicketReservationRequest.SetCurrentKey("Session Token ID");
                TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
                TicketReservationRequest.SetFilter("Ext. Line Reference No.", '=%1', TokenLineNumber);
                TicketReservationRequest.SetFilter(Default, '=%1', true);
                if (TicketReservationRequest.FindFirst()) then
                    SaleLinePOS."Description 2" := TicketReservationRequest."Scheduled Time Description";

                SaleLinePOS.Modify();
                Commit();

                POSSession.GetFrontEnd(FrontEnd);
                SeatingUI.ShowSelectSeatUI(FrontEnd, Token, false);

                exit(1); // nothing to confirm;
            end;
        end;

        Commit();

        ResponseCode := -1;
        ResponseMessage := ABORTED;
        if (AcquireTicketAdmissionSchedule(Token, SaleLinePOS, true, ResponseMessage)) then
            ResponseCode := TicketRequestManager.IssueTicketFromReservationToken(Token, false, ResponseMessage);

        if (ResponseCode = -1) and (TicketRetailManager.UseFrontEndScheduleUX()) then
            ResponseCode := 0;

        if (ResponseCode = 0) then begin
            Commit();

            if (not TicketRetailManager.UseFrontEndScheduleUX()) then
                AcquireTicketParticipant(Token, ExternalMemberNo, false);

            Commit();

            POSSession.GetFrontEnd(FrontEnd);
            SeatingUI.ShowSelectSeatUI(FrontEnd, Token, false);

            exit(1);
        end;

        TicketRequestManager.LockResources('NewTicketSales_3');
        SaleLinePOS.Delete();
        TicketRequestManager.DeleteReservationRequest(Token, true);
        Commit();
        Error(ResponseMessage);
    end;

    local procedure RevokeTicketSales(var ReturnSaleLinePOS: Record "NPR POS Sale Line")
    var
        Ticket: Record "NPR TM Ticket";
        OriginalSaleLine: Record "NPR POS Entry Sales Line";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        UnitPrice: Decimal;
        Token: Text[100];
        TicketCount: Integer;
        RevokeQuantity: Integer;

    begin
        if (ReturnSaleLinePOS."Return Sale Sales Ticket No." = '') then
            exit;

        OriginalSaleLine."Document No." := ReturnSaleLinePOS."Return Sale Sales Ticket No.";
        OriginalSaleLine."Line No." := ReturnSaleLinePOS."Line No.";

        // A return sales ticket line number can not be trusted to be the same as the original ticket line number
        if (not (IsNullGuid(ReturnSaleLinePOS."Orig.POS Entry S.Line SystemId"))) then
            OriginalSaleLine.GetBySystemId(ReturnSaleLinePOS."Orig.POS Entry S.Line SystemId");

        Ticket.SetFilter("Sales Receipt No.", '=%1', OriginalSaleLine."Document No.");
        Ticket.SetFilter("Line No.", '=%1', OriginalSaleLine."Line No.");

        if (Ticket.FindSet()) then begin
            Token := '';

            repeat
                UnitPrice := ReturnSaleLinePOS."Unit Price";
                if (TicketRequestManager.POS_CreateRevokeRequest(Token, Ticket."No.", ReturnSaleLinePOS."Sales Ticket No.", ReturnSaleLinePOS."Line No.", UnitPrice, RevokeQuantity)) then
                    TicketCount -= RevokeQuantity;
            until (Ticket.Next() = 0);

            // on partial refunds unit price will become altered and qty should be one.
            if (UnitPrice <> ReturnSaleLinePOS."Unit Price") then begin
                ReturnSaleLinePOS.Validate("Unit Price", UnitPrice);
                ReturnSaleLinePOS.Modify();
            end;

            if (TicketCount <> ReturnSaleLinePOS.Quantity) then begin
                ReturnSaleLinePOS.Quantity := TicketCount;
                ReturnSaleLinePOS.UpdateAmounts(ReturnSaleLinePOS);
                ReturnSaleLinePOS.Modify();
            end;
        end;
    end;

}

