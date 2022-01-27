codeunit 6060110 "NPR TM Statistics WebService"
{
    // TM1.39/TSA /20190122 CASE 341335 Expose statistics to 3rd party
    // TM130.1.39/TSA /20190110 CASE 353981 Changed property "Functional Visibility" to External

    trigger OnRun()
    var
        FromDate: Date;
        UntilDate: Date;
        TempTicketAccessStatistics: Record "NPR TM Ticket Access Stats" temporary;
        TempLineFacts: Record "NPR TM Ticket Access Fact" temporary;
        TempColumnFacts: Record "NPR TM Ticket Access Fact" temporary;
    begin

        FromDate := 20190110D;
        UntilDate := 20190114D;

        TempLineFacts."Fact Name" := TempLineFacts."Fact Name"::ADMISSION_CODE;
        TempColumnFacts."Fact Name" := TempColumnFacts."Fact Name"::ITEM;

        Build2DimensionalStatistics(FromDate, UntilDate, TempLineFacts."Fact Name", TempColumnFacts."Fact Name", TempTicketAccessStatistics, TempLineFacts, TempColumnFacts);
    end;

    procedure GetNDimTicketStatistics(var TicketStatistics: XMLport "NPR TM Ticket Statistics N-Dim")
    var
        FromDate: Date;
        UntilDate: Date;
        TempTicketAccessStatistics: Record "NPR TM Ticket Access Stats" temporary;
        TicketAccessStatistics: Codeunit "NPR TM Ticket Access Stats";
    begin

        TicketStatistics.Import();

        TicketStatistics.GetRequest(FromDate, UntilDate);
        TicketAccessStatistics.BuildCompressedStatisticsAdHoc(FromDate, UntilDate, TempTicketAccessStatistics);
        TicketStatistics.SetResponse(TempTicketAccessStatistics);
    end;

    procedure Get2DimTicketStatistics(var TicketStatistics: XMLport "NPR TM Ticket Statistics 2-Dim")
    var
        FromDate: Date;
        UntilDate: Date;
        TempTicketAccessStatistics: Record "NPR TM Ticket Access Stats" temporary;
        TempLineFacts: Record "NPR TM Ticket Access Fact" temporary;
        TempColumnFacts: Record "NPR TM Ticket Access Fact" temporary;
        TempColumns: Record "NPR TM Ticket Access Fact" temporary;
        TempLines: Record "NPR TM Ticket Access Fact" temporary;
        Dim1: Text;
        Dim2: Text;
        ReasonText: Text;
    begin


        TicketStatistics.Import();
        TicketStatistics.GetRequest(FromDate, UntilDate, Dim1, Dim2);

        if (not GetFactOption(Dim1, TempLines."Fact Name", ReasonText)) then begin
            TicketStatistics.SetErrorResponse(ReasonText);
            exit;
        end;

        if (not GetFactOption(Dim2, TempColumns."Fact Name", ReasonText)) then begin
            TicketStatistics.SetErrorResponse(ReasonText);
            exit;
        end;

        Build2DimensionalStatistics(FromDate, UntilDate, TempLines."Fact Name", TempColumns."Fact Name", TempTicketAccessStatistics, TempLineFacts, TempColumnFacts);
        TicketStatistics.SetResponse(TempLineFacts, TempColumnFacts, TempTicketAccessStatistics);
    end;

    local procedure GetFactOption(DimensionText: Text; var FactCode: Option; var ReasonText: Text): Boolean
    var
        TicketAccessFact: Record "NPR TM Ticket Access Fact";
        ReasonLbl: Label 'Unknown dimensioncode [%1], use one of: [Ticket, TicketType, AdmissionDate, AdmissionHour, AdmissionCode, TicketVariant] or [0,1,2,3,4,5] for short.';
    begin

        case UpperCase(DimensionText) of
            '0', 'ITEM', 'TICKET':
                FactCode := TicketAccessFact."Fact Name"::ITEM;
            '1', 'TICKETTYPE', 'TICKET TYPE':
                FactCode := TicketAccessFact."Fact Name"::TICKET_TYPE;
            '2', 'ADMISSIONDATE', 'ADMISSION DATE':
                FactCode := TicketAccessFact."Fact Name"::ADMISSION_DATE;
            '3', 'ADMISSIONHOUR', 'ADMISSION HOUR':
                FactCode := TicketAccessFact."Fact Name"::ADMISSION_HOUR;
            '4', 'ADMISSIONCODE', 'ADMISSION CODE':
                FactCode := TicketAccessFact."Fact Name"::ADMISSION_CODE;
            '5', 'VARIANTCODE', 'TICKETVARIANT', 'TICKET VARIANT':
                FactCode := TicketAccessFact."Fact Name"::VARIANT_CODE;
            else begin
                    ReasonText := StrSubstNo(ReasonLbl, DimensionText);
                    exit(false);
                end;
        end;

        exit(true);
    end;

    procedure Build2DimensionalStatistics(FromDate: Date; UntilDate: Date; Dim1: Option; Dim2: Option; var Tmp2DimStatistics: Record "NPR TM Ticket Access Stats" temporary; var TmpLineFacts: Record "NPR TM Ticket Access Fact" temporary; var TmpColumnFacts: Record "NPR TM Ticket Access Fact" temporary)
    var
        TempTicketAccessStatistics: Record "NPR TM Ticket Access Stats" temporary;
        TicketAccessStatistics: Codeunit "NPR TM Ticket Access Stats";
        AdmissionHour: Integer;
        AdmissionDate: Date;
        EntryNumber: Integer;
    begin

        EntryNumber := 0;
        TicketAccessStatistics.BuildCompressedStatisticsAdHoc(FromDate, UntilDate, TempTicketAccessStatistics);

        // build a fact table based on the dataset in tmp statistics
        BuildFactTable(TempTicketAccessStatistics, TmpLineFacts);
        BuildFactTable(TempTicketAccessStatistics, TmpColumnFacts);

        // Keep the expressed line & column facts only
        TmpLineFacts.SetFilter("Fact Name", '<>%1', Dim1);
        if (TmpLineFacts.IsTemporary()) then
            TmpLineFacts.DeleteAll();

        TmpColumnFacts.SetFilter("Fact Name", '<>%1', Dim2);
        if (TmpColumnFacts.IsTemporary()) then
            TmpColumnFacts.DeleteAll();

        TmpLineFacts.Reset();
        TmpColumnFacts.Reset();

        // This is TmpLineFacts.COUNT() * Columns.COUNT() to get statistics calculated for every cell.
        if (TmpLineFacts.FindSet()) then
            repeat
                if (TmpColumnFacts.FindSet()) then
                    repeat

                        case TmpLineFacts."Fact Name" of
                            TmpLineFacts."Fact Name"::ADMISSION_CODE:
                                TempTicketAccessStatistics.SetFilter("Admission Code", '=%1', TmpLineFacts."Fact Code");
                            TmpLineFacts."Fact Name"::ADMISSION_HOUR:
                                begin
                                    Evaluate(AdmissionHour, TmpLineFacts."Fact Code");
                                    TempTicketAccessStatistics.SetFilter("Admission Hour", '=%1', AdmissionHour);
                                end;
                            TmpLineFacts."Fact Name"::ITEM:
                                TempTicketAccessStatistics.SetFilter("Item No.", '=%1', TmpLineFacts."Fact Code");
                            TmpLineFacts."Fact Name"::TICKET_TYPE:
                                TempTicketAccessStatistics.SetFilter("Ticket Type", '=%1', TmpLineFacts."Fact Code");
                            TmpLineFacts."Fact Name"::VARIANT_CODE:
                                TempTicketAccessStatistics.SetFilter("Variant Code", '=%1', TmpLineFacts."Fact Code");
                            TmpLineFacts."Fact Name"::ADMISSION_DATE:
                                begin
                                    Evaluate(AdmissionDate, TmpLineFacts."Fact Code", 9);
                                    TempTicketAccessStatistics.SetFilter("Admission Date", '=%1', AdmissionDate);
                                end;
                        end;

                        case TmpColumnFacts."Fact Name" of
                            TmpColumnFacts."Fact Name"::ADMISSION_CODE:
                                TempTicketAccessStatistics.SetFilter("Admission Code", '=%1', TmpColumnFacts."Fact Code");
                            TmpColumnFacts."Fact Name"::ADMISSION_HOUR:
                                begin
                                    Evaluate(AdmissionHour, TmpColumnFacts."Fact Code");
                                    TempTicketAccessStatistics.SetFilter("Admission Hour", '=%1', AdmissionHour);
                                end;
                            TmpColumnFacts."Fact Name"::ITEM:
                                TempTicketAccessStatistics.SetFilter("Item No.", '=%1', TmpColumnFacts."Fact Code");
                            TmpColumnFacts."Fact Name"::TICKET_TYPE:
                                TempTicketAccessStatistics.SetFilter("Ticket Type", '=%1', TmpColumnFacts."Fact Code");
                            TmpColumnFacts."Fact Name"::VARIANT_CODE:
                                TempTicketAccessStatistics.SetFilter("Variant Code", '=%1', TmpColumnFacts."Fact Code");
                            TmpColumnFacts."Fact Name"::ADMISSION_DATE:
                                begin
                                    Evaluate(AdmissionDate, TmpColumnFacts."Fact Code", 9);
                                    TempTicketAccessStatistics.SetFilter("Admission Date", '=%1', AdmissionDate);
                                end;
                        end;

                        // hi-jack "item no." for lines and "admission code" for columns
                        if (TempTicketAccessStatistics.FindSet()) then begin
                            repeat
                                Tmp2DimStatistics.SetFilter("Item No.", '=%1', TmpLineFacts."Fact Code");
                                Tmp2DimStatistics.SetFilter("Admission Code", '=%1', TmpColumnFacts."Fact Code");
                                if (Tmp2DimStatistics.FindFirst()) then begin
                                    Tmp2DimStatistics."Admission Count" += TempTicketAccessStatistics."Admission Count";
                                    Tmp2DimStatistics."Admission Count (Neg)" += TempTicketAccessStatistics."Admission Count (Neg)";
                                    Tmp2DimStatistics."Admission Count (Re-Entry)" += TempTicketAccessStatistics."Admission Count (Re-Entry)";
                                    Tmp2DimStatistics."Generated Count (Neg)" += TempTicketAccessStatistics."Generated Count (Neg)";
                                    Tmp2DimStatistics."Generated Count (Pos)" += TempTicketAccessStatistics."Generated Count (Pos)";
                                    Tmp2DimStatistics.Modify();
                                end else begin
                                    Tmp2DimStatistics.Init();
                                    EntryNumber += 1;
                                    Tmp2DimStatistics."Entry No." := EntryNumber;
                                    Tmp2DimStatistics."Item No." := TmpLineFacts."Fact Code";
                                    Tmp2DimStatistics."Admission Code" := TmpColumnFacts."Fact Code";
                                    Tmp2DimStatistics."Admission Count" := TempTicketAccessStatistics."Admission Count";
                                    Tmp2DimStatistics."Admission Count (Neg)" := TempTicketAccessStatistics."Admission Count (Neg)";
                                    Tmp2DimStatistics."Admission Count (Re-Entry)" := TempTicketAccessStatistics."Admission Count (Re-Entry)";
                                    Tmp2DimStatistics."Generated Count (Neg)" := TempTicketAccessStatistics."Generated Count (Neg)";
                                    Tmp2DimStatistics."Generated Count (Pos)" := TempTicketAccessStatistics."Generated Count (Pos)";

                                    Tmp2DimStatistics.Insert();
                                end;
                            until (TempTicketAccessStatistics.Next() = 0);
                        end else begin
                            Tmp2DimStatistics.Init();
                            EntryNumber += 1;
                            Tmp2DimStatistics."Entry No." := EntryNumber;
                            Tmp2DimStatistics."Item No." := TmpLineFacts."Fact Code";
                            Tmp2DimStatistics."Admission Code" := TmpColumnFacts."Fact Code";
                            Tmp2DimStatistics.Insert();
                        end;

                    until (TmpColumnFacts.Next() = 0);
            until (TmpLineFacts.Next() = 0);

        Tmp2DimStatistics.Reset();
        TempTicketAccessStatistics.Reset();
    end;

    local procedure BuildFactTable(var TmpTicketAccessStatistics: Record "NPR TM Ticket Access Stats" temporary; var TmpTicketAccessFact: Record "NPR TM Ticket Access Fact" temporary)
    var
        TicketType: Record "NPR TM Ticket Type";
        Item: Record Item;
        FactCode: Code[20];
        Admission: Record "NPR TM Admission";
        Variant: Record "Item Variant";
        FactCodeLbl: Label '0%1', Locked = true;
        FactDescriptionLbl: Label '%1:00 - %1:59', Locked = true;
    begin

        TmpTicketAccessStatistics.Reset();
        if (not TmpTicketAccessStatistics.FindSet()) then
            exit;

        repeat

            if (not TmpTicketAccessFact.Get(TmpTicketAccessFact."Fact Name"::TICKET_TYPE, TmpTicketAccessStatistics."Ticket Type")) then begin
                TmpTicketAccessFact.Init();
                TmpTicketAccessFact."Fact Name" := TmpTicketAccessFact."Fact Name"::TICKET_TYPE;
                TmpTicketAccessFact."Fact Code" := TmpTicketAccessStatistics."Ticket Type";
                if (TicketType.Get(TmpTicketAccessFact."Fact Code")) then
                    TmpTicketAccessFact.Description := TicketType.Description;
                TmpTicketAccessFact.Insert();
            end;

            if (not TmpTicketAccessFact.Get(TmpTicketAccessFact."Fact Name"::ADMISSION_CODE, TmpTicketAccessStatistics."Admission Code")) then begin
                TmpTicketAccessFact.Init();
                TmpTicketAccessFact."Fact Name" := TmpTicketAccessFact."Fact Name"::ADMISSION_CODE;
                TmpTicketAccessFact."Fact Code" := TmpTicketAccessStatistics."Admission Code";
                if (Admission.Get(TmpTicketAccessFact."Fact Code")) then
                    TmpTicketAccessFact.Description := CopyStr(Admission.Description, 1, MaxStrLen(TmpTicketAccessFact.Description));
                TmpTicketAccessFact.Insert();
            end;

            if (not TmpTicketAccessFact.Get(TmpTicketAccessFact."Fact Name"::ITEM, TmpTicketAccessStatistics."Item No.")) then begin
                TmpTicketAccessFact.Init();
                TmpTicketAccessFact."Fact Name" := TmpTicketAccessFact."Fact Name"::ITEM;
                TmpTicketAccessFact."Fact Code" := TmpTicketAccessStatistics."Item No.";
                if (Item.Get(TmpTicketAccessFact."Fact Code")) then
                    TmpTicketAccessFact.Description := CopyStr(Item.Description, 1, MaxStrLen(TmpTicketAccessFact.Description));
                TmpTicketAccessFact.Insert();
            end;

            if (not TmpTicketAccessFact.Get(TmpTicketAccessFact."Fact Name"::VARIANT_CODE, TmpTicketAccessStatistics."Variant Code")) then begin
                TmpTicketAccessFact.Init();
                TmpTicketAccessFact."Fact Name" := TmpTicketAccessFact."Fact Name"::VARIANT_CODE;
                TmpTicketAccessFact."Fact Code" := TmpTicketAccessStatistics."Variant Code";
                if (Variant.Get(TmpTicketAccessStatistics."Item No.", TmpTicketAccessStatistics."Variant Code")) then
                    TmpTicketAccessFact.Description := CopyStr(Variant.Description, 1, MaxStrLen(TmpTicketAccessFact.Description));
                TmpTicketAccessFact.Insert();
            end;

            FactCode := Format(TmpTicketAccessStatistics."Admission Date", 0, 9);
            if (not TmpTicketAccessFact.Get(TmpTicketAccessFact."Fact Name"::ADMISSION_DATE, FactCode)) then begin
                TmpTicketAccessFact.Init();
                TmpTicketAccessFact."Fact Name" := TmpTicketAccessFact."Fact Name"::ADMISSION_DATE;
                TmpTicketAccessFact."Fact Code" := FactCode;
                TmpTicketAccessFact.Description := Format(TmpTicketAccessStatistics."Admission Date");
                TmpTicketAccessFact.Insert();
            end;

            FactCode := Format(TmpTicketAccessStatistics."Admission Hour");
            if (StrLen(FactCode) = 1) then
                FactCode := StrSubstNo(FactCodeLbl, FactCode);
            if (not TmpTicketAccessFact.Get(TmpTicketAccessFact."Fact Name"::ADMISSION_HOUR, FactCode)) then begin
                TmpTicketAccessFact.Init();
                TmpTicketAccessFact."Fact Name" := TmpTicketAccessFact."Fact Name"::ADMISSION_HOUR;
                TmpTicketAccessFact."Fact Code" := FactCode;
                TmpTicketAccessFact.Description := StrSubstNo(FactDescriptionLbl, FactCode);
                TmpTicketAccessFact.Insert();
            end;
        until (TmpTicketAccessStatistics.Next() = 0);
    end;
}

