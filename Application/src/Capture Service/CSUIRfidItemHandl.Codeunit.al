codeunit 6151369 "NPR CS UI Rfid Item Handl."
{
    // NPR5.47/CLVA/20181012 CASE 318296 Object created
    // NPR5.48/CLVA/20181227 CASE 335051 Added media lib check

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
        CSSessionId: Text;
        Text013: Label 'Input value is not valid';
        Text015: Label '%1 : %2 %3';
        Text016: Label '%1 : %2';
        Text020: Label 'Variant is not a record';
        Text021: Label 'No Rfid Tags Models supported';
        Text022: Label 'Rfid Tag Family %1 and Model %2 is not supported';
        Text023: Label 'Rfid Tag Model %1 is discontinued. Item Cross Reference can''t be created with this model';
        Text024: Label 'Item Cross Reference %1 already exists';
        Text025: Label 'Tag TID lenght %1 is not supported. Max lenght is %2';
        Text026: Label 'Tag TID %1 is already assigned to Item No. %2';
        ItemKeyRef: Record Item;
        AddKey: Boolean;

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
        CSRfidItemHandling: Record "NPR CS Rfid Item Handl.";
        CSRfidItemHandling2: Record "NPR CS Rfid Item Handl.";
        CommaString: DotNet NPRNetString;
        Values: DotNet NPRNetArray;
        Separator: DotNet NPRNetString;
        Value: Text;
        SetDefaults: Boolean;
        i: Integer;
        ItemNo: Code[20];
        DuplicateIndicator: Boolean;
    begin
        if XMLDOMMgt.FindNode(RootNode, 'Header/Input', ReturnedNode) then
            TextValue := ReturnedNode.InnerText
        else
            Error(Text006);

        Evaluate(TableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'RecordID'));
        if RecRef.Get(RecId) then begin
            RecRef.SetTable(CSRfidItemHandling);
            RecRef.SetRecFilter;
            CSCommunication.SetRecRef(RecRef);
        end else begin
            CSCommunication.RunPreviousUI(DOMxmlin);
            exit;
        end;

        if StrLen(TextValue) < 250 then
            FuncGroup.KeyDef := CSCommunication.GetFunctionKey(CSUIHeader.Code, TextValue)
        else
            FuncGroup.KeyDef := FuncGroup.KeyDef::Input;

        ActiveInputField := 1;

        case FuncGroup.KeyDef of
            FuncGroup.KeyDef::Esc:
                begin
                    DeleteEmptyDataLines(CSRfidItemHandling);
                    CSCommunication.RunPreviousUI(DOMxmlin);
                end;
            FuncGroup.KeyDef::"Function":
                begin
                    FuncName := CSCommunication.GetNodeAttribute(ReturnedNode, 'FuncName');
                    case FuncName of
                        'DELETELINE':
                            begin
                                ItemNo := CSCommunication.GetNodeAttribute(ReturnedNode, 'FuncRecordID');
                                DuplicateIndicator := (CSCommunication.GetNodeAttribute(ReturnedNode, 'FuncRecordID') = 'minus');
                                CSRfidItemHandling.SetRange("Item No.", ItemNo);
                                CSRfidItemHandling.SetRange("Duplicate Tag Id", DuplicateIndicator);
                                CSRfidItemHandling.SetRange("Transferred to Item Cross Ref.", false);
                                CSRfidItemHandling.DeleteAll(true);
                            end;
                    end;
                end;
            FuncGroup.KeyDef::First:
                begin
                    CSRfidItemHandling.Barcode := '';
                    CSRfidItemHandling."Item No." := '';
                    CSRfidItemHandling."Variant Code" := '';
                    CSRfidItemHandling.Modify(true);
                    RecRef.GetTable(CSRfidItemHandling);
                    CSCommunication.FindRecRef(RecRef, 0, CSUIHeader."No. of Records in List");
                end;
            FuncGroup.KeyDef::Reset:
                begin
                    Reset;
                    CSRfidItemHandling.Barcode := '';
                    CSRfidItemHandling."Item No." := '';
                    CSRfidItemHandling."Variant Code" := '';
                    CSRfidItemHandling.Modify(true);
                    RecRef.GetTable(CSRfidItemHandling);
                    CSCommunication.FindRecRef(RecRef, 0, CSUIHeader."No. of Records in List");
                end;
            FuncGroup.KeyDef::Register:
                begin
                    Register;
                    if Remark = '' then begin
                        DeleteEmptyDataLines(CSRfidItemHandling);
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

                    //SetDefaults := (Values.Length > 1);

                    foreach Value in Values do begin

                        i += 1;
                        SetDefaults := (i < Values.Length);

                        if Value <> '' then begin

                            case FldNo of
                                CSRfidItemHandling.FieldNo(Barcode):
                                    CheckBarcode(CSRfidItemHandling, Value);
                                CSRfidItemHandling.FieldNo("Rfid Id"):
                                    CheckRfidId(CSRfidItemHandling, Value);
                                else begin
                                        CSCommunication.FieldSetvalue(RecRef, FldNo, Value);
                                    end;
                            end;

                            CSRfidItemHandling.Modify(true);

                            RecRef.GetTable(CSRfidItemHandling);
                            CSCommunication.SetRecRef(RecRef);
                            ActiveInputField := CSCommunication.GetActiveInputNo(CurrentCode, FldNo);
                            if Remark = '' then begin
                                if CSCommunication.LastEntryField(CurrentCode, FldNo) then begin

                                    UpdateDataLine(CSRfidItemHandling);
                                    //IF TransferDataLine(CSRfidItemHandling) THEN BEGIN
                                    //  CSRfidItemHandling."Transferred to Item Cross Ref." := TRUE;
                                    //  CSRfidItemHandling.MODIFY(TRUE);
                                    //END;
                                    CreateDataLine(CSRfidItemHandling2, CSRfidItemHandling, SetDefaults);

                                    //              IF (i = Values.Length) THEN BEGIN
                                    //                CSRfidItemHandling2.Barcode := '';
                                    //                CSRfidItemHandling2."Item No." := '';
                                    //                CSRfidItemHandling2."Variant Code" := '';
                                    //                CSRfidItemHandling2."Rfid Id" := '';
                                    //                CSRfidItemHandling2.MODIFY(TRUE);
                                    //              END;

                                    RecRef.GetTable(CSRfidItemHandling2);
                                    CSCommunication.SetRecRef(RecRef);

                                    Clear(CSRfidItemHandling);
                                    CSRfidItemHandling := CSRfidItemHandling2;

                                    ActiveInputField := 1
                                end else begin
                                    UpdateDataLine(CSRfidItemHandling);
                                    RecRef.GetTable(CSRfidItemHandling);
                                    CSCommunication.SetRecRef(RecRef);
                                    ActiveInputField += 1;
                                end;
                            end;
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
        CSRfidItemHandling: Record "NPR CS Rfid Item Handl.";
        RecId: RecordID;
        TableNo: Integer;
    begin
        DeleteEmptyDataLines(CSRfidItemHandling);
        CreateDataLine(CSRfidItemHandling, CSRfidItemHandling, false);

        RecId := CSRfidItemHandling.RecordId;

        RecRef.Open(RecId.TableNo);
        RecRef.Get(RecId);
        RecRef.SetRecFilter;

        CSCommunication.SetRecRef(RecRef);
        ActiveInputField := 1;
        SendForm(ActiveInputField);
    end;

    local procedure SendForm(InputField: Integer)
    var
        Records: DotNet NPRNetXmlElement;
    begin
        CSCommunication.EncodeUI(CSUIHeader, StackCode, DOMxmlin, InputField, Remark, CSUserId);
        CSCommunication.GetReturnXML(DOMxmlin);

        if AddKey then
            if AddKeyObject(Records) then
                DOMxmlin.DocumentElement.AppendChild(Records);

        if AddSummarize(Records) then
            DOMxmlin.DocumentElement.AppendChild(Records);

        CSMgt.SendXMLReply(DOMxmlin);
    end;

    local procedure CheckBarcode(var CSRfidItemPlaceholder: Record "NPR CS Rfid Item Handl."; InputValue: Text)
    var
        BarcodeLibrary: Codeunit "NPR Barcode Library";
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
    begin
        if InputValue = '' then begin
            Remark := Text005;
            exit;
        end;

        if StrLen(InputValue) > MaxStrLen(CSRfidItemPlaceholder.Barcode) then begin
            Remark := Text008;
            exit;
        end;

        if BarcodeLibrary.TranslateBarcodeToItemVariant(InputValue, ItemNo, VariantCode, ResolvingTable, true) then begin
            CSRfidItemPlaceholder."Item No." := ItemNo;
            CSRfidItemPlaceholder."Variant Code" := VariantCode;
        end else begin
            Remark := StrSubstNo(Text010, CSRfidItemPlaceholder.Barcode);
            exit;
        end;

        AddKey := ItemKeyRef.Get(ItemNo);

        CSRfidItemPlaceholder.Barcode := InputValue;
    end;

    local procedure CheckRfidId(var CSRfidItemPlaceholder: Record "NPR CS Rfid Item Handl."; InputValue: Text)
    var
        CSRfidTagModels: Record "NPR CS Rfid Tag Models";
        ItemCrossReference: Record "Item Cross Reference";
        TagFamily: Code[10];
        TagModel: Code[10];
        TagId: Code[20];
        TestCSRfidItemPlaceholder: Record "NPR CS Rfid Item Handl.";
    begin
        if InputValue = '' then begin
            Remark := Text005;
            exit;
        end;

        if StrLen(InputValue) > 24 then begin
            Remark := StrSubstNo(Text025, StrLen(InputValue), 24);
            exit;
        end;

        if not CSRfidTagModels.FindFirst then begin
            Remark := Text021;
            exit;
        end;

        TagFamily := CopyStr(InputValue, 1, 4);
        TagModel := CopyStr(InputValue, 5, 4);
        TagId := CopyStr(InputValue, 5);

        if (StrLen(InputValue) > MaxStrLen(CSRfidItemPlaceholder."Rfid Id")) or (StrLen(InputValue) < MaxStrLen(CSRfidTagModels.Family)) then begin
            Remark := Text008;
            exit;
        end;

        if not CSRfidTagModels.Get(TagFamily, TagModel) then begin
            Remark := StrSubstNo(Text022, TagFamily, TagModel);
            exit;
        end;

        if CSRfidTagModels.Discontinued then begin
            Remark := StrSubstNo(Text023, TagFamily, TagModel);
            exit;
        end;

        Clear(TestCSRfidItemPlaceholder);
        TestCSRfidItemPlaceholder.SetRange(Id, CSSessionId);
        TestCSRfidItemPlaceholder.SetRange("Transferred to Item Cross Ref.", false);
        TestCSRfidItemPlaceholder.SetRange("Rfid Id", InputValue);
        if TestCSRfidItemPlaceholder.FindSet then begin
            CSRfidItemPlaceholder."Duplicate Tag Id" := true;
            Remark := StrSubstNo(Text026, InputValue, TestCSRfidItemPlaceholder."Item No.");
            exit;
        end;

        Clear(ItemCrossReference);
        ItemCrossReference.SetRange("Cross-Reference Type", ItemCrossReference."Cross-Reference Type"::"Bar Code");
        ItemCrossReference.SetRange("Cross-Reference No.", TagId);
        ItemCrossReference.SetRange("NPR Is Retail Serial No.", true);
        if ItemCrossReference.FindSet then begin
            CSRfidItemPlaceholder."Duplicate Tag Id" := true;
            Remark := StrSubstNo(Text024, InputValue);
            exit;
        end;

        CSRfidItemPlaceholder."Rfid Id" := InputValue;
    end;

    local procedure CreateDataLine(var CSRfidItemHandling: Record "NPR CS Rfid Item Handl."; CurrCSRfidItemHandling: Record "NPR CS Rfid Item Handl."; SetDefaults: Boolean)
    var
        NewCSRfidItemHandling: Record "NPR CS Rfid Item Handl.";
        LineNo: Integer;
        RecRef: RecordRef;
    begin
        Clear(NewCSRfidItemHandling);
        NewCSRfidItemHandling.SetRange(Id, CSSessionId);
        if NewCSRfidItemHandling.FindLast then
            LineNo := NewCSRfidItemHandling."Line No." + 1
        else
            LineNo := 1;

        CSRfidItemHandling.Init;
        CSRfidItemHandling.Id := CSSessionId;
        CSRfidItemHandling."Line No." := LineNo;
        CSRfidItemHandling."Created By" := UserId;
        CSRfidItemHandling.Created := CurrentDateTime;

        if SetDefaults then begin
            CSRfidItemHandling.Barcode := NewCSRfidItemHandling.Barcode;
            CSRfidItemHandling."Item No." := NewCSRfidItemHandling."Item No.";
            CSRfidItemHandling."Variant Code" := NewCSRfidItemHandling."Variant Code";
            CSRfidItemHandling."Rfid Id" := CurrCSRfidItemHandling."Rfid Id";
            CSRfidItemHandling.Handled := NewCSRfidItemHandling.Handled;
        end;

        RecRef.GetTable(CSRfidItemHandling);

        CSRfidItemHandling."Table No." := RecRef.Number;
        CSRfidItemHandling."Record Id" := CSRfidItemHandling.RecordId;
        CSRfidItemHandling.Insert(true);

        CSRfidItemHandling."Rfid Id" := '';
    end;

    local procedure UpdateDataLine(var CSRfidItemHandling: Record "NPR CS Rfid Item Handl.")
    var
        LineNo: Integer;
        BarcodeLibrary: Codeunit "NPR Barcode Library";
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
        CSSetup: Record "NPR CS Setup";
    begin
        // IF BarcodeLibrary.TranslateBarcodeToItemVariant(CSRfidItemHandling.Barcode, ItemNo, VariantCode, ResolvingTable, TRUE) THEN BEGIN
        //  CSRfidItemHandling."Item No." := ItemNo;
        //  CSRfidItemHandling."Variant Code" := VariantCode;
        // END ELSE BEGIN
        //  CSSetup.GET;
        //  IF CSSetup."Error On Invalid Barcode" THEN
        //    Remark := STRSUBSTNO(Text010,CSRfidItemHandling.Barcode);
        // END;

        if CSRfidItemHandling."Rfid Id" <> '' then
            CSRfidItemHandling.Handled := true;
        CSRfidItemHandling.Modify(true);
    end;

    local procedure DeleteEmptyDataLines(var CurrCSRfidItemHandling: Record "NPR CS Rfid Item Handl.")
    var
        CSRfidItemHandling: Record "NPR CS Rfid Item Handl.";
    begin
        CSRfidItemHandling.SetRange(Id, CSSessionId);
        CSRfidItemHandling.SetRange(Handled, false);
        CSRfidItemHandling.SetRange("Transferred to Item Cross Ref.", false);
        CSRfidItemHandling.DeleteAll(true);
    end;

    local procedure AddAttribute(var NewChild: DotNet NPRNetXmlNode; AttribName: Text[250]; AttribValue: Text[250])
    begin
        if XMLDOMMgt.AddAttribute(NewChild, AttribName, AttribValue) > 0 then
            Error(Text002, AttribName);
    end;

    local procedure AddSummarize(var Records: DotNet NPRNetXmlElement) NotEmptyResult: Boolean
    var
        "Record": DotNet NPRNetXmlElement;
        Line: DotNet NPRNetXmlElement;
        Indicator: Text;
        LineType: Option TEXT,BUTTON;
        CurrRecordID: Code[20];
        TableNo: Integer;
        SummarizeCounting: Query "NPR CS Rfid Item Totals";
    begin
        Records := DOMxmlin.CreateElement('Records');

        SummarizeCounting.SetRange(Id, CSSessionId);
        SummarizeCounting.SetRange(Handled, true);
        SummarizeCounting.SetRange(Transferred_to_Item_Cross_Ref, false);
        SummarizeCounting.Open;
        while SummarizeCounting.Read do begin
            NotEmptyResult := true;
            Record := DOMxmlin.CreateElement('Record');

            //CurrRecordID := SummarizeCounting.Item_No;
            //TableNo := CurrRecordID.TABLENO;

            if SummarizeCounting.Duplicate_Tag_Id then
                Indicator := 'minus'
            else
                Indicator := 'ok';

            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line, 'Descrip', 'Description');
            AddAttribute(Line, 'Indicator', Indicator);
            if (Indicator = 'ok') then
                Line.InnerText := StrSubstNo(Text015, SummarizeCounting.Count_, SummarizeCounting.Item_No, SummarizeCounting.Item_Description)
            else
                Line.InnerText := StrSubstNo(Text016, SummarizeCounting.Count_, 'Duplicated Rfid Ids');
            Record.AppendChild(Line);

            if (SummarizeCounting.Variant_Code <> '') then begin
                Line := DOMxmlin.CreateElement('Line');
                AddAttribute(Line, 'Descrip', 'Variant');
                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                Line.InnerText := SummarizeCounting.Variant_Code + ' - ' + SummarizeCounting.Variant_Description;
                Record.AppendChild(Line);
            end;

            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line, 'Descrip', 'Delete..');
            AddAttribute(Line, 'Type', Format(LineType::BUTTON));
            AddAttribute(Line, 'TableNo', Indicator);
            AddAttribute(Line, 'RecordID', SummarizeCounting.Item_No);
            AddAttribute(Line, 'FuncName', 'DELETELINE');
            Record.AppendChild(Line);

            Records.AppendChild(Record);
        end;
        SummarizeCounting.Close;

        exit(NotEmptyResult);
    end;

    local procedure AddKeyObject(var Records: DotNet NPRNetXmlElement) NotEmptyResult: Boolean
    var
        "Record": DotNet NPRNetXmlElement;
        Line: DotNet NPRNetXmlElement;
        ImageUrl: Text;
        MagentoPicture: Record "NPR Magento Picture";
        MagentoPictureLink: Record "NPR Magento Picture Link";
        CSSetup: Record "NPR CS Setup";
    begin
        CSSetup.Get;
        Records := DOMxmlin.CreateElement('KeyObjects');
        Record := DOMxmlin.CreateElement('Record');

        NotEmptyResult := true;
        Line := DOMxmlin.CreateElement('Line');
        AddAttribute(Line, 'Key', ItemKeyRef."No.");
        AddAttribute(Line, 'Title', ItemKeyRef.Description);

        //-NPR5.48 [335051]
        if CSSetup."Media Library" = CSSetup."Media Library"::Magento then begin
            //+NPR5.48 [335051]
            MagentoPictureLink.SetRange("Item No.", ItemKeyRef."No.");
            MagentoPictureLink.SetRange("Base Image", true);
            if MagentoPictureLink.FindFirst then
                if MagentoPicture.Get(MagentoPicture.Type::Item, MagentoPictureLink."Picture Name") then
                    ImageUrl := MagentoPicture.GetMagentoUrl;
            //-NPR5.48 [335051]
        end;
        //+NPR5.48 [335051]

        AddAttribute(Line, 'ImageUrl', ImageUrl);

        Record.AppendChild(Line);

        AddKey := false;
        Records.AppendChild(Record);

        exit(NotEmptyResult);
    end;

    local procedure Reset()
    var
        CSRfidItemHandling: Record "NPR CS Rfid Item Handl.";
    begin
        Clear(CSRfidItemHandling);
        CSRfidItemHandling.SetRange(Id, CSSessionId);
        CSRfidItemHandling.SetRange(Handled, true);
        CSRfidItemHandling.SetRange("Transferred to Item Cross Ref.", false);
        CSRfidItemHandling.DeleteAll(true);
    end;

    local procedure Register()
    var
        CSRfidItemHandling: Record "NPR CS Rfid Item Handl.";
    begin
        CSRfidItemHandling.SetRange(Id, CSSessionId);
        CSRfidItemHandling.SetRange(Handled, true);
        CSRfidItemHandling.SetRange("Duplicate Tag Id", false);
        CSRfidItemHandling.SetRange("Transferred to Item Cross Ref.", false);
        if CSRfidItemHandling.FindSet then begin
            repeat
                if TransferDataLine(CSRfidItemHandling) then begin
                    CSRfidItemHandling."Transferred to Item Cross Ref." := true;
                    CSRfidItemHandling.Modify(true);
                end;
            until CSRfidItemHandling.Next = 0;
        end;
    end;

    local procedure TransferDataLine(var CSRfidItemHandling: Record "NPR CS Rfid Item Handl."): Boolean
    var
        ItemCrossReference: Record "Item Cross Reference";
        TagId: Code[20];
    begin

        TagId := CopyStr(CSRfidItemHandling."Rfid Id", 5);

        Clear(ItemCrossReference);
        ItemCrossReference.Validate("Item No.", CSRfidItemHandling."Item No.");
        ItemCrossReference.Validate("Variant Code", CSRfidItemHandling."Variant Code");
        ItemCrossReference.Validate("Cross-Reference Type", ItemCrossReference."Cross-Reference Type"::"Bar Code");
        ItemCrossReference.Validate("Cross-Reference No.", TagId);
        ItemCrossReference.Validate("NPR Is Retail Serial No.", true);
        ItemCrossReference.Insert(true);

        exit(true);
    end;
}

