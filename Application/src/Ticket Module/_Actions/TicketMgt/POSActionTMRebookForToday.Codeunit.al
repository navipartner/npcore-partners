codeunit 6248358 "NPR POSAction TMRebookForToday" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        _ActionDescription: Label 'Rebook tickets for Today';
        _TicketReferencePrompt: Label 'Ticket or Reservation Number: ';
        _WindowTitle: Label 'Rebook Ticket for Today';

        _RevokeSalesLineIds: List of [Guid];


    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ItemNumberCaption: Label 'Item Number';
        ItemNumberUsage: Label 'This item number will soak up the overflow amount when new tickets is cheaper than the revoked ticket.';
    begin
        WorkflowConfig.AddActionDescription(_ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddTextParameter('ItemNumber', '', ItemNumberCaption, ItemNumberUsage);
        WorkflowConfig.AddLabel('TicketReferencePrompt', _TicketReferencePrompt);
        WorkflowConfig.AddLabel('WindowTitle', _WindowTitle);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'RebookForToday':
                DoRebookTicket(Context);
        end;
    end;

    local procedure DoRebookTicket(Context: Codeunit "NPR POS JSON Helper")
    var
        TicketReferenceNumber: Text[50];
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        SaleLinePos: Record "NPR POS Sale Line";
        RequestHandler: Codeunit "NPR TM Ticket Request Manager";
        RetailHandler: Codeunit "NPR TM Ticket Retail Mgt.";
        UnitPrice, TotalPrice : Decimal;
        RevokeSalesLineId, NewSalesLineId : Guid;
        AdditionalItemNo: Code[20];
        ResponseMessage: Text;
        NothingToRevoke: Label 'There is nothing to revoke for this ticket or reservation number.';
        IssueNewTicketProblem: Label 'There was a problem issuing the new ticket. %1';
    begin
        TicketReferenceNumber := CopyStr(Context.GetString('TicketReference'), 1, MaxStrLen(TicketReferenceNumber));

        if (TicketReferenceNumber = '') then
            exit;

        ReservationRequest.Reset();
        ReservationRequest.SetCurrentKey("Session Token ID");
        ReservationRequest.SetFilter("Session Token ID", '=%1', CopyStr(TicketReferenceNumber, 1, MaxStrLen(ReservationRequest."Session Token ID")));
        ReservationRequest.SetFilter("Primary Request Line", '=%1', true);
        if (ReservationRequest.FindFirst()) then begin
            Ticket.Reset();
            Ticket.SetCurrentKey("Ticket Reservation Entry No.");
            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', ReservationRequest."Entry No.");
            Ticket.SetFilter(Blocked, '=%1', false);
            if (Ticket.FindSet()) then begin
                repeat
                    RevokeTicket(Ticket."External Ticket No.", UnitPrice);
                    TotalPrice -= UnitPrice;
                until (Ticket.Next() = 0);
            end;
        end else begin
            Ticket.Reset();
            Ticket.SetCurrentKey("External Ticket No.");
            Ticket.SetFilter("External Ticket No.", '=%1', CopyStr(TicketReferenceNumber, 1, MaxStrLen(Ticket."External Ticket No.")));
            Ticket.SetFilter(Blocked, '=%1', false);
            if (Ticket.FindFirst()) then begin
                RevokeTicket(Ticket."External Ticket No.", UnitPrice);
                TotalPrice -= UnitPrice;
            end;
        end;

        if (_RevokeSalesLineIds.Count() = 0) then
            Error(NothingToRevoke);

        SaleLinePos.GetBySystemId(_RevokeSalesLineIds.Get(1));
        ReservationRequest.Reset();
        ReservationRequest.SetFilter("Receipt No.", '%1', SaleLinePos."Sales Ticket No.");
        ReservationRequest.SetFilter("Line No.", '%1', SaleLinePos."Line No.");
        ReservationRequest.FindFirst(); // One of the revoking request lines with todays admission schedule time description

        // Create sales for new tickets for today
        NewSalesLineId := CreateSalesLine(SaleLinePos."Line No." - 1, SaleLinePos."No.", SaleLinePos."Variant Code", ReservationRequest."Scheduled Time Description", _RevokeSalesLineIds.Count(), 0);
        SaleLinePos.GetBySystemId(NewSalesLineId);
        TotalPrice += SaleLinePos."Unit Price" * SaleLinePos.Quantity;

        if (RetailHandler.UseFrontEndScheduleUX()) then begin
            ReservationRequest.Reset();
            ReservationRequest.SetFilter("Receipt No.", '%1', SaleLinePos."Sales Ticket No.");
            ReservationRequest.SetFilter("Line No.", '%1', SaleLinePos."Line No.");
            ReservationRequest.FindFirst(); // Issuing Request line

            if (0 <> RequestHandler.IssueTicketFromReservationToken(ReservationRequest."Session Token ID", false, ResponseMessage)) then begin
                SaleLinePos.Delete(true);
                foreach RevokeSalesLineId in _RevokeSalesLineIds do begin
                    SaleLinePos.GetBySystemId(RevokeSalesLineId);
                    SaleLinePos.Delete(true);
                end;

                Message(IssueNewTicketProblem, ResponseMessage);
                exit;
            end;
        end;

        // Create a sales line to soak up the overflow amount
        if (TotalPrice < 0) then begin
            AdditionalItemNo := CopyStr(Context.GetStringParameter('ItemNumber'), 1, MaxStrLen(AdditionalItemNo));
            SaleLinePos.GetBySystemId(_RevokeSalesLineIds.Get(_RevokeSalesLineIds.Count()));
            if (AdditionalItemNo <> '') then
                CreateSalesLine(SaleLinePos."Line No." + 10000, AdditionalItemNo, '', '', _RevokeSalesLineIds.Count(), Abs(TotalPrice) / _RevokeSalesLineIds.Count());
        end;

    end;


    local procedure RevokeTicket(TicketReferenceNumber: Text[50]; var UnitPrice: Decimal)
    var
        PosRevoke: Codeunit "NPR POS Action - Ticket Mgt B.";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePos: Record "NPR POS Sale Line";
        RevokeSalesLineId: Guid;
    begin
        RevokeSalesLineId := PosRevoke.RevokeTicketReservation(POSSession, TicketReferenceNumber);
        SaleLinePos.GetBySystemId(RevokeSalesLineId);
        UnitPrice := SaleLinePos."Unit Price";

        // Update the revoke request with admission schedule entries that are for today - create ticket will pick up the schedule
        AdjustScheduleSelection(RevokeSalesLineId);

        _RevokeSalesLineIds.Add(RevokeSalesLineId);
    end;

    local procedure CreateSalesLine(LineNo: Integer; ItemNo: Code[20]; VariantCode: Code[10]; Description2: Text[50]; Quantity: Decimal; UnitPrice: Decimal): Guid
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePos: Record "NPR POS Sale Line";
    begin
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(SaleLinePos);
        POSSaleLine.SetUsePresetLineNo(true);

        SaleLinePos."Line Type" := SaleLinePos."Line Type"::Item;
        SaleLinePos."Line No." := LineNo;
        SaleLinePos."No." := ItemNo;
        SaleLinePos."Variant Code" := VariantCode;
        SaleLinePos.Quantity := Abs(Quantity);
        SaleLinePos."Description 2" := Description2;

        if (UnitPrice <> 0) then
            SaleLinePos."Unit Price" := UnitPrice;

        POSSaleLine.InsertLine(SaleLinePos);
        POSSaleLine.RefreshCurrent();
        POSSaleLine.SetUsePresetLineNo(false);

        exit(SaleLinePos.SystemId);
    end;

    local procedure AdjustScheduleSelection(RevokeSalesLineId: Guid)
    var
        SaleLinePos: Record "NPR POS Sale Line";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        DateTimeLbl: Label '%1 - %2', Locked = true;
    begin
        if not SaleLinePos.GetBySystemId(RevokeSalesLineId) then
            exit;

        // Eventually the revoke request lines are cleaned up in OnDeletePOSSaleLineWorker when sales line is deleted
        TicketReservationRequest.SetFilter("Receipt No.", '%1', SaleLinePos."Sales Ticket No.");
        TicketReservationRequest.SetFilter("Line No.", '%1', SaleLinePos."Line No.");
        if (not TicketReservationRequest.FindSet()) then
            exit;

        repeat
            AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', TicketReservationRequest."Admission Code");
            AdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', Today());
            AdmissionScheduleEntry.SetFilter("Admission Start Time", '<=%1', Time());
            AdmissionScheduleEntry.SetFilter("Admission End Time", '>=%1', Time());
            AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
            AdmissionScheduleEntry.SetFilter("Admission Is", '=%1', AdmissionScheduleEntry."Admission Is"::OPEN);

            TicketReservationRequest."External Adm. Sch. Entry No." := 0;
            TicketReservationRequest."Scheduled Time Description" := '';
            if (AdmissionScheduleEntry.FindFirst()) then begin
                TicketReservationRequest."External Adm. Sch. Entry No." := AdmissionScheduleEntry."Entry No.";
                TicketReservationRequest."Scheduled Time Description" := StrSubstNo(DateTimeLbl, AdmissionScheduleEntry."Admission Start Date", AdmissionScheduleEntry."Admission Start Time");
            end;

            TicketReservationRequest.Modify();

        until (TicketReservationRequest.Next() = 0);

    end;


    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionTMRebookForToday.Codeunit.js### 
'const main=async({workflow:i,popup:c,captions:e})=>{const t={},n=await c.input({caption:e.TicketReferencePrompt,title:e.WindowTitle});n&&(t.TicketReference=n,await i.respond("RebookForToday",t))};'
        )
    end;

}