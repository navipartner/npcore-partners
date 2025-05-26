codeunit 6248358 "NPR POSAction TMRebookForToday" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        _ActionDescription: Label 'Rebook tickets for Today';
        _TicketReferencePrompt: Label 'Ticket, Wallet or Reservation Number: ';
        _WindowTitle: Label 'Rebook Ticket for Today';

        _CreatedSalesLineIds: List of [Guid];

        _AdmitMode_Name: Label 'AdmitMode', locked = true;
        _TicketReference_Name: Label 'TicketReference', locked = true;
        _ItemNumber_Name: Label 'ItemNumber', locked = true;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ItemNumberCaption: Label 'Item Number';
        ItemNumberUsage: Label 'This item number will soak up the overflow amount when new tickets is cheaper than the revoked ticket.';

        AdmitMode_Caption: Label 'Admit Mode';
        AdmitMode_Desc: Label 'Determines how end of sale admit mode will be handled (Sale=Normal, Scan=As scanned by POS).';
        AdmitMode_OptionString: Label 'SALE,SCAN,NO_ADMIT_ON_EOS';
        AdmitMode_OptionCaption: Label 'Sale,Scan,No Admit On End Of Sale';
    begin
        WorkflowConfig.AddActionDescription(_ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddTextParameter(_ItemNumber_Name, '', ItemNumberCaption, ItemNumberUsage);
        WorkflowConfig.AddLabel('TicketReferencePrompt', _TicketReferencePrompt);
        WorkflowConfig.AddLabel('WindowTitle', _WindowTitle);
        WorkflowConfig.AddOptionParameter(_AdmitMode_Name,
                                 AdmitMode_OptionString,
                                 CopyStr(SelectStr(1, AdmitMode_OptionString), 1, 250),
                                 AdmitMode_Caption,
                                 AdmitMode_Desc,
                                 AdmitMode_OptionCaption);
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
        Wallet: Query "NPR FindAttractionWallets";
        WalletFacade: Codeunit "NPR AttractionWalletFacade";
        ReferenceNumber: Text[50];
        AdditionalItemNo: Code[20];
        IsWallet: Boolean;
        RevokeCount: Integer;
        NothingToRebook: Label 'There is nothing to rebook for this reference number.';
        AmountRevoked: Decimal;
        SelectedAdmitMode: Option SALE,SCAN,NO_ADMIT_ON_EOS;
    begin
        ReferenceNumber := CopyStr(Context.GetString(_TicketReference_Name), 1, MaxStrLen(ReferenceNumber));
        AdditionalItemNo := CopyStr(Context.GetStringParameter(_ItemNumber_Name), 1, MaxStrLen(AdditionalItemNo));
        SelectedAdmitMode := Context.GetIntegerParameter(_AdmitMode_Name);

        if (ReferenceNumber = '') then
            exit;

        WalletFacade.FindWalletByReferenceNumber(ReferenceNumber, Wallet);
        if (Wallet.Read()) then begin
            WalletFacade.GetWalletAssets(Wallet.WalletReferenceNumber, WalletAssets);
            while (WalletAssets.Read()) do begin
                IsWallet := true;
                RevokeCount := 1;
                if (WalletAssets.AssetType = WalletAssets.AssetType::TICKET) then
                    RebookOneTicket(WalletAssets.AssetReferenceNumber, ReferenceNumber, WalletAssets.WalletEntryNo, AmountRevoked);
            end;

            GobbleNegativeAmount(AdditionalItemNo, RevokeCount, AmountRevoked);
        end;

        if (not IsWallet) then
            RevokeCount := RebookTicketWorker(ReferenceNumber, AdditionalItemNo);

        if (RevokeCount = 0) then
            error(NothingToRebook);

        SetEndOfSaleAdmitMode(SelectedAdmitMode);
    end;

    local procedure SetEndOfSaleAdmitMode(SelectedAdmitMode: Option SALE,SCAN,NO_ADMIT_ON_EOS)
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Item: Record Item;
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        SaleLinePos: Record "NPR POS Sale Line";
        SalesLineId: Guid;
    begin
        foreach SalesLineId in _CreatedSalesLineIds do begin
            SaleLinePos.GetBySystemId(SalesLineId);
            TicketReservationRequest.SetCurrentKey("Receipt No.", "Line No.");
            TicketReservationRequest.SetFilter("Receipt No.", '%1', SaleLinePos."Sales Ticket No.");
            TicketReservationRequest.SetFilter("Line No.", '%1', SaleLinePos."Line No.");
            if (TicketReservationRequest.FindSet()) then
                repeat
                    if (TicketRequestManager.IsReservationRequest(TicketReservationRequest."Session Token ID")) then
                        case SelectedAdmitMode of
                            SelectedAdmitMode::SALE:
                                TicketReservationRequest.EndOfSaleAdmitMode := TicketReservationRequest.EndOfSaleAdmitMode::SALE;
                            SelectedAdmitMode::SCAN:
                                begin
                                    TicketReservationRequest.EndOfSaleAdmitMode := TicketReservationRequest.EndOfSaleAdmitMode::SCAN;
                                    if (Item.Get(TicketReservationRequest."Item No.")) then
                                        if (Item."NPR POS Admit Action" in [Item."NPR POS Admit Action"::PRINT, Item."NPR POS Admit Action"::NONE]) then
                                            TicketReservationRequest.EndOfSaleAdmitMode := TicketReservationRequest.EndOfSaleAdmitMode::NO_ADMIT_ON_EOS;
                                end;
                            SelectedAdmitMode::NO_ADMIT_ON_EOS:
                                TicketReservationRequest.EndOfSaleAdmitMode := TicketReservationRequest.EndOfSaleAdmitMode::NO_ADMIT_ON_EOS;
                            else
                                TicketReservationRequest.EndOfSaleAdmitMode := TicketReservationRequest.EndOfSaleAdmitMode::SALE;
                        end;

                    if (TicketRequestManager.IsRevokeRequest(TicketReservationRequest."Session Token ID")) then
                        TicketReservationRequest.EndOfSaleAdmitMode := ENUM::"NPR TM AdmitTicketOnEoSMode"::NO_ADMIT_ON_EOS;

                    TicketReservationRequest.Modify();
                until (TicketReservationRequest.Next() = 0);
        end;
    end;

    local procedure RebookTicketWorker(TicketReferenceNumber: Text[50]; AdditionalItemNo: Code[20]) TotalRevokeCount: Integer;
    var
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        UnitPrice, AmountRevoked : Decimal;
        SaleLineCount: Integer;
        RevokeCount: Integer;
        AmountToGobble, TotalAmountToGobble : Decimal;
        QuantityPerUnit: Integer;
    begin
        // Revoke the ticket and create a new one for today
        TotalRevokeCount := RebookOneTicket(TicketReferenceNumber, TotalAmountToGobble);
        if (TotalRevokeCount > 0) then begin
            GobbleNegativeAmount(AdditionalItemNo, TotalRevokeCount, TotalAmountToGobble);
            exit(TotalRevokeCount);
        end;

        // Revoke the ticket reservation and create new for today
        ReservationRequest.Reset();
        ReservationRequest.SetCurrentKey("Session Token ID");
        ReservationRequest.SetFilter("Session Token ID", '=%1', CopyStr(TicketReferenceNumber, 1, MaxStrLen(ReservationRequest."Session Token ID")));
        ReservationRequest.SetFilter("Primary Request Line", '=%1', true);
        if (ReservationRequest.FindSet()) then begin
            repeat
                Ticket.Reset();
                Ticket.SetCurrentKey("Ticket Reservation Entry No.");
                Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', ReservationRequest."Entry No.");
                Ticket.SetFilter(Blocked, '=%1', false);
                if (Ticket.FindSet()) then begin
                    SaleLineCount := _CreatedSalesLineIds.Count() + 1;
                    repeat
                        RevokeTicket(Ticket, UnitPrice, QuantityPerUnit);
                        AmountRevoked -= UnitPrice * QuantityPerUnit;
                        RevokeCount += QuantityPerUnit;
                    until (Ticket.Next() = 0);
                end;

                if (RevokeCount > 0) then
                    CreateTicketSales(SaleLineCount, RevokeCount, AmountRevoked, AmountToGobble);

                TotalRevokeCount += RevokeCount;
                TotalAmountToGobble += AmountToGobble;
                AmountToGobble := 0;
                AmountRevoked := 0;
                RevokeCount := 0;
            until (ReservationRequest.Next() = 0);

            GobbleNegativeAmount(AdditionalItemNo, TotalRevokeCount, TotalAmountToGobble);
        end;
    end;

    local procedure RebookOneTicket(TicketReferenceNumber: Text[50]; var AmountToGobble: Decimal) RevokeCount: Integer;
    begin
        RevokeCount := RebookOneTicket(TicketReferenceNumber, '', 0, AmountToGobble);
    end;

    local procedure RebookOneTicket(TicketReferenceNumber: Text[50]; WalletReferenceNumber: Text[50]; WalletEntryNo: Integer; var AmountToGobble: Decimal) RevokeCount: Integer;
    var
        Ticket: Record "NPR TM Ticket";
        UnitPrice, AmountRevoked : Decimal;
        SaleLineCount: Integer;
        QuantityPerUnit: Integer;
    begin

        Ticket.Reset();
        Ticket.SetCurrentKey("External Ticket No.");
        Ticket.SetFilter("External Ticket No.", '=%1', CopyStr(TicketReferenceNumber, 1, MaxStrLen(Ticket."External Ticket No.")));
        Ticket.SetFilter(Blocked, '=%1', false);
        if (Ticket.FindFirst()) then begin
            RevokeTicket(Ticket, UnitPrice, QuantityPerUnit);
            AmountRevoked := -UnitPrice * QuantityPerUnit;
            RevokeCount := QuantityPerUnit;
            SaleLineCount := _CreatedSalesLineIds.Count();
            CreateTicketSales(SaleLineCount, RevokeCount, AmountRevoked, WalletReferenceNumber, WalletEntryNo, AmountToGobble);
        end;
    end;

    local procedure CreateTicketSales(SaleLineCount: Integer; RevokeTicketCount: Integer; TotalPrice: Decimal; var AmountToGobble: Decimal): Boolean;
    begin
        exit(CreateTicketSales(SaleLineCount, RevokeTicketCount, TotalPrice, '', 0, AmountToGobble));
    end;

    local procedure CreateTicketSales(SaleLineCount: Integer; RevokeTicketCount: Integer; TotalPrice: Decimal; WalletReferenceNumber: Text[50]; WalletEntryNo: Integer; var AmountToGobble: Decimal): Boolean;
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

        SaleLinePos.GetBySystemId(_CreatedSalesLineIds.Get(SaleLineCount));

        ReservationRequest.Reset();
        ReservationRequest.SetCurrentKey("Receipt No.", "Line No.");
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
            ReservationRequest.SetCurrentKey("Receipt No.", "Line No.");
            ReservationRequest.SetFilter("Receipt No.", '%1', SaleLinePos."Sales Ticket No.");
            ReservationRequest.SetFilter("Line No.", '%1', SaleLinePos."Line No.");
            ReservationRequest.FindFirst(); // Issuing Request line

            if (0 <> RequestHandler.IssueTicketFromReservationToken(ReservationRequest."Session Token ID", false, ResponseMessage)) then begin
                // On error - delete all the created sales lines
                foreach SalesLineIdToDelete in _CreatedSalesLineIds do begin
                    SaleLinePos.GetBySystemId(SalesLineIdToDelete);
                    SaleLinePos.Delete(true);
                end;
                Message(IssueNewTicketProblem, ResponseMessage);
                exit(false);
            end;
        end;

        AmountToGobble += TotalPrice;
        exit(true);
    end;

    local procedure GobbleNegativeAmount(AdditionalItemNo: Code[20]; RevokeCount: Integer; Amount: Decimal): Boolean;
    var
        SaleLinePos: Record "NPR POS Sale Line";
    begin
        if ((RevokeCount <> 0) and (Amount < 0)) then begin
            SaleLinePos.GetBySystemId(_CreatedSalesLineIds.Get(_CreatedSalesLineIds.Count() - 1));
            if (AdditionalItemNo <> '') then
                CreateSalesLine(SaleLinePos."Line No." + 10000, AdditionalItemNo, '', '', RevokeCount, Abs(Amount) / RevokeCount);
        end;
    end;

    local procedure RevokeTicket(Ticket: Record "NPR TM Ticket"; var UnitPrice: Decimal; var QuantityToRebook: Integer)
    var
        PosRevoke: Codeunit "NPR POS Action - Ticket Mgt B.";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePos: Record "NPR POS Sale Line";
        RevokeSalesLineId: Guid;
        QtyPerUoM: integer;
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        QuantityToRebook := 1;

        RevokeSalesLineId := PosRevoke.RevokeTicketReservation(POSSession, Ticket."External Ticket No.", true);
        _CreatedSalesLineIds.Add(RevokeSalesLineId);

        // In case of a group ticket we need to get the quantity per unit of measure from the ticket access entry to reproduce new ticket sales lines
        TicketAccessEntry.Reset();
        TicketAccessEntry.SetCurrentKey("Ticket No.");
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.FindFirst();
        QtyPerUoM := Round(TicketAccessEntry.Quantity, 1);

        SaleLinePos.GetBySystemId(RevokeSalesLineId);
        UnitPrice := SaleLinePos."Unit Price" / QtyPerUoM;

        if (QtyPerUoM > 1) then begin // Hmm - sketchy - but we need to rebook with the remaining quantity
            TicketReservationRequest.Get(Ticket."Ticket Reservation Entry No.");
            QuantityToRebook := TicketReservationRequest.Quantity;
            if (TicketAccessEntry.Quantity < TicketReservationRequest.Quantity) then begin
                QuantityToRebook := TicketReservationRequest.Quantity - Round(TicketAccessEntry.Quantity, 1);
                UnitPrice := SaleLinePos."Unit Price" / QuantityToRebook;
            end;
        end;

        AdjustScheduleSelectionForToday(RevokeSalesLineId);
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

    local procedure AdjustScheduleSelectionForToday(RevokeSalesLineId: Guid)
    var
        SaleLinePos: Record "NPR POS Sale Line";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        TicketManager: Codeunit "NPR TM Ticket Management";
        EntryNo: Integer;
        DateTimeLbl: Label '%1 - %2', Locked = true;
        ScheduleContext: Option Admit,Sale;
    begin
        if not SaleLinePos.GetBySystemId(RevokeSalesLineId) then
            exit;

        // Eventually the revoke request lines are cleaned up in OnDeletePOSSaleLineWorker when sales line is deleted
        TicketReservationRequest.SetFilter("Receipt No.", '%1', SaleLinePos."Sales Ticket No.");
        TicketReservationRequest.SetFilter("Line No.", '%1', SaleLinePos."Line No.");
        if (not TicketReservationRequest.FindSet()) then
            exit;

        repeat
            TicketReservationRequest."External Adm. Sch. Entry No." := 0;
            TicketReservationRequest."Scheduled Time Description" := '';

            // Schedule Selection rule Today and Next Available
            EntryNo := TicketManager.GetCurrentScheduleEntry(TicketReservationRequest."Item No.", TicketReservationRequest."Variant Code", TicketReservationRequest."Admission Code", false, ScheduleContext::Sale);

            // Try harder - manually set the entry no. to the first entry for today
            if (EntryNo = 0) then begin
                AdmissionScheduleEntry.Reset();
                AdmissionScheduleEntry.SetCurrentKey("Admission Start Date", "Admission Start Time");
                AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', TicketReservationRequest."Admission Code");
                AdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', Today());
                AdmissionScheduleEntry.SetFilter("Admission Is", '=%1', AdmissionScheduleEntry."Admission Is"::OPEN);
                AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
                if (AdmissionScheduleEntry.FindFirst()) then begin
                    EntryNo := AdmissionScheduleEntry."Entry No.";

                    // Narrow down to the time of day
                    AdmissionScheduleEntry.SetFilter("Admission Start Time", '<=%1', Time());
                    AdmissionScheduleEntry.SetFilter("Admission End Time", '>=%1', Time());
                    if (AdmissionScheduleEntry.FindFirst()) then
                        EntryNo := AdmissionScheduleEntry."Entry No.";
                end;
            end;

            if (AdmissionScheduleEntry.Get(EntryNo)) then begin
                TicketReservationRequest."External Adm. Sch. Entry No." := AdmissionScheduleEntry."External Schedule Entry No.";
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