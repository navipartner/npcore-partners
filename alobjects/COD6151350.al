codeunit 6151350 "CS UI Stock Adjustment Unplan"
{
    // NPR5.53/SARA/20191030 CASE 375030 New object, ajustment for Location as Directed PutAway and Pick

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
        Text020: Label 'Location Should be DirectedPutAway/Pick';
        Text028: Label '%1 Item Journal';
        InventoryAdjCaption: Label 'Inventory adjusted to %1';
        AdjustInventoryCaption: Label 'Adjust inventory';
        LocationCodeErr: Label 'Location code is blank';
        BinCodeErr: Label 'Bin Code %1 is not valid or location has not been set';
        LocationErr: Label 'Location %1 can not be found';
        LocationMultipleNameErr: Label 'There are multiple locations with the name %1, please choose a location by code';
        EmployeeUnauthorizedErr: Label 'Employee is not authorized for this location: %1';
        SimpleInvJnlNameTxt: Label 'DEFAULT', Comment='The default name of the item journal';
        QuantityCoincideErr: Label 'Quantity in bin coincides with input quantity, nothing to adjust';
        AtributeErr: Label 'Failed to add the attribute: %1.';
        AdjustingFailedErr: Label 'Adjustment could not be done because posting failed. Error: %1';
        MissingBarcodeErr: Label 'Barcode must be scanned before adjustment can be done';

    local procedure ProcessInput()
    var
        FuncGroup: Record "CS UI Function Group";
        CSWarehouseActivityHandling: Record "CS Warehouse Activity Handling";
        RecId: RecordID;
        TextValue: Text[250];
        FuncValue: Text;
        FuncName: Code[10];
        TableNo: Integer;
        FldNo: Integer;
        FuncFieldId: Integer;
        Step: Integer;
    begin
        if XMLDOMMgt.FindNode(RootNode,'Header/Input',ReturnedNode) then
          TextValue := ReturnedNode.InnerText
        else
          Error(Text006);

        Evaluate(TableNo,CSCommunication.GetNodeAttribute(ReturnedNode,'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId,CSCommunication.GetNodeAttribute(ReturnedNode,'RecordID'));
        if RecRef.Get(RecId) then begin
          RecRef.SetTable(CSWarehouseActivityHandling);
          RecRef.SetRecFilter;
          CSCommunication.SetRecRef(RecRef);
        end else begin
          CSCommunication.RunPreviousUI(DOMxmlin);
          exit;
        end;

        FuncGroup.KeyDef := CSCommunication.GetFunctionKey(MiniformHeader.Code,TextValue);
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
              FuncName := CSCommunication.GetNodeAttribute(ReturnedNode,'FuncName');

              if FuncName = 'DEFAULT' then begin
                FuncValue := CSCommunication.GetNodeAttribute(ReturnedNode,'FuncValue');
                Evaluate(FuncFieldId,CSCommunication.GetNodeAttribute(ReturnedNode,'FieldID'));

                case FuncFieldId of
                  CSWarehouseActivityHandling.FieldNo("Location Code"):
                    CheckLocation(CSWarehouseActivityHandling,FuncValue);
                  CSWarehouseActivityHandling.FieldNo("Bin Code"):
                    CheckBin(CSWarehouseActivityHandling,FuncValue);
                end;

                AddDefault(FuncFieldId,FuncValue);

                Input(CSWarehouseActivityHandling,FuncFieldId,0);
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
              Evaluate(FldNo,CSCommunication.GetNodeAttribute(ReturnedNode,'FieldID'));
              case FldNo of
                CSWarehouseActivityHandling.FieldNo(Barcode):
                  begin
                    CheckBarcode(CSWarehouseActivityHandling,TextValue);
                    Step := 1;
                  end;
                CSWarehouseActivityHandling.FieldNo(Qty):
                  begin
                    ChangeQty(CSWarehouseActivityHandling,TextValue);
                    Step := 1;
                  end;
                CSWarehouseActivityHandling.FieldNo("Bin Code"):
                  begin
                    CheckBin(CSWarehouseActivityHandling,TextValue);

                    AddDefault(FldNo,TextValue);
                  end;
                else
                  CSCommunication.FieldSetvalue(RecRef,FldNo,TextValue);
              end;

              Input(CSWarehouseActivityHandling,FldNo,Step);
            end;
          else
            Error(Text000);
        end;

        if not (FuncGroup.KeyDef = FuncGroup.KeyDef::Esc) then
          SendForm(ActiveInputField);
    end;

    local procedure PrepareData()
    var
        CSWarehouseActivityHandling: Record "CS Warehouse Activity Handling";
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
        CSCommunication.EncodeUI(MiniformHeader,StackCode,DOMxmlin,InputField,Remark,CSUserId);
        CSCommunication.GetReturnXML(DOMxmlin);

        AddAdditionalInfo(DOMxmlin);

        CSMgt.SendXMLReply(DOMxmlin);
    end;

    local procedure CheckLocation(var CSWarehouseActivityHandling: Record "CS Warehouse Activity Handling";InputValue: Text): Code[10]
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
          Location.SetRange(Name,InputValue);
          case Location.Count of
            1:
              Location.FindFirst;
            0:
              begin
                Remark := StrSubstNo(LocationErr,InputValue);
                exit;
              end;
            else
              begin
                Remark := StrSubstNo(LocationMultipleNameErr,InputValue);
                exit;
              end;
          end;
        end;

        if not WarehouseEmployee.Get(CSWarehouseActivityHandling."Created By",InputValue) then begin
          Remark := StrSubstNo(EmployeeUnauthorizedErr,InputValue);
          exit;
        end;

        if not Location."Directed Put-away and Pick" then
          Remark := Text020;

        CSWarehouseActivityHandling."Location Code" := InputValue;
    end;

    local procedure CheckBarcode(var CSWarehouseActivityHandling: Record "CS Warehouse Activity Handling";InputValue: Text)
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

        if StrLen(InputValue) > MaxStrLen(CSWarehouseActivityHandling.Barcode) then begin
          Remark := Text008;
          exit;
        end;

        if BarcodeLibrary.TranslateBarcodeToItemVariant(InputValue, ItemNo, VariantCode, ResolvingTable, true) then begin
          if not Item.Get(ItemNo) then begin
            Remark := StrSubstNo(Text014,InputValue);
            exit;
          end;

          CSWarehouseActivityHandling."Item No." := ItemNo;
          CSWarehouseActivityHandling."Variant Code" := VariantCode;

          if (ResolvingTable = DATABASE::"Item Cross Reference") then begin
            with ItemCrossReference do begin
              if (StrLen(InputValue) <= MaxStrLen("Cross-Reference No.")) then begin
                SetCurrentKey("Cross-Reference Type", "Cross-Reference No.");
                SetFilter("Cross-Reference Type", '=%1', "Cross-Reference Type"::"Bar Code");
                SetFilter("Cross-Reference No.", '=%1', UpperCase (InputValue));
                if FindFirst() then
                  CSWarehouseActivityHandling."Unit of Measure" := ItemCrossReference."Unit of Measure";
              end;
            end;
          end;
        end else begin
          Remark := StrSubstNo(Text010,InputValue);
          exit;
        end;

        CSWarehouseActivityHandling.CalcFields("Bin Base Qty.");
        CSWarehouseActivityHandling.Barcode := InputValue;
    end;

    local procedure ChangeQty(var CSWarehouseActivityHandling: Record "CS Warehouse Activity Handling";InputValue: Text)
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

        CSWarehouseActivityHandling.Qty := Qty;
    end;

    local procedure CheckBin(var CSWarehouseActivityHandling: Record "CS Warehouse Activity Handling";InputValue: Text)
    var
        Bin: Record Bin;
    begin
        if InputValue = '' then begin
          Remark := Text019;
          exit;
        end;

        if StrLen(InputValue) > MaxStrLen(Bin.Code) then begin
          Remark := Text008;
          exit;
        end;

        if not Bin.Get(CSWarehouseActivityHandling."Location Code",InputValue) then begin
          Remark := StrSubstNo(BinCodeErr,InputValue);
          exit;
        end;

        CSWarehouseActivityHandling."Bin Code" := InputValue;
    end;

    local procedure CreateDataLine(var CSWarehouseActivityHandling: Record "CS Warehouse Activity Handling")
    var
        NewCSWarehouseActivityHandling: Record "CS Warehouse Activity Handling";
        LineNo: Integer;
    begin
        Clear(NewCSWarehouseActivityHandling);
        NewCSWarehouseActivityHandling.SetRange(Id,CSSessionId);
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
        CSWarehouseActivityHandling: Record "CS Warehouse Activity Handling";
    begin
        CSWarehouseActivityHandling.SetRange(Id,CSSessionId);
        CSWarehouseActivityHandling.SetRange(Handled,false);
        CSWarehouseActivityHandling.SetRange("Transferred to Document",false);
        CSWarehouseActivityHandling.DeleteAll(true);
    end;

    local procedure Adjust(CSWarehouseActivityHandling: Record "CS Warehouse Activity Handling")
    var
        WarehouseJnlTemplate: Record "Warehouse Journal Template";
        NewItemJournalLine: Record "Item Journal Line";
        WarehouseJournalLine: Record "Warehouse Journal Line";
        OffsetQty: Decimal;
        PostingFinished: Boolean;
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
        LineNo: Integer;
    begin
        Clear(Remark);

        if CSWarehouseActivityHandling.Barcode = '' then begin
          Remark := MissingBarcodeErr;
          exit;
        end;

        CSWarehouseActivityHandling.CalcFields("Bin Base Qty.");

        OffsetQty := CSWarehouseActivityHandling.Qty - CSWarehouseActivityHandling."Bin Base Qty.";
        if OffsetQty = 0 then begin
          Remark := QuantityCoincideErr;
          exit;
        end;


        WarehouseJnlTemplate.SetRange(Type,WarehouseJnlTemplate.Type::Item);
        WarehouseJnlTemplate.FindFirst;

        WarehouseJournalLine.Init;
        WarehouseJournalLine.Validate("Journal Template Name",WarehouseJnlTemplate.Name);
        WarehouseJournalLine.Validate("Journal Batch Name",CreateWhseBatch(WarehouseJnlTemplate.Name,CSWarehouseActivityHandling."Location Code"));
        WarehouseJournalLine.Validate("Location Code",CSWarehouseActivityHandling."Location Code");
        WarehouseJournalLine."Line No." := 1000;
        WarehouseJournalLine.Insert(true);

        WarehouseJournalLine.Validate("Registering Date",Today);
        WarehouseJournalLine."Whse. Document No." := Format(Today);
        WarehouseJournalLine.Validate("Item No.",CSWarehouseActivityHandling."Item No.");
        WarehouseJournalLine.Validate(Description,CSWarehouseActivityHandling."Item Description");
        WarehouseJournalLine.Validate("Variant Code",CSWarehouseActivityHandling."Variant Code");
        WarehouseJournalLine.Validate(Quantity,OffsetQty);
        WarehouseJournalLine.Validate("Bin Code",CSWarehouseActivityHandling."Bin Code");
        WarehouseJournalLine.SetUpNewLine(WarehouseJournalLine);
        WarehouseJournalLine.Modify(true);

        Commit;

        PostingFinished := CODEUNIT.Run(CODEUNIT::"Whse. Jnl.-Register Batch",WarehouseJournalLine);


        if PostingFinished then
          DeleteWhseBatch(WarehouseJournalLine."Journal Template Name",WarehouseJournalLine."Journal Batch Name",WarehouseJournalLine."Location Code");

        if not PostingFinished then begin
          Remark := CopyStr(GetLastErrorText,1,MaxStrLen(Remark));
          exit;
        end;

        Clear(CSWarehouseActivityHandling.Qty);
        Clear(CSWarehouseActivityHandling.Barcode);
        CSWarehouseActivityHandling.Modify;
    end;

    local procedure Input(CSWarehouseActivityHandling: Record "CS Warehouse Activity Handling";FldNo: Integer;Step: Integer)
    var
        CSFieldDefaults: Record "CS Field Defaults";
        CSWarehouseActivityHandling2: Record "CS Warehouse Activity Handling";
    begin
        CSWarehouseActivityHandling.Modify;

        RecRef.GetTable(CSWarehouseActivityHandling);
        CSCommunication.SetRecRef(RecRef);
        ActiveInputField := CSCommunication.GetActiveInputNo(CurrentCode,FldNo);
        if Remark = '' then
          if CSCommunication.LastEntryField(CurrentCode,FldNo) then begin
            CSFieldDefaults.SetRange(Id,CSUserId);
            CSFieldDefaults.SetRange("Use Case Code",CurrentCode);
            if CSFieldDefaults.FindSet then begin
              repeat
                CSCommunication.FieldSetvalue(RecRef,CSFieldDefaults."Field No",CSFieldDefaults.Value);
                RecRef.SetTable(CSWarehouseActivityHandling);
                RecRef.SetRecFilter;
                CSCommunication.SetRecRef(RecRef);
              until CSFieldDefaults.Next = 0;
            end;

            ActiveInputField := 1;
          end else
            ActiveInputField += Step;
    end;

    local procedure CreateWhseBatch(TemplateName: Code[10];LocationCode: Code[20]): Code[10]
    var
        WhseJournalBatch: Record "Warehouse Journal Batch";
    begin
        WhseJournalBatch.Init;
        WhseJournalBatch."Journal Template Name" := TemplateName;
        WhseJournalBatch.Name := CreateBatchName;
        WhseJournalBatch."Location Code" := LocationCode;
        WhseJournalBatch.Description := SimpleInvJnlNameTxt;
        WhseJournalBatch.Insert;

        exit(WhseJournalBatch.Name);
    end;

    local procedure DeleteWhseBatch(TemplateName: Code[10];BatchName: Code[10];LocationCode: Code[10])
    var
        WhseJournalBatch: Record "Warehouse Journal Batch";
    begin
        if WhseJournalBatch.Get(TemplateName,BatchName,LocationCode) then
          WhseJournalBatch.Delete(true);
    end;

    local procedure CreateBatchName(): Code[10]
    var
        GuidStr: Text;
        BatchName: Text;
    begin
        GuidStr := Format(CreateGuid);

        // Remove numbers to avoid batch name change by INCSTR in codeunit 23
        BatchName := ConvertStr(GuidStr,'1234567890-','GHIJKLMNOPQ');
        exit(CopyStr(BatchName,2,10));
    end;

    local procedure AddAdditionalInfo(var xmlout: DotNet npNetXmlDocument)
    var
        CurrentRootNode: DotNet npNetXmlNode;
        XMLFunctionNode: DotNet npNetXmlNode;
        StrMenuTxt: Text;
    begin
        CurrentRootNode := xmlout.DocumentElement;
        XMLDOMMgt.FindNode(CurrentRootNode,'Header/Functions',ReturnedNode);

        foreach XMLFunctionNode in ReturnedNode.ChildNodes do begin
          if (XMLFunctionNode.InnerText = 'REGISTER') then
            AddAttribute(XMLFunctionNode,'Actions',AdjustInventoryCaption);
        end;
    end;

    local procedure AddAttribute(var NewChild: DotNet npNetXmlNode;AttribName: Text[250];AttribValue: Text[250])
    begin
        if XMLDOMMgt.AddAttribute(NewChild,AttribName,AttribValue) > 0 then
          Error(AtributeErr,AttribName);
    end;

    local procedure AddDefault(FieldId: Integer;FuncValue: Text)
    var
        CSFieldDefaults: Record "CS Field Defaults";
    begin
        if CSFieldDefaults.Get(CSUserId,CurrentCode,FieldId) then begin
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

    local procedure GetDefault(var CSWarehouseActivityHandling: Record "CS Warehouse Activity Handling")
    var
        CSFieldDefaults: Record "CS Field Defaults";
    begin
        CSFieldDefaults.SetRange(Id,CSUserId);
        CSFieldDefaults.SetRange("Use Case Code",CurrentCode);

        if CSWarehouseActivityHandling."Location Code" = '' then begin
          CSFieldDefaults.SetRange("Field No",CSWarehouseActivityHandling.FieldNo("Location Code"));
          if CSFieldDefaults.FindFirst then
            CSWarehouseActivityHandling."Location Code" := CSFieldDefaults.Value;
        end;

        if CSWarehouseActivityHandling."Bin Code" = '' then begin
          CSFieldDefaults.SetRange("Field No",CSWarehouseActivityHandling.FieldNo("Bin Code"));
          if CSFieldDefaults.FindFirst then
            CSWarehouseActivityHandling."Bin Code" := CSFieldDefaults.Value;
        end;
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

