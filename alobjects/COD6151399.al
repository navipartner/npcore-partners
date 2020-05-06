codeunit 6151399 "CS UI Warehouse Activity V2"
{
    // NPR5.54/CLVA/20180313 CASE 306407 Object created - NP Capture Service

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
        Text003: Label '%1 is equal %2';
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
        Text016: Label 'Qty. to Handle exceed Outstanding Qty.';
        Text017: Label 'Bin Code %1 is not valid';
        Text018: Label 'Bin Code %1 is already selected for this line';
        Text019: Label 'Bin Code is blank';
        Text020: Label 'Variant is not a record';
        Text021: Label 'Item %1 not found on doc. %2';
        Text022: Label 'Qty. does not match.';
        Text023: Label '%1 = ''%2'', %3 = ''%4'', %5 = ''%6'', %7 = ''%8'': The total base quantity to take %9 must be equal to the total base quantity to place %10.';
        Text024: Label '%1 = ''%2'', %3 = ''%4'':\The total base quantity to take %5 must be equal to the total base quantity to place %6.';
        Text025: Label '%1 is 0';
        Text026: Label '%1 / %2';
        Text027: Label '%1 | %2';

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
        CSWarehouseActivityHandling: Record "CS Warehouse Activity Handling";
        CSWarehouseActivityHandling2: Record "CS Warehouse Activity Handling";
        CSFieldDefaults: Record "CS Field Defaults";
        WhseActivityLine: Record "Warehouse Activity Line";
        ActionIndex: Integer;
        CSUILine: Record "CS UI Line";
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

        case FuncGroup.KeyDef of
          FuncGroup.KeyDef::Esc:
            begin
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
                  'SPLITLINE':
                  begin
                    Evaluate(FuncTableNo,CSCommunication.GetNodeAttribute(ReturnedNode,'FuncTableNo'));
                    FuncRecRef.Open(FuncTableNo);
                    Evaluate(FuncRecId,CSCommunication.GetNodeAttribute(ReturnedNode,'FuncRecordID'));
                    if FuncRecRef.Get(FuncRecId) then begin
                      FuncRecRef.SetTable(WhseActivityLine);
                      SplitLine(WhseActivityLine);
                    end;
                  end;
                end;
              end;
          FuncGroup.KeyDef::Reset:
            Reset(CSWarehouseActivityHandling);
          FuncGroup.KeyDef::Register:
            begin
              if not Evaluate(ActionIndex,CSCommunication.GetNodeAttribute(ReturnedNode,'ActionIndex')) then
                ActionIndex := MiniformHeader."Posting Type" + 1;
              Register(CSWarehouseActivityHandling,ActionIndex);
              if Remark = '' then begin
                CSCommunication.RunPreviousUI(DOMxmlin)
              end else
                SendForm(ActiveInputField,CSWarehouseActivityHandling);
            end;
          FuncGroup.KeyDef::Input:
            begin
              Evaluate(FldNo,CSCommunication.GetNodeAttribute(ReturnedNode,'FieldID'));
              case FldNo of
                CSWarehouseActivityHandling.FieldNo(Barcode):
                  CheckBarcode(CSWarehouseActivityHandling,TextValue);
                CSWarehouseActivityHandling.FieldNo(Qty):
                  CheckQty(CSWarehouseActivityHandling,TextValue);
                CSWarehouseActivityHandling.FieldNo("Bin Code"):
                  CheckBin(CSWarehouseActivityHandling,TextValue);
                else begin
                  CSCommunication.FieldSetvalue(RecRef,FldNo,TextValue);
                end;
              end;

              RecRef.GetTable(CSWarehouseActivityHandling);
              CSCommunication.SetRecRef(RecRef);
              ActiveInputField := CSCommunication.GetActiveInputNo(CurrentCode,FldNo);
              if Remark = '' then
                if CSCommunication.LastEntryField(CurrentCode,FldNo) then begin

        //          CLEAR(CSFieldDefaults);
        //          CSFieldDefaults.SETRANGE(Id,CSUserId);
        //          CSFieldDefaults.SETRANGE("Use Case Code",CurrentCode);
        //          IF CSFieldDefaults.FINDSET THEN BEGIN
        //            REPEAT
        //
        //              CLEAR(CSUILine);
        //              CSUILine.SETRANGE("UI Code",MiniformHeader.Code);
        //              CSUILine.SETRANGE("Field No.",CSFieldDefaults."Field No");
        //              CSUILine.SETRANGE("Field Type",CSUILine."Field Type"::Input);
        //              IF NOT CSUILine.FINDSET THEN BEGIN
        //                CSCommunication.FieldSetvalue(RecRef,CSFieldDefaults."Field No",CSFieldDefaults.Value);
        //                RecRef.SETTABLE(CSWarehouseActivityHandling);
        //                RecRef.SETRECFILTER;
        //                CSCommunication.SetRecRef(RecRef);
        //              END;
        //            UNTIL CSFieldDefaults.NEXT = 0;
        //          END;

                  UpdateDataLine(CSWarehouseActivityHandling);
                  ClearDataLine(CSWarehouseActivityHandling);
                  RecRef.GetTable(CSWarehouseActivityHandling);
                  CSCommunication.SetRecRef(RecRef);
                  ActiveInputField := 1;
                end else
                  ActiveInputField += 1;
            end;
          else
            Error(Text000);
        end;

        if not (FuncGroup.KeyDef in [FuncGroup.KeyDef::Esc,FuncGroup.KeyDef::Register]) then
          SendForm(ActiveInputField,CSWarehouseActivityHandling);
    end;

    local procedure PrepareData()
    var
        WarehouseActivityHeader: Record "Warehouse Activity Header";
        CSWarehouseActivityHandling: Record "CS Warehouse Activity Handling";
        RecId: RecordID;
        TableNo: Integer;
    begin
        XMLDOMMgt.FindNode(RootNode,'Header/Input',ReturnedNode);

        Evaluate(TableNo,CSCommunication.GetNodeAttribute(ReturnedNode,'TableNo'));
        Evaluate(RecId,CSCommunication.GetNodeAttribute(ReturnedNode,'RecordID'));

        RecRef.Open(TableNo);
        RecRef.Get(RecId);
        RecRef.SetTable(WarehouseActivityHeader);

        CreateDataLine(CSWarehouseActivityHandling,WarehouseActivityHeader);

        RecRef.Close;

        RecId := CSWarehouseActivityHandling.RecordId;

        RecRef.Open(RecId.TableNo);
        RecRef.Get(RecId);
        RecRef.SetRecFilter;

        CSCommunication.SetRecRef(RecRef);
        ActiveInputField := 1;
        SendForm(ActiveInputField,CSWarehouseActivityHandling);
    end;

    local procedure SendForm(InputField: Integer;CSWarehouseActivityHandling: Record "CS Warehouse Activity Handling")
    var
        Records: DotNet npNetXmlElement;
    begin
        CSCommunication.EncodeUI(MiniformHeader,StackCode,DOMxmlin,InputField,Remark,CSUserId);
        CSCommunication.GetReturnXML(DOMxmlin);

        if MiniformHeader."Posting Type" = MiniformHeader."Posting Type"::"Prompt User" then
          AddAdditionalInfo(DOMxmlin,CSWarehouseActivityHandling);

        if AddSummarize(Records) then
          DOMxmlin.DocumentElement.AppendChild(Records);

        CSMgt.SendXMLReply(DOMxmlin);
    end;

    local procedure CheckBarcode(var CSWarehouseActivityHandling: Record "CS Warehouse Activity Handling";InputValue: Text)
    var
        BarcodeLibrary: Codeunit "Barcode Library";
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
        Item: Record Item;
        ItemCrossReference: Record "Item Cross Reference";
        WhseActivityLine: Record "Warehouse Activity Line";
        QtytoHandle: Decimal;
        QtyOutstanding: Decimal;
        CSSetup: Record "CS Setup";
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
                if FindFirst() then begin
                  CSWarehouseActivityHandling."Unit of Measure" := ItemCrossReference."Unit of Measure";
                end;
              end;
            end;
          end;

        end else begin
          Remark := StrSubstNo(Text010,InputValue);
          exit;
        end;

        CSSetup.Get;
        if CSSetup."Sum Qty. to Handle" then begin
          QtytoHandle := 0;
          QtyOutstanding := 0;

          WhseActivityLine.SetCurrentKey("Activity Type","No.","Sorting Sequence No.");
          WhseActivityLine.SetRange("Activity Type",CSWarehouseActivityHandling."Activity Type");
          WhseActivityLine.SetRange("No.",CSWarehouseActivityHandling."No.");
          WhseActivityLine.SetRange("Item No.",CSWarehouseActivityHandling."Item No.");
          WhseActivityLine.SetRange("Variant Code",CSWarehouseActivityHandling."Variant Code");
          case CSWarehouseActivityHandling."Activity Type" of
            CSWarehouseActivityHandling."Activity Type"::Pick:
              WhseActivityLine.SetRange("Action Type",WhseActivityLine."Action Type"::Take);
            CSWarehouseActivityHandling."Activity Type"::"Put-away":
              WhseActivityLine.SetRange("Action Type",WhseActivityLine."Action Type"::Place);
          end;
          if WhseActivityLine.FindSet then begin
            repeat
              QtytoHandle := QtytoHandle + WhseActivityLine."Qty. to Handle";
              QtyOutstanding := QtyOutstanding + WhseActivityLine."Qty. Outstanding";
            until WhseActivityLine.Next = 0;

            CSWarehouseActivityHandling.Qty := QtyOutstanding - QtytoHandle;

          end;
        end;

        CSWarehouseActivityHandling.Barcode := InputValue;
        CSWarehouseActivityHandling.Modify(true);
    end;

    local procedure CheckQty(var CSWarehouseActivityHandling: Record "CS Warehouse Activity Handling";InputValue: Text)
    var
        Qty: Decimal;
        UpdatedCSWarehouseActivityHandling: Record "CS Warehouse Activity Handling";
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
        CSWarehouseActivityHandling.Modify(true);
    end;

    local procedure CheckBin(var CSWarehouseActivityHandling: Record "CS Warehouse Activity Handling";InputValue: Text)
    var
        Bin: Record Bin;
        UpdatedCSWarehouseActivityHandling: Record "CS Warehouse Activity Handling";
    begin
        if InputValue = '' then begin
          Remark := Text019;
          exit;
        end;

        if (StrLen(InputValue) > MaxStrLen(Bin.Code)) then begin
          Remark := Text008;
          exit;
        end;

        if not Bin.Get(CSWarehouseActivityHandling."Location Code",InputValue) then begin
          Remark := StrSubstNo(Text017,InputValue);
          exit;
        end;

        CSWarehouseActivityHandling."Bin Code" := InputValue;
        CSWarehouseActivityHandling.Modify(true);
    end;

    local procedure CreateDataLine(var CSWarehouseActivityHandling: Record "CS Warehouse Activity Handling";WarehouseActivityHeader: Record "Warehouse Activity Header")
    var
        NewCSWarehouseActivityHandling: Record "CS Warehouse Activity Handling";
        CSUIHeader: Record "CS UI Header";
    begin
        if WarehouseActivityHeader.IsEmpty then
          Error(Text020);

        Clear(NewCSWarehouseActivityHandling);
        NewCSWarehouseActivityHandling.SetRange(Id,CSSessionId);
        NewCSWarehouseActivityHandling.DeleteAll(true);

        CSWarehouseActivityHandling.Init;
        CSWarehouseActivityHandling.Id := CSSessionId;
        CSWarehouseActivityHandling."Line No." := 1;
        CSWarehouseActivityHandling."Created By" := UserId;
        CSWarehouseActivityHandling.Created := CurrentDateTime;

        CSWarehouseActivityHandling."Table No." := 5766;
        CSWarehouseActivityHandling."Activity Type" := WarehouseActivityHeader.Type;
        CSWarehouseActivityHandling."No." := WarehouseActivityHeader."No.";
        CSWarehouseActivityHandling."Assignment Date" := WarehouseActivityHeader."Assignment Date";
        CSWarehouseActivityHandling."Record Id" := WarehouseActivityHeader.RecordId;
        CSWarehouseActivityHandling."Location Code" := WarehouseActivityHeader."Location Code";

        CSWarehouseActivityHandling.Insert(true);
    end;

    local procedure UpdateDataLine(var CSWarehouseActivityHandling: Record "CS Warehouse Activity Handling")
    begin
        CSWarehouseActivityHandling.Handled := true;
        CSWarehouseActivityHandling.Modify(true);

        if TransferDataLine(CSWarehouseActivityHandling) then begin
          CSWarehouseActivityHandling."Transferred to Document" := true;
          CSWarehouseActivityHandling.Modify(true);
        end;
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
        CSWarehouseActivityHandling: Record "CS Warehouse Activity Handling";
        WhseActivityLine: Record "Warehouse Activity Line";
        LineType: Option TEXT,BUTTON;
        CurrRecordID: RecordID;
        TableNo: Integer;
        BinIsMandatory: Boolean;
        Location: Record Location;
    begin
        Clear(CSWarehouseActivityHandling);
        CSWarehouseActivityHandling.SetRange(Id,CSSessionId);
        if not CSWarehouseActivityHandling.FindLast then
          exit(false);

        if Location.Get(CSWarehouseActivityHandling."Location Code") then
          BinIsMandatory := Location."Bin Mandatory";

        if BinIsMandatory then
          WhseActivityLine.SetCurrentKey("Bin Code","Location Code","Action Type","Breakbulk No.");

        WhseActivityLine.SetRange("No.",CSWarehouseActivityHandling."No.");
        WhseActivityLine.SetRange("Activity Type",CSWarehouseActivityHandling."Activity Type");

        if BinIsMandatory then begin
          case CSWarehouseActivityHandling."Activity Type" of
            CSWarehouseActivityHandling."Activity Type"::Pick : WhseActivityLine.SetRange("Action Type",WhseActivityLine."Action Type"::Take);
            CSWarehouseActivityHandling."Activity Type"::"Put-away" : WhseActivityLine.SetRange("Action Type",WhseActivityLine."Action Type"::Place);
          end;
        end else begin
          case CSWarehouseActivityHandling."Activity Type" of
            CSWarehouseActivityHandling."Activity Type"::"Invt. Put-away" : WhseActivityLine.SetRange("Activity Type",WhseActivityLine."Activity Type"::"Invt. Put-away");
            CSWarehouseActivityHandling."Activity Type"::"Invt. Pick" : WhseActivityLine.SetRange("Activity Type",WhseActivityLine."Activity Type"::"Invt. Pick");
          end;
        end;

        if WhseActivityLine.FindSet then begin
          Records := DOMxmlin.CreateElement('Records');
          repeat
            Record := DOMxmlin.CreateElement('Record');

            CurrRecordID := WhseActivityLine.RecordId;
            TableNo := CurrRecordID.TableNo;

            if (WhseActivityLine."Qty. to Handle" < WhseActivityLine."Qty. Outstanding") then
              Indicator := 'minus'
            else if (WhseActivityLine."Qty. to Handle" = WhseActivityLine."Qty. Outstanding") then
              Indicator := 'ok'
            else
              Indicator := 'plus';

            if Indicator = 'minus' then begin
              if MiniformHeader."Expand Summary Items" then begin
                //1
                Line := DOMxmlin.CreateElement('Line');
                AddAttribute(Line,'Descrip',WhseActivityLine.FieldCaption(Description));
                AddAttribute(Line,'Indicator',Indicator);
                AddAttribute(Line,'Type',Format(LineType::TEXT));
                AddAttribute(Line,'CollapsItems','FALSE');
                Line.InnerText := WhseActivityLine."Bin Code";
                Record.AppendChild(Line);

                //2
                Line := DOMxmlin.CreateElement('Line');
                AddAttribute(Line,'Descrip',WhseActivityLine.FieldCaption("Qty. Outstanding"));
                AddAttribute(Line,'Type',Format(LineType::TEXT));
                Line.InnerText := StrSubstNo(Text026,WhseActivityLine."Qty. to Handle",WhseActivityLine."Qty. Outstanding");
                Record.AppendChild(Line);

                //3
                Line := DOMxmlin.CreateElement('Line');
                AddAttribute(Line,'Descrip',WhseActivityLine.FieldCaption("Item No."));
                AddAttribute(Line,'Type',Format(LineType::TEXT));
                if WhseActivityLine."Variant Code" <> '' then
                  Line.InnerText := StrSubstNo(Text027,WhseActivityLine."Item No.",WhseActivityLine."Variant Code")
                else
                  Line.InnerText := WhseActivityLine."Item No.";
                Record.AppendChild(Line);

                //4
                Line := DOMxmlin.CreateElement('Line');
                AddAttribute(Line,'Descrip',WhseActivityLine.FieldCaption("Unit of Measure Code"));
                AddAttribute(Line,'Type',Format(LineType::TEXT));
                Line.InnerText := WhseActivityLine."Unit of Measure Code";
                Record.AppendChild(Line);

                //5
                Line := DOMxmlin.CreateElement('Line');
                AddAttribute(Line,'Descrip',WhseActivityLine.FieldCaption(Description));
                AddAttribute(Line,'Type',Format(LineType::TEXT));
                Line.InnerText := WhseActivityLine.Description;
                Record.AppendChild(Line);

                //6
                Line := DOMxmlin.CreateElement('Line');
                AddAttribute(Line,'Descrip','');
                AddAttribute(Line,'Type',Format(LineType::TEXT));
                Line.InnerText := '';
                Record.AppendChild(Line);

                if Location.Get(WhseActivityLine."Location Code") then
                  if Location."Bin Mandatory" then begin
                    Line := DOMxmlin.CreateElement('Line');
                    AddAttribute(Line,'Descrip','Split Line..');
                    AddAttribute(Line,'Type',Format(LineType::BUTTON));
                    AddAttribute(Line,'TableNo',Format(TableNo));
                    AddAttribute(Line,'RecordID',Format(CurrRecordID));
                    AddAttribute(Line,'FuncName','SPLITLINE');
                    Record.AppendChild(Line);
                end;

              end else begin
                Line := DOMxmlin.CreateElement('Line');
                AddAttribute(Line,'Descrip',WhseActivityLine.FieldCaption(Description));
                AddAttribute(Line,'Indicator',Indicator);
                AddAttribute(Line,'Type',Format(LineType::TEXT));
                AddAttribute(Line,'CollapsItems','TRUE');

                if WhseActivityLine."Variant Code" <> '' then
                  Line.InnerText := StrSubstNo(Text015,WhseActivityLine."Qty. to Handle",WhseActivityLine."Qty. Outstanding",WhseActivityLine."Item No."+'-'+WhseActivityLine."Variant Code",WhseActivityLine.Description)
                else
                Line.InnerText := StrSubstNo(Text015,WhseActivityLine."Qty. to Handle",WhseActivityLine."Qty. Outstanding",WhseActivityLine."Item No.",WhseActivityLine.Description);
                Record.AppendChild(Line);

                if Location.Get(WhseActivityLine."Location Code") then
                  if Location."Bin Mandatory" then begin
                    Line := DOMxmlin.CreateElement('Line');
                    AddAttribute(Line,'Descrip','Split Line..');
                    AddAttribute(Line,'Type',Format(LineType::BUTTON));
                    AddAttribute(Line,'TableNo',Format(TableNo));
                    AddAttribute(Line,'RecordID',Format(CurrRecordID));
                    AddAttribute(Line,'FuncName','SPLITLINE');
                    Record.AppendChild(Line);
                end;

                Line := DOMxmlin.CreateElement('Line');
                AddAttribute(Line,'Descrip',WhseActivityLine.FieldCaption(Description));
                AddAttribute(Line,'Type',Format(LineType::TEXT));
                Line.InnerText := WhseActivityLine.Description;
                Record.AppendChild(Line);

                Line := DOMxmlin.CreateElement('Line');
                AddAttribute(Line,'Descrip',WhseActivityLine.FieldCaption("Bin Code"));
                AddAttribute(Line,'Type',Format(LineType::TEXT));
                Line.InnerText := WhseActivityLine."Bin Code";
                Record.AppendChild(Line);

                Line := DOMxmlin.CreateElement('Line');
                AddAttribute(Line,'Descrip',WhseActivityLine.FieldCaption("Source Document"));
                AddAttribute(Line,'Type',Format(LineType::TEXT));
                Line.InnerText := Format(WhseActivityLine."Source Document");
                Record.AppendChild(Line);

                Line := DOMxmlin.CreateElement('Line');
                AddAttribute(Line,'Descrip',WhseActivityLine.FieldCaption("Source No."));
                AddAttribute(Line,'Type',Format(LineType::TEXT));
                Line.InnerText := WhseActivityLine."Source No.";
                Record.AppendChild(Line);

                Line := DOMxmlin.CreateElement('Line');
                AddAttribute(Line,'Descrip',WhseActivityLine.FieldCaption("Unit of Measure Code"));
                AddAttribute(Line,'Type',Format(LineType::TEXT));
                Line.InnerText := WhseActivityLine."Unit of Measure Code";
                Record.AppendChild(Line);

                Line := DOMxmlin.CreateElement('Line');
                AddAttribute(Line,'Descrip',WhseActivityLine.FieldCaption("Qty. per Unit of Measure"));
                AddAttribute(Line,'Type',Format(LineType::TEXT));
                Line.InnerText := Format(WhseActivityLine."Qty. per Unit of Measure");
                Record.AppendChild(Line);
              end;
              Records.AppendChild(Record);
            end;
          until WhseActivityLine.Next = 0;

          if not MiniformHeader."Hid Fulfilled Lines" then begin
            if WhseActivityLine.FindSet then begin
              repeat
                Record := DOMxmlin.CreateElement('Record');

                CurrRecordID := WhseActivityLine.RecordId;
                TableNo := CurrRecordID.TableNo;

                if (WhseActivityLine."Qty. to Handle" < WhseActivityLine."Qty. Outstanding") then
                  Indicator := 'minus'
                else if (WhseActivityLine."Qty. to Handle" = WhseActivityLine."Qty. Outstanding") then
                  Indicator := 'ok'
                else
                  Indicator := 'plus';

                if Indicator <> 'minus' then begin
                  if MiniformHeader."Expand Summary Items" then begin
                    //1
                    Line := DOMxmlin.CreateElement('Line');
                    AddAttribute(Line,'Descrip',WhseActivityLine.FieldCaption(Description));
                    AddAttribute(Line,'Indicator',Indicator);
                    AddAttribute(Line,'Type',Format(LineType::TEXT));
                    AddAttribute(Line,'CollapsItems','FALSE');
                    Line.InnerText := WhseActivityLine."Bin Code";
                    Record.AppendChild(Line);

                    //2
                    Line := DOMxmlin.CreateElement('Line');
                    AddAttribute(Line,'Descrip',WhseActivityLine.FieldCaption("Qty. Outstanding"));
                    AddAttribute(Line,'Type',Format(LineType::TEXT));
                    Line.InnerText := StrSubstNo(Text026,WhseActivityLine."Qty. to Handle",WhseActivityLine."Qty. Outstanding");
                    Record.AppendChild(Line);

                    //3
                    Line := DOMxmlin.CreateElement('Line');
                    AddAttribute(Line,'Descrip',WhseActivityLine.FieldCaption("Item No."));
                    AddAttribute(Line,'Type',Format(LineType::TEXT));
                    if WhseActivityLine."Variant Code" <> '' then
                      Line.InnerText := StrSubstNo(Text027,WhseActivityLine."Item No.",WhseActivityLine."Variant Code")
                    else
                      Line.InnerText := WhseActivityLine."Item No.";
                    Record.AppendChild(Line);

                    //4
                    Line := DOMxmlin.CreateElement('Line');
                    AddAttribute(Line,'Descrip',WhseActivityLine.FieldCaption("Unit of Measure Code"));
                    AddAttribute(Line,'Type',Format(LineType::TEXT));
                    Line.InnerText := WhseActivityLine."Unit of Measure Code";
                    Record.AppendChild(Line);

                    //5
                    Line := DOMxmlin.CreateElement('Line');
                    AddAttribute(Line,'Descrip',WhseActivityLine.FieldCaption(Description));
                    AddAttribute(Line,'Type',Format(LineType::TEXT));
                    Line.InnerText := WhseActivityLine.Description;
                    Record.AppendChild(Line);

                    //6
                    Line := DOMxmlin.CreateElement('Line');
                    AddAttribute(Line,'Descrip','');
                    AddAttribute(Line,'Type',Format(LineType::TEXT));
                    Line.InnerText := '';
                    Record.AppendChild(Line);

                    if Location.Get(WhseActivityLine."Location Code") then
                      if Location."Bin Mandatory" then begin
                        Line := DOMxmlin.CreateElement('Line');
                        AddAttribute(Line,'Descrip','Split Line..');
                        AddAttribute(Line,'Type',Format(LineType::BUTTON));
                        AddAttribute(Line,'TableNo',Format(TableNo));
                        AddAttribute(Line,'RecordID',Format(CurrRecordID));
                        AddAttribute(Line,'FuncName','SPLITLINE');
                        Record.AppendChild(Line);
                    end;
                  end else begin
                    Line := DOMxmlin.CreateElement('Line');
                    AddAttribute(Line,'Descrip',WhseActivityLine.FieldCaption(Description));
                    AddAttribute(Line,'Indicator',Indicator);
                    AddAttribute(Line,'Type',Format(LineType::TEXT));
                    if WhseActivityLine."Variant Code" <> '' then
                      Line.InnerText := StrSubstNo(Text015,WhseActivityLine."Qty. to Handle",WhseActivityLine."Qty. Outstanding",WhseActivityLine."Item No."+'-'+WhseActivityLine."Variant Code",WhseActivityLine.Description)
                    else
                      Line.InnerText := StrSubstNo(Text015,WhseActivityLine."Qty. to Handle",WhseActivityLine."Qty. Outstanding",WhseActivityLine."Item No.",WhseActivityLine.Description);
                    Record.AppendChild(Line);

                    if Location.Get(WhseActivityLine."Location Code") then
                      if Location."Bin Mandatory" then begin
                        Line := DOMxmlin.CreateElement('Line');
                        AddAttribute(Line,'Descrip','Split Line..');
                        AddAttribute(Line,'Type',Format(LineType::BUTTON));
                        AddAttribute(Line,'TableNo',Format(TableNo));
                        AddAttribute(Line,'RecordID',Format(CurrRecordID));
                        AddAttribute(Line,'FuncName','SPLITLINE');
                        Record.AppendChild(Line);
                      end;

                    Line := DOMxmlin.CreateElement('Line');
                    AddAttribute(Line,'Descrip',WhseActivityLine.FieldCaption(Description));
                    AddAttribute(Line,'Type',Format(LineType::TEXT));
                    Line.InnerText := WhseActivityLine.Description;
                    Record.AppendChild(Line);

                    Line := DOMxmlin.CreateElement('Line');
                    AddAttribute(Line,'Descrip',WhseActivityLine.FieldCaption("Bin Code"));
                    AddAttribute(Line,'Type',Format(LineType::TEXT));
                    Line.InnerText := WhseActivityLine."Bin Code";
                    Record.AppendChild(Line);

                    Line := DOMxmlin.CreateElement('Line');
                    AddAttribute(Line,'Descrip',WhseActivityLine.FieldCaption("Source Document"));
                    AddAttribute(Line,'Type',Format(LineType::TEXT));
                    Line.InnerText := Format(WhseActivityLine."Source Document");
                    Record.AppendChild(Line);

                    Line := DOMxmlin.CreateElement('Line');
                    AddAttribute(Line,'Descrip',WhseActivityLine.FieldCaption("Source No."));
                    AddAttribute(Line,'Type',Format(LineType::TEXT));
                    Line.InnerText := WhseActivityLine."Source No.";
                    Record.AppendChild(Line);

                    Line := DOMxmlin.CreateElement('Line');
                    AddAttribute(Line,'Descrip',WhseActivityLine.FieldCaption("Unit of Measure Code"));
                    AddAttribute(Line,'Type',Format(LineType::TEXT));
                    Line.InnerText := WhseActivityLine."Unit of Measure Code";
                    Record.AppendChild(Line);

                    Line := DOMxmlin.CreateElement('Line');
                    AddAttribute(Line,'Descrip',WhseActivityLine.FieldCaption("Qty. per Unit of Measure"));
                    AddAttribute(Line,'Type',Format(LineType::TEXT));
                    Line.InnerText := Format(WhseActivityLine."Qty. per Unit of Measure");
                    Record.AppendChild(Line);
                  end;
                  Records.AppendChild(Record);
                end;
              until WhseActivityLine.Next = 0;
             end;
            end;
          exit(true);
        end else
          exit(false);
    end;

    local procedure AddAdditionalInfo(var xmlout: DotNet npNetXmlDocument;CSWarehouseActivityHandling: Record "CS Warehouse Activity Handling")
    var
        CurrentRootNode: DotNet npNetXmlNode;
        XMLFunctionNode: DotNet npNetXmlNode;
        StrMenuTxt: Text;
    begin
        if not (CSWarehouseActivityHandling."Activity Type" in [CSWarehouseActivityHandling."Activity Type"::"Invt. Put-away",CSWarehouseActivityHandling."Activity Type"::"Invt. Pick"]) then
          exit;

        case CSWarehouseActivityHandling."Activity Type" of
          CSWarehouseActivityHandling."Activity Type"::"Invt. Put-away" : StrMenuTxt := 'Handle,Handle & Invoice';
          CSWarehouseActivityHandling."Activity Type"::"Invt. Pick" : StrMenuTxt := 'Handle,Handle & Invoice';
        end;

        CurrentRootNode := xmlout.DocumentElement;
        XMLDOMMgt.FindNode(CurrentRootNode,'Header/Functions',ReturnedNode);

        foreach XMLFunctionNode in ReturnedNode.ChildNodes do begin
          if (XMLFunctionNode.InnerText = 'REGISTER') then
            AddAttribute(XMLFunctionNode,'Actions',StrMenuTxt);
        end;
    end;

    local procedure Reset(CSWarehouseActivityHandling: Record "CS Warehouse Activity Handling")
    var
        WhseActivityLine: Record "Warehouse Activity Line";
        Location: Record Location;
        BinIsMandatory: Boolean;
        xRecQtyToHandle: Decimal;
    begin
        Remark := '';
        WhseActivityLine.SetRange("No.",CSWarehouseActivityHandling."No.");

        if Location.Get(CSWarehouseActivityHandling."Location Code") then
          BinIsMandatory := Location."Bin Mandatory";

        if BinIsMandatory then begin
          case CSWarehouseActivityHandling."Activity Type" of
            CSWarehouseActivityHandling."Activity Type"::Pick : WhseActivityLine.SetRange("Action Type",WhseActivityLine."Action Type"::Take);
            CSWarehouseActivityHandling."Activity Type"::"Put-away" : WhseActivityLine.SetRange("Action Type",WhseActivityLine."Action Type"::Place);
          end;
        end else begin
          case CSWarehouseActivityHandling."Activity Type" of
            CSWarehouseActivityHandling."Activity Type"::"Invt. Put-away" : WhseActivityLine.SetRange("Activity Type",WhseActivityLine."Activity Type"::"Invt. Put-away");
            CSWarehouseActivityHandling."Activity Type"::"Invt. Pick" : WhseActivityLine.SetRange("Activity Type",WhseActivityLine."Activity Type"::"Invt. Pick");
          end;
        end;

        if WhseActivityLine.FindSet then begin
          repeat
            xRecQtyToHandle := WhseActivityLine."Qty. to Handle";
            WhseActivityLine.Validate("Qty. to Handle",0);
            WhseActivityLine.Modify;
            UpdateActivityLine(WhseActivityLine,1);
          until WhseActivityLine.Next = 0;
        end else
          Error(Text007);

        CSCommunication.SetRecRef(RecRef);
        ActiveInputField := 1;
    end;

    local procedure Register(CSWarehouseActivityHandling: Record "CS Warehouse Activity Handling";Index: Integer)
    var
        WhseActivityLine: Record "Warehouse Activity Line";
        WhseActivityRegister: Codeunit "Whse.-Activity-Register";
        WhseActivityPost: Codeunit "Whse.-Activity-Post";
        WarehouseActivityHeader: Record "Warehouse Activity Header";
        CSSetup: Record "CS Setup";
        PostingRecRef: RecordRef;
        CSPostingBuffer: Record "CS Posting Buffer";
        CSPostEnqueue: Codeunit "CS Post - Enqueue";
        Posted: Boolean;
    begin
        Remark := '';

        CSSetup.Get;
        if CSSetup."Post with Job Queue" then begin
          WarehouseActivityHeader.Get(CSWarehouseActivityHandling."Activity Type",CSWarehouseActivityHandling."No.");
          PostingRecRef.GetTable(WarehouseActivityHeader);
          CSPostingBuffer.Init;
          CSPostingBuffer."Table No." := PostingRecRef.Number;
          CSPostingBuffer."Record Id" := PostingRecRef.RecordId;
          CSPostingBuffer."Posting Index" := Index;
          CSPostingBuffer."Update Posting Date" := MiniformHeader."Update Posting Date";
          case CSWarehouseActivityHandling."Activity Type" of
            CSWarehouseActivityHandling."Activity Type"::"Invt. Movement" : CSPostingBuffer."Job Type" := CSPostingBuffer."Job Type"::"Invt. Movement";
            CSWarehouseActivityHandling."Activity Type"::"Invt. Pick" : CSPostingBuffer."Job Type" := CSPostingBuffer."Job Type"::"Invt. Pick";
            CSWarehouseActivityHandling."Activity Type"::"Invt. Put-away" : CSPostingBuffer."Job Type" := CSPostingBuffer."Job Type"::"Invt. Put-away";
            CSWarehouseActivityHandling."Activity Type"::Movement : CSPostingBuffer."Job Type" := CSPostingBuffer."Job Type"::Movement;
            CSWarehouseActivityHandling."Activity Type"::Pick : CSPostingBuffer."Job Type" := CSPostingBuffer."Job Type"::Pick;
            CSWarehouseActivityHandling."Activity Type"::"Put-away" : CSPostingBuffer."Job Type" := CSPostingBuffer."Job Type"::"Put-away";
          end;
          if CSPostingBuffer.Insert(true) then
            CSPostEnqueue.Run(CSPostingBuffer)
          else
            Remark := GetLastErrorText;
          exit;
        end;

        WhseActivityLine.SetRange("No.",CSWarehouseActivityHandling."No.");

        if WhseActivityLine.FindSet then begin

          if MiniformHeader."Update Posting Date" then begin
            WarehouseActivityHeader.Get(CSWarehouseActivityHandling."Activity Type",CSWarehouseActivityHandling."No.");
            WarehouseActivityHeader.Validate("Posting Date",Today);
            WarehouseActivityHeader.Modify(true);
          end;

          Posted := false;

          repeat
            case CSWarehouseActivityHandling."Activity Type" of
              CSWarehouseActivityHandling."Activity Type"::Pick,CSWarehouseActivityHandling."Activity Type"::"Put-away" : begin
                  if CheckBalanceQtyToHandle(WhseActivityLine) then begin
                    WhseActivityRegister.ShowHideDialog(true);
                    WhseActivityRegister.Run(WhseActivityLine);
                    Posted := true;
                  end;
                end;
              CSWarehouseActivityHandling."Activity Type"::"Invt. Pick",CSWarehouseActivityHandling."Activity Type"::"Invt. Put-away" : begin
                  if WhseActivityLine."Qty. to Handle" <> 0 then begin
                    WhseActivityPost.SetInvoiceSourceDoc(Index = 2);
                    WhseActivityPost.Run(WhseActivityLine);
                    Clear(WhseActivityPost);
                    Posted := true;
                  end;
                end;
            end;
          until (WhseActivityLine.Next = 0) or Posted;

        end else
          Error(Text007);
    end;

    local procedure TransferDataLine(CSWarehouseActivityHandling: Record "CS Warehouse Activity Handling"): Boolean
    var
        WhseActivityLine: Record "Warehouse Activity Line";
        FoundedRecToUpdate: Boolean;
        Qty: Decimal;
        Location: Record Location;
        BinIsMandatory: Boolean;
        WhseActivityLineSum: Record "Warehouse Activity Line";
        QtytoHandle: Decimal;
        QtyOutstanding: Decimal;
        CurrQtytoHandle: Decimal;
        Item: Record Item;
        BaseQty: Decimal;
        ItemUnitofMeasure: Record "Item Unit of Measure";
    begin
        WhseActivityLine.SetCurrentKey("Activity Type","No.","Sorting Sequence No.");
        WhseActivityLine.SetRange("No.",CSWarehouseActivityHandling."No.");
        WhseActivityLine.SetRange("Item No.",CSWarehouseActivityHandling."Item No.");

        if CSWarehouseActivityHandling."Variant Code" <> '' then
          WhseActivityLine.SetRange("Variant Code",CSWarehouseActivityHandling."Variant Code");

        if Location.Get(CSWarehouseActivityHandling."Location Code") then
          BinIsMandatory := Location."Bin Mandatory";

        if BinIsMandatory then begin
          case CSWarehouseActivityHandling."Activity Type" of
            CSWarehouseActivityHandling."Activity Type"::Pick : WhseActivityLine.SetRange("Action Type",WhseActivityLine."Action Type"::Take);
            CSWarehouseActivityHandling."Activity Type"::"Put-away" : WhseActivityLine.SetRange("Action Type",WhseActivityLine."Action Type"::Place);
          end;
        end else begin
          case CSWarehouseActivityHandling."Activity Type" of
            CSWarehouseActivityHandling."Activity Type"::"Invt. Pick" : WhseActivityLine.SetRange("Activity Type",WhseActivityLine."Activity Type"::"Invt. Pick");
            CSWarehouseActivityHandling."Activity Type"::"Invt. Put-away" : WhseActivityLine.SetRange("Activity Type",WhseActivityLine."Activity Type"::"Invt. Put-away");
          end;
        end;

        if WhseActivityLine.FindSet then begin

          Clear(WhseActivityLineSum);
          WhseActivityLineSum.CopyFilters(WhseActivityLine);
          if WhseActivityLineSum.FindSet then begin
            repeat
              QtytoHandle := QtytoHandle + WhseActivityLineSum."Qty. to Handle";
              QtyOutstanding := QtyOutstanding + WhseActivityLineSum."Qty. Outstanding";
            until WhseActivityLineSum.Next = 0;

            CurrQtytoHandle := CSWarehouseActivityHandling.Qty;

          end;

          repeat

            if (QtytoHandle < QtyOutstanding) then begin

              FoundedRecToUpdate := true;

              if ((QtytoHandle + CSWarehouseActivityHandling.Qty) > QtyOutstanding) or (CurrQtytoHandle > QtyOutstanding) then begin
                Remark := Text016;
                exit(false);
              end;

              if (WhseActivityLine."Qty. to Handle" < WhseActivityLine."Qty. Outstanding") and (CurrQtytoHandle > 0) then begin

                if (WhseActivityLine."Qty. to Handle" + CurrQtytoHandle) <= WhseActivityLine."Qty. Outstanding" then begin
                  Qty := WhseActivityLine."Qty. to Handle" + CurrQtytoHandle;
                  CurrQtytoHandle := 0;
                end else begin
                  Qty := WhseActivityLine."Qty. Outstanding" - WhseActivityLine."Qty. to Handle";
                  CurrQtytoHandle := CurrQtytoHandle - Qty;
                end;

                WhseActivityLine.Validate("Qty. to Handle", Qty);
                if CSWarehouseActivityHandling."Bin Code" <> '' then
                  WhseActivityLine.Validate("Bin Code",CSWarehouseActivityHandling."Bin Code");
                WhseActivityLine.Modify(true);
                UpdateActivityLine(WhseActivityLine,0);
              end;
            end;

          until (WhseActivityLine.Next = 0) or (CurrQtytoHandle = 0);

          if not FoundedRecToUpdate then begin
            Remark := Text016;
            exit(false);
          end;

        end else begin
          Remark := StrSubstNo(Text021,CSWarehouseActivityHandling."Item No.",CSWarehouseActivityHandling."No.");
          exit(false);
        end;

        exit(true);
    end;

    procedure CheckBalanceQtyToHandle(var WhseActivLine2: Record "Warehouse Activity Line"): Boolean
    var
        WhseActivLine: Record "Warehouse Activity Line";
        WhseActivLine3: Record "Warehouse Activity Line";
        TempWhseActivLine: Record "Warehouse Activity Line" temporary;
        QtyToPick: Decimal;
        QtyToPutAway: Decimal;
        ErrorText: Text[250];
    begin
        WhseActivLine.Copy(WhseActivLine2);
        with WhseActivLine do begin
          SetCurrentKey("Activity Type","No.","Item No.","Variant Code","Action Type");
          SetRange("Activity Type","Activity Type");
          SetRange("No.","No.");
          SetRange("Action Type");
          if FindSet then
            repeat
              if not TempWhseActivLine.Get("Activity Type","No.","Line No.") then begin
                WhseActivLine3.Copy(WhseActivLine);

                WhseActivLine3.SetRange("Item No.","Item No.");
                WhseActivLine3.SetRange("Variant Code","Variant Code");
                WhseActivLine3.SetRange("Serial No.","Serial No.");
                WhseActivLine3.SetRange("Lot No.","Lot No.");

                if (WhseActivLine2."Action Type" = WhseActivLine2."Action Type"::Take) or
                   (WhseActivLine2.GetFilter("Action Type") = '')
                then begin
                  WhseActivLine3.SetRange("Action Type",WhseActivLine3."Action Type"::Take);
                  if WhseActivLine3.FindSet then
                    repeat
                      QtyToPick := QtyToPick + WhseActivLine3."Qty. to Handle (Base)";
                      TempWhseActivLine := WhseActivLine3;
                      TempWhseActivLine.Insert;
                    until WhseActivLine3.Next = 0;
                end;

                if (WhseActivLine2."Action Type" = WhseActivLine2."Action Type"::Place) or
                   (WhseActivLine2.GetFilter("Action Type") = '')
                then begin
                  WhseActivLine3.SetRange("Action Type",WhseActivLine3."Action Type"::Place);
                  if WhseActivLine3.FindSet then
                    repeat
                      QtyToPutAway := QtyToPutAway + WhseActivLine3."Qty. to Handle (Base)";
                      TempWhseActivLine := WhseActivLine3;
                      TempWhseActivLine.Insert;
                    until WhseActivLine3.Next = 0;
                end;

                if QtyToPick <> QtyToPutAway then begin
                  if (WhseActivLine3.GetFilter("Serial No.") <> '') or
                     (WhseActivLine3.GetFilter("Lot No.") <> '')
                  then
                    Remark :=
                      StrSubstNo(
                        Text023,
                        FieldCaption("Item No."),"Item No.",
                        FieldCaption("Variant Code"),"Variant Code",
                        FieldCaption("Lot No."),"Lot No.",
                        FieldCaption("Serial No."),"Serial No.",
                        QtyToPick,QtyToPutAway)
                  else
                    Remark :=
                      StrSubstNo(
                        Text024,
                        FieldCaption("Item No."),"Item No.",FieldCaption("Variant Code"),
                        "Variant Code",QtyToPick,QtyToPutAway);
                  exit(false);
                end;

                QtyToPick := 0;
                QtyToPutAway := 0;
              end;
            until Next = 0;
        end;
        exit(true);
    end;

    procedure SplitLine(var WhseActivLine: Record "Warehouse Activity Line")
    var
        NewWhseActivLine: Record "Warehouse Activity Line";
        LineSpacing: Integer;
        Location: Record Location;
        WMSMgt: Codeunit "WMS Management";
    begin
        if WhseActivLine."Qty. to Handle" = 0 then begin
          Remark := StrSubstNo(Text025,WhseActivLine.FieldCaption("Qty. to Handle"));
          exit;
        end;

        if WhseActivLine."Activity Type" = WhseActivLine."Activity Type"::"Put-away" then begin
          if WhseActivLine."Breakbulk No." <> 0 then
            Error(Text007);
          WhseActivLine.TestField("Action Type",WhseActivLine."Action Type"::Place);
        end;
        if WhseActivLine."Qty. to Handle" = WhseActivLine."Qty. Outstanding" then begin
          Remark := StrSubstNo(Text003,WhseActivLine.FieldCaption("Qty. to Handle"),WhseActivLine.FieldCaption("Qty. Outstanding"));
          exit;
        end;
        NewWhseActivLine := WhseActivLine;
        NewWhseActivLine.SetRange("No.",WhseActivLine."No.");
        if NewWhseActivLine.Find('>') then
          LineSpacing :=
            (NewWhseActivLine."Line No." - WhseActivLine."Line No.") div 2
        else
          LineSpacing := 10000;

        NewWhseActivLine.Reset;
        NewWhseActivLine.Init;
        NewWhseActivLine := WhseActivLine;
        NewWhseActivLine."Line No." := NewWhseActivLine."Line No." + LineSpacing;
        NewWhseActivLine.Quantity :=
          WhseActivLine."Qty. Outstanding" - WhseActivLine."Qty. to Handle";
        NewWhseActivLine."Qty. (Base)" :=
          WhseActivLine."Qty. Outstanding (Base)" - WhseActivLine."Qty. to Handle (Base)";
        NewWhseActivLine."Qty. Outstanding" := NewWhseActivLine.Quantity;
        NewWhseActivLine."Qty. Outstanding (Base)" := NewWhseActivLine."Qty. (Base)";
        NewWhseActivLine."Qty. to Handle" := 0;
        NewWhseActivLine."Qty. to Handle (Base)" := 0;
        NewWhseActivLine."Qty. Handled" := 0;
        NewWhseActivLine."Qty. Handled (Base)" := 0;

        NewWhseActivLine.Validate("Qty. to Handle",0);
        NewWhseActivLine.Validate("Bin Code",'');

        GetLocation(WhseActivLine."Location Code");
        if Location."Directed Put-away and Pick" then begin
          WMSMgt.CalcCubageAndWeight(
            NewWhseActivLine."Item No.",NewWhseActivLine."Unit of Measure Code",
            NewWhseActivLine."Qty. to Handle",NewWhseActivLine.Cubage,NewWhseActivLine.Weight);
          if not
             (((NewWhseActivLine."Activity Type" = NewWhseActivLine."Activity Type"::"Put-away") and
               (NewWhseActivLine."Action Type" = NewWhseActivLine."Action Type"::Take)) or
              ((NewWhseActivLine."Activity Type" = NewWhseActivLine."Activity Type"::Pick) and
               (NewWhseActivLine."Action Type" = NewWhseActivLine."Action Type"::Place)) or
              (WhseActivLine."Breakbulk No." <> 0))
          then begin
            NewWhseActivLine."Zone Code" := '';
            NewWhseActivLine."Bin Code" := '';
          end;
        end;
        NewWhseActivLine.Insert;

        WhseActivLine.Quantity := WhseActivLine."Qty. to Handle" + WhseActivLine."Qty. Handled";
        WhseActivLine."Qty. (Base)" :=
          WhseActivLine."Qty. to Handle (Base)" + WhseActivLine."Qty. Handled (Base)";
        WhseActivLine."Qty. Outstanding" := WhseActivLine."Qty. to Handle";
        WhseActivLine."Qty. Outstanding (Base)" := WhseActivLine."Qty. to Handle (Base)";
        if Location."Directed Put-away and Pick" then
          WMSMgt.CalcCubageAndWeight(
            WhseActivLine."Item No.",WhseActivLine."Unit of Measure Code",
            WhseActivLine."Qty. to Handle",WhseActivLine.Cubage,WhseActivLine.Weight);
        WhseActivLine.Modify;
    end;

    local procedure GetLocation(LocationCode: Code[10])
    var
        Location: Record Location;
    begin
        if LocationCode = '' then
          Clear(Location)
        else
          if Location.Code <> LocationCode then
            Location.Get(LocationCode);
    end;

    local procedure CalcBaseQty(var WhseActivLine: Record "Warehouse Activity Line";Qty: Decimal): Decimal
    begin
        WhseActivLine.TestField("Qty. per Unit of Measure");
        exit(Round(Qty * WhseActivLine."Qty. per Unit of Measure",0.00001));
    end;

    local procedure UpdateActivityLine(WhseActivityLine: Record "Warehouse Activity Line";ActionToTake: Option Increase,Decrease)
    var
        WhseActivityLineUpdate: Record "Warehouse Activity Line";
        UpdateActionType: Integer;
        QtyToHandle: Decimal;
    begin
        if WhseActivityLine."Action Type" = WhseActivityLine."Action Type"::" " then
          exit;
        case WhseActivityLine."Action Type" of
          WhseActivityLine."Action Type"::Place:
            UpdateActionType := WhseActivityLine."Action Type"::Take;
          WhseActivityLine."Action Type"::Take:
            UpdateActionType := WhseActivityLine."Action Type"::Place;
        end;

        WhseActivityLine.SetRange("Activity Type",WhseActivityLine."Activity Type");
        WhseActivityLine.SetRange("No.",WhseActivityLine."No.");
        WhseActivityLine.SetRange("Source Type",WhseActivityLine."Source Type");
        WhseActivityLine.SetRange("Source Subtype",WhseActivityLine."Source Subtype");
        WhseActivityLine.SetRange("Source No.",WhseActivityLine."Source No.");
        WhseActivityLine.SetRange("Source Line No.",WhseActivityLine."Source Line No.");
        WhseActivityLine.SetRange("Action Type",WhseActivityLine."Action Type");
        if WhseActivityLine.FindSet then
          repeat
            QtyToHandle += WhseActivityLine."Qty. to Handle";
          until WhseActivityLine.Next = 0;

        if ActionToTake = ActionToTake::Decrease then
          QtyToHandle := -1 * QtyToHandle;

        WhseActivityLineUpdate.SetRange("Activity Type",WhseActivityLine."Activity Type");
        WhseActivityLineUpdate.SetRange("No.",WhseActivityLine."No.");
        WhseActivityLineUpdate.SetRange("Source Type",WhseActivityLine."Source Type");
        WhseActivityLineUpdate.SetRange("Source Subtype",WhseActivityLine."Source Subtype");
        WhseActivityLineUpdate.SetRange("Source No.",WhseActivityLine."Source No.");
        WhseActivityLineUpdate.SetRange("Source Line No.",WhseActivityLine."Source Line No.");
        WhseActivityLineUpdate.SetRange("Action Type",UpdateActionType);
        if WhseActivityLineUpdate.FindFirst then begin
          WhseActivityLineUpdate.Validate("Qty. to Handle",QtyToHandle);
          WhseActivityLineUpdate.Modify(true);
        end;
    end;

    [EventSubscriber(ObjectType::Table, 7317, 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsertWhseReceiptLine(var Rec: Record "Warehouse Receipt Line";RunTrigger: Boolean)
    var
        CSSetup: Record "CS Setup";
    begin
        if Rec.IsTemporary then
          exit;

        if not CSSetup.Get then
          exit;

        if not CSSetup."Zero Def. Qty. to Handle" then
          exit;

        Rec.Validate("Qty. to Receive",0);
        Rec.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 7313, 'OnAfterWhseActivLineInsert', '', true, true)]
    local procedure CreatePutAwayOnAfterWhseActivLineInsert(var WarehouseActivityLine: Record "Warehouse Activity Line")
    var
        CSSetup: Record "CS Setup";
    begin
        if not CSSetup.Get then
          exit;
        if not CSSetup."Zero Def. Qty. to Handle" then
          exit;
        WarehouseActivityLine.Validate("Qty. to Handle",0);
        WarehouseActivityLine.Modify(true);
    end;

    local procedure ClearDataLine(var CSWarehouseActivityHandling: Record "CS Warehouse Activity Handling")
    var
        LineNo: Integer;
        CSUIHeader: Record "CS UI Header";
    begin
        if CSUIHeader.Get(CurrentCode) then
          if not CSUIHeader."Set defaults from last record" then
            CSWarehouseActivityHandling.Qty := 1;

        CSWarehouseActivityHandling."Item No." := '';
        CSWarehouseActivityHandling."Variant Code" := '';
        CSWarehouseActivityHandling."Serial No." := '';
        CSWarehouseActivityHandling."Shelf No." := '';
        CSWarehouseActivityHandling."Lot No." := '';
        CSWarehouseActivityHandling."Bin Code" := '';
        CSWarehouseActivityHandling."Bin Base Qty." := 0;
        CSWarehouseActivityHandling."Unit of Measure" := '';
        CSWarehouseActivityHandling.Barcode := '';
        CSWarehouseActivityHandling.Handled := false;
        CSWarehouseActivityHandling."Transferred to Document" := false;

        CSWarehouseActivityHandling.Modify(true);
    end;
}

