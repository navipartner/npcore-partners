#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
page 6150963 "NPR Ticket Reserv. Req. List"
{
    PageType = List;
    ApplicationArea = NPRRetail;
    UsageCategory = None;
    SourceTable = "NPR Ticket Reservation Buffer";
    SourceTableTemporary = true;
    Caption = 'Ticket Reservation Tokens';
    Editable = false;
    Extensible = false;
    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Session Token ID"; Rec."Session Token ID")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Session Token ID';
                    ToolTip = 'Specifies the value of the Session Token ID field.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Quantity';
                    ToolTip = 'Specifies the value of the Quantity field.';
                    trigger OnDrillDown()
                    begin
                        OpenTicketRequestsForToken();
                    end;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        LoadTokens();
    end;

    internal procedure GetSelectedToken(): Text[100]
    begin
        exit(Rec."Session Token ID");
    end;

    local procedure LoadTokens()
    var
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        TempNPRTicketReservationBuffer: Record "NPR Ticket Reservation Buffer" temporary;
        EntryNo: Integer;
    begin
        Rec.Reset();
        Rec.DeleteAll();
        EntryNo := 0;

        TicketRequest.Reset();
        TicketRequest.SetCurrentKey("Session Token ID");
        TicketRequest.SetRange("Entry Type", TicketRequest."Entry Type"::PRIMARY);
        TicketRequest.SetRange("Request Status", TicketRequest."Request Status"::REGISTERED);
        if CurrentTicketToken <> '' then
            TicketRequest.SetFilter("Session Token ID", '<>%1', CurrentTicketToken);
        if TicketRequest.FindSet() then
            repeat
                TempNPRTicketReservationBuffer.Reset();
                TempNPRTicketReservationBuffer.SetRange("Session Token ID", TicketRequest."Session Token ID");
                if not TempNPRTicketReservationBuffer.FindFirst() then begin
                    EntryNo += 1;
                    TempNPRTicketReservationBuffer.Init();
                    TempNPRTicketReservationBuffer."Entry No." := EntryNo;
                    TempNPRTicketReservationBuffer."Session Token ID" := TicketRequest."Session Token ID";
                    TempNPRTicketReservationBuffer.Quantity := GetTotalQuantityForToken(TicketRequest."Session Token ID");
                    TempNPRTicketReservationBuffer.Insert();
                end;
            until TicketRequest.Next() = 0;

        TempNPRTicketReservationBuffer.Reset();
        if TempNPRTicketReservationBuffer.FindSet() then
            repeat
                Rec := TempNPRTicketReservationBuffer;
                Rec.Insert();
            until TempNPRTicketReservationBuffer.Next() = 0;
    end;

    local procedure GetTotalQuantityForToken(SessionTokenID: Text[100]): Integer
    var
        TicketRequestQty: Record "NPR TM Ticket Reservation Req.";
        TotalQuantity: Integer;
    begin
        TicketRequestQty.Reset();
        TicketRequestQty.SetRange("Session Token ID", SessionTokenID);
        TicketRequestQty.CalcSums(Quantity);
        TotalQuantity := TicketRequestQty.Quantity;
        exit(TotalQuantity);
    end;

    local procedure OpenTicketRequestsForToken()
    var
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        if Rec."Session Token ID" = '' then
            exit;
        TicketRequest.SetRange("Session Token ID", Rec."Session Token ID");
        Page.Run(Page::"NPR TM Ticket Request", TicketRequest);
    end;

    internal procedure SetCurrentTicketToken(CurrToken: Text[100])
    begin
        CurrentTicketToken := CurrToken;
    end;

    var
        CurrentTicketToken: Text[100];
}
#endif
