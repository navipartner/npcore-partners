codeunit 6060122 "NPR TM Report - Ticket Complex"
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

        if Ticket.FindSet then
            repeat
                TicketType.Get(Ticket."Ticket Type Code");
                if (TicketType."Print Ticket") then
                    PrintOne(Ticket);

            until Ticket.Next = 0;
    end;

    var
        Printer: Codeunit "NPR RP Line Print Mgt.";
        Txt000001: Label 'Valid For';
        Txt000002: Label 'Time';
        Txt000003: Label 'Ticket No.';

    local procedure PrintOne(Ticket: Record "NPR TM Ticket")
    var
        Item: Record Item;
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Admission: Record "NPR TM Admission";
        PosEntry: Record "NPR POS Entry";
        PosEntrySalesLine: Record "NPR POS Sales Line";
        TMDetTickAccEntry: Record "NPR TM Det. Ticket AccessEntry";
        TMAdmSchEntry: Record "NPR TM Admis. Schedule Entry";
        AdmStartDate: array[10] of Date;
        AdmEndDate: array[10] of Date;
        AdmStartTime: array[10] of Time;
        AdmEndTime: array[10] of Time;
        i: Integer;
        AdmissionCode: array[10] of Code[20];
        TimeHeaderCreated: Boolean;
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

        end else
            Printer.AddTextField(1, 0, '   ' + Ticket."Ticket Type Code");

        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");

        if TicketAccessEntry.FindSet then
            repeat
                if Admission.Get(TicketAccessEntry."Admission Code") then begin
                    Printer.AddTextField(1, 0, '   ' + Admission.Description);
                    Printer.AddTextField(2, 2, StrSubstNo('%1 %2', TicketAccessEntry.Quantity, TicketAccessEntry.FieldCaption(Quantity)));
                    i += 1;
                    AdmStartDate[i] := Ticket."Valid From Date";
                    AdmEndDate[i] := Ticket."Valid To Date";
                    AdmStartTime[i] := Ticket."Valid From Time";
                    AdmEndTime[i] := Ticket."Valid To Time";
                    AdmissionCode[i] := Admission."Admission Code";
                    TMDetTickAccEntry.SetRange("Ticket Access Entry No.", TicketAccessEntry."Entry No.");
                    TMDetTickAccEntry.SetRange(Type, TMDetTickAccEntry.Type::RESERVATION);
                    if TMDetTickAccEntry.FindFirst then begin
                        TMAdmSchEntry.SetRange("External Schedule Entry No.", TMDetTickAccEntry."External Adm. Sch. Entry No.");
                        if TMAdmSchEntry.FindFirst then begin
                            AdmStartDate[i] := TMAdmSchEntry."Admission Start Date";
                            AdmEndDate[i] := TMAdmSchEntry."Admission End Date";
                            AdmStartTime[i] := TMAdmSchEntry."Admission Start Time";
                            AdmEndTime[i] := TMAdmSchEntry."Admission End Time";
                        end;
                    end;
                end;
            until TicketAccessEntry.Next = 0;

        Printer.SetBold(false);
        Printer.AddLine(' ');
        Printer.AddTextField(1, 0, '   ' + Txt000001);
        Printer.SetBold(true);

        Printer.NewLine();
        for i := 1 to ArrayLen(AdmissionCode) do begin
            if Admission.Get(AdmissionCode[i]) then begin
                Printer.AddTextField(1, 0, '   ' + Admission.Description);
                if (AdmStartDate[i] <> AdmEndDate[i]) then
                    Printer.AddTextField(2, 2, StrSubstNo('%1 - %2', AdmStartDate[i], AdmEndDate[i]))
                else
                    Printer.AddTextField(2, 2, Format(AdmStartDate[i]));
                Printer.NewLine();
            end;
        end;

        Printer.SetBold(false);

        for i := 1 to ArrayLen(AdmissionCode) do begin
            if (AdmStartTime[i] > 000000T) and Admission.Get(AdmissionCode[i]) then begin
                if not TimeHeaderCreated then begin
                    Printer.AddLine(' ');
                    Printer.AddTextField(1, 0, '   ' + Txt000002);
                    Printer.NewLine();
                    TimeHeaderCreated := true;
                end;
                Printer.AddTextField(1, 0, '   ' + Admission.Description);
                if AdmStartTime[i] <> AdmEndTime[i] then
                    Printer.AddTextField(2, 2, StrSubstNo('%1 - %2', AdmStartTime[i], AdmEndTime[i]))
                else
                    Printer.AddTextField(2, 2, Format(AdmStartTime[i]));
                Printer.NewLine();
            end;
        end;

        Printer.AddLine(' ');
        Printer.AddLine(' ');

        Printer.AddBarcode('Code128', Ticket."External Ticket No.", 2);
        Printer.AddLine(' ');

        Printer.SetFont('Control');
        Printer.AddLine('P');
    end;
}

