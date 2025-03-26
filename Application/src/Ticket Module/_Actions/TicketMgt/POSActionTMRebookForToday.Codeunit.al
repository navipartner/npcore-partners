codeunit 6248358 "NPR POSAction TMRebookForToday" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        _ActionDescription: Label 'Rebook tickets for Today';
        _TicketReferencePrompt: Label 'Ticket, Wallet or Reservation Number: ';
        _WindowTitle: Label 'Rebook Ticket for Today';

        _CreatedSalesLineIds: List of [Guid];



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
        WalletAssets: Query "NPR AttractionWalletAssets";
        ReferenceNumber: Text[50];
        AdditionalItemNo: Code[20];
        IsWallet: Boolean;
        RevokeTicketCount: Integer;
        NothingToRevoke: Label 'There is nothing to revoke for this reference number.';
    begin
        ReferenceNumber := CopyStr(Context.GetString('TicketReference'), 1, MaxStrLen(ReferenceNumber));
        AdditionalItemNo := CopyStr(Context.GetStringParameter('ItemNumber'), 1, MaxStrLen(AdditionalItemNo));

        if (ReferenceNumber = '') then
            exit;

        WalletAssets.SetFilter(WalletAssets.WalletReferenceNumber, '=%1', ReferenceNumber);
        if (WalletAssets.Open()) then
            while (WalletAssets.Read()) do begin
                IsWallet := true;
                if (WalletAssets.AssetType = WalletAssets.AssetType::TICKET) then
                    RevokeTicketCount += HandleTicketOrReservation(WalletAssets.AssetReferenceNumber, AdditionalItemNo, ReferenceNumber, WalletAssets.WalletEntryNo);
            end;

        if (not IsWallet) then
            RevokeTicketCount := HandleTicketOrReservation(ReferenceNumber, AdditionalItemNo, '', 0);

        if (RevokeTicketCount = 0) then
            error(NothingToRevoke);

    end;

    local procedure HandleTicketOrReservation(TicketReferenceNumber: Text[50]; AdditionalItemNo: Code[20]; WalletReferenceNumber: Text[50]; WalletEntryNo: Integer) RevokeTicketCount: Integer;
    var
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        UnitPrice, TotalPrice : Decimal;
        SaleLineCount: Integer;
    begin

        SaleLineCount := _CreatedSalesLineIds.Count();

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
                    RevokeTicketCount += 1;
                until (Ticket.Next() = 0);
            end;

            if (RevokeTicketCount > 0) then
                CreateTicketSalesAndGobbleOverflow(AdditionalItemNo, SaleLineCount, RevokeTicketCount, TotalPrice, WalletReferenceNumber, WalletEntryNo);
        end;

        Ticket.Reset();
        Ticket.SetCurrentKey("External Ticket No.");
        Ticket.SetFilter("External Ticket No.", '=%1', CopyStr(TicketReferenceNumber, 1, MaxStrLen(Ticket."External Ticket No.")));
        Ticket.SetFilter(Blocked, '=%1', false);
        if (Ticket.FindFirst()) then begin
            RevokeTicket(Ticket."External Ticket No.", UnitPrice);
            TotalPrice := -UnitPrice;
            RevokeTicketCount := 1;
            CreateTicketSalesAndGobbleOverflow(AdditionalItemNo, SaleLineCount, RevokeTicketCount, TotalPrice, WalletReferenceNumber, WalletEntryNo);
        end;

    end;

    local procedure CreateTicketSalesAndGobbleOverflow(AdditionalItemNo: Code[20]; SaleLineCount: Integer; RevokeTicketCount: Integer; TotalPrice: Decimal; WalletReferenceNumber: Text[50]; WalletEntryNo: Integer): Boolean;
    var
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
        // Ticket: Record "NPR TM Ticket";
        SaleHeaderPos: Record "NPR POS Sale";
        SaleLinePos: Record "NPR POS Sale Line";
        RequestHandler: Codeunit "NPR TM Ticket Request Manager";
        RetailHandler: Codeunit "NPR TM Ticket Retail Mgt.";
        Wallet: Codeunit "NPR AttractionWalletCreate";
        SalesLineIdToDelete, NewSalesLineId : Guid;
        ResponseMessage: Text;
        IssueNewTicketProblem: Label 'There was a problem issuing the new ticket. %1';
    begin

        SaleLinePos.GetBySystemId(_CreatedSalesLineIds.Get(SaleLineCount + 1));

        ReservationRequest.Reset();
        ReservationRequest.SetFilter("Receipt No.", '%1', SaleLinePos."Sales Ticket No.");
        ReservationRequest.SetFilter("Line No.", '%1', SaleLinePos."Line No.");
        ReservationRequest.FindFirst(); // One of the revoking request lines with todays admission schedule time description

        // Create sales for new tickets for today
        NewSalesLineId := CreateSalesLine(SaleLinePos."Line No." - 1, SaleLinePos."No.", SaleLinePos."Variant Code", ReservationRequest."Scheduled Time Description", RevokeTicketCount, 0);
        SaleLinePos.GetBySystemId(NewSalesLineId);

        if (WalletReferenceNumber <> '') then begin
            SaleHeaderPos.Get(SaleLinePos."Register No.", SaleLinePos."Sales Ticket No.");
            Wallet.RemoveIntermediateWalletsForLine(SaleHeaderPos.SystemId, SaleLinePos."Line No.", 0);
            Wallet.CreateIntermediateWalletForExistingWallet(SaleHeaderPos.SystemId, SaleLinePos.SystemId, SaleLinePos."Line No.", '', WalletReferenceNumber, WalletEntryNo);
        end;

        TotalPrice += SaleLinePos."Unit Price" * SaleLinePos.Quantity;

        if (RetailHandler.UseFrontEndScheduleUX()) then begin
            ReservationRequest.Reset();
            ReservationRequest.SetFilter("Receipt No.", '%1', SaleLinePos."Sales Ticket No.");
            ReservationRequest.SetFilter("Line No.", '%1', SaleLinePos."Line No.");
            ReservationRequest.FindFirst(); // Issuing Request line

            if (0 <> RequestHandler.IssueTicketFromReservationToken(ReservationRequest."Session Token ID", false, ResponseMessage)) then begin
                // Delete all the created sales lines
                foreach SalesLineIdToDelete in _CreatedSalesLineIds do begin
                    SaleLinePos.GetBySystemId(SalesLineIdToDelete);
                    SaleLinePos.Delete(true);
                end;
                Message(IssueNewTicketProblem, ResponseMessage);
                exit(false);
            end;
        end;

        // Create a sales line to soak up the overflow amount
        if (TotalPrice < 0) then begin
            SaleLinePos.GetBySystemId(_CreatedSalesLineIds.Get(_CreatedSalesLineIds.Count()));
            if (AdditionalItemNo <> '') then
                NewSalesLineId := CreateSalesLine(SaleLinePos."Line No." + 10000, AdditionalItemNo, '', '', RevokeTicketCount, Abs(TotalPrice) / RevokeTicketCount);
        end;

        exit(true);
    end;

    local procedure RevokeTicket(TicketReferenceNumber: Text[50]; var UnitPrice: Decimal)
    var
        PosRevoke: Codeunit "NPR POS Action - Ticket Mgt B.";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePos: Record "NPR POS Sale Line";
        RevokeSalesLineId: Guid;
    begin
        RevokeSalesLineId := PosRevoke.RevokeTicketReservation(POSSession, TicketReferenceNumber);
        _CreatedSalesLineIds.Add(RevokeSalesLineId);

        SaleLinePos.GetBySystemId(RevokeSalesLineId);
        UnitPrice := SaleLinePos."Unit Price";

        // Update the revoke request with admission schedule entries that are for today - the create new ticket process will pick up the existing schedule
        AdjustScheduleSelection(RevokeSalesLineId);
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

        _CreatedSalesLineIds.Add(SaleLinePos.SystemId);
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