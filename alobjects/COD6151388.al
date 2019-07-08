codeunit 6151388 "CS UI Warehouse Receipt"
{
    // NPR5.41/NPKNAV/20180427  CASE 306407 Transport NPR5.41 - 27 April 2018
    // NPR5.43/CLVA/20180604 CASE 304872 Added previous value to qty
    // NPR5.48/CLVA/20181109  CASE 335606 Handling UOM
    // NPR5.49/TJ  /20190220 CASE 346224 If Variant Code is used, it's added to InnerText
    // NPR5.50/CLVA/20190116 CASE 335606 Added variant filter.
    //                                   Removed loop
    // NPR5.50/CLVA/20190226 CASE 346068 Added support for Rfid
    // NPR5.50/CLVA/20190425 CASE 247747 Added functionality to hid fulfilled lines

    TableNo = "CS UI Header";

    trigger OnRun()
    var
        MiniformMgmt: Codeunit "CS UI Management";
    begin
        MiniformMgmt.Initialize(
          MiniformHeader,Rec,DOMxmlin,ReturnedNode,
          RootNode,XMLDOMMgt,CSCommunication,CSUserId,
          CurrentCode,StackCode,WhseEmpId,LocationFilter,CSSessionId);

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
        Text016: Label 'Qty. to Receive exceed Outstanding Qty.';
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
        CSWarehouseReceiptHandling: Record "CS Warehouse Receipt Handling";
        CSWarehouseReceiptHandling2: Record "CS Warehouse Receipt Handling";
        CSFieldDefaults: Record "CS Field Defaults";
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
        CommaString: DotNet npNetString;
        Values: DotNet npNetArray;
        Separator: DotNet npNetString;
        Value: Text;
    begin
        if XMLDOMMgt.FindNode(RootNode,'Header/Input',ReturnedNode) then
          TextValue := ReturnedNode.InnerText
        else
          Error(Text006);

        Evaluate(TableNo,CSCommunication.GetNodeAttribute(ReturnedNode,'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId,CSCommunication.GetNodeAttribute(ReturnedNode,'RecordID'));
        if RecRef.Get(RecId) then begin
          RecRef.SetTable(CSWarehouseReceiptHandling);
          RecRef.SetRecFilter;
          CSCommunication.SetRecRef(RecRef);
        end else begin
          CSCommunication.RunPreviousUI(DOMxmlin);
          exit;
        end;

        FuncGroup.KeyDef := CSCommunication.GetFunctionKey(MiniformHeader.Code,TextValue);
        ActiveInputField := 1;

        case FuncGroup.KeyDef of
          FuncGroup.KeyDef::Esc:
            begin
              DeleteEmptyDataLines();
              CSCommunication.RunPreviousUI(DOMxmlin);
            end;
          FuncGroup.KeyDef::"Function":
            begin
              FuncName := CSCommunication.GetNodeAttribute(ReturnedNode,'FuncName');
              case FuncName of
                  'DEFAULT':
                  begin
                    FuncValue := CSCommunication.GetNodeAttribute(ReturnedNode,'FuncValue');
                    Evaluate(FuncFieldId,CSCommunication.GetNodeAttribute(ReturnedNode,'FieldID'));
                    if CSFieldDefaults.Get(CSUserId,CurrentCode,FuncFieldId) then begin
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
              Evaluate(FldNo,CSCommunication.GetNodeAttribute(ReturnedNode,'FieldID'));
              //-NPR5.50 [346068]
              CommaString := TextValue;
              Separator := ',';
              Values := CommaString.Split(Separator.ToCharArray());

              foreach Value in Values do begin

                if Value <> '' then begin
              //+NPR5.50 [346068]

                case FldNo of
                  CSWarehouseReceiptHandling.FieldNo(Barcode):
                    //-NPR5.50 [346068]
                    //CheckBarcode(CSWarehouseReceiptHandling,TextValue);
                    CheckBarcode(CSWarehouseReceiptHandling,Value);
                    //+NPR5.50 [346068]
                  CSWarehouseReceiptHandling.FieldNo(Qty):
                    //-NPR5.50 [346068]
                    //CheckQty(CSWarehouseReceiptHandling,TextValue);
                    CheckQty(CSWarehouseReceiptHandling,Value);
                    //+NPR5.50 [346068]
                  CSWarehouseReceiptHandling.FieldNo("Bin Code"):
                    //-NPR5.50 [346068]
                    //CheckBin(CSWarehouseReceiptHandling,TextValue);
                    CheckBin(CSWarehouseReceiptHandling,Value);
                    //+NPR5.50 [346068]
                  else begin
                    //-NPR5.50 [346068]
                    //CSCommunication.FieldSetvalue(RecRef,FldNo,TextValue);
                    CSCommunication.FieldSetvalue(RecRef,FldNo,Value);
                    //+NPR5.50 [346068]
                  end;
                end;

                CSWarehouseReceiptHandling.Modify;

                RecRef.GetTable(CSWarehouseReceiptHandling);
                CSCommunication.SetRecRef(RecRef);
                ActiveInputField := CSCommunication.GetActiveInputNo(CurrentCode,FldNo);
                if Remark = '' then
                  if CSCommunication.LastEntryField(CurrentCode,FldNo) then begin

                    Clear(CSFieldDefaults);
                    CSFieldDefaults.SetRange(Id,CSUserId);
                    CSFieldDefaults.SetRange("Use Case Code",CurrentCode);
                    if CSFieldDefaults.FindSet then begin
                      repeat
                        CSCommunication.FieldSetvalue(RecRef,CSFieldDefaults."Field No",CSFieldDefaults.Value);
                        RecRef.SetTable(CSWarehouseReceiptHandling);
                        RecRef.SetRecFilter;
                        CSCommunication.SetRecRef(RecRef);
                      until CSFieldDefaults.Next = 0;
                    end;

                    UpdateDataLine(CSWarehouseReceiptHandling);
                    CreateDataLine(CSWarehouseReceiptHandling2,CSWarehouseReceiptHandling);
                    RecRef.GetTable(CSWarehouseReceiptHandling2);
                    CSCommunication.SetRecRef(RecRef);
                    ActiveInputField := 1;
                  end else
                    ActiveInputField += 1;
                end;
            //-NPR5.50 [346068]
              end;
            end;
            //+NPR5.50 [346068]
          else
            Error(Text000);
        end;

        if not (FuncGroup.KeyDef in [FuncGroup.KeyDef::Esc,FuncGroup.KeyDef::Register]) then
          SendForm(ActiveInputField);
    end;

    local procedure PrepareData()
    var
        WarehouseReceiptHeader: Record "Warehouse Receipt Header";
        CSWarehouseReceiptHandling: Record "CS Warehouse Receipt Handling";
        RecId: RecordID;
        TableNo: Integer;
    begin
        XMLDOMMgt.FindNode(RootNode,'Header/Input',ReturnedNode);

        Evaluate(TableNo,CSCommunication.GetNodeAttribute(ReturnedNode,'TableNo'));
        Evaluate(RecId,CSCommunication.GetNodeAttribute(ReturnedNode,'RecordID'));

        RecRef.Open(TableNo);
        RecRef.Get(RecId);
        RecRef.SetTable(WarehouseReceiptHeader);

        DeleteEmptyDataLines();
        CreateDataLine(CSWarehouseReceiptHandling,WarehouseReceiptHeader);

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
        Records: DotNet npNetXmlElement;
    begin
        CSCommunication.EncodeUI(MiniformHeader,StackCode,DOMxmlin,InputField,Remark,CSUserId);
        CSCommunication.GetReturnXML(DOMxmlin);

        if AddSummarize(Records) then
          DOMxmlin.DocumentElement.AppendChild(Records);

        CSMgt.SendXMLReply(DOMxmlin);
    end;

    local procedure CheckBarcode(var CSWarehouseReceiptHandling: Record "CS Warehouse Receipt Handling";InputValue: Text)
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

        if StrLen(InputValue) > MaxStrLen(CSWarehouseReceiptHandling.Barcode) then begin
          Remark := Text008;
          exit;
        end;

        if BarcodeLibrary.TranslateBarcodeToItemVariant(InputValue, ItemNo, VariantCode, ResolvingTable, true) then begin
          if not Item.Get(ItemNo) then begin
            Remark := StrSubstNo(Text014,InputValue);
            exit;
          end;

          CSWarehouseReceiptHandling."Item No." := ItemNo;
          CSWarehouseReceiptHandling."Variant Code" := VariantCode;

          //-NPR5.48 [335606]
          if (ResolvingTable = DATABASE::"Item Cross Reference") then begin
            with ItemCrossReference do begin
              if (StrLen(InputValue) <= MaxStrLen("Cross-Reference No.")) then begin
                SetCurrentKey("Cross-Reference Type", "Cross-Reference No.");
                SetFilter("Cross-Reference Type", '=%1', "Cross-Reference Type"::"Bar Code");
                SetFilter("Cross-Reference No.", '=%1', UpperCase (InputValue));
                if FindFirst() then
                  CSWarehouseReceiptHandling."Unit of Measure" := ItemCrossReference."Unit of Measure";
              end;
            end;
          end;
          //+NPR5.48 [335606]

        end else begin
          Remark := StrSubstNo(Text010,InputValue);
          exit;
        end;

        CSWarehouseReceiptHandling.Barcode := InputValue;
    end;

    local procedure CheckQty(var CSWarehouseReceiptHandling: Record "CS Warehouse Receipt Handling";InputValue: Text)
    var
        Qty: Decimal;
    begin
        if InputValue = '' then begin
          Remark := Text011;
          exit;
        end;

        if not Evaluate(Qty,InputValue) then begin
          Remark := Text013;
          exit;
        end;

        CSWarehouseReceiptHandling.Qty := Qty;
    end;

    local procedure CheckBin(var CSWarehouseReceiptHandling: Record "CS Warehouse Receipt Handling";InputValue: Text)
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

        if not Bin.Get(CSWarehouseReceiptHandling."Location Code",InputValue) then begin
          Remark := StrSubstNo(Text017,InputValue);
          exit;
        end;

        CSWarehouseReceiptHandling."Bin Code" := InputValue;
    end;

    local procedure CreateDataLine(var CSWarehouseReceiptHandling: Record "CS Warehouse Receipt Handling";RecordVariant: Variant)
    var
        NewCSWarehouseReceiptHandling: Record "CS Warehouse Receipt Handling";
        LineNo: Integer;
        RecRefByVariant: RecordRef;
        CSWarehouseReceiptHandlingByVar: Record "CS Warehouse Receipt Handling";
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

        //-NPR5.43 [304872]
        CSWarehouseReceiptHandling.Qty := NewCSWarehouseReceiptHandling.Qty;
        //+NPR5.43 [304872]

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

    local procedure UpdateDataLine(var CSWarehouseReceiptHandling: Record "CS Warehouse Receipt Handling")
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
        CSWarehouseReceiptHandling: Record "CS Warehouse Receipt Handling";
    begin
        CSWarehouseReceiptHandling.SetRange(Id,CSSessionId);
        CSWarehouseReceiptHandling.SetRange(Handled,false);
        CSWarehouseReceiptHandling.DeleteAll(true);
    end;

    local procedure AddAttribute(var NewChild: DotNet npNetXmlNode;AttribName: Text[250];AttribValue: Text[250])
    begin
        if XMLDOMMgt.AddAttribute(NewChild,AttribName,AttribValue) > 0 then
          Error(Text002,AttribName);
    end;

    local procedure AddSummarize(var Records: DotNet npNetXmlElement): Boolean
    var
        "Record": DotNet npNetXmlElement;
        Line: DotNet npNetXmlElement;
        Indicator: Text;
        CSWarehouseReceiptHandling: Record "CS Warehouse Receipt Handling";
        WhseReceiptLine: Record "Warehouse Receipt Line";
        LineType: Option TEXT,BUTTON;
        CurrRecordID: RecordID;
        TableNo: Integer;
    begin
        Clear(CSWarehouseReceiptHandling);
        CSWarehouseReceiptHandling.SetRange(Id,CSSessionId);
        if not CSWarehouseReceiptHandling.FindLast then
          exit(false);

        WhseReceiptLine.SetRange("No.",CSWarehouseReceiptHandling."No.");
        if WhseReceiptLine.FindSet then begin
          Records := DOMxmlin.CreateElement('Records');
          repeat
            Record := DOMxmlin.CreateElement('Record');

            CurrRecordID := WhseReceiptLine.RecordId;
            TableNo := CurrRecordID.TableNo;

            if (WhseReceiptLine."Qty. to Receive" < WhseReceiptLine."Qty. Outstanding") then
              Indicator := 'minus'
            else if (WhseReceiptLine."Qty. to Receive" = WhseReceiptLine."Qty. Outstanding") then
              Indicator := 'ok'
            else
              Indicator := 'plus';

            if Indicator = 'minus' then begin
              Line := DOMxmlin.CreateElement('Line');
              AddAttribute(Line,'Descrip',WhseReceiptLine.FieldCaption(Description));
              AddAttribute(Line,'Indicator',Indicator);
              AddAttribute(Line,'Type',Format(LineType::TEXT));
              //-NPR5.49 [346224]
              if WhseReceiptLine."Variant Code" <> '' then
                Line.InnerText := StrSubstNo(Text015,WhseReceiptLine."Qty. to Receive",WhseReceiptLine."Qty. Outstanding",WhseReceiptLine."Item No." + '-' + WhseReceiptLine."Variant Code",WhseReceiptLine.Description)
              else
              //+NPR5.49 [346224]
              Line.InnerText := StrSubstNo(Text015,WhseReceiptLine."Qty. to Receive",WhseReceiptLine."Qty. Outstanding",WhseReceiptLine."Item No.",WhseReceiptLine.Description);
              Record.AppendChild(Line);

              Line := DOMxmlin.CreateElement('Line');
              AddAttribute(Line,'Descrip',WhseReceiptLine.FieldCaption(Description));
              AddAttribute(Line,'Type',Format(LineType::TEXT));
              Line.InnerText := WhseReceiptLine.Description;
              Record.AppendChild(Line);

              Line := DOMxmlin.CreateElement('Line');
              AddAttribute(Line,'Descrip',WhseReceiptLine.FieldCaption("Source Document"));
              AddAttribute(Line,'Type',Format(LineType::TEXT));
              Line.InnerText := Format(WhseReceiptLine."Source Document");
              Record.AppendChild(Line);

              Line := DOMxmlin.CreateElement('Line');
              AddAttribute(Line,'Descrip',WhseReceiptLine.FieldCaption("Source No."));
              AddAttribute(Line,'Type',Format(LineType::TEXT));
              Line.InnerText := WhseReceiptLine."Source No.";
              Record.AppendChild(Line);

              Line := DOMxmlin.CreateElement('Line');
              AddAttribute(Line,'Descrip',WhseReceiptLine.FieldCaption("Unit of Measure Code"));
              AddAttribute(Line,'Type',Format(LineType::TEXT));
              Line.InnerText := WhseReceiptLine."Unit of Measure Code";
              Record.AppendChild(Line);

              Line := DOMxmlin.CreateElement('Line');
              AddAttribute(Line,'Descrip',WhseReceiptLine.FieldCaption("Qty. per Unit of Measure"));
              AddAttribute(Line,'Type',Format(LineType::TEXT));
              Line.InnerText := Format(WhseReceiptLine."Qty. per Unit of Measure");
              Record.AppendChild(Line);

              Records.AppendChild(Record);
            end;
          until WhseReceiptLine.Next = 0;

          //-NPR5.50 [247747]
          if not MiniformHeader."Hid Fulfilled Lines" then begin
          //+NPR5.50 [247747]
            if WhseReceiptLine.FindSet then begin
              repeat
                Record := DOMxmlin.CreateElement('Record');

                CurrRecordID := WhseReceiptLine.RecordId;
                TableNo := CurrRecordID.TableNo;

                if (WhseReceiptLine."Qty. to Receive" < WhseReceiptLine."Qty. Outstanding") then
                  Indicator := 'minus'
                else if (WhseReceiptLine."Qty. to Receive" = WhseReceiptLine."Qty. Outstanding") then
                  Indicator := 'ok'
                else
                  Indicator := 'plus';

                if Indicator <> 'minus' then begin
                  Line := DOMxmlin.CreateElement('Line');
                  AddAttribute(Line,'Descrip',WhseReceiptLine.FieldCaption(Description));
                  AddAttribute(Line,'Indicator',Indicator);
                  AddAttribute(Line,'Type',Format(LineType::TEXT));
                  //-NPR5.49 [346224]
                  if WhseReceiptLine."Variant Code" <> '' then
                    Line.InnerText := StrSubstNo(Text015,WhseReceiptLine."Qty. to Receive",WhseReceiptLine."Qty. Outstanding",WhseReceiptLine."Item No." + '-' + WhseReceiptLine."Variant Code",WhseReceiptLine.Description)
                  else
                  //+NPR5.49 [346224]
                  Line.InnerText := StrSubstNo(Text015,WhseReceiptLine."Qty. to Receive",WhseReceiptLine."Qty. Outstanding",WhseReceiptLine."Item No.",WhseReceiptLine.Description);
                  Record.AppendChild(Line);

                  Line := DOMxmlin.CreateElement('Line');
                  AddAttribute(Line,'Descrip',WhseReceiptLine.FieldCaption(Description));
                  AddAttribute(Line,'Type',Format(LineType::TEXT));
                  Line.InnerText := WhseReceiptLine.Description;
                  Record.AppendChild(Line);

                  Line := DOMxmlin.CreateElement('Line');
                  AddAttribute(Line,'Descrip',WhseReceiptLine.FieldCaption("Source Document"));
                  AddAttribute(Line,'Type',Format(LineType::TEXT));
                  Line.InnerText := Format(WhseReceiptLine."Source Document");
                  Record.AppendChild(Line);

                  Line := DOMxmlin.CreateElement('Line');
                  AddAttribute(Line,'Descrip',WhseReceiptLine.FieldCaption("Source No."));
                  AddAttribute(Line,'Type',Format(LineType::TEXT));
                  Line.InnerText := WhseReceiptLine."Source No.";
                  Record.AppendChild(Line);

                  Line := DOMxmlin.CreateElement('Line');
                  AddAttribute(Line,'Descrip',WhseReceiptLine.FieldCaption("Unit of Measure Code"));
                  AddAttribute(Line,'Type',Format(LineType::TEXT));
                  Line.InnerText := WhseReceiptLine."Unit of Measure Code";
                  Record.AppendChild(Line);

                  Line := DOMxmlin.CreateElement('Line');
                  AddAttribute(Line,'Descrip',WhseReceiptLine.FieldCaption("Qty. per Unit of Measure"));
                  AddAttribute(Line,'Type',Format(LineType::TEXT));
                  Line.InnerText := Format(WhseReceiptLine."Qty. per Unit of Measure");
                  Record.AppendChild(Line);

                  Records.AppendChild(Record);
                end;
              until WhseReceiptLine.Next = 0;
             end;
            //-NPR5.50 [247747]
            end;
            //+NPR5.50 [247747]
          exit(true);
        end else
          exit(false);
    end;

    local procedure Reset(CSWarehouseReceiptHandling: Record "CS Warehouse Receipt Handling")
    var
        WhseReceiptLine: Record "Warehouse Receipt Line";
    begin
        Remark := '';
        WhseReceiptLine.SetRange("No.",CSWarehouseReceiptHandling."No.");
        if WhseReceiptLine.FindSet then begin
          repeat
              WhseReceiptLine.Validate("Qty. to Receive",0);
              WhseReceiptLine.Modify;
          until WhseReceiptLine.Next = 0;
        end else
          Error(Text007);

        CSCommunication.SetRecRef(RecRef);
        ActiveInputField := 1;
    end;

    local procedure Register(CSWarehouseReceiptHandling: Record "CS Warehouse Receipt Handling")
    var
        WhsePostReceipt: Codeunit "Whse.-Post Receipt";
        WhseReceiptLine: Record "Warehouse Receipt Line";
    begin
        Remark := '';
        WhseReceiptLine.SetRange("No.",CSWarehouseReceiptHandling."No.");

        //-NPR5.50 [335606]
        // IF WhseReceiptLine.FINDSET THEN BEGIN
        //  REPEAT
        //    WhsePostReceipt.RUN(WhseReceiptLine);
        //    WhsePostReceipt.GetResultMessage;
        //    CLEAR(WhsePostReceipt);
        //  UNTIL WhseReceiptLine.NEXT = 0;
        if WhseReceiptLine.FindFirst then begin
          WhsePostReceipt.Run(WhseReceiptLine);
          WhsePostReceipt.GetResultMessage;
          Clear(WhsePostReceipt);

          WhseReceiptLine.DeleteQtyToReceive(WhseReceiptLine);

        //+NPR5.50 [335606]
        end else
          Error(Text007);
    end;

    local procedure TransferDataLine(CSWarehouseReceiptHandling: Record "CS Warehouse Receipt Handling"): Boolean
    var
        WhseReceiptLine: Record "Warehouse Receipt Line";
    begin
        WhseReceiptLine.SetCurrentKey("Source Type","Source Subtype","Source No.","Source Line No.");
        WhseReceiptLine.SetRange("No.",CSWarehouseReceiptHandling."No.");
        WhseReceiptLine.SetRange("Item No.",CSWarehouseReceiptHandling."Item No.");
        if WhseReceiptLine.FindSet then begin
          if WhseReceiptLine."Qty. to Receive" = WhseReceiptLine."Qty. Outstanding" then begin
            Remark := StrSubstNo(Text016);
            exit(false);
          end;
          WhseReceiptLine.Validate("Qty. to Receive",WhseReceiptLine."Qty. to Receive" + CSWarehouseReceiptHandling.Qty);
          //-NPR5.48 [335606]
          if CSWarehouseReceiptHandling."Unit of Measure" <> '' then
            WhseReceiptLine.Validate("Unit of Measure Code",CSWarehouseReceiptHandling."Unit of Measure");
          //+NPR5.48 [335606]
          WhseReceiptLine.Modify(true);
        end else begin
          Remark := StrSubstNo(Text021,CSWarehouseReceiptHandling."Item No.",CSWarehouseReceiptHandling."No.");
          exit(false);
        end;

        exit(true);
    end;

    trigger DOMxmlin::NodeInserting(sender: Variant;e: DotNet npNetXmlNodeChangedEventArgs)
    begin
    end;

    trigger DOMxmlin::NodeInserted(sender: Variant;e: DotNet npNetXmlNodeChangedEventArgs)
    begin
    end;

    trigger DOMxmlin::NodeRemoving(sender: Variant;e: DotNet npNetXmlNodeChangedEventArgs)
    begin
    end;

    trigger DOMxmlin::NodeRemoved(sender: Variant;e: DotNet npNetXmlNodeChangedEventArgs)
    begin
    end;

    trigger DOMxmlin::NodeChanging(sender: Variant;e: DotNet npNetXmlNodeChangedEventArgs)
    begin
    end;

    trigger DOMxmlin::NodeChanged(sender: Variant;e: DotNet npNetXmlNodeChangedEventArgs)
    begin
    end;
}

