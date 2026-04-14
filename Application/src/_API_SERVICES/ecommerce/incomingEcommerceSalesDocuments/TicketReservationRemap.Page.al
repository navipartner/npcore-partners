#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
page 6150962 "NPR Ticket Reservation Remap"
{
    Extensible = false;
    PageType = Worksheet;
    ApplicationArea = NPRRetail;
    UsageCategory = None;
    SourceTable = "NPR Ticket Reservation Buffer";
    SourceTableTemporary = true;
    Caption = 'Change Ticket Reservation Token';
    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field(CurrentTicketReservationToken; CurrentTicketReservationToken)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Current Ticket Reservation Token';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Current Ticket Reservation Token field.';
                }

                field(NewTicketReservationToken; NewTicketReservationToken)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'New Ticket Reservation Token';
                    Editable = false;
                    ToolTip = 'Specifies the value of the New Ticket Reservation Token field.';
                    trigger OnDrillDown()
                    begin
                        SelectNewReservationToken();
                    end;
                }

            }

            repeater(Lines)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Item No. field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Quantity field.';
                }

                field("Ticket Reservation Line Id"; Rec."Ticket Reservation Line Id")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Ticket Reservation Line Id field.';
                    trigger OnDrillDown()
                    begin
                        SelectTicketRequestLine();
                    end;
                }
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        ApplyConfirmed := false;

        if CloseAction <> Action::LookupOK then
            exit(true);

        ValidateBeforeClose();

        if not Confirm(ConfirmExitQst, false) then
            exit(false);

        ApplyConfirmed := true;
        exit(true);
    end;

    internal procedure SetDocument(var pEcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
        EcomSalesHeader := pEcomSalesHeader;
        CurrentTicketReservationToken := EcomSalesHeader."Ticket Reservation Token";
        NewTicketReservationToken := '';
        ApplyConfirmed := false;
        LoadSalesLines();
    end;

    internal procedure GetApplyConfirmed(): Boolean
    begin
        exit(ApplyConfirmed);
    end;

    internal procedure GetNewReservationToken(): Text[100]
    begin
        exit(NewTicketReservationToken);
    end;

    internal procedure GetLineMappings(var TempResultBuffer: Record "NPR Ticket Reservation Buffer" temporary)
    var
        TempNPRTicketReservationBuffer: Record "NPR Ticket Reservation Buffer" temporary;
    begin
        TempResultBuffer.Reset();
        TempResultBuffer.DeleteAll();

        TempNPRTicketReservationBuffer.Copy(Rec, true);
        TempNPRTicketReservationBuffer.Reset();

        if TempNPRTicketReservationBuffer.FindSet() then
            repeat
                TempResultBuffer := TempNPRTicketReservationBuffer;
                TempResultBuffer.Insert();
            until TempNPRTicketReservationBuffer.Next() = 0;
    end;

    local procedure LoadSalesLines()
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EntryNo: Integer;
    begin
        Rec.Reset();
        Rec.DeleteAll();

        EntryNo := 0;

        EcomSalesLine.Reset();
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetRange(Subtype, EcomSalesLine.Subtype::Ticket);

        if EcomSalesLine.FindSet() then
            repeat
                EntryNo += 1;
                Rec.Init();
                Rec."Entry No." := EntryNo;
                Rec."Document Entry No." := EcomSalesLine."Document Entry No.";
                Rec."Sales Line No." := EcomSalesLine."Line No.";
#pragma warning disable AA0139
                Rec."Item No." := EcomSalesLine."No.";
#pragma warning restore AA0139
                Rec.Quantity := EcomSalesLine.Quantity;
                Rec.Description := EcomSalesLine.Description;
                Rec."Ticket Reservation Line Id" := EcomSalesLine."Ticket Reservation Line Id";
                Rec.Insert();
            until EcomSalesLine.Next() = 0;
    end;

    local procedure SelectNewReservationToken()
    var
        TicketRequestTokens: Page "NPR Ticket Reserv. Req. List";
    begin
        TicketRequestTokens.LookupMode(true);
        TicketRequestTokens.SetCurrentTicketToken(CurrentTicketReservationToken);
        if TicketRequestTokens.RunModal() = Action::LookupOK then begin
            NewTicketReservationToken := TicketRequestTokens.GetSelectedToken();
            ClearSelectedLines();
            CurrPage.Update(false);
        end;
    end;

    local procedure ClearSelectedLines()
    var
        TempNPRTicketReservationBuffer: Record "NPR Ticket Reservation Buffer" temporary;
        BlankGuid: Guid;
    begin
        TempNPRTicketReservationBuffer.Copy(Rec, true);
        TempNPRTicketReservationBuffer.Reset();

        if TempNPRTicketReservationBuffer.FindSet() then
            repeat
                TempNPRTicketReservationBuffer."Ticket Reservation Line Id" := BlankGuid;
                TempNPRTicketReservationBuffer."Session Token ID" := NewTicketReservationToken;
                TempNPRTicketReservationBuffer.Modify();
            until TempNPRTicketReservationBuffer.Next() = 0;
    end;

    local procedure SelectTicketRequestLine()
    var
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        if NewTicketReservationToken = '' then
            Error(NewTokenMissingErr);

        TicketRequest.Reset();
        TicketRequest.SetRange("Entry Type", TicketRequest."Entry Type"::PRIMARY);
        TicketRequest.SetRange("Request Status", TicketRequest."Request Status"::REGISTERED);
        TicketRequest.SetRange("Session Token ID", NewTicketReservationToken);

        if Page.RunModal(Page::"NPR TM Ticket Request", TicketRequest) = Action::LookupOK then begin
            if (TicketRequest."Item No." <> '') and (Rec."Item No." <> '') and (TicketRequest."Item No." <> Rec."Item No.") then
                if not Confirm(DifferentItemNoQst, false, TicketRequest."Item No.", Rec."Item No.") then
                    exit;

            if IsRequestLineAlreadySelected(TicketRequest.SystemId, Rec."Entry No.") then
                Error(DuplicateMappingErr);

            Rec."Ticket Reservation Line Id" := TicketRequest.SystemId;
            Rec."Session Token ID" := TicketRequest."Session Token ID";
            Rec.Modify();
            CurrPage.Update(false);
        end;
    end;

    local procedure IsRequestLineAlreadySelected(RequestSystemId: Guid; CurrentEntryNo: Integer): Boolean
    var
        TempNPRTicketReservationBuffer: Record "NPR Ticket Reservation Buffer" temporary;
    begin
        if IsNullGuid(RequestSystemId) then
            exit(false);

        TempNPRTicketReservationBuffer.Copy(Rec, true);
        TempNPRTicketReservationBuffer.Reset();
        TempNPRTicketReservationBuffer.SetRange("Ticket Reservation Line Id", RequestSystemId);

        if TempNPRTicketReservationBuffer.FindFirst() then
            exit(TempNPRTicketReservationBuffer."Entry No." <> CurrentEntryNo);

        exit(false);
    end;

    local procedure ValidateBeforeClose()
    var
        TempNPRTicketReservationBuffer: Record "NPR Ticket Reservation Buffer" temporary;
    begin
        if NewTicketReservationToken = '' then
            Error(NewTokenMissingErr);

        TempNPRTicketReservationBuffer.Copy(Rec, true);
        TempNPRTicketReservationBuffer.Reset();

        if not TempNPRTicketReservationBuffer.FindFirst() then
            Error(NothingToApplyErr);

        if TempNPRTicketReservationBuffer.FindSet() then
            repeat
                if IsNullGuid(TempNPRTicketReservationBuffer."Ticket Reservation Line Id") then
                    Error(MappingMissingErr);
            until TempNPRTicketReservationBuffer.Next() = 0;
    end;

    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        CurrentTicketReservationToken: Text[100];
        NewTicketReservationToken: Text[100];
        ApplyConfirmed: Boolean;
        NothingToApplyErr: Label 'There are no sales lines to remap.';
        NewTokenMissingErr: Label 'You must select New Reservation Token.';
        MappingMissingErr: Label 'All shown sales lines must be mapped to a Ticket Reservation line before continuing.';
        DuplicateMappingErr: Label 'This Ticket Request line is already assigned to another sales line.';
        ConfirmExitQst: Label 'Are you sure you want to continue?\The new Ticket Reservation Token will be applied, and the mapped Ticket Reservation lines will be assigned to the sales lines.';
        DifferentItemNoQst: Label 'The selected Ticket Request line has Item No. %1, which is different from the sales line Item No. %2. Do you want to continue?', Comment = '%1 = Ticket Request Item No.; %2 = Sales Line Item No.';

}
#endif
