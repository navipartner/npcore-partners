xmlport 6060122 "NPR TM Ticket Get Print URL"
{
    // TM1.26/NPKNAV/20171122  CASE 285601-01 Transport TM1.26 - 22 November 2017

    Caption = 'Ticket Print Request';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    UseRequestPage = false;

    schema
    {
        textelement(tickets)
        {
            textelement(print_request)
            {
                tableelement(tmpticketin; "NPR TM Ticket")
                {
                    XmlName = 'ticket';
                    UseTemporary = true;
                    fieldattribute(ticket_number; TmpTicketIn."External Ticket No.")
                    {
                    }

                    trigger OnBeforeInsertRecord()
                    begin

                        LineCounter += 1;
                        TmpTicketIn."No." := Format(LineCounter, 0, 9);
                    end;
                }
            }
            tableelement(tmpticketout; "NPR TM Ticket")
            {
                MinOccurs = Zero;
                XmlName = 'print_response';
                UseTemporary = true;
                fieldattribute(ticket_number; TmpTicketOut."External Ticket No.")
                {
                }
                textattribute(ticket_url)
                {

                    trigger OnBeforePassVariable()
                    begin
                        ticket_url := StrSubstNo(TicketUrlLbl, TicketSetup."Print Server Ticket URL", TmpTicketOut."External Ticket No.");
                    end;
                }
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    var
        TicketSetup: Record "NPR TM Ticket Setup";
        LineCounter: Integer;
        TicketUrlLbl: Label '%1%2', Locked = true;
    procedure CreateResponse()
    var
        Ticket: Record "NPR TM Ticket";
        DIYTicketPrint: Codeunit "NPR TM Ticket DIY Ticket Print";
        FailReason: Text;
    begin

        if (not TicketSetup.Get()) then
            Error('Ticket Setup has not been completed in respect to creating online tickets.');

        if (TmpTicketIn.IsEmpty()) then
            exit;

        TmpTicketIn.FindSet();
        repeat
            Ticket.SetFilter("External Ticket No.", '=%1', TmpTicketIn."External Ticket No.");
            if (Ticket.FindFirst()) then begin
                if (DIYTicketPrint.GenerateTicketPrint(Ticket."Ticket Reservation Entry No.", false, FailReason)) then begin
                    TmpTicketOut.TransferFields(Ticket);
                    if (TmpTicketOut.Insert()) then begin
                        Ticket."Printed Date" := Today();
                        Ticket.Modify();
                    end;
                end else begin
                    Error(FailReason);
                end;
            end;
        until (TmpTicketIn.Next() = 0);
    end;
}

