xmlport 6060119 "NPR TM Ticket Revoke"
{
    Caption = 'Ticket Revoke';
    Encoding = UTF8;
    UseDefaultNamespace = true;
    UseRequestPage = false;

    schema
    {
        textelement(tickets)
        {
            MaxOccurs = Once;
            XmlName = 'Tickets';

            textelement(request)
            {
                MaxOccurs = Once;
                XmlName = 'RevokeTicketRequest';

                tableelement(TempTicketReservationRequest; "NPR TM Ticket Reservation Req.")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                    XmlName = 'Request';
                    UseTemporary = true;

                    fieldelement(ticket_number; TempTicketReservationRequest."External Ticket Number")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                        XmlName = 'TicketNumber';
                        trigger OnAfterAssignField()
                        begin
                            if (ReservationID = '') then
                                ReservationID := TempTicketReservationRequest."Session Token ID";
                        end;
                    }

                    fieldelement(pin_code; TempTicketReservationRequest."Authorization Code")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                        XmlName = 'PinCode';

                    }
                }
            }
            tableelement(TempResult; "NPR TM Ticket Reservation Req.")
            {
                MaxOccurs = Once;
                MinOccurs = Zero;
                XmlName = 'Result';
                UseTemporary = true;

                textelement(ResponseCode)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                    XmlName = 'ResponseCode';
                }
                textelement(ResponseMessage)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                    XmlName = 'ResponseMessage';
                }
                textelement(ExpiresAt)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                    XmlName = 'ExpiresAt';

                    textattribute(ExpireAtUTC)
                    {
                        Occurrence = Required;
                        XmlName = 'UTC';
                        trigger OnAfterAssignVariable()
                        begin
                            ExpireAtUTC := FORMAT(TempResult."Expires Date Time", 0, 9);
                        end;
                    }
                }
                textelement(Ticket)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                    XmlName = 'Ticket';

                    fieldattribute(TicketItemNumber; TempResult."External Ticket Number")
                    {
                        Occurrence = Required;
                        XmlName = 'TicketItemNumber';
                    }
                    fieldattribute(RevokeRequestToken; TempResult."Session Token ID")
                    {
                        Occurrence = Required;
                        XmlName = 'RevokeRequestToken';
                    }
                    textattribute(AmountLcy)
                    {
                        Occurrence = Optional;
                        XmlName = 'AmountLCY';
                        trigger OnAfterAssignVariable()
                        begin
                            AmountLcy := '';
                            if (TempResult.AmountInclVat <> 0) then
                                AmountLcy := Format(TempResult.AmountInclVat, 0, 9);
                        end;
                    }
                }
            }

        }
    }

    var
        ReservationID: Text[100];
        ExternalIdCount: Integer;
        QtySum: Integer;

    procedure GetToken(): Text[100]
    begin
        exit(ReservationID);
    end;

    procedure GetSummary(): Text[30]
    begin
        exit(StrSubstNo('%1-%2', ExternalIdCount, QtySum));
    end;

    procedure SetReservationResult(Token: Text[100]; Success: Boolean)
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin

        Commit();
        if (TempResult.IsTemporary()) then
            TempResult.DeleteAll();

        if (not Success) then begin
            SetErrorResult(GetLastErrorText());
            exit;
        end;

        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.FindSet();

        TempResult."Entry No." := 1;
        TempResult.TransferFields(TicketReservationRequest, false);
        TempResult.Insert();

        ResponseCode := 'WARNING';
        ResponseMessage := 'AmountLCY is estimated and not based on actual sales.';
    end;

    procedure SetErrorResult(ErrorMessage: Text)
    begin
        TempResult."Entry No." := 1;
        TempResult.TransferFields(TempTicketReservationRequest, false);
        TempResult.Insert();
        ResponseCode := 'Error';
        ResponseMessage := ErrorMessage;
    end;
}