codeunit 6014581 "NPR Retail Report Select. Mgt."
{
    // NPR4.18/MMV/20151216 CASE 225584 Created CU
    // 
    // This codeunit acts as a wrapper for all retail report selection needs.
    // Created to unify all usage of both "Report selection retail" and "Report selection - Photo" in one place with minimal code required elsewhere.
    // 
    // NPR5.22/MMV/20160420 CASE 237743 Changed how Type is handled.
    //                                  Removed support for "Report Selection - Photo".
    // NPR5.22/MMV/20160421 CASE 237314 Added support for "Report Printer Interface".
    // NPR5.23/MMV/20160509 CASE 240211 Changed how multiple reports are handled.
    //                                  Changed how matrix print iteration is handled.
    //                                  Changed how filtered report selection lines are handled.
    //                                  Added support for optional reports.
    // NPR5.26/MMV /20160825 CASE 241549 Cleanup - removed old comments.
    // NPR5.32/MMV /20170428 CASE 241995 Retail Print 2.0
    // NPR5.39/MMV /20180207 CASE 304165 Added OnAfterRunReportSelection for modules interested in what is printed from report selection.
    // NPR5.40/MMV /20180319 CASE 304639 Renamed existing event to OnAfterRunReportSelectionRecord and added new OnAfterRunReportSelectionType event.


    trigger OnRun()
    var
        StringLibrary: Codeunit "NPR String Library";
    begin
    end;

    var
        Err000001: Label 'Invalid Type: %1';
        RegisterNo: Code[10];
        Import: Boolean;
        ReqWindow: Boolean;
        SystemPrinter: Boolean;
        PrintSingle: Boolean;
        MatrixPrintQuantity: Integer;
        MatrixPrintIterationFieldNo: Integer;

    procedure RunObjects(var RecRef: RecordRef; ReportType: Integer)
    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
    begin
        with ReportSelectionRetail do begin
            SetRange("Report Type", ReportType);

            if RegisterNo <> '' then
                SetRange("Register No.", RegisterNo);

            if IsEmpty then
                SetRange("Register No.", '');

            SetRange(Optional, false);
            RunSelection(ReportSelectionRetail, RecRef);

            SetRange(Optional, true);
            RunOptionalSelection(ReportSelectionRetail, RecRef);
        end;
    end;

    local procedure "-- Settings"()
    begin
    end;

    procedure SetRegisterNo(RegisterNoIn: Code[10])
    begin
        RegisterNo := RegisterNoIn;
    end;

    procedure SetImport(ImportIn: Boolean)
    begin
        Import := ImportIn;
    end;

    procedure SetRequestWindow(ReqWindowIn: Boolean)
    begin
        ReqWindow := ReqWindowIn;
    end;

    procedure SetUseSystemPrinter(SystemPrinterIn: Boolean)
    begin
        SystemPrinter := SystemPrinterIn;
    end;

    procedure SetMatrixPrintIterationFieldNo(FieldNo: Integer)
    begin
        MatrixPrintIterationFieldNo := FieldNo;
    end;

    local procedure "-- Aux"()
    begin
    end;

    local procedure RunOptionalSelection(var ReportSelection: Record "NPR Report Selection Retail"; var RecRefIn: RecordRef)
    var
        OptionString: Text;
        Itt: Integer;
        Option: Integer;
    begin
        ReportSelection.SetCurrentKey("Report Type", Sequence);
        ReportSelection.SetAutoCalcFields("Report Name", "Codeunit Name", "XML Port Name");
        if ReportSelection.FindSet then
            repeat
                case true of
                    ReportSelection."Print Template" <> '':
                        OptionString += DelChr(ReportSelection."Print Template", '=', ',') + ',';
                    ReportSelection."Report Name" <> '':
                        OptionString += DelChr(ReportSelection."Report Name", '=', ',') + ',';
                    ReportSelection."Codeunit Name" <> '':
                        OptionString += DelChr(ReportSelection."Codeunit Name", '=', ',') + ',';
                    ReportSelection."XML Port Name" <> '':
                        OptionString += DelChr(ReportSelection."XML Port Name", '=', ',') + ',';
                end;
            until ReportSelection.Next = 0;

        if OptionString = '' then
            exit;

        Option := StrMenu(OptionString);

        if Option > 0 then begin
            ReportSelection.FindSet;
            Itt := 1;
            repeat
                if Itt = Option then begin
                    ReportSelection.SetRecFilter;
                    RunSelection(ReportSelection, RecRefIn);
                end;
                Itt += 1;
            until ReportSelection.Next = 0;
        end;
    end;

    local procedure RunSelection(var ReportSelection: Record "NPR Report Selection Retail"; var RecRefIn: RecordRef)
    var
        Variant: Variant;
        MatrixPrintMgt: Codeunit "NPR RP Matrix Print Mgt.";
        LinePrintMgt: Codeunit "NPR RP Line Print Mgt.";
        ObjectOutputMgt: Codeunit "NPR Object Output Mgt.";
        ReportPrinterInterface: Codeunit "NPR Report Printer Interface";
        RecRef: RecordRef;
        RecordView: Text;
        TaskLine: Record "NPR Task Line" temporary;
        TemplateMgt: Codeunit "NPR RP Template Mgt.";
    begin
        with ReportSelection do begin
            if FindSet then
                repeat
                    if Format("Record Filter") <> '' then begin
                        TaskLine.Init;
                        TaskLine."Table 1 No." := "Filter Object ID";
                        TaskLine."Table 1 Filter" := "Record Filter";
                        RecordView := TaskLine.GetTableView("Filter Object ID", RecordView);
                    end else
                        RecordView := '';

                    RecRef := RecRefIn.Duplicate;
                    if TestRecRefFilter(RecRef, "Filter Object ID", RecordView) then begin
                        Variant := RecRef;
                        case true of
                            StrLen("Print Template") > 0:
                                TemplateMgt.PrintTemplate("Print Template", RecRef, MatrixPrintIterationFieldNo);

                            "Report ID" > 0:
                                ReportPrinterInterface.RunReport("Report ID", ReqWindow, SystemPrinter, Variant);

                            "Codeunit ID" > 0:
                                if ObjectOutputMgt.GetCodeunitOutputPath("Codeunit ID") <> '' then
                                    LinePrintMgt.ProcessCodeunit("Codeunit ID", Variant)
                                else
                                    CODEUNIT.Run("Codeunit ID", Variant);

                            "XML Port ID" > 0:
                                XMLPORT.Run("XML Port ID", ReqWindow, Import, Variant);
                        end;
                        //-NPR5.39 [304165]
                        OnAfterRunReportSelectionRecord(ReportSelection, RecRefIn);
                        //+NPR5.39 [304165]
                    end;
                until Next = 0;
        end;

        //-NPR5.40 [304639]
        OnAfterRunReportSelectionType(ReportSelection, RecRefIn);
        //+NPR5.40 [304639]
    end;

    local procedure TestRecRefFilter(var RecRef: RecordRef; ObjectNo: Integer; RecordFilter: Text): Boolean
    var
        Item: Record Item;
        RetailJournalLine: Record "NPR Retail Journal Line";
        ExchangeLabel: Record "NPR Exchange Label";
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        if RecordFilter <> '' then begin
            if RecRef.Number = ObjectNo then begin
                RecRef.FilterGroup(9);
                RecRef.SetView(RecordFilter);
            end else begin //Attempt hardcoded filter handling instead. Currently accepts filter on T 27 if RecRef is one of our commonly used POS print tables.
                case ObjectNo of
                    DATABASE::Item:
                        begin
                            Item.SetView(RecordFilter);
                            case RecRef.Number of
                                DATABASE::"NPR Retail Journal Line":
                                    begin
                                        RecRef.SetTable(RetailJournalLine);
                                        if RetailJournalLine.FindSet then
                                            repeat
                                                Item.SetRange("No.", RetailJournalLine."Item No.");
                                                if not Item.IsEmpty then
                                                    RetailJournalLine.Mark(true);
                                            until RetailJournalLine.Next = 0;
                                        RetailJournalLine.MarkedOnly(true);
                                        RecRef.GetTable(RetailJournalLine);
                                    end;
                                DATABASE::"NPR Exchange Label":
                                    begin
                                        RecRef.SetTable(ExchangeLabel);
                                        if ExchangeLabel.FindSet then
                                            repeat
                                                Item.SetRange("No.", ExchangeLabel."Item No.");
                                                if not Item.IsEmpty then
                                                    ExchangeLabel.Mark(true);
                                            until ExchangeLabel.Next = 0;
                                        ExchangeLabel.MarkedOnly(true);
                                        RecRef.GetTable(ExchangeLabel);
                                    end;
                                DATABASE::"NPR Sale Line POS":
                                    begin
                                        RecRef.SetTable(SaleLinePOS);
                                        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Item);
                                        if SaleLinePOS.FindSet then
                                            repeat
                                                Item.SetRange("No.", SaleLinePOS."No.");
                                                if not Item.IsEmpty then
                                                    SaleLinePOS.Mark(true);
                                            until SaleLinePOS.Next = 0;
                                        SaleLinePOS.MarkedOnly(true);
                                        RecRef.GetTable(SaleLinePOS);
                                    end;
                            end;
                        end;
                end;
            end;
        end;

        exit(not RecRef.IsEmpty);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRunReportSelectionRecord(ReportSelectionRetail: Record "NPR Report Selection Retail"; RecRef: RecordRef)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRunReportSelectionType(ReportSelectionRetail: Record "NPR Report Selection Retail"; RecRef: RecordRef)
    begin
    end;
}

