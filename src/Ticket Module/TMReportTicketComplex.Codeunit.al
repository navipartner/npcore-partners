codeunit 6060122 "NPR TM Report - Ticket Complex"
{
    // TM1.18/TJ/20161005 CASE 248514 This is a copy of original codeunit 6014571 with extra features.
    // TM1.18/MMV /20170118 CASE 245881 Changed barcode from code39 to code128
    // #264219/JLK /20170126  CASE 264219 Changed Barcode Print to External Ticket No.
    // TM1.21/TSA/20170525  CASE 278049 Fixing issues report by OMA, removed global variable Ticket

    TableNo = "NPR TM Ticket";

    trigger OnRun()
    var
        Ticket: Record "NPR TM Ticket";
        TicketType: Record "NPR TM Ticket Type";
    begin
        Ticket.CopyFilters(Rec);

        Printer.SetAutoLineBreak(true);
        Printer.SetThreeColumnDistribution(0.465, 0.35, 0.235);

        //-TM1.17 [255556]
        if Ticket.FindSet then
            repeat
                TicketType.Get(Ticket."Ticket Type Code");
                if (TicketType."Print Ticket") then
                    PrintOne(Ticket);

            until Ticket.Next = 0;
        //+TM1.17 [255556]
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
        AuditRoll: Record "NPR Audit Roll";
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

            //-#248514 [248514]
            AuditRoll.SetRange("Sales Ticket No.", Ticket."Sales Receipt No.");
            AuditRoll.SetRange("Line No.", Ticket."Line No.");
            if AuditRoll.FindFirst and (AuditRoll.Quantity <> 0) then
                Printer.AddTextField(2, 2, Format(AuditRoll."Amount Including VAT" / AuditRoll.Quantity))
            else
                //+#248514 [248514]

                if Item."Unit Price" <> 0 then
                    Printer.AddTextField(2, 2, Format(Item."Unit Price"));
        end else
            Printer.AddTextField(1, 0, '   ' + Ticket."Ticket Type Code");

        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");

        //-#248514 [248514]
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
        //+#248514 [248514]

        Printer.SetBold(false);
        Printer.AddLine(' ');
        Printer.AddTextField(1, 0, '   ' + Txt000001);
        Printer.SetBold(true);

        //-#248514 [248514]
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
        //+#248514 [248514]

        Printer.SetBold(false);

        //-#248514 [248514]
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
        //+#248514 [248514]

        Printer.AddLine(' ');
        //Printer.AddTextField(1,0,'   ' + Txt000003);
        //Printer.AddTextField(2,2,FORMAT(Ticket."No."));
        //Printer.AddLine(' ');

        //Ticket text here
        Printer.AddLine(' ');

        //-#245881 [245881]
        //Printer.AddBarcode('Code39',Ticket."No.",4);
        //-#264219
        //Printer.AddBarcode('Code128',Ticket."No.",2);
        Printer.AddBarcode('Code128', Ticket."External Ticket No.", 2);
        //+#264219
        //+#245881 [245881]
        Printer.AddLine(' ');

        Printer.SetFont('Control');
        Printer.AddLine('P');
    end;
}

