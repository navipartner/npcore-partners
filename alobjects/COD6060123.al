codeunit 6060123 "TM POS Action - Ticket Mgmt."
{
    // NPR5.30/TSA/20161213  CASE 260816 Initial version for Transcendence compliance
    // NPR5.32/TSA/20170320  CASE 269171 Support for changing a confirm tickets qty (down)
    // NPR5.32/TSA/20170323  CASE 269171 Partial Refund
    // TM1.21/TSA/20170511  CASE 267611 Changes to AquireTicketAdmissionSchedule to allow quantity change from dialog
    // NPR5.32.10/TSA/20170616  CASE 250631 Return sales limits
    // NPR5.32.10/TSA/20170616  CASE 279495 Fixed the scan if ticket number from EAN box and it was due the option value "default" was not handled in javascript WF.
    // TM1.23/TSA /20170717 CASE 284248 Added action "Pick-up Ticket Reservation"
    // TM1.23/TSA /20170726 CASE 285079 Added LockResource () to eliminate deadlock
    // TM1.28/TSA /20180129 CASE 301222 Added ConvertToMembership function
    // TM1.30/TSA /20180427 CASE 313196 Sloppy filter when returning ticket, not testing for a blank value
    // TM1.31/TSA /20180515 CASE 306040 OnBeforeSetQuantity changed to handle change qty when you scan a sale ticket on return sales
    // TM1.34/MHA /20180619  CASE 319425 Added OnAfterInsertSaleLine POS Sales Workflow
    // TM1.35/TSA/20180725  CASE 323330 Transport TM1.35 - 25 July 2018
    // TM1.36/MHA /20180817  CASE 326753 Added Ean Box Event Handler functions
    // TM1.36/TSA /20180817 CASE 325345 UpdateAmounts() called explicitly
    // TM1.36/TSA /20180817 CASE 325345 Checking if this ticket exists in the processing list when revoking
    // TM1.38/TSA /20181025 CASE 333413 Add qty limits
    // TM1.38/TSA /20181025 CASE 333705 Variants and revoke
    // TM1.38/TSA /20181109 CASE 335653 Signature change on POS_CreateRevokeRequest
    // TM1.39/TSA /20190124 CASE 343585 Check for blank receipt number for prepaid/postpaid tickets
    // TM1.40/MHA /20190328  CASE 350434 Added MaxStrLen to EanBox.Description in DiscoverEanBoxEvents()
    // TM1.41/TSA /20190509 CASE 353981 Schedule based pricing
    // TM1.41/TSA /20190527 CASE 356057 Revoke Ticket also sets the original sales ticket as a reference in return sales fields
    // TM1.42/TSA /20190826 CASE 357359 Seating UI
    // TM1.43/TSA /20190902 CASE 357359 Seating UI
    // TM1.43/TSA /20190910 CASE 368043 Refactored usage of "External Item Code"


    trigger OnRun()
    begin
    end;

    var
        ILLEGAL_VALUE: Label 'Value %1 is not a valid %2.';
        TICKET_NUMBER: Label 'Ticket Number';
        ABORTED: Label 'Aborted.';
        ERRORTITLE: Label 'Error.';
        INVALID_ADMISSION: Label 'Parameter %1 specifies an invalid value for admission code. %2 not found.';
        TicketNumberPrompt: Label 'Enter Ticketnumber:';
        TicketTitle: Label '%1 - Ticket Management.';
        TicketQtyPrompt: Label 'Confirm group ticket quantity (max %1):';
        ReferencePrompt: Label 'Enter Ticket Reference Number:';
        ActionDescription: Label 'This action handles ticket management functions.';
        NotAGroupTicket: Label 'Ticket %1 is not a group ticket.';
        QtyNotSettable: Label 'Quantity for ticket %1 can''t be changed.';
        Welcome: Label 'Welcome.';
        SCHEDULE_ERROR: Label 'There was an error changing the reservation \\%1\\Do you want to try again?';
        DELETE_SINGLE_ERROR: Label 'Changing quantiy on a return sale of tickets is not supported.\You may return either all tickets by keeping the line, or none by deleting the line.\Use the "Revoke Reservation" action to return individual tickets.';
        INVALID_QTY: Label 'Invalid quantity. Old quantity %1, new quantity %2.';
        Text000: Label 'Update Ticket metadata on Sale Line Insert';
        REVOKE_IN_PROGRESS: Label 'Ticket %1 is being processed for revoke and can''t be added at this time.';

    local procedure "--Subscribers"()
    begin
    end;

    local procedure ActionCode(): Text
    begin
        exit('TM_TICKETMGMT');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.2');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverActions(var Sender: Record "POS Action")
    var
        FunctionOptionString: Text;
        JSArr: Text;
        N: Integer;
    begin
        if Sender.DiscoverAction(
          ActionCode(),
          ActionDescription,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple)
        then begin
            FunctionOptionString := 'Admission Count,' +
                                    'Register Arrival,' +
                                    'Revoke Reservation,Edit Reservation,Reconfirm Reservation,' +
                                    'Edit Ticketholder,' +
                                    'Change Confirmed Ticket Quantity,Pickup Ticket Reservation,Convert To Membership';
            for N := 1 to 9 do
                JSArr += StrSubstNo('"%1",', SelectStr(N, FunctionOptionString));
            JSArr := StrSubstNo('var optionNames = [%1];', CopyStr(JSArr, 1, StrLen(JSArr) - 1));

            // Sender.RegisterWorkflowStep ('0', JSArr +'windowTitle = labels.TicketTitle.substitute (optionNames[param.Function].toString()); ');
            Sender.RegisterWorkflowStep('0', JSArr + 'if (param.Function < 0) {param.Function = 1;}; windowTitle = labels.TicketTitle.substitute (optionNames[param.Function].toString());');

            Sender.RegisterWorkflowStep('ticketnumber', '(context.ShowTicketDialog) && input ({caption: labels.TicketPrompt, title: windowTitle}).ok(respond).cancel(abort);');
            Sender.RegisterWorkflowStep('ticketquantity', '(context.ShowTicketQtyDialog) && numpad ({caption: labels.TicketQtyPrompt.substitute(context.TicketMaxQty), title: windowTitle, value: context.TicketQty}).cancel(abort);');
            Sender.RegisterWorkflowStep('ticketreference', '(context.ShowReferenceDialog) && input ({caption: labels.ReferencePrompt, title: windowTitle}).ok(respond).cancel(abort);');
            Sender.RegisterWorkflowStep('9', 'respond ();');
            Sender.RegisterWorkflowStep('verbose', '(context.Verbose) && message ({caption: context.VerboseMessage, title: windowTitle});');
            Sender.RegisterWorkflow(true);

            Sender.RegisterOptionParameter('Function', FunctionOptionString, 'Register Arrival');
            Sender.RegisterTextParameter('Admission Code', '');
            Sender.RegisterTextParameter('DefaultTicketNumber', '');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    var
        UI: Codeunit "POS UI Management";
    begin
        Captions.AddActionCaption(ActionCode, 'TicketPrompt', TicketNumberPrompt);
        Captions.AddActionCaption(ActionCode, 'TicketQtyPrompt', TicketQtyPrompt);
        Captions.AddActionCaption(ActionCode, 'TicketTitle', TicketTitle);
        Captions.AddActionCaption(ActionCode, 'ReferencePrompt', ReferencePrompt);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "POS Action"; Parameters: JsonObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; var Handled: Boolean)
    var
        Context: Codeunit "POS JSON Management";
        POSSaleLine: Codeunit "POS Sale Line";
        JSON: Codeunit "POS JSON Management";
        SaleLinePOS: Record "Sale Line POS";
        Token: Text[100];
        FunctionId: Integer;
        ShowTicketDialog: Boolean;
        ShowTicketQtyDialog: Boolean;
        ShowReferenceDialog: Boolean;
        DefaultTicketNumber: Text;
    begin

        if (not Action.IsThisAction(ActionCode())) then
            exit;

        JSON.InitializeJObjectParser(Parameters, FrontEnd);
        FunctionId := JSON.GetInteger('Function', true);
        DefaultTicketNumber := JSON.GetString('DefaultTicketNumber', false);

        if (FunctionId < 0) then
            FunctionId := 1;

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        ShowTicketDialog := false;
        ShowTicketQtyDialog := false;
        ShowReferenceDialog := false;

        case FunctionId of
            0:
                ShowTicketDialog := false; // Admission Count
            1:
                ShowTicketDialog := true; // Register Arrival
            2:
                ShowTicketDialog := true; // Revoke Reservation
            3:
                ShowTicketDialog := not (GetRequestToken(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", Token)); // Edit Reservation
            4:
                ShowTicketDialog := false; // Reconfirm Reservation
            5:
                ShowTicketDialog := not (GetRequestToken(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", Token)); // Edit Ticketholder
            6:
                begin // Change Confirmed Ticket Quantity
                    ShowTicketDialog := true;
                    ShowTicketQtyDialog := true;
                end;
            7:
                ShowReferenceDialog := true; // Pick-up Ticket Reservation
            8:
                ShowTicketDialog := true; // Convert To Membership
        end;

        Context.SetContext('ShowTicketDialog', ShowTicketDialog and (DefaultTicketNumber = ''));
        Context.SetContext('ShowTicketQtyDialog', ShowTicketQtyDialog);
        Context.SetContext('ShowReferenceDialog', ShowReferenceDialog);
        FrontEnd.SetActionContext(ActionCode, Context);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', true, true)]
    local procedure OnAction("Action": Record "POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        FunctionId: Integer;
        AdmissionCode: Code[20];
        ExternalTicketNumber: Code[50];
        TicketMaxQty: Integer;
        ShowQtyDialog: Boolean;
        DefaultTicketNumber: Text;
        TicketReference: Code[20];
    begin

        if (not Action.IsThisAction(ActionCode())) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        FunctionId := JSON.GetIntegerParameter('Function', true);
        if (FunctionId < 0) then
            FunctionId := 0;

        AdmissionCode := JSON.GetStringParameter('Admission Code', false);
        DefaultTicketNumber := JSON.GetStringParameter('DefaultTicketNumber', false);
        TicketReference := CopyStr(GetInput(JSON, 'ticketreference'), 1, MaxStrLen(TicketReference));
        JSON.InitializeJObjectParser(Context, FrontEnd);

        if (DefaultTicketNumber = '') then begin
            ExternalTicketNumber := CopyStr(GetInput(JSON, 'ticketnumber'), 1, MaxStrLen(ExternalTicketNumber));
        end else begin
            ExternalTicketNumber := CopyStr(DefaultTicketNumber, 1, MaxStrLen(ExternalTicketNumber));
            if (FunctionId = 1) then begin
                JSON.SetContext('Verbose', true);
                JSON.SetContext('VerboseMessage', Welcome);
            end;
        end;

        if (WorkflowStep = 'ticketnumber') then begin
            TicketMaxQty := GetGroupTicketQuantity(POSSession, JSON, ExternalTicketNumber, AdmissionCode, FunctionId, ShowQtyDialog);

            if (FunctionId = 6) then begin
                if (not ShowQtyDialog) then begin
                    JSON.SetContext('Verbose', true);
                    if (TicketMaxQty <= 1) then
                        JSON.SetContext('VerboseMessage', StrSubstNo(NotAGroupTicket, ExternalTicketNumber));
                    if (TicketMaxQty >= 2) then
                        JSON.SetContext('VerboseMessage', StrSubstNo(QtyNotSettable, ExternalTicketNumber));
                end;
            end;
        end;

        if (WorkflowStep = '9') then begin
            case FunctionId of
                0:
                    ShowQuickStatistics(AdmissionCode);
                1:
                    begin
                        SetGroupTicketConfirmedQuantity(POSSession, JSON, ExternalTicketNumber, AdmissionCode);
                        RegisterArrival(ExternalTicketNumber, AdmissionCode);
                    end;
                2:
                    RevokeTicketReservation(POSSession, ExternalTicketNumber);
                3:
                    EditReservation(POSSession, ExternalTicketNumber);
                4:
                    ReconfirmReservation(POSSession, ExternalTicketNumber);
                5:
                    EditTicketholder(POSSession, ExternalTicketNumber);
                6:
                    SetGroupTicketConfirmedQuantity(POSSession, JSON, ExternalTicketNumber, '');
                7:
                    PickupPreConfirmedTicket(POSSession, TicketReference);
                8:
                    ConvertToMembership(POSSession, Context, FrontEnd, ExternalTicketNumber, AdmissionCode);
                else
                    Error('Function with ID %1 is not implemented.', FunctionId);
            end;

            POSSession.RequestRefreshData();
        end;

        FrontEnd.SetActionContext(ActionCode, JSON);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150706, 'OnAfterInsertSaleLine', '', true, true)]
    local procedure UpdateTicketOnSaleLineInsert(POSSalesWorkflowStep: Record "POS Sales Workflow Step"; SaleLinePOS: Record "Sale Line POS")
    var
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        TicketType: Record "TM Ticket Type";
        Item: Record Item;
        Ticket: Record "TM Ticket";
        UnitPrice: Decimal;
        Token: Text[100];
        TicketCount: Integer;
        RevokeQuantity: Integer;
    begin
        //-TM1.34 [319425]
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;

        if POSSalesWorkflowStep."Subscriber Function" <> 'UpdateTicketOnSaleLineInsert' then
            exit;

        //+TM1.34 [319425]
        if (not IsTicketSalesLine(SaleLinePOS)) then
            exit;

        // This is a ticket event
        //-TM1.23 [285079]
        TicketRequestManager.LockResources();
        //+TM1.23 [285079]

        TicketRequestManager.ExpireReservationRequests();

        if (SaleLinePOS.Quantity > 0) then
            NewTicketSales(SaleLinePOS);

        if (SaleLinePOS.Quantity < 0) then begin

            //-#313196 [313196]
            if (SaleLinePOS."Return Sale Sales Ticket No." = '') then
                exit;
            //+#313196 [313196]

            Ticket.SetFilter("Sales Receipt No.", '=%1', SaleLinePOS."Return Sale Sales Ticket No.");
            Ticket.SetFilter("Line No.", '=%1', SaleLinePOS."Line No.");

            if (Ticket.FindSet()) then begin
                Token := '';

                repeat

                    UnitPrice := SaleLinePOS."Unit Price";
                    //-TM1.38 [335653]
                    // IF (TicketRequestManager.POS_CreateRevokeRequest (Token, Ticket."No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", UnitPrice)) THEN
                    //   TicketCount -= 1;

                    if (TicketRequestManager.POS_CreateRevokeRequest(Token, Ticket."No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", UnitPrice, RevokeQuantity)) then
                        TicketCount -= RevokeQuantity;
                    //+TM1.38 [335653]

                until (Ticket.Next() = 0);

                // on partial refunds unit price will become altered and qty should be one.
                if (UnitPrice <> SaleLinePOS."Unit Price") then begin
                    SaleLinePOS.Validate("Unit Price", UnitPrice);
                    SaleLinePOS.Modify();
                end;

                if (TicketCount <> SaleLinePOS.Quantity) then begin
                    SaleLinePOS.Quantity := TicketCount;

                    //-TM1.36 [325345]
                    SaleLinePOS.UpdateAmounts(SaleLinePOS);
                    //+TM1.36 [325345]

                    SaleLinePOS.Modify();
                end;

            end;
            //+NPR5.32.10 [250631]
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150706, 'OnBeforeDeletePOSSaleLine', '', true, true)]
    local procedure OnBeforeDeletePOSSaleLine(SaleLinePOS: Record "Sale Line POS")
    var
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        TicketType: Record "TM Ticket Type";
        Item: Record Item;
        Token: Text[100];
    begin

        if (not IsTicketSalesLine(SaleLinePOS)) then
            exit;

        // This is a ticket event
        if (GetRequestToken(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", Token)) then begin
            if (TicketRequestManager.IsRequestStatusReservation(Token)) then
                exit;

            TicketRequestManager.DeleteReservationRequest(Token, true);

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060138, 'OnAssociateSaleWithMember', '', false, false)]
    local procedure OnAssociateSaleWithMember(POSSession: Codeunit "POS Session"; ExternalMembershipNo: Code[20]; ExternalMemberNo: Code[20])
    var
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        POSSaleLine: Codeunit "POS Sale Line";
        SaleLinePOS: Record "Sale Line POS";
        Token: Text[100];
    begin

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if (not IsTicketSalesLine(SaleLinePOS)) then
            exit;

        if (GetRequestToken(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", Token)) then
            TicketRequestManager.SetTicketMember(Token, ExternalMemberNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150706, 'OnBeforeSetQuantity', '', true, true)]
    local procedure OnBeforeSetQuantity(SaleLinePOS: Record "Sale Line POS"; var NewQuantity: Decimal)
    var
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        SeatingUI: Codeunit "TM Seating UI";
        POSSession: Codeunit "POS Session";
        FrontEnd: Codeunit "POS Front End Management";
        TicketType: Record "TM Ticket Type";
        Item: Record Item;
        Ticket: Record "TM Ticket";
        Token: Text[100];
        ResponseMessage: Text;
        ResponseCode: Integer;
        UnitPrice: Decimal;
        CreateCount: Integer;
    begin

        if (not IsTicketSalesLine(SaleLinePOS)) then
            exit;

        if ((SaleLinePOS.Quantity > 0) and (NewQuantity < 0)) or
           ((SaleLinePOS.Quantity < 0) and (NewQuantity > 0)) then
            Error(INVALID_QTY, SaleLinePOS.Quantity, NewQuantity);


        //-TM1.38 [333413]
        // Dont do what I dont mean!
        if (StrLen(Format(Abs(NewQuantity))) > 14) then
            Error('Is that a serial number?');

        if (StrLen(Format(Abs(NewQuantity))) in [12, 13, 14]) then
            Error('Oopsy woopsy, it looks like you scanned a barcode! Its a bit large to use as a quantity.');

        if (NewQuantity > SaleLinePOS.Quantity) then begin
            if (Abs(NewQuantity) > 20000) then
                Error('%1 is a ridiculous number of tickets! Create them in batches of 20000, if you really want that many.', NewQuantity);

            if (Abs(NewQuantity) > 100) then
                if (not Confirm('Do you really want to create %1 tickets?', true, NewQuantity)) then
                    Error('');
        end;
        //+TM1.38 [333413]

        SaleLinePOS.Quantity := NewQuantity;

        if (SaleLinePOS.Quantity > 0) then begin
            TicketRequestManager.POS_OnModifyQuantity(SaleLinePOS);
          //-TM1.43 [357359]
          if (TicketRequestManager.GetTokenFromReceipt (SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", Token)) then begin
            if (POSSession.IsActiveSession (FrontEnd)) then
              SeatingUI.ShowSelectSeatUI (FrontEnd, Token);
          end;
          //+TM1.43 [357359]
            exit;
        end;

        //-TM1.31 [306040]
        //IF (SaleLinePOS.Quantity < 0) THEN
        //  ERROR (DELETE_SINGLE_ERROR);

        if (SaleLinePOS.Quantity < 0) then begin
            if (SaleLinePOS."Return Sale Sales Ticket No." = '') then
                exit;

            // when there is a return sales ticket number, there should be a revoke request
            TicketRequestManager.POS_OnModifyQuantity(SaleLinePOS);
            exit;
        end;
        //+TM1.31 [306040]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014453, 'OnAfterFindSalesLinePrice', '', true, true)]
    local procedure OnAfterFindSalesLinePrice(SalePOS: Record "Sale POS"; var SaleLinePOS: Record "Sale Line POS")
    var
        TicketUnitPrice: Decimal;
        Token: Text[100];
    begin

        //-TM1.41 [353981]
        if (not IsTicketSalesLine(SaleLinePOS)) then
            exit;

        if ((SaleLinePOS."Eksp. Salgspris") or (SaleLinePOS."Custom Price")) then
            exit;

        if (GetRequestToken(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", Token)) then begin
            if (GetTicketUnitPrice(Token, SaleLinePOS."Unit Price", SaleLinePOS."Price Includes VAT", SaleLinePOS."VAT %", TicketUnitPrice)) then begin
                SaleLinePOS."Unit Price" := TicketUnitPrice;
            end;
        end;
        //+TM1.41 [353981]
    end;

    local procedure "--Workers"()
    begin
    end;

    local procedure NewTicketSales(SaleLinePOS: Record "Sale Line POS") ReturnCode: Integer
    var
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        TicketType: Record "TM Ticket Type";
        Item: Record Item;
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        TicketReservationRequest2: Record "TM Ticket Reservation Request";
        ResponseCode: Integer;
        ResponseMessage: Text;
        Token: Text[100];
        ExternalMemberNo: Code[20];
        TicketUnitPrice: Decimal;
        POSSession: Codeunit "POS Session";
        FrontEnd: Codeunit "POS Front End Management";
        SeatingUI: Codeunit "TM Seating UI";
    begin

        //-TM1.23 [284248]
        if (GetRequestToken(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", Token)) then begin
            if (TicketRequestManager.IsRequestStatusReservation(Token)) then
                exit(0);

            TicketRequestManager.DeleteReservationRequest(Token, true);
        end;
        //+TM1.23 [284248]

        ExternalMemberNo := SaleLinePOS."Serial No.";
        Token := TicketRequestManager.POS_CreateReservationRequest(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", SaleLinePOS."No.", SaleLinePOS."Variant Code", SaleLinePOS.Quantity, ExternalMemberNo);
        Commit;

        AssignSameSchedule(Token);
        AssignSameNotificationAddress(Token);

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("External Adm. Sch. Entry No.", '<=%1', 0);

        if (TicketReservationRequest.IsEmpty()) then begin
            ResponseCode := TicketRequestManager.IssueTicketFromReservationToken(Token, false, ResponseMessage);
            if (ResponseCode = 0) then begin
                Commit;

                AquireTicketParticipant(Token, ExternalMemberNo);

                // -TM1.41 [353981]
                if (GetTicketUnitPrice(Token, SaleLinePOS."Unit Price", SaleLinePOS."Price Includes VAT", SaleLinePOS."VAT %", TicketUnitPrice)) then begin
                    SaleLinePOS.Validate("Unit Price", TicketUnitPrice);
                    SaleLinePOS.UpdateAmounts(SaleLinePOS);
                    SaleLinePOS."Eksp. Salgspris" := false;
                    SaleLinePOS."Custom Price" := false;
                    SaleLinePOS.Modify();
                end;
                //+TM1.41 [353981]

                Commit;

        //-TM1.43 [357359]
        //    IF (USERID = 'TSA') THEN BEGIN
        //      IF (SaleLinePOS."No." = '32010') THEN BEGIN
        //        IF (POSSession.IsActiveSession (FrontEnd)) THEN
        //          SeatingUI.ShowUI (FrontEnd);
        //      END;
        //    END;
          if (POSSession.IsActiveSession (FrontEnd)) then
            SeatingUI.ShowSelectSeatUI (FrontEnd, Token);
        //+TM1.43 [357359]

                exit(1); // nothing to confirm;
            end;
        end;

        Commit;
        ResponseCode := -1;
        ResponseMessage := ABORTED;
        if (AquireTicketAdmissionSchedule(Token, SaleLinePOS, true)) then
            ResponseCode := TicketRequestManager.IssueTicketFromReservationToken(Token, false, ResponseMessage);

        if (ResponseCode = 0) then begin
            Commit;

            AquireTicketParticipant(Token, ExternalMemberNo);

            //-TM1.41 [353981]
            if (GetTicketUnitPrice(Token, SaleLinePOS."Unit Price", SaleLinePOS."Price Includes VAT", SaleLinePOS."VAT %", TicketUnitPrice)) then begin
                SaleLinePOS.Validate("Unit Price", TicketUnitPrice);
                SaleLinePOS.UpdateAmounts(SaleLinePOS);
                SaleLinePOS."Eksp. Salgspris" := false;
                SaleLinePOS."Custom Price" := false;
                SaleLinePOS.Modify();
            end;
            //+TM1.41 [353981]

            Commit;

        //-TM1.43 [357359]
        //    IF (USERID = 'TSA') THEN BEGIN
        //      IF (SaleLinePOS."No." = '32010') THEN BEGIN
        //        IF (POSSession.IsActiveSession (FrontEnd)) THEN
        //          SeatingUI.ShowUI (FrontEnd);
        //      END;
        //    END;
          if (POSSession.IsActiveSession (FrontEnd)) then
            SeatingUI.ShowSelectSeatUI (FrontEnd, Token);
        //+TM1.43 [357359]

            exit(1);
        end;

        SaleLinePOS.Delete();
        TicketRequestManager.DeleteReservationRequest(Token, true);
        Commit;
        Error(ResponseMessage);
    end;

    local procedure RegisterArrival(ExternalTicketNumber: Code[50]; AdmissionCode: Code[20])
    var
        TicketManagement: Codeunit "TM Ticket Management";
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        Admission: Record "TM Admission";
        ResponseMessage: Text;
    begin

        if (AdmissionCode <> '') then
            if (not Admission.Get(AdmissionCode)) then
                Error(StrSubstNo(INVALID_ADMISSION, 'Admission Code', AdmissionCode));

        //-TM1.23 [285079]
        TicketRequestManager.LockResources();
        //+TM1.23 [285079]

        if (TicketManagement.ValidateTicketForArrival(1, ExternalTicketNumber, AdmissionCode, -1, false, ResponseMessage) <> 0) then
            Error(ResponseMessage);
    end;

    local procedure ShowQuickStatistics(AdmissionCode: Code[20])
    var
        Admission: Record "TM Admission";
        QuickStatsPage: Page "TM Ticket Quick Statistics";
        AdmissionScheduleEntry: Record "TM Admission Schedule Entry";
    begin

        if (AdmissionCode <> '') then begin
            if (not Admission.Get(AdmissionCode)) then
                Error(StrSubstNo(INVALID_ADMISSION, 'Admission Code', AdmissionCode));
            AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        end;

        AdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', Today);
        QuickStatsPage.SetFilterRecord(AdmissionScheduleEntry);
        QuickStatsPage.RunModal();
    end;

    local procedure RevokeTicketReservation(POSSession: Codeunit "POS Session"; ExternalTicketNumber: Code[50])
    var
        TicketManagement: Codeunit "TM Ticket Management";
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        POSSaleLine: Codeunit "POS Sale Line";
        SaleLinePOS: Record "Sale Line POS";
        TicketAccessEntry: Record "TM Ticket Access Entry";
        Ticket: Record "TM Ticket";
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        AuditRoll: Record "Audit Roll";
        TicketAccessEntryNo: BigInteger;
        Token: Text;
        ResponseMessage: Text;
        UnitPrice: Decimal;
        RevokeQuantity: Integer;
    begin

        if (ExternalTicketNumber = '') then
            Error(ILLEGAL_VALUE, ExternalTicketNumber, TICKET_NUMBER);

        POSSession.GetSaleLine(POSSaleLine);

        TicketManagement.VerifyTicketReference(1, ExternalTicketNumber, '', TicketAccessEntryNo, true, ResponseMessage);
        TicketAccessEntry.Get(TicketAccessEntryNo);
        Ticket.Get(TicketAccessEntry."Ticket No.");


        //-TM1.36 [325345]
        //TicketReservationRequest.SETCURRENTKEY ("External Ticket Number");
        TicketReservationRequest.SetFilter("External Ticket Number", '=%1', Ticket."External Ticket No.");
        TicketReservationRequest.SetFilter("Revoke Ticket Request", '=%1', true);
        TicketReservationRequest.SetFilter("Request Status", '<>%1', TicketReservationRequest."Request Status"::CANCELED); // in progress
        if (TicketReservationRequest.FindFirst()) then
            Error(REVOKE_IN_PROGRESS, Ticket."External Ticket No.");
        TicketReservationRequest.Reset;
        //+TM1.36 [325345]


        TicketReservationRequest.Get(Ticket."Ticket Reservation Entry No.");

        SaleLinePOS.Type := SaleLinePOS.Type::Item;
        SaleLinePOS."No." := Ticket."Item No.";
        SaleLinePOS."Variant Code" := Ticket."Variant Code"; //-+TM1.38 [333705]
        SaleLinePOS.Quantity := -1; //-+NPR5.32.10 [250631] Only one ticket should be returned (request could have many tickets)

        //-TM1.41 [356057]
        SaleLinePOS."Return Sale Sales Ticket No." := Ticket."Sales Receipt No.";
        SaleLinePOS."Return Sale Line No." := Ticket."Line No.";
        //+TM1.41 [356057]

        POSSaleLine.InsertLine(SaleLinePOS);
        POSSaleLine.RefreshCurrent();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        UnitPrice := SaleLinePOS."Unit Price";

        //-TM1.39 [343585]
        // AuditRoll.SETFILTER ("Sales Ticket No.", '=%1', TicketReservationRequest."Receipt No.");
        // AuditRoll.SETFILTER ("Line No.", '=%1', TicketReservationRequest."Line No.");
        // IF (AuditRoll.FINDFIRST ()) THEN
        //  UnitPrice := AuditRoll."Unit Price";
        if (TicketReservationRequest."Receipt No." <> '') then begin
            AuditRoll.SetFilter("Sales Ticket No.", '=%1', TicketReservationRequest."Receipt No.");
            AuditRoll.SetFilter("Line No.", '=%1', TicketReservationRequest."Line No.");
            if (AuditRoll.FindFirst()) then
                UnitPrice := AuditRoll."Unit Price";
        end;
        //+TM1.39 [343585]

        //-TM1.38 [335653]
        //TicketRequestManager.POS_CreateRevokeRequest (Token, Ticket."No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", UnitPrice);
        TicketRequestManager.POS_CreateRevokeRequest(Token, Ticket."No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", UnitPrice, RevokeQuantity);

        POSSaleLine.SetQuantity(-1 * Abs(RevokeQuantity));
        //+TM1.38 [335653]

        POSSaleLine.SetUnitPrice(UnitPrice);
        //-NPR5.32 [269171]

        POSSession.RequestRefreshData();
    end;

    local procedure EditReservation(POSSession: Codeunit "POS Session"; ExternalTicketNumber: Code[50])
    var
        TicketManagement: Codeunit "TM Ticket Management";
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        POSSaleLine: Codeunit "POS Sale Line";
        SaleLinePOS: Record "Sale Line POS";
        TicketAccessEntry: Record "TM Ticket Access Entry";
        Ticket: Record "TM Ticket";
        TicketAccessEntryNo: BigInteger;
        Token: Text[100];
        ResponseMessage: Text;
        HaveSalesTicket: Boolean;
    begin

        if (ExternalTicketNumber <> '') then begin
            Ticket.SetFilter("External Ticket No.", '=%1', CopyStr(ExternalTicketNumber, 1, MaxStrLen(Ticket."External Ticket No.")));
            if (not Ticket.FindFirst()) then
                Error(ILLEGAL_VALUE, ExternalTicketNumber, TICKET_NUMBER);

            Ticket.TestField(Blocked, false);
            TicketRequestManager.GetTicketToken(Ticket."No.", Token);
            HaveSalesTicket := false;

        end else begin
            POSSession.GetSaleLine(POSSaleLine);
            POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
            GetRequestToken(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", Token);
            HaveSalesTicket := true;
        end;

        if (Token <> '') then
            AquireTicketAdmissionSchedule(Token, SaleLinePOS, HaveSalesTicket);
    end;

    local procedure ReconfirmReservation(POSSession: Codeunit "POS Session"; ExternalTicketNumber: Code[50])
    var
        TicketManagement: Codeunit "TM Ticket Management";
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        POSSaleLine: Codeunit "POS Sale Line";
        SaleLinePOS: Record "Sale Line POS";
        TicketAccessEntry: Record "TM Ticket Access Entry";
        Ticket: Record "TM Ticket";
        TicketAccessEntryNo: BigInteger;
        Token: Text[100];
        ResponseMessage: Text;
        ResponseCode: Integer;
        HaveSalesTicket: Boolean;
    begin

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if (GetRequestToken(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", Token)) then begin
            if (TicketRequestManager.ReadyToConfirm(Token)) then begin
                TicketRequestManager.DeleteReservationRequest(Token, false);
                ResponseCode := TicketRequestManager.IssueTicketFromReservationToken(Token, false, ResponseMessage);
                if (ResponseCode <> 0) then
                    Error(ResponseMessage);

                AquireTicketAdmissionSchedule(Token, SaleLinePOS, true);
            end;
        end;
    end;

    local procedure EditTicketholder(POSSession: Codeunit "POS Session"; ExternalTicketNumber: Code[50])
    var
        TicketManagement: Codeunit "TM Ticket Management";
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        POSSaleLine: Codeunit "POS Sale Line";
        SaleLinePOS: Record "Sale Line POS";
        TicketAccessEntry: Record "TM Ticket Access Entry";
        Ticket: Record "TM Ticket";
        TicketAccessEntryNo: BigInteger;
        Token: Text[100];
        ResponseMessage: Text;
    begin

        if (ExternalTicketNumber <> '') then begin
            Ticket.SetFilter("External Ticket No.", '=%1', CopyStr(ExternalTicketNumber, 1, MaxStrLen(Ticket."External Ticket No.")));
            if (not Ticket.FindFirst()) then
                Error(ILLEGAL_VALUE, ExternalTicketNumber, TICKET_NUMBER);

            Ticket.TestField(Blocked, false);
            TicketRequestManager.GetTicketToken(Ticket."No.", Token);

        end else begin
            POSSession.GetSaleLine(POSSaleLine);
            POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

            GetRequestToken(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", Token);

        end;

        if (Token <> '') then
            AquireTicketParticipant(Token, Ticket."External Member Card No.");
    end;

    local procedure GetGroupTicketQuantity(POSSession: Codeunit "POS Session"; JSON: Codeunit "POS JSON Management"; ExternalTicketNumber: Code[50]; AdmissionCode: Code[20]; FunctionId: Integer; var ShowQtyDialogOut: Boolean) TicketMaxQty: Integer
    var
        TicketAccessEntry: Record "TM Ticket Access Entry";
        Ticket: Record "TM Ticket";
        DetTicketAccessEntry: Record "TM Det. Ticket Access Entry";
        IsAdmitted: Boolean;
    begin

        Ticket.SetFilter("External Ticket No.", '=%1', CopyStr(ExternalTicketNumber, 1, MaxStrLen(Ticket."External Ticket No.")));
        if (not Ticket.FindFirst()) then
            Error(ILLEGAL_VALUE, ExternalTicketNumber, TICKET_NUMBER);

        Ticket.TestField(Blocked, false);

        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        if (AdmissionCode <> '') then
            TicketAccessEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        TicketAccessEntry.FindFirst();

        DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
        if (AdmissionCode = '') then begin
            DetTicketAccessEntry.Reset();
            DetTicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        end;

        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::ADMITTED);
        IsAdmitted := DetTicketAccessEntry.FindFirst();

        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::INITIAL_ENTRY);
        DetTicketAccessEntry.FindFirst();
        TicketMaxQty := DetTicketAccessEntry.Quantity;

        ShowQtyDialogOut := ((not IsAdmitted) and (TicketMaxQty > 1));
        if (FunctionId = 2) then
            ShowQtyDialogOut := false;

        JSON.SetContext('TicketQty', TicketAccessEntry.Quantity);
        JSON.SetContext('TicketMaxQty', TicketMaxQty);
        JSON.SetContext('ShowTicketQtyDialog', ShowQtyDialogOut);

        exit(TicketMaxQty);
    end;

    local procedure SetGroupTicketConfirmedQuantity(POSSession: Codeunit "POS Session"; JSON: Codeunit "POS JSON Management"; ExternalTicketNumber: Code[50]; AdmissionCode: Code[20])
    var
        TicketManagement: Codeunit "TM Ticket Management";
        Ticket: Record "TM Ticket";
        ResponseMessage: Text;
        NewTicketQty: Integer;
        ResultCode: Integer;
    begin

        Ticket.SetFilter("External Ticket No.", '=%1', CopyStr(ExternalTicketNumber, 1, MaxStrLen(Ticket."External Ticket No.")));
        if (not Ticket.FindFirst()) then
            Error(ILLEGAL_VALUE, ExternalTicketNumber, TICKET_NUMBER);

        Ticket.TestField(Blocked, false);

        NewTicketQty := GetInteger(JSON, 'ticketquantity');
        if (NewTicketQty = 0) then
            exit;

        ResultCode := TicketManagement.ChangeConfirmedTicketQuantity(false, Ticket."No.", AdmissionCode, NewTicketQty, ResponseMessage);

        JSON.SetScope('/', true);
        JSON.SetContext('Verbose', (ResultCode < 0));

        if (ResultCode < 0) then
            JSON.SetContext('VerboseMessage', ResponseMessage);
    end;

    local procedure PickupPreConfirmedTicket(POSSession: Codeunit "POS Session"; TicketReference: Code[30])
    var
        PickUpReservedTickets: Page "TM Pick-Up Reserved Tickets";
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        TicketReservationRequest2: Record "TM Ticket Reservation Request";
        PageAction: Action;
        POSSaleLine: Codeunit "POS Sale Line";
        SaleLinePos: Record "Sale Line POS";
        BarcodeLibrary: Codeunit "Barcode Library";
        Resolver: Integer;
        Ticket: Record "TM Ticket";
        TicketManagement: Codeunit "TM Ticket Management";
    begin

        Ticket.SetFilter("External Ticket No.", '=%1', CopyStr(TicketReference, 1, MaxStrLen(Ticket."External Ticket No.")));
        if (Ticket.FindFirst()) then begin
            TicketReservationRequest.SetFilter("Entry No.", '=%1', Ticket."Ticket Reservation Entry No.");
            TicketReservationRequest.FindFirst();
            TicketReservationRequest.Reset();
            TicketReservationRequest.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");

        end else begin
            TicketReservationRequest.SetFilter("External Member No.", '%1', CopyStr(TicketReference, 1, MaxStrLen(TicketReservationRequest."External Member No.")));
            if (TicketReference = '') then
                TicketReservationRequest.SetFilter("External Member No.", '<>%1', '');

            if (TicketReservationRequest.IsEmpty()) then
                TicketReservationRequest.SetFilter("External Member No.", '<>%1', '');

        end;

        PickUpReservedTickets.SetTableView(TicketReservationRequest);

        PickUpReservedTickets.LookupMode(true);
        PageAction := PickUpReservedTickets.RunModal();
        if (PageAction <> ACTION::LookupOK) then
            exit;

        PickUpReservedTickets.GetRecord(TicketReservationRequest);

        // Create a pos sale line to finish the reservation
        if (TicketReservationRequest."Payment Option" = TicketReservationRequest."Payment Option"::UNPAID) then begin

            // Create a POS sales line which needs to be paid.
            POSSession.GetSaleLine(POSSaleLine);
            POSSaleLine.GetNewSaleLine(SaleLinePos);

            TicketReservationRequest2.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
            TicketReservationRequest2.SetFilter("Ext. Line Reference No.", '=%1', TicketReservationRequest."Ext. Line Reference No.");

            TicketReservationRequest2.ModifyAll("Receipt No.", SaleLinePos."Sales Ticket No.");
            TicketReservationRequest2.ModifyAll("Line No.", SaleLinePos."Line No." + 10000);
            TicketReservationRequest2.ModifyAll("Request Status", TicketReservationRequest2."Request Status"::RESERVED);

            SaleLinePos.Type := SaleLinePos.Type::Item;

          //-TM1.43 [368043]
          // IF (NOT BarcodeLibrary.TranslateBarcodeToItemVariant (TicketReservationRequest."External Item Code", SaleLinePos."No.", SaleLinePos."Variant Code", Resolver, FALSE)) THEN
          //  ERROR (ILLEGAL_VALUE, TicketReservationRequest."External Item Code", 'Barcode or Item');
          SaleLinePos."No." := TicketReservationRequest."Item No.";
          SaleLinePos."Variant Code" := TicketReservationRequest."Variant Code";
          //+TM1.43 [368043]

            SaleLinePos.Quantity := TicketReservationRequest.Quantity;
            POSSaleLine.InsertLine(SaleLinePos);

            exit;
        end;

        // Print this reservation
        Ticket.Reset();
        TicketReservationRequest.Reset();
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
        TicketReservationRequest.FindFirst();

        TicketReservationRequest.TestField("Admission Created", true);
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
        Ticket.FindFirst();

        TicketManagement.PrintSingleTicket(Ticket);
    end;

    local procedure ConvertToMembership(POSSession: Codeunit "POS Session"; Context: JsonObject; FrontEnd: Codeunit "POS Front End Management"; ExternalTicketNumber: Code[50]; AdmissionCode: Code[20])
    var
        Ticket: Record "TM Ticket";
        TicketType: Record "TM Ticket Type";
        EanBoxEventHandler: Codeunit "Ean Box Event Handler";
        TicketManagement: Codeunit "TM Ticket Management";
        ReasonText: Text;
    begin

        //-TM1.28 [301222]
        Ticket.SetFilter("External Ticket No.", '=%1', CopyStr(ExternalTicketNumber, 1, MaxStrLen(Ticket."External Ticket No.")));
        if (not Ticket.FindFirst()) then
            Error(ILLEGAL_VALUE, ExternalTicketNumber, TICKET_NUMBER);

        Ticket.TestField(Blocked, false);
        TicketType.Get(Ticket."Ticket Type Code");
        TicketType.TestField("Membership Sales Item No.");

        TicketManagement.CheckIfConsumed(true, Ticket."No.", AdmissionCode, TicketType."Membership Sales Item No.", ReasonText);
        //-TM1.36 [319706]
        //POSActionTextEnter.ScanBarcode (Context, POSSession, FrontEnd, TicketType."Membership Sales Item No.");
        EanBoxEventHandler.InvokeEanBox(TicketType."Membership Sales Item No.", Context, POSSession, FrontEnd);
        //+TM1.36 [319706]

        TicketManagement.ConsumeItem(true, Ticket."No.", AdmissionCode, TicketType."Membership Sales Item No.", ReasonText);
    end;

    local procedure GetTicketUnitPrice(Token: Text[100]; OriginalUnitPrice: Decimal; PriceIncludesVAT: Boolean; VatPercentage: Decimal; var NewTicketPrice: Decimal): Boolean
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        AdmissionScheduleEntry: Record "TM Admission Schedule Entry";
        AdmissionScheduleLines: Record "TM Admission Schedule Lines";
        TotalRelativeChange: Decimal;
    begin

        //-TM1.41 [353981]
        NewTicketPrice := OriginalUnitPrice;
        TotalRelativeChange := 0;

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("External Adm. Sch. Entry No.", '>%1', 0);
        if (TicketReservationRequest.FindSet()) then begin

            // First get the lowest fixed price.
            repeat
                AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', TicketReservationRequest."External Adm. Sch. Entry No.");
                AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
                if (AdmissionScheduleEntry.FindLast()) then begin
                    with AdmissionScheduleLines do begin
                        Get(AdmissionScheduleEntry."Admission Code", AdmissionScheduleEntry."Schedule Code");
                        if ("Price Scope" in ["Price Scope"::API_POS_M2, "Price Scope"::POS_M2]) then begin
                            case "Pricing Option" of
                                "Pricing Option"::NA:
                                    ;
                                "Pricing Option"::FIXED:
                                    begin
                                        if (PriceIncludesVAT = "Amount Includes VAT") then begin
                                            if (Amount < NewTicketPrice) then NewTicketPrice := Amount;
                                        end else begin
                                            if (PriceIncludesVAT) and not ("Amount Includes VAT") then begin
                                                if (Amount * ((100 + VatPercentage) / 100) < NewTicketPrice) then NewTicketPrice := Amount * ((100 + VatPercentage) / 100);
                                            end else begin
                                                if (Amount / ((100 + VatPercentage) / 100) < NewTicketPrice) then NewTicketPrice := Amount / ((100 + VatPercentage) / 100);
                                            end;
                                        end;
                                    end;
                            end;
                        end;
                    end;
                end;
            until (TicketReservationRequest.Next() = 0);

            // Then apply relative price changes.
            TicketReservationRequest.FindSet();
            repeat
                AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', TicketReservationRequest."External Adm. Sch. Entry No.");
                AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
                if (AdmissionScheduleEntry.FindLast()) then begin
                    with AdmissionScheduleLines do begin
                        Get(AdmissionScheduleEntry."Admission Code", AdmissionScheduleEntry."Schedule Code");
                        if ("Price Scope" in ["Price Scope"::API_POS_M2, "Price Scope"::POS_M2]) then begin
                            case "Pricing Option" of
                                "Pricing Option"::RELATIVE:
                                    begin
                                        if (PriceIncludesVAT = "Amount Includes VAT") then begin
                                            TotalRelativeChange += Amount;
                                        end else begin
                                            if (PriceIncludesVAT) and not ("Amount Includes VAT") then begin
                                                TotalRelativeChange += Amount * ((100 + VatPercentage) / 100);
                                            end else begin
                                                TotalRelativeChange += Amount / ((100 + VatPercentage) / 100);
                                            end;
                                        end;
                                    end;
                                "Pricing Option"::PERCENT:
                                    begin
                                        if (PriceIncludesVAT = "Amount Includes VAT") then begin
                                            TotalRelativeChange += NewTicketPrice * Percentage / 100;
                                        end else begin
                                            if (PriceIncludesVAT) and not ("Amount Includes VAT") then begin
                                                TotalRelativeChange += NewTicketPrice * ((100 + VatPercentage) / 100) * Percentage;
                                            end else begin
                                                TotalRelativeChange += NewTicketPrice / ((100 + VatPercentage) / 100) * Percentage;
                                            end;
                                        end;
                                    end;
                            end;
                        end;
                    end;
                end;
            until (TicketReservationRequest.Next() = 0);

        end;

        NewTicketPrice += TotalRelativeChange;
        NewTicketPrice := Round(NewTicketPrice, 0.01);

        exit((OriginalUnitPrice <> NewTicketPrice) and (NewTicketPrice >= 0));
        //+TM1.41 [353981]
    end;

    local procedure "--Helpers"()
    begin
    end;

    local procedure AquireTicketAdmissionSchedule(Token: Text[100]; var SaleLinePOS: Record "Sale Line POS"; HaveSalesLine: Boolean) LookupOK: Boolean
    var
        TicketRetailManagement: Codeunit "TM Ticket Retail Management";
    begin

        //-TM1.21
        LookupOK := TicketRetailManagement.AquireTicketAdmissionSchedule(Token, SaleLinePOS, HaveSalesLine);
        exit(LookupOK);
        //+TM1.21
    end;

    local procedure AquireTicketParticipant(Token: Text[100]; ExternalMemberNo: Code[20]): Boolean
    var
        TicketNotifyParticipant: Codeunit "TM Ticket Notify Participant";
        MemberManagement: Codeunit "MM Membership Management";
        Member: Record "MM Member";
        SuggestMethod: Option NA,EMAIL,SMS;
        SuggestAddress: Text[100];
        TicketReservationRequest: Record "TM Ticket Reservation Request";
    begin

        if (Token = '') then
            exit(false);

        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindFirst()) then begin
            SuggestAddress := TicketReservationRequest."Notification Address";
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
                case Member."Notification Method" of
                    Member."Notification Method"::EMAIL:
                        begin
                            SuggestMethod := SuggestMethod::EMAIL;
                            SuggestAddress := Member."E-Mail Address";
                        end;
                end;
            end;
        end;

        exit(TicketNotifyParticipant.AquireTicketParticipant(Token, SuggestMethod, SuggestAddress));
    end;

    local procedure AssignSameSchedule(Token: Text[100])
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        TicketReservationRequest2: Record "TM Ticket Reservation Request";
    begin

        // assign same schedule to same admission objects
        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("External Adm. Sch. Entry No.", '<=%1', 0);
        if (TicketReservationRequest.FindSet()) then begin
            repeat
                TicketReservationRequest2.Reset();
                TicketReservationRequest2.SetFilter("Receipt No.", '=%1', TicketReservationRequest."Receipt No.");
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

    local procedure AssignSameNotificationAddress(Token: Text[100])
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        TicketReservationRequest2: Record "TM Ticket Reservation Request";
    begin

        // assign same notification address
        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Notification Address", '=%1', '');
        if (TicketReservationRequest.FindSet()) then begin
            repeat
                TicketReservationRequest2.Reset();
                TicketReservationRequest2.SetFilter("Receipt No.", '=%1', TicketReservationRequest."Receipt No.");
                TicketReservationRequest2.SetFilter("Admission Code", '=%1', TicketReservationRequest."Admission Code");
                TicketReservationRequest2.SetFilter("Notification Address", '<>%1', '');
                if (TicketReservationRequest2.FindLast()) then begin
                    TicketReservationRequest."Notification Method" := TicketReservationRequest2."Notification Method";
                    TicketReservationRequest."Notification Address" := TicketReservationRequest2."Notification Address";
                    TicketReservationRequest.Modify();
                end;
            until (TicketReservationRequest.Next() = 0);
        end;
    end;

    procedure GetRequestToken(ReceiptNo: Code[20]; LineNumber: Integer; var Token: Text[100]): Boolean
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
    begin
        Token := '';

        if (ReceiptNo = '') then
            exit(false);

        TicketReservationRequest.SetCurrentKey("Receipt No.");
        TicketReservationRequest.SetFilter("Receipt No.", '=%1', ReceiptNo);
        TicketReservationRequest.SetFilter("Line No.", '=%1', LineNumber);

        if (TicketReservationRequest.FindFirst()) then
            Token := TicketReservationRequest."Session Token ID";

        exit(Token <> '');
    end;

    local procedure GetInput(var JSON: Codeunit "POS JSON Management"; Path: Text): Text
    begin

        JSON.SetScope('/', true);
        if (not JSON.SetScope('$' + Path, false)) then
            exit('');

        exit(JSON.GetString('input', false));
    end;

    local procedure GetInteger(var JSON: Codeunit "POS JSON Management"; Path: Text): Integer
    begin

        JSON.SetScope('/', true);
        if (not JSON.SetScope('$' + Path, false)) then
            exit(0);

        exit(JSON.GetInteger('numpad', false));
    end;

    local procedure IsTicketSalesLine(SaleLinePOS: Record "Sale Line POS"): Boolean
    var
        TicketType: Record "TM Ticket Type";
        Item: Record Item;
    begin

        if (not Item.Get(SaleLinePOS."No.")) then
            exit(false);

        if (Item."Ticket Type" = '') then
            exit(false);

        if (not TicketType.Get(Item."Ticket Type")) then
            exit(false);

        exit(true);
    end;

    local procedure "--- Ean Box Event Handling"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "Ean Box Event")
    var
        TMTicket: Record "TM Ticket";
    begin
        //-TM1.36 [319706]
        if (not EanBoxEvent.Get(EventCodeExternalTicketNo())) then begin
            EanBoxEvent.Init;
            EanBoxEvent.Code := EventCodeExternalTicketNo;
            EanBoxEvent."Module Name" := 'Ticket Management';
            //-TM1.40 [350434]
            //EanBoxEvent.Description := TMTicket.FIELDCAPTION ("External Ticket No.");
            EanBoxEvent.Description := CopyStr(TMTicket.FieldCaption("External Ticket No."), 1, MaxStrLen(EanBoxEvent.Description));
            //+TM1.40 [350434]
            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;
        //+TM1.36 [319706]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "Ean Box Setup Mgt."; EanBoxEvent: Record "Ean Box Event")
    begin
        //-TM1.36 [319706]
        case EanBoxEvent.Code of
            EventCodeExternalTicketNo():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'DefaultTicketNumber', true, '');
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'Function', false, 'Register Arrival');
                end;
        end;
        //+TM1.36 [319706]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060107, 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeExternalTicketNo(EanBoxSetupEvent: Record "Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        TMTicket: Record "TM Ticket";
    begin
        //-TM1.36 [319706]
        if (EanBoxSetupEvent."Event Code" <> EventCodeExternalTicketNo()) then
            exit;

        if (StrLen(EanBoxValue) > MaxStrLen(TMTicket."External Ticket No.")) then
            exit;

        TMTicket.SetRange("External Ticket No.", EanBoxValue);
        if (TMTicket.FindFirst()) then
            InScope := true;
        //+TM1.36 [319706]
    end;

    local procedure EventCodeExternalTicketNo(): Code[20]
    begin
        //-TM1.36 [319706]
        exit('TICKET_ARRIVAL');
        //+TM1.36 [319706]
    end;

    local procedure "--- OnAfterInsertSaleLine Workflow"()
    begin
        //-TM1.34 [319425]
        //+TM1.34 [319425]
    end;

    [EventSubscriber(ObjectType::Table, 6150730, 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "POS Sales Workflow Step"; RunTrigger: Boolean)
    begin
        //-TM1.34 [319425]
        if Rec."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;

        case Rec."Subscriber Function" of
            'UpdateTicketOnSaleLineInsert':
                begin
                    Rec.Description := Text000;
                    Rec."Sequence No." := 20;
                end;
        end;
        //+TM1.34 [319425]
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        //-TM1.34 [319425]
        exit(CODEUNIT::"TM POS Action - Ticket Mgmt.");
        //+TM1.34 [319425]
    end;
}

