codeunit 6151362 "CS UI Stock Adjustment"
{
    // NPR5.51/ALST/20190731 CASE 362173 new object, used to adjust stock after counting bin contents
    // NPR5.51/CLVA/20190826 CASE 362173 Rearranged code to optimize functionality
    // NPR5.51/CLVA/20190830 CASE 366739 Changed error handling to overcome text overflow
    // NPR5.53/SARA/20191030 CASE 375030 Added validation for Location = Directed PutAway and Pick
    // NPR5.53/CLVA/20191118 CASE 377721 Changed posting to background posting
    // NPR5.53/CLVA/20191128 CASE 379973 Handling duplicate entries

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
        Text020: Label 'Location Should not be DirectedPutAway/Pick';
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
        Text029: Label 'Adjustment for item %1 : %2 to Bin %3 is already added for posting';

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

        //-NPR5.53 [375030]
        if Location."Directed Put-away and Pick" then
          Remark := Text020;
        //+NPR5.53 [375030]
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
            Remark := StrSubstNo(Text014,InputValue);
            exit;
          end;

          CSWarehouseActivityHandling."Item No." := ItemNo;
          CSWarehouseActivityHandling."Variant Code" := VariantCode;

          //-NPR5.53 [379973]
          if CSWarehouseActivityHandling."Bin Code" <> '' then begin
            ItemJnlTemplate.SetRange(Type,ItemJnlTemplate.Type::Item);
            if ItemJnlTemplate.FindFirst then begin

              if ItemJournalBatch.Get(ItemJnlTemplate.Name,UserId) then begin
                Clear(ItemJournalLine);
                ItemJournalLine.SetRange("Journal Template Name",ItemJournalBatch."Journal Template Name");
                ItemJournalLine.SetRange("Journal Batch Name",ItemJournalBatch.Name);
                ItemJournalLine.SetRange("Item No.",CSWarehouseActivityHandling."Item No.");
                ItemJournalLine.SetRange("Variant Code",CSWarehouseActivityHandling."Variant Code");
                ItemJournalLine.SetRange("Bin Code",CSWarehouseActivityHandling."Bin Code");
                if ItemJournalLine.FindFirst then begin
                  Remark := StrSubstNo(Text029,CSWarehouseActivityHandling."Item No.",CSWarehouseActivityHandling."Variant Code",CSWarehouseActivityHandling."Bin Code");
                  exit;
                end;
              end;

            end;
          end;
          //+NPR5.53 [379973]

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
        ItemJnlTemplate: Record "Item Journal Template";
        NewItemJournalLine: Record "Item Journal Line";
        ItemJournalLine: Record "Item Journal Line";
        OffsetQty: Decimal;
        PostingFinished: Boolean;
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
        LineNo: Integer;
        PostingRecRef: RecordRef;
        CSPostEnqueue: Codeunit "CS Post - Enqueue";
        CSPostingBuffer: Record "CS Posting Buffer";
        CSSetup: Record "CS Setup";
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

        //NPR5.51-
        //ItemJournalLine.INIT;
        //ItemJournalTemplate.SETRANGE(Type,ItemJournalTemplate.Type::Item);
        //ItemJournalTemplate.FINDFIRST;
        //ItemJournalLine.VALIDATE("Journal Template Name",ItemJournalTemplate.Name);
        //ItemJournalLine.VALIDATE("Journal Batch Name",CreateItemBatch(ItemJournalLine."Journal Template Name"));
        ItemJnlTemplate.SetRange(Type,ItemJnlTemplate.Type::Item);
        ItemJnlTemplate.FindFirst;

        if not ItemJournalBatch.Get(ItemJnlTemplate.Name,UserId) then begin
          ItemJournalBatch.Init;
          ItemJournalBatch.Validate("Journal Template Name",ItemJnlTemplate.Name);
          ItemJournalBatch.Validate(Name,UserId);
          ItemJournalBatch.Description := StrSubstNo(Text028,UserId);
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
        ItemJournalLine.Validate("Journal Template Name",ItemJournalBatch."Journal Template Name");
        ItemJournalLine.Validate("Journal Batch Name",ItemJournalBatch.Name);
        ItemJournalLine."Line No." := LineNo;
        ItemJournalLine.Insert(true);

        if OffsetQty > 0 then
          ItemJournalLine.Validate("Entry Type",ItemJournalLine."Entry Type"::"Positive Adjmt.")
        else
          ItemJournalLine.Validate("Entry Type",ItemJournalLine."Entry Type"::"Negative Adjmt.");

        ItemJournalLine.Validate("Item No.",CSWarehouseActivityHandling."Item No.");
        ItemJournalLine.Validate(Description,CSWarehouseActivityHandling."Item Description");
        ItemJournalLine.Validate("Variant Code",CSWarehouseActivityHandling."Variant Code");
        ItemJournalLine.Validate("Location Code",CSWarehouseActivityHandling."Location Code");
        ItemJournalLine.Validate(Quantity,Abs(OffsetQty));
        ItemJournalLine.Validate("Bin Code",CSWarehouseActivityHandling."Bin Code");
        ItemJournalLine.Validate("Posting Date",Today);
        ItemJournalLine."Document Date" := WorkDate;
        //-NPR5.53 [377721]
        //ItemJournalLine.VALIDATE("External Document No.",'MOBILE');
        ItemJournalLine.Validate("External Document No.",CSSessionId);
        //+NPR5.53 [377721]
        ItemJournalLine.Validate("Changed by User",true);
        ItemJournalLine."Document No." := Format(Today);
        ItemJournalLine.Modify(true);
        //NPR5.51+

        //-NPR5.53 [377721]
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
          //+NPR5.53 [377721]
          Commit;
          PostingFinished := CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post Batch",ItemJournalLine);
          //-NPR5.53 [377721]
        end;
        //+NPR5.53 [377721]

        //NPR5.51-
        //DeleteItemBatch(ItemJournalLine."Journal Template Name",ItemJournalLine."Journal Batch Name");
        //NPR5.51+

        if not PostingFinished then begin
          //NPR5.51- [366739]
          //Remark := STRSUBSTNO(AdjustingFailedErr,GETLASTERRORTEXT);
          Remark := CopyStr(GetLastErrorText,1,MaxStrLen(Remark));
          //NPR5.51+ [366739]
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

    local procedure DeleteItemBatch(TemplateName: Code[10];BatchName: Code[10])
    var
        ItemJournalBatch: Record "Item Journal Batch";
    begin
        //NPR5.51-
        //IF ItemJournalBatch.GET(TemplateName,BatchName) THEN
        //  ItemJournalBatch.DELETE(TRUE);
        //NPR5.51+
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
}

