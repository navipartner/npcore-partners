codeunit 6150660 "NPRE Waiter Pad POS Management"
{
    // NPR5.34/ANEN/20170712  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.35/ANEN/20170821  CASE 283376 Solution rename to NP Restaurant
    // NPR5.41/THRO/20180412  CASE 309869 Filter parameters in SeatingLookup
    // NPR5.42/MMV /20180524  CASE 315838 Properly delete sale lines.
    // NPR5.45/MHA /20180827  CASE 318369 Added functions FindSeating(),GetSeatingCode(),SelectWaiterPad() and cleaned up code syntax
    // NPR5.50/TJ  /20190528  CASE 346384 New parameter for showing only active waiterpad on seatings


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

    procedure SplitBill(WaiterPad: Record "NPRE Waiter Pad";POSSaleLine: Codeunit "POS Sale Line")
    var
        TMPWaiterPadLine: Record "NPRE Waiter Pad Line" temporary;
        ChoosenWaiterPadLine: Record "NPRE Waiter Pad Line";
        SaleLinePOS: Record "Sale Line POS";
        DeleteWPLine: Boolean;
    begin
        if not UIShowWaiterPadSplitBilForm(WaiterPad, TMPWaiterPadLine) then
          exit;

        TMPWaiterPadLine.SetFilter(Marked, '=%1', true);
        TMPWaiterPadLine.SetFilter("Marked Qty", '<>%1', 0);
        if TMPWaiterPadLine.IsEmpty then
          exit;

        TMPWaiterPadLine.FindFirst;
        repeat
          ChoosenWaiterPadLine.Get(TMPWaiterPadLine."Waiter Pad No.", TMPWaiterPadLine."Line No.");
          POSSaleLine.GetNewSaleLine(SaleLinePOS);

          //-NPR5.45 [318369]
          // IF TMPWaiterPadLine.Quantity = TMPWaiterPadLine."Marked Qty" THEN BEGIN
          //  DeleteWPLine := TRUE;
          // END ELSE BEGIN
          //  DeleteWPLine := FALSE;
          // END;
          DeleteWPLine := TMPWaiterPadLine.Quantity = TMPWaiterPadLine."Marked Qty";
          //+NPR5.45 [318369]
          MoveSaleLineFromWaiterPadToPOS(SaleLinePOS, ChoosenWaiterPadLine, DeleteWPLine, POSSaleLine);

          POSSaleLine.SetQuantity(TMPWaiterPadLine."Marked Qty");

          if TMPWaiterPadLine.Quantity <> TMPWaiterPadLine."Marked Qty" then begin
            ChoosenWaiterPadLine.Quantity := ChoosenWaiterPadLine.Quantity - TMPWaiterPadLine."Marked Qty";
            ChoosenWaiterPadLine.Modify;
          end;
        until (0 = TMPWaiterPadLine.Next);

        CloseWaiterPad(WaiterPad);
    end;

    procedure MoveSaleFromPOSToWaiterPad(SalePOS: Record "Sale POS";WaiterPad: Record "NPRE Waiter Pad")
    var
        SaleLinePOS: Record "Sale Line POS";
        NPHHospitalityPrint: Codeunit "NPRE Restaurant Print";
    begin
        SaleLinePOS.Reset;
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SalePOS.Date);
        SaleLinePOS.SetRange("Sale Type", SalePOS."Sale type");
        //-NPR5.42 [315838]
        // IF SaleLinePOS.ISEMPTY THEN EXIT;
        // SaleLinePOS.FINDFIRST;
        // REPEAT
        //  MoveSaleLineFromPOSToWaiterPad(SaleLinePOS, WaiterPad);
        // UNTIL (SaleLinePOS.NEXT = 0);
        if not SaleLinePOS.FindSet(true) then
          exit;

        repeat
          MoveSaleLineFromPOSToWaiterPad(SaleLinePOS, WaiterPad);
          SaleLinePOS.Delete(true);
        until SaleLinePOS.Next = 0;
        //+NPR5.42 [315838]

        NPHHospitalityPrint.LinesAddedToWaiterPad(WaiterPad);
    end;

    local procedure MoveSaleLineFromPOSToWaiterPad(SaleLinePOS: Record "Sale Line POS";WaiterPad: Record "NPRE Waiter Pad")
    var
        WaiterPadLine: Record "NPRE Waiter Pad Line";
        Item: Record Item;
        NPHPrintCategory: Record "NPRE Print Category";
    begin
        WaiterPadLine.Init;
        WaiterPadLine."Waiter Pad No." := WaiterPad."No.";
        WaiterPadLine."Register No." := SaleLinePOS."Register No.";
        WaiterPadLine."Start Date" := Today;
        WaiterPadLine."Start Time" :=  Time;

        WaiterPadLine.Type                        := SaleLinePOS.Type;
        WaiterPadLine."Sale Type"                 := SaleLinePOS."Sale Type";
        WaiterPadLine.Description                 := SaleLinePOS.Description;
        WaiterPadLine."No."                       := SaleLinePOS."No.";
        WaiterPadLine."Description 2"             := SaleLinePOS."Description 2";
        WaiterPadLine."Variant Code"              := SaleLinePOS."Variant Code";
        WaiterPadLine."Order No. from Web"        := SaleLinePOS."Order No. from Web";
        WaiterPadLine."Order Line No. from Web"   := SaleLinePOS."Order Line No. from Web";
        WaiterPadLine."Unit of Measure Code"      := SaleLinePOS."Unit of Measure Code";
        WaiterPadLine.Quantity                    := SaleLinePOS.Quantity;
        WaiterPadLine."Unit Price"                := SaleLinePOS."Unit Price";
        WaiterPadLine."Discount Type"             := SaleLinePOS."Discount Type";
        WaiterPadLine."Discount Code"             := SaleLinePOS."Discount Code";
        WaiterPadLine."Allow Line Discount"       := SaleLinePOS."Allow Line Discount";
        WaiterPadLine."Discount %"                := SaleLinePOS."Discount %";
        WaiterPadLine."Discount Amount"           := SaleLinePOS."Discount Amount";
        WaiterPadLine."Allow Invoice Discount"    := SaleLinePOS."Allow Invoice Discount";
        WaiterPadLine."Invoice Discount Amount"   := SaleLinePOS."Invoice Discount Amount";
        WaiterPadLine."Amount Excl. VAT"          := SaleLinePOS.Amount;
        WaiterPadLine."Amount Incl. VAT"          := SaleLinePOS."Amount Including VAT";

        //-NPR5.42 [315838]
        // IF POSSaleLine.SetPosition(SaleLinePOS.GETPOSITION) THEN BEGIN
        //  WaiterPadLine.INSERT(TRUE);
        //  POSSaleLine.DeleteLine();
        // END;
        WaiterPadLine.Insert(true);
        //+NPR5.42 [315838]

        if WaiterPadLine.Type = WaiterPadLine.Type::Item then begin
          if Item.Get(WaiterPadLine."No.") then begin
            if Item."Print Tags" <> '' then begin
              NPHPrintCategory.Reset;
              NPHPrintCategory.SetFilter("Print Tag", '=%1', Item."Print Tags");
              if NPHPrintCategory.FindFirst then begin
                WaiterPadLine."Print Category" := NPHPrintCategory.Code;
                WaiterPadLine.Modify;
              end;
            end;
          end;
        end;
    end;

    procedure MoveSaleFromWaiterPadToPOS(WaiterPad: Record "NPRE Waiter Pad";POSSaleLine: Codeunit "POS Sale Line")
    var
        SaleLinePOS: Record "Sale Line POS";
        WaiterPadLine: Record "NPRE Waiter Pad Line";
    begin
        WaiterPadLine.Reset;
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        //-NPR5.45 [318369]
        //IF WaiterPadLine.ISEMPTY THEN EXIT;
        if WaiterPadLine.IsEmpty then begin
          CloseWaiterPad(WaiterPad);
          exit;
        end;
        //+NPR5.45 [318369]

        WaiterPadLine.FindSet(true, false);
        repeat
          POSSaleLine.GetNewSaleLine(SaleLinePOS);
          MoveSaleLineFromWaiterPadToPOS(SaleLinePOS, WaiterPadLine, true, POSSaleLine);
        until (0 = WaiterPadLine.Next);

        CloseWaiterPad(WaiterPad);
    end;

    local procedure MoveSaleLineFromWaiterPadToPOS(var SaleLinePOS: Record "Sale Line POS";WaiterPadLine: Record "NPRE Waiter Pad Line";DeleteWaiterPadLine: Boolean;var POSSaleLine: Codeunit "POS Sale Line")
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

        SaleLinePOS."Discount Type" := WaiterPadLine."Discount Type";
        SaleLinePOS."Discount Code" := WaiterPadLine."Discount Code";

        SaleLinePOS."Allow Line Discount" := WaiterPadLine."Allow Line Discount";
        SaleLinePOS."Allow Invoice Discount" := WaiterPadLine."Allow Invoice Discount";

        SaleLinePOS."Discount %" := WaiterPadLine."Discount %";
        SaleLinePOS."Invoice Discount Amount" := WaiterPadLine."Invoice Discount Amount";

        POSSaleLine.InsertLine(SaleLinePOS);

        if DeleteWaiterPadLine then
          WaiterPadLine.Delete;
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

    local procedure GetWaiterPadForSeating(SeatingCode: Code[20];var WaiterPad: Record "NPRE Waiter Pad")
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

    procedure AddNewWaiterPadForSeating(SeatingCode: Code[10];var WaiterPad: Record "NPRE Waiter Pad";var SeatingWaiterPadLink: Record "NPRE Seating - Waiter Pad Link") OK: Boolean
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

    local procedure UIShowWaiterPadSplitBilForm(WaiterPad: Record "NPRE Waiter Pad";var TMPWaiterPadLine: Record "NPRE Waiter Pad Line" temporary) OK: Boolean
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

    procedure GetQtyUI(OrgQty: Decimal;Description: Text;var ioChosenQty: Decimal) OK: Boolean
    var
        Marshaller: Codeunit "POS Event Marshaller";
    begin
        //Used by page [Tmp POS Waiter Pad Lines] to chose a qty from a total qty
        //Shall show numpad
        ioChosenQty := OrgQty;
        if not Marshaller.NumPad((StrSubstNo(TXTQtyToMove, Description, OrgQty)),ioChosenQty,false,false) then
          exit(false);

        exit(true);
    end;

    procedure MoveWaiterPadToNewSeatingUI(var WaiterPad: Record "NPRE Waiter Pad")
    var
        Seating: Record "NPRE Seating";
        SeatingManagement: Codeunit "NPRE Seating Management";
        WaiterPadManagement: Codeunit "NPRE Waiter Pad Management";
    begin
        //Called from Waiter pad page -  with UI used to change seating on waiter pad
        //-NPR5.41 [309869]
        Seating.Get(SeatingManagement.UILookUpSeating('',''));
        //+NPR5.41 [309869]

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
        //-NPR5.41 [309869]
        ChosenSeatingCode := SeatingManagement.UILookUpSeating('','');
        //+NPR5.41 [309869]
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

    procedure FindSeating(JSON: Codeunit "POS JSON Management";var NPRESeating: Record "NPRE Seating")
    var
        SeatingCode: Code[10];
        LocationFilter: Text;
        SeatingFilter: Text;
    begin
        //-NPR5.45 [318369]
        SeatingCode := GetSeatingCode(JSON);
        NPRESeating.Get(SeatingCode);

        if not JSON.SetScope('parameters',false) then
          exit;

        SeatingFilter := JSON.GetString('SeatingFilter',false);
        LocationFilter := JSON.GetString('LocationFilter',false);
        if (SeatingFilter <> '') or (LocationFilter <> '') then begin
          NPRESeating.SetRecFilter;
          NPRESeating.FilterGroup(2);
          NPRESeating.SetFilter(Code,SeatingFilter);
          NPRESeating.SetFilter("Seating Location",LocationFilter);
          NPRESeating.FindFirst;
        end;
        //+NPR5.45 [318369]
    end;

    local procedure GetSeatingCode(JSON: Codeunit "POS JSON Management") SeatingCode: Code[10]
    var
        SeatingManagement: Codeunit "NPRE Seating Management";
        SeatingFilter: Text;
        LocationFilter: Text;
        NPRESeating: Record "NPRE Seating";
    begin
        //-NPR5.45 [318369]
        SeatingCode := CopyStr(UpperCase(JSON.GetString('seatingCode',false)),1,MaxStrLen(SeatingCode));
        if SeatingCode <> '' then
          exit(SeatingCode);

        JSON.SetScope('/',true);
        JSON.SetScope('parameters',true);
        if JSON.GetInteger('InputType',true) <> 2 then
          exit('');

        //-NPR5.50 [346384]
        if JSON.GetBoolean('ShowOnlyActiveWaiPad',false) then begin
          NPRESeating.SetAutoCalcFields("Current Waiter Pad FF");
          NPRESeating.SetFilter("Current Waiter Pad FF",'<>%1','');
          SeatingManagement.SetAddSeatingFilters(NPRESeating);
        end;
        //+NPR5.50 [346384]
        SeatingFilter := JSON.GetString('SeatingFilter',true);
        LocationFilter := JSON.GetString('LocationFilter',true);
        SeatingCode := SeatingManagement.UILookUpSeating(SeatingFilter,LocationFilter);
        exit(SeatingCode);
        //+NPR5.45 [318369]
    end;

    procedure SelectWaiterPad(NPRESeating: Record "NPRE Seating";var NPREWaiterPad: Record "NPRE Waiter Pad"): Boolean
    var
        NPRESeatingWaiterPadLink: Record "NPRE Seating - Waiter Pad Link";
        TempNPREWaiterPad: Record "NPRE Waiter Pad" temporary;
    begin
        //-NPR5.45 [318369]
        NPRESeatingWaiterPadLink.SetRange("Seating Code",NPRESeating.Code);
        if NPRESeatingWaiterPadLink.IsEmpty then
          Error(ERRNoPadForSeating,NPRESeating.Code);

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
          if PAGE.RunModal(0,TempNPREWaiterPad) <> ACTION::LookupOK then begin
            Clear(NPREWaiterPad);
            exit(false);
          end;
        end;

        NPREWaiterPad.Get(TempNPREWaiterPad."No.");
        exit(true);
        //+NPR5.45 [318369]
    end;
}

