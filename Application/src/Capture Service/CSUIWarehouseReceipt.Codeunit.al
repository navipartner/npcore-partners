codeunit 6151388 "NPR CS UI Warehouse Receipt"
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
        ActiveInputField: Integer;
        CSSessionId: Text;
        Text000: Label 'Function not Found.';
        Text002: Label 'Failed to add the attribute: %1.';
        Text004: Label 'Invalid %1.';
        Text005: Label 'Barcode is blank';
        Text006: Label 'No input Node found.';
        Text007: Label 'Record not found.';
        Text008: Label 'Input value Length Error';
        Text009: Label 'Shelf  No. is blank';
        Text010: Label 'Barcode %1 doesn''t exist';
        Text011: Label 'Qty. is blank';
        Text012: Label 'No Lines available.';
        Text013: Label 'Input value is not valid';
        Text014: Label 'Item %1 doesn''t exist';
        Text015: Label '%1/%2 : %3 %4';
        Text016: Label 'Qty. to Receive exceed Outstanding Qty.';
        Text017: Label 'Bin Code %1 is not valid';
        Text018: Label 'Bin Code %1 is already selected for this line';
        Text019: Label 'Bin Code is blank';
        Text020: Label 'Variant is not a record';
        Text021: Label 'Item %1 not found on doc. %2';
        Text026: Label '%1 / %2';
        Text027: Label '%1 | %2';

    local procedure ProcessInput()
    var
        FuncGroup: Record "NPR CS UI Function Group";
        RecId: RecordID;
        TextValue: Text[250];
        TableNo: Integer;
        FldNo: Integer;
        FuncRecId: RecordID;
        FuncTableNo: Integer;
        FuncRecRef: RecordRef;
        FuncFieldId: Integer;
        FuncName: Code[10];
        FuncValue: Text;
        CSWarehouseReceiptHandling: Record "NPR CS Wareh. Receipt Handl.";
        CSWarehouseReceiptHandling2: Record "NPR CS Wareh. Receipt Handl.";
        CSFieldDefaults: Record "NPR CS Field Defaults";
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
        CommaString: DotNet NPRNetString;
        Values: DotNet NPRNetArray;
        Separator: DotNet NPRNetString;
        Value: Text;
    begin
        if RootNode.AsXmlAttribute().SelectSingleNode('Header/Input', ReturnedNode) then
            TextValue := ReturnedNode.AsXmlElement().InnerText
        else
            Error(Text006);

        Evaluate(TableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'RecordID'));
        if RecRef.Get(RecId) then begin
            RecRef.SetTable(CSWarehouseReceiptHandling);
            RecRef.SetRecFilter;
            CSCommunication.SetRecRef(RecRef);
        end else begin
            CSCommunication.RunPreviousUI(DOMxmlin);
            exit;
        end;

        FuncGroup.KeyDef := CSCommunication.GetFunctionKey(MiniformHeader.Code, TextValue);
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
                    end;
                end;
            FuncGroup.KeyDef::Reset:
                Reset(CSWarehouseReceiptHandling);
            FuncGroup.KeyDef::Register:
                begin
                    Register(CSWarehouseReceiptHandling);
                    if Remark = '' then begin
                        DeleteEmptyDataLines();
                        CSCommunication.RunPreviousUI(DOMxmlin)
                    end else
                        SendForm(ActiveInputField);
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
                                CSWarehouseReceiptHandling.FieldNo(Barcode):
                                    CheckBarcode(CSWarehouseReceiptHandling, Value);
                                CSWarehouseReceiptHandling.FieldNo(Qty):
                                    CheckQty(CSWarehouseReceiptHandling, Value);
                                CSWarehouseReceiptHandling.FieldNo("Bin Code"):
                                    CheckBin(CSWarehouseReceiptHandling, Value);
                                else begin
                                        CSCommunication.FieldSetvalue(RecRef, FldNo, Value);
                                    end;
                            end;

                            CSWarehouseReceiptHandling.Modify;

                            RecRef.GetTable(CSWarehouseReceiptHandling);
                            CSCommunication.SetRecRef(RecRef);
                            ActiveInputField := CSCommunication.GetActiveInputNo(CurrentCode, FldNo);
                            if Remark = '' then
                                if CSCommunication.LastEntryField(CurrentCode, FldNo) then begin

                                    Clear(CSFieldDefaults);
                                    CSFieldDefaults.SetRange(Id, CSUserId);
                                    CSFieldDefaults.SetRange("Use Case Code", CurrentCode);
                                    if CSFieldDefaults.FindSet then begin
                                        repeat
                                            CSCommunication.FieldSetvalue(RecRef, CSFieldDefaults."Field No", CSFieldDefaults.Value);
                                            RecRef.SetTable(CSWarehouseReceiptHandling);
                                            RecRef.SetRecFilter;
                                            CSCommunication.SetRecRef(RecRef);
                                        until CSFieldDefaults.Next = 0;
                                    end;

                                    UpdateDataLine(CSWarehouseReceiptHandling);
                                    CreateDataLine(CSWarehouseReceiptHandling2, CSWarehouseReceiptHandling);
                                    RecRef.GetTable(CSWarehouseReceiptHandling2);
                                    CSCommunication.SetRecRef(RecRef);
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
            SendForm(ActiveInputField);
    end;

    local procedure PrepareData()
    var
        WarehouseReceiptHeader: Record "Warehouse Receipt Header";
        CSWarehouseReceiptHandling: Record "NPR CS Wareh. Receipt Handl.";
        RecId: RecordID;
        TableNo: Integer;
    begin
        RootNode.SelectSingleNode('Header/Input', ReturnedNode);

        Evaluate(TableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'TableNo'));
        Evaluate(RecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'RecordID'));

        RecRef.Open(TableNo);
        RecRef.Get(RecId);
        RecRef.SetTable(WarehouseReceiptHeader);

        DeleteEmptyDataLines();
        CreateDataLine(CSWarehouseReceiptHandling, WarehouseReceiptHeader);

        RecRef.Close;

        RecId := CSWarehouseReceiptHandling.RecordId;

        RecRef.Open(RecId.TableNo);
        RecRef.Get(RecId);
        RecRef.SetRecFilter;

        CSCommunication.SetRecRef(RecRef);
        ActiveInputField := 1;
        SendForm(ActiveInputField);
    end;

    local procedure SendForm(InputField: Integer)
    var
        Records: XmlElement;
        RootElement: XmlElement;
    begin
        CSCommunication.EncodeUI(MiniformHeader, StackCode, DOMxmlin, InputField, Remark, CSUserId);
        CSCommunication.GetReturnXML(DOMxmlin);

        DOMxmlin.GetRoot(RootElement);
        if AddSummarize(Records) then
            RootElement.Add(Records);

        CSMgt.SendXMLReply(DOMxmlin);
    end;

    local procedure CheckBarcode(var CSWarehouseReceiptHandling: Record "NPR CS Wareh. Receipt Handl."; InputValue: Text)
    var
        BarcodeLibrary: Codeunit "NPR Barcode Library";
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
        Item: Record Item;
        ItemCrossReference: Record "Item Cross Reference";
    begin
        if InputValue = '' then begin
            Remark := Text005;
            exit;
        end;

        if StrLen(InputValue) > MaxStrLen(CSWarehouseReceiptHandling.Barcode) then begin
            Remark := Text008;
            exit;
        end;

        if BarcodeLibrary.TranslateBarcodeToItemVariant(InputValue, ItemNo, VariantCode, ResolvingTable, true) then begin
            if not Item.Get(ItemNo) then begin
                Remark := StrSubstNo(Text014, InputValue);
                exit;
            end;

            CSWarehouseReceiptHandling."Item No." := ItemNo;
            CSWarehouseReceiptHandling."Variant Code" := VariantCode;

            if (ResolvingTable = DATABASE::"Item Cross Reference") then begin
                with ItemCrossReference do begin
                    if (StrLen(InputValue) <= MaxStrLen("Cross-Reference No.")) then begin
                        SetCurrentKey("Cross-Reference Type", "Cross-Reference No.");
                        SetFilter("Cross-Reference Type", '=%1', "Cross-Reference Type"::"Bar Code");
                        SetFilter("Cross-Reference No.", '=%1', UpperCase(InputValue));
                        if FindFirst() then
                            CSWarehouseReceiptHandling."Unit of Measure" := ItemCrossReference."Unit of Measure";
                    end;
                end;
            end;
        end else begin
            Remark := StrSubstNo(Text010, InputValue);
            exit;
        end;

        CSWarehouseReceiptHandling.Barcode := InputValue;
    end;

    local procedure CheckQty(var CSWarehouseReceiptHandling: Record "NPR CS Wareh. Receipt Handl."; InputValue: Text)
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

        CSWarehouseReceiptHandling.Qty := Qty;
    end;

    local procedure CheckBin(var CSWarehouseReceiptHandling: Record "NPR CS Wareh. Receipt Handl."; InputValue: Text)
    var
        Bin: Record Bin;
    begin
        if InputValue = '' then begin
            Remark := Text019;
            exit;
        end;

        if (StrLen(InputValue) > MaxStrLen(Bin.Code)) then begin
            Remark := Text008;
            exit;
        end;

        if not Bin.Get(CSWarehouseReceiptHandling."Location Code", InputValue) then begin
            Remark := StrSubstNo(Text017, InputValue);
            exit;
        end;

        CSWarehouseReceiptHandling."Bin Code" := InputValue;
    end;

    local procedure CreateDataLine(var CSWarehouseReceiptHandling: Record "NPR CS Wareh. Receipt Handl."; RecordVariant: Variant)
    var
        NewCSWarehouseReceiptHandling: Record "NPR CS Wareh. Receipt Handl.";
        LineNo: Integer;
        RecRefByVariant: RecordRef;
        CSWarehouseReceiptHandlingByVar: Record "NPR CS Wareh. Receipt Handl.";
        WarehouseReceiptHeaderByVar: Record "Warehouse Receipt Header";
    begin
        if not RecordVariant.IsRecord then
            Error(Text020);

        Clear(NewCSWarehouseReceiptHandling);
        NewCSWarehouseReceiptHandling.SetRange(Id, CSSessionId);
        if NewCSWarehouseReceiptHandling.FindLast then
            LineNo := NewCSWarehouseReceiptHandling."Line No." + 1
        else
            LineNo := 1;

        CSWarehouseReceiptHandling.Init;
        CSWarehouseReceiptHandling.Id := CSSessionId;
        CSWarehouseReceiptHandling."Line No." := LineNo;
        CSWarehouseReceiptHandling."Created By" := UserId;
        CSWarehouseReceiptHandling.Created := CurrentDateTime;
        CSWarehouseReceiptHandling.Qty := NewCSWarehouseReceiptHandling.Qty;

        RecRefByVariant.GetTable(RecordVariant);

        CSWarehouseReceiptHandling."Table No." := RecRefByVariant.Number;

        if RecRefByVariant.Number = 7316 then begin
            WarehouseReceiptHeaderByVar := RecordVariant;
            CSWarehouseReceiptHandling."No." := WarehouseReceiptHeaderByVar."No.";
            CSWarehouseReceiptHandling."Assignment Date" := WarehouseReceiptHeaderByVar."Assignment Date";
            CSWarehouseReceiptHandling."Record Id" := WarehouseReceiptHeaderByVar.RecordId;
        end else begin
            CSWarehouseReceiptHandlingByVar := RecordVariant;
            CSWarehouseReceiptHandling."No." := CSWarehouseReceiptHandlingByVar."No.";
            CSWarehouseReceiptHandling."Assignment Date" := CSWarehouseReceiptHandlingByVar."Assignment Date";
            CSWarehouseReceiptHandling."Record Id" := CSWarehouseReceiptHandlingByVar.RecordId;
        end;

        CSWarehouseReceiptHandling.Insert(true);
    end;

    local procedure UpdateDataLine(var CSWarehouseReceiptHandling: Record "NPR CS Wareh. Receipt Handl.")
    begin
        CSWarehouseReceiptHandling.Handled := true;
        CSWarehouseReceiptHandling.Modify(true);

        if TransferDataLine(CSWarehouseReceiptHandling) then begin
            CSWarehouseReceiptHandling."Transferred to Document" := true;
            CSWarehouseReceiptHandling.Modify(true);
        end;
    end;

    local procedure DeleteEmptyDataLines()
    var
        CSWarehouseReceiptHandling: Record "NPR CS Wareh. Receipt Handl.";
    begin
        CSWarehouseReceiptHandling.SetRange(Id, CSSessionId);
        CSWarehouseReceiptHandling.SetRange(Handled, false);
        CSWarehouseReceiptHandling.DeleteAll(true);
    end;

    local procedure AddAttribute(var NewChild: XmlElement; AttribName: Text[250]; AttribValue: Text[250])
    begin
        NewChild.SetAttribute(AttribName, AttribValue);
    end;

    local procedure AddSummarize(var Records: XmlElement): Boolean
    var
        RecordElement: XmlElement;
        Line: XmlElement;
        Indicator: Text;
        CSWarehouseReceiptHandling: Record "NPR CS Wareh. Receipt Handl.";
        WhseReceiptLine: Record "Warehouse Receipt Line";
        LineType: Option TEXT,BUTTON;
        CurrRecordID: RecordID;
        TableNo: Integer;
        Location: Record Location;
        CSWarehouseActivitySetup: Record "NPR CS Wareh. Activ. Setup";
        ItemIdentifier: Text;
    begin
        Clear(CSWarehouseReceiptHandling);
        CSWarehouseReceiptHandling.SetRange(Id, CSSessionId);
        if not CSWarehouseReceiptHandling.FindLast then
            exit(false);

        WhseReceiptLine.SetRange("No.", CSWarehouseReceiptHandling."No.");
        if WhseReceiptLine.FindSet then begin
            Records := XmlElement.Create('Records');
            repeat
                RecordElement := XmlElement.Create('Record');

                CurrRecordID := WhseReceiptLine.RecordId;
                TableNo := CurrRecordID.TableNo;

                if (WhseReceiptLine."Qty. to Receive" < WhseReceiptLine."Qty. Outstanding") then
                    Indicator := 'minus'
                else
                    if (WhseReceiptLine."Qty. to Receive" = WhseReceiptLine."Qty. Outstanding") then
                        Indicator := 'ok'
                    else
                        Indicator := 'plus';

                if Indicator = 'minus' then begin
                    if MiniformHeader."Expand Summary Items" then begin
                        //1
                        Line := XmlElement.Create('Line', '', WhseReceiptLine."Bin Code");
                        AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption(Description));
                        AddAttribute(Line, 'Indicator', Indicator);
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        AddAttribute(Line, 'CollapsItems', 'FALSE');
                        RecordElement.Add(Line);

                        //2
                        Line := XmlElement.Create('Line', '',
                            StrSubstNo(Text026, WhseReceiptLine."Qty. to Receive", WhseReceiptLine."Qty. Outstanding"));
                        AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption("Qty. Outstanding"));
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        RecordElement.Add(Line);

                        //3
                        ItemIdentifier := CSWarehouseActivitySetup.ItemIdentifier(WhseReceiptLine.RecordId, true, ' | ');
                        Line := XmlElement.Create('Line', '', ItemIdentifier);
                        AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption("Item No."));
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        RecordElement.Add(Line);

                        //4
                        Line := XmlElement.Create('Line', '', WhseReceiptLine."Unit of Measure Code");
                        AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption("Unit of Measure Code"));
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        RecordElement.Add(Line);

                        //5
                        Line := XmlElement.Create('Line', '', WhseReceiptLine.Description);
                        AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption(Description));
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        RecordElement.Add(Line);

                        //6
                        Line := XmlElement.Create('Line', '', '');
                        AddAttribute(Line, 'Descrip', '');
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        RecordElement.Add(Line);

                        if Location.Get(WhseReceiptLine."Location Code") then
                            if Location."Bin Mandatory" then begin
                                Line := XmlElement.Create('Line');
                                AddAttribute(Line, 'Descrip', 'Split Line..');
                                AddAttribute(Line, 'Type', Format(LineType::BUTTON));
                                AddAttribute(Line, 'TableNo', Format(TableNo));
                                AddAttribute(Line, 'RecordID', Format(CurrRecordID));
                                AddAttribute(Line, 'FuncName', 'SPLITLINE');
                                RecordElement.Add(Line);
                            end;

                    end else begin
                        ItemIdentifier := CSWarehouseActivitySetup.ItemIdentifier(WhseReceiptLine.RecordId, true, '-');
                        Line := XmlElement.Create('Line', '',
                            StrSubstNo(Text015, WhseReceiptLine."Qty. to Receive", WhseReceiptLine."Qty. Outstanding",
                                ItemIdentifier, WhseReceiptLine.Description));
                        AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption(Description));
                        AddAttribute(Line, 'Indicator', Indicator);
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        RecordElement.Add(Line);

                        Line := XmlElement.Create('Line', '', WhseReceiptLine.Description);
                        AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption(Description));
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        RecordElement.Add(Line);

                        Line := XmlElement.Create('Line', '', Format(WhseReceiptLine."Source Document"));
                        AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption("Source Document"));
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        RecordElement.Add(Line);

                        Line := XmlElement.Create('Line', '', WhseReceiptLine."Source No.");
                        AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption("Source No."));
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        RecordElement.Add(Line);

                        Line := XmlElement.Create('Line', '', WhseReceiptLine."Unit of Measure Code");
                        AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption("Unit of Measure Code"));
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        RecordElement.Add(Line);

                        Line := XmlElement.Create('Line', '', Format(WhseReceiptLine."Qty. per Unit of Measure"));
                        AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption("Qty. per Unit of Measure"));
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        RecordElement.Add(Line);
                    end;
                    Records.Add(RecordElement);
                end;
            until WhseReceiptLine.Next = 0;

            if not MiniformHeader."Hid Fulfilled Lines" then begin
                if WhseReceiptLine.FindSet then begin
                    repeat
                        RecordElement := XmlElement.Create('Record');

                        CurrRecordID := WhseReceiptLine.RecordId;
                        TableNo := CurrRecordID.TableNo;

                        if (WhseReceiptLine."Qty. to Receive" < WhseReceiptLine."Qty. Outstanding") then
                            Indicator := 'minus'
                        else
                            if (WhseReceiptLine."Qty. to Receive" = WhseReceiptLine."Qty. Outstanding") then
                                Indicator := 'ok'
                            else
                                Indicator := 'plus';

                        if Indicator <> 'minus' then begin
                            if MiniformHeader."Expand Summary Items" then begin
                                //1
                                Line := XmlElement.Create('Line', '', WhseReceiptLine."Bin Code");
                                AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption(Description));
                                AddAttribute(Line, 'Indicator', Indicator);
                                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                                AddAttribute(Line, 'CollapsItems', 'FALSE');
                                RecordElement.Add(Line);

                                //2
                                Line := XmlElement.Create('Line', '',
                                    StrSubstNo(Text026, WhseReceiptLine."Qty. to Receive", WhseReceiptLine."Qty. Outstanding"));
                                AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption("Qty. Outstanding"));
                                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                                RecordElement.Add(Line);

                                //3
                                ItemIdentifier := CSWarehouseActivitySetup.ItemIdentifier(WhseReceiptLine.RecordId, true, ' | ');
                                Line := XmlElement.Create('Line', '', ItemIdentifier);
                                AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption("Item No."));
                                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                                RecordElement.Add(Line);

                                //4
                                Line := XmlElement.Create('Line', '', WhseReceiptLine."Unit of Measure Code");
                                AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption("Unit of Measure Code"));
                                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                                RecordElement.Add(Line);

                                //5
                                Line := XmlElement.Create('Line', '', WhseReceiptLine.Description);
                                AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption(Description));
                                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                                RecordElement.Add(Line);

                                //6
                                Line := XmlElement.Create('Line', '', '');
                                AddAttribute(Line, 'Descrip', '');
                                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                                RecordElement.Add(Line);

                                if Location.Get(WhseReceiptLine."Location Code") then
                                    if Location."Bin Mandatory" then begin
                                        Line := XmlElement.Create('Line');
                                        AddAttribute(Line, 'Descrip', 'Split Line..');
                                        AddAttribute(Line, 'Type', Format(LineType::BUTTON));
                                        AddAttribute(Line, 'TableNo', Format(TableNo));
                                        AddAttribute(Line, 'RecordID', Format(CurrRecordID));
                                        AddAttribute(Line, 'FuncName', 'SPLITLINE');
                                        RecordElement.Add(Line);
                                    end;
                            end else begin
                                ItemIdentifier := CSWarehouseActivitySetup.ItemIdentifier(WhseReceiptLine.RecordId, true, '-');
                                Line := XmlElement.Create('Line', '',
                                    StrSubstNo(Text015, WhseReceiptLine."Qty. to Receive", WhseReceiptLine."Qty. Outstanding",
                                        ItemIdentifier, WhseReceiptLine.Description));
                                AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption(Description));
                                AddAttribute(Line, 'Indicator', Indicator);
                                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                                RecordElement.Add(Line);

                                Line := XmlElement.Create('Line', '', WhseReceiptLine.Description);
                                AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption(Description));
                                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                                RecordElement.Add(Line);

                                Line := XmlElement.Create('Line', '', Format(WhseReceiptLine."Source Document"));
                                AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption("Source Document"));
                                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                                RecordElement.Add(Line);

                                Line := XmlElement.Create('Line', '', WhseReceiptLine."Source No.");
                                AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption("Source No."));
                                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                                RecordElement.Add(Line);

                                Line := XmlElement.Create('Line', '', WhseReceiptLine."Unit of Measure Code");
                                AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption("Unit of Measure Code"));
                                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                                RecordElement.Add(Line);

                                Line := XmlElement.Create('Line', '', Format(WhseReceiptLine."Qty. per Unit of Measure"));
                                AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption("Qty. per Unit of Measure"));
                                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                                RecordElement.Add(Line);
                            end;
                            Records.Add(RecordElement);
                        end;
                    until WhseReceiptLine.Next = 0;
                end;
            end;
            exit(true);
        end else
            exit(false);
    end;

    local procedure Reset(CSWarehouseReceiptHandling: Record "NPR CS Wareh. Receipt Handl.")
    var
        WhseReceiptLine: Record "Warehouse Receipt Line";
    begin
        Remark := '';
        WhseReceiptLine.SetRange("No.", CSWarehouseReceiptHandling."No.");
        if WhseReceiptLine.FindSet then begin
            repeat
                WhseReceiptLine.Validate("Qty. to Receive", 0);
                WhseReceiptLine.Modify;
            until WhseReceiptLine.Next = 0;
        end else
            Error(Text007);

        CSCommunication.SetRecRef(RecRef);
        ActiveInputField := 1;
    end;

    local procedure Register(CSWarehouseReceiptHandling: Record "NPR CS Wareh. Receipt Handl.")
    var
        WhsePostReceipt: Codeunit "Whse.-Post Receipt";
        WhseReceiptLine: Record "Warehouse Receipt Line";
        WarehouseReceiptHeader: Record "Warehouse Receipt Header";
    begin
        Remark := '';
        WhseReceiptLine.SetRange("No.", CSWarehouseReceiptHandling."No.");
        if WhseReceiptLine.FindFirst then begin
            if MiniformHeader."Update Posting Date" then begin
                WarehouseReceiptHeader.Get(CSWarehouseReceiptHandling."No.");
                WarehouseReceiptHeader.Validate("Posting Date", Today);
                WarehouseReceiptHeader.Modify(true);
            end;

            WhsePostReceipt.Run(WhseReceiptLine);
            WhsePostReceipt.GetResultMessage;
            Clear(WhsePostReceipt);
        end else
            Error(Text007);
    end;

    local procedure TransferDataLine(CSWarehouseReceiptHandling: Record "NPR CS Wareh. Receipt Handl."): Boolean
    var
        WhseReceiptLine: Record "Warehouse Receipt Line";
    begin
        WhseReceiptLine.SetCurrentKey("Source Type", "Source Subtype", "Source No.", "Source Line No.");
        WhseReceiptLine.SetRange("No.", CSWarehouseReceiptHandling."No.");
        WhseReceiptLine.SetRange("Item No.", CSWarehouseReceiptHandling."Item No.");
        if WhseReceiptLine.FindSet then begin
            if WhseReceiptLine."Qty. to Receive" = WhseReceiptLine."Qty. Outstanding" then begin
                Remark := StrSubstNo(Text016);
                exit(false);
            end;
            WhseReceiptLine.Validate("Qty. to Receive", WhseReceiptLine."Qty. to Receive" + CSWarehouseReceiptHandling.Qty);
            if CSWarehouseReceiptHandling."Unit of Measure" <> '' then
                WhseReceiptLine.Validate("Unit of Measure Code", CSWarehouseReceiptHandling."Unit of Measure");
            WhseReceiptLine.Modify(true);
        end else begin
            Remark := StrSubstNo(Text021, CSWarehouseReceiptHandling."Item No.", CSWarehouseReceiptHandling."No.");
            exit(false);
        end;

        exit(true);
    end;
}
