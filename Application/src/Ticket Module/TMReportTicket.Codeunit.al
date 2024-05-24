﻿codeunit 6014571 "NPR TM Report - Ticket"
{
    Access = Internal;
    TableNo = "NPR TM Ticket";

    trigger OnRun()
    var
        PrinterDeviceSettings: Record "NPR Printer Device Settings";
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

        Printer.ProcessBuffer(Codeunit::"NPR TM Report - Ticket", Enum::"NPR Line Printer Device"::Epson, PrinterDeviceSettings);
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
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
        PrinterLbl: Label '%1 %2', Locked = true;
        PrinterLbl2Lbl: Label '%1 - %2', Locked = true;
    begin
        Printer.SetFont('COMMAND');
        Printer.AddLine('STOREDLOGO_1', 0);
        Printer.SetFont('A11');
        Printer.SetPadChar('.');
        Printer.AddLine('', 0);
        Printer.SetPadChar('');
        Printer.AddLine(' ', 0);

        Printer.SetBold(true);

        if Ticket."Item No." <> '' then begin
            Item.Get(Ticket."Item No.");
            Printer.AddTextField(1, 0, '   ' + Item.Description);

            PosEntry.SetFilter("Document No.", Ticket."Sales Receipt No.");
            if (PosEntry.FindFirst()) then begin
                if FeatureFlagsManagement.IsEnabled('endSalePerformanceImprovements') then begin
                    if PosEntrySalesLine.Get(PosEntry."Entry No.", Ticket."Line No.") then begin
                        Printer.AddTextField(2, 2, Format(PosEntrySalesLine."Amount Incl. VAT" / PosEntrySalesLine.Quantity))
                    end else begin
                        if Item."Unit Price" <> 0 then
                            Printer.AddTextField(2, 2, Format(Item."Unit Price"));
                    end;
                end else begin
                    PosEntrySalesLine.SetFilter("POS Entry No.", '=%1', PosEntry."Entry No.");
                    PosEntrySalesLine.SetFilter("Line No.", '=%1', Ticket."Line No.");
                    if (PosEntrySalesLine.FindFirst()) then begin
                        Printer.AddTextField(2, 2, Format(PosEntrySalesLine."Amount Incl. VAT" / PosEntrySalesLine.Quantity))
                    end else begin
                        if Item."Unit Price" <> 0 then
                            Printer.AddTextField(2, 2, Format(Item."Unit Price"));
                    end;
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
            Printer.AddTextField(2, 2, StrSubstNo(PrinterLbl, TicketAccessEntry.Quantity, TicketAccessEntry.FieldCaption(Quantity)));

        Printer.SetBold(false);
        Printer.AddLine(' ', 0);
        Printer.AddTextField(1, 0, '   ' + Txt000001);
        Printer.SetBold(true);

        if (Ticket."Valid From Date" <> Ticket."Valid To Date") then begin
            Printer.AddTextField(2, 2, StrSubstNo(PrinterLbl2Lbl, Ticket."Valid From Date", Ticket."Valid To Date"))
        end else begin
            Printer.AddTextField(2, 2, Format(Ticket."Valid From Date"));
        end;

        Printer.SetBold(false);

        if (Ticket."Valid From Time" > 000000T) then begin
            Printer.AddLine(' ', 0);
            Printer.AddTextField(1, 0, '   ' + Txt000002);
            Printer.AddTextField(2, 2, Format(Ticket."Valid From Time"));
        end;

        Printer.AddLine(' ', 0);
        Printer.AddLine(' ', 0);

        Printer.AddBarcode('Code128', Ticket."External Ticket No.", 2, false, 40);
        Printer.AddLine(' ', 0);

        Printer.SetFont('COMMAND');
        Printer.AddLine('PAPERCUT', 0);
    end;
}

