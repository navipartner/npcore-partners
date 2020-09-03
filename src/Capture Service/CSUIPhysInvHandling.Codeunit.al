codeunit 6151361 "NPR CS UI Phys. Inv. Handling"
{
    // NPR5.51/CLVA/20190812  CASE 362173 Object created
    // NPR5.52/CLVA/20190916  CASE 368484 Changed field assigning

    TableNo = "NPR CS UI Header";

    trigger OnRun()
    var
        MiniformMgmt: Codeunit "NPR CS UI Management";
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
        CSUIHeader: Record "NPR CS UI Header";
        XMLDOMMgt: Codeunit "XML DOM Management";
        CSCommunication: Codeunit "NPR CS Communication";
        CSMgt: Codeunit "NPR CS Management";
        RecRef: RecordRef;
        DOMxmlin: DotNet "NPRNetXmlDocument";
        ReturnedNode: DotNet NPRNetXmlNode;
        RootNode: DotNet NPRNetXmlNode;
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
        FuncGroup: Record "NPR CS UI Function Group";
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
        CSPhysInventoryHandling: Record "NPR CS Phys. Inv. Handl.";
        CSPhysInventoryHandling2: Record "NPR CS Phys. Inv. Handl.";
        CSFieldDefaults: Record "NPR CS Field Defaults";
        CommaString: DotNet NPRNetString;
        Values: DotNet NPRNetArray;
        Separator: DotNet NPRNetString;
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
        CSPhysInventoryHandling: Record "NPR CS Phys. Inv. Handl.";
        Bin: Record Bin;
        RecId: RecordID;
        TableNo: Integer;
        ItemJournalBatch: Record "Item Journal Batch";
        CSSetup: Record "NPR CS Setup";
    begin
        XMLDOMMgt.FindNode(RootNode, 'Header/Input', ReturnedNode);

        Evaluate(TableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'TableNo'));
        Evaluate(RecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'RecordID'));

        RecRef.Open(TableNo);
        RecRef.Get(RecId);
        RecRef.SetTable(Bin);

        CSSetup.Get;
        CSSetup.TestField("Phys. Inv Jour Temp Name");
        if not ItemJournalBatch.Get(CSSetup."Phys. Inv Jour Temp Name", UserId) then begin
            ItemJournalBatch.Init;
            ItemJournalBatch.Validate("Journal Template Name", CSSetup."Phys. Inv Jour Temp Name");
            ItemJournalBatch.Validate(Name, UserId);
            ItemJournalBatch.Description := StrSubstNo(Text028, UserId);
            ItemJournalBatch.Validate("No. Series", CSSetup."Phys. Inv Jour No. Series");
            ItemJournalBatch.Insert(true);
        end;

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

    local procedure SendForm(InputField: Integer; CSPhysInventoryHandling: Record "NPR CS Phys. Inv. Handl.")
    var
        Records: DotNet NPRNetXmlElement;
        CSSetup: Record "NPR CS Setup";
    begin
        CSCommunication.EncodeUI(CSUIHeader, StackCode, DOMxmlin, InputField, Remark, CSUserId);
        CSCommunication.GetReturnXML(DOMxmlin);

        if AddSummarize(Records, CSPhysInventoryHandling) then
            DOMxmlin.DocumentElement.AppendChild(Records);

        CSMgt.SendXMLReply(DOMxmlin);
    end;

    local procedure CheckBarcode(var CSPhysInventoryHandling: Record "NPR CS Phys. Inv. Handl."; InputValue: Text)
    var
        BarcodeLibrary: Codeunit "NPR Barcode Library";
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

    local procedure CheckBinCode(var CSPhysInventoryHandling: Record "NPR CS Phys. Inv. Handl."; InputValue: Text)
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

    local procedure CheckQty(var CSPhysInventoryHandling: Record "NPR CS Phys. Inv. Handl."; InputValue: Text)
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

    local procedure CreateDataLine(var CSPhysInventoryHandling: Record "NPR CS Phys. Inv. Handl."; LocationCode: Code[10]; BinCode: Code[20])
    var
        NewCSPhysInventoryHandling: Record "NPR CS Phys. Inv. Handl.";
        LineNo: Integer;
        CSUIHeader: Record "NPR CS UI Header";
        RecRef: RecordRef;
        CSSetup: Record "NPR CS Setup";
    begin
        if LocationCode = '' then
            Error(Text020);

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

    local procedure UpdateDataLine(var CSPhysInventoryHandling: Record "NPR CS Phys. Inv. Handl.")
    var
        LineNo: Integer;
        CSSetup: Record "NPR CS Setup";
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
        CSPhysInventoryHandling: Record "NPR CS Phys. Inv. Handl.";
    begin
        CSPhysInventoryHandling.SetRange(Id, CSSessionId);
        CSPhysInventoryHandling.SetRange(Handled, false);
        CSPhysInventoryHandling.SetRange("Transferred to Journal", false);
        CSPhysInventoryHandling.DeleteAll(true);
    end;

    local procedure Register(CurrCSPhysInventoryHandling: Record "NPR CS Phys. Inv. Handl.")
    var
        ItemJnlTemplate: Record "Item Journal Template";
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
        ItemJournalLine: Record "Item Journal Line";
    begin
        ItemJnlTemplate.Get(CurrCSPhysInventoryHandling."Journal Template Name");
        ItemJnlTemplate.TestField("Force Posting Report", false);

        Clear(ItemJournalLine);
        ItemJournalLine.SetRange("Journal Template Name", CurrCSPhysInventoryHandling."Journal Template Name");
        ItemJournalLine.SetRange("Journal Batch Name", CurrCSPhysInventoryHandling."Journal Batch Name");
        ItemJournalLine.SetRange("Bin Code", CurrCSPhysInventoryHandling."Bin Code");
        ItemJournalLine.SetRange("External Document No.", 'MOBILE');
        if ItemJournalLine.FindSet then begin
            repeat
                ItemJnlPostBatch.Run(ItemJournalLine);
            until ItemJournalLine.Next = 0;
        end;
    end;

    local procedure Reset(CSPhysInventoryHandling: Record "NPR CS Phys. Inv. Handl.")
    var
        CSSetup: Record "NPR CS Setup";
        ItemJournalLine: Record "Item Journal Line";
        Item: Record Item;
        ItemJnlTemplate: Record "Item Journal Template";
        ItemJnlBatch: Record "Item Journal Batch";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        CSSetup.Get;
        CSSetup.TestField("Phys. Inv Jour Temp Name");
        CSSetup.TestField("Phys. Inv Jour No. Series");

        // CLEAR(Item);
        // Item.SETFILTER("Location Filter",CSPhysInventoryHandling."Location Code");
        // Item.SETFILTER("Bin Filter",CSPhysInventoryHandling."Bin Code");
        // // IF NOT Item.FINDSET THEN BEGIN
        // //  Remark := STRSUBSTNO(Text029,CSPhysInventoryHandling."Location Code",CSPhysInventoryHandling."Bin Code");
        // //  EXIT;
        // // END;
        // IF NOT Item.FINDFIRST THEN
        //    ERROR(Text029,CSPhysInventoryHandling."Location Code",CSPhysInventoryHandling."Bin Code");

        Clear(ItemJournalLine);
        ItemJournalLine.SetRange("Journal Template Name", CSSetup."Phys. Inv Jour Temp Name");
        ItemJournalLine.SetRange("Journal Batch Name", UserId);
        ItemJournalLine.SetRange("Location Code", CSPhysInventoryHandling."Location Code");
        ItemJournalLine.SetRange("Bin Code", CSPhysInventoryHandling."Bin Code");
        ItemJournalLine.DeleteAll;

        Clear(ItemJournalLine);
        ItemJournalLine.Init;
        ItemJournalLine.Validate("Journal Template Name", CSSetup."Phys. Inv Jour Temp Name");
        ItemJournalLine.Validate("Journal Batch Name", UserId);
        //-NPR5.52 [370367]
        //ItemJournalLine.VALIDATE("Location Code",CSPhysInventoryHandling."Location Code");
        //ItemJournalLine.VALIDATE("Bin Code",CSPhysInventoryHandling."Bin Code");
        ItemJournalLine."Location Code" := CSPhysInventoryHandling."Location Code";
        ItemJournalLine."Bin Code" := CSPhysInventoryHandling."Bin Code";
        //+NPR5.52 [370367]
        ItemJnlTemplate.Get(CSSetup."Phys. Inv Jour Temp Name");
        ItemJnlBatch.Get(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");

        Clear(NoSeriesMgt);
        ItemJournalLine."Document No." := NoSeriesMgt.GetNextNo(ItemJnlBatch."No. Series", ItemJournalLine."Posting Date", false);
        ItemJournalLine."Source Code" := ItemJnlTemplate."Source Code";
        ItemJournalLine."Reason Code" := ItemJnlBatch."Reason Code";
        ItemJournalLine."Posting No. Series" := ItemJnlBatch."Posting No. Series";

        CalculateInventory(ItemJournalLine, Item, WorkDate, false, false);

        // CLEAR(ItemJournalLine);
        // ItemJournalLine.SETRANGE("Journal Template Name",CSSetup."Phys. Inv Jour Temp Name");
        // ItemJournalLine.SETRANGE("Journal Batch Name",USERID);
        // ItemJournalLine.SETRANGE("Location Code",CSPhysInventoryHandling."Location Code");
        // ItemJournalLine.MODIFYALL("External Document No.",'MOBILE',TRUE);
    end;

    local procedure TransferDataLine(CSPhysInventoryHandling: Record "NPR CS Phys. Inv. Handl."): Boolean
    var
        ItemJournalLine: Record "Item Journal Line";
        NewItemJournalLine: Record "Item Journal Line";
        LineNo: Integer;
        ItemJnlTemplate: Record "Item Journal Template";
        ItemJnlBatch: Record "Item Journal Batch";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
    begin
        Clear(ItemJournalLine);
        ItemJournalLine.SetRange("Journal Template Name", CSPhysInventoryHandling."Journal Template Name");
        ItemJournalLine.SetRange("Journal Batch Name", CSPhysInventoryHandling."Journal Batch Name");
        ItemJournalLine.SetRange("Location Code", CSPhysInventoryHandling."Location Code");
        ItemJournalLine.SetRange("Bin Code", CSPhysInventoryHandling."Bin Code");
        ItemJournalLine.SetRange("Item No.", CSPhysInventoryHandling."Item No.");
        ItemJournalLine.SetRange("Variant Code", CSPhysInventoryHandling."Variant Code");
        if not ItemJournalLine.FindSet then begin
            Clear(NewItemJournalLine);
            NewItemJournalLine.SetRange("Journal Template Name", CSPhysInventoryHandling."Journal Template Name");
            NewItemJournalLine.SetRange("Journal Batch Name", CSPhysInventoryHandling."Journal Batch Name");
            LineNo := 0;
            if NewItemJournalLine.FindLast then
                LineNo := NewItemJournalLine."Line No." + 1000
            else
                LineNo := 1000;

            Clear(ItemJournalLine);
            ItemJournalLine.Validate("Journal Template Name", CSPhysInventoryHandling."Journal Template Name");
            ItemJournalLine.Validate("Journal Batch Name", CSPhysInventoryHandling."Journal Batch Name");
            ItemJournalLine."Line No." := LineNo;
            ItemJournalLine.Insert(true);

            ItemJournalLine.Validate("Entry Type", ItemJournalLine."Entry Type"::"Positive Adjmt.");
            ItemJournalLine.Validate("Item No.", CSPhysInventoryHandling."Item No.");
            ItemJournalLine.Validate("Variant Code", CSPhysInventoryHandling."Variant Code");
            ItemJournalLine.Validate("Location Code", CSPhysInventoryHandling."Location Code");
            ItemJournalLine.Validate("Phys. Inventory", true);
            ItemJournalLine.Validate("Qty. (Phys. Inventory)", CSPhysInventoryHandling.Qty);
            ItemJournalLine.Validate("Bin Code", CSPhysInventoryHandling."Bin Code");
            ItemJournalLine."Posting Date" := WorkDate;
            ItemJournalLine."Document Date" := WorkDate;
            ItemJournalLine.Validate("External Document No.", 'MOBILE');
            ItemJournalLine.Validate("Changed by User", true);

            ItemJnlTemplate.Get(ItemJournalLine."Journal Template Name");
            ItemJnlBatch.Get(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");

            Clear(NoSeriesMgt);
            ItemJournalLine."Document No." := NoSeriesMgt.GetNextNo(ItemJnlBatch."No. Series", ItemJournalLine."Posting Date", false);
            ItemJournalLine."Source Code" := ItemJnlTemplate."Source Code";
            ItemJournalLine."Reason Code" := ItemJnlBatch."Reason Code";
            ItemJournalLine."Posting No. Series" := ItemJnlBatch."Posting No. Series";
            ItemJournalLine.Modify(true);
        end else begin
            ItemJournalLine.Validate("Qty. (Phys. Inventory)", CSPhysInventoryHandling.Qty);
            ItemJournalLine.Validate("Changed by User", true);
            ItemJournalLine.Modify(true);
        end;

        exit(true);
    end;

    local procedure AddSummarize(var Records: DotNet NPRNetXmlElement; CSPhysInventoryHandling: Record "NPR CS Phys. Inv. Handl."): Boolean
    var
        "Record": DotNet NPRNetXmlElement;
        Line: DotNet NPRNetXmlElement;
        Indicator: Text;
        LineType: Option TEXT,BUTTON;
        CurrRecordID: RecordID;
        TableNo: Integer;
        CSItemReclassHandling: Record "NPR CS Item Reclass. Handling";
        CSSetup: Record "NPR CS Setup";
        ItemJournalLine: Record "Item Journal Line";
        Item: Record Item;
    begin
        SelectLatestVersion;

        CSSetup.Get;
        CSSetup.TestField("Phys. Inv Jour Temp Name");

        Clear(ItemJournalLine);
        ItemJournalLine.SetRange("Journal Template Name", CSSetup."Phys. Inv Jour Temp Name");
        ItemJournalLine.SetRange("Journal Batch Name", UserId);
        ItemJournalLine.SetRange("Location Code", CSPhysInventoryHandling."Location Code");
        ItemJournalLine.SetRange("Bin Code", CSPhysInventoryHandling."Bin Code");
        if ItemJournalLine.FindSet then begin
            Records := DOMxmlin.CreateElement('Records');
            repeat
                Record := DOMxmlin.CreateElement('Record');

                CurrRecordID := ItemJournalLine.RecordId;
                TableNo := CurrRecordID.TableNo;

                if ItemJournalLine."Changed by User" then
                    Indicator := 'ok'
                else
                    Indicator := 'minus';

                if Indicator = 'minus' then begin
                    if CSUIHeader."Expand Summary Items" then begin
                        //1
                        Line := DOMxmlin.CreateElement('Line');
                        AddAttribute(Line, 'Descrip', ItemJournalLine.FieldCaption(Description));
                        AddAttribute(Line, 'Indicator', Indicator);
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        AddAttribute(Line, 'CollapsItems', 'FALSE');
                        Line.InnerText := ItemJournalLine."Bin Code";
                        Record.AppendChild(Line);

                        //2
                        Line := DOMxmlin.CreateElement('Line');
                        AddAttribute(Line, 'Descrip', ItemJournalLine.FieldCaption("Qty. (Calculated)"));
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        Line.InnerText := StrSubstNo(Text030, ItemJournalLine."Qty. (Calculated)", ItemJournalLine."Qty. (Phys. Inventory)", ItemJournalLine.Quantity);
                        Record.AppendChild(Line);

                        //3
                        Line := DOMxmlin.CreateElement('Line');
                        AddAttribute(Line, 'Descrip', ItemJournalLine.FieldCaption("Item No."));
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        if ItemJournalLine."Variant Code" <> '' then
                            Line.InnerText := StrSubstNo(Text027, ItemJournalLine."Item No.", ItemJournalLine."Variant Code")
                        else
                            Line.InnerText := ItemJournalLine."Item No.";
                        Record.AppendChild(Line);

                        //4
                        Line := DOMxmlin.CreateElement('Line');
                        AddAttribute(Line, 'Descrip', ItemJournalLine.FieldCaption("Unit of Measure Code"));
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        Line.InnerText := ItemJournalLine."Unit of Measure Code";
                        Record.AppendChild(Line);

                        //5
                        Item.Get(ItemJournalLine."Item No.");
                        Line := DOMxmlin.CreateElement('Line');
                        AddAttribute(Line, 'Descrip', ItemJournalLine.FieldCaption(Description));
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
                        Line.InnerText := StrSubstNo(Text015, ItemJournalLine.Quantity, ItemJournalLine."Qty. (Calculated)", ItemJournalLine."Item No.", ItemJournalLine.Description);
                        //Line.InnerText := STRSUBSTNO(Text015,ItemJournalLine."Qty. (Phys. Inventory)",ItemJournalLine.Quantity,ItemJournalLine."Item No.",ItemJournalLine.Description);
                        Record.AppendChild(Line);

                        Line := DOMxmlin.CreateElement('Line');
                        AddAttribute(Line, 'Descrip', ItemJournalLine.FieldCaption("Item No."));
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        Line.InnerText := ItemJournalLine."Item No.";
                        Record.AppendChild(Line);

                        if (ItemJournalLine."Variant Code" <> '') then begin
                            Line := DOMxmlin.CreateElement('Line');
                            AddAttribute(Line, 'Descrip', ItemJournalLine.FieldCaption("Variant Code"));
                            AddAttribute(Line, 'Type', Format(LineType::TEXT));
                            Line.InnerText := ItemJournalLine."Variant Code";
                            Record.AppendChild(Line);
                        end;

                        Line := DOMxmlin.CreateElement('Line');
                        AddAttribute(Line, 'Descrip', ItemJournalLine.FieldCaption("Bin Code"));
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        Line.InnerText := ItemJournalLine."Bin Code";
                        Record.AppendChild(Line);
                    end;
                    Records.AppendChild(Record);
                end;
            until ItemJournalLine.Next = 0;

            if ItemJournalLine.FindSet then begin
                repeat
                    Record := DOMxmlin.CreateElement('Record');

                    CurrRecordID := ItemJournalLine.RecordId;
                    TableNo := CurrRecordID.TableNo;

                    if ItemJournalLine."Changed by User" then
                        Indicator := 'ok'
                    else
                        Indicator := 'minus';

                    if Indicator = 'ok' then begin
                        if CSUIHeader."Expand Summary Items" then begin
                            //1
                            Line := DOMxmlin.CreateElement('Line');
                            AddAttribute(Line, 'Descrip', ItemJournalLine.FieldCaption(Description));
                            AddAttribute(Line, 'Indicator', Indicator);
                            AddAttribute(Line, 'Type', Format(LineType::TEXT));
                            AddAttribute(Line, 'CollapsItems', 'FALSE');
                            Line.InnerText := ItemJournalLine."Bin Code";
                            Record.AppendChild(Line);

                            //2
                            Line := DOMxmlin.CreateElement('Line');
                            AddAttribute(Line, 'Descrip', ItemJournalLine.FieldCaption("Qty. (Calculated)"));
                            AddAttribute(Line, 'Type', Format(LineType::TEXT));
                            Line.InnerText := StrSubstNo(Text030, ItemJournalLine."Qty. (Calculated)", ItemJournalLine."Qty. (Phys. Inventory)", ItemJournalLine.Quantity);
                            Record.AppendChild(Line);

                            //3
                            Line := DOMxmlin.CreateElement('Line');
                            AddAttribute(Line, 'Descrip', ItemJournalLine.FieldCaption("Item No."));
                            AddAttribute(Line, 'Type', Format(LineType::TEXT));
                            if ItemJournalLine."Variant Code" <> '' then
                                Line.InnerText := StrSubstNo(Text027, ItemJournalLine."Item No.", ItemJournalLine."Variant Code")
                            else
                                Line.InnerText := ItemJournalLine."Item No.";
                            Record.AppendChild(Line);

                            //4
                            Line := DOMxmlin.CreateElement('Line');
                            AddAttribute(Line, 'Descrip', ItemJournalLine.FieldCaption("Unit of Measure Code"));
                            AddAttribute(Line, 'Type', Format(LineType::TEXT));
                            Line.InnerText := ItemJournalLine."Unit of Measure Code";
                            Record.AppendChild(Line);

                            //5
                            Item.Get(ItemJournalLine."Item No.");
                            Line := DOMxmlin.CreateElement('Line');
                            AddAttribute(Line, 'Descrip', ItemJournalLine.FieldCaption(Description));
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
                            Line.InnerText := StrSubstNo(Text015, ItemJournalLine.Quantity, ItemJournalLine."Qty. (Calculated)", ItemJournalLine."Item No.", ItemJournalLine.Description);
                            Record.AppendChild(Line);

                            Line := DOMxmlin.CreateElement('Line');
                            AddAttribute(Line, 'Descrip', ItemJournalLine.FieldCaption("Item No."));
                            AddAttribute(Line, 'Type', Format(LineType::TEXT));
                            Line.InnerText := ItemJournalLine."Item No.";
                            Record.AppendChild(Line);

                            if (ItemJournalLine."Variant Code" <> '') then begin
                                Line := DOMxmlin.CreateElement('Line');
                                AddAttribute(Line, 'Descrip', ItemJournalLine.FieldCaption("Variant Code"));
                                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                                Line.InnerText := ItemJournalLine."Variant Code";
                                Record.AppendChild(Line);
                            end;

                            Line := DOMxmlin.CreateElement('Line');
                            AddAttribute(Line, 'Descrip', ItemJournalLine.FieldCaption("Bin Code"));
                            AddAttribute(Line, 'Type', Format(LineType::TEXT));
                            Line.InnerText := ItemJournalLine."Bin Code";
                            Record.AppendChild(Line);
                        end;
                        Records.AppendChild(Record);
                    end;
                until ItemJournalLine.Next = 0;
            end;
            exit(true);
        end else
            exit(false);
    end;

    local procedure AddAttribute(var NewChild: DotNet NPRNetXmlNode; AttribName: Text[250]; AttribValue: Text[250])
    begin
        if XMLDOMMgt.AddAttribute(NewChild, AttribName, AttribValue) > 0 then
            Error(Text002, AttribName);
    end;

    procedure CalculateInventory(BaseItemJournalLine: Record "Item Journal Line"; var Item: Record Item; PostingDate: Date; ItemsNotOnInvt: Boolean; InclItemWithNoTrans: Boolean)
    var
        CalculateInventory: Report "Calculate Inventory";
        NewItemJournalLine: Record "Item Journal Line";
        LineNo: Integer;
        ItemJournalLine: Record "Item Journal Line";
        BinContent: Record "Bin Content";
        TestItem: Record Item;
    begin
        // CLEAR(CalculateInventory);
        // CalculateInventory.USEREQUESTPAGE(FALSE);
        // CalculateInventory.SETTABLEVIEW(Item);
        // CalculateInventory.SetItemJnlLine(ItemJournalLine);
        // CalculateInventory.InitializeRequest(PostingDate,ItemJournalLine."Document No.",ItemsNotOnInvt,InclItemWithNoTrans);
        // CalculateInventory.RUN;

        Clear(NewItemJournalLine);
        NewItemJournalLine.SetRange("Journal Template Name", BaseItemJournalLine."Journal Template Name");
        NewItemJournalLine.SetRange("Journal Batch Name", BaseItemJournalLine."Journal Batch Name");
        LineNo := 0;
        if NewItemJournalLine.FindLast then
            LineNo := NewItemJournalLine."Line No." + 1000
        else
            LineNo := 1000;

        Clear(BinContent);
        BinContent.SetRange("Location Code", BaseItemJournalLine."Location Code");
        BinContent.SetRange("Bin Code", BaseItemJournalLine."Bin Code");
        if BinContent.FindSet then begin
            repeat

                TestItem.Get(BinContent."Item No.");
                if not TestItem.Blocked then begin
                    BinContent.CalcFields(Quantity);

                    Clear(ItemJournalLine);
                    ItemJournalLine.Validate("Journal Template Name", BaseItemJournalLine."Journal Template Name");
                    ItemJournalLine.Validate("Journal Batch Name", BaseItemJournalLine."Journal Batch Name");
                    ItemJournalLine."Line No." := LineNo;
                    ItemJournalLine.Insert(true);

                    ItemJournalLine.Validate("Entry Type", ItemJournalLine."Entry Type"::"Positive Adjmt.");
                    ItemJournalLine.Validate("Item No.", BinContent."Item No.");
                    ItemJournalLine.Validate("Variant Code", BinContent."Variant Code");
                    ItemJournalLine.Validate("Location Code", BaseItemJournalLine."Location Code");
                    ItemJournalLine.Validate("Phys. Inventory", true);
                    //-NPR5.52 [368484]
                    //ItemJournalLine.VALIDATE("Qty. (Phys. Inventory)",BinContent.Quantity);
                    //+NPR5.52 [368484]
                    ItemJournalLine.Validate("Qty. (Calculated)", BinContent.Quantity);
                    ItemJournalLine.Validate("Bin Code", BinContent."Bin Code");
                    ItemJournalLine."Posting Date" := WorkDate;
                    ItemJournalLine."Document Date" := WorkDate;
                    ItemJournalLine.Validate("External Document No.", 'MOBILE');

                    ItemJournalLine."Document No." := BaseItemJournalLine."Document No.";
                    ItemJournalLine."Source Code" := BaseItemJournalLine."Source Code";
                    ItemJournalLine."Reason Code" := BaseItemJournalLine."Reason Code";
                    ItemJournalLine."Posting No. Series" := BaseItemJournalLine."Posting No. Series";
                    ItemJournalLine.Modify(true);
                    LineNo += 1000;
                end;
            until BinContent.Next = 0;
        end else
            Error(Text029, BaseItemJournalLine."Location Code", BaseItemJournalLine."Bin Code");
    end;
}

