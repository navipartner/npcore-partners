codeunit 6060117 "TM Ticket Retail Management"
{
    // TM1.00/TSA/20151217  CASE 228982 NaviPartner Ticket Management
    // TM1.09/TSA/20160223  CASE 232952 Refactor or PUSH button implementation
    // TM1.09/TSA/20160301  CASE 235860 Sell event tickets in POS
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.15/TSA/20160512  CASE 240863 POS Quick Statistics
    // TM1.15/TSA/20160512  CASE 240864 Cancel Ticket
    // TM1.16/TSA/20160714  CASE 245004 Handling of ticket notification
    // TM1.17/TSA/20130913  CASE 252053 Update schedules when the "more info" dialog is displayed
    // TM1.17/TSA/20160913  CASE 251883 Added SMS as Notification Method
    // TM1.17/TSA/20160930  CASE 253951 Missing the * between qty and itemnumber in RevokeTicketReservation!, Menuline must be declared VAR in prepush functions
    // TM1.17/TSA/20160930  CASE 254019 GetRequestToken returns wrong token when receipt is blank,
    // TM1.17/TSA/20160930  CASE 254019 Make ticket functions work on no sales line - query for ticket number.
    // TM1.19/TSA/20170217  CASE 266372 Made function IssueTicket from inlined code
    // TM1.20/TSA/20170323  CASE 269171 POS_CreateRevokeRequest signature change
    // TM1.21/TSA/20170503  CASE 267611 Allowing quantity change in page AquireTicketAdmissionSchedule
    // NPR5.32.10/TSA/20170616  CASE 250631 Changed Signature of POS_CreateRevokeRequest
    // TM1.23/TSA /20170727 CASE 285079 Added LockResources() to RegisterArrival() and NewTicketSalesAdmissionCapture()
    // TM1.28/TSA /20170727 CASE 284248 PickupPreConfirmedTicket() and 'PICKUP_RESERVATION' switch
    // TM1.28/TSA /20180220 CASE 305707 Setting ticket item number to ticket request page
    // TM1.30/TSA /20180420 CASE 310947 When there is no sale line available, item is selected from ticket request instead
    // TM1.39/TSA /20181109 CASE 335653 Signature change on POS_CreateRevokeRequest
    // TM1.41/TSA /20190509 CASE 353981 Dynamic ticket schedule price
    // TM1.42/TSA /20190812 CASE 364739 Incorrect filter when receipt number is empty
    // TM1.45/TSA /20191203 CASE 380754 Waiting List schedule selection, changed signature on AquireTicketAdmissionSchedule()


    trigger OnRun()
    begin
    end;

    var
        ILLEGAL_VALUE: Label 'Value %1 is not a valid %2.';
        TICKET_NUMBER: Label 'Ticket Number';
        TICKET_REF: Label 'Ticket Reference';
        ABORTED: Label 'Aborted.';
        Marshaller: Codeunit "POS Event Marshaller";
        ERRORTITLE: Label 'Error.';
        INVALID_ADMISSION: Label 'Invalid parameter %1 specified in menu line %2, admission code %3 not found.';
        GlobalRequestToken: Text[100];
        SCHEDULE_ERROR: Label 'There was an error changing the reservation \\%1\\Do you want to try again?';
        WAITING_LIST: Label 'Waiting list entry created.';

    procedure TouchSalesPrePush(var SaleLinePOS: Record "Sale Line POS";var MenuLine: Record "Touch Screen - Menu Lines";var ValueToValidate: Code[50]) Result: Integer
    var
        ParameterAction: Code[250];
    begin

        ParameterAction := UpperCase (MenuLine.Parametre);
        if (StrPos (ParameterAction, '::') > 1) then
          ParameterAction := CopyStr (MenuLine.Parametre, 1, StrPos (ParameterAction, '::') -1);

        case UpperCase (ParameterAction) of
          'ARRIVAL' :             exit (RegisterArrival (SaleLinePOS, MenuLine, ValueToValidate));
          'ADMITTED_COUNT' :      exit (ShowQuickStatistics (SaleLinePOS, MenuLine, ValueToValidate));
          'REVOKE_RESERVATION' :  exit (RevokeTicketReservation (SaleLinePOS, MenuLine, ValueToValidate));
          'PICKUP_RESERVATION' :  exit (PickupPreConfirmedTicket (SaleLinePOS, MenuLine, ValueToValidate)); //-+#284248 [284248]

        end;

        exit (0);
    end;

    procedure TouchSalesPostPush(var SaleLinePOS: Record "Sale Line POS";MenuLine: Record "Touch Screen - Menu Lines";var PushAction: Text[250];var ValueToValidate: Code[50]) Result: Integer
    var
        Token: Text[100];
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        ResponseCode: Integer;
        ResponseMessage: Text;
        ExternalMemberNo: Code[20];
        Ticket: Record "TM Ticket";
        ExternalTicketNo: Text[50];
    begin
        MenuLine.Get (MenuLine."Menu No.", MenuLine.Type, MenuLine."No.");

        ExternalMemberNo := SaleLinePOS."Serial No.";

        case UpperCase (MenuLine.Parametre) of
          'EDIT_TICKETHOLDER' : begin
            if (GetRequestToken (SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", Token)) then begin

              //-TM1.17 [254019]
              if (TicketRequestManager.ReadyToConfirm (Token)) then begin
                TicketRequestManager.GetTokenTicket (Token, Ticket."No.");
              end else begin
                Token := '';
              end;
            end;

            if (Token = '') then begin
              ExternalTicketNo := GetTicketNoDialog (TICKET_NUMBER);
              if (ExternalTicketNo = '') then
                exit (0);
              Ticket.SetFilter ("External Ticket No.", '=%1', CopyStr(ExternalTicketNo, 1, MaxStrLen(Ticket."External Ticket No.")));
              if (not Ticket.FindFirst ()) then
                Error (ILLEGAL_VALUE, ExternalTicketNo, TICKET_NUMBER);
              Ticket.TestField (Blocked, false);
              TicketRequestManager.GetTicketToken (Ticket."No.", Token);
            end;

            if (Token <> '') then
              AquireTicketParticipant (Token, Ticket."External Member Card No.");
            //+TM1.17 [254019]

            exit (0);
          end;

          'EDIT_RESERVATION' : begin
            if (GetRequestToken (SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", Token)) then begin

              //-TM1.17 [254019]
              if (TicketRequestManager.ReadyToConfirm (Token)) then begin
                TicketRequestManager.GetTokenTicket (Token, Ticket."No.");
              end else begin
                Token := '';
              end;
            end;

            if (Token = '') then begin
              ExternalTicketNo := GetTicketNoDialog (TICKET_NUMBER);
              if (ExternalTicketNo = '') then
                exit (0);
              Ticket.SetFilter ("External Ticket No.", '=%1', CopyStr(ExternalTicketNo, 1, MaxStrLen(Ticket."External Ticket No.")));
              if (not Ticket.FindFirst ()) then
                Error (ILLEGAL_VALUE, ExternalTicketNo, TICKET_NUMBER);
              Ticket.TestField (Blocked, false);
              TicketRequestManager.GetTicketToken (Ticket."No.", Token);
            end;

            if (Token <> '') then
              AquireTicketAdmissionSchedule (Token, SaleLinePOS, true, ResponseMessage); //-+TM1.45 [380754]
            //-TM1.17 [254019]

            exit (0);
          end;

          'RECONFIRM_RESERVATION' : begin
            if (GetRequestToken (SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", Token)) then begin
              //-TM1.17 [254019]
              if (TicketRequestManager.ReadyToConfirm (Token)) then begin
                TicketRequestManager.DeleteReservationRequest (Token, false);
                ResponseCode := TicketRequestManager.IssueTicketFromReservationToken (Token, false, ResponseMessage);
                if (ResponseCode <> 0) then
                  Marshaller.DisplayError (MenuLine.Parametre, ResponseMessage, true);

                AquireTicketAdmissionSchedule (Token, SaleLinePOS, true, ResponseMessage); //-+TM1.45 [380754]
              end;
            end;
            exit (0);
          end;

          'REVOKE_RESERVATION' : begin
            if (not TicketRequestManager.SetReceiptForToken (SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", GlobalRequestToken)) then ;
          end;

          //-#284248 [284248]
          'PICKUP_RESERVATION' : begin
            //IF (NOT TicketRequestManager.SetReceiptForToken (SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", GlobalRequestToken)) THEN ;
          end;
          //+#284248 [284248]

        end;

        exit (0);
    end;

    local procedure "--"()
    begin
    end;

    local procedure RegisterArrival(var SaleLinePOS: Record "Sale Line POS";MenuLine: Record "Touch Screen - Menu Lines";var ValueToValidate: Code[50]): Integer
    var
        TicketManagement: Codeunit "TM Ticket Management";
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        ExternalTicketNo: Code[50];
        ResponseMessage: Text;
        AdmissionCode: Code[20];
        Admission: Record "TM Admission";
        ParameterAction: Code[250];
        ParameterParameter: Code[250];
    begin
        ParameterAction := UpperCase (MenuLine.Parametre);
        ExternalTicketNo := GetTicketNoDialog (TICKET_NUMBER);

        if (StrPos (ParameterAction, '::') > 1) then begin
          ParameterAction := CopyStr (MenuLine.Parametre, 1, StrPos (ParameterAction, '::') -1);
          if ((StrLen(MenuLine.Parametre) >= StrPos (MenuLine.Parametre, '::')+2)) then
            ParameterParameter := CopyStr (MenuLine.Parametre, StrPos (MenuLine.Parametre, '::')+2);
        end;

        AdmissionCode := '';
        if (ParameterParameter <> '') then begin
          AdmissionCode := ParameterParameter;
          if (not Admission.Get (AdmissionCode)) then
            Marshaller.DisplayError (MenuLine.Parametre, StrSubstNo (INVALID_ADMISSION, MenuLine.Parametre, MenuLine."No.", AdmissionCode), true);
        end;

        //-TM1.23 [285079]
        TicketRequestManager.LockResources ();
        //+TM1.23 [285079]

        if (TicketManagement.ValidateTicketForArrival (1, ExternalTicketNo, AdmissionCode, -1, false, ResponseMessage) <> 0) then
          Marshaller.DisplayError (MenuLine.Parametre, ResponseMessage, true);

        exit (0);
    end;

    local procedure ShowQuickStatistics(var SaleLinePOS: Record "Sale Line POS";MenuLine: Record "Touch Screen - Menu Lines";var ValueToValidate: Code[50]): Integer
    var
        TicketManagement: Codeunit "TM Ticket Management";
        AdmissionCode: Code[20];
        Admission: Record "TM Admission";
        ParameterAction: Code[250];
        ParameterParameter: Code[250];
        QuickStatsPage: Page "TM Ticket Quick Statistics";
        AdmissionScheduleEntry: Record "TM Admission Schedule Entry";
    begin
        ParameterAction := UpperCase (MenuLine.Parametre);

        if (StrPos (ParameterAction, '::') > 1) then begin
          ParameterAction := CopyStr (MenuLine.Parametre, 1, StrPos (ParameterAction, '::') -1);
          if ((StrLen(MenuLine.Parametre) >= StrPos (MenuLine.Parametre, '::')+2)) then
            ParameterParameter := CopyStr (MenuLine.Parametre, StrPos (MenuLine.Parametre, '::')+2);
        end;

        AdmissionCode := '';
        if (ParameterParameter <> '') then begin
          AdmissionCode := ParameterParameter;
          if (not Admission.Get (AdmissionCode)) then
            Marshaller.DisplayError (MenuLine.Parametre, StrSubstNo (INVALID_ADMISSION, MenuLine.Parametre, MenuLine."No.", AdmissionCode), true);
          AdmissionScheduleEntry.SetFilter ("Admission Code", '=%1', AdmissionCode);
        end;
        AdmissionScheduleEntry.SetFilter ("Admission Start Date", '=%1', Today);
        QuickStatsPage.SetFilterRecord (AdmissionScheduleEntry);
        QuickStatsPage.RunModal();

        exit (0);
    end;

    local procedure RevokeTicketReservation(var SaleLinePOS: Record "Sale Line POS";var MenuLine: Record "Touch Screen - Menu Lines";var ValueToValidate: Code[50]): Integer
    var
        TicketAccessEntry: Record "TM Ticket Access Entry";
        TicketManagement: Codeunit "TM Ticket Management";
        TicketRequestManagement: Codeunit "TM Ticket Request Manager";
        ExternalTicketNo: Code[50];
        ResponseMessage: Text;
        TicketAccessEntryNo: BigInteger;
        Ticket: Record "TM Ticket";
        UnitPriceInclVat: Decimal;
        RevokeQuantity: Integer;
    begin
        ExternalTicketNo := GetTicketNoDialog (TICKET_NUMBER);

        TicketManagement.VerifyTicketReference (1, ExternalTicketNo, '', TicketAccessEntryNo, true, ResponseMessage);
        TicketAccessEntry.Get (TicketAccessEntryNo);
        Ticket.Get (TicketAccessEntry."Ticket No.");

        //-NPR5.32.10 [250631]
        //-TM1.20 [269171]
        //GlobalRequestToken := TicketRequestManagement.POS_CreateRevokeRequest (Ticket."No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.");
        //GlobalRequestToken := TicketRequestManagement.POS_CreateRevokeRequest (Ticket."No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", UnitPriceInclVat);

        UnitPriceInclVat := 0;
        GlobalRequestToken := '';

        //-#335653 [335653]
        //TicketRequestManagement.POS_CreateRevokeRequest (GlobalRequestToken, Ticket."No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", UnitPriceInclVat);
        TicketRequestManagement.POS_CreateRevokeRequest (GlobalRequestToken, Ticket."No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", UnitPriceInclVat, RevokeQuantity);
        //+#335653 [335653]

        //-TM1.20 [269171]
        //-NPR5.32.10 [250631]

        ValueToValidate := StrSubstNo ('%1*%2', Abs(TicketAccessEntry.Quantity) * -1, TicketRequestManagement.GetExternalNo (Ticket."Item No.", Ticket."Variant Code"));
        MenuLine.Parametre := ''; // must be numeric for EnterPush to work, as it evaluates to decimal and means default Qty
        exit (1); // EnterPush - Process ValueToValidate
    end;

    local procedure PickupPreConfirmedTicket(var SaleLinePOS: Record "Sale Line POS";var MenuLine: Record "Touch Screen - Menu Lines";var ValueToValidate: Code[50]): Integer
    var
        PickUpReservedTickets: Page "TM Pick-Up Reserved Tickets";
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        TicketReservationRequest2: Record "TM Ticket Reservation Request";
        PageAction: Action;
        BarcodeLibrary: Codeunit "Barcode Library";
        Resolver: Integer;
        Ticket: Record "TM Ticket";
        TicketManagement: Codeunit "TM Ticket Management";
        TicketReference: Code[20];
    begin

        //-#284248 [284248]
        MenuLine.Parametre := ''; // must be numeric for EnterPush to work, as it evaluates to decimal and means default Qty

        TicketReference := GetTicketNoDialog (TICKET_REF);

        Ticket.SetFilter ("External Ticket No.", '=%1', CopyStr (TicketReference, 1, MaxStrLen (Ticket."External Ticket No.")));
        if (Ticket.FindFirst ()) then begin
          TicketReservationRequest.SetFilter ("Entry No.", '=%1', Ticket."Ticket Reservation Entry No.");
          TicketReservationRequest.FindFirst ();
          TicketReservationRequest.Reset ();
          TicketReservationRequest.SetFilter ("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");

        end else begin
          TicketReservationRequest.SetFilter ("External Member No.", '%1', CopyStr (TicketReference, 1, MaxStrLen(TicketReservationRequest."External Member No.")));
          if (TicketReference = '') then
            TicketReservationRequest.SetFilter ("External Member No.", '<>%1', '');

          if (TicketReservationRequest.IsEmpty ()) then
            TicketReservationRequest.SetFilter ("External Member No.", '<>%1', '');
        end;

        PickUpReservedTickets.SetTableView (TicketReservationRequest);

        PickUpReservedTickets.LookupMode (true);
        PageAction := PickUpReservedTickets.RunModal ();
        if (PageAction <> ACTION::LookupOK) then
          exit;

        PickUpReservedTickets.GetRecord (TicketReservationRequest);

        // Create a pos sale line to finish the reservation
        if (TicketReservationRequest."Payment Option" = TicketReservationRequest."Payment Option"::UNPAID) then begin

          // Create a POS sales line which needs to be paid.
          TicketReservationRequest2.SetFilter ("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
          TicketReservationRequest2.SetFilter ("Ext. Line Reference No.", '=%1', TicketReservationRequest."Ext. Line Reference No.");

          TicketReservationRequest2.ModifyAll ("Request Status", TicketReservationRequest2."Request Status"::RESERVED);

          if (not BarcodeLibrary.TranslateBarcodeToItemVariant (TicketReservationRequest."External Item Code", SaleLinePOS."No.", SaleLinePOS."Variant Code", Resolver, false)) then
            Error (ILLEGAL_VALUE, TicketReservationRequest."External Item Code", 'Barcode or Item');

          // Manipulate the POS worker code to me what I want
          ValueToValidate := SaleLinePOS."No.";
          MenuLine.Parametre := Format (TicketReservationRequest.Quantity);
          GlobalRequestToken := TicketReservationRequest."Session Token ID"; // for postpush to set receipt no and line no on created line
          SaleLinePOS."Description 2" := GlobalRequestToken;
          exit (1); // EnterPush - Process ValueToValidate

        end;

        // Print this reservation
        Ticket.Reset ();
        TicketReservationRequest.Reset ();
        TicketReservationRequest.SetFilter ("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
        TicketReservationRequest.FindFirst ();

        TicketReservationRequest.TestField ("Admission Created", true);
        Ticket.SetFilter ("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
        Ticket.FindFirst ();

        TicketManagement.PrintSingleTicket (Ticket);

        exit (0);
        //+#284248 [284248]
    end;

    local procedure "---"()
    begin
    end;

    procedure GetErrorMessage(MessageNumber: Integer) MessageText: Text
    begin

        case MessageNumber of
          -1200 : MessageText := ABORTED;
          else
            MessageText := StrSubstNo ('Error number %1 not defined',MessageNumber);
        end;
    end;

    local procedure GetTicketNoDialog(DialogCaption: Text) ScannedValue: Text
    var
        Ticket: Record "TM Ticket";
    begin

        ScannedValue := Marshaller.SearchBox (DialogCaption, '', MaxStrLen (Ticket."External Ticket No."));
        if (ScannedValue = '<CANCEL>') then
          Error ('');

        if (StrLen (ScannedValue) > MaxStrLen(Ticket."External Ticket No.")) then
          Error (ILLEGAL_VALUE, ScannedValue, DialogCaption);

        exit (ScannedValue);
    end;

    procedure NewTicketSalesAdmissionCapture(SaleLinePOS: Record "Sale Line POS") ReturnCode: Integer
    var
        TicketType: Record "TM Ticket Type";
        Item: Record Item;
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        Token: Text[100];
        ResponseCode: Integer;
        ResponseMessage: Text;
        ExternalMemberNo: Code[20];
    begin
        //-NPR5.32.10
        if (not Item.Get (SaleLinePOS."No.")) then
          exit (0);

        if (Item."Ticket Type" = '') then
          exit (0);

        if (not TicketType.Get (Item."Ticket Type")) then
          exit (0);

        //-TM1.23 [285079]
        TicketRequestManager.LockResources();
        //+TM1.23 [285079]

        TicketRequestManager.ExpireReservationRequests ();

        if (SaleLinePOS.Quantity < 0) then
          exit;

        //-#284248 [284248]
        // IF (GetRequestToken (SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", Token)) THEN
        //  TicketRequestManager.DeleteReservationRequest (Token, TRUE);
        if (GetRequestToken (SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", Token)) then begin
          if (TicketRequestManager.IsRequestStatusReservation (Token)) then
            exit (0);

          TicketRequestManager.DeleteReservationRequest (Token, true);
        end;
        //+#284248 [284248]

        //ExternalMemberNo := SaleLinePOS."Serial No.";
        ExternalMemberNo := '';
        Token := TicketRequestManager.POS_CreateReservationRequest (SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", SaleLinePOS."No.", SaleLinePOS."Variant Code", SaleLinePOS.Quantity, ExternalMemberNo);
        Commit;

        //-TM1.19 [266372]

        if (IssueTicket (Token, ExternalMemberNo, false, ResponseCode, ResponseMessage, SaleLinePOS, true)) then
          exit (1);
        //+TM1.19 [266372]

        SaleLinePOS.Delete ();
        TicketRequestManager.DeleteReservationRequest (Token, true);
        Commit;

        Marshaller.DisplayError ('', ResponseMessage, true);

        exit (0);
    end;

    procedure IssueTicket(Token: Text[100];ExternalMemberNo: Code[20];FailWithError: Boolean;ResponseCode: Integer;ResponseMessage: Text;SaleLinePOS: Record "Sale Line POS";UpdateSalesLine: Boolean) Success: Boolean
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
    begin

        //-TM1.19 [266372]
        AssignSameSchedule (Token);
        AssignSameNotificationAddress (Token);

        TicketReservationRequest.Reset ();
        TicketReservationRequest.SetCurrentKey ("Session Token ID");
        TicketReservationRequest.SetFilter ("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter ("External Adm. Sch. Entry No.", '<=%1', 0);
        if (TicketReservationRequest.IsEmpty ()) then begin
          ResponseCode := TicketRequestManager.IssueTicketFromReservationToken (Token, false, ResponseMessage);
          if (ResponseCode = 0) then begin

            Commit;
            AquireTicketParticipant (Token, ExternalMemberNo);

            Commit;
            exit (true); // nothing to confirm;
          end;
        end;

        Commit;
        ResponseCode := -1;
        ResponseMessage := ABORTED;
        if (AquireTicketAdmissionSchedule (Token, SaleLinePOS, UpdateSalesLine, ResponseMessage)) then begin //-+TM1.45 [380754]
          ResponseMessage := '';
          ResponseCode := TicketRequestManager.IssueTicketFromReservationToken (Token, false, ResponseMessage);
        end;

        if (ResponseCode = 0) then begin

          Commit;
          AquireTicketParticipant (Token, ExternalMemberNo);

          Commit;
          exit (true);
        end;

        exit (false);
        //-TM1.19 [266372]
    end;

    procedure AquireTicketAdmissionSchedule(Token: Text[100];var SaleLinePOS: Record "Sale Line POS";HaveSalesLine: Boolean;var ResponseMessage: Text) LookupOK: Boolean
    var
        PageAction: Action;
        Item: Record Item;
        i: Integer;
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        DisplayTicketeservationRequest: Page "TM Ticket Make Reservation";
        TicketManagement: Codeunit "TM Ticket Management";
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        NewQuantity: Integer;
        ResolvedByTable: Integer;
        ResultCode: Integer;
    begin

        TicketReservationRequest.Reset ();
        TicketReservationRequest.FilterGroup(2);
        TicketReservationRequest.Reset ();
        TicketReservationRequest.SetCurrentKey ("Session Token ID");
        TicketReservationRequest.SetFilter ("Session Token ID", '=%1', Token);
        TicketReservationRequest.FilterGroup(0);

        TicketReservationRequest.FindSet ();
        repeat
          if (TicketReservationRequest."Admission Code" <> '') then
            TicketManagement.GetCurrentScheduleEntry (TicketReservationRequest."Admission Code", true);
        until (TicketReservationRequest.Next() = 0);
        Commit;

        //-#310947 [310947]
        if (not HaveSalesLine) then begin
          // Get the ticket item from token line instead
          if (TicketReservationRequest.FindFirst ()) then
            TicketRequestManager.TranslateBarcodeToItemVariant (TicketReservationRequest."External Item Code", SaleLinePOS."No.", SaleLinePOS."Variant Code", ResolvedByTable);
        end;
        //+#310947 [310947]

        repeat
          Clear (DisplayTicketeservationRequest);
          DisplayTicketeservationRequest.LoadTicketRequest (Token);
          DisplayTicketeservationRequest.SetTicketItem (SaleLinePOS."No.", SaleLinePOS."Variant Code");
          DisplayTicketeservationRequest.AllowQuantityChange (HaveSalesLine);
          DisplayTicketeservationRequest.LookupMode(true);
          DisplayTicketeservationRequest.Editable(true);

          //-TM1.45 [380754] refactored
          if (ResultCode <> 0) then
            if (not Confirm (SCHEDULE_ERROR, true, ResponseMessage)) then
              exit (false);

          PageAction := DisplayTicketeservationRequest.RunModal ();
          if (PageAction <> ACTION::LookupOK) then begin
            ResponseMessage := ABORTED;
            exit (false);
          end;

          ResultCode := DisplayTicketeservationRequest.FinalizeReservationRequest (false, ResponseMessage);
          if (ResultCode = 11) then begin
            ResponseMessage := ''; // Silent error downstream
            exit (false);
          end;
          //+TM1.45 [380754]

        until (ResultCode = 0);

        if (HaveSalesLine) then begin
          //-TM1.41 [353981]
          //  IF (DisplayTicketeservationRequest.GetChangedTicketQuantity (NewQuantity)) THEN BEGIN
          //    SaleLinePOS.VALIDATE (Quantity, NewQuantity);
          //    SaleLinePOS.MODIFY ();
          //    COMMIT;
          //  END;
          DisplayTicketeservationRequest.GetChangedTicketQuantity (NewQuantity);
          SaleLinePOS."Unit Price" := SaleLinePOS.FindItemSalesPrice ();
          SaleLinePOS.Validate (Quantity, NewQuantity);
          SaleLinePOS.Modify ();
          Commit;
          //+TM1.41 [353981]
        end;

        exit (true);
    end;

    procedure AquireTicketParticipant(Token: Text[100];ExternalMemberNo: Code[20]): Boolean
    var
        TicketNotifyParticipant: Codeunit "TM Ticket Notify Participant";
        MemberManagement: Codeunit "MM Membership Management";
        Member: Record "MM Member";
        SuggestMethod: Option NA,EMAIL,SMS;
        SuggestAddress: Text[100];
        TicketReservationRequest: Record "TM Ticket Reservation Request";
    begin

        if (Token = '') then
          exit (false);

        TicketReservationRequest.SetFilter ("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindFirst()) then begin
          SuggestAddress := TicketReservationRequest."Notification Address";
          case TicketReservationRequest."Notification Method" of
            TicketReservationRequest."Notification Method"::EMAIL : SuggestMethod := SuggestMethod::EMAIL;
            TicketReservationRequest."Notification Method"::SMS   : SuggestMethod := SuggestMethod::SMS;
            else SuggestMethod := SuggestMethod::NA;
          end;
        end;

        if (ExternalMemberNo <> '') then begin
          if (Member.Get (MemberManagement.GetMemberFromExtMemberNo(ExternalMemberNo))) then begin
            case Member."Notification Method" of
              Member."Notification Method"::EMAIL :
                begin
                  SuggestMethod := SuggestMethod::EMAIL;
                  SuggestAddress := Member."E-Mail Address";
                end;
            end;
          end;
        end;

        exit (TicketNotifyParticipant.AquireTicketParticipant (Token, SuggestMethod, SuggestAddress));
    end;

    procedure AssignSameSchedule(Token: Text[100])
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        TicketReservationRequest2: Record "TM Ticket Reservation Request";
    begin

        // assign same schedule to same admission objects
        TicketReservationRequest.Reset ();
        TicketReservationRequest.SetCurrentKey ("Session Token ID");
        TicketReservationRequest.SetFilter ("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter ("External Adm. Sch. Entry No.", '<=%1', 0);
        if (TicketReservationRequest.FindSet ()) then begin
          repeat
            TicketReservationRequest2.Reset ();
            //-TM1.42 [364739]
            // TicketReservationRequest2.SETFILTER ("Receipt No.", '=%1', TicketReservationRequest."Receipt No.");
            if (TicketReservationRequest."Receipt No." <> '') then begin
              TicketReservationRequest2.SetFilter ("Receipt No.", '=%1', TicketReservationRequest."Receipt No.");
            end else begin
              TicketReservationRequest2.SetFilter ("Session Token ID", '=%1', Token);
            end;
            //+TM1.42 [364739]
            TicketReservationRequest2.SetFilter ("Admission Code", '=%1', TicketReservationRequest."Admission Code");
            TicketReservationRequest2.SetFilter ("External Adm. Sch. Entry No.", '>%1', 0);
            if (TicketReservationRequest2.FindLast ()) then begin
              TicketReservationRequest."External Adm. Sch. Entry No." := TicketReservationRequest2."External Adm. Sch. Entry No.";
              TicketReservationRequest."Scheduled Time Description" := TicketReservationRequest2."Scheduled Time Description";
              TicketReservationRequest.Modify ();
            end;
          until (TicketReservationRequest.Next () = 0);
        end;
    end;

    procedure AssignSameNotificationAddress(Token: Text[100])
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        TicketReservationRequest2: Record "TM Ticket Reservation Request";
    begin

        // assign same notification address
        TicketReservationRequest.Reset ();
        TicketReservationRequest.SetCurrentKey ("Session Token ID");
        TicketReservationRequest.SetFilter ("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter ("Notification Address", '=%1', '');
        if (TicketReservationRequest.FindSet ()) then begin
          repeat
            TicketReservationRequest2.Reset ();
            //-TM1.42 [364739]
            // TicketReservationRequest2.SETFILTER ("Receipt No.", '=%1', TicketReservationRequest."Receipt No.");
            if (TicketReservationRequest."Receipt No." <> '') then begin
              TicketReservationRequest2.SetFilter ("Receipt No.", '=%1', TicketReservationRequest."Receipt No.");
            end else begin
              TicketReservationRequest2.SetFilter ("Session Token ID", '=%1', Token);
            end;
            //+TM1.42 [364739]
            TicketReservationRequest2.SetFilter ("Admission Code", '=%1', TicketReservationRequest."Admission Code");
            TicketReservationRequest2.SetFilter ("Notification Address", '<>%1', '');
            if (TicketReservationRequest2.FindLast ()) then begin
              TicketReservationRequest."Notification Method" := TicketReservationRequest2."Notification Method";
              TicketReservationRequest."Notification Address" := TicketReservationRequest2."Notification Address";
              TicketReservationRequest.Modify ();
            end;
          until (TicketReservationRequest.Next () = 0);
        end;
    end;

    procedure GetRequestToken(ReceiptNo: Code[20];LineNumber: Integer;var Token: Text[100]): Boolean
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
    begin
        Token := '';

        //-TM1.17 [254019]
        if (ReceiptNo = '') then
          exit (false);
        //-TM1.17 [254019]

        TicketReservationRequest.SetCurrentKey ("Receipt No.");
        TicketReservationRequest.SetFilter ("Receipt No.", '=%1', ReceiptNo);
        TicketReservationRequest.SetFilter ("Line No.", '=%1', LineNumber);

        if (TicketReservationRequest.FindFirst ()) then
          Token := TicketReservationRequest."Session Token ID";

        //IF (CONFIRM ('%1 \\ %2', TRUE, Token, TicketReservationRequest)) THEN ;
        exit (Token <> '');
    end;
}

