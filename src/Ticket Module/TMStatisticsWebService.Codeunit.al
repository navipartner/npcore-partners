codeunit 6060110 "NPR TM Statistics WebService"
{
    // TM1.39/TSA /20190122 CASE 341335 Expose statistics to 3rd party
    // TM130.1.39/TSA /20190110 CASE 353981 Changed property "Functional Visibility" to External


    trigger OnRun()
    var
        FromDate: Date;
        UntilDate: Date;
        TmpTicketAccessStatistics: Record "NPR TM Ticket Access Stats" temporary;
        TmpLineFacts: Record "NPR TM Ticket Access Fact" temporary;
        TmpColumnFacts: Record "NPR TM Ticket Access Fact" temporary;
    begin

        FromDate := 20190110D;
        UntilDate := 20190114D;

        TmpLineFacts."Fact Name" := TmpLineFacts."Fact Name"::ADMISSION_CODE;
        TmpColumnFacts."Fact Name" := TmpColumnFacts."Fact Name"::ITEM;

        Build2DimensionalStatistics(FromDate, UntilDate, TmpLineFacts."Fact Name", TmpColumnFacts."Fact Name", TmpTicketAccessStatistics, TmpLineFacts, TmpColumnFacts);
    end;

    procedure GetNDimTicketStatistics(var TicketStatistics: XMLport "NPR TM Ticket Statistics N-Dim")
    var
        FromDate: Date;
        UntilDate: Date;
        TmpTicketAccessStatistics: Record "NPR TM Ticket Access Stats" temporary;
        TicketAccessStatistics: Codeunit "NPR TM Ticket Access Stats";
    begin

        TicketStatistics.Import();

        TicketStatistics.GetRequest(FromDate, UntilDate);
        TicketAccessStatistics.BuildCompressedStatisticsAdHoc(FromDate, UntilDate, TmpTicketAccessStatistics);
        TicketStatistics.SetResponse(TmpTicketAccessStatistics);
    end;

    procedure Get2DimTicketStatistics(var TicketStatistics: XMLport "NPR TM Ticket Statistics 2-Dim")
    var
        FromDate: Date;
        UntilDate: Date;
        TmpTicketAccessStatistics: Record "NPR TM Ticket Access Stats" temporary;
        TicketAccessStatistics: Codeunit "NPR TM Ticket Access Stats";
        Tmp2DimStatisics: Record "NPR TM Ticket Access Stats";
        TmpLineFacts: Record "NPR TM Ticket Access Fact" temporary;
        TmpColumnFacts: Record "NPR TM Ticket Access Fact" temporary;
        Columns: Record "NPR TM Ticket Access Fact" temporary;
        Lines: Record "NPR TM Ticket Access Fact" temporary;
        AdmissionHour: Integer;
        AdmissionDate: Date;
        EntryNumber: Integer;
        Dim1: Text;
        Dim2: Text;
        ReasonText: Text;
    begin


        TicketStatistics.Import();
        TicketStatistics.GetRequest(FromDate, UntilDate, Dim1, Dim2);

        if (not GetFactOption(Dim1, Lines."Fact Name", ReasonText)) then begin
            TicketStatistics.SetErrorResponse(ReasonText);
            exit;
        end;

        if (not GetFactOption(Dim2, Columns."Fact Name", ReasonText)) then begin
            TicketStatistics.SetErrorResponse(ReasonText);
            exit;
        end;

        Build2DimensionalStatistics(FromDate, UntilDate, Lines."Fact Name", Columns."Fact Name", TmpTicketAccessStatistics, TmpLineFacts, TmpColumnFacts);
        TicketStatistics.SetResponse(TmpLineFacts, TmpColumnFacts, TmpTicketAccessStatistics);
    end;

    local procedure GetFactOption(DimensionText: Text; var FactCode: Option; var ReasonText: Text): Boolean
    var
        TicketAccessFact: Record "NPR TM Ticket Access Fact";
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
                    ReasonText := StrSubstNo('Unknown dimensioncode [%1], use one of: [Ticket, TicketType, AdmissionDate, AdmissionHour, AdmissionCode, TicketVariant] or [0,1,2,3,4,5] for short.', DimensionText);
                    exit(false);
                end;
        end;

        exit(true);
    end;

    procedure Build2DimensionalStatistics(FromDate: Date; UntilDate: Date; Dim1: Option; Dim2: Option; var Tmp2DimStatistics: Record "NPR TM Ticket Access Stats" temporary; var TmpLineFacts: Record "NPR TM Ticket Access Fact" temporary; var TmpColumnFacts: Record "NPR TM Ticket Access Fact" temporary)
    var
        TmpTicketAccessStatistics: Record "NPR TM Ticket Access Stats" temporary;
        TicketAccessStatistics: Codeunit "NPR TM Ticket Access Stats";
        Columns: Record "NPR TM Ticket Access Fact" temporary;
        Lines: Record "NPR TM Ticket Access Fact" temporary;
        AdmissionHour: Integer;
        AdmissionDate: Date;
        EntryNumber: Integer;
    begin

        EntryNumber := 0;
        TicketAccessStatistics.BuildCompressedStatisticsAdHoc(FromDate, UntilDate, TmpTicketAccessStatistics);

        // build a fact table based on the dataset in tmp statistics
        BuildFactTable(TmpTicketAccessStatistics, TmpLineFacts);
        BuildFactTable(TmpTicketAccessStatistics, TmpColumnFacts);

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

                        with TmpLineFacts do
                            case "Fact Name" of
                                "Fact Name"::ADMISSION_CODE:
                                    TmpTicketAccessStatistics.SetFilter("Admission Code", '=%1', "Fact Code");
                                "Fact Name"::ADMISSION_HOUR:
                                    begin
                                        Evaluate(AdmissionHour, "Fact Code");
                                        TmpTicketAccessStatistics.SetFilter("Admission Hour", '=%1', AdmissionHour);
                                    end;
                                "Fact Name"::ITEM:
                                    TmpTicketAccessStatistics.SetFilter("Item No.", '=%1', "Fact Code");
                                "Fact Name"::TICKET_TYPE:
                                    TmpTicketAccessStatistics.SetFilter("Ticket Type", '=%1', "Fact Code");
                                "Fact Name"::VARIANT_CODE:
                                    TmpTicketAccessStatistics.SetFilter("Variant Code", '=%1', "Fact Code");
                                "Fact Name"::ADMISSION_DATE:
                                    begin
                                        Evaluate(AdmissionDate, "Fact Code", 9);
                                        TmpTicketAccessStatistics.SetFilter("Admission Date", '=%1', AdmissionDate);
                                    end;
                            end;

                        with TmpColumnFacts do
                            case "Fact Name" of
                                "Fact Name"::ADMISSION_CODE:
                                    TmpTicketAccessStatistics.SetFilter("Admission Code", '=%1', "Fact Code");
                                "Fact Name"::ADMISSION_HOUR:
                                    begin
                                        Evaluate(AdmissionHour, "Fact Code");
                                        TmpTicketAccessStatistics.SetFilter("Admission Hour", '=%1', AdmissionHour);
                                    end;
                                "Fact Name"::ITEM:
                                    TmpTicketAccessStatistics.SetFilter("Item No.", '=%1', "Fact Code");
                                "Fact Name"::TICKET_TYPE:
                                    TmpTicketAccessStatistics.SetFilter("Ticket Type", '=%1', "Fact Code");
                                "Fact Name"::VARIANT_CODE:
                                    TmpTicketAccessStatistics.SetFilter("Variant Code", '=%1', "Fact Code");
                                "Fact Name"::ADMISSION_DATE:
                                    begin
                                        Evaluate(AdmissionDate, "Fact Code", 9);
                                        TmpTicketAccessStatistics.SetFilter("Admission Date", '=%1', AdmissionDate);
                                    end;
                            end;

                        // hi-jack "item no." for lines and "admission code" for columns
                        if (TmpTicketAccessStatistics.FindSet()) then begin
                            repeat
                                Tmp2DimStatistics.SetFilter("Item No.", '=%1', TmpLineFacts."Fact Code");
                                Tmp2DimStatistics.SetFilter("Admission Code", '=%1', TmpColumnFacts."Fact Code");
                                if (Tmp2DimStatistics.FindFirst()) then begin
                                    Tmp2DimStatistics."Admission Count" += TmpTicketAccessStatistics."Admission Count";
                                    Tmp2DimStatistics."Admission Count (Neg)" += TmpTicketAccessStatistics."Admission Count (Neg)";
                                    Tmp2DimStatistics."Admission Count (Re-Entry)" += TmpTicketAccessStatistics."Admission Count (Re-Entry)";
                                    Tmp2DimStatistics."Generated Count (Neg)" += TmpTicketAccessStatistics."Generated Count (Neg)";
                                    Tmp2DimStatistics."Generated Count (Pos)" += TmpTicketAccessStatistics."Generated Count (Pos)";
                                    Tmp2DimStatistics.Modify();
                                end else begin
                                    Tmp2DimStatistics.Init();
                                    EntryNumber += 1;
                                    Tmp2DimStatistics."Entry No." := EntryNumber;
                                    Tmp2DimStatistics."Item No." := TmpLineFacts."Fact Code";
                                    Tmp2DimStatistics."Admission Code" := TmpColumnFacts."Fact Code";
                                    Tmp2DimStatistics."Admission Count" := TmpTicketAccessStatistics."Admission Count";
                                    Tmp2DimStatistics."Admission Count (Neg)" := TmpTicketAccessStatistics."Admission Count (Neg)";
                                    Tmp2DimStatistics."Admission Count (Re-Entry)" := TmpTicketAccessStatistics."Admission Count (Re-Entry)";
                                    Tmp2DimStatistics."Generated Count (Neg)" := TmpTicketAccessStatistics."Generated Count (Neg)";
                                    Tmp2DimStatistics."Generated Count (Pos)" := TmpTicketAccessStatistics."Generated Count (Pos)";

                                    Tmp2DimStatistics.Insert();
                                end;
                            until (TmpTicketAccessStatistics.Next() = 0);
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
        TmpTicketAccessStatistics.Reset();
    end;

    local procedure BuildFactTable(var TmpTicketAccessStatistics: Record "NPR TM Ticket Access Stats" temporary; var TmpTicketAccessFact: Record "NPR TM Ticket Access Fact" temporary)
    var
        TicketType: Record "NPR TM Ticket Type";
        Item: Record Item;
        FactCode: Code[20];
        Ticket: Record "NPR TM Ticket";
        Admission: Record "NPR TM Admission";
        Variant: Record "Item Variant";
    begin

        TmpTicketAccessStatistics.Reset();
        if (not TmpTicketAccessStatistics.FindSet()) then
            exit;

        repeat

            with TmpTicketAccessFact do begin

                if (not Get("Fact Name"::TICKET_TYPE, TmpTicketAccessStatistics."Ticket Type")) then begin
                    Init();
                    "Fact Name" := "Fact Name"::TICKET_TYPE;
                    "Fact Code" := TmpTicketAccessStatistics."Ticket Type";
                    if (TicketType.Get("Fact Code")) then
                        Description := TicketType.Description;
                    Insert();
                end;

                if (not Get("Fact Name"::ADMISSION_CODE, TmpTicketAccessStatistics."Admission Code")) then begin
                    Init();
                    "Fact Name" := "Fact Name"::ADMISSION_CODE;
                    "Fact Code" := TmpTicketAccessStatistics."Admission Code";
                    if (Admission.Get("Fact Code")) then
                        Description := Admission.Description;
                    Insert();
                end;

                if (not Get("Fact Name"::ITEM, TmpTicketAccessStatistics."Item No.")) then begin
                    Init();
                    "Fact Name" := "Fact Name"::ITEM;
                    "Fact Code" := TmpTicketAccessStatistics."Item No.";
                    if (Item.Get("Fact Code")) then
                        Description := CopyStr(Item.Description, 1, MaxStrLen(Description));
                    Insert();
                end;

                if (not Get("Fact Name"::VARIANT_CODE, TmpTicketAccessStatistics."Variant Code")) then begin
                    Init();
                    "Fact Name" := "Fact Name"::VARIANT_CODE;
                    "Fact Code" := TmpTicketAccessStatistics."Variant Code";
                    if (Variant.Get(TmpTicketAccessStatistics."Item No.", TmpTicketAccessStatistics."Variant Code")) then
                        Description := CopyStr(Variant.Description, 1, MaxStrLen(Description));
                    Insert();
                end;

                FactCode := Format(TmpTicketAccessStatistics."Admission Date", 0, 9);
                if (not Get("Fact Name"::ADMISSION_DATE, FactCode)) then begin
                    Init();
                    "Fact Name" := "Fact Name"::ADMISSION_DATE;
                    "Fact Code" := FactCode;
                    Description := Format(TmpTicketAccessStatistics."Admission Date");
                    Insert();
                end;

                FactCode := Format(TmpTicketAccessStatistics."Admission Hour");
                if (StrLen(FactCode) = 1) then
                    FactCode := StrSubstNo('0%1', FactCode);
                if (not Get("Fact Name"::ADMISSION_HOUR, FactCode)) then begin
                    Init();
                    "Fact Name" := "Fact Name"::ADMISSION_HOUR;
                    "Fact Code" := FactCode;
                    Description := StrSubstNo('%1:00 - %1:59', FactCode);
                    Insert();
                end;
            end;
        until (TmpTicketAccessStatistics.Next() = 0);
    end;
}

