codeunit 6014440 "POS Customer Location Mgt."
{
    // NPR5.22/MMV/20160404 CASE 232067 Created CU
    // 
    // Handles moving sale line POS records to and from a location such as a dining table, movie theater seat, paintball course etc.
    // 
    // NPR5.23/MMV/20160512 Moved audit roll trace comment from GetSaleFromLoc() to LoadSavedSale() in Touch - Sale POS codeunits
    // NPR5.29/MMV /20161214 CASE 261034 Only show locations with sales attached in list when importing sale.
    // NPR5.31/MMV /20170317 CASE 264109 Applied change from 5.29 to Print action as well.
    // NPR5.31/MMV /20170321 CASE 264112 New function StampSaleAndPrint.
    //                                   Replaced Marshaller calls with system calls.
    // NPR5.31/MMV /20170322 CASE 270332 Added guard against floating sale lines.

    TableNo = "Sale POS";

    trigger OnRun()
    begin
    end;

    var
        PrintEvent: Option "Trigger",OnSave;
        ErrorTxt: Label 'Error';
        Error000001: Label 'No sale found at this location';
        Error000002: Label 'The selected location is invalid';
        Error000003: Label 'The current sale must not contain any lines before import';
        Error000004: Label 'There are no lines to save';
        Text0000001: Label 'Transferred to location receipt %1';
        Marshaller: Codeunit "POS Event Marshaller";
        POSCustLoc: Record "POS Customer Location";

    procedure GetSaleFromLoc(LocNumber: Code[20]; var SalePOS: Record "Sale POS"; var SalePOSLoc: Record "Sale POS"): Boolean
    var
        RetailFormCode: Codeunit "Retail Form Code";
    begin
        if LocNumber = '' then
            LocNumber := List(true, false);

        if LocNumber = '' then
            exit(false);

        //-NPR5.31 [264112]
        POSCustLoc.Get(LocNumber);

        if not ExistingLocationReceipt(LocNumber) then
            Error(Error000001);

        if not EmptySale(SalePOS) then
            Error(Error000003);

        // IF NOT POSCustLoc.GET(LocNumber) THEN BEGIN
        //  Marshaller.Error(ErrorTxt,Error000002,FALSE);
        //  EXIT(FALSE);
        // END;
        //
        // IF NOT ExistingLocationReceipt(LocNumber) THEN BEGIN
        //  Marshaller.Error(ErrorTxt,Error000001,FALSE);
        //  EXIT(FALSE);
        // END;
        //
        // IF NOT EmptySale(SalePOS) THEN BEGIN
        //  Marshaller.Error(ErrorTxt,Error000003,FALSE);
        //  EXIT(FALSE);
        // END;
        //+NPR5.31 [264112]

        SalePOSLoc.SetRange("Customer Location No.", LocNumber);
        SalePOSLoc.FindFirst;

        exit(true);
    end;

    procedure SaveSaleToLoc(LocNumber: Code[20]; var SalePOS: Record "Sale POS"): Boolean
    var
        ErrorMsg: Text;
        NewReceipt: Boolean;
        POSCustLoc: Record "POS Customer Location";
        SaleLinePOS: Record "Sale Line POS";
    begin
        if LocNumber = '' then
            LocNumber := List(true, true);

        if LocNumber = '' then
            exit(false);

        //-NPR5.31 [264112]
        POSCustLoc.Get(LocNumber);

        if EmptySale(SalePOS) then
            Error(Error000004);

        // IF NOT POSCustLoc.GET(LocNumber) THEN BEGIN
        //  Marshaller.Error(ErrorTxt,Error000002,FALSE);
        //  EXIT(FALSE);
        // END;
        //
        // IF EmptySale(SalePOS) THEN BEGIN
        //  Marshaller.Error(ErrorTxt,Error000004,FALSE);
        //  EXIT(FALSE);
        // END;
        //+NPR5.31 [264112]

        NewReceipt := not ExistingLocationReceipt(LocNumber);

        //-NPR5.31 [270332]
        // Temporary protection against floating sale lines if a header has been deleted. When the POS is more robust this can be removed.
        if NewReceipt then begin
            SaleLinePOS.SetRange("Customer Location No.", LocNumber);
            SaleLinePOS.DeleteAll;
        end;
        //+NPR5.31 [270332]

        SalePOS."Customer Location No." := LocNumber; //Stamp sale with location no. before print.
        SalePOS.Modify;

        Print(PrintEvent::OnSave, SalePOS, '');

        //-NPR5.31 [264112]
        SaveSale(LocNumber, SalePOS, NewReceipt, true);
        //+NPR5.31 [264112]

        exit(true);
    end;

    procedure Print(PrintEventIn: Integer; var SalePOSIn: Record "Sale POS"; LocNumber: Code[20])
    var
        RetailReportSelectionMgt: Codeunit "Retail Report Selection Mgt.";
        RecRef: RecordRef;
        SalePOS: Record "Sale POS";
        ReportSelectionRetail: Record "Report Selection Retail";
    begin
        case PrintEventIn of
            PrintEvent::"Trigger": //Print existing sale on location when triggered from POS
                begin
                    if LocNumber = '' then
                        //-NPR5.31 [264109]
                        LocNumber := List(true, false);
                    //LocNumber := List(TRUE, TRUE);
                    //+NPR5.31 [264109]
                    if LocNumber = '' then
                        exit;

                    if POSCustLoc.Get(LocNumber) then begin
                        if not ExistingLocationReceipt(LocNumber) then begin
                            //-NPR5.31 [264112]
                            //Marshaller.Error(ErrorTxt, Error000001, FALSE);
                            Error(Error000001);
                            //+NPR5.31 [264112]
                            exit;
                        end;

                        SalePOS.SetRange("Customer Location No.", LocNumber);
                        SalePOS.SetRange("Saved Sale", true);
                        SalePOS.FindSet;
                        RecRef.GetTable(SalePOS);
                        RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::CustomerLocationOnTrigger);
                    end else
                        //-NPR5.31 [264112]
                        Error(Error000002);
                    //Marshaller.Error(ErrorTxt,Error000002,FALSE);
                    //+NPR5.31 [264112]
                end;

            PrintEvent::OnSave: //Print sale being saved to location.
                begin
                    RecRef.GetTable(SalePOSIn);
                    RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::CustomerLocationOnSave);
                end;
        end;
    end;

    procedure List(Lookup: Boolean; ShowEmpty: Boolean): Code[20]
    var
        TSCustLocations: Page "Touch Screen - Cust Locations";
        POSCustLocation: Record "POS Customer Location";
    begin
        if not ShowEmpty then begin
            POSCustLocation.SetRange(POSCustLocation."Contains Sales", true);
            TSCustLocations.SetTableView(POSCustLocation);
        end;

        if Lookup then begin
            TSCustLocations.LookupMode(true);
            if TSCustLocations.RunModal = ACTION::LookupOK then begin
                TSCustLocations.GetRecord(POSCustLocation);
                exit(POSCustLocation."No.");
            end;
        end else
            TSCustLocations.RunModal;
    end;

    procedure StampSaleAndGetFromLoc(LocNumber: Code[20]; var SalePOS: Record "Sale POS"; var SalePOSLoc: Record "Sale POS"): Boolean
    begin
        //-NPR5.31 [264112]
        if LocNumber = '' then
            LocNumber := List(true, true);

        if LocNumber = '' then
            exit(false);

        POSCustLoc.Get(LocNumber);

        SalePOS."Customer Location No." := LocNumber;
        SalePOS.Modify;

        Print(PrintEvent::OnSave, SalePOS, '');

        SalePOS."Customer Location No." := '';
        SalePOS.Modify;

        if ExistingLocationReceipt(LocNumber) then begin
            SaveSale(LocNumber, SalePOS, false, false);
            SalePOSLoc.SetRange("Customer Location No.", LocNumber);
            exit(SalePOSLoc.FindFirst);
        end;
        //+NPR5.31 [264112]
    end;

    local procedure "-- Aux"()
    begin
    end;

    local procedure EmptySale(var SalePOS: Record "Sale POS"): Boolean
    var
        SaleLinePOS: Record "Sale Line POS";
    begin
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        exit(SaleLinePOS.IsEmpty);
    end;

    local procedure SaveSale(LocNumber: Code[20]; var SalePOS: Record "Sale POS"; NewReceipt: Boolean; DeleteCurrentSaleHeader: Boolean)
    var
        SalePOSLoc: Record "Sale POS";
        SaleLinePOSLoc: Record "Sale Line POS";
        SaleLinePOS: Record "Sale Line POS";
        LineNo: Integer;
        RetailFormCode: Codeunit "Retail Form Code";
    begin
        if NewReceipt then begin //Consider the current receipt as the new receipt for the location
            SalePOS."Saved Sale" := true;
            SalePOS.Modify;

            SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
            SaleLinePOS.ModifyAll("Customer Location No.", LocNumber);
        end else begin //Add sale lines to existing receipt for the location
            SalePOSLoc.SetRange("Customer Location No.", LocNumber);
            SalePOSLoc.SetRange("Saved Sale", true);
            SalePOSLoc.FindFirst;

            SaleLinePOSLoc.SetCurrentKey("Register No.", "Sales Ticket No.", "Line No.");
            SaleLinePOSLoc.SetRange("Register No.", SalePOSLoc."Register No.");
            SaleLinePOSLoc.SetRange("Sales Ticket No.", SalePOSLoc."Sales Ticket No.");

            SaleLinePOS.SetCurrentKey("Register No.", "Sales Ticket No.", "Line No.");
            SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");

            if SaleLinePOSLoc.FindLast then
                LineNo := Round(SaleLinePOSLoc."Line No.", 10000, '<') + 10000
            else
                LineNo := 10000;

            if SaleLinePOS.FindSet then
                repeat
                    SaleLinePOSLoc.Init;
                    SaleLinePOSLoc := SaleLinePOS;
                    SaleLinePOSLoc."Sales Ticket No." := SalePOSLoc."Sales Ticket No.";
                    SaleLinePOSLoc."Register No." := SalePOSLoc."Register No.";
                    SaleLinePOSLoc."Line No." := LineNo;
                    SaleLinePOSLoc."Customer Location No." := LocNumber;
                    SaleLinePOSLoc.Insert;
                    LineNo += 10000;
                until SaleLinePOS.Next = 0;

            //-NPR5.31 [264112]
            if DeleteCurrentSaleHeader then begin
                //+NPR5.31 [264112]
                RetailFormCode.AuditRollCancelSale(SalePOS, StrSubstNo(Text0000001, SaleLinePOSLoc."Sales Ticket No."));
                SalePOS.Delete(true);
                //-NPR5.31 [264112]
            end else begin
                SaleLinePOS.DeleteAll(true);
            end;
            //+NPR5.31 [264112]
            Commit;
        end
    end;

    local procedure ExistingLocationReceipt(LocNumber: Code[20]): Boolean
    var
        SalePOS: Record "Sale POS";
    begin
        SalePOS.SetRange("Customer Location No.", LocNumber);
        SalePOS.SetRange("Saved Sale", true);
        exit(not SalePOS.IsEmpty);
    end;
}

