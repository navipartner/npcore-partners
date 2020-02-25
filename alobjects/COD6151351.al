codeunit 6151351 "CS UI Phys. Inventory Planned"
{
    // NPR5.53/SARA/20190930  CASE 375041 New object, ajustment for Location as Directed PutAway and Pick
    // NPR5.53/SARA/20200123  CASE 383352 Issue with No Series

    TableNo = "CS UI Header";

    trigger OnRun()
    var
        MiniformMgmt: Codeunit "CS UI Management";
    begin
        MiniformMgmt.Initialize(
          CSUIHeader, Rec, DOMxmlin, ReturnedNode,
          RootNode, XMLDOMMgt, CSCommunication, CSUserId,
          CurrentCode, StackCode, WhseEmpId, LocationFilter, CSSessionId);

        if Code <> CurrentCode then
            PrepareData
        else
            ProcessInput;

        Clear(DOMxmlin);
    end;

    var
        CSUIHeader: Record "CS UI Header";
        XMLDOMMgt: Codeunit "XML DOM Management";
        CSCommunication: Codeunit "CS Communication";
        CSMgt: Codeunit "CS Management";
        RecRef: RecordRef;
        DOMxmlin: DotNet npNetXmlDocument;
        ReturnedNode: DotNet npNetXmlNode;
        RootNode: DotNet npNetXmlNode;
        CSUserId: Text[250];
        Remark: Text[250];
        WhseEmpId: Text[250];
        LocationFilter: Text[250];
        CurrentCode: Text[250];
        StackCode: Text[250];
        ActiveInputField: Integer;
        CSSessionId: Text;
        Text000: Label 'Function not Found.';
        Text002: Label 'Failed to add the attribute: %1.';
        Text004: Label 'Invalid %1.';
        Text005: Label 'Barcode is blank';
        Text006: Label 'No input Node found.';
        Text007: Label 'Record not found.';
        Text008: Label 'Input value Length Error';
        Text009: Label 'Bin Code is blank';
        Text010: Label 'Barcode %1 doesn''t exist';
        Text011: Label 'Qty. is blank';
        Text012: Label 'No Lines available.';
        Text013: Label 'Input value is not valid';
        Text014: Label 'Item %1 doesn''t exist';
        Text015: Label '%1/%2 : %3 %4';
        Text016: Label '%1 : %2';
        Text020: Label 'Location Code is blank';
        Text021: Label 'Bin Code is not valid';
        Text022: Label 'Bin Content do not exist in filter: %1';
        Text023: Label 'Qty. exceeds Bin Content Quantity';
        Text024: Label 'New Bin Code is equal existent Bin Code';
        Text025: Label 'Please select bin';
        Text026: Label '%1 / %2';
        Text027: Label '%1 | %2';
        Text028: Label '%1 Default Journal';
        Text029: Label 'There is no Items on Location %1 at Bin %2';
        Text030: Label '%1 / %2 / %3';

    local procedure ProcessInput()
    var
        FuncGroup: Record "CS UI Function Group";
        RecId: RecordID;
        TextValue: Text;
        TableNo: Integer;
        FldNo: Integer;
        FuncRecId: RecordID;
        FuncTableNo: Integer;
        FuncRecRef: RecordRef;
        FuncFieldId: Integer;
        FuncName: Code[10];
        FuncValue: Text;
        CSPhysInventoryHandling: Record "CS Phys. Inventory Handling";
        CSPhysInventoryHandling2: Record "CS Phys. Inventory Handling";
        CSFieldDefaults: Record "CS Field Defaults";
        CommaString: DotNet npNetString;
        Values: DotNet npNetArray;
        Separator: DotNet npNetString;
        Value: Text;
        ItemJournalLine: Record "Item Journal Line";
    begin
        if XMLDOMMgt.FindNode(RootNode, 'Header/Input', ReturnedNode) then
            TextValue := ReturnedNode.InnerText
        else
            Error(Text006);

        Evaluate(TableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'RecordID'));
        if RecRef.Get(RecId) then begin
            RecRef.SetTable(CSPhysInventoryHandling);
            RecRef.SetRecFilter;
            CSCommunication.SetRecRef(RecRef);
        end else begin
            CSCommunication.RunPreviousUI(DOMxmlin);
            exit;
        end;

        FuncGroup.KeyDef := CSCommunication.GetFunctionKey(CSUIHeader.Code, TextValue);
        ActiveInputField := 1;

        case FuncGroup.KeyDef of
            FuncGroup.KeyDef::Esc:
                begin
                    DeleteEmptyDataLines();
                    CSCommunication.RunPreviousUI(DOMxmlin);
                end;
            FuncGroup.KeyDef::"Function":
                begin
                    FuncName := CSCommunication.GetNodeAttribute(ReturnedNode, 'FuncName');
                    case FuncName of
                        'DEFAULT':
                            begin
                                FuncValue := CSCommunication.GetNodeAttribute(ReturnedNode, 'FuncValue');
                                Evaluate(FuncFieldId, CSCommunication.GetNodeAttribute(ReturnedNode, 'FieldID'));
                                if CSFieldDefaults.Get(CSUserId, CurrentCode, FuncFieldId) then begin
                                    CSFieldDefaults.Value := FuncValue;
                                    CSFieldDefaults.Modify;
                                end else begin
                                    Clear(CSFieldDefaults);
                                    CSFieldDefaults.Id := CSUserId;
                                    CSFieldDefaults."Use Case Code" := CurrentCode;
                                    CSFieldDefaults."Field No" := FuncFieldId;
                                    CSFieldDefaults.Insert;
                                    CSFieldDefaults.Value := FuncValue;
                                    CSFieldDefaults.Modify;
                                end;
                            end;
                        'DELETELINE':
                            begin
                                Evaluate(FuncTableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'FuncTableNo'));
                                FuncRecRef.Open(FuncTableNo);
                                Evaluate(FuncRecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'FuncRecordID'));
                                if FuncRecRef.Get(FuncRecId) then begin
                                    FuncRecRef.SetTable(ItemJournalLine);
                                    ItemJournalLine.Delete(true);
                                end;
                            end;
                    end;
                end;
            FuncGroup.KeyDef::Reset:
                Reset(CSPhysInventoryHandling);
            FuncGroup.KeyDef::Register:
                begin
                    Register(CSPhysInventoryHandling);
                    if Remark = '' then begin
                        DeleteEmptyDataLines();
                        CSCommunication.RunPreviousUI(DOMxmlin)
                    end else
                        SendForm(ActiveInputField, CSPhysInventoryHandling);
                end;
            FuncGroup.KeyDef::Input:
                begin
                    Evaluate(FldNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'FieldID'));

                    CommaString := TextValue;
                    Separator := ',';
                    Values := CommaString.Split(Separator.ToCharArray());

                    foreach Value in Values do begin

                        if Value <> '' then begin

                            case FldNo of
                                CSPhysInventoryHandling.FieldNo(Barcode):
                                    CheckBarcode(CSPhysInventoryHandling, Value);
                                CSPhysInventoryHandling.FieldNo("Bin Code"):
                                    CheckBinCode(CSPhysInventoryHandling, Value);
                                CSPhysInventoryHandling.FieldNo(Qty):
                                    CheckQty(CSPhysInventoryHandling, Value);
                                else begin
                                        CSCommunication.FieldSetvalue(RecRef, FldNo, Value);
                                    end;
                            end;

                            CSPhysInventoryHandling.Modify;

                            RecRef.GetTable(CSPhysInventoryHandling);
                            CSCommunication.SetRecRef(RecRef);
                            ActiveInputField := CSCommunication.GetActiveInputNo(CurrentCode, FldNo);
                            if Remark = '' then
                                if CSCommunication.LastEntryField(CurrentCode, FldNo) then begin

                                    UpdateDataLine(CSPhysInventoryHandling);
                                    CreateDataLine(CSPhysInventoryHandling2, CSPhysInventoryHandling."Location Code", CSPhysInventoryHandling."Bin Code");
                                    RecRef.GetTable(CSPhysInventoryHandling2);
                                    CSCommunication.SetRecRef(RecRef);

                                    Clear(CSPhysInventoryHandling);
                                    CSPhysInventoryHandling := CSPhysInventoryHandling2;

                                    ActiveInputField := 1;
                                end else
                                    ActiveInputField += 1;
                        end;
                    end;
                end;
            else
                Error(Text000);
        end;

        if not (FuncGroup.KeyDef in [FuncGroup.KeyDef::Esc, FuncGroup.KeyDef::Register]) then
            SendForm(ActiveInputField, CSPhysInventoryHandling);
    end;

    local procedure PrepareData()
    var
        CSPhysInventoryHandling: Record "CS Phys. Inventory Handling";
        Bin: Record Bin;
        RecId: RecordID;
        TableNo: Integer;
        WhsePhyJournalBatch: Record "Warehouse Journal Batch";
        CSSetup: Record "CS Setup";
    begin
        XMLDOMMgt.FindNode(RootNode, 'Header/Input', ReturnedNode);

        Evaluate(TableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'TableNo'));
        Evaluate(RecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'RecordID'));

        RecRef.Open(TableNo);
        RecRef.Get(RecId);
        RecRef.SetTable(Bin);

        CSSetup.Get;
        CSSetup.TestField("Phys. Inv Jour Temp Name");
        //NPR5.53
        /*
        IF NOT ItemJournalBatch.GET(CSSetup."Phys. Inv Jour Temp Name",USERID) THEN BEGIN
          ItemJournalBatch.INIT;
          ItemJournalBatch.VALIDATE("Journal Template Name",CSSetup."Phys. Inv Jour Temp Name");
          ItemJournalBatch.VALIDATE(Name,USERID);
          ItemJournalBatch.Description := STRSUBSTNO(Text028,USERID);
          ItemJournalBatch.VALIDATE("No. Series",CSSetup."Phys. Inv Jour No. Series");
          ItemJournalBatch.INSERT(TRUE);
        END;
        */
        if not WhsePhyJournalBatch.Get(CSSetup."Phys. Inv Jour Temp Name", UserId, Bin."Location Code") then begin
            WhsePhyJournalBatch.Init;
            WhsePhyJournalBatch.Validate("Journal Template Name", CSSetup."Phys. Inv Jour Temp Name");
            WhsePhyJournalBatch.Validate(Name, UserId);
            WhsePhyJournalBatch.Validate("Location Code", Bin."Location Code");
            WhsePhyJournalBatch.Description := StrSubstNo(Text028, UserId);
            WhsePhyJournalBatch.Validate("No. Series", CSSetup."Phys. Inv Jour No. Series");
            WhsePhyJournalBatch.Insert(true);
        end;
        //NPR5.53
        DeleteEmptyDataLines();
        CreateDataLine(CSPhysInventoryHandling, Bin."Location Code", Bin.Code);

        RecRef.Close;

        RecId := CSPhysInventoryHandling.RecordId;

        RecRef.Open(RecId.TableNo);
        RecRef.Get(RecId);
        RecRef.SetRecFilter;

        CSCommunication.SetRecRef(RecRef);
        ActiveInputField := 1;
        SendForm(ActiveInputField, CSPhysInventoryHandling);

    end;

    local procedure SendForm(InputField: Integer; CSPhysInventoryHandling: Record "CS Phys. Inventory Handling")
    var
        Records: DotNet npNetXmlElement;
        CSSetup: Record "CS Setup";
    begin
        CSCommunication.EncodeUI(CSUIHeader, StackCode, DOMxmlin, InputField, Remark, CSUserId);
        CSCommunication.GetReturnXML(DOMxmlin);

        if AddSummarize(Records, CSPhysInventoryHandling) then
            DOMxmlin.DocumentElement.AppendChild(Records);

        CSMgt.SendXMLReply(DOMxmlin);
    end;

    local procedure CheckBarcode(var CSPhysInventoryHandling: Record "CS Phys. Inventory Handling"; InputValue: Text)
    var
        BarcodeLibrary: Codeunit "Barcode Library";
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
        Item: Record Item;
        BinContent: Record "Bin Content";
    begin
        if InputValue = '' then begin
            Remark := Text005;
            exit;
        end;

        if StrLen(InputValue) > MaxStrLen(CSPhysInventoryHandling.Barcode) then begin
            Remark := Text008;
            exit;
        end;

        if BarcodeLibrary.TranslateBarcodeToItemVariant(InputValue, ItemNo, VariantCode, ResolvingTable, true) then begin
            if not Item.Get(ItemNo) then begin
                Remark := StrSubstNo(Text014, InputValue);
                exit;
            end;

            CSPhysInventoryHandling."Item No." := ItemNo;
            CSPhysInventoryHandling."Variant Code" := VariantCode;

        end else begin
            Remark := StrSubstNo(Text010, InputValue);
            exit;
        end;

        CSPhysInventoryHandling.Barcode := InputValue;
    end;

    local procedure CheckBinCode(var CSPhysInventoryHandling: Record "CS Phys. Inventory Handling"; InputValue: Text)
    var
        QtyToHandle: Decimal;
        BinContent: Record "Bin Content";
        Bin: Record Bin;
    begin
        if InputValue = '' then begin
            Remark := Text009;
            exit;
        end;

        if StrLen(InputValue) > MaxStrLen(CSPhysInventoryHandling."Bin Code") then begin
            Remark := Text008;
            exit;
        end;

        Clear(Bin);
        Bin.SetRange("Location Code", CSPhysInventoryHandling."Location Code");
        Bin.SetRange(Code, InputValue);
        if not Bin.FindSet then
            Remark := Text021;

        CSPhysInventoryHandling."Bin Code" := InputValue;
    end;

    local procedure CheckQty(var CSPhysInventoryHandling: Record "CS Phys. Inventory Handling"; InputValue: Text)
    var
        Qty: Decimal;
        BinContent: Record "Bin Content";
    begin
        if InputValue = '' then begin
            Remark := Text011;
            exit;
        end;

        if not Evaluate(Qty, InputValue) then begin
            Remark := Text013;
            exit;
        end;

        CSPhysInventoryHandling.Qty := Qty;
    end;

    local procedure CheckLocation(InputValue: Text)
    var
        Location: Record Location;
        WarehouseEmployee: Record "Warehouse Employee";
    begin
        if not Location.Get(InputValue) then
            Location.SetRange(Name, InputValue);
        if Location.Count > 0 then
            Location.FindFirst;
    end;

    local procedure CreateDataLine(var CSPhysInventoryHandling: Record "CS Phys. Inventory Handling"; LocationCode: Code[10]; BinCode: Code[20])
    var
        NewCSPhysInventoryHandling: Record "CS Phys. Inventory Handling";
        LineNo: Integer;
        CSUIHeader: Record "CS UI Header";
        RecRef: RecordRef;
        CSSetup: Record "CS Setup";
    begin
        if LocationCode = '' then
            Error(Text020);

        CheckLocation(LocationCode);

        Clear(NewCSPhysInventoryHandling);
        NewCSPhysInventoryHandling.SetRange(Id, CSSessionId);
        if NewCSPhysInventoryHandling.FindLast then
            LineNo := NewCSPhysInventoryHandling."Line No." + 1
        else
            LineNo := 1;

        CSPhysInventoryHandling.Init;
        CSPhysInventoryHandling.Id := CSSessionId;
        CSPhysInventoryHandling."Line No." := LineNo;
        CSPhysInventoryHandling."Created By" := UserId;
        CSPhysInventoryHandling.Created := CurrentDateTime;
        CSPhysInventoryHandling."Location Code" := LocationCode;
        CSPhysInventoryHandling."Bin Code" := BinCode;

        RecRef.GetTable(CSPhysInventoryHandling);
        CSPhysInventoryHandling."Table No." := RecRef.Number;

        CSSetup.Get;
        CSSetup.TestField("Phys. Inv Jour Temp Name");

        CSPhysInventoryHandling."Journal Template Name" := CSSetup."Phys. Inv Jour Temp Name";
        CSPhysInventoryHandling."Journal Batch Name" := UserId;
        CSPhysInventoryHandling."Record Id" := CSPhysInventoryHandling.RecordId;

        CSPhysInventoryHandling.Insert(true);
    end;

    local procedure UpdateDataLine(var CSPhysInventoryHandling: Record "CS Phys. Inventory Handling")
    var
        LineNo: Integer;
        CSSetup: Record "CS Setup";
    begin
        CSSetup.Get;

        CSPhysInventoryHandling.Handled := true;
        CSPhysInventoryHandling.Modify(true);

        if TransferDataLine(CSPhysInventoryHandling) then begin
            CSPhysInventoryHandling."Transferred to Journal" := true;
            CSPhysInventoryHandling.Modify(true);
        end;
    end;

    local procedure DeleteEmptyDataLines()
    var
        CSPhysInventoryHandling: Record "CS Phys. Inventory Handling";
    begin
        CSPhysInventoryHandling.SetRange(Id, CSSessionId);
        CSPhysInventoryHandling.SetRange(Handled, false);
        CSPhysInventoryHandling.SetRange("Transferred to Journal", false);
        CSPhysInventoryHandling.DeleteAll(true);
    end;

    local procedure Register(CurrCSPhysInventoryHandling: Record "CS Phys. Inventory Handling")
    var
        WhseJnlTemplate: Record "Warehouse Journal Template";
        WhseJnlPostBatch: Codeunit "Whse. Jnl.-Register Batch";
        WhseJournalLine: Record "Warehouse Journal Line";
    begin
        WhseJnlTemplate.Get(CurrCSPhysInventoryHandling."Journal Template Name");
        //WhseJnlTemplate.TESTFIELD("Force Posting Report",FALSE);

        Clear(WhseJournalLine);
        WhseJournalLine.SetRange("Journal Template Name", CurrCSPhysInventoryHandling."Journal Template Name");
        WhseJournalLine.SetRange("Journal Batch Name", CurrCSPhysInventoryHandling."Journal Batch Name");
        WhseJournalLine.SetRange("Location Code", CurrCSPhysInventoryHandling."Location Code");
        //-NPR5.53 [383352]
        //WhseJournalLine.SETRANGE("Whse. Document No.",FORMAT(TODAY));
        //+NPR5.53 [383352]
        if WhseJournalLine.FindSet then begin
            WhseJnlPostBatch.Run(WhseJournalLine);
            WhseJournalLine.DeleteAll;
        end;
    end;

    local procedure Reset(CSPhysInventoryHandling: Record "CS Phys. Inventory Handling")
    var
        CSSetup: Record "CS Setup";
        WhseJournalLine: Record "Warehouse Journal Line";
        Item: Record Item;
        WhseJnlTemplate: Record "Warehouse Journal Template";
        WhseJnlBatch: Record "Warehouse Journal Batch";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        CSSetup.Get;
        CSSetup.TestField("Phys. Inv Jour Temp Name");
        CSSetup.TestField("Phys. Inv Jour No. Series");

        Clear(WhseJournalLine);
        WhseJournalLine.SetRange("Journal Template Name", CSSetup."Phys. Inv Jour Temp Name");
        WhseJournalLine.SetRange("Journal Batch Name", UserId);
        WhseJournalLine.SetRange("Location Code", CSPhysInventoryHandling."Location Code");
        WhseJournalLine.SetRange("Bin Code", CSPhysInventoryHandling."Bin Code");
        WhseJournalLine.DeleteAll;

        Clear(WhseJournalLine);
        WhseJournalLine.Init;
        WhseJournalLine.Validate("Journal Template Name", CSSetup."Phys. Inv Jour Temp Name");
        WhseJournalLine.Validate("Journal Batch Name", UserId);
        WhseJournalLine.Validate("Location Code", CSPhysInventoryHandling."Location Code");
        WhseJournalLine.Validate("Bin Code", CSPhysInventoryHandling."Bin Code");
        WhseJournalLine."Registering Date" := Today;
        WhseJnlTemplate.Get(CSSetup."Phys. Inv Jour Temp Name");
        WhseJnlBatch.Get(WhseJournalLine."Journal Template Name", WhseJournalLine."Journal Batch Name", CSPhysInventoryHandling."Location Code");

        Clear(NoSeriesMgt);
        WhseJournalLine."Whse. Document No." := Format(Today);
        WhseJournalLine."Source Code" := WhseJnlTemplate."Source Code";
        WhseJournalLine."Reason Code" := WhseJnlBatch."Reason Code";
        WhseJournalLine."Registering No. Series" := NoSeriesMgt.GetNextNo(WhseJnlBatch."No. Series", WhseJournalLine."Registering Date", false);
        ;

        CalculateInventory(WhseJournalLine, Item, WorkDate, false, false);
    end;

    local procedure TransferDataLine(CSPhysInventoryHandling: Record "CS Phys. Inventory Handling"): Boolean
    var
        WhseJournalLine: Record "Warehouse Journal Line";
        NewWhseJournalLine: Record "Warehouse Journal Line";
        LineNo: Integer;
        WhseJnlTemplate: Record "Warehouse Journal Template";
        WhseJnlBatch: Record "Warehouse Journal Batch";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
    begin
        Clear(WhseJournalLine);
        WhseJournalLine.SetRange("Journal Template Name", CSPhysInventoryHandling."Journal Template Name");
        WhseJournalLine.SetRange("Journal Batch Name", CSPhysInventoryHandling."Journal Batch Name");
        WhseJournalLine.SetRange("Location Code", CSPhysInventoryHandling."Location Code");
        WhseJournalLine.SetRange("Bin Code", CSPhysInventoryHandling."Bin Code");
        WhseJournalLine.SetRange("Item No.", CSPhysInventoryHandling."Item No.");
        WhseJournalLine.SetRange("Variant Code", CSPhysInventoryHandling."Variant Code");
        if not WhseJournalLine.FindSet then begin
            NewWhseJournalLine.Reset;
            NewWhseJournalLine.SetRange("Journal Template Name", CSPhysInventoryHandling."Journal Template Name");
            NewWhseJournalLine.SetRange("Journal Batch Name", CSPhysInventoryHandling."Journal Batch Name");
            LineNo := 0;
            if NewWhseJournalLine.FindLast then
                LineNo := NewWhseJournalLine."Line No." + 1000
            else
                LineNo := 1000;

            Clear(WhseJournalLine);
            WhseJournalLine.Validate("Journal Template Name", CSPhysInventoryHandling."Journal Template Name");
            WhseJournalLine.Validate("Journal Batch Name", CSPhysInventoryHandling."Journal Batch Name");
            WhseJournalLine.Validate("Location Code", CSPhysInventoryHandling."Location Code");
            WhseJournalLine."Line No." := LineNo;
            WhseJournalLine.Insert(true);

            WhseJournalLine.Validate("Entry Type", WhseJournalLine."Entry Type"::"Positive Adjmt.");
            WhseJournalLine.Validate("Item No.", CSPhysInventoryHandling."Item No.");
            WhseJournalLine.Validate("Variant Code", CSPhysInventoryHandling."Variant Code");
            WhseJournalLine.Validate("Bin Code", CSPhysInventoryHandling."Bin Code");
            WhseJournalLine.Validate("Phys. Inventory", true);
            WhseJournalLine.Validate("Qty. (Phys. Inventory)", CSPhysInventoryHandling.Qty);

            WhseJournalLine."Registering Date" := WorkDate;

            WhseJnlTemplate.Get(WhseJournalLine."Journal Template Name");
            WhseJnlBatch.Get(WhseJournalLine."Journal Template Name", WhseJournalLine."Journal Batch Name", WhseJournalLine."Location Code");

            Clear(NoSeriesMgt);
            WhseJournalLine."Whse. Document No." := Format(Today);
            WhseJournalLine."Source Code" := WhseJnlTemplate."Source Code";
            WhseJournalLine."Reason Code" := WhseJnlTemplate."Reason Code";
            if WhseJnlBatch."No. Series" <> '' then
                WhseJournalLine."Whse. Document No." := NoSeriesMgt.GetNextNo(WhseJnlBatch."No. Series", WhseJournalLine."Registering Date", false);
            WhseJournalLine."Registering No. Series" := WhseJnlBatch."No. Series";
            WhseJournalLine.SetUpNewLine(WhseJournalLine);
            WhseJournalLine.Modify(true);
        end else begin
            WhseJournalLine.Validate("Qty. (Phys. Inventory)", CSPhysInventoryHandling.Qty);
            WhseJournalLine.Modify(true);
        end;

        exit(true);
    end;

    local procedure AddSummarize(var Records: DotNet npNetXmlElement; CSPhysInventoryHandling: Record "CS Phys. Inventory Handling"): Boolean
    var
        "Record": DotNet npNetXmlElement;
        Line: DotNet npNetXmlElement;
        Indicator: Text;
        LineType: Option TEXT,BUTTON;
        CurrRecordID: RecordID;
        TableNo: Integer;
        CSItemReclassHandling: Record "CS Item Reclass. Handling";
        CSSetup: Record "CS Setup";
        WhseJournalLine: Record "Warehouse Journal Line";
        Item: Record Item;
    begin
        SelectLatestVersion;

        CSSetup.Get;
        CSSetup.TestField("Phys. Inv Jour Temp Name");

        Clear(WhseJournalLine);
        WhseJournalLine.SetRange("Journal Template Name", CSSetup."Phys. Inv Jour Temp Name");
        WhseJournalLine.SetRange("Journal Batch Name", UserId);
        WhseJournalLine.SetRange("Location Code", CSPhysInventoryHandling."Location Code");
        WhseJournalLine.SetRange("Bin Code", CSPhysInventoryHandling."Bin Code");
        if WhseJournalLine.FindSet then begin
            Records := DOMxmlin.CreateElement('Records');
            repeat
                Record := DOMxmlin.CreateElement('Record');

                CurrRecordID := WhseJournalLine.RecordId;
                TableNo := CurrRecordID.TableNo;

                //IF WhseJournalLine."Changed by User" THEN
                //Indicator := 'ok'
                //ELSE
                Indicator := 'minus';

                if Indicator = 'minus' then begin
                    if CSUIHeader."Expand Summary Items" then begin
                        //1
                        Line := DOMxmlin.CreateElement('Line');
                        AddAttribute(Line, 'Descrip', WhseJournalLine.FieldCaption(Description));
                        AddAttribute(Line, 'Indicator', Indicator);
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        AddAttribute(Line, 'CollapsItems', 'FALSE');
                        Line.InnerText := WhseJournalLine."Bin Code";
                        Record.AppendChild(Line);

                        //2
                        Line := DOMxmlin.CreateElement('Line');
                        AddAttribute(Line, 'Descrip', WhseJournalLine.FieldCaption("Qty. (Calculated)"));
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        Line.InnerText := StrSubstNo(Text030, WhseJournalLine."Qty. (Calculated)", WhseJournalLine."Qty. (Phys. Inventory)", WhseJournalLine.Quantity);
                        Record.AppendChild(Line);

                        //3
                        Line := DOMxmlin.CreateElement('Line');
                        AddAttribute(Line, 'Descrip', WhseJournalLine.FieldCaption("Item No."));
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        if WhseJournalLine."Variant Code" <> '' then
                            Line.InnerText := StrSubstNo(Text027, WhseJournalLine."Item No.", WhseJournalLine."Variant Code")
                        else
                            Line.InnerText := WhseJournalLine."Item No.";
                        Record.AppendChild(Line);

                        //4
                        Line := DOMxmlin.CreateElement('Line');
                        AddAttribute(Line, 'Descrip', WhseJournalLine.FieldCaption("Unit of Measure Code"));
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        Line.InnerText := WhseJournalLine."Unit of Measure Code";
                        Record.AppendChild(Line);

                        //5
                        Item.Get(WhseJournalLine."Item No.");
                        Line := DOMxmlin.CreateElement('Line');
                        AddAttribute(Line, 'Descrip', WhseJournalLine.FieldCaption(Description));
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        Line.InnerText := Item.Description;
                        Record.AppendChild(Line);

                        //6
                        Line := DOMxmlin.CreateElement('Line');
                        AddAttribute(Line, 'Descrip', '');
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        Line.InnerText := '';
                        Record.AppendChild(Line);
                    end else begin
                        Line := DOMxmlin.CreateElement('Line');
                        AddAttribute(Line, 'Descrip', 'Description');
                        AddAttribute(Line, 'Indicator', Indicator);
                        Line.InnerText := StrSubstNo(Text015, WhseJournalLine.Quantity, WhseJournalLine."Qty. (Calculated)", WhseJournalLine."Item No.", WhseJournalLine.Description);
                        Record.AppendChild(Line);

                        Line := DOMxmlin.CreateElement('Line');
                        AddAttribute(Line, 'Descrip', WhseJournalLine.FieldCaption("Item No."));
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        Line.InnerText := WhseJournalLine."Item No.";
                        Record.AppendChild(Line);

                        if (WhseJournalLine."Variant Code" <> '') then begin
                            Line := DOMxmlin.CreateElement('Line');
                            AddAttribute(Line, 'Descrip', WhseJournalLine.FieldCaption("Variant Code"));
                            AddAttribute(Line, 'Type', Format(LineType::TEXT));
                            Line.InnerText := WhseJournalLine."Variant Code";
                            Record.AppendChild(Line);
                        end;

                        Line := DOMxmlin.CreateElement('Line');
                        AddAttribute(Line, 'Descrip', WhseJournalLine.FieldCaption("Bin Code"));
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        Line.InnerText := WhseJournalLine."Bin Code";
                        Record.AppendChild(Line);
                    end;
                    Records.AppendChild(Record);
                end;
            until WhseJournalLine.Next = 0;

            if WhseJournalLine.FindSet then begin
                repeat
                    Record := DOMxmlin.CreateElement('Record');

                    CurrRecordID := WhseJournalLine.RecordId;
                    TableNo := CurrRecordID.TableNo;

                    //IF WhseJournalLine."Changed by User" THEN
                    //Indicator := 'ok'
                    //ELSE
                    Indicator := 'minus';

                    if Indicator = 'ok' then begin
                        if CSUIHeader."Expand Summary Items" then begin
                            //1
                            Line := DOMxmlin.CreateElement('Line');
                            AddAttribute(Line, 'Descrip', WhseJournalLine.FieldCaption(Description));
                            AddAttribute(Line, 'Indicator', Indicator);
                            AddAttribute(Line, 'Type', Format(LineType::TEXT));
                            AddAttribute(Line, 'CollapsItems', 'FALSE');
                            Line.InnerText := WhseJournalLine."Bin Code";
                            Record.AppendChild(Line);

                            //2
                            Line := DOMxmlin.CreateElement('Line');
                            AddAttribute(Line, 'Descrip', WhseJournalLine.FieldCaption("Qty. (Calculated)"));
                            AddAttribute(Line, 'Type', Format(LineType::TEXT));
                            Line.InnerText := StrSubstNo(Text030, WhseJournalLine."Qty. (Calculated)", WhseJournalLine."Qty. (Phys. Inventory)", WhseJournalLine.Quantity);
                            Record.AppendChild(Line);

                            //3
                            Line := DOMxmlin.CreateElement('Line');
                            AddAttribute(Line, 'Descrip', WhseJournalLine.FieldCaption("Item No."));
                            AddAttribute(Line, 'Type', Format(LineType::TEXT));
                            if WhseJournalLine."Variant Code" <> '' then
                                Line.InnerText := StrSubstNo(Text027, WhseJournalLine."Item No.", WhseJournalLine."Variant Code")
                            else
                                Line.InnerText := WhseJournalLine."Item No.";
                            Record.AppendChild(Line);

                            //4
                            Line := DOMxmlin.CreateElement('Line');
                            AddAttribute(Line, 'Descrip', WhseJournalLine.FieldCaption("Unit of Measure Code"));
                            AddAttribute(Line, 'Type', Format(LineType::TEXT));
                            Line.InnerText := WhseJournalLine."Unit of Measure Code";
                            Record.AppendChild(Line);

                            //5
                            Item.Get(WhseJournalLine."Item No.");
                            Line := DOMxmlin.CreateElement('Line');
                            AddAttribute(Line, 'Descrip', WhseJournalLine.FieldCaption(Description));
                            AddAttribute(Line, 'Type', Format(LineType::TEXT));
                            Line.InnerText := Item.Description;
                            Record.AppendChild(Line);

                            //6
                            Line := DOMxmlin.CreateElement('Line');
                            AddAttribute(Line, 'Descrip', '');
                            AddAttribute(Line, 'Type', Format(LineType::TEXT));
                            Line.InnerText := '';
                            Record.AppendChild(Line);
                        end else begin
                            Line := DOMxmlin.CreateElement('Line');
                            AddAttribute(Line, 'Descrip', 'Description');
                            AddAttribute(Line, 'Indicator', Indicator);
                            Line.InnerText := StrSubstNo(Text015, WhseJournalLine.Quantity, WhseJournalLine."Qty. (Calculated)", WhseJournalLine."Item No.", WhseJournalLine.Description);
                            Record.AppendChild(Line);

                            Line := DOMxmlin.CreateElement('Line');
                            AddAttribute(Line, 'Descrip', WhseJournalLine.FieldCaption("Item No."));
                            AddAttribute(Line, 'Type', Format(LineType::TEXT));
                            Line.InnerText := WhseJournalLine."Item No.";
                            Record.AppendChild(Line);

                            if (WhseJournalLine."Variant Code" <> '') then begin
                                Line := DOMxmlin.CreateElement('Line');
                                AddAttribute(Line, 'Descrip', WhseJournalLine.FieldCaption("Variant Code"));
                                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                                Line.InnerText := WhseJournalLine."Variant Code";
                                Record.AppendChild(Line);
                            end;

                            Line := DOMxmlin.CreateElement('Line');
                            AddAttribute(Line, 'Descrip', WhseJournalLine.FieldCaption("Bin Code"));
                            AddAttribute(Line, 'Type', Format(LineType::TEXT));
                            Line.InnerText := WhseJournalLine."Bin Code";
                            Record.AppendChild(Line);
                        end;
                        Records.AppendChild(Record);
                    end;
                until WhseJournalLine.Next = 0;
            end;
            exit(true);
        end else
            exit(false);
    end;

    local procedure AddAttribute(var NewChild: DotNet npNetXmlNode; AttribName: Text[250]; AttribValue: Text[250])
    begin
        if XMLDOMMgt.AddAttribute(NewChild, AttribName, AttribValue) > 0 then
            Error(Text002, AttribName);
    end;

    procedure CalculateInventory(BaseWhseJournalLine: Record "Warehouse Journal Line"; var Item: Record Item; PostingDate: Date; ItemsNotOnInvt: Boolean; InclItemWithNoTrans: Boolean)
    var
        CalculateInventory: Report "Calculate Inventory";
        NewWhseJournalLine: Record "Warehouse Journal Line";
        LineNo: Integer;
        WhseJournalLine: Record "Warehouse Journal Line";
        BinContent: Record "Bin Content";
        TestItem: Record Item;
    begin

        Clear(NewWhseJournalLine);
        NewWhseJournalLine.SetRange("Journal Template Name", BaseWhseJournalLine."Journal Template Name");
        NewWhseJournalLine.SetRange("Journal Batch Name", BaseWhseJournalLine."Journal Batch Name");
        NewWhseJournalLine.SetRange("Location Code", BaseWhseJournalLine."Location Code");
        LineNo := 0;
        if NewWhseJournalLine.FindLast then
            LineNo := NewWhseJournalLine."Line No." + 1000
        else
            LineNo := 1000;

        Clear(BinContent);
        BinContent.SetRange("Location Code", BaseWhseJournalLine."Location Code");
        BinContent.SetRange("Bin Code", BaseWhseJournalLine."Bin Code");
        if BinContent.FindSet then begin
            repeat

                TestItem.Get(BinContent."Item No.");
                if not TestItem.Blocked then begin
                    BinContent.CalcFields(Quantity);

                    Clear(WhseJournalLine);
                    WhseJournalLine.Validate("Journal Template Name", BaseWhseJournalLine."Journal Template Name");
                    WhseJournalLine.Validate("Journal Batch Name", BaseWhseJournalLine."Journal Batch Name");
                    WhseJournalLine.Validate("Location Code", BaseWhseJournalLine."Location Code");
                    WhseJournalLine."Line No." := LineNo;
                    WhseJournalLine.Insert(true);

                    WhseJournalLine.Validate("Entry Type", WhseJournalLine."Entry Type"::"Positive Adjmt.");
                    WhseJournalLine.Validate("Item No.", BinContent."Item No.");
                    WhseJournalLine.Validate("Variant Code", BinContent."Variant Code");
                    WhseJournalLine.Validate("Bin Code", BinContent."Bin Code");
                    WhseJournalLine.Validate("Phys. Inventory", true);
                    WhseJournalLine.Validate("Qty. (Calculated)", BinContent.Quantity);
                    WhseJournalLine."Registering Date" := WorkDate;

                    WhseJournalLine."Whse. Document No." := BaseWhseJournalLine."Whse. Document No.";
                    WhseJournalLine."Source Code" := BaseWhseJournalLine."Source Code";
                    WhseJournalLine."Reason Code" := BaseWhseJournalLine."Reason Code";
                    WhseJournalLine."Registering No. Series" := BaseWhseJournalLine."Registering No. Series";
                    WhseJournalLine.SetUpNewLine(WhseJournalLine);
                    WhseJournalLine.Modify(true);
                    LineNo += 1000;
                end;
            until BinContent.Next = 0;
        end else
            Error(Text029, BaseWhseJournalLine."Location Code", BaseWhseJournalLine."Bin Code");
    end;
}

