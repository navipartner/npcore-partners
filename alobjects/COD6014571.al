codeunit 6014571 "TM Report - Ticket"
{
    // NPR4.16/MMV/20150812 CASE 217433 Changed object from print reservation 12 to 'Report - Ticket'.
    // TM1.03/TSA/20160113 CASE 231260 This will be the default ticket, added quantity for group tickets.
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // #248514/TJ/20161005 CASE 248514 Using actual unit price from audit roll
    // TM1.17/TSA/20161019  CASE 255556 Restructured, Added support for suppressing printout when printing multiple tickets
    // TM1.18/MMV /20170118 CASE 245881 Changed barcode from code39 to code128
    // #264219/JLK /20170126  CASE 264219 Changed Barcode Print to External Ticket No.
    // TM1.21/TSA/20170525  CASE 278049 Fixing issues report by OMA - Removing global variable ticket
    // TM1.22/TSA/20170525  CASE 278049 Fixing issues report by OMA - House cleaning

    TableNo = "TM Ticket";

    trigger OnRun()
    var
        Ticket: Record "TM Ticket";
        TicketType: Record "TM Ticket Type";
    begin
        Ticket.CopyFilters(Rec);

        Printer.SetAutoLineBreak(true);
        Printer.SetThreeColumnDistribution(0.465,0.35,0.235);

        if Ticket.FindSet then repeat
          TicketType.Get (Ticket."Ticket Type Code");
          if (TicketType."Print Ticket") then
            PrintOne (Ticket);

        until Ticket.Next = 0;
    end;

    var
        Printer: Codeunit "RP Line Print Mgt.";
        Txt000001: Label 'Valid For';
        Txt000002: Label 'Time';
        Txt000003: Label 'Ticket No.';

    local procedure PrintOne(Ticket: Record "TM Ticket")
    var
        Item: Record Item;
        TicketAccessEntry: Record "TM Ticket Access Entry";
        Admission: Record "TM Admission";
        AuditRoll: Record "Audit Roll";
        TMTicketType: Record "TM Ticket Type";
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
          Printer.AddTextField(1,0,'   ' + Item.Description);

          AuditRoll.SetRange("Sales Ticket No.",Ticket."Sales Receipt No.");
          AuditRoll.SetRange("Line No.",Ticket."Line No.");
          if AuditRoll.FindFirst and (AuditRoll.Quantity <> 0) then
            Printer.AddTextField(2,2,Format(AuditRoll."Amount Including VAT" / AuditRoll.Quantity))
          else

          if Item."Unit Price" <> 0 then begin
            Printer.AddTextField(2,2,Format(Item."Unit Price"));
          end;

        end else begin
          Printer.AddTextField(1,0,'   ' + Ticket."Ticket Type Code");
        end;

        if TMTicketType.Get(Ticket."Ticket Type Code") then
          Printer.AddTextField (1,0,'   ' + TMTicketType.Description);

        TicketAccessEntry.SetFilter ("Ticket No.", '=%1', Ticket."No.");
        if (TicketAccessEntry.FindFirst()) then
          Printer.AddTextField (2,2, StrSubstNo ('%1 %2', TicketAccessEntry.Quantity, TicketAccessEntry.FieldCaption(Quantity)));

        Printer.SetBold(false);
        Printer.AddLine(' ');
        Printer.AddTextField(1,0,'   ' + Txt000001);
        Printer.SetBold(true);

        if (Ticket."Valid From Date" <> Ticket."Valid To Date") then begin
          Printer.AddTextField(2,2, StrSubstNo ('%1 - %2', Ticket."Valid From Date", Ticket."Valid To Date"))
        end else begin
          Printer.AddTextField(2,2,Format(Ticket."Valid From Date"));
        end;

        Printer.SetBold(false);

        if (Ticket."Valid From Time" > 000000T) then begin
          Printer.AddLine(' ');
          Printer.AddTextField(1,0,'   ' + Txt000002);
          Printer.AddTextField(2,2,Format(Ticket."Valid From Time"));
        end;

        Printer.AddLine(' ');
        Printer.AddLine(' ');

        Printer.AddBarcode('Code128',Ticket."External Ticket No.",2);
        Printer.AddLine(' ');

        Printer.SetFont('Control');
        Printer.AddLine('P');
    end;
}

