codeunit 6150640 "NPR POS Info Management"
{
    Access = Internal;

    var
        TempGlobalPOSInfoTransaction: Record "NPR POS Info Transaction" temporary;
        ApplicScope: Option " ","Current Line","All Lines","New Lines",Ask;

    procedure CollectPOSInfo(var Rec: Record "NPR POS Sale Line")
    var
        POSInfoLinkTable: Record "NPR POS Info Link Table";
    begin
        if Rec.IsTemporary then
            exit;
        if Rec."Line Type" = Rec."Line Type"::Item then begin
            POSInfoLinkTable.Reset();
            POSInfoLinkTable.SetRange("Table ID", DATABASE::Item);
            POSInfoLinkTable.SetRange("Primary Key", Rec."No.");
            // Collect POS info data with RunModal pages (outside transaction)
            CollectPOSInfoData(POSInfoLinkTable, Rec, ApplicScope::"Current Line");
        end;
    end;

    procedure ApplyPOSInfo(var Rec: Record "NPR POS Sale Line")
    var
        POSInfoTransaction: Record "NPR POS Info Transaction";
    begin
        if Rec.IsTemporary then
            exit;
        if Rec."Line Type" = Rec."Line Type"::Item then begin
            // Apply collected data transactionally
            ApplyCollectedPOSInfoData(Rec, ApplicScope::"Current Line");
        end;
        CopyPOSInfoTransFromHeader(Rec, POSInfoTransaction);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sale", 'OnBeforeValidateEvent', 'Customer No.', false, false)]
    local procedure OnBeforeValidateCustomerNoSalePos(var Rec: Record "NPR POS Sale")
    var
        Customer: Record Customer;
        POSInfoLinkTable: Record "NPR POS Info Link Table";
        pSaleLinePos: Record "NPR POS Sale Line";
    begin
        if Rec.IsTemporary then
            exit;
        if Rec."Customer No." <> '' then begin
            Customer.Get(Rec."Customer No.");
            Customer.CalcFields("Balance (LCY)");
        end else
            Clear(Customer);
        POSInfoLinkTable.Reset();
        POSInfoLinkTable.SetRange("Table ID", DATABASE::Customer);
        POSInfoLinkTable.SetRange("Primary Key", Rec."Customer No.");
        Case true of
            Customer."Balance (LCY)" > 0:
                POSInfoLinkTable.SetFilter("When to Use", '%1|%2', POSInfoLinkTable."When to Use"::Always, POSInfoLinkTable."When to Use"::Positive);
            Customer."Balance (LCY)" < 0:
                POSInfoLinkTable.SetFilter("When to Use", '%1|%2', POSInfoLinkTable."When to Use"::Always, POSInfoLinkTable."When to Use"::Negative);
            Customer."Balance (LCY)" = 0:
                POSInfoLinkTable.SetRange("When to Use", POSInfoLinkTable."When to Use"::Always);
        end;

        pSaleLinePos.Init();
        pSaleLinePos."Register No." := Rec."Register No.";
        pSaleLinePos."Sales Ticket No." := Rec."Sales Ticket No.";
        pSaleLinePos.Date := Rec.Date;
        pSaleLinePos."Line No." := 0;

        CollectPOSInfoData(POSInfoLinkTable, pSaleLinePos, ApplicScope::"All Lines");
        ApplyCollectedPOSInfoData(pSaleLinePos, ApplicScope::"All Lines");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Create Entry", 'OnAfterInsertPOSEntry', '', true, true)]
    local procedure OnAfterInsertPOSEntry(var SalePOS: Record "NPR POS Sale"; var POSEntry: Record "NPR POS Entry")
    var
        POSInfoTransaction: Record "NPR POS Info Transaction";
        POSInfoPOSEntry: Record "NPR POS Info POS Entry";
    begin
        POSInfoTransaction.SetCurrentKey("Register No.", "Sales Ticket No.", "Sales Line No.");
        POSInfoTransaction.SetRange("Register No.", SalePOS."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if POSInfoTransaction.FindSet() then
            repeat
                UpdatePOSInfoTransaction(POSInfoTransaction);
                POSInfoPOSEntry.Init();
                POSInfoPOSEntry."POS Entry No." := POSEntry."Entry No.";
                POSInfoPOSEntry."POS Info Code" := POSInfoTransaction."POS Info Code";
                POSInfoPOSEntry."Entry No." := POSInfoTransaction."Entry No.";
                POSInfoPOSEntry.TransferFields(POSInfoTransaction, false);
                POSInfoPOSEntry."POS Unit No." := POSEntry."POS Unit No.";
                POSInfoPOSEntry."Salesperson Code" := POSEntry."Salesperson Code";
                POSInfoPOSEntry.Insert();
            until POSInfoTransaction.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sale", 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterDeleteSalePOS(var Rec: Record "NPR POS Sale"; RunTrigger: Boolean)
    var
        POSInfoTransaction: Record "NPR POS Info Transaction";
        POSSaleMediaInfo: Record "NPR POS Sale Media Info";
    begin
        if Rec.IsTemporary then
            exit;
        POSInfoTransaction.SetCurrentKey("Register No.", "Sales Ticket No.", "Sales Line No.");
        POSInfoTransaction.SetRange("Register No.", Rec."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.", Rec."Sales Ticket No.");
        POSInfoTransaction.SetRange("Sales Line No.", 0);
        if not POSInfoTransaction.IsEmpty() then
            POSInfoTransaction.DeleteAll();

        POSSaleMediaInfo.DeleteEntriesForPosSale(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sale Line", 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterDeleteSaleLinePOS(var Rec: Record "NPR POS Sale Line"; RunTrigger: Boolean)
    begin
        DeleteLine(Rec);
    end;

    local procedure CollectPOSInfoData(var POSInfoLinkTable: Record "NPR POS Info Link Table"; pSaleLinePos: Record "NPR POS Sale Line"; pApplicScope: Option " ","Current Line","All Lines","New Lines",Ask)
    var
        POSInfo: Record "NPR POS Info";
        UserInputString: Text;
    begin
        // Clear any previous data
        TempGlobalPOSInfoTransaction.Reset();
        TempGlobalPOSInfoTransaction.DeleteAll();

        // Collect POS info data by running modal pages (no commit needed here)
        if POSInfoLinkTable.FindSet() then
            repeat
                POSInfo.Get(POSInfoLinkTable."POS Info Code");
                if ConfirmPOSInfoTransOverwrite(pSaleLinePos, POSInfo, pApplicScope, true) then begin
                    TempGlobalPOSInfoTransaction.Init();
                    TempGlobalPOSInfoTransaction.CopyFromPOSInfo(POSInfo);
                    TempGlobalPOSInfoTransaction."POS Info" := CopyStr(GetPosInfoOutput(POSInfo, UserInputString), 1, MaxStrLen(TempGlobalPOSInfoTransaction."POS Info"));
                    TempGlobalPOSInfoTransaction.Insert();
                end;
            until POSInfoLinkTable.Next() = 0;
    end;

    local procedure ApplyCollectedPOSInfoData(pSaleLinePos: Record "NPR POS Sale Line"; pApplicScope: Option " ","Current Line","All Lines","New Lines",Ask) FrontEndUpdateIsNeeded: Boolean
    begin
        // Apply the collected POS info data transactionally
        FrontEndUpdateIsNeeded := false;
        if TempGlobalPOSInfoTransaction.FindSet() then
            repeat
                TempGlobalPOSInfoTransaction.ShowMessage();
                if SaleLineApplyPOSInfo(pSaleLinePos, TempGlobalPOSInfoTransaction, pApplicScope, false) then
                    FrontEndUpdateIsNeeded := true;
            until TempGlobalPOSInfoTransaction.Next() = 0;
    end;

    procedure ProcessPOSInfoMenuFunction(pSaleLinePos: Record "NPR POS Sale Line"; pPOSInfoCode: Code[20]; pApplicScope: Option " ","Current Line","All Lines","New Lines",Ask; pClearInfo: Boolean; UserInputString: Text): Boolean
    var
        POSInfo: Record "NPR POS Info";
        POSInfoTransParam: Record "NPR POS Info Transaction";
    begin
        POSInfo.Get(pPOSInfoCode);
        CheckAndAdjustApplicationScope(pSaleLinePos, POSInfo, pApplicScope);
        if not pClearInfo then
            if not ConfirmPOSInfoTransOverwrite(pSaleLinePos, POSInfo, pApplicScope, false) then
                exit;

        POSInfoTransParam.Init();
        POSInfoTransParam.CopyFromPOSInfo(POSInfo);
        if not pClearInfo then begin
            POSInfoTransParam."POS Info" := CopyStr(GetPosInfoOutput(POSInfo, UserInputString), 1, MaxStrLen(POSInfoTransParam."POS Info"));
            POSInfoTransParam.ShowMessage();
        end;

        exit(SaleLineApplyPOSInfo(pSaleLinePos, POSInfoTransParam, pApplicScope, pClearInfo));
    end;

    local procedure CheckAndAdjustApplicationScope(pSaleLinePos: Record "NPR POS Sale Line"; POSInfo: Record "NPR POS Info"; var pApplicScope: Option " ","Current Line","All Lines","New Lines",Ask)
    var
        SaleLinePos2: Record "NPR POS Sale Line";
        DialogOptionsLbl: Label 'Current Line,All Lines,New Lines';
        SelectScopeLbl: Label 'Please select the scope POS info must be applied to';
    begin
        if pApplicScope = pApplicScope::"New Lines" then
            POSInfo.TestField("Copy from Header", true);

        SaleLinePos2.SetRange("Register No.", pSaleLinePos."Register No.");
        SaleLinePos2.SetRange("Sales Ticket No.", pSaleLinePos."Sales Ticket No.");
        SaleLinePos2.SetRange(Date, pSaleLinePos.Date);
        if SaleLinePos2.IsEmpty and (pApplicScope in [pApplicScope::" ", pApplicScope::Ask]) then
            pApplicScope := pApplicScope::"New Lines";
        if pApplicScope = pApplicScope::" " then
            pApplicScope := pApplicScope::"Current Line";

        if pApplicScope = pApplicScope::Ask then
            pApplicScope := StrMenu(DialogOptionsLbl, 1, SelectScopeLbl);
        if not (pApplicScope in [pApplicScope::"Current Line" .. pApplicScope::"New Lines"]) then
            Error('');
    end;

    local procedure ConfirmPOSInfoTransOverwrite(pSaleLinePos: Record "NPR POS Sale Line"; POSInfo: Record "NPR POS Info"; pApplicScope: Option " ","Current Line","All Lines","New Lines",Ask; CalledByPOSInfoLinks: Boolean): Boolean
    var
        POSInfoTransaction: Record "NPR POS Info Transaction";
        Confirmed: Boolean;
        ConfirmOverwriteQst: Label 'There is already a Pos Info entry of type %1 for this sale, do you want to overwrite?';
    begin
        SetPosInfoTransactionFilters(POSInfoTransaction, pSaleLinePos, POSInfo, pApplicScope);
        Confirmed := POSInfoTransaction.IsEmpty();
        if not Confirmed then
            if not (CalledByPOSInfoLinks and POSInfo."Once per Transaction" and (pApplicScope = pApplicScope::"Current Line")) then
                Confirmed := Confirm(StrSubstNo(ConfirmOverwriteQst, POSInfo.Code), true);
        exit(Confirmed);
    end;

    local procedure SetPosInfoTransactionFilters(var POSInfoTransaction: Record "NPR POS Info Transaction"; pSaleLinePos: Record "NPR POS Sale Line"; POSInfo: Record "NPR POS Info"; pApplicScope: Option " ","Current Line","All Lines","New Lines",Ask)
    begin
        POSInfoTransaction.SetRange("POS Info Code", POSInfo.Code);
        POSInfoTransaction.SetRange("Register No.", pSaleLinePos."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.", pSaleLinePos."Sales Ticket No.");
        case true of
            not POSInfo."Once per Transaction" and (pApplicScope = pApplicScope::"Current Line"):
                POSInfoTransaction.SetRange("Sales Line No.", pSaleLinePos."Line No.");
            pApplicScope = pApplicScope::"New Lines":
                POSInfoTransaction.SetRange("Sales Line No.", 0);
            else
                POSInfoTransaction.SetRange("Sales Line No.");
        end;
    end;

    local procedure GetPosInfoOutput(POSInfo: Record "NPR POS Info"; UserInputString: Text) Info: Text
    var
        POSInfoLookupTable: Record "NPR POS Info Lookup";
        POSInfoLookupPage: Page "NPR POS Info Lookup";
        POSInfoRequestText: page "NPR POS Info: Request Text";
        RecRef: RecordRef;
    begin
        Info := '';
        case POSInfo."Type" of
            POSInfo."Type"::"Request Data":
                case POSInfo."Input Type" of
                    POSInfo."Input Type"::"Text":
                        begin
                            Info := UserInputString;
                            if Info = '' then begin
                                Clear(POSInfoRequestText);
                                POSInfoRequestText.SetRecord(POSInfo);
                                if POSInfoRequestText.RunModal() = Action::OK then
                                    Info := POSInfoRequestText.GetUserInput();

                            end;
                            if (Info = '') and POSInfo."Input Mandatory" then
                                Error('');
                        end;

                    POSInfo."Input Type"::"Table":
                        begin
                            POSInfoLookupPage.SetPOSInfo(POSInfo);
                            POSInfoLookupPage.LookupMode(true);
                            if POSInfoLookupPage.RunModal() = Action::LookupOK then begin
                                POSInfoLookupPage.GetRecord(POSInfoLookupTable);
                                RecRef.Open(POSInfo."Table No.");
                                RecRef.Get(POSInfoLookupTable.RecID);
                                Info := RecRef.GetPosition(false);
                            end;
                        end;

                    POSInfo."Input Type"::SubCode:
                        begin
                            POSInfoLookupPage.SetPOSInfo(POSInfo);
                            POSInfoLookupPage.LookupMode(true);
                            if POSInfoLookupPage.RunModal() = Action::LookupOK then begin
                                POSInfoLookupPage.GetRecord(POSInfoLookupTable);
                                Info := POSInfoLookupTable."Field 1";
                            end;
                        end;
                end;

            POSInfo."Type"::"Show Message",
            POSInfo."Type"::"Write Default Message":
                Info := POSInfo.Message;
        end;
    end;

    procedure PosInfoInputTextRequired(POSInfo: Record "NPR POS Info"): Boolean
    begin
        exit((POSInfo."Type" = POSInfo."Type"::"Request Data") and (POSInfo."Input Type" = POSInfo."Input Type"::"Text"));
    end;

    local procedure SaleLineApplyPOSInfo(pSaleLinePos: Record "NPR POS Sale Line"; POSInfoTransParam: Record "NPR POS Info Transaction"; pApplicScope: Option " ","Current Line","All Lines","New Lines",Ask; pClearInfo: Boolean) FrontEndUpdateIsNeeded: Boolean
    var
        POSInfo: Record "NPR POS Info";
        POSInfoTransaction: Record "NPR POS Info Transaction";
        SaleLinePos2: Record "NPR POS Sale Line";
        TempSaleLinePos: Record "NPR POS Sale Line" temporary;
    begin
        FrontEndUpdateIsNeeded := false;
        if not POSInfoTransParam."Once per Transaction" and (pApplicScope in [pApplicScope::"Current Line", pApplicScope::"All Lines"]) then begin
            SaleLinePos2.SetRange("Register No.", pSaleLinePos."Register No.");
            SaleLinePos2.SetRange("Sales Ticket No.", pSaleLinePos."Sales Ticket No.");
            SaleLinePos2.SetRange(Date, pSaleLinePos.Date);
            if pApplicScope = pApplicScope::"Current Line" then
                SaleLinePos2.SetRange("Line No.", pSaleLinePos."Line No.");
            if SaleLinePos2.FindSet() then begin
                repeat
                    TempSaleLinePos := SaleLinePos2;
                    TempSaleLinePos.Insert();
                until SaleLinePos2.Next() = 0;
            end else
                if (pApplicScope = pApplicScope::"Current Line") and (pSaleLinePos."Line No." <> 0) then
                    InsertTempSaleLine(TempSaleLinePos, pSaleLinePos, pSaleLinePos."Line No.");
        end;
        if POSInfoTransParam."Once per Transaction" or (pApplicScope in [pApplicScope::"All Lines", pApplicScope::"New Lines"]) then
            InsertTempSaleLine(TempSaleLinePos, pSaleLinePos, 0);

        POSInfo.Get(POSInfoTransParam."POS Info Code");
        SetPosInfoTransactionFilters(POSInfoTransaction, pSaleLinePos, POSInfo, pApplicScope);
        if TempSaleLinePos.FindSet() then
            repeat
                POSInfoTransaction.SetRange("Sales Line No.", TempSaleLinePos."Line No.");
                if POSInfoTransaction.FindFirst() then begin
                    if pClearInfo then
                        POSInfoTransaction.Delete()
                    else begin
                        POSInfoTransaction."POS Info" := POSInfoTransParam."POS Info";
                        POSInfoTransaction.Modify();
                    end;
                    FrontEndUpdateIsNeeded := true;
                end else
                    if not pClearInfo then begin
                        POSInfoTransaction.Init();
                        POSInfoTransaction."Register No." := TempSaleLinePos."Register No.";
                        POSInfoTransaction."Sales Ticket No." := TempSaleLinePos."Sales Ticket No.";
                        POSInfoTransaction."Sales Line No." := TempSaleLinePos."Line No.";
                        POSInfoTransaction."Sale Date" := TempSaleLinePos.Date;
                        POSInfoTransaction."Line Type" := TempSaleLinePos."Line Type";
                        POSInfoTransaction."Entry No." := 0;
                        POSInfoTransaction."POS Info Code" := POSInfoTransParam."POS Info Code";
                        POSInfoTransaction."POS Info" := POSInfoTransParam."POS Info";
                        POSInfoTransaction."POS Info Type" := POSInfoTransParam."POS Info Type";
                        POSInfoTransaction."Once per Transaction" := POSInfoTransParam."Once per Transaction";
                        POSInfoTransaction.Insert(true);
                        FrontEndUpdateIsNeeded := true;
                    end;
            until TempSaleLinePos.Next() = 0;
    end;

    local procedure InsertTempSaleLine(var ToSaleLinePos: Record "NPR POS Sale Line"; pSaleLinePos: Record "NPR POS Sale Line"; LineNo: Integer)
    begin
        if not ToSaleLinePos.IsTemporary then
            Exit;

        ToSaleLinePos.Init();
        ToSaleLinePos."Register No." := pSaleLinePos."Register No.";
        ToSaleLinePos."Sales Ticket No." := pSaleLinePos."Sales Ticket No.";
        ToSaleLinePos.Date := pSaleLinePos.Date;
        ToSaleLinePos."Line Type" := ToSaleLinePos."Line Type"::Item;
        ToSaleLinePos."Line No." := LineNo;
        ToSaleLinePos.Insert();
    end;

    procedure DeleteLine(var SaleLinePOS: Record "NPR POS Sale Line")
    var
        POSInfoTransaction: Record "NPR POS Info Transaction";
    begin
        if SaleLinePOS.IsTemporary then
            exit;

        POSInfoTransaction.SetCurrentKey("Register No.", "Sales Ticket No.", "Sales Line No.");
        POSInfoTransaction.SetRange("Register No.", SaleLinePOS."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        POSInfoTransaction.SetRange("Sales Line No.", SaleLinePOS."Line No.");
        if not POSInfoTransaction.IsEmpty() then
            POSInfoTransaction.DeleteAll();
    end;

    procedure RetrieveSavedLines(ToSalePOS: Record "NPR POS Sale"; FromSalePOS: Record "NPR POS Sale")
    var
        POSInfoTransactionOld: Record "NPR POS Info Transaction";
        POSInfoTransactionNew: Record "NPR POS Info Transaction";
    begin
        POSInfoTransactionOld.SetCurrentKey("Register No.", "Sales Ticket No.", "Sales Line No.");
        POSInfoTransactionOld.SetRange("Register No.", FromSalePOS."Register No.");
        POSInfoTransactionOld.SetRange("Sales Ticket No.", FromSalePOS."Sales Ticket No.");
        if POSInfoTransactionOld.FindSet(true) then
            repeat
                POSInfoTransactionNew := POSInfoTransactionOld;
                POSInfoTransactionNew."Register No." := ToSalePOS."Register No.";
                POSInfoTransactionNew."Sales Ticket No." := ToSalePOS."Sales Ticket No.";
                POSInfoTransactionNew.Insert();
                POSInfoTransactionOld.Delete();
            until POSInfoTransactionOld.Next() = 0;
    end;

    local procedure UpdatePOSInfoTransaction(var POSInfoTransaction: Record "NPR POS Info Transaction")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", POSInfoTransaction."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", POSInfoTransaction."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, POSInfoTransaction."Sale Date");
        if POSInfoTransaction."Sales Line No." <> 0 then
            SaleLinePOS.SetRange("Line No.", POSInfoTransaction."Sales Line No.");
        if SaleLinePOS.IsEmpty() then
            exit;

        SaleLinePOS.CalcSums(Quantity, Amount, "Amount Including VAT", "Discount Amount");
        POSInfoTransaction.Quantity := POSInfoTransaction.Quantity + SaleLinePOS.Quantity;
        POSInfoTransaction."Net Amount" := POSInfoTransaction."Net Amount" + SaleLinePOS.Amount;
        POSInfoTransaction."Gross Amount" := POSInfoTransaction."Gross Amount" + SaleLinePOS."Amount Including VAT";
        POSInfoTransaction."Discount Amount" := POSInfoTransaction."Discount Amount" + SaleLinePOS."Discount Amount";

        if POSInfoTransaction."Sales Line No." <> 0 then begin
            SaleLinePOS.SetLoadFields("No.", "Unit Price");
            SaleLinePOS.FindLast();
            POSInfoTransaction."No." := SaleLinePOS."No.";
            POSInfoTransaction.Price := SaleLinePOS."Unit Price";
        end;
    end;

    procedure ProcessPOSInfoText(pSaleLinePos: Record "NPR POS Sale Line"; pSalePos: Record "NPR POS Sale"; pPOSInfoCode: Code[20]; pInfoText: Text)
    var
        POSInfo: Record "NPR POS Info";
        Info: Text[250];
        POSInfoTransaction: Record "NPR POS Info Transaction";
        InfoRequiredErr: Label 'POS Info can not be empty for POS Info Code %1.';
    begin
        Info := CopyStr(pInfoText, 1, MaxStrLen(POSInfoTransaction."POS Info"));

        POSInfo.Get(pPOSInfoCode);
        POSInfo.TestField("Input Type", POSInfo."Input Type"::Text);
        POSInfo.TestField(Type, POSInfo.Type::"Request Data");
        if (Info = '') and POSInfo."Input Mandatory" then begin
            Error(InfoRequiredErr, POSInfo.Code);
        end;

        POSInfoTransaction.SetRange("POS Info Code", pPOSInfoCode);
        POSInfoTransaction.SetRange("Register No.", pSalePos."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.", pSalePos."Sales Ticket No.");
        if not POSInfo."Once per Transaction" then begin
            POSInfoTransaction.SetRange("Sales Line No.", pSaleLinePos."Line No.")
        end else begin
            POSInfoTransaction.SetRange("Sales Line No.");
        end;

        if POSInfoTransaction.FindFirst() then begin
            POSInfoTransaction."POS Info" := Info;
            POSInfoTransaction.Modify();
        end else begin
            POSInfoTransaction.Init();
            POSInfoTransaction."Register No." := pSalePos."Register No.";
            POSInfoTransaction."Sales Ticket No." := pSalePos."Sales Ticket No.";

            if not POSInfo."Once per Transaction" then begin
                POSInfoTransaction."Sales Line No." := pSaleLinePos."Line No.";

                POSInfoTransaction."Sale Date" := pSaleLinePos.Date;
                POSInfoTransaction."Line Type" := pSaleLinePos."Line Type";
            end else begin
                POSInfoTransaction."Sale Date" := pSalePos.Date;
                POSInfoTransaction."Line Type" := pSaleLinePos."Line Type"::Comment;
            end;

            POSInfoTransaction."Entry No." := 0;
            POSInfoTransaction."POS Info Code" := POSInfo.Code;
            POSInfoTransaction."POS Info" := Info;
            POSInfoTransaction.Insert(true);
        end;
    end;

    procedure CopyPOSInfoTransFromHeader(SaleLinePos: Record "NPR POS Sale Line"; var POSInfoTransaction: Record "NPR POS Info Transaction"): Boolean
    var
        POSInfo: Record "NPR POS Info";
        POSInfoTransaction_Hdr: Record "NPR POS Info Transaction";
        Updated: Boolean;
    begin
        if not (SaleLinePos."Line Type" in [SaleLinePos."Line Type"::Item, SaleLinePos."Line Type"::"Item Category", SaleLinePos."Line Type"::"Customer Deposit", SaleLinePOS."Line Type"::"Issue Voucher", SaleLinePos."Line Type"::Comment]) then
            exit(false);

        POSInfoTransaction_Hdr.SetCurrentKey("Register No.", "Sales Ticket No.", "Sales Line No.");
        POSInfoTransaction_Hdr.SetRange("Register No.", SaleLinePos."Register No.");
        POSInfoTransaction_Hdr.SetRange("Sales Ticket No.", SaleLinePos."Sales Ticket No.");
        POSInfoTransaction_Hdr.SetRange("Sales Line No.", 0);
        POSInfoTransaction_Hdr.SetFilter("POS Info Code", '<>%1', '');
        if not POSInfoTransaction_Hdr.FindSet() then
            exit(false);

        Updated := false;
        repeat
            POSInfo.Get(POSInfoTransaction_Hdr."POS Info Code");
            if not POSInfo."Once per Transaction" and POSInfo."Copy from Header" then begin
                SaleLinePos.TestField("Line No.");  //Ensure line has been already inserted
                POSInfoTransaction.Reset();
                POSInfoTransaction.SetRange("POS Info Code", POSInfoTransaction_Hdr."POS Info Code");
                POSInfoTransaction.SetRange("Register No.", SaleLinePos."Register No.");
                POSInfoTransaction.SetRange("Sales Ticket No.", SaleLinePos."Sales Ticket No.");
                POSInfoTransaction.SetRange("Sales Line No.", SaleLinePos."Line No.");
                if POSInfoTransaction.IsEmpty then begin
                    POSInfoTransaction.Init();
                    POSInfoTransaction."Register No." := SaleLinePos."Register No.";
                    POSInfoTransaction."Sales Ticket No." := SaleLinePos."Sales Ticket No.";
                    POSInfoTransaction."Sales Line No." := SaleLinePos."Line No.";
                    POSInfoTransaction."Sale Date" := SaleLinePos.Date;
                    POSInfoTransaction."Line Type" := SaleLinePos."Line Type";
                    POSInfoTransaction."Entry No." := 0;
                    POSInfoTransaction."POS Info Code" := POSInfoTransaction_Hdr."POS Info Code";
                    POSInfoTransaction."POS Info" := POSInfoTransaction_Hdr."POS Info";
                    POSInfoTransaction.Insert(true);
                    if not Updated then
                        Updated := true;
                end;
            end;
        until POSInfoTransaction_Hdr.Next() = 0;
        POSInfoTransaction.Reset();
        exit(Updated);
    end;

    procedure CopyPOSInfo(var SaleLinePOS: Record "NPR POS Sale Line"; POSSaleLine: Record "NPR POS Entry Sales Line"; SaleLineNo: Integer)
    var
        POSInfoTransaction: Record "NPR POS Info Transaction";
        POSInfoPOSEntry: Record "NPR POS Info POS Entry";
        POSInfo: Record "NPR POS Info";
    begin
        POSInfo.SetLoadFields(Type, "Once per Transaction");
        POSInfoPOSEntry.SetLoadFields("POS Info Code", "POS Info");

        POSInfoPOSEntry.SetRange("POS Entry No.", POSSaleLine."POS Entry No.");
        POSInfoPOSEntry.SetRange("Document No.", POSSaleLine."Document No.");
        POSInfoPOSEntry.SetRange("Sales Line No.", SaleLineNo);
        if POSInfoPOSEntry.FindSet(false) then
            repeat
                POSInfo.Get(POSInfoPOSEntry."POS Info Code");

                POSInfoTransaction.Init();
                POSInfoTransaction."Register No." := SaleLinePOS."Register No.";
                POSInfoTransaction."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
                if SaleLineNo <> 0 then
                    POSInfoTransaction."Sales Line No." := SaleLinePOS."Line No."
                else
                    POSInfoTransaction."Sales Line No." := SaleLineNo;
                POSInfoTransaction."Sale Date" := SaleLinePOS.Date;
                POSInfoTransaction."Line Type" := SaleLinePOS."Line Type";
                POSInfoTransaction."Entry No." := 0;
                POSInfoTransaction."POS Info Code" := POSInfoPOSEntry."POS Info Code";
                POSInfoTransaction."POS Info" := POSInfoPOSEntry."POS Info";
                POSInfoTransaction."POS Info Type" := POSInfo.Type;
                POSInfoTransaction."Once per Transaction" := POSInfo."Once per Transaction";
                POSInfoTransaction.Insert(true);
            until POSInfoPOSEntry.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Ext.: Line Format.", 'OnGetLineStyle', '', false, false)]
    local procedure FormatSaleLine_OnPOSInfoAssigment(var Color: Text; var Weight: Text; var Style: Text; SaleLinePOS: Record "NPR POS Sale Line"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSInfo: Record "NPR POS Info";
        POSInfoTransaction: Record "NPR POS Info Transaction";
        Found: Boolean;
    begin
        FilterPOSInfoTrans(POSInfoTransaction, '', SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.");
        Found := false;
        if POSInfoTransaction.FindSet() then
            repeat
                if POSInfo.Get(POSInfoTransaction."POS Info Code") then
                    Found := POSInfo."Set POS Sale Line Color to Red";
            until (POSInfoTransaction.Next() = 0) or Found;
        if Found then
            Color := 'red';
        POSSession.RequestRefreshData();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Ext.: Line Format.", 'OnGetLineFormatting', '', false, false)]
    local procedure OnGetLineFormat(var Highlighted: Boolean; SaleLinePOS: Record "NPR POS Sale Line")
    var
        POSInfo: Record "NPR POS Info";
        POSInfoTransaction: Record "NPR POS Info Transaction";
        Found: Boolean;
    begin
        FilterPOSInfoTrans(POSInfoTransaction, '', SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.");
        Found := false;
        if POSInfoTransaction.FindSet() then
            repeat
                if POSInfo.Get(POSInfoTransaction."POS Info Code") then
                    Found := POSInfo."Set POS Sale Line Color to Red";
            until (POSInfoTransaction.Next() = 0) or Found;
        if Found then
            Highlighted := true;
    end;


    local procedure FilterPOSInfoTrans(var POSInfoTransaction: Record "NPR POS Info Transaction"; POSInfoCode: Code[20]; RegisterNo: Code[10]; SalesTicketNo: Code[20]; LineNo: Integer)
    begin
        POSInfoTransaction.Reset();
        if POSInfoCode = '' then
            POSInfoTransaction.SetCurrentKey("Register No.", "Sales Ticket No.", "Sales Line No.")
        else
            POSInfoTransaction.SetRange("POS Info Code", POSInfoCode);
        POSInfoTransaction.SetRange("Register No.", RegisterNo);
        POSInfoTransaction.SetRange("Sales Ticket No.", SalesTicketNo);
        POSInfoTransaction.SetRange("Sales Line No.", LineNo);
    end;

    procedure GetPOSInfo(POSInfoCode: Code[20]; RegisterNo: Code[10]; SalesTicketNo: Code[20]; LineNo: Integer): Text[250]
    var
        POSInfoTransaction: Record "NPR POS Info Transaction";
    begin
        POSInfoTransaction.Reset();
        POSInfoTransaction.SetRange("POS Info Code", POSInfoCode);
        POSInfoTransaction.SetRange("Register No.", RegisterNo);
        POSInfoTransaction.SetRange("Sales Ticket No.", SalesTicketNo);
        POSInfoTransaction.SetRange("Sales Line No.", LineNo);
        POSInfoTransaction.SetFilter("POS Info", '<>%1', '');
        if POSInfoTransaction.FindFirst() then
            exit(POSInfoTransaction."POS Info")
        else
            exit('');

    end;

    procedure GetPOSInfo(POSInfoCode: Code[20]; RegisterNo: Code[10]; SalesTicketNo: Code[20]): Text[250]
    var
        POSInfoTransaction: Record "NPR POS Info Transaction";
    begin
        POSInfoTransaction.Reset();
        POSInfoTransaction.SetRange("POS Info Code", POSInfoCode);
        POSInfoTransaction.SetRange("Register No.", RegisterNo);
        POSInfoTransaction.SetRange("Sales Ticket No.", SalesTicketNo);
        POSInfoTransaction.SetFilter("POS Info", '<>%1', '');
        if POSInfoTransaction.FindFirst() then
            exit(POSInfoTransaction."POS Info")
        else
            exit('');

    end;

    procedure UpsertPOSInfo(POSInfoCode: Code[20]; SalePOSLine: Record "NPR POS Sale Line"; POSInfoText: Text)
    var
        POSInfoTransaction: Record "NPR POS Info Transaction";
    begin
        POSInfoTransaction.Reset();
        POSInfoTransaction.SetRange("POS Info Code", POSInfoCode);
        POSInfoTransaction.SetRange("Register No.", SalePOSLine."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.", SalePOSLine."Sales Ticket No.");
        POSInfoTransaction.SetRange("Sales Line No.", SalePOSLine."Line No.");
        if POSInfoTransaction.FindFirst() then begin
            POSInfoTransaction."Sale Date" := SalePOSLine.Date;
            POSInfoTransaction."Line Type" := SalePOSLine."Line Type";
            POSInfoTransaction."POS Info" := CopyStr(POSInfoText, 1, MaxStrLen(POSInfoTransaction."POS Info"));
            POSInfoTransaction."No." := SalePOSLine."No.";
            POSInfoTransaction.Quantity := SalePOSLine.Quantity;
            POSInfoTransaction.Modify(true);
        end else begin
            POSInfoTransaction.Init();
            POSInfoTransaction."POS Info Code" := POSInfoCode;
            POSInfoTransaction."Register No." := SalePOSLine."Register No.";
            POSInfoTransaction."Sales Ticket No." := SalePOSLine."Sales Ticket No.";
            POSInfoTransaction."Sales Line No." := SalePOSLine."Line No.";
            POSInfoTransaction."Sale Date" := SalePOSLine.Date;
            POSInfoTransaction."Line Type" := SalePOSLine."Line Type";
            POSInfoTransaction."POS Info" := CopyStr(POSInfoText, 1, MaxStrLen(POSInfoTransaction."POS Info"));
            POSInfoTransaction."No." := SalePOSLine."No.";
            POSInfoTransaction.Quantity := SalePOSLine.Quantity;
            POSInfoTransaction.Insert(true);
        end;
    end;

    procedure UpsertPOSInfo(POSInfoCode: Code[20]; SalePOS: Record "NPR POS Sale"; POSInfoText: Text)
    var
        POSInfoTransaction: Record "NPR POS Info Transaction";
    begin
        POSInfoTransaction.Reset();
        POSInfoTransaction.SetRange("POS Info Code", POSInfoCode);
        POSInfoTransaction.SetRange("Register No.", SalePOS."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if POSInfoTransaction.FindFirst() then begin
            POSInfoTransaction."POS Info" := CopyStr(POSInfoText, 1, MaxStrLen(POSInfoTransaction."POS Info"));
            POSInfoTransaction.Modify(true);
        end else begin
            POSInfoTransaction.Init();
            POSInfoTransaction."POS Info Code" := POSInfoCode;
            POSInfoTransaction."Register No." := SalePOS."Register No.";
            POSInfoTransaction."Sales Ticket No." := SalePOS."Sales Ticket No.";
            POSInfoTransaction."Sale Date" := SalePOS.Date;
            POSInfoTransaction."Line Type" := POSInfoTransaction."Line Type"::"Customer Deposit";
            POSInfoTransaction."POS Info" := CopyStr(POSInfoText, 1, MaxStrLen(POSInfoTransaction."POS Info"));
            POSInfoTransaction.Insert(true);
        end;
    end;

    procedure DeletePOSInfoTransaction(RegisterNo: Code[10]; SalesTicketNo: Code[20]; SalesLineNo: Integer; POSInfoCode: Code[20]; POSInfo: Text[250])
    var
        POSInfoTransaction: Record "NPR POS Info Transaction";
    begin
        POSInfoTransaction.SetRange("Register No.", RegisterNo);
        POSInfoTransaction.SetRange("Sales Ticket No.", SalesTicketNo);
        POSInfoTransaction.SetRange("Sales Line No.", SalesLineNo);
        POSInfoTransaction.SetRange("POS Info Code", POSInfoCode);
        if POSInfo <> '' then
            POSInfoTransaction.SetRange("POS Info", POSInfo);
        if POSInfoTransaction.FindFirst() then
            POSInfoTransaction.Delete(true);
    end;

    procedure FindPOSInfoTransaction(RegisterNo: Code[10]; SalesTicketNo: Code[20]; SalesLineNo: Integer; POSInfoCode: Code[20]; POSInfo: Text[250]): Boolean
    var
        POSInfoTransaction: Record "NPR POS Info Transaction";
    begin
        POSInfoTransaction.SetRange("Register No.", RegisterNo);
        POSInfoTransaction.SetRange("Sales Ticket No.", SalesTicketNo);
        POSInfoTransaction.SetRange("Sales Line No.", SalesLineNo);
        POSInfoTransaction.SetRange("POS Info Code", POSInfoCode);
        if POSInfo <> '' then
            POSInfoTransaction.SetRange("POS Info", POSInfo);
        exit(not POSInfoTransaction.IsEmpty);
    end;


    #region DataSource Extension
    local procedure ThisExtension(): Text
    begin
        exit('POS_INFO');
    end;

    local procedure DataSoucePOSInfoColumnName(POSInfoCode: Code[20]): Text
    var
        POSInfoCodeLbl: Label '%1', Locked = true;
    begin
        exit(StrSubstNo(POSInfoCodeLbl, POSInfoCode));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDiscoverDataSourceExtensions', '', false, false)]
    local procedure OnDiscoverDataSourceExtension(DataSourceName: Text; Extensions: List of [Text])
    var
        POSInfo: Record "NPR POS Info";
        POSDataMgt: Codeunit "NPR POS Data Management";
    begin
        if not (DataSourceName in [POSDataMgt.POSDataSource_BuiltInSale(), POSDataMgt.POSDataSource_BuiltInSaleLine()]) then
            exit;
        POSInfo.SetRange("Available in Front-End", true);
        if POSInfo.IsEmpty then
            exit;

        Extensions.Add(ThisExtension());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnGetDataSourceExtension', '', false, false)]
    local procedure OnGetDataSourceExtension(DataSourceName: Text; ExtensionName: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        POSInfo: Record "NPR POS Info";
        POSDataMgt: Codeunit "NPR POS Data Management";
        DataType: Enum "NPR Data Type";
        POSInfoLbl: Label 'POS Info: %1', Locked = true;
    begin
        if not ((DataSourceName in [POSDataMgt.POSDataSource_BuiltInSale(), POSDataMgt.POSDataSource_BuiltInSaleLine()]) and (ExtensionName = ThisExtension())) then
            exit;

        Handled := true;

        POSInfo.SetRange("Available in Front-End", true);
        if not POSInfo.FindSet() then
            exit;
        repeat
            DataSource.AddColumn(DataSoucePOSInfoColumnName(POSInfo.Code), StrSubstNo(POSInfoLbl, POSInfo.Code), DataType::String, false);
        until POSInfo.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDataSourceExtensionReadData', '', false, false)]
    local procedure OnDataSourceExtensionReadData(DataSourceName: Text; ExtensionName: Text; var RecRef: RecordRef; DataRow: Codeunit "NPR Data Row"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        POSInfo: Record "NPR POS Info";
        POSInfoTransaction: Record "NPR POS Info Transaction";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSDataMgt: Codeunit "NPR POS Data Management";
        POSSale: Codeunit "NPR POS Sale";
    begin
        if not ((DataSourceName in [POSDataMgt.POSDataSource_BuiltInSale(), POSDataMgt.POSDataSource_BuiltInSaleLine()]) and (ExtensionName = ThisExtension())) then
            exit;

        Handled := true;

        POSInfo.SetRange("Available in Front-End", true);
        if not POSInfo.FindSet() then
            exit;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if RecRef.Number = Database::"NPR POS Sale Line" then
            RecRef.SetTable(SaleLinePOS)
        else
            Clear(SaleLinePOS);
        if SaleLinePOS."Line No." = 0 then begin
            SaleLinePOS."Register No." := SalePOS."Register No.";
            SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
        end;

        repeat
            FilterPOSInfoTrans(POSInfoTransaction, POSInfo.Code, SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.");
            if POSInfoTransaction.IsEmpty and POSInfo."Once per Transaction" and (SaleLinePOS."Line No." <> 0) then
                POSInfoTransaction.SetRange("Sales Line No.", 0);
            if not POSInfoTransaction.FindFirst() then
                POSInfoTransaction.Init();
            DataRow.Add(DataSoucePOSInfoColumnName(POSInfo.Code), POSInfoTransaction."POS Info");
        until POSInfo.Next() = 0;
    end;
    #endregion DataSource Extension
}
