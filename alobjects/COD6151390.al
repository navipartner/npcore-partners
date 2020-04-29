codeunit 6151390 "CS UI Transfer Order Handling"
{
    // NPR5.43/CLVA/20180313 CASE 315503 Object created - NP Capture Service
    // NPR5.43/NPKNAV/20180629  CASE 304872 Transport NPR5.43 - 29 June 2018
    // NPR5.44/CLVA/20180719 CASE 315503 Added filter on Transfer Line
    // NPR5.48/CLVA/20181109 CASE 335606 Handling UOM

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
        Text001: Label 'There is nothing to post.';
        Text002: Label 'Failed to add the attribute: %1.';
        Text005: Label 'Barcode is blank';
        Text006: Label 'No input Node found.';
        Text007: Label 'Record not found.';
        Text008: Label 'Input value Length Error';
        Text010: Label 'Barcode %1 doesn''t exist';
        Text011: Label 'Qty. is blank';
        Text013: Label 'Input value is not valid';
        Text014: Label 'Item %1 doesn''t exist';
        Text015: Label '%1 : %2 %3';
        Text016: Label 'Quantity exceed Qty. Shipped';
        Text017: Label 'Unable to Post Shipment';
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
        CSTransferOrderHandling: Record "CS Transfer Order Handling";
        CSTransferOrderHandling2: Record "CS Transfer Order Handling";
        CSFieldDefaults: Record "CS Field Defaults";
        TransferLine: Record "Transfer Line";
    begin
        if XMLDOMMgt.FindNode(RootNode,'Header/Input',ReturnedNode) then
          TextValue := ReturnedNode.InnerText
        else
          Error(Text006);

        Evaluate(TableNo,CSCommunication.GetNodeAttribute(ReturnedNode,'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId,CSCommunication.GetNodeAttribute(ReturnedNode,'RecordID'));
        if RecRef.Get(RecId) then begin
          RecRef.SetTable(CSTransferOrderHandling);
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
                'DELETELINE':
                  begin
                    Evaluate(FuncTableNo,CSCommunication.GetNodeAttribute(ReturnedNode,'FuncTableNo'));
                    FuncRecRef.Open(FuncTableNo);
                    Evaluate(FuncRecId,CSCommunication.GetNodeAttribute(ReturnedNode,'FuncRecordID'));
                    if FuncRecRef.Get(FuncRecId) then begin
                      FuncRecRef.SetTable(TransferLine);
                      TransferLine.Delete(true);
                    end;
                  end;
                end;
              end;
          FuncGroup.KeyDef::Reset:
            Reset(CSTransferOrderHandling);
          FuncGroup.KeyDef::Register:
            begin
              Register(CSTransferOrderHandling);
              if Remark = '' then begin
                DeleteEmptyDataLines();
                CSCommunication.RunPreviousUI(DOMxmlin)
              end else
                SendForm(ActiveInputField);
            end;
          FuncGroup.KeyDef::Input:
            begin
              Evaluate(FldNo,CSCommunication.GetNodeAttribute(ReturnedNode,'FieldID'));
              case FldNo of
                CSTransferOrderHandling.FieldNo(Barcode):
                  CheckBarcode(CSTransferOrderHandling,TextValue);
                CSTransferOrderHandling.FieldNo(Qty):
                  CheckQty(CSTransferOrderHandling,TextValue);
                else begin
                  CSCommunication.FieldSetvalue(RecRef,FldNo,TextValue);
                end;
              end;

              CSTransferOrderHandling.Modify;

              RecRef.GetTable(CSTransferOrderHandling);
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
                      RecRef.SetTable(CSTransferOrderHandling);
                      RecRef.SetRecFilter;
                      CSCommunication.SetRecRef(RecRef);
                    until CSFieldDefaults.Next = 0;
                  end;

                  UpdateDataLine(CSTransferOrderHandling);
                  CreateDataLine(CSTransferOrderHandling2,CSTransferOrderHandling);
                  RecRef.GetTable(CSTransferOrderHandling2);
                  CSCommunication.SetRecRef(RecRef);
                  ActiveInputField := 1;
                end else
                  ActiveInputField += 1;
            end;
          else
            Error(Text000);
        end;

        if not (FuncGroup.KeyDef in [FuncGroup.KeyDef::Esc,FuncGroup.KeyDef::Register]) then
          SendForm(ActiveInputField);
    end;

    local procedure PrepareData()
    var
        TransferHeader: Record "Transfer Header";
        CSTransferOrderHandling: Record "CS Transfer Order Handling";
        RecId: RecordID;
        TableNo: Integer;
    begin
        XMLDOMMgt.FindNode(RootNode,'Header/Input',ReturnedNode);

        Evaluate(TableNo,CSCommunication.GetNodeAttribute(ReturnedNode,'TableNo'));
        Evaluate(RecId,CSCommunication.GetNodeAttribute(ReturnedNode,'RecordID'));

        RecRef.Open(TableNo);
        RecRef.Get(RecId);
        RecRef.SetTable(TransferHeader);

        DeleteEmptyDataLines();
        CreateDataLine(CSTransferOrderHandling,TransferHeader);

        RecRef.Close;

        RecId := CSTransferOrderHandling.RecordId;

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

    local procedure CheckBarcode(var CSTransferOrderHandling: Record "CS Transfer Order Handling";InputValue: Text)
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

        if StrLen(InputValue) > MaxStrLen(CSTransferOrderHandling.Barcode) then begin
          Remark := Text008;
          exit;
        end;

        if BarcodeLibrary.TranslateBarcodeToItemVariant(InputValue, ItemNo, VariantCode, ResolvingTable, true) then begin
          if not Item.Get(ItemNo) then begin
            Remark := StrSubstNo(Text014,InputValue);
            exit;
          end;


          CSTransferOrderHandling."Item No." := ItemNo;
          CSTransferOrderHandling."Variant Code" := VariantCode;

          //-NPR5.48 [335606]
          if (ResolvingTable = DATABASE::"Item Cross Reference") then begin
            with ItemCrossReference do begin
              if (StrLen(InputValue) <= MaxStrLen("Cross-Reference No.")) then begin
                SetCurrentKey("Cross-Reference Type", "Cross-Reference No.");
                SetFilter("Cross-Reference Type", '=%1', "Cross-Reference Type"::"Bar Code");
                SetFilter("Cross-Reference No.", '=%1', UpperCase (InputValue));
                if FindFirst() then
                  CSTransferOrderHandling."Unit of Measure" := ItemCrossReference."Unit of Measure";
              end;
            end;
          end;
          //+NPR5.48 [335606]

        end else begin
          Remark := StrSubstNo(Text010,InputValue);
          exit;
        end;

        CSTransferOrderHandling.Barcode := InputValue;
    end;

    local procedure CheckQty(var CSTransferOrderHandling: Record "CS Transfer Order Handling";InputValue: Text)
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

        CSTransferOrderHandling.Qty := Qty;
    end;

    local procedure CreateDataLine(var CSTransferOrderHandling: Record "CS Transfer Order Handling";RecordVariant: Variant)
    var
        NewCSTransferOrderHandling: Record "CS Transfer Order Handling";
        LineNo: Integer;
        RecRefByVariant: RecordRef;
        CSTransferOrderHandlingByVar: Record "CS Transfer Order Handling";
        TransferHeaderByVar: Record "Transfer Header";
    begin
        if not RecordVariant.IsRecord then
          Error(Text020);

        Clear(NewCSTransferOrderHandling);
        NewCSTransferOrderHandling.SetRange(Id, CSSessionId);
        if NewCSTransferOrderHandling.FindLast then
          LineNo := NewCSTransferOrderHandling."Line No." + 1
        else
          LineNo := 1;

        CSTransferOrderHandling.Init;
        CSTransferOrderHandling.Id := CSSessionId;
        CSTransferOrderHandling."Line No." := LineNo;
        CSTransferOrderHandling."Created By" := UserId;
        CSTransferOrderHandling.Created := CurrentDateTime;

        RecRefByVariant.GetTable(RecordVariant);

        CSTransferOrderHandling."Table No." := RecRefByVariant.Number;

        if RecRefByVariant.Number = 5740 then begin
          TransferHeaderByVar := RecordVariant;
          CSTransferOrderHandling."No." := TransferHeaderByVar."No.";
          CSTransferOrderHandling."Record Id" := TransferHeaderByVar.RecordId;
        end else begin
          CSTransferOrderHandlingByVar := RecordVariant;
          CSTransferOrderHandling."No." := CSTransferOrderHandlingByVar."No.";
          CSTransferOrderHandling."Record Id" := CSTransferOrderHandlingByVar.RecordId;
        end;

        CSTransferOrderHandling.Insert(true);
    end;

    local procedure UpdateDataLine(var CSTransferOrderHandling: Record "CS Transfer Order Handling")
    begin
        if TransferDataLine(CSTransferOrderHandling) then begin
          CSTransferOrderHandling."Transferred to Document" := true;
          CSTransferOrderHandling.Modify(true);
        end;

        CSTransferOrderHandling.Handled := true;
        CSTransferOrderHandling.Modify(true);
    end;

    local procedure DeleteEmptyDataLines()
    var
        CSTransferOrderHandling: Record "CS Transfer Order Handling";
    begin
        CSTransferOrderHandling.SetRange(Id,CSSessionId);
        CSTransferOrderHandling.SetRange(Handled,false);
        CSTransferOrderHandling.SetRange("Transferred to Document",false);
        CSTransferOrderHandling.DeleteAll(true);
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
        CSTransferOrderHandling: Record "CS Transfer Order Handling";
        TransferLine: Record "Transfer Line";
        LineType: Option TEXT,BUTTON;
        CurrRecordID: RecordID;
        TableNo: Integer;
        ItemVariant: Record "Item Variant";
    begin
        Clear(CSTransferOrderHandling);
        CSTransferOrderHandling.SetRange(Id,CSSessionId);
        if not CSTransferOrderHandling.FindLast then
          exit(false);

        Clear(TransferLine);
        TransferLine.SetAscending("Line No.",false);
        TransferLine.SetRange("Document No.",CSTransferOrderHandling."No.");
        //-NPR5.44 [315503]
        TransferLine.SetRange("Derived From Line No.",0);
        //+NPR5.44 [315503]
        if TransferLine.FindSet then begin
          Records := DOMxmlin.CreateElement('Records');
          repeat
            Record := DOMxmlin.CreateElement('Record');

            CurrRecordID := TransferLine.RecordId;
            TableNo := CurrRecordID.TableNo;

            Indicator := 'ok';

            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line,'Descrip',TransferLine.FieldCaption(Description));
            AddAttribute(Line,'Indicator',Indicator);
            AddAttribute(Line,'Type',Format(LineType::TEXT));
            Line.InnerText := StrSubstNo(Text015,TransferLine.Quantity,TransferLine."Item No.",TransferLine.Description);
            Record.AppendChild(Line);

            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line,'Descrip','Delete..');
            AddAttribute(Line,'Type',Format(LineType::BUTTON));
            AddAttribute(Line,'TableNo',Format(TableNo));
            AddAttribute(Line,'RecordID',Format(CurrRecordID));
            AddAttribute(Line,'FuncName','DELETELINE');
            Record.AppendChild(Line);

            if (TransferLine."Variant Code" <> '') then begin
              Line := DOMxmlin.CreateElement('Line');
              AddAttribute(Line,'Descrip',TransferLine.FieldCaption("Variant Code"));
              AddAttribute(Line,'Type',Format(LineType::TEXT));
              Line.InnerText := TransferLine."Variant Code";
              Record.AppendChild(Line);

              if ItemVariant.Get(TransferLine."Item No.",TransferLine."Variant Code") then begin
                Line := DOMxmlin.CreateElement('Line');
                AddAttribute(Line,'Descrip',ItemVariant.FieldCaption(Description));
                AddAttribute(Line,'Type',Format(LineType::TEXT));
                Line.InnerText := ItemVariant.Description;
                Record.AppendChild(Line);
              end;
            end;

            Records.AppendChild(Record);

          until TransferLine.Next = 0;
          exit(true);
        end else
          exit(false);
    end;

    local procedure Reset(var CSTransferOrderHandling: Record "CS Transfer Order Handling")
    var
        TransferLine: Record "Transfer Line";
    begin
        Remark := '';
        TransferLine.SetRange("Document No.",CSTransferOrderHandling."No.");
        TransferLine.DeleteAll(true);

        CSCommunication.SetRecRef(RecRef);
        ActiveInputField := 1;
    end;

    local procedure Register(CSTransferOrderHandling: Record "CS Transfer Order Handling")
    var
        TransferHeader: Record "Transfer Header";
        TransferPostShipment: Codeunit "TransferOrder-Post Shipment";
        TransferLine: Record "Transfer Line";
    begin
        Remark := '';
        if TransferHeader.Get(CSTransferOrderHandling."No.") then begin
          TransferLine.Reset;
          TransferLine.SetRange("Document No.",TransferHeader."No.");
          TransferLine.SetRange("Derived From Line No.",0);
          TransferLine.SetFilter(Quantity,'<>0');
          TransferLine.SetFilter("Qty. to Ship",'<>0');
          if TransferLine.IsEmpty then
            Remark := Text001
          else
            TransferPostShipment.Run(TransferHeader);
        end else
          Remark := Text007;
    end;

    local procedure TransferDataLine(CSTransferOrderHandling: Record "CS Transfer Order Handling"): Boolean
    var
        TransferLine: Record "Transfer Line";
        NewTransferLine: Record "Transfer Line";
        LineNo: Integer;
    begin
        Clear(NewTransferLine);
        NewTransferLine.SetRange("Document No.", CSTransferOrderHandling."No.");
        if NewTransferLine.FindLast then
          LineNo := NewTransferLine."Line No." + 10000
        else
          LineNo := 10000;

        TransferLine.Init;
        TransferLine."Document No." := CSTransferOrderHandling."No.";
        TransferLine."Line No." := LineNo;
        TransferLine.Insert(true);

        TransferLine.Validate("Item No.",CSTransferOrderHandling."Item No.");
        if (CSTransferOrderHandling."Variant Code" <> '') then
          TransferLine.Validate("Variant Code",CSTransferOrderHandling."Variant Code");
        TransferLine.Validate(Quantity,CSTransferOrderHandling.Qty);
        //-NPR5.48 [335606]
        if CSTransferOrderHandling."Unit of Measure" <> '' then
          TransferLine.Validate("Unit of Measure Code",CSTransferOrderHandling."Unit of Measure");
        //+NPR5.48 [335606]
        TransferLine.Modify(true);

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

