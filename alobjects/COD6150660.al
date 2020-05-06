// TODO: CTRLUPGRADE - uses old Standard code; must be removed or refactored
codeunit 6150660 "NPRE Waiter Pad POS Management"
{
    // NPR5.34/ANEN/20170712 CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.35/ANEN/20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.41/THRO/20180412 CASE 309869 Filter parameters in SeatingLookup
    // NPR5.42/MMV /20180524 CASE 315838 Properly delete sale lines.
    // NPR5.45/MHA /20180827 CASE 318369 Added functions FindSeating(),GetSeatingCode(),SelectWaiterPad() and cleaned up code syntax
    // NPR5.50/TJ  /20190528 CASE 346384 New parameter for showing only active waiterpad on seatings
    // NPR5.53/ALPO/20191029 CASE 373792 Splitting the bill: include selected comment lines as well
    //                                   Automatically remove comment lines from waiterpad, if those are the only lines remaining on the waiterpad
    // NPR5.53/ALPO/20191122 CASE 376538 POS Info - Waiter Pad integration: save sale pos info and restore it, when waiter pad lines are moved back to a sale
    //                                   + Removed old version comment lines
    // NPR5.53/ALPO/20191122 CASE 378585 A new publisher to override existing print category assignment procedure
    // NPR5.53/ALPO/20191211 CASE 380609 NPRE: New guest arrival procedure. Use preselected Waiterpad No. and Seating Code as well as Number of Guests
    // NPR5.53/ALPO/20200102 CASE 360258 Possibility to send to kitchen only selected waiter pad lines or lines of specific print category
    // NPR5.53/ALPO/20200108 CASE 380918 Post Seating Code and Number of Guests to POS Entries (for further sales analysis breakedown)
    // NPR5.54/ALPO/20200331 CASE 398454 Preserve price VAT parameters and use it when copying waiter pad lines to a POS sale
    // NPR5.54/ALPO/20200414 CASE 400139 Item Add-On lines were not copied to waiter pads


    trigger OnRun()
    begin
    end;

    var
        ERRNoPadForSeating: Label 'No active waiter pad exists for seating %1.';
        WaiterPadUI: Page "NPRE Waiter Pad";
        TXTQtyToMove: Label 'Enter quantity to move to sales ticket from line %1 with total quantity %2.';
        CFRM_Move_seating: Label 'Do you want to move waiter pad %1 %2 from seating %3 to %4?';
        ERRMergeToSelf: Label 'Waiter pad can not be merged into itself, choose another waiter pad.';
        TXTMerged: Label 'Waiter pad lines merged into waiter pad %1 - %2.';
        CFRM_Merge: Label 'Do you want to move lines from waiter pad %1 %2 into waiter pad %3 %4.';

    procedure SplitBill(WaiterPad: Record "NPRE Waiter Pad"; POSSaleLine: Codeunit "POS Sale Line")
    var
        TMPWaiterPadLine: Record "NPRE Waiter Pad Line" temporary;
        ChoosenWaiterPadLine: Record "NPRE Waiter Pad Line";
        SaleLinePOS: Record "Sale Line POS";
        DeleteWPLine: Boolean;
    begin
        if not UIShowWaiterPadSplitBilForm(WaiterPad, TMPWaiterPadLine) then
            exit;

        TMPWaiterPadLine.SetFilter(Marked, '=%1', true);
        TMPWaiterPadLine.FilterGroup(-1);  //NPR5.53 [373792]
        TMPWaiterPadLine.SetFilter("Marked Qty", '<>%1', 0);
        //-NPR5.53 [373792]
        TMPWaiterPadLine.SetRange(Type,TMPWaiterPadLine.Type::Comment);
        TMPWaiterPadLine.FilterGroup(0);
        //+NPR5.53 [373792]
        if TMPWaiterPadLine.IsEmpty then
            exit;

        TMPWaiterPadLine.FindFirst;
        repeat
            ChoosenWaiterPadLine.Get(TMPWaiterPadLine."Waiter Pad No.", TMPWaiterPadLine."Line No.");
            POSSaleLine.GetNewSaleLine(SaleLinePOS);

            DeleteWPLine := TMPWaiterPadLine.Quantity = TMPWaiterPadLine."Marked Qty";
          //MoveSaleLineFromWaiterPadToPOS(SaleLinePOS, ChoosenWaiterPadLine, DeleteWPLine, POSSaleLine);  //NPR5.53 [380918]-revoked
          MoveSaleLineFromWaiterPadToPOS(SaleLinePOS,WaiterPad,ChoosenWaiterPadLine,DeleteWPLine,POSSaleLine);  //NPR5.53 [380918]

            POSSaleLine.SetQuantity(TMPWaiterPadLine."Marked Qty");

            if TMPWaiterPadLine.Quantity <> TMPWaiterPadLine."Marked Qty" then begin
                ChoosenWaiterPadLine.Quantity := ChoosenWaiterPadLine.Quantity - TMPWaiterPadLine."Marked Qty";
                ChoosenWaiterPadLine.Modify;
            end;
        until (0 = TMPWaiterPadLine.Next);

        UpdateNoOfGuests(WaiterPad,SaleLinePOS."Register No.",SaleLinePOS."Sales Ticket No.",1);  //NPR5.53 [380918]
        CopySaleHdrPOSInfo(SaleLinePOS."Register No.",SaleLinePOS."Sales Ticket No.",WaiterPad."No.",false);  //NPR5.53 [376538]

        CloseWaiterPad(WaiterPad);
    end;

    procedure MoveSaleFromPOSToWaiterPad(SalePOS: Record "Sale POS"; WaiterPad: Record "NPRE Waiter Pad")
    var
        SaleLinePOS: Record "Sale Line POS";
        WaiterPadLine: Record "NPRE Waiter Pad Line";
        NPHHospitalityPrint: Codeunit "NPRE Restaurant Print";
    begin
        SaleLinePOS.Reset;
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SalePOS.Date);
        SaleLinePOS.SetRange("Sale Type", SalePOS."Sale type");
        if not SaleLinePOS.FindSet(true) then
            exit;

        CopySaleHdrPOSInfo(SaleLinePOS."Register No.",SaleLinePOS."Sales Ticket No.",WaiterPad."No.",true);  //NPR5.53 [376538]
        repeat
          //MoveSaleLineFromPOSToWaiterPad(SaleLinePOS, WaiterPad);  //NPR5.53 [380609]-revoked
          MoveSaleLineFromPOSToWaiterPad(SaleLinePOS,WaiterPad,WaiterPadLine);  //NPR5.53 [380609]
          //SaleLinePOS.DELETE(TRUE);  //NPR5.54 [400139]-revoked
        until SaleLinePOS.Next = 0;
        SaleLinePOS.DeleteAll(true);  //NPR5.54 [400139]

        //-NPR5.53 [380609]
        WaiterPadLine.MarkedOnly(true);
        OnAfterMoveSaleFromPosToWaiterPad(WaiterPad,WaiterPadLine);
        //+NPR5.53 [380609]

        NPHHospitalityPrint.LinesAddedToWaiterPad(WaiterPad);
    end;

    local procedure MoveSaleLineFromPOSToWaiterPad(SaleLinePOS: Record "Sale Line POS";WaiterPad: Record "NPRE Waiter Pad";var WaiterPadLine: Record "NPRE Waiter Pad Line")
    var
        Item: Record Item;
        NPHPrintCategory: Record "NPRE Print Category";
        Handled: Boolean;
    begin
        WaiterPadLine.Init;
        WaiterPadLine."Waiter Pad No." := WaiterPad."No.";
        WaiterPadLine."Register No." := SaleLinePOS."Register No.";
        WaiterPadLine."Start Date" := Today;
        WaiterPadLine."Start Time" := Time;
        
        WaiterPadLine.Type := SaleLinePOS.Type;
        WaiterPadLine."Sale Type" := SaleLinePOS."Sale Type";
        WaiterPadLine.Description := SaleLinePOS.Description;
        WaiterPadLine."No." := SaleLinePOS."No.";
        WaiterPadLine."Description 2" := SaleLinePOS."Description 2";
        WaiterPadLine."Variant Code" := SaleLinePOS."Variant Code";
        WaiterPadLine."Order No. from Web" := SaleLinePOS."Order No. from Web";
        WaiterPadLine."Order Line No. from Web" := SaleLinePOS."Order Line No. from Web";
        WaiterPadLine."Unit of Measure Code" := SaleLinePOS."Unit of Measure Code";
        WaiterPadLine.Quantity := SaleLinePOS.Quantity;
        WaiterPadLine."Unit Price" := SaleLinePOS."Unit Price";
        WaiterPadLine."Discount Type" := SaleLinePOS."Discount Type";
        WaiterPadLine."Discount Code" := SaleLinePOS."Discount Code";
        WaiterPadLine."Allow Line Discount" := SaleLinePOS."Allow Line Discount";
        WaiterPadLine."Discount %" := SaleLinePOS."Discount %";
        WaiterPadLine."Discount Amount" := SaleLinePOS."Discount Amount";
        WaiterPadLine."Allow Invoice Discount" := SaleLinePOS."Allow Invoice Discount";
        WaiterPadLine."Invoice Discount Amount" := SaleLinePOS."Invoice Discount Amount";
        WaiterPadLine."Amount Excl. VAT" := SaleLinePOS.Amount;
        WaiterPadLine."Amount Incl. VAT" := SaleLinePOS."Amount Including VAT";
        //-NPR5.54 [398454]
        WaiterPadLine."Price Includes VAT" := SaleLinePOS."Price Includes VAT";
        WaiterPadLine."VAT Bus. Posting Group" := SaleLinePOS."VAT Bus. Posting Group";
        WaiterPadLine."VAT Prod. Posting Group" := SaleLinePOS."VAT Prod. Posting Group";
        //+NPR5.54 [398454]
        WaiterPadLine.Insert(true);
        WaiterPadLine.Mark(true);  //NPR5.53 [380609]
        
        CopyPOSInfo(SaleLinePOS,WaiterPadLine."Waiter Pad No.",WaiterPadLine."Line No.",true);  //NPR5.53 [376538]
        
        AssignWPadLinePrintCategories(WaiterPadLine,true);  //NPR5.53 [360258]
        //-NPR5.53 [360258]-revoked
        /*
        //-NPR5.53 [378585]
        WPadLine_OnBeforeAssignPrintCategory(WaiterPadLine,Handled);
        IF NOT Handled THEN
        //+NPR5.53 [378585]
          IF WaiterPadLine.Type = WaiterPadLine.Type::Item THEN BEGIN
            IF Item.GET(WaiterPadLine."No.") THEN BEGIN
              IF Item."Print Tags" <> '' THEN BEGIN
                NPHPrintCategory.RESET;
                NPHPrintCategory.SETFILTER("Print Tag", '=%1', Item."Print Tags");
                IF NPHPrintCategory.FINDFIRST THEN BEGIN
                  WaiterPadLine."Print Category" := NPHPrintCategory.Code;
                  WaiterPadLine.MODIFY;
                END;
              END;
            END;
          END;
        */
        //+NPR5.53 [360258]-revoked

    end;

    procedure MoveSaleFromWaiterPadToPOS(WaiterPad: Record "NPRE Waiter Pad"; POSSaleLine: Codeunit "POS Sale Line")
    var
        SaleLinePOS: Record "Sale Line POS";
        WaiterPadLine: Record "NPRE Waiter Pad Line";
    begin
        WaiterPadLine.Reset;
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        if WaiterPadLine.IsEmpty then begin
            CloseWaiterPad(WaiterPad);
            exit;
        end;

        WaiterPadLine.FindSet(true, false);
        repeat
            POSSaleLine.GetNewSaleLine(SaleLinePOS);
          //MoveSaleLineFromWaiterPadToPOS(SaleLinePOS, WaiterPadLine, TRUE, POSSaleLine);  //NPR5.53 [380918]-revoked
          MoveSaleLineFromWaiterPadToPOS(SaleLinePOS,WaiterPad,WaiterPadLine,true,POSSaleLine);  //NPR5.53 [380918]
        until (0 = WaiterPadLine.Next);

        UpdateNoOfGuests(WaiterPad,SaleLinePOS."Register No.",SaleLinePOS."Sales Ticket No.",WaiterPad."Number of Guests" - WaiterPad."Billed Number of Guests");  //NPR5.53 [380918]
        CopySaleHdrPOSInfo(SaleLinePOS."Register No.",SaleLinePOS."Sales Ticket No.",WaiterPad."No.",false);  //NPR5.53 [376538]
        CloseWaiterPad(WaiterPad);
    end;

    local procedure MoveSaleLineFromWaiterPadToPOS(var SaleLinePOS: Record "Sale Line POS";WaiterPad: Record "NPRE Waiter Pad";WaiterPadLine: Record "NPRE Waiter Pad Line";DeleteWaiterPadLine: Boolean;var POSSaleLine: Codeunit "POS Sale Line")
    begin
        SaleLinePOS.Silent := true;

        SaleLinePOS.Type := WaiterPadLine.Type;
        SaleLinePOS."Sale Type" := WaiterPadLine."Sale Type";
        if SaleLinePOS.Type <> SaleLinePOS.Type::Comment then
            SaleLinePOS."No." := WaiterPadLine."No.";
        SaleLinePOS."Variant Code" := WaiterPadLine."Variant Code";

        SaleLinePOS.Description := WaiterPadLine.Description;
        SaleLinePOS."Description 2" := WaiterPadLine."Description 2";
        SaleLinePOS."Order No. from Web" := WaiterPadLine."Order No. from Web";
        SaleLinePOS."Order Line No. from Web" := WaiterPadLine."Order Line No. from Web";
        if SaleLinePOS.Type = SaleLinePOS.Type::Item then
            SaleLinePOS.Validate("Unit of Measure Code");
        SaleLinePOS.Silent := false;

        SaleLinePOS.Validate(Quantity, WaiterPadLine.Quantity);
        SaleLinePOS."Unit Price" := WaiterPadLine."Unit Price";
        //-NPR5.54 [398454]
        SaleLinePOS."Price Includes VAT" := WaiterPadLine."Price Includes VAT";
        SaleLinePOS."VAT Bus. Posting Group" := WaiterPadLine."VAT Bus. Posting Group";
        SaleLinePOS."VAT Prod. Posting Group" := WaiterPadLine."VAT Prod. Posting Group";
        //+NPR5.54 [398454]

        SaleLinePOS."Discount Type" := WaiterPadLine."Discount Type";
        SaleLinePOS."Discount Code" := WaiterPadLine."Discount Code";

        SaleLinePOS."Allow Line Discount" := WaiterPadLine."Allow Line Discount";
        SaleLinePOS."Allow Invoice Discount" := WaiterPadLine."Allow Invoice Discount";

        SaleLinePOS."Discount %" := WaiterPadLine."Discount %";
        SaleLinePOS."Invoice Discount Amount" := WaiterPadLine."Invoice Discount Amount";

        //-NPR5.53 [380918]
        if SaleLinePOS.Type <> SaleLinePOS.Type::Comment then begin
          WaiterPad.CalcFields("Current Seating FF");
          SaleLinePOS."NPRE Seating Code" := WaiterPad."Current Seating FF";
        end;
        //+NPR5.53 [380918]

        POSSaleLine.SetUseLinePriceVATParams(true);  //NPR5.54 [398454]
        POSSaleLine.InsertLine(SaleLinePOS);
        CopyPOSInfo(SaleLinePOS,WaiterPadLine."Waiter Pad No.",WaiterPadLine."Line No.",false);  //NPR5.53 [376538]

        if DeleteWaiterPadLine then
          //WaiterPadLine.DELETE;  //NPR5.53 [360258]-revoked
          WaiterPadLine.Delete(true);  //NPR5.53 [360258]
    end;

    local procedure WaiterPadExistsForSeating(SeatingCode: Code[20]) Exists: Boolean
    var
        SeatingWaiterPadLink: Record "NPRE Seating - Waiter Pad Link";
        Seating: Record "NPRE Seating";
    begin
        Seating.Get(SeatingCode);

        SeatingWaiterPadLink.Reset;
        SeatingWaiterPadLink.SetRange("Seating Code", Seating.Code);

        exit(not SeatingWaiterPadLink.IsEmpty);
    end;

    local procedure GetWaiterPadForSeating(SeatingCode: Code[20]; var WaiterPad: Record "NPRE Waiter Pad")
    var
        SeatingWaiterPadLink: Record "NPRE Seating - Waiter Pad Link";
        Seating: Record "NPRE Seating";
    begin
        Seating.Get(SeatingCode);

        SeatingWaiterPadLink.Reset;
        SeatingWaiterPadLink.SetRange("Seating Code", Seating.Code);

        if SeatingWaiterPadLink.IsEmpty then
            AddNewWaiterPadForSeating(Seating.Code, WaiterPad, SeatingWaiterPadLink);

        if SeatingWaiterPadLink.Count > 1 then begin
            SeatingWaiterPadLink.FindSet;
            WaiterPad.Reset;
            repeat
                WaiterPad.Get(SeatingWaiterPadLink."Waiter Pad No.");
                WaiterPad.Mark(true);
            until SeatingWaiterPadLink.Next = 0;
            WaiterPad.MarkedOnly(true);
        end else begin
            SeatingWaiterPadLink.FindFirst;
            WaiterPad.Reset;
            WaiterPad.SetRange("No.", SeatingWaiterPadLink."Waiter Pad No.");
            WaiterPad.FindFirst;
        end;
    end;

    procedure AddNewWaiterPadForSeating(SeatingCode: Code[10]; var WaiterPad: Record "NPRE Waiter Pad"; var SeatingWaiterPadLink: Record "NPRE Seating - Waiter Pad Link") OK: Boolean
    var
        Seating: Record "NPRE Seating";
        WaiterPadManagement: Codeunit "NPRE Waiter Pad Management";
    begin
        Seating.Get(SeatingCode);
        if WaiterPad."No." = '' then
            WaiterPadManagement.InsertWaiterPad(WaiterPad, true);

        SeatingWaiterPadLink.Init;
        SeatingWaiterPadLink."Seating Code" := Seating.Code;
        SeatingWaiterPadLink."Waiter Pad No." := WaiterPad."No.";
        SeatingWaiterPadLink.Insert;

        exit(true);
    end;

    local procedure UILookUpWaiterPad(var WaiterPad: Record "NPRE Waiter Pad") LookUpOK: Boolean
    var
        WaiterPadList: Page "NPRE Waiter Pad List";
    begin
        WaiterPadList.SetTableView(WaiterPad);
        WaiterPadList.LookupMode := true;
        if WaiterPadList.RunModal = ACTION::LookupOK then begin
            WaiterPadList.GetRecord(WaiterPad);
            WaiterPad.SetRange("No.", WaiterPad."No.");
            WaiterPad.FindFirst;
            LookUpOK := true;
        end else begin
            LookUpOK := false;
        end;

        exit(LookUpOK);
    end;

    local procedure UIShowWaiterPadSplitBilForm(WaiterPad: Record "NPRE Waiter Pad"; var TMPWaiterPadLine: Record "NPRE Waiter Pad Line" temporary) OK: Boolean
    var
        POSWaiterPadLines: Page "NPRE Tmp POS Waiter Pad Lines";
        WaiterPadLine: Record "NPRE Waiter Pad Line";
    begin
        WaiterPadLine.Reset;
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");

        TMPWaiterPadLine.Reset;
        TMPWaiterPadLine.DeleteAll;

        WaiterPadLine.FindFirst;
        repeat
            TMPWaiterPadLine.TransferFields(WaiterPadLine);
            TMPWaiterPadLine.Marked := false;
            TMPWaiterPadLine."Marked Qty" := 0;
            TMPWaiterPadLine.Insert;
        until (0 = WaiterPadLine.Next);

        Clear(POSWaiterPadLines);

        POSWaiterPadLines.fnSetLines(TMPWaiterPadLine);
        POSWaiterPadLines.SetTableView(TMPWaiterPadLine);

        POSWaiterPadLines.Editable(false);

        if POSWaiterPadLines.RunModal = ACTION::OK then begin
            POSWaiterPadLines.fnGetLines(TMPWaiterPadLine);
            exit(true);
        end else begin
            exit(false);
        end;
    end;

    procedure UIShowWaiterPad(WaiterPad: Record "NPRE Waiter Pad")
    begin
        WaiterPadUI.SetRecord(WaiterPad);
        WaiterPadUI.RunModal;
    end;

    procedure CloseWaiterPad(var WaiterPad: Record "NPRE Waiter Pad")
    var
        WaiterPadLine: Record "NPRE Waiter Pad Line";
        SeatingWaiterPadLink: Record "NPRE Seating - Waiter Pad Link";
    begin
        CleanupWaiterPad(WaiterPad);  //NPR5.53 [373792]
        WaiterPadLine.Reset;
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        if WaiterPadLine.IsEmpty then begin
            WaiterPad."Close Date" := WorkDate;
            WaiterPad."Close Time" := Time;
            WaiterPad.Closed := true;
            WaiterPad.Modify;

            SeatingWaiterPadLink.Reset;
            SeatingWaiterPadLink.SetRange("Waiter Pad No.", WaiterPad."No.");
            if not SeatingWaiterPadLink.IsEmpty then
                SeatingWaiterPadLink.DeleteAll;
        end;
    end;

    procedure GetQtyUI(OrgQty: Decimal; Description: Text; var ioChosenQty: Decimal) OK: Boolean
    var
        // TODO: CTRLUPGRADE - declares a removed codeunit; all dependent functionality must be refactored
        //Marshaller: Codeunit "POS Event Marshaller";
    begin
        //Used by page [Tmp POS Waiter Pad Lines] to chose a qty from a total qty
        //Shall show numpad
        ioChosenQty := OrgQty;

        // TODO: CTRLUPGRADE - Must be refactored to not use Marshaller
        Error('CTRLUPGRADE');
        /*
        if not Marshaller.NumPad((StrSubstNo(TXTQtyToMove, Description, OrgQty)), ioChosenQty, false, false) then
            exit(false);
        */

        exit(true);
    end;

    procedure MoveWaiterPadToNewSeatingUI(var WaiterPad: Record "NPRE Waiter Pad")
    var
        Seating: Record "NPRE Seating";
        SeatingManagement: Codeunit "NPRE Seating Management";
        WaiterPadManagement: Codeunit "NPRE Waiter Pad Management";
    begin
        //Called from Waiter pad page -  with UI used to change seating on waiter pad
        Seating.Get(SeatingManagement.UILookUpSeating('', ''));

        WaiterPad.CalcFields("Current Seating FF");

        if not Confirm(StrSubstNo(CFRM_Move_seating, WaiterPad."No.", WaiterPad.Description, WaiterPad."Current Seating Description", Seating.Description), true) then
            exit;
        WaiterPadManagement.ChangeSeating(WaiterPad."No.", WaiterPad."Current Seating FF", Seating.Code);
    end;

    procedure MergeWaiterPadUI(var WaiterPad: Record "NPRE Waiter Pad") OK: Boolean
    var
        Seating: Record "NPRE Seating";
        MergeToWaiterPad: Record "NPRE Waiter Pad";
        SeatingManagement: Codeunit "NPRE Seating Management";
        WaiterPadManagement: Codeunit "NPRE Waiter Pad Management";
        ChosenSeatingCode: Code[10];
    begin
        //Called from Waiter pad card - with UI to chose a waiter pad and merge current waiter pad into it
        ChosenSeatingCode := SeatingManagement.UILookUpSeating('', '');
        if ChosenSeatingCode = '' then
            exit;
        Seating.Get(ChosenSeatingCode);

        if not WaiterPadExistsForSeating(Seating.Code) then
            Error(ERRNoPadForSeating, Seating.Description);

        GetWaiterPadForSeating(Seating.Code, MergeToWaiterPad);

        if MergeToWaiterPad.Count = 0 then
            exit;

        if MergeToWaiterPad.Count > 1 then begin
            if not UILookUpWaiterPad(MergeToWaiterPad) then
                exit;
        end;

        if WaiterPad."No." = MergeToWaiterPad."No." then
            Error(ERRMergeToSelf);

        if not Confirm(StrSubstNo(CFRM_Merge, WaiterPad."No.", WaiterPad.Description, MergeToWaiterPad."No.", MergeToWaiterPad.Description), true) then
            exit;

        if WaiterPadManagement.MergeWaiterPad(WaiterPad, MergeToWaiterPad) then begin
            WaiterPad.Get(MergeToWaiterPad."No.");
            if Confirm(StrSubstNo(TXTMerged, MergeToWaiterPad."No.", MergeToWaiterPad.Description), true) then;
            exit(true);
        end;
    end;

    procedure FindSeating(JSON: Codeunit "POS JSON Management"; var NPRESeating: Record "NPRE Seating")
    var
        SeatingCode: Code[10];
        LocationFilter: Text;
        SeatingFilter: Text;
    begin
        SeatingCode := GetSeatingCode(JSON);
        NPRESeating.Get(SeatingCode);

        if not JSON.SetScope('parameters', false) then
            exit;

        SeatingFilter := JSON.GetString('SeatingFilter', false);
        LocationFilter := JSON.GetString('LocationFilter', false);
        if (SeatingFilter <> '') or (LocationFilter <> '') then begin
            NPRESeating.SetRecFilter;
            NPRESeating.FilterGroup(2);
            NPRESeating.SetFilter(Code, SeatingFilter);
            NPRESeating.SetFilter("Seating Location", LocationFilter);
            NPRESeating.FindFirst;
        end;
    end;

    local procedure GetSeatingCode(JSON: Codeunit "POS JSON Management") SeatingCode: Code[10]
    var
        SeatingManagement: Codeunit "NPRE Seating Management";
        SeatingFilter: Text;
        LocationFilter: Text;
        NPRESeating: Record "NPRE Seating";
    begin
        SeatingCode := CopyStr(UpperCase(JSON.GetString('seatingCode', false)), 1, MaxStrLen(SeatingCode));
        if SeatingCode <> '' then
            exit(SeatingCode);

        JSON.SetScope('/', true);
        JSON.SetScope('parameters', true);
        if JSON.GetInteger('InputType', true) <> 2 then
            exit('');

        if JSON.GetBoolean('ShowOnlyActiveWaiPad', false) then begin
            NPRESeating.SetAutoCalcFields("Current Waiter Pad FF");
            NPRESeating.SetFilter("Current Waiter Pad FF", '<>%1', '');
            SeatingManagement.SetAddSeatingFilters(NPRESeating);
        end;
        SeatingFilter := JSON.GetString('SeatingFilter', true);
        LocationFilter := JSON.GetString('LocationFilter', true);
        SeatingCode := SeatingManagement.UILookUpSeating(SeatingFilter, LocationFilter);
        exit(SeatingCode);
    end;

    procedure SelectWaiterPad(NPRESeating: Record "NPRE Seating"; var NPREWaiterPad: Record "NPRE Waiter Pad"): Boolean
    var
        NPRESeatingWaiterPadLink: Record "NPRE Seating - Waiter Pad Link";
        TempNPREWaiterPad: Record "NPRE Waiter Pad" temporary;
    begin
        NPRESeatingWaiterPadLink.SetRange("Seating Code", NPRESeating.Code);
        if NPRESeatingWaiterPadLink.IsEmpty then
            Error(ERRNoPadForSeating, NPRESeating.Code);

        NPRESeatingWaiterPadLink.FindSet;
        repeat
            if NPREWaiterPad.Get(NPRESeatingWaiterPadLink."Waiter Pad No.") then begin
                TempNPREWaiterPad.Init;
                TempNPREWaiterPad := NPREWaiterPad;
                TempNPREWaiterPad.Insert;
            end;
        until NPRESeatingWaiterPadLink.Next = 0;

        TempNPREWaiterPad.FindLast;
        NPREWaiterPad."No." := TempNPREWaiterPad."No.";

        TempNPREWaiterPad.FindFirst;
        if NPREWaiterPad."No." <> TempNPREWaiterPad."No." then begin
            if PAGE.RunModal(0, TempNPREWaiterPad) <> ACTION::LookupOK then begin
                Clear(NPREWaiterPad);
                exit(false);
            end;
        end;

        NPREWaiterPad.Get(TempNPREWaiterPad."No.");
        exit(true);
    end;

    local procedure CleanupWaiterPad(WaiterPad: Record "NPRE Waiter Pad")
    var
        WaiterPadLine: Record "NPRE Waiter Pad Line";
        POSInfoWaiterPadLink: Record "POS Info NPRE Waiter Pad";
    begin
        //-NPR5.53 [373792]
        WaiterPadLine.Reset;
        WaiterPadLine.SetRange("Waiter Pad No.",WaiterPad."No.");
        WaiterPadLine.SetFilter(Type,'<>%1',WaiterPadLine.Type::Comment);
        if not WaiterPadLine.IsEmpty then
          exit;

        WaiterPadLine.SetRange(Type,WaiterPadLine.Type::Comment);
        if not WaiterPadLine.IsEmpty then
          WaiterPadLine.DeleteAll(true);
        //+NPR5.53 [373792]

        //-NPR5.53 [376538]
        POSInfoWaiterPadLink.SetRange("Waiter Pad No.",WaiterPad."No.");
        POSInfoWaiterPadLink.DeleteAll;
        //+NPR5.53 [376538]
    end;

    local procedure CopyPOSInfo(SaleLinePOS: Record "Sale Line POS";WaiterPadNo: Code[20];WaiterPadLineNo: Integer;ToWaiterPad: Boolean)
    var
        POSInfoWaiterPadLink: Record "POS Info NPRE Waiter Pad";
        POSInfoTransaction: Record "POS Info Transaction";
    begin
        //-NPR5.53 [376538]
        POSInfoTransaction.SetRange("Register No.",SaleLinePOS."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
        POSInfoTransaction.SetRange("Sales Line No.",SaleLinePOS."Line No.");
        if ToWaiterPad then begin
          if POSInfoTransaction.FindSet then
            repeat
              POSInfoWaiterPadLink.Init;
              POSInfoWaiterPadLink."Waiter Pad No." := WaiterPadNo;
              POSInfoWaiterPadLink."Waiter Pad Line No." := WaiterPadLineNo;
              POSInfoWaiterPadLink."POS Info Code" := POSInfoTransaction."POS Info Code";
              if not POSInfoWaiterPadLink.Find then
                POSInfoWaiterPadLink.Insert;
              POSInfoWaiterPadLink."POS Info" := POSInfoTransaction."POS Info";
              POSInfoWaiterPadLink.Modify;
            until POSInfoTransaction.Next = 0;

        end else begin
          POSInfoTransaction.DeleteAll;

          POSInfoWaiterPadLink.SetRange("Waiter Pad No.",WaiterPadNo);
          POSInfoWaiterPadLink.SetRange("Waiter Pad Line No.",WaiterPadLineNo);
          if POSInfoWaiterPadLink.FindSet then
            repeat
              POSInfoTransaction.SetRange("POS Info Code",POSInfoWaiterPadLink."POS Info Code");
              if POSInfoTransaction.FindFirst then begin
                POSInfoTransaction."POS Info" := POSInfoWaiterPadLink."POS Info";
                POSInfoTransaction.Modify;
              end else begin
                POSInfoTransaction.Init;
                POSInfoTransaction."Register No." := SaleLinePOS."Register No.";
                POSInfoTransaction."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
                POSInfoTransaction."Sales Line No." := SaleLinePOS."Line No.";
                POSInfoTransaction."Sale Date" := SaleLinePOS.Date;
                POSInfoTransaction."Receipt Type" := SaleLinePOS.Type;
                POSInfoTransaction."Entry No." := 0;
                POSInfoTransaction."POS Info Code" := POSInfoWaiterPadLink."POS Info Code";
                POSInfoTransaction."POS Info" := POSInfoWaiterPadLink."POS Info";
                POSInfoTransaction.Insert(true);
              end;
            until POSInfoWaiterPadLink.Next = 0;
        end;
        //+NPR5.53 [376538]
    end;

    local procedure CopySaleHdrPOSInfo(RegisterNo: Code[10];SalesTicketNo: Code[20];WaiterPadNo: Code[20];ToWaiterPad: Boolean)
    var
        SaleLinePOS: Record "Sale Line POS";
    begin
        //-NPR5.53 [376538]
        SaleLinePOS."Register No." := RegisterNo;
        SaleLinePOS."Sales Ticket No." := SalesTicketNo;
        SaleLinePOS."Line No." := 0;
        CopyPOSInfo(SaleLinePOS,WaiterPadNo,0,ToWaiterPad);
        //+NPR5.53 [376538]
    end;

    procedure ClearSaleHdrNPREPresetFields(var SalePOS: Record "Sale POS";ModifyRec: Boolean)
    begin
        //-NPR5.53 [380609]
        SalePOS."NPRE Number of Guests" := 0;
        SalePOS."NPRE Pre-Set Seating Code" := '';
        SalePOS."NPRE Pre-Set Waiter Pad No." := '';
        if ModifyRec then
          SalePOS.Modify;
        //+NPR5.53 [380609]
    end;

    local procedure UpdateNoOfGuests(var WaiterPad: Record "NPRE Waiter Pad";RegisterNo: Code[10];SalesTicketNo: Code[20];NumberOfGuests: Integer)
    var
        SalePOS: Record "Sale POS";
    begin
        //-NPR5.53 [380918]
        if WaiterPad."Number of Guests" - WaiterPad."Billed Number of Guests" < NumberOfGuests then
          NumberOfGuests := WaiterPad."Number of Guests" - WaiterPad."Billed Number of Guests";
        if NumberOfGuests = 0 then
          exit;

        WaiterPad."Billed Number of Guests" += NumberOfGuests;
        WaiterPad.Modify;

        if SalePOS.Get(RegisterNo,SalesTicketNo) then
          UpdateSaleHdrNoOfGuests(SalePOS,true,NumberOfGuests);
        //+NPR5.53 [380918]
    end;

    procedure UpdateSaleHdrNoOfGuests(var SalePOS: Record "Sale POS";ModifyRec: Boolean;NumberOfGuests: Integer)
    begin
        //-NPR5.53 [380918]
        SalePOS."NPRE Number of Guests" += NumberOfGuests;
        if ModifyRec then
          SalePOS.Modify;
        //+NPR5.53 [380918]
    end;

    procedure AssignWPadLinePrintCategories(WaiterPadLine: Record "NPRE Waiter Pad Line";RemoveExisting: Boolean)
    var
        Item: Record Item;
        PrintCategory: Record "NPRE Print Category";
        WPadLinePrintCategory: Record "NPRE W.Pad Line Print Category";
        Handled: Boolean;
    begin
        //-NPR5.53 [360258]
        OnBeforeAssignWPadLinePrintCategories(WaiterPadLine,RemoveExisting,Handled);
        if Handled then
          exit;

        if RemoveExisting then
          ClearWPadLinePrintCategories(WaiterPadLine);

        if (WaiterPadLine.Type <> WaiterPadLine.Type::Item) or (WaiterPadLine."No." = '') then
          exit;
        if not (Item.Get(WaiterPadLine."No.") and (Item."Print Tags" <> '')) then
          exit;

        PrintCategory.SetFilter("Print Tag",ConvertStr(Item."Print Tags",',','|'));
        if PrintCategory.FindSet then
          repeat
            AddWPadLinePrintCategory(WaiterPadLine,PrintCategory);
          until PrintCategory.Next = 0;
        //+NPR5.53 [360258]
    end;

    procedure AddWPadLinePrintCategory(WaiterPadLine: Record "NPRE Waiter Pad Line";PrintCategory: Record "NPRE Print Category")
    var
        WPadLinePrintCategory: Record "NPRE W.Pad Line Print Category";
    begin
        //-NPR5.53 [360258]
        WPadLinePrintCategory.Init;
        WPadLinePrintCategory."Waiter Pad No." := WaiterPadLine."Waiter Pad No.";
        WPadLinePrintCategory."Waiter Pad Line No." := WaiterPadLine."Line No.";
        WPadLinePrintCategory."Print Category Code" := PrintCategory.Code;
        if not WPadLinePrintCategory.Find then
          WPadLinePrintCategory.Insert;
        //+NPR5.53 [360258]
    end;

    procedure ClearWPadLinePrintCategories(WaiterPadLine: Record "NPRE Waiter Pad Line")
    var
        WPadLinePrintCategory: Record "NPRE W.Pad Line Print Category";
    begin
        //-NPR5.53 [360258]
        WPadLinePrintCategory.SetRange("Waiter Pad No.",WaiterPadLine."Waiter Pad No.");
        WPadLinePrintCategory.SetRange("Waiter Pad Line No.",WaiterPadLine."Line No.");
        if not WPadLinePrintCategory.IsEmpty then
          WPadLinePrintCategory.DeleteAll(true);
        //+NPR5.53 [360258]
    end;

    [EventSubscriber(ObjectType::Table, 6150661, 'OnAfterDeleteEvent', '', true, false)]
    local procedure DeleteWPadPOSInfoLink(var Rec: Record "NPRE Waiter Pad Line";RunTrigger: Boolean)
    var
        POSInfoWaiterPadLink: Record "POS Info NPRE Waiter Pad";
    begin
        //-NPR5.53 [376538]
        with Rec do begin
          POSInfoWaiterPadLink.SetRange("Waiter Pad No.","Waiter Pad No.");
          POSInfoWaiterPadLink.SetRange("Waiter Pad Line No.","Line No.");
          if not POSInfoWaiterPadLink.IsEmpty then
            POSInfoWaiterPadLink.DeleteAll;
        end;
        //+NPR5.53 [376538]
    end;

    [IntegrationEvent(TRUE, false)]
    procedure OnBeforeAssignWPadLinePrintCategories(var WaiterPadLine: Record "NPRE Waiter Pad Line";RemoveExisting: Boolean;var Handled: Boolean)
    begin
        //NPR5.53 [378585]
    end;

    [IntegrationEvent(TRUE, false)]
    procedure OnAfterMoveSaleFromPosToWaiterPad(var WaiterPad: Record "NPRE Waiter Pad";var WaiterPadLine: Record "NPRE Waiter Pad Line")
    begin
        //NPR5.53 [380609]
    end;
}

