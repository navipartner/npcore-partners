codeunit 6151244 "NP Retail Update Cues"
{
    trigger OnRun()
    begin
        UpdateGrossTurnover;
        UpdateTableTurnover;
        UpdateTableStatus;

        //AdminCue.GET();
        AdminCue.Init();
        AdminCue."Gross turnover" := GrossRevenue;
        IF GrossRevenue <> 0 Then
            AdminCue."Amount per Guest" := GrossRevenue / (InhouseGuests + AvailableSeats)
        Else
            AdminCue."Amount per guest" := 0.00;
        IF NumberofTransaction <> 0 THEN
            AdminCue."Table turnover" := GrossRevenue / NumberofTransaction
        ELSE
            AdminCue."Table turnover" := 0.00;
        AdminCue."Occupied table" := OccupiedTable;
        AdminCue."Total free tables" := TotalFreeTables;
        AdminCue."Inhouse guests" := InhouseGuests;
        AdminCue."Available seats" := AvailableSeats;
        AdminCue.Transactions := NooftransactionDaily;
        AdminCue."Total guests" := InhouseGuests + AvailableSeats;
        AdminCue."Revenue per seat hour" := 0.00;
        IF NOT AdminCue.Insert() then
            AdminCue.Modify();


    end;

    procedure UpdateGrossTurnover()
    begin
        //NumberofTransaction := 1;
        //GrossRevenue := 1.0;
        POSEntry.RESET;
        //POSEntry.SETRANGE("Posting Date", TODAY);
        POSEntry.SETRANGE("Entry Type", POSEntry."Entry Type"::"Direct Sale");
        //POSEntry.SETRANGE("Shortcut Dimension 1 Code", 'RESTAURANT');
        POSEntry.SetRange("POS Unit No.", '2');
        IF POSEntry.FINDSET THEN BEGIN
            NumberofTransaction := POSEntry.COUNT;
            REPEAT
                GrossRevenue += POSEntry."Amount Incl. Tax";
            UNTIL POSEntry.NEXT = 0;
        END;
    end;

    procedure UpdateNumberOfTransactionDaily()
    begin
        POSEntry.RESET;
        POSEntry.SETRANGE("Posting Date", TODAY);
        POSEntry.SETRANGE("Entry Type", POSEntry."Entry Type"::"Direct Sale");
        //POSEntry.SETRANGE("Shortcut Dimension 1 Code", 'RESTAURANT');
        POSEntry.SetRange("POS Unit No.", '2');
        IF POSEntry.FINDSET THEN BEGIN
            NooftransactionDaily := POSEntry.COUNT;
        END;

    end;

    procedure UpdateTableTurnover()
    begin
        NumberofSeats := 1;
        TableTurnOver := 0.0;
        IF NPRESeating.FindLast THEN begin
            repeat
                NumberofSeats += 1;
            until NPRESeating.Next = 0;
        END;

        IF GrossRevenue <> 0 THEN
            TableTurnOver := GrossRevenue / NumberofSeats;

    end;

    procedure UpdateTableStatus()
    begin
        OccupiedTable := 0;
        TotalFreeTables := 0;
        InhouseGuests := 0;
        AvailableSeats := 0;

        NPRESeating.RESET;
        //NPRESeating.SETFILTER("Multiple Waiter Pad FF", '<>%1', 0);
        NPRESeating.SetFilter(Status, 'INUSE');
        IF NPRESeating.FINDSET THEN BEGIN
            OccupiedTable := NPRESeating.COUNT;
            REPEAT
                InhouseGuests += NPRESeating.Capacity;
            UNTIL NPRESeating.NEXT = 0;
        END;

        NPRESeating.RESET;
        //NPRESeating.SETFILTER("Multiple Waiter Pad FF", '=%1', 0);
        NPRESeating.SetRange(Status, 'READY');
        IF NPRESeating.FINDSET THEN BEGIN
            TotalFreeTables := NPRESeating.COUNT;
            REPEAT
                AvailableSeats += NPRESeating.Capacity;
            UNTIL NPRESeating.NEXT = 0;
        END;
    end;

    var

        AdminCue: record "NP Retail Resturant Cue";
        POSEntry: Record "POS Entry";
        POSSalesLine: Record "POS Sales Line";
        GrossRevenue: Decimal;
        NumberofTransaction: Integer;
        NPRESeating: Record "NPRE Seating";
        OccupiedTable: Integer;
        TotalFreeTables: Integer;
        InhouseGuests: Integer;
        AvailableSeats: Integer;
        TableTurnOver: Decimal;
        AmountperGuest: Decimal;
        NumberofSeats: Integer;
        ReveuneperHour: Decimal;
        NooftransactionDaily: Integer;


}
