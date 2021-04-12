codeunit 6014571 "NPR TM Report - Ticket"
{
    TableNo = "NPR TM Ticket";

    trigger OnRun()
    var
        Ticket: Record "NPR TM Ticket";
        TicketType: Record "NPR TM Ticket Type";
    begin
        Ticket.CopyFilters(Rec);

        Printer.SetAutoLineBreak(true);
        Printer.SetThreeColumnDistribution(0.465, 0.35, 0.235);

        if Ticket.FindSet() then
            repeat
                TicketType.Get(Ticket."Ticket Type Code");
                if (TicketType."Print Ticket") then
                    PrintOne(Ticket);

            until Ticket.Next() = 0;
    end;

    var
        Printer: Codeunit "NPR RP Line Print Mgt.";
        Txt000001: Label 'Valid For';
        Txt000002: Label 'Time';

    local procedure PrintOne(Ticket: Record "NPR TM Ticket")
    var
        Item: Record Item;
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        TMTicketType: Record "NPR TM Ticket Type";
        PosEntry: Record "NPR POS Entry";
        PosEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        Printer.SetFont('Control');
        Printer.AddLine('h');
        Printer.AddLine('G');
        Printer.SetFont('A11');
        Printer.SetPadChar('.');
        Printer.AddLine('');
        Printer.SetPadChar('');
        Printer.AddLine(' ');

        Printer.SetBold(true);

        if Ticket."Item No." <> '' then begin
            Item.Get(Ticket."Item No.");
            Printer.AddTextField(1, 0, '   ' + Item.Description);

            PosEntry.SetFilter("Document No.", Ticket."Sales Receipt No.");
            if (PosEntry.FindFirst()) then begin
                PosEntrySalesLine.SetFilter("POS Entry No.", '=%1', PosEntry."Entry No.");
                PosEntrySalesLine.SetFilter("Line No.", '=%1', Ticket."Line No.");
                if (PosEntrySalesLine.FindFirst()) then begin
                    Printer.AddTextField(2, 2, Format(PosEntrySalesLine."Amount Incl. VAT" / PosEntrySalesLine.Quantity))
                end else begin
                    if Item."Unit Price" <> 0 then
                        Printer.AddTextField(2, 2, Format(Item."Unit Price"));
                end;

            end else begin
                if Item."Unit Price" <> 0 then
                    Printer.AddTextField(2, 2, Format(Item."Unit Price"));
            end;

        end else begin
            Printer.AddTextField(1, 0, '   ' + Ticket."Ticket Type Code");
        end;

        if TMTicketType.Get(Ticket."Ticket Type Code") then
            Printer.AddTextField(1, 0, '   ' + TMTicketType.Description);

        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        if (TicketAccessEntry.FindFirst()) then
            Printer.AddTextField(2, 2, StrSubstNo('%1 %2', TicketAccessEntry.Quantity, TicketAccessEntry.FieldCaption(Quantity)));

        Printer.SetBold(false);
        Printer.AddLine(' ');
        Printer.AddTextField(1, 0, '   ' + Txt000001);
        Printer.SetBold(true);

        if (Ticket."Valid From Date" <> Ticket."Valid To Date") then begin
            Printer.AddTextField(2, 2, StrSubstNo('%1 - %2', Ticket."Valid From Date", Ticket."Valid To Date"))
        end else begin
            Printer.AddTextField(2, 2, Format(Ticket."Valid From Date"));
        end;

        Printer.SetBold(false);

        if (Ticket."Valid From Time" > 000000T) then begin
            Printer.AddLine(' ');
            Printer.AddTextField(1, 0, '   ' + Txt000002);
            Printer.AddTextField(2, 2, Format(Ticket."Valid From Time"));
        end;

        Printer.AddLine(' ');
        Printer.AddLine(' ');

        Printer.AddBarcode('Code128', Ticket."External Ticket No.", 2);
        Printer.AddLine(' ');

        Printer.SetFont('Control');
        Printer.AddLine('P');
    end;
}

