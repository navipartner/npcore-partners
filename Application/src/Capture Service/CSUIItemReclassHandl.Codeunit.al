codeunit 6151364 "NPR CS UI Item Reclass. Handl."
{
    TableNo = "NPR CS UI Header";

    trigger OnRun()
    var
        MiniformMgmt: Codeunit "NPR CS UI Management";
    begin
        MiniformMgmt.Initialize(
          CSUIHeader, Rec, DOMxmlin, ReturnedNode,
          RootNode, CSCommunication, CSUserId,
          CurrentCode, StackCode, WhseEmpId, LocationFilter, CSSessionId);

        if Code <> CurrentCode then
            PrepareData
        else
            ProcessInput;

        Clear(DOMxmlin);
    end;

    var
        CSUIHeader: Record "NPR CS UI Header";
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
        CSSessionId: Text;
        Text013: Label 'Input value is not valid';
        Text014: Label 'Item %1 doesn''t exist';
        Text015: Label '%1 : %2 %3';
        Text016: Label '%1 : %2';
        Text020: Label 'Location Code is blank';
        Text021: Label 'Bin Code is not valid';
        Text022: Label 'Bin Content do not exist in filter: %1';
        Text023: Label 'Qty. exceeds Bin Content Quantity';
        Text024: Label 'New Bin Code is equal existent Bin Code';
        StrMenuTxt: Text;
        Text025: Label 'Please select bin';
        Text026: Label 'Qty. can not be 0';
        Text029: Label 'Inventory move for item %1 : %2 to Bin %3 is already added for posting';

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
        CSItemReclassHandling: Record "NPR CS Item Reclass. Handling";
        CSItemReclassHandling2: Record "NPR CS Item Reclass. Handling";
        CSFieldDefaults: Record "NPR CS Field Defaults";
        CommaString: Text;
        Separator: Text;
        Values: List of [Text];
        Value: Text;
        ItemJournalLine: Record "Item Journal Line";
    begin
        if RootNode.AsXmlElement().SelectSingleNode('Header/Input', ReturnedNode) then
            TextValue := ReturnedNode.AsXmlElement().InnerText
        else
            Error(Text006);

        Evaluate(TableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'RecordID'));
        if RecRef.Get(RecId) then begin
            RecRef.SetTable(CSItemReclassHandling);
            RecRef.SetRecFilter;
            CSCommunication.SetRecRef(RecRef);
        end else begin
            CSCommunication.RunPreviousUI(DOMxmlin);
            exit;
        end;

        FuncGroup.KeyDef := CSCommunication.GetFunctionKey(CSUIHeader.Code, TextValue);

        ActiveInputField := 1;
        StrMenuTxt := '';

        case FuncGroup.KeyDef of
            FuncGroup.KeyDef::Esc:
                begin
                    DeleteEmptyDataLines(CSItemReclassHandling);
                    CSCommunication.RunPreviousUI(DOMxmlin);
                end;
            FuncGroup.KeyDef::First:
                begin
                    if ActiveInputField > 1 then
                        ActiveInputField -= 1;
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
                Reset(CSItemReclassHandling);
            FuncGroup.KeyDef::Register:
                begin
                    Register();
                    if Remark = '' then begin
                        DeleteEmptyDataLines(CSItemReclassHandling);
                        CSCommunication.RunPreviousUI(DOMxmlin)
                    end else
                        SendForm(ActiveInputField);
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
                                CSItemReclassHandling.FieldNo(Barcode):
                                    CheckBarcode(CSItemReclassHandling, Value);
                                CSItemReclassHandling.FieldNo("Bin Code"):
                                    CheckBinCode(CSItemReclassHandling, Value);
                                CSItemReclassHandling.FieldNo("New Bin Code"):
                                    CheckNewBinCode(CSItemReclassHandling, Value);
                                CSItemReclassHandling.FieldNo(Qty):
                                    CheckQty(CSItemReclassHandling, Value);
                                else begin
                                        CSCommunication.FieldSetvalue(RecRef, FldNo, Value);
                                    end;
                            end;

                            CSItemReclassHandling.Modify;

                            RecRef.GetTable(CSItemReclassHandling);
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
                                            RecRef.SetTable(CSItemReclassHandling);
                                            RecRef.SetRecFilter;
                                            CSCommunication.SetRecRef(RecRef);
                                        until CSFieldDefaults.Next = 0;
                                    end;

                                    UpdateDataLine(CSItemReclassHandling);
                                    CreateDataLine(CSItemReclassHandling2, CSItemReclassHandling."Location Code");
                                    RecRef.GetTable(CSItemReclassHandling2);
                                    CSCommunication.SetRecRef(RecRef);

                                    Clear(CSItemReclassHandling);
                                    CSItemReclassHandling := CSItemReclassHandling2;

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
        CSItemReclassHandling: Record "NPR CS Item Reclass. Handling";
        Location: Record Location;
        RecId: RecordID;
        TableNo: Integer;
    begin
        RootNode.AsXmlElement().SelectSingleNode('Header/Input', ReturnedNode);

        Evaluate(TableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'TableNo'));
        Evaluate(RecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'RecordID'));

        RecRef.Open(TableNo);
        RecRef.Get(RecId);
        RecRef.SetTable(Location);

        DeleteEmptyDataLines(CSItemReclassHandling);
        CreateDataLine(CSItemReclassHandling, Location.Code);

        RecRef.Close;

        RecId := CSItemReclassHandling.RecordId;

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
        CSSetup: Record "NPR CS Setup";
        Options: XmlElement;
    begin
        CSCommunication.EncodeUI(CSUIHeader, StackCode, DOMxmlin, InputField, Remark, CSUserId);
        CSCommunication.GetReturnXML(DOMxmlin);

        DOMxmlin.GetRoot(RootElement);
        if AddOptions(Options) then
            RootElement.Add(Options);

        if AddSummarize(Records) then
            RootElement.Add(Records);

        CSMgt.SendXMLReply(DOMxmlin);
    end;

    local procedure CheckBarcode(var CSItemReclassHandling: Record "NPR CS Item Reclass. Handling"; InputValue: Text)
    var
        BarcodeLibrary: Codeunit "NPR Barcode Library";
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
        Item: Record Item;
        BinContent: Record "Bin Content";
        CSSetup: Record "NPR CS Setup";
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalLine: Record "Item Journal Line";
    begin
        if InputValue = '' then begin
            Remark := Text005;
            exit;
        end;

        if StrLen(InputValue) > MaxStrLen(CSItemReclassHandling.Barcode) then begin
            Remark := Text008;
            exit;
        end;

        if BarcodeLibrary.TranslateBarcodeToItemVariant(InputValue, ItemNo, VariantCode, ResolvingTable, true) then begin
            if not Item.Get(ItemNo) then begin
                Remark := StrSubstNo(Text014, InputValue);
                exit;
            end;

            CSItemReclassHandling."Item No." := ItemNo;
            CSItemReclassHandling."Variant Code" := VariantCode;

        end else begin
            Remark := StrSubstNo(Text010, InputValue);
            exit;
        end;

        Clear(BinContent);
        BinContent.SetRange("Location Code", CSItemReclassHandling."Location Code");
        BinContent.SetRange("Item No.", ItemNo);
        BinContent.SetRange("Variant Code", VariantCode);
        BinContent.SetFilter(Quantity, '>%1', 0);
        if not BinContent.FindFirst then begin
            Remark := StrSubstNo(Text022, BinContent.GetFilters());
            exit;
        end else begin
            BinContent.CalcFields(Quantity);
            CSItemReclassHandling."Bin Code" := BinContent."Bin Code";
            CSItemReclassHandling.Qty := BinContent.Quantity;

            if CSItemReclassHandling."Bin Code" <> '' then begin
                CSSetup.Get;
                if ItemJournalBatch.Get(CSSetup."Item Reclass. Jour Temp Name", CSSetup."Item Reclass. Jour Batch Name") then begin
                    Clear(ItemJournalLine);
                    ItemJournalLine.SetRange("Journal Template Name", ItemJournalBatch."Journal Template Name");
                    ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);
                    ItemJournalLine.SetRange("Item No.", CSItemReclassHandling."Item No.");
                    ItemJournalLine.SetRange("Variant Code", CSItemReclassHandling."Variant Code");
                    ItemJournalLine.SetRange("Bin Code", CSItemReclassHandling."Bin Code");
                    if ItemJournalLine.FindFirst then begin
                        Remark := StrSubstNo(Text029, CSItemReclassHandling."Item No.", CSItemReclassHandling."Variant Code", CSItemReclassHandling."Bin Code");
                        exit;
                    end;
                end;
            end;

            repeat
                BinContent.CalcFields(Quantity);
                StrMenuTxt := StrMenuTxt + BinContent."Bin Code" + ' | ' + Format(BinContent.Quantity) + ' ' + BinContent."Unit of Measure Code" + ',';
            until BinContent.Next = 0;
            StrMenuTxt := CopyStr(StrMenuTxt, 1, (StrLen(StrMenuTxt) - 1));
        end;

        CSItemReclassHandling.Barcode := InputValue;
    end;

    local procedure CheckBinCode(var CSItemReclassHandlingPlaceholder: Record "NPR CS Item Reclass. Handling"; InputValue: Text)
    var
        QtyToHandle: Decimal;
        BinContent: Record "Bin Content";
        CSSetup: Record "NPR CS Setup";
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalLine: Record "Item Journal Line";
    begin
        if InputValue = '' then begin
            Remark := Text009;
            exit;
        end;

        if StrLen(InputValue) > MaxStrLen(CSItemReclassHandlingPlaceholder."Bin Code") then begin
            Remark := Text008;
            exit;
        end;


        Clear(BinContent);
        BinContent.SetRange("Location Code", CSItemReclassHandlingPlaceholder."Location Code");
        BinContent.SetRange("Item No.", CSItemReclassHandlingPlaceholder."Item No.");
        BinContent.SetRange("Variant Code", CSItemReclassHandlingPlaceholder."Variant Code");
        BinContent.SetRange("Bin Code", InputValue);
        if not BinContent.FindSet then begin
            Remark := Text021;
            exit;
        end;

        if CSItemReclassHandlingPlaceholder."Item No." <> '' then begin
            CSSetup.Get;
            if ItemJournalBatch.Get(CSSetup."Item Reclass. Jour Temp Name", CSSetup."Item Reclass. Jour Batch Name") then begin
                Clear(ItemJournalLine);
                ItemJournalLine.SetRange("Journal Template Name", ItemJournalBatch."Journal Template Name");
                ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);
                ItemJournalLine.SetRange("Item No.", CSItemReclassHandlingPlaceholder."Item No.");
                ItemJournalLine.SetRange("Variant Code", CSItemReclassHandlingPlaceholder."Variant Code");
                ItemJournalLine.SetRange("Bin Code", InputValue);
                if ItemJournalLine.FindFirst then begin
                    Remark := StrSubstNo(Text029, CSItemReclassHandlingPlaceholder."Item No.", CSItemReclassHandlingPlaceholder."Variant Code", InputValue);
                    exit;
                end;
            end;
        end;

        CSItemReclassHandlingPlaceholder."Bin Code" := InputValue;
        BinContent.CalcFields(Quantity);
        CSItemReclassHandlingPlaceholder.Qty := BinContent.Quantity;
    end;

    local procedure CheckNewBinCode(var CSItemReclassHandlingPlaceholder: Record "NPR CS Item Reclass. Handling"; InputValue: Text)
    var
        QtyToHandle: Decimal;
        BinContent: Record "Bin Content";
        Bin: Record Bin;
    begin
        if InputValue = '' then begin
            Remark := Text009;
            exit;
        end;

        if StrLen(InputValue) > MaxStrLen(CSItemReclassHandlingPlaceholder."New Bin Code") then begin
            Remark := Text008;
            exit;
        end;

        if InputValue = CSItemReclassHandlingPlaceholder."Bin Code" then begin
            Remark := Text024;
            exit;
        end;

        Clear(Bin);
        Bin.SetRange("Location Code", CSItemReclassHandlingPlaceholder."Location Code");
        Bin.SetRange(Code, InputValue);
        if not Bin.FindSet then begin
            Remark := Text021;
            exit;
        end;

        CSItemReclassHandlingPlaceholder."New Bin Code" := InputValue;
    end;

    local procedure CheckQty(var CSItemReclassHandlingPlaceholder: Record "NPR CS Item Reclass. Handling"; InputValue: Text)
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

        if Qty = 0 then begin
            Remark := Text026;
            exit;
        end;

        Clear(BinContent);
        BinContent.SetRange("Location Code", CSItemReclassHandlingPlaceholder."Location Code");
        BinContent.SetRange("Item No.", CSItemReclassHandlingPlaceholder."Item No.");
        BinContent.SetRange("Variant Code", CSItemReclassHandlingPlaceholder."Variant Code");
        BinContent.SetRange("Bin Code", CSItemReclassHandlingPlaceholder."Bin Code");
        BinContent.SetFilter(Quantity, '>%1', 0);
        if not BinContent.FindFirst then begin
            Remark := StrSubstNo(Text022, BinContent.GetFilters());
            exit;
        end;

        BinContent.CalcFields(Quantity);
        if Qty > BinContent.Quantity then begin
            Remark := Text023;
            exit;
        end;

        CSItemReclassHandlingPlaceholder.Qty := Qty;
    end;

    local procedure CreateDataLine(var CSItemReclassHandling: Record "NPR CS Item Reclass. Handling"; LocationCode: Code[10])
    var
        NewCSItemReclassHandling: Record "NPR CS Item Reclass. Handling";
        LineNo: Integer;
        CSUIHeader: Record "NPR CS UI Header";
        RecRef: RecordRef;
        CSSetup: Record "NPR CS Setup";
    begin
        if LocationCode = '' then
            Error(Text020);

        Clear(NewCSItemReclassHandling);
        NewCSItemReclassHandling.SetRange(Id, CSSessionId);
        if NewCSItemReclassHandling.FindLast then
            LineNo := NewCSItemReclassHandling."Line No." + 1
        else
            LineNo := 1;

        CSItemReclassHandling.Init;
        CSItemReclassHandling.Id := CSSessionId;
        CSItemReclassHandling."Line No." := LineNo;
        CSItemReclassHandling."Created By" := UserId;
        CSItemReclassHandling.Created := CurrentDateTime;
        CSItemReclassHandling."Location Code" := LocationCode;

        if CSUIHeader.Get(CurrentCode) then begin
            if CSUIHeader."Set defaults from last record" then begin
                CSItemReclassHandling.Qty := NewCSItemReclassHandling.Qty;
            end;
        end;

        RecRef.GetTable(CSItemReclassHandling);
        CSItemReclassHandling."Table No." := RecRef.Number;

        CSSetup.Get;
        CSSetup.TestField("Item Reclass. Jour Temp Name");
        CSSetup.TestField("Item Reclass. Jour Batch Name");

        CSItemReclassHandling."Journal Template Name" := CSSetup."Item Reclass. Jour Temp Name";
        CSItemReclassHandling."Journal Batch Name" := CSSetup."Item Reclass. Jour Batch Name";
        CSItemReclassHandling."Record Id" := CSItemReclassHandling.RecordId;

        CSItemReclassHandling.Insert(true);
    end;

    local procedure UpdateDataLine(var CSItemReclassHandling: Record "NPR CS Item Reclass. Handling")
    var
        LineNo: Integer;
        CSSetup: Record "NPR CS Setup";
    begin
        CSItemReclassHandling.Handled := true;
        CSItemReclassHandling.Modify(true);

        if TransferDataLine(CSItemReclassHandling) then begin
            CSItemReclassHandling."Transferred to Worksheet" := true;
            CSItemReclassHandling.Modify(true);
        end;
    end;

    local procedure DeleteEmptyDataLines(var CurrCSItemReclassHandling: Record "NPR CS Item Reclass. Handling")
    var
        CSItemReclassHandling: Record "NPR CS Item Reclass. Handling";
    begin
        CSItemReclassHandling.SetRange(Id, CSSessionId);
        CSItemReclassHandling.SetRange(Handled, false);
        CSItemReclassHandling.SetRange("Transferred to Worksheet", false);
        CSItemReclassHandling.DeleteAll(true);
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
        LineType: Option TEXT,BUTTON;
        CurrRecordID: RecordID;
        TableNo: Integer;
        CSItemReclassHandling: Record "NPR CS Item Reclass. Handling";
        CSSetup: Record "NPR CS Setup";
        ItemJournalLine: Record "Item Journal Line";
    begin
        CSSetup.Get;

        Clear(ItemJournalLine);
        ItemJournalLine.SetRange("Journal Template Name", CSSetup."Item Reclass. Jour Temp Name");
        ItemJournalLine.SetRange("Journal Batch Name", CSSetup."Item Reclass. Jour Batch Name");
        ItemJournalLine.SetRange("External Document No.", CSSessionId);
        if ItemJournalLine.FindSet then begin
            Records := XmlElement.Create('Records');
            repeat
                RecordElement := XmlElement.Create('Record');

                CurrRecordID := ItemJournalLine.RecordId;
                TableNo := CurrRecordID.TableNo;

                Indicator := 'ok';

                Line := XmlElement.Create('Line', '',
                    StrSubstNo(Text015, ItemJournalLine.Quantity, ItemJournalLine."Item No.", ItemJournalLine.Description));
                AddAttribute(Line, 'Descrip', 'Description');
                AddAttribute(Line, 'Indicator', Indicator);
                RecordElement.Add(Line);

                Line := XmlElement.Create('Line');
                AddAttribute(Line, 'Descrip', 'Delete..');
                AddAttribute(Line, 'Type', Format(LineType::BUTTON));
                AddAttribute(Line, 'TableNo', Format(TableNo));
                AddAttribute(Line, 'RecordID', Format(CurrRecordID));
                AddAttribute(Line, 'FuncName', 'DELETELINE');
                RecordElement.Add(Line);

                Line := XmlElement.Create('Line', '', ItemJournalLine."Item No.");
                AddAttribute(Line, 'Descrip', ItemJournalLine.FieldCaption("Item No."));
                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                RecordElement.Add(Line);

                if (ItemJournalLine."Variant Code" <> '') then begin
                    Line := XmlElement.Create('Line', '', ItemJournalLine."Variant Code");
                    AddAttribute(Line, 'Descrip', ItemJournalLine.FieldCaption("Variant Code"));
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    RecordElement.Add(Line);
                end;

                Line := XmlElement.Create('Line', '', ItemJournalLine."Bin Code");
                AddAttribute(Line, 'Descrip', ItemJournalLine.FieldCaption("Bin Code"));
                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                RecordElement.Add(Line);

                Line := XmlElement.Create('Line', '', ItemJournalLine."New Bin Code");
                AddAttribute(Line, 'Descrip', ItemJournalLine.FieldCaption("New Bin Code"));
                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                RecordElement.Add(Line);

                Records.Add(RecordElement);
            until ItemJournalLine.Next = 0;
            exit(true);
        end else
            exit(false);
    end;

    local procedure AddAggSummarize(var Records: XmlElement) NotEmptyResult: Boolean
    var
        RecordElement: XmlElement;
        Line: XmlElement;
        Indicator: Text;
        LineType: Option TEXT,BUTTON;
        CurrRecordID: RecordID;
        TableNo: Integer;
        SummarizeCounting: Query "NPR CS Stock-Take Summarize";
    begin
        Records := XmlElement.Create('Records');

        SummarizeCounting.SetRange(Id, CSSessionId);
        SummarizeCounting.SetRange(Handled, true);
        SummarizeCounting.SetRange(Transferred_to_Worksheet, false);
        SummarizeCounting.Open;
        while SummarizeCounting.Read do begin

            NotEmptyResult := true;
            RecordElement := XmlElement.Create('Record');

            if SummarizeCounting.Item_No = '' then
                Indicator := 'minus'
            else
                Indicator := 'ok';

            if (Indicator = 'ok') then
                Line := XmlElement.Create('Line', '',
                    StrSubstNo(Text015, SummarizeCounting.Count_, SummarizeCounting.Item_No, SummarizeCounting.Item_Description))
            else
                Line := XmlElement.Create('Line', '',
                    StrSubstNo(Text016, SummarizeCounting.Count_, 'Unknown Tag Id'));
            AddAttribute(Line, 'Descrip', 'Description');
            AddAttribute(Line, 'Indicator', Indicator);
            RecordElement.Add(Line);

            Line := XmlElement.Create('Line', '', SummarizeCounting.Item_No);
            AddAttribute(Line, 'Descrip', 'No.');
            AddAttribute(Line, 'Type', Format(LineType::TEXT));
            RecordElement.Add(Line);

            Line := XmlElement.Create('Line', '', SummarizeCounting.Item_Description);
            AddAttribute(Line, 'Descrip', 'Name');
            AddAttribute(Line, 'Type', Format(LineType::TEXT));
            RecordElement.Add(Line);

            if (SummarizeCounting.Variant_Code <> '') then begin
                Line := XmlElement.Create('Line', '',
                    SummarizeCounting.Variant_Code + ' - ' + SummarizeCounting.Variant_Description);
                AddAttribute(Line, 'Descrip', 'Variant');
                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                RecordElement.Add(Line);
            end;

            Records.Add(RecordElement);
        end;

        SummarizeCounting.Close;

        exit(NotEmptyResult);
    end;

    local procedure AddOptions(var Options: XmlElement) NotEmptyResult: Boolean
    begin
        NotEmptyResult := StrMenuTxt <> '';

        if not NotEmptyResult then
            exit(NotEmptyResult);

        Options := XmlElement.Create('Options', '', StrMenuTxt);
        AddAttribute(Options, 'Descrip', Text025);

        exit(NotEmptyResult);
    end;

    local procedure Reset(var CurrCSItemReclassHandling: Record "NPR CS Item Reclass. Handling")
    var
        CSItemReclassHandling: Record "NPR CS Item Reclass. Handling";
        CSSetup: Record "NPR CS Setup";
        ItemJournalLine: Record "Item Journal Line";
    begin
        CSSetup.Get;

        Clear(ItemJournalLine);
        ItemJournalLine.SetRange("Journal Template Name", CSSetup."Item Reclass. Jour Temp Name");
        ItemJournalLine.SetRange("Journal Batch Name", CSSetup."Item Reclass. Jour Batch Name");
        ItemJournalLine.SetRange("External Document No.", CSSessionId);
        ItemJournalLine.DeleteAll(true);

        CSCommunication.SetRecRef(RecRef);
        ActiveInputField := 1;
    end;

    local procedure Register()
    var
        CSSetup: Record "NPR CS Setup";
        ItemJnlTemplate: Record "Item Journal Template";
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
        ItemJournalLine: Record "Item Journal Line";
        CSPostingBuffer: Record "NPR CS Posting Buffer";
        PostingRecRef: RecordRef;
        CSPostEnqueue: Codeunit "NPR CS Post - Enqueue";
        ItemJournalBatch: Record "Item Journal Batch";
    begin
        CSSetup.Get;
        if CSSetup."Post with Job Queue" then begin
            ItemJournalBatch.Get(CSSetup."Item Reclass. Jour Temp Name", CSSetup."Item Reclass. Jour Batch Name");
            PostingRecRef.GetTable(ItemJournalBatch);
            CSPostingBuffer.Init;
            CSPostingBuffer."Table No." := PostingRecRef.Number;
            CSPostingBuffer."Record Id" := PostingRecRef.RecordId;
            CSPostingBuffer."Job Type" := CSPostingBuffer."Job Type"::"Item Reclass.";
            CSPostingBuffer."Session Id" := CSSessionId;
            CSPostingBuffer."Job Queue Priority for Post" := 1000;
            if CSPostingBuffer.Insert(true) then
                CSPostEnqueue.Run(CSPostingBuffer)
            else
                Remark := GetLastErrorText;
        end else begin
            ItemJnlTemplate.Get(CSSetup."Item Reclass. Jour Temp Name");
            ItemJnlTemplate.TestField("Force Posting Report", false);

            Clear(ItemJournalLine);
            ItemJournalLine.SetRange("Journal Template Name", CSSetup."Item Reclass. Jour Temp Name");
            ItemJournalLine.SetRange("Journal Batch Name", CSSetup."Item Reclass. Jour Batch Name");
            ItemJournalLine.SetRange("External Document No.", CSSessionId);
            if ItemJournalLine.FindSet then begin
                repeat
                    ItemJnlPostBatch.Run(ItemJournalLine);
                until ItemJournalLine.Next = 0;
            end;
        end;
    end;

    local procedure TransferDataLine(var CSItemReclassHandling: Record "NPR CS Item Reclass. Handling"): Boolean
    var
        ItemJournalLine: Record "Item Journal Line";
        NewItemJournalLine: Record "Item Journal Line";
        LineNo: Integer;
        ItemJnlTemplate: Record "Item Journal Template";
        ItemJnlBatch: Record "Item Journal Batch";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
        PostingRecRef: RecordRef;
        CSPostEnqueue: Codeunit "NPR CS Post - Enqueue";
        CSPostingBuffer: Record "NPR CS Posting Buffer";
        CSSetup: Record "NPR CS Setup";
    begin
        CSSetup.Get;

        Clear(NewItemJournalLine);
        NewItemJournalLine.SetRange("Journal Template Name", CSSetup."Item Reclass. Jour Temp Name");
        NewItemJournalLine.SetRange("Journal Batch Name", CSSetup."Item Reclass. Jour Batch Name");
        LineNo := 0;
        if NewItemJournalLine.FindLast then
            LineNo := NewItemJournalLine."Line No." + 1000
        else
            LineNo := 1000;

        Clear(ItemJournalLine);
        ItemJournalLine.Validate("Journal Template Name", CSSetup."Item Reclass. Jour Temp Name");
        ItemJournalLine.Validate("Journal Batch Name", CSSetup."Item Reclass. Jour Batch Name");
        ItemJournalLine."Line No." := LineNo;
        ItemJournalLine.Insert(true);

        ItemJournalLine.Validate("Entry Type", ItemJournalLine."Entry Type"::Transfer);
        ItemJournalLine.Validate("Item No.", CSItemReclassHandling."Item No.");
        ItemJournalLine.Validate("Variant Code", CSItemReclassHandling."Variant Code");
        ItemJournalLine.Validate("Location Code", CSItemReclassHandling."Location Code");
        ItemJournalLine.Validate("New Location Code", CSItemReclassHandling."Location Code");
        ItemJournalLine.Validate(Quantity, CSItemReclassHandling.Qty);
        ItemJournalLine.Validate("Bin Code", CSItemReclassHandling."Bin Code");
        ItemJournalLine.Validate("New Bin Code", CSItemReclassHandling."New Bin Code");
        ItemJournalLine."Posting Date" := WorkDate;
        ItemJournalLine."Document Date" := WorkDate;

        ItemJnlTemplate.Get(ItemJournalLine."Journal Template Name");
        ItemJnlBatch.Get(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");

        if CSSetup."Post with Job Queue" then begin
            ItemJournalLine."Document No." := Format(Today);
        end else begin
            Clear(NoSeriesMgt);
            ItemJournalLine."Document No." := NoSeriesMgt.GetNextNo(ItemJnlBatch."No. Series", ItemJournalLine."Posting Date", false);
        end;
        ItemJournalLine."Source Code" := ItemJnlTemplate."Source Code";
        ItemJournalLine."Reason Code" := ItemJnlBatch."Reason Code";
        ItemJournalLine."Posting No. Series" := ItemJnlBatch."Posting No. Series";
        ItemJournalLine."External Document No." := CSSessionId;
        ItemJournalLine.Modify(true);

        if CSSetup."Post with Job Queue" then begin
            PostingRecRef.GetTable(ItemJnlBatch);
            CSPostingBuffer.Init;
            CSPostingBuffer."Table No." := PostingRecRef.Number;
            CSPostingBuffer."Record Id" := PostingRecRef.RecordId;
            CSPostingBuffer."Job Type" := CSPostingBuffer."Job Type"::"Item Reclass.";
            CSPostingBuffer."Session Id" := CSSessionId;
            if CSPostingBuffer.Insert(true) then
                CSPostEnqueue.Run(CSPostingBuffer)
            else
                Remark := GetLastErrorText;
        end else begin
            ItemJnlPostBatch.Run(ItemJournalLine);
        end;

        exit(true);
    end;
}
