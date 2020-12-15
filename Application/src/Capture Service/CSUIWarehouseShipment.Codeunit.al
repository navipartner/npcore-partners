codeunit 6151367 "NPR CS UI Warehouse Shipment"
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
        Text016: Label 'Qty. to Ship exceed Qty. Outstanding';
        Text017: Label 'Bin Code %1 is not valid';
        Text018: Label 'Bin Code %1 is already selected for this line';
        Text019: Label 'Bin Code is blank';
        Text020: Label 'Variant is not a record';
        Text021: Label 'Item %1 not found on doc. %2';

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
        CSWarehouseShipmentHandling: Record "NPR CS Warehouse Shipm. Handl.";
        CSWarehouseShipmentHandling2: Record "NPR CS Warehouse Shipm. Handl.";
        CSFieldDefaults: Record "NPR CS Field Defaults";
        CommaString: Text;
        Values: List of [Text];
        Separator: Text;
        Value: Text;
        ActionIndex: Integer;
    begin
        if RootNode.AsXmlAttribute().SelectSingleNode('Header/Input', ReturnedNode) then
            TextValue := ReturnedNode.AsXmlElement().InnerText
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
                        ActionIndex := MiniformHeader."Posting Type" + 1;
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
                    Values := CommaString.Split(Separator);

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
        CSWarehouseShipmentHandling: Record "NPR CS Warehouse Shipm. Handl.";
        RecId: RecordID;
        TableNo: Integer;
        Barcode: Text;
    begin
        RootNode.SelectSingleNode('Header/Input', ReturnedNode);

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

    local procedure SendForm(InputField: Integer; CSWarehouseShipmentHandling: Record "NPR CS Warehouse Shipm. Handl.")
    var
        Records: XmlElement;
        RootElement: XmlElement;
    begin
        CSCommunication.EncodeUI(MiniformHeader, StackCode, DOMxmlin, InputField, Remark, CSUserId);
        CSCommunication.GetReturnXML(DOMxmlin);

        if MiniformHeader."Posting Type" = MiniformHeader."Posting Type"::"Handle & Invoice" then
            AddAdditionalInfo(DOMxmlin, CSWarehouseShipmentHandling);

        DOMxmlin.GetRoot(RootElement);
        if AddSummarize(Records) then
            RootElement.Add(Records);

        CSMgt.SendXMLReply(DOMxmlin);
    end;

    local procedure CheckBarcode(var CSWarehouseShipmentHandling: Record "NPR CS Warehouse Shipm. Handl."; InputValue: Text)
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
            CSWarehouseShipmentHandling."Vendor Item No." := Item."Vendor Item No.";

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

    local procedure CheckQty(var CSWarehouseShipmentHandling: Record "NPR CS Warehouse Shipm. Handl."; InputValue: Text)
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

    local procedure CheckBin(var CSWarehouseShipmentHandling: Record "NPR CS Warehouse Shipm. Handl."; InputValue: Text)
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

    local procedure CreateDataLine(var CSWarehouseShipmentHandling: Record "NPR CS Warehouse Shipm. Handl."; RecordVariant: Variant)
    var
        NewCSWarehouseShipmentHandling: Record "NPR CS Warehouse Shipm. Handl.";
        LineNo: Integer;
        RecRefByVariant: RecordRef;
        CSWarehouseShipmentHandlingByVar: Record "NPR CS Warehouse Shipm. Handl.";
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

        if (NewCSWarehouseShipmentHandling."Source Doc. No." <> '') and (NewCSWarehouseShipmentHandling."Source Doc. No." <> NewCSWarehouseShipmentHandling."No.") then
            CSWarehouseShipmentHandling."Source Doc. No." := NewCSWarehouseShipmentHandling."Source Doc. No.";

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

    local procedure UpdateDataLine(var CSWarehouseShipmentHandling: Record "NPR CS Warehouse Shipm. Handl.")
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
        CSWarehouseShipmentHandling: Record "NPR CS Warehouse Shipm. Handl.";
    begin
        CSWarehouseShipmentHandling.SetRange(Id, CSSessionId);
        CSWarehouseShipmentHandling.SetRange(Handled, false);
        CSWarehouseShipmentHandling.DeleteAll(true);
    end;

    local procedure AddAttribute(var NewChild: XmlNode; AttribName: Text[250]; AttribValue: Text[250])
    begin
        NewChild.AsXmlElement().SetAttribute(AttribName, AttribValue);
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
        CSWarehouseShipmentHandling: Record "NPR CS Warehouse Shipm. Handl.";
        WhseShipmentLine: Record "Warehouse Shipment Line";
        LineType: Option TEXT,BUTTON;
        CurrRecordID: RecordID;
        TableNo: Integer;
        CSWarehouseActivitySetup: Record "NPR CS Wareh. Activ. Setup";
        ItemIdentifier: Text;
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
            Records := XmlElement.Create('Records');
            repeat
                RecordElement := XmlElement.Create('Record');

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
                    ItemIdentifier := CSWarehouseActivitySetup.ItemIdentifier(WhseShipmentLine.RecordId, true, '-');
                    Line := XmlElement.Create('Line', '',
                        StrSubstNo(Text015, WhseShipmentLine."Qty. to Ship", WhseShipmentLine."Qty. Outstanding",
                            ItemIdentifier, WhseShipmentLine.Description));
                    AddAttribute(Line, 'Descrip', WhseShipmentLine.FieldCaption(Description));
                    AddAttribute(Line, 'Indicator', Indicator);
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    RecordElement.Add(Line);

                    Line := XmlElement.Create('Line', '', WhseShipmentLine.Description);
                    AddAttribute(Line, 'Descrip', WhseShipmentLine.FieldCaption(Description));
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    RecordElement.Add(Line);

                    Line := XmlElement.Create('Line', '', Format(WhseShipmentLine."Source Document"));
                    AddAttribute(Line, 'Descrip', WhseShipmentLine.FieldCaption("Source Document"));
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    RecordElement.Add(Line);

                    Line := XmlElement.Create('Line', '', WhseShipmentLine."Source No.");
                    AddAttribute(Line, 'Descrip', WhseShipmentLine.FieldCaption("Source No."));
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    RecordElement.Add(Line);

                    Line := XmlElement.Create('Line', '', WhseShipmentLine."Unit of Measure Code");
                    AddAttribute(Line, 'Descrip', WhseShipmentLine.FieldCaption("Unit of Measure Code"));
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    RecordElement.Add(Line);

                    Line := XmlElement.Create('Line', '', Format(WhseShipmentLine."Qty. per Unit of Measure"));
                    AddAttribute(Line, 'Descrip', WhseShipmentLine.FieldCaption("Qty. per Unit of Measure"));
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    RecordElement.Add(Line);

                    Records.Add(RecordElement);
                end;
            until WhseShipmentLine.Next = 0;

            if not MiniformHeader."Hid Fulfilled Lines" then begin
                if WhseShipmentLine.FindSet then begin
                    repeat
                        RecordElement := XmlElement.Create('Record');

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
                            ItemIdentifier := CSWarehouseActivitySetup.ItemIdentifier(WhseShipmentLine.RecordId, true, '-');
                            Line := XmlElement.Create('Line', '',
                                StrSubstNo(Text015, WhseShipmentLine."Qty. to Ship", WhseShipmentLine."Qty. Outstanding",
                                    ItemIdentifier, WhseShipmentLine.Description));
                            AddAttribute(Line, 'Descrip', WhseShipmentLine.FieldCaption(Description));
                            AddAttribute(Line, 'Indicator', Indicator);
                            AddAttribute(Line, 'Type', Format(LineType::TEXT));
                            RecordElement.Add(Line);

                            Line := XmlElement.Create('Line', '', WhseShipmentLine.Description);
                            AddAttribute(Line, 'Descrip', WhseShipmentLine.FieldCaption(Description));
                            AddAttribute(Line, 'Type', Format(LineType::TEXT));
                            RecordElement.Add(Line);

                            Line := XmlElement.Create('Line', '', Format(WhseShipmentLine."Source Document"));
                            AddAttribute(Line, 'Descrip', WhseShipmentLine.FieldCaption("Source Document"));
                            AddAttribute(Line, 'Type', Format(LineType::TEXT));
                            RecordElement.Add(Line);

                            Line := XmlElement.Create('Line', '', WhseShipmentLine."Source No.");
                            AddAttribute(Line, 'Descrip', WhseShipmentLine.FieldCaption("Source No."));
                            AddAttribute(Line, 'Type', Format(LineType::TEXT));
                            RecordElement.Add(Line);

                            Line := XmlElement.Create('Line', '', WhseShipmentLine."Unit of Measure Code");
                            AddAttribute(Line, 'Descrip', WhseShipmentLine.FieldCaption("Unit of Measure Code"));
                            AddAttribute(Line, 'Type', Format(LineType::TEXT));
                            RecordElement.Add(Line);

                            Line := XmlElement.Create('Line', '', Format(WhseShipmentLine."Qty. per Unit of Measure"));
                            AddAttribute(Line, 'Descrip', WhseShipmentLine.FieldCaption("Qty. per Unit of Measure"));
                            AddAttribute(Line, 'Type', Format(LineType::TEXT));
                            RecordElement.Add(Line);

                            Records.Add(RecordElement);
                        end;
                    until WhseShipmentLine.Next = 0;
                end;
            end;
            exit(true);
        end else
            exit(false);
    end;

    local procedure AddAdditionalInfo(var xmlout: XmlDocument; CSWarehouseShipmentHandling: Record "NPR CS Warehouse Shipm. Handl.")
    var
        CurrentRootNode: XmlElement;
        XMLFunctionNode: XmlNode;
        StrMenuTxt: Text;
    begin
        StrMenuTxt := 'Ship,Ship and Invoice';

        xmlout.GetRoot(CurrentRootNode);
        CurrentRootNode.SelectSingleNode('Header/Functions', ReturnedNode);

        foreach XMLFunctionNode in ReturnedNode.AsXmlElement().GetChildNodes() do begin
            if (XMLFunctionNode.AsXmlElement().InnerText = 'REGISTER') then
                AddAttribute(XMLFunctionNode, 'Actions', StrMenuTxt);
        end;
    end;

    local procedure Reset(CSWarehouseShipmentHandling: Record "NPR CS Warehouse Shipm. Handl.")
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

    local procedure Register(CSWarehouseShipmentHandling: Record "NPR CS Warehouse Shipm. Handl."; Index: Integer)
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

    local procedure TransferDataLine(CSWarehouseShipmentHandling: Record "NPR CS Warehouse Shipm. Handl."): Boolean
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

    [EventSubscriber(ObjectType::Table, 7321, 'OnBeforeInsertEvent', '', false, false)]
    local procedure EmptyQtyToShipOnWarehouseShipment(var Rec: Record "Warehouse Shipment Line"; RunTrigger: Boolean)
    var
        CSSetup: Record "NPR CS Setup";
    begin
        if Rec.IsTemporary then
            exit;

        if CSSetup.Get and CSSetup."Zero Def. Qty. to Handle" then
            Rec."Qty. to Ship" := 0;
    end;
}