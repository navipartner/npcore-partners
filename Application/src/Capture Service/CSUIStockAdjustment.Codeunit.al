codeunit 6151362 "NPR CS UI Stock Adjustment"
{
    TableNo = "NPR CS UI Header";

    trigger OnRun()
    var
        MiniformMgmt: Codeunit "NPR CS UI Management";
    begin
        MiniformMgmt.Initialize(
          MiniformHeader, Rec, DOMxmlin, ReturnedNode,
          RootNode, CSCommunication, CSUserId,
          CurrentCode, StackCode, WhseEmpId, LocationFilter, CSSessionId);

        if Code <> CurrentCode then
            PrepareData
        else
            ProcessInput;

        Clear(DOMxmlin);
    end;

    var
        MiniformHeader: Record "NPR CS UI Header";
        CSCommunication: Codeunit "NPR CS Communication";
        CSMgt: Codeunit "NPR CS Management";
        RecRef: RecordRef;
        DOMxmlin: XmlDocument;
        ReturnedNode: XmlNode;
        RootNode: XmlNode;
        CSUserId: Text[250];
        Remark: Text[250];
        WhseEmpId: Text[250];
        LocationFilter: Text[250];
        CurrentCode: Text[250];
        StackCode: Text[250];
        CSSessionId: Text;
        ActiveInputField: Integer;
        Text000: Label 'Function not Found.';
        Text005: Label 'Barcode is blank';
        Text006: Label 'No input Node found.';
        Text008: Label 'Input value Length Error';
        Text010: Label 'Barcode %1 doesn''t exist';
        Text011: Label 'Qty. is blank';
        Text013: Label 'Input value is not valid';
        Text014: Label 'Item %1 doesn''t exist';
        Text019: Label 'Bin Code is blank';
        Text020: Label 'Location Should not be DirectedPutAway/Pick';
        Text028: Label '%1 Item Journal';
        InventoryAdjCaption: Label 'Inventory adjusted to %1';
        AdjustInventoryCaption: Label 'Adjust inventory';
        LocationCodeErr: Label 'Location code is blank';
        BinCodeErr: Label 'Bin Code %1 is not valid or location has not been set';
        LocationErr: Label 'Location %1 can not be found';
        LocationMultipleNameErr: Label 'There are multiple locations with the name %1, please choose a location by code';
        EmployeeUnauthorizedErr: Label 'Employee is not authorized for this location: %1';
        SimpleInvJnlNameTxt: Label 'DEFAULT', Comment = 'The default name of the item journal';
        QuantityCoincideErr: Label 'Quantity in bin coincides with input quantity, nothing to adjust';
        AtributeErr: Label 'Failed to add the attribute: %1.';
        AdjustingFailedErr: Label 'Adjustment could not be done because posting failed. Error: %1';
        MissingBarcodeErr: Label 'Barcode must be scanned before adjustment can be done';
        Text029: Label 'Adjustment for item %1 : %2 to Bin %3 is already added for posting';
        NoBinsForLocation: Label 'Bin Code must not be specified for location %1';

    local procedure ProcessInput()
    var
        FuncGroup: Record "NPR CS UI Function Group";
        CSWarehouseActivityHandling: Record "NPR CS Wareh. Activ. Handling";
        RecId: RecordID;
        TextValue: Text[250];
        FuncValue: Text;
        FuncName: Code[10];
        TableNo: Integer;
        FldNo: Integer;
        FuncFieldId: Integer;
        Step: Integer;
    begin
        if RootNode.AsXmlAttribute().SelectSingleNode('Header/Input', ReturnedNode) then
            TextValue := ReturnedNode.AsXmlElement().InnerText
        else
            Error(Text006);

        Evaluate(TableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'RecordID'));
        if RecRef.Get(RecId) then begin
            RecRef.SetTable(CSWarehouseActivityHandling);
            RecRef.SetRecFilter;
            CSCommunication.SetRecRef(RecRef);
        end else begin
            CSCommunication.RunPreviousUI(DOMxmlin);
            exit;
        end;

        FuncGroup.KeyDef := CSCommunication.GetFunctionKey(MiniformHeader.Code, TextValue);
        ActiveInputField := 1;

        GetDefault(CSWarehouseActivityHandling);

        case FuncGroup.KeyDef of
            FuncGroup.KeyDef::Esc:
                begin
                    DeleteEmptyDataLines;
                    CSCommunication.RunPreviousUI(DOMxmlin);
                end;
            FuncGroup.KeyDef::"Function":
                begin
                    FuncName := CSCommunication.GetNodeAttribute(ReturnedNode, 'FuncName');

                    if FuncName = 'DEFAULT' then begin
                        FuncValue := CSCommunication.GetNodeAttribute(ReturnedNode, 'FuncValue');
                        Evaluate(FuncFieldId, CSCommunication.GetNodeAttribute(ReturnedNode, 'FieldID'));

                        case FuncFieldId of
                            CSWarehouseActivityHandling.FieldNo("Location Code"):
                                CheckLocation(CSWarehouseActivityHandling, FuncValue);
                            CSWarehouseActivityHandling.FieldNo("Bin Code"):
                                CheckBin(CSWarehouseActivityHandling, FuncValue);
                        end;

                        AddDefault(FuncFieldId, FuncValue);

                        Input(CSWarehouseActivityHandling, FuncFieldId, 0);
                    end;
                end;
            FuncGroup.KeyDef::Register:
                begin
                    Adjust(CSWarehouseActivityHandling);

                    if Remark > '' then
                        SendForm(ActiveInputField);
                end;
            FuncGroup.KeyDef::Input:
                begin
                    Evaluate(FldNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'FieldID'));
                    case FldNo of
                        CSWarehouseActivityHandling.FieldNo(Barcode):
                            begin
                                CheckBarcode(CSWarehouseActivityHandling, TextValue);
                                Step := 1;
                            end;
                        CSWarehouseActivityHandling.FieldNo(Qty):
                            begin
                                ChangeQty(CSWarehouseActivityHandling, TextValue);
                                Step := 1;
                            end;
                        CSWarehouseActivityHandling.FieldNo("Bin Code"):
                            begin
                                CheckBin(CSWarehouseActivityHandling, TextValue);

                                AddDefault(FldNo, TextValue);
                            end;
                        else
                            CSCommunication.FieldSetvalue(RecRef, FldNo, TextValue);
                    end;

                    Input(CSWarehouseActivityHandling, FldNo, Step);
                end;
            else
                Error(Text000);
        end;

        if not (FuncGroup.KeyDef = FuncGroup.KeyDef::Esc) then
            SendForm(ActiveInputField);
    end;

    local procedure PrepareData()
    var
        CSWarehouseActivityHandling: Record "NPR CS Wareh. Activ. Handling";
        RecId: RecordID;
    begin
        DeleteEmptyDataLines;

        CreateDataLine(CSWarehouseActivityHandling);

        RecId := CSWarehouseActivityHandling.RecordId;

        RecRef.Open(RecId.TableNo);
        RecRef.Get(RecId);
        RecRef.SetRecFilter;

        CSCommunication.SetRecRef(RecRef);
        ActiveInputField := 1;

        SendForm(ActiveInputField);
    end;

    local procedure SendForm(InputField: Integer)
    begin
        CSCommunication.EncodeUI(MiniformHeader, StackCode, DOMxmlin, InputField, Remark, CSUserId);
        CSCommunication.GetReturnXML(DOMxmlin);

        AddAdditionalInfo(DOMxmlin);

        CSMgt.SendXMLReply(DOMxmlin);
    end;

    local procedure CheckLocation(var CSWarehouseActivityHandling: Record "NPR CS Wareh. Activ. Handling"; InputValue: Text): Code[10]
    var
        Location: Record Location;
        WarehouseEmployee: Record "Warehouse Employee";
    begin
        ClearLastError;

        if InputValue = '' then begin
            Remark := LocationCodeErr;
            exit;
        end;

        if StrLen(InputValue) > MaxStrLen(CSWarehouseActivityHandling."Location Code") then begin
            Remark := Text008;
            exit;
        end;

        if not Location.Get(InputValue) then begin
            Location.SetRange(Name, InputValue);
            case Location.Count of
                1:
                    Location.FindFirst;
                0:
                    begin
                        Remark := StrSubstNo(LocationErr, InputValue);
                        exit;
                    end;
                else begin
                        Remark := StrSubstNo(LocationMultipleNameErr, InputValue);
                        exit;
                    end;
            end;
        end;

        if not WarehouseEmployee.Get(CSWarehouseActivityHandling."Created By", InputValue) then begin
            Remark := StrSubstNo(EmployeeUnauthorizedErr, InputValue);
            exit;
        end;

        if Location."Directed Put-away and Pick" then
            Remark := Text020;
        CSWarehouseActivityHandling."Location Code" := InputValue;
    end;

    local procedure CheckBarcode(var CSWarehouseActivityHandling: Record "NPR CS Wareh. Activ. Handling"; InputValue: Text)
    var
        BarcodeLibrary: Codeunit "NPR Barcode Library";
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
        Item: Record Item;
        ItemCrossReference: Record "Item Cross Reference";
        ItemJnlTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalLine: Record "Item Journal Line";
    begin
        if InputValue = '' then begin
            Remark := Text005;
            exit;
        end;

        if StrLen(InputValue) > MaxStrLen(CSWarehouseActivityHandling.Barcode) then begin
            Remark := Text008;
            exit;
        end;

        if BarcodeLibrary.TranslateBarcodeToItemVariant(InputValue, ItemNo, VariantCode, ResolvingTable, true) then begin
            if not Item.Get(ItemNo) then begin
                Remark := StrSubstNo(Text014, InputValue);
                exit;
            end;

            CSWarehouseActivityHandling."Item No." := ItemNo;
            CSWarehouseActivityHandling."Variant Code" := VariantCode;

            if CSWarehouseActivityHandling."Bin Code" <> '' then begin
                ItemJnlTemplate.SetRange(Type, ItemJnlTemplate.Type::Item);
                if ItemJnlTemplate.FindFirst then begin

                    if ItemJournalBatch.Get(ItemJnlTemplate.Name, UserId) then begin
                        Clear(ItemJournalLine);
                        ItemJournalLine.SetRange("Journal Template Name", ItemJournalBatch."Journal Template Name");
                        ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);
                        ItemJournalLine.SetRange("Item No.", CSWarehouseActivityHandling."Item No.");
                        ItemJournalLine.SetRange("Variant Code", CSWarehouseActivityHandling."Variant Code");
                        ItemJournalLine.SetRange("Bin Code", CSWarehouseActivityHandling."Bin Code");
                        if ItemJournalLine.FindFirst then begin
                            Remark := StrSubstNo(Text029, CSWarehouseActivityHandling."Item No.", CSWarehouseActivityHandling."Variant Code", CSWarehouseActivityHandling."Bin Code");
                            exit;
                        end;
                    end;

                end;
            end;

            if (ResolvingTable = DATABASE::"Item Cross Reference") then begin
                with ItemCrossReference do begin
                    if (StrLen(InputValue) <= MaxStrLen("Cross-Reference No.")) then begin
                        SetCurrentKey("Cross-Reference Type", "Cross-Reference No.");
                        SetFilter("Cross-Reference Type", '=%1', "Cross-Reference Type"::"Bar Code");
                        SetFilter("Cross-Reference No.", '=%1', UpperCase(InputValue));
                        if FindFirst() then
                            CSWarehouseActivityHandling."Unit of Measure" := ItemCrossReference."Unit of Measure";
                    end;
                end;
            end;
        end else begin
            Remark := StrSubstNo(Text010, InputValue);
            exit;
        end;

        UpdateCurrentQtyOnStock(CSWarehouseActivityHandling);
        CSWarehouseActivityHandling.Barcode := InputValue;
    end;

    local procedure ChangeQty(var CSWarehouseActivityHandling: Record "NPR CS Wareh. Activ. Handling"; InputValue: Text)
    var
        Qty: Decimal;
    begin
        if InputValue = '' then begin
            Remark := Text011;
            exit;
        end;

        if not Evaluate(Qty, InputValue) then begin
            Remark := Text013;
            exit;
        end;

        CSWarehouseActivityHandling.Qty := Qty;
    end;

    local procedure CheckBin(var CSWarehouseActivityHandling: Record "NPR CS Wareh. Activ. Handling"; InputValue: Text)
    var
        Bin: Record Bin;
        ItemJnlTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalLine: Record "Item Journal Line";
    begin
        if CSWarehouseActivityHandling."Location Code" = '' then begin
            Remark := LocationCodeErr;
            exit;
        end;

        if not IsBinEnabledLocation(CSWarehouseActivityHandling."Location Code") then begin
            if InputValue <> '' then
                Remark := StrSubstNo(NoBinsForLocation, CSWarehouseActivityHandling."Location Code");
            CSWarehouseActivityHandling."Bin Code" := '';
            exit;
        end;

        if InputValue = '' then begin
            Remark := Text019;
            exit;
        end;

        if StrLen(InputValue) > MaxStrLen(Bin.Code) then begin
            Remark := Text008;
            exit;
        end;

        if not Bin.Get(CSWarehouseActivityHandling."Location Code", InputValue) then begin
            Remark := StrSubstNo(BinCodeErr, InputValue);
            exit;
        end;

        if CSWarehouseActivityHandling."Item No." <> '' then begin
            ItemJnlTemplate.SetRange(Type, ItemJnlTemplate.Type::Item);
            if ItemJnlTemplate.FindFirst then begin

                if ItemJournalBatch.Get(ItemJnlTemplate.Name, UserId) then begin
                    Clear(ItemJournalLine);
                    ItemJournalLine.SetRange("Journal Template Name", ItemJournalBatch."Journal Template Name");
                    ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);
                    ItemJournalLine.SetRange("Item No.", CSWarehouseActivityHandling."Item No.");
                    ItemJournalLine.SetRange("Variant Code", CSWarehouseActivityHandling."Variant Code");
                    ItemJournalLine.SetRange("Bin Code", InputValue);
                    if ItemJournalLine.FindFirst then begin
                        Remark := StrSubstNo(Text029, CSWarehouseActivityHandling."Item No.", CSWarehouseActivityHandling."Variant Code", InputValue);
                        exit;
                    end;
                end;

            end;
        end;

        CSWarehouseActivityHandling."Bin Code" := InputValue;
    end;

    local procedure CreateDataLine(var CSWarehouseActivityHandling: Record "NPR CS Wareh. Activ. Handling")
    var
        NewCSWarehouseActivityHandling: Record "NPR CS Wareh. Activ. Handling";
        LineNo: Integer;
    begin
        Clear(NewCSWarehouseActivityHandling);
        NewCSWarehouseActivityHandling.SetRange(Id, CSSessionId);
        if NewCSWarehouseActivityHandling.FindLast then
            LineNo := NewCSWarehouseActivityHandling."Line No." + 1
        else
            LineNo := 1;

        with CSWarehouseActivityHandling do begin
            Init;
            Id := CSSessionId;
            "Line No." := LineNo;

            Insert(true);

            "Created By" := UserId;
            Created := CurrentDateTime;

            Modify;
        end;
    end;

    local procedure DeleteEmptyDataLines()
    var
        CSWarehouseActivityHandling: Record "NPR CS Wareh. Activ. Handling";
    begin
        CSWarehouseActivityHandling.SetRange(Id, CSSessionId);
        CSWarehouseActivityHandling.SetRange(Handled, false);
        CSWarehouseActivityHandling.SetRange("Transferred to Document", false);
        CSWarehouseActivityHandling.DeleteAll(true);
    end;

    local procedure Adjust(CSWarehouseActivityHandling: Record "NPR CS Wareh. Activ. Handling")
    var
        ItemJnlTemplate: Record "Item Journal Template";
        NewItemJournalLine: Record "Item Journal Line";
        ItemJournalLine: Record "Item Journal Line";
        OffsetQty: Decimal;
        PostingFinished: Boolean;
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
        LineNo: Integer;
        PostingRecRef: RecordRef;
        CSPostEnqueue: Codeunit "NPR CS Post - Enqueue";
        CSPostingBuffer: Record "NPR CS Posting Buffer";
        CSSetup: Record "NPR CS Setup";
    begin
        Clear(Remark);

        if CSWarehouseActivityHandling.Barcode = '' then begin
            Remark := MissingBarcodeErr;
            exit;
        end;

        OffsetQty := CSWarehouseActivityHandling.Qty - CSWarehouseActivityHandling."Qty. in Stock";  //NPR5.55 [384923]
        if OffsetQty = 0 then begin
            Remark := QuantityCoincideErr;
            exit;
        end;

        ItemJnlTemplate.SetRange(Type, ItemJnlTemplate.Type::Item);
        ItemJnlTemplate.FindFirst;

        if not ItemJournalBatch.Get(ItemJnlTemplate.Name, UserId) then begin
            ItemJournalBatch.Init;
            ItemJournalBatch.Validate("Journal Template Name", ItemJnlTemplate.Name);
            ItemJournalBatch.Validate(Name, UserId);
            ItemJournalBatch.Description := StrSubstNo(Text028, UserId);
            ItemJournalBatch.Insert(true);
        end;

        Clear(NewItemJournalLine);
        NewItemJournalLine.SetRange("Journal Template Name", ItemJournalBatch."Journal Template Name");
        NewItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);
        if NewItemJournalLine.FindLast then
            LineNo := NewItemJournalLine."Line No." + 1000
        else
            LineNo := 1000;

        Clear(ItemJournalLine);
        ItemJournalLine.Validate("Journal Template Name", ItemJournalBatch."Journal Template Name");
        ItemJournalLine.Validate("Journal Batch Name", ItemJournalBatch.Name);
        ItemJournalLine."Line No." := LineNo;
        ItemJournalLine.Insert(true);

        if OffsetQty > 0 then
            ItemJournalLine.Validate("Entry Type", ItemJournalLine."Entry Type"::"Positive Adjmt.")
        else
            ItemJournalLine.Validate("Entry Type", ItemJournalLine."Entry Type"::"Negative Adjmt.");

        ItemJournalLine.Validate("Item No.", CSWarehouseActivityHandling."Item No.");
        ItemJournalLine.Validate(Description, CSWarehouseActivityHandling."Item Description");
        ItemJournalLine.Validate("Variant Code", CSWarehouseActivityHandling."Variant Code");
        ItemJournalLine.Validate("Location Code", CSWarehouseActivityHandling."Location Code");
        ItemJournalLine.Validate(Quantity, Abs(OffsetQty));
        ItemJournalLine.Validate("Bin Code", CSWarehouseActivityHandling."Bin Code");
        ItemJournalLine.Validate("Posting Date", Today);
        ItemJournalLine."Document Date" := WorkDate;
        ItemJournalLine.Validate("External Document No.", CSSessionId);
        ItemJournalLine.Validate("Changed by User", true);
        ItemJournalLine."Document No." := Format(Today);
        ItemJournalLine.Modify(true);

        CSSetup.Get;
        if CSSetup."Post with Job Queue" then begin
            PostingRecRef.GetTable(ItemJournalBatch);
            CSPostingBuffer.Init;
            CSPostingBuffer."Table No." := PostingRecRef.Number;
            CSPostingBuffer."Record Id" := PostingRecRef.RecordId;
            CSPostingBuffer."Job Type" := CSPostingBuffer."Job Type"::"Unplanned Count";
            CSPostingBuffer."Session Id" := CSSessionId;
            if CSPostingBuffer.Insert(true) then begin
                CSPostEnqueue.Run(CSPostingBuffer);
                PostingFinished := true;
            end else
                Remark := GetLastErrorText;
        end else begin
            Commit;
            PostingFinished := CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post Batch", ItemJournalLine);
        end;

        if not PostingFinished then begin
            Remark := CopyStr(GetLastErrorText, 1, MaxStrLen(Remark));
            exit;
        end;

        UpdateCurrentQtyOnStock(CSWarehouseActivityHandling);
        Clear(CSWarehouseActivityHandling.Qty);
        Clear(CSWarehouseActivityHandling.Barcode);
        Input(CSWarehouseActivityHandling, CSWarehouseActivityHandling.FieldNo(Barcode), 0);
    end;

    local procedure Input(CSWarehouseActivityHandling: Record "NPR CS Wareh. Activ. Handling"; FldNo: Integer; Step: Integer)
    var
        CSFieldDefaults: Record "NPR CS Field Defaults";
        CSWarehouseActivityHandling2: Record "NPR CS Wareh. Activ. Handling";
    begin
        CSWarehouseActivityHandling.Modify;

        RecRef.GetTable(CSWarehouseActivityHandling);
        CSCommunication.SetRecRef(RecRef);
        ActiveInputField := CSCommunication.GetActiveInputNo(CurrentCode, FldNo);
        if Remark = '' then
            if CSCommunication.LastEntryField(CurrentCode, FldNo) then begin
                CSFieldDefaults.SetRange(Id, CSUserId);
                CSFieldDefaults.SetRange("Use Case Code", CurrentCode);
                if CSFieldDefaults.FindSet then begin
                    repeat
                        CSCommunication.FieldSetvalue(RecRef, CSFieldDefaults."Field No", CSFieldDefaults.Value);
                        RecRef.SetTable(CSWarehouseActivityHandling);
                        RecRef.SetRecFilter;
                        CSCommunication.SetRecRef(RecRef);
                    until CSFieldDefaults.Next = 0;
                end;

                ActiveInputField := 1;
            end else
                ActiveInputField += Step;
    end;

    local procedure CreateItemBatch(TemplateName: Code[10]): Code[10]
    var
        ItemJournalBatch: Record "Item Journal Batch";
    begin
        ItemJournalBatch.Init;
        ItemJournalBatch."Journal Template Name" := TemplateName;
        ItemJournalBatch.Name := CreateBatchName;
        ItemJournalBatch.Description := SimpleInvJnlNameTxt;
        ItemJournalBatch.Insert;

        exit(ItemJournalBatch.Name);
    end;

    local procedure DeleteItemBatch(TemplateName: Code[10]; BatchName: Code[10])
    var
        ItemJournalBatch: Record "Item Journal Batch";
    begin

    end;

    local procedure CreateBatchName(): Code[10]
    var
        GuidStr: Text;
        BatchName: Text;
    begin
        GuidStr := Format(CreateGuid);

        // Remove numbers to avoid batch name change by INCSTR in codeunit 23
        BatchName := ConvertStr(GuidStr, '1234567890-', 'GHIJKLMNOPQ');
        exit(CopyStr(BatchName, 2, 10));
    end;

    local procedure AddAdditionalInfo(var xmlout: XmlDocument)
    var
        CurrentRootElement: XmlElement;
        XMLFunctionNode: XmlNode;
        StrMenuTxt: Text;
    begin
        xmlout.GetRoot(CurrentRootElement);

        CurrentRootElement.SelectSingleNode('Header/Functions', ReturnedNode);

        foreach XMLFunctionNode in ReturnedNode.AsXmlElement().GetChildNodes() do begin
            if (XMLFunctionNode.AsXmlElement().InnerText = 'REGISTER') then
                AddAttribute(XMLFunctionNode, 'Actions', AdjustInventoryCaption);
        end;
    end;

    local procedure AddAttribute(var NewChild: XmlNode; AttribName: Text[250]; AttribValue: Text[250])
    begin
        NewChild.AsXmlElement().SetAttribute(AttribName, AttribValue);
    end;

    local procedure AddDefault(FieldId: Integer; FuncValue: Text)
    var
        CSFieldDefaults: Record "NPR CS Field Defaults";
    begin
        if CSFieldDefaults.Get(CSUserId, CurrentCode, FieldId) then begin
            CSFieldDefaults.Value := FuncValue;
            CSFieldDefaults.Modify;
        end else begin
            Clear(CSFieldDefaults);
            CSFieldDefaults.Id := CSUserId;
            CSFieldDefaults."Use Case Code" := CurrentCode;
            CSFieldDefaults."Field No" := FieldId;
            CSFieldDefaults.Insert;
            CSFieldDefaults.Value := FuncValue;
            CSFieldDefaults.Modify;
        end;
    end;

    local procedure GetDefault(var CSWarehouseActivityHandling: Record "NPR CS Wareh. Activ. Handling")
    var
        CSFieldDefaults: Record "NPR CS Field Defaults";
    begin
        CSFieldDefaults.SetRange(Id, CSUserId);
        CSFieldDefaults.SetRange("Use Case Code", CurrentCode);

        if CSWarehouseActivityHandling."Location Code" = '' then begin
            CSFieldDefaults.SetRange("Field No", CSWarehouseActivityHandling.FieldNo("Location Code"));
            if CSFieldDefaults.FindFirst then
                CSWarehouseActivityHandling."Location Code" := CSFieldDefaults.Value;
        end;

        if CSWarehouseActivityHandling."Bin Code" = '' then begin
            CSFieldDefaults.SetRange("Field No", CSWarehouseActivityHandling.FieldNo("Bin Code"));
            if CSFieldDefaults.FindFirst then
                CSWarehouseActivityHandling."Bin Code" := CSFieldDefaults.Value;
        end;
    end;

    local procedure IsBinEnabledLocation(LocationCode: Code[10]): Boolean
    var
        Location: Record Location;
    begin
        exit(Location.Get(LocationCode) and Location."Bin Mandatory");
    end;

    local procedure UpdateCurrentQtyOnStock(var CSWarehouseActivityHandling: Record "NPR CS Wareh. Activ. Handling")
    begin
        if IsBinEnabledLocation(CSWarehouseActivityHandling."Location Code") then begin
            CSWarehouseActivityHandling.CalcFields("Bin Base Qty.");
            CSWarehouseActivityHandling."Qty. in Stock" := CSWarehouseActivityHandling."Bin Base Qty.";
        end else begin
            CSWarehouseActivityHandling.CalcFields(Inventory);
            CSWarehouseActivityHandling."Qty. in Stock" := CSWarehouseActivityHandling.Inventory;
        end;
    end;
}
