codeunit 6151367 "CS UI Warehouse Shipment"
{
    // NPR5.50/CLVA/20190425 CASE 352719 Object created - NP Capture Service

    TableNo = "CS UI Header";

    trigger OnRun()
    var
        MiniformMgmt: Codeunit "CS UI Management";
    begin
        MiniformMgmt.Initialize(
          MiniformHeader, Rec, DOMxmlin, ReturnedNode,
          RootNode, XMLDOMMgt, CSCommunication, CSUserId,
          CurrentCode, StackCode, WhseEmpId, LocationFilter, CSSessionId);

        if Code <> CurrentCode then
            PrepareData
        else
            ProcessInput;

        Clear(DOMxmlin);
    end;

    var
        MiniformHeader: Record "CS UI Header";
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
        Text009: Label 'Shelf  No. is blank';
        Text010: Label 'Barcode %1 doesn''t exist';
        Text011: Label 'Qty. is blank';
        Text012: Label 'No Lines available.';
        Text013: Label 'Input value is not valid';
        Text014: Label 'Item %1 doesn''t exist';
        Text015: Label '%1/%2 : %3 %4';
        Text016: Label 'Qty. to Ship exceed Qty. Outstanding';
        Text017: Label 'Bin Code %1 is not valid';
        Text018: Label 'Bin Code %1 is already selected for this line';
        Text019: Label 'Bin Code is blank';
        Text020: Label 'Variant is not a record';
        Text021: Label 'Item %1 not found on doc. %2';

    local procedure ProcessInput()
    var
        FuncGroup: Record "CS UI Function Group";
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
        CSWarehouseShipmentHandling: Record "CS Warehouse Shipment Handling";
        CSWarehouseShipmentHandling2: Record "CS Warehouse Shipment Handling";
        CSFieldDefaults: Record "CS Field Defaults";
        CommaString: DotNet npNetString;
        Values: DotNet npNetArray;
        Separator: DotNet npNetString;
        Value: Text;
        ActionIndex: Integer;
    begin
        if XMLDOMMgt.FindNode(RootNode, 'Header/Input', ReturnedNode) then
            TextValue := ReturnedNode.InnerText
        else
            Error(Text006);

        Evaluate(TableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'RecordID'));
        if RecRef.Get(RecId) then begin
            RecRef.SetTable(CSWarehouseShipmentHandling);
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
                Reset(CSWarehouseShipmentHandling);
            FuncGroup.KeyDef::Register:
                begin
                    if not Evaluate(ActionIndex, CSCommunication.GetNodeAttribute(ReturnedNode, 'ActionIndex')) then
                        ActionIndex := 2;
                    Register(CSWarehouseShipmentHandling, ActionIndex);
                    if Remark = '' then begin
                        DeleteEmptyDataLines();
                        CSCommunication.RunPreviousUI(DOMxmlin)
                    end else
                        SendForm(ActiveInputField, CSWarehouseShipmentHandling);
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
                                CSWarehouseShipmentHandling.FieldNo(Barcode):
                                    CheckBarcode(CSWarehouseShipmentHandling, Value);
                                CSWarehouseShipmentHandling.FieldNo(Qty):
                                    CheckQty(CSWarehouseShipmentHandling, Value);
                                CSWarehouseShipmentHandling.FieldNo("Bin Code"):
                                    CheckBin(CSWarehouseShipmentHandling, Value);
                                else begin
                                        CSCommunication.FieldSetvalue(RecRef, FldNo, Value);
                                    end;
                            end;

                            CSWarehouseShipmentHandling.Modify;

                            RecRef.GetTable(CSWarehouseShipmentHandling);
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
                                            RecRef.SetTable(CSWarehouseShipmentHandling);
                                            RecRef.SetRecFilter;
                                            CSCommunication.SetRecRef(RecRef);
                                        until CSFieldDefaults.Next = 0;
                                    end;

                                    UpdateDataLine(CSWarehouseShipmentHandling);
                                    CreateDataLine(CSWarehouseShipmentHandling2, CSWarehouseShipmentHandling);
                                    RecRef.GetTable(CSWarehouseShipmentHandling2);
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
            SendForm(ActiveInputField, CSWarehouseShipmentHandling);
    end;

    local procedure PrepareData()
    var
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        CSWarehouseShipmentHandling: Record "CS Warehouse Shipment Handling";
        RecId: RecordID;
        TableNo: Integer;
        Barcode: Text;
    begin
        XMLDOMMgt.FindNode(RootNode, 'Header/Input', ReturnedNode);

        Evaluate(TableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'TableNo'));
        Evaluate(RecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'RecordID'));

        RecRef.Open(TableNo);
        RecRef.Get(RecId);
        RecRef.SetTable(WarehouseShipmentHeader);

        DeleteEmptyDataLines();
        CreateDataLine(CSWarehouseShipmentHandling, WarehouseShipmentHeader);

        Barcode := CSCommunication.GetNodeAttribute(ReturnedNode, 'Barcode');
        if Barcode <> '' then
            CSWarehouseShipmentHandling."Source Doc. No." := Barcode
        else
            CSWarehouseShipmentHandling."Source Doc. No." := CSWarehouseShipmentHandling."No.";
        CSWarehouseShipmentHandling.Modify;

        RecRef.Close;

        RecId := CSWarehouseShipmentHandling.RecordId;

        RecRef.Open(RecId.TableNo);
        RecRef.Get(RecId);
        RecRef.SetRecFilter;

        CSCommunication.SetRecRef(RecRef);
        ActiveInputField := 1;
        SendForm(ActiveInputField, CSWarehouseShipmentHandling);
    end;

    local procedure SendForm(InputField: Integer; CSWarehouseShipmentHandling: Record "CS Warehouse Shipment Handling")
    var
        Records: DotNet npNetXmlElement;
    begin
        CSCommunication.EncodeUI(MiniformHeader, StackCode, DOMxmlin, InputField, Remark, CSUserId);
        CSCommunication.GetReturnXML(DOMxmlin);

        if MiniformHeader."Add Posting Options" then
            AddAdditionalInfo(DOMxmlin, CSWarehouseShipmentHandling);

        if AddSummarize(Records) then
            DOMxmlin.DocumentElement.AppendChild(Records);

        CSMgt.SendXMLReply(DOMxmlin);
    end;

    local procedure CheckBarcode(var CSWarehouseShipmentHandling: Record "CS Warehouse Shipment Handling"; InputValue: Text)
    var
        BarcodeLibrary: Codeunit "Barcode Library";
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

        if StrLen(InputValue) > MaxStrLen(CSWarehouseShipmentHandling.Barcode) then begin
            Remark := Text008;
            exit;
        end;

        if BarcodeLibrary.TranslateBarcodeToItemVariant(InputValue, ItemNo, VariantCode, ResolvingTable, true) then begin
            if not Item.Get(ItemNo) then begin
                Remark := StrSubstNo(Text014, InputValue);
                exit;
            end;

            CSWarehouseShipmentHandling."Item No." := ItemNo;
            CSWarehouseShipmentHandling."Variant Code" := VariantCode;

            if (ResolvingTable = DATABASE::"Item Cross Reference") then begin
                with ItemCrossReference do begin
                    if (StrLen(InputValue) <= MaxStrLen("Cross-Reference No.")) then begin
                        SetCurrentKey("Cross-Reference Type", "Cross-Reference No.");
                        SetFilter("Cross-Reference Type", '=%1', "Cross-Reference Type"::"Bar Code");
                        SetFilter("Cross-Reference No.", '=%1', UpperCase(InputValue));
                        if FindFirst() then
                            CSWarehouseShipmentHandling."Unit of Measure" := ItemCrossReference."Unit of Measure";
                    end;
                end;
            end;

        end else begin
            Remark := StrSubstNo(Text010, InputValue);
            exit;
        end;

        CSWarehouseShipmentHandling.Barcode := InputValue;
    end;

    local procedure CheckQty(var CSWarehouseShipmentHandling: Record "CS Warehouse Shipment Handling"; InputValue: Text)
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

        CSWarehouseShipmentHandling.Qty := Qty;
    end;

    local procedure CheckBin(var CSWarehouseShipmentHandling: Record "CS Warehouse Shipment Handling"; InputValue: Text)
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

        if not Bin.Get(CSWarehouseShipmentHandling."Location Code", InputValue) then begin
            Remark := StrSubstNo(Text017, InputValue);
            exit;
        end;

        CSWarehouseShipmentHandling."Bin Code" := InputValue;
    end;

    local procedure CreateDataLine(var CSWarehouseShipmentHandling: Record "CS Warehouse Shipment Handling"; RecordVariant: Variant)
    var
        NewCSWarehouseShipmentHandling: Record "CS Warehouse Shipment Handling";
        LineNo: Integer;
        RecRefByVariant: RecordRef;
        CSWarehouseShipmentHandlingByVar: Record "CS Warehouse Shipment Handling";
        WarehouseShipmentHeaderByVar: Record "Warehouse Shipment Header";
    begin
        if not RecordVariant.IsRecord then
            Error(Text020);

        Clear(NewCSWarehouseShipmentHandling);
        NewCSWarehouseShipmentHandling.SetRange(Id, CSSessionId);
        if NewCSWarehouseShipmentHandling.FindLast then
            LineNo := NewCSWarehouseShipmentHandling."Line No." + 1
        else
            LineNo := 1;

        CSWarehouseShipmentHandling.Init;
        CSWarehouseShipmentHandling.Id := CSSessionId;
        CSWarehouseShipmentHandling."Line No." := LineNo;
        CSWarehouseShipmentHandling."Created By" := UserId;
        CSWarehouseShipmentHandling.Created := CurrentDateTime;

        if MiniformHeader."Set defaults from last record" then
            CSWarehouseShipmentHandling.Qty := NewCSWarehouseShipmentHandling.Qty;

        RecRefByVariant.GetTable(RecordVariant);

        CSWarehouseShipmentHandling."Table No." := RecRefByVariant.Number;

        if RecRefByVariant.Number = 7320 then begin
            WarehouseShipmentHeaderByVar := RecordVariant;
            CSWarehouseShipmentHandling."No." := WarehouseShipmentHeaderByVar."No.";
            CSWarehouseShipmentHandling."Assignment Date" := WarehouseShipmentHeaderByVar."Assignment Date";
            CSWarehouseShipmentHandling."Record Id" := WarehouseShipmentHeaderByVar.RecordId;
        end else begin
            CSWarehouseShipmentHandlingByVar := RecordVariant;
            CSWarehouseShipmentHandling."No." := CSWarehouseShipmentHandlingByVar."No.";
            CSWarehouseShipmentHandling."Assignment Date" := CSWarehouseShipmentHandlingByVar."Assignment Date";
            CSWarehouseShipmentHandling."Record Id" := CSWarehouseShipmentHandlingByVar.RecordId;
        end;

        CSWarehouseShipmentHandling.Insert(true);
    end;

    local procedure UpdateDataLine(var CSWarehouseShipmentHandling: Record "CS Warehouse Shipment Handling")
    begin
        CSWarehouseShipmentHandling.Handled := true;
        CSWarehouseShipmentHandling.Modify(true);

        if TransferDataLine(CSWarehouseShipmentHandling) then begin
            CSWarehouseShipmentHandling."Transferred to Document" := true;
            CSWarehouseShipmentHandling.Modify(true);
        end;
    end;

    local procedure DeleteEmptyDataLines()
    var
        CSWarehouseShipmentHandling: Record "CS Warehouse Shipment Handling";
    begin
        CSWarehouseShipmentHandling.SetRange(Id, CSSessionId);
        CSWarehouseShipmentHandling.SetRange(Handled, false);
        CSWarehouseShipmentHandling.DeleteAll(true);
    end;

    local procedure AddAttribute(var NewChild: DotNet npNetXmlNode;AttribName: Text[250];AttribValue: Text[250])
    begin
        if XMLDOMMgt.AddAttribute(NewChild, AttribName, AttribValue) > 0 then
            Error(Text002, AttribName);
    end;

    local procedure AddSummarize(var Records: DotNet npNetXmlElement): Boolean
    var
        "Record": DotNet npNetXmlElement;
        Line: DotNet npNetXmlElement;
        Indicator: Text;
        CSWarehouseShipmentHandling: Record "CS Warehouse Shipment Handling";
        WhseShipmentLine: Record "Warehouse Shipment Line";
        LineType: Option TEXT,BUTTON;
        CurrRecordID: RecordID;
        TableNo: Integer;
    begin
        Clear(CSWarehouseShipmentHandling);
        CSWarehouseShipmentHandling.SetRange(Id, CSSessionId);
        if not CSWarehouseShipmentHandling.FindLast then
            exit(false);

        if (CSWarehouseShipmentHandling."Source Doc. No." <> '') and (CSWarehouseShipmentHandling."Source Doc. No." <> CSWarehouseShipmentHandling."No.") then begin
            WhseShipmentLine.SetRange("Source Document", WhseShipmentLine."Source Document"::"Sales Order");
            WhseShipmentLine.SetRange("Source No.", CSWarehouseShipmentHandling."Source Doc. No.");
        end else
            WhseShipmentLine.SetRange("No.", CSWarehouseShipmentHandling."No.");
        if WhseShipmentLine.FindSet then begin
            Records := DOMxmlin.CreateElement('Records');
            repeat
                Record := DOMxmlin.CreateElement('Record');

                CurrRecordID := WhseShipmentLine.RecordId;
                TableNo := CurrRecordID.TableNo;

                if (WhseShipmentLine."Qty. to Ship" < WhseShipmentLine."Qty. Outstanding") then
                    Indicator := 'minus'
                else
                    if (WhseShipmentLine."Qty. to Ship" = WhseShipmentLine."Qty. Outstanding") then
                        Indicator := 'ok'
                    else
                        Indicator := 'plus';

                if Indicator = 'minus' then begin
                    Line := DOMxmlin.CreateElement('Line');
                    AddAttribute(Line, 'Descrip', WhseShipmentLine.FieldCaption(Description));
                    AddAttribute(Line, 'Indicator', Indicator);
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    if WhseShipmentLine."Variant Code" <> '' then
                        Line.InnerText := StrSubstNo(Text015, WhseShipmentLine."Qty. to Ship", WhseShipmentLine."Qty. Outstanding", WhseShipmentLine."Item No." + '-' + WhseShipmentLine."Variant Code", WhseShipmentLine.Description)
                    else
                        Line.InnerText := StrSubstNo(Text015, WhseShipmentLine."Qty. to Ship", WhseShipmentLine."Qty. Outstanding", WhseShipmentLine."Item No.", WhseShipmentLine.Description);
                    Record.AppendChild(Line);

                    Line := DOMxmlin.CreateElement('Line');
                    AddAttribute(Line, 'Descrip', WhseShipmentLine.FieldCaption(Description));
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    Line.InnerText := WhseShipmentLine.Description;
                    Record.AppendChild(Line);

                    Line := DOMxmlin.CreateElement('Line');
                    AddAttribute(Line, 'Descrip', WhseShipmentLine.FieldCaption("Source Document"));
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    Line.InnerText := Format(WhseShipmentLine."Source Document");
                    Record.AppendChild(Line);

                    Line := DOMxmlin.CreateElement('Line');
                    AddAttribute(Line, 'Descrip', WhseShipmentLine.FieldCaption("Source No."));
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    Line.InnerText := WhseShipmentLine."Source No.";
                    Record.AppendChild(Line);

                    Line := DOMxmlin.CreateElement('Line');
                    AddAttribute(Line, 'Descrip', WhseShipmentLine.FieldCaption("Unit of Measure Code"));
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    Line.InnerText := WhseShipmentLine."Unit of Measure Code";
                    Record.AppendChild(Line);

                    Line := DOMxmlin.CreateElement('Line');
                    AddAttribute(Line, 'Descrip', WhseShipmentLine.FieldCaption("Qty. per Unit of Measure"));
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    Line.InnerText := Format(WhseShipmentLine."Qty. per Unit of Measure");
                    Record.AppendChild(Line);

                    Records.AppendChild(Record);
                end;
            until WhseShipmentLine.Next = 0;

            if not MiniformHeader."Hid Fulfilled Lines" then begin
                if WhseShipmentLine.FindSet then begin
                    repeat
                        Record := DOMxmlin.CreateElement('Record');

                        CurrRecordID := WhseShipmentLine.RecordId;
                        TableNo := CurrRecordID.TableNo;

                        if (WhseShipmentLine."Qty. to Ship" < WhseShipmentLine."Qty. Outstanding") then
                            Indicator := 'minus'
                        else
                            if (WhseShipmentLine."Qty. to Ship" = WhseShipmentLine."Qty. Outstanding") then
                                Indicator := 'ok'
                            else
                                Indicator := 'plus';

                        if Indicator <> 'minus' then begin
                            Line := DOMxmlin.CreateElement('Line');
                            AddAttribute(Line, 'Descrip', WhseShipmentLine.FieldCaption(Description));
                            AddAttribute(Line, 'Indicator', Indicator);
                            AddAttribute(Line, 'Type', Format(LineType::TEXT));
                            if WhseShipmentLine."Variant Code" <> '' then
                                Line.InnerText := StrSubstNo(Text015, WhseShipmentLine."Qty. to Ship", WhseShipmentLine."Qty. Outstanding", WhseShipmentLine."Item No." + '-' + WhseShipmentLine."Variant Code", WhseShipmentLine.Description)
                            else
                                Line.InnerText := StrSubstNo(Text015, WhseShipmentLine."Qty. to Ship", WhseShipmentLine."Qty. Outstanding", WhseShipmentLine."Item No.", WhseShipmentLine.Description);
                            Record.AppendChild(Line);

                            Line := DOMxmlin.CreateElement('Line');
                            AddAttribute(Line, 'Descrip', WhseShipmentLine.FieldCaption(Description));
                            AddAttribute(Line, 'Type', Format(LineType::TEXT));
                            Line.InnerText := WhseShipmentLine.Description;
                            Record.AppendChild(Line);

                            Line := DOMxmlin.CreateElement('Line');
                            AddAttribute(Line, 'Descrip', WhseShipmentLine.FieldCaption("Source Document"));
                            AddAttribute(Line, 'Type', Format(LineType::TEXT));
                            Line.InnerText := Format(WhseShipmentLine."Source Document");
                            Record.AppendChild(Line);

                            Line := DOMxmlin.CreateElement('Line');
                            AddAttribute(Line, 'Descrip', WhseShipmentLine.FieldCaption("Source No."));
                            AddAttribute(Line, 'Type', Format(LineType::TEXT));
                            Line.InnerText := WhseShipmentLine."Source No.";
                            Record.AppendChild(Line);

                            Line := DOMxmlin.CreateElement('Line');
                            AddAttribute(Line, 'Descrip', WhseShipmentLine.FieldCaption("Unit of Measure Code"));
                            AddAttribute(Line, 'Type', Format(LineType::TEXT));
                            Line.InnerText := WhseShipmentLine."Unit of Measure Code";
                            Record.AppendChild(Line);

                            Line := DOMxmlin.CreateElement('Line');
                            AddAttribute(Line, 'Descrip', WhseShipmentLine.FieldCaption("Qty. per Unit of Measure"));
                            AddAttribute(Line, 'Type', Format(LineType::TEXT));
                            Line.InnerText := Format(WhseShipmentLine."Qty. per Unit of Measure");
                            Record.AppendChild(Line);

                            Records.AppendChild(Record);
                        end;
                    until WhseShipmentLine.Next = 0;
                end;
            end;
            exit(true);
        end else
            exit(false);
    end;

    local procedure AddAdditionalInfo(var xmlout: DotNet npNetXmlDocument;CSWarehouseShipmentHandling: Record "CS Warehouse Shipment Handling")
    var
        CurrentRootNode: DotNet npNetXmlNode;
        XMLFunctionNode: DotNet npNetXmlNode;
        StrMenuTxt: Text;
    begin
        StrMenuTxt := 'Ship,Ship and Invoice';

        CurrentRootNode := xmlout.DocumentElement;
        XMLDOMMgt.FindNode(CurrentRootNode, 'Header/Functions', ReturnedNode);

        foreach XMLFunctionNode in ReturnedNode.ChildNodes do begin
            if (XMLFunctionNode.InnerText = 'REGISTER') then
                AddAttribute(XMLFunctionNode, 'Actions', StrMenuTxt);
        end;
    end;

    local procedure Reset(CSWarehouseShipmentHandling: Record "CS Warehouse Shipment Handling")
    var
        WhseShipmentLine: Record "Warehouse Shipment Line";
    begin
        Remark := '';
        WhseShipmentLine.SetRange("No.", CSWarehouseShipmentHandling."No.");
        if WhseShipmentLine.FindSet then begin
            repeat
                WhseShipmentLine.Validate("Qty. to Ship", 0);
                WhseShipmentLine.Modify;
            until WhseShipmentLine.Next = 0;
        end else
            Error(Text007);

        CSCommunication.SetRecRef(RecRef);
        ActiveInputField := 1;
    end;

    local procedure Register(CSWarehouseShipmentHandling: Record "CS Warehouse Shipment Handling"; Index: Integer)
    var
        WhsePostShipment: Codeunit "Whse.-Post Shipment";
        WhseShipmentLine: Record "Warehouse Shipment Line";
    begin
        Remark := '';
        if (CSWarehouseShipmentHandling."Source Doc. No." <> '') and (CSWarehouseShipmentHandling."Source Doc. No." <> CSWarehouseShipmentHandling."No.") then begin
            WhseShipmentLine.SetRange("Source Document", WhseShipmentLine."Source Document"::"Sales Order");
            WhseShipmentLine.SetRange("Source No.", CSWarehouseShipmentHandling."Source Doc. No.");
        end else
            WhseShipmentLine.SetRange("No.", CSWarehouseShipmentHandling."No.");
        if WhseShipmentLine.FindSet then begin
            repeat
                WhsePostShipment.SetPostingSettings(Index = 2);
                WhsePostShipment.Run(WhseShipmentLine);
                WhsePostShipment.GetResultMessage;
                Clear(WhsePostShipment);

                WhseShipmentLine.DeleteQtyToHandle(WhseShipmentLine);
            until WhseShipmentLine.Next = 0;
        end else
            Error(Text007);
    end;

    local procedure TransferDataLine(CSWarehouseShipmentHandling: Record "CS Warehouse Shipment Handling"): Boolean
    var
        WhseShipmentLine: Record "Warehouse Shipment Line";
    begin
        WhseShipmentLine.SetCurrentKey("Source Type", "Source Subtype", "Source No.", "Source Line No.");
        if (CSWarehouseShipmentHandling."Source Doc. No." <> '') and (CSWarehouseShipmentHandling."Source Doc. No." <> CSWarehouseShipmentHandling."No.") then begin
            WhseShipmentLine.SetRange("Source Document", WhseShipmentLine."Source Document"::"Sales Order");
            WhseShipmentLine.SetRange("Source No.", CSWarehouseShipmentHandling."Source Doc. No.");
        end else
            WhseShipmentLine.SetRange("No.", CSWarehouseShipmentHandling."No.");
        WhseShipmentLine.SetRange("Item No.", CSWarehouseShipmentHandling."Item No.");
        if WhseShipmentLine.FindSet then begin
            if WhseShipmentLine."Qty. to Ship" = WhseShipmentLine."Qty. Outstanding" then begin
                Remark := StrSubstNo(Text016);
                exit(false);
            end;
            WhseShipmentLine.Validate("Qty. to Ship", WhseShipmentLine."Qty. to Ship" + CSWarehouseShipmentHandling.Qty);
            if CSWarehouseShipmentHandling."Unit of Measure" <> '' then
                WhseShipmentLine.Validate("Unit of Measure Code", CSWarehouseShipmentHandling."Unit of Measure");
            WhseShipmentLine.Modify(true);
        end else begin
            Remark := StrSubstNo(Text021, CSWarehouseShipmentHandling."Item No.", CSWarehouseShipmentHandling."No.");
            exit(false);
        end;

        exit(true);
    end;
}

