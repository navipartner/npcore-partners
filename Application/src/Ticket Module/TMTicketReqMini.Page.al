page 6060101 "NPR TM Ticket Req. Mini"
{
    Extensible = False;
    Caption = 'Ticket Request Mini';
    InsertAllowed = false;
    InstructionalText = 'Set quantity to the number of guest for each line';
    PageType = List;
    SourceTable = "NPR TM Ticket Reservation Req.";
    SourceTableTemporary = true;
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;
    ContextSensitiveHelpPage = 'docs/entertainment/ticket/intro/';

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("External Item Code"; Rec."External Item Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the External Item Code field';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Quantity field';

                    trigger OnValidate()
                    var
                        MaxGuests: Integer;
                    begin
                        if (_GuestMax.Get(Rec."Entry No.", MaxGuests)) then
                            if ((MaxGuests >= 0) and (Rec.Quantity > MaxGuests)) then
                                Error(GuestCountExceededErr, MaxGuests);
                        CurrPage.Update(true);
                    end;
                }
                field(MaxGuestsText; _MaxGuestsText)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Max';
                    Editable = false;
                    ToolTip = 'Specifies the maximum number of guests allowed for this line.';
                }
                field("Admission Code"; Rec."Admission Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Admission Code field';
                }
                field("Admission Description"; Rec."Admission Description")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Admission Description field';
                }
                field("Notification Method"; Rec."Notification Method")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notification Method field';
                }
                field("Notification Address"; Rec."Notification Address")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notification Address field';
                }
            }
        }
    }

    var
        _GuestMax: Dictionary of [Integer, Integer];
        _MaxGuestsText: Text;
        UnlimitedLbl: Label 'Unlimited';
        GuestCountExceededErr: Label 'You can register at most %1 guest(s) for this line.', Comment = '%1 = maximum guest count';

    trigger OnAfterGetRecord()
    var
        MaxGuests: Integer;
    begin
        _MaxGuestsText := '';
        if (_GuestMax.Get(Rec."Entry No.", MaxGuests)) then
            if (MaxGuests < 0) then
                _MaxGuestsText := UnlimitedLbl
            else
                _MaxGuestsText := Format(MaxGuests);
    end;

    internal procedure SetGuestMax(GuestMax: Dictionary of [Integer, Integer])
    begin
        _GuestMax := GuestMax;
    end;

    internal procedure FillRequestTable(var TmpTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary)
    begin
        if TmpTicketReservationRequest.FindSet() then
            repeat
                Rec.TransferFields(TmpTicketReservationRequest, true);
                Rec.Insert();
            until (TmpTicketReservationRequest.Next() = 0);
    end;

    internal procedure GetTicketRequest(var TmpTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary)
    begin
        Rec.Reset();
        if Rec.FindSet() then
            repeat
                TmpTicketReservationRequest.TransferFields(Rec, true);
                TmpTicketReservationRequest.Insert();
            until Rec.Next() = 0;
    end;
}

