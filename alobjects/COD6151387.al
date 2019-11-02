codeunit 6151387 "CS UI Warehouse Activity"
{
    // NPR5.41/CLVA/20180313 CASE 306407 Object created - NP Capture Service
    // NPR5.43/CLVA/20180604 CASE 304872 Added previous value to qty
    // NPR5.48/CLVA/20181109 CASE 335606 Handling Splitline, UOM and Outstanding Qty. Added function SplitLine
    // NPR5.49/TJ  /20190215 CASE 346070 Line created with SplitLine also has Qty. to Handle = 0
    //                                   Place line also updates Take line
    // NPR5.49/TJ  /20190220 CASE 346066 Qty. to Receive is set to 0 when created from Purchase Line
    //                                   Qty. to Handle is set to 0 when created from receipt
    // NPR5.49/TJ  /20190221 CASE 346224 Variant Code displayed for other indicators as well
    // NPR5.49/CLVA/20190327 CASE 349554 Added option to expand or collaps summary items
    // NPR5.50/TJ  /20190325 CASE 349530 Fixed an issue with UpdateTakeLine when quantity is increased
    // NPR5.50/CLVA/20190425 CASE 247747 Added Text Constant "Text027"
    //                                   Addded default value handling
    //                                   Added sorting key on AddSummarize
    //                                   Added functionality to fulfilled lines
    // NPR5.50/CLVA/20190426 CASE 347971 Added Posting options
    //                                   Changed default posting for "Invt. Pick" and "Invt. Put-away" to "Ship & Invoice"
    // NPR5.50/TJ  /20190417 CASE 351937 Blank InnerText is causing app to crash so have commented it out
    // NPR5.50/CLVA/20190515 CASE 351937 Case 351937 is not an error but TJ using a old app version. Code uncomment again.
    // NPR5.51/CLVA/20190612 CASE 357577 Added posting date functionality
    // NPR5.51/CLVA/20190628 CASE 360425 Summarizing qty
    // NPR5.51/CLVA/20190619 CASE 359268 Added receive posting.
    // NPR5.52/CLVA/20190904 CASE 365967 Added support for Job Queue Posting and setup "Sum Qty. to Handle"
    // NPR5.52/CLVA/20191010 CASE 370452 Changed posting functionality
    // NPR5.52/TJ  /20191010 CASE 371682 Renamed function UpdateTakeLine to UpdateActivityLine and removed parameter QtyToHandle
    //                                   Updating both Place and Take lines
    //                                   Fixed suggested quantity after scan
    //                                   Fixed quantity assign on split lines

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
                  'SPLITLINE':
                  begin
                    Evaluate(FuncTableNo,CSCommunication.GetNodeAttribute(ReturnedNode,'FuncTableNo'));
                    FuncRecRef.Open(FuncTableNo);
                    Evaluate(FuncRecId,CSCommunication.GetNodeAttribute(ReturnedNode,'FuncRecordID'));
                    if FuncRecRef.Get(FuncRecId) then begin
                      FuncRecRef.SetTable(WhseActivityLine);
                      //-NPR5.48 [335606]
                      //WhseActivityLine.SplitLine(WhseActivityLine);
                      SplitLine(WhseActivityLine);
                      //+NPR5.48 [335606]
                    end;
                  end;
                end;
              end;
          FuncGroup.KeyDef::Reset:
            Reset(CSWarehouseActivityHandling);
          FuncGroup.KeyDef::Register:
            begin
              //-NPR5.48 [335606]
              if not Evaluate(ActionIndex,CSCommunication.GetNodeAttribute(ReturnedNode,'ActionIndex')) then
                //-NPR5.50 [347971]
                //ActionIndex := 1;
                //ActionIndex := 2;
                //-NPR5.52 [370452]
                ActionIndex := MiniformHeader."Posting Type" + 1;
                //+NPR5.52 [370452]
                //+NPR5.50 [347971]
              //+NPR5.48 [335606]
              Register(CSWarehouseActivityHandling,ActionIndex);
              if Remark = '' then begin
                DeleteEmptyDataLines();
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

              CSWarehouseActivityHandling.Modify;

              RecRef.GetTable(CSWarehouseActivityHandling);
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
                      RecRef.SetTable(CSWarehouseActivityHandling);
                      RecRef.SetRecFilter;
                      CSCommunication.SetRecRef(RecRef);
                    until CSFieldDefaults.Next = 0;
                  end;

                  UpdateDataLine(CSWarehouseActivityHandling);
                  CreateDataLine(CSWarehouseActivityHandling2,CSWarehouseActivityHandling);
                  RecRef.GetTable(CSWarehouseActivityHandling2);
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

        DeleteEmptyDataLines();
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

        //-NPR5.50 [347971]
        //-NPR5.52 [370452]
        //IF MiniformHeader."Add Posting Options" THEN
        if MiniformHeader."Posting Type" = MiniformHeader."Posting Type"::"Handle & Invoice" then
        //+NPR5.52 [370452]
        //+NPR5.50 [347971]
          AddAdditionalInfo(DOMxmlin,CSWarehouseActivityHandling);

        if AddSummarize(Records) then
          DOMxmlin.DocumentElement.AppendChild(Records);

        //MiniformHeader.SaveXMLin(DOMxmlin);

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

          //-NPR5.48 [335606]
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
          //+NPR5.48 [335606]

        end else begin
          Remark := StrSubstNo(Text010,InputValue);
          exit;
        end;

        //-NPR5.52 [365967]
        CSSetup.Get;
        if CSSetup."Sum Qty. to Handle" then begin
        //+NPR5.52 [365967]
          //-#360425 [360425]
          QtytoHandle := 0;
          QtyOutstanding := 0;

          WhseActivityLine.SetCurrentKey("Activity Type","No.","Sorting Sequence No.");
          WhseActivityLine.SetRange("Activity Type",CSWarehouseActivityHandling."Activity Type");
          WhseActivityLine.SetRange("No.",CSWarehouseActivityHandling."No.");
          WhseActivityLine.SetRange("Item No.",CSWarehouseActivityHandling."Item No.");
          WhseActivityLine.SetRange("Variant Code",CSWarehouseActivityHandling."Variant Code");
          //-NPR5.52 [371682]
          case CSWarehouseActivityHandling."Activity Type" of
            CSWarehouseActivityHandling."Activity Type"::Pick:
              WhseActivityLine.SetRange("Action Type",WhseActivityLine."Action Type"::Take);
            CSWarehouseActivityHandling."Activity Type"::"Put-away":
              WhseActivityLine.SetRange("Action Type",WhseActivityLine."Action Type"::Place);
          end;
          //+NPR5.52 [371682]
          if WhseActivityLine.FindSet then begin
            repeat
              QtytoHandle := QtytoHandle + WhseActivityLine."Qty. to Handle";
              QtyOutstanding := QtyOutstanding + WhseActivityLine."Qty. Outstanding";
            until WhseActivityLine.Next = 0;

            CSWarehouseActivityHandling.Qty := QtyOutstanding - QtytoHandle;

          end;
          //+#360425 [360425]
        //-NPR5.52 [365967]
        end;
        //+NPR5.52 [365967]

        CSWarehouseActivityHandling.Barcode := InputValue;
    end;

    local procedure CheckQty(var CSWarehouseActivityHandling: Record "CS Warehouse Activity Handling";InputValue: Text)
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

        if (StrLen(InputValue) > MaxStrLen(Bin.Code)) then begin
          Remark := Text008;
          exit;
        end;

        if not Bin.Get(CSWarehouseActivityHandling."Location Code",InputValue) then begin
          Remark := StrSubstNo(Text017,InputValue);
          exit;
        end;

        CSWarehouseActivityHandling."Bin Code" := InputValue;
    end;

    local procedure CreateDataLine(var CSWarehouseActivityHandling: Record "CS Warehouse Activity Handling";RecordVariant: Variant)
    var
        NewCSWarehouseActivityHandling: Record "CS Warehouse Activity Handling";
        LineNo: Integer;
        RecRefByVariant: RecordRef;
        CSWarehouseActivityHandlingByVar: Record "CS Warehouse Activity Handling";
        WarehouseActivityHeaderByVar: Record "Warehouse Activity Header";
        CSUIHeader: Record "CS UI Header";
    begin
        if not RecordVariant.IsRecord then
          Error(Text020);

        Clear(NewCSWarehouseActivityHandling);
        NewCSWarehouseActivityHandling.SetRange(Id, CSSessionId);
        if NewCSWarehouseActivityHandling.FindLast then
          LineNo := NewCSWarehouseActivityHandling."Line No." + 1
        else
          LineNo := 1;

        CSWarehouseActivityHandling.Init;
        CSWarehouseActivityHandling.Id := CSSessionId;
        CSWarehouseActivityHandling."Line No." := LineNo;
        CSWarehouseActivityHandling."Created By" := UserId;
        CSWarehouseActivityHandling.Created := CurrentDateTime;

        //-NPR5.50 [247747]
        if CSUIHeader.Get(CurrentCode) then begin
          if CSUIHeader."Set defaults from last record" then begin
        //+NPR5.50 [247747]
          //-NPR5.43 [304872]
          CSWarehouseActivityHandling.Qty := NewCSWarehouseActivityHandling.Qty;
          //+NPR5.43 [304872]
        //-NPR5.50 [247747]
          end;
        end;
        //+NPR5.50 [247747]

        RecRefByVariant.GetTable(RecordVariant);

        CSWarehouseActivityHandling."Table No." := RecRefByVariant.Number;

        if RecRefByVariant.Number = 5766 then begin
          WarehouseActivityHeaderByVar := RecordVariant;
          CSWarehouseActivityHandling."Activity Type" := WarehouseActivityHeaderByVar.Type;
          CSWarehouseActivityHandling."No." := WarehouseActivityHeaderByVar."No.";
          CSWarehouseActivityHandling."Assignment Date" := WarehouseActivityHeaderByVar."Assignment Date";
          CSWarehouseActivityHandling."Record Id" := WarehouseActivityHeaderByVar.RecordId;
          CSWarehouseActivityHandling."Location Code" := WarehouseActivityHeaderByVar."Location Code";
        end else begin
          CSWarehouseActivityHandlingByVar := RecordVariant;
          CSWarehouseActivityHandling."Activity Type" := CSWarehouseActivityHandlingByVar."Activity Type";
          CSWarehouseActivityHandling."No." := CSWarehouseActivityHandlingByVar."No.";
          CSWarehouseActivityHandling."Assignment Date" := CSWarehouseActivityHandlingByVar."Assignment Date";
          CSWarehouseActivityHandling."Record Id" := CSWarehouseActivityHandlingByVar.RecordId;
          CSWarehouseActivityHandling."Location Code" := CSWarehouseActivityHandlingByVar."Location Code";
        end;

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

    local procedure DeleteEmptyDataLines()
    var
        CSWarehouseActivityHandling: Record "CS Warehouse Activity Handling";
    begin
        CSWarehouseActivityHandling.SetRange(Id,CSSessionId);
        CSWarehouseActivityHandling.SetRange(Handled,false);
        CSWarehouseActivityHandling.SetRange("Transferred to Document",false);
        CSWarehouseActivityHandling.DeleteAll(true);
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

        //-NPR5.50 [247747]
        if Location.Get(CSWarehouseActivityHandling."Location Code") then
          BinIsMandatory := Location."Bin Mandatory";

        if BinIsMandatory then
          WhseActivityLine.SetCurrentKey("Bin Code","Location Code","Action Type","Breakbulk No.");
        //+NPR5.50 [247747]

        WhseActivityLine.SetRange("No.",CSWarehouseActivityHandling."No.");
        WhseActivityLine.SetRange("Activity Type",CSWarehouseActivityHandling."Activity Type");

        //-NPR5.50 [247747]
        //IF Location.GET(CSWarehouseActivityHandling."Location Code") THEN
        //  BinIsMandatory := Location."Bin Mandatory";
        //+NPR5.50 [247747]

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
              //-NPR5.49 [349554]
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
                //-NPR5.50 [247747]
                if WhseActivityLine."Variant Code" <> '' then
                  Line.InnerText := StrSubstNo(Text027,WhseActivityLine."Item No.",WhseActivityLine."Variant Code")
                else
                //-NPR5.50 [247747]
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
                //-NPR5.50 [351937]
                Line := DOMxmlin.CreateElement('Line');
                AddAttribute(Line,'Descrip','');
                AddAttribute(Line,'Type',Format(LineType::TEXT));
                Line.InnerText := '';
                Record.AppendChild(Line);
                //+NPR5.50 [351937]

                //-NPR5.48 [335606]
                if Location.Get(WhseActivityLine."Location Code") then
                  if Location."Bin Mandatory" then begin
                //+NPR5.48 [335606]
                    Line := DOMxmlin.CreateElement('Line');
                    AddAttribute(Line,'Descrip','Split Line..');
                    AddAttribute(Line,'Type',Format(LineType::BUTTON));
                    AddAttribute(Line,'TableNo',Format(TableNo));
                    AddAttribute(Line,'RecordID',Format(CurrRecordID));
                    AddAttribute(Line,'FuncName','SPLITLINE');
                    Record.AppendChild(Line);
                //-NPR5.48 [335606]
                end;
                //+NPR5.48 [335606]

              end else begin
              //+NPR5.49 [349554]
                Line := DOMxmlin.CreateElement('Line');
                AddAttribute(Line,'Descrip',WhseActivityLine.FieldCaption(Description));
                AddAttribute(Line,'Indicator',Indicator);
                AddAttribute(Line,'Type',Format(LineType::TEXT));
                //-NPR5.49 [349554]
                AddAttribute(Line,'CollapsItems','TRUE');
                //+NPR5.49 [349554]
                //-NPR5.49 [346224]
                if WhseActivityLine."Variant Code" <> '' then
                  Line.InnerText := StrSubstNo(Text015,WhseActivityLine."Qty. to Handle",WhseActivityLine."Qty. Outstanding",WhseActivityLine."Item No."+'-'+WhseActivityLine."Variant Code",WhseActivityLine.Description)
                else
                //+NPR5.49 [346224]
                Line.InnerText := StrSubstNo(Text015,WhseActivityLine."Qty. to Handle",WhseActivityLine."Qty. Outstanding",WhseActivityLine."Item No.",WhseActivityLine.Description);
                Record.AppendChild(Line);

                //-NPR5.48 [335606]
                if Location.Get(WhseActivityLine."Location Code") then
                  if Location."Bin Mandatory" then begin
                //+NPR5.48 [335606]
                    Line := DOMxmlin.CreateElement('Line');
                    AddAttribute(Line,'Descrip','Split Line..');
                    AddAttribute(Line,'Type',Format(LineType::BUTTON));
                    AddAttribute(Line,'TableNo',Format(TableNo));
                    AddAttribute(Line,'RecordID',Format(CurrRecordID));
                    AddAttribute(Line,'FuncName','SPLITLINE');
                    Record.AppendChild(Line);
                //-NPR5.48 [335606]
                end;
                //+NPR5.48 [335606]
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
              //-NPR5.49 [349554]
              end;
              //+NPR5.49 [349554]
              Records.AppendChild(Record);
            end;
          until WhseActivityLine.Next = 0;

          //-NPR5.50 [247747]
          if not MiniformHeader."Hid Fulfilled Lines" then begin
          //+NPR5.50 [247747]
            if WhseActivityLine.FindSet then begin
              //Records := DOMxmlin.CreateElement('Records');
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
                  //-NPR5.49 [349554]
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
                    //-NPR5.50 [247747]
                    if WhseActivityLine."Variant Code" <> '' then
                      Line.InnerText := StrSubstNo(Text027,WhseActivityLine."Item No.",WhseActivityLine."Variant Code")
                    else
                    //-NPR5.50 [247747]
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

                    //-NPR5.48 [335606]
                    if Location.Get(WhseActivityLine."Location Code") then
                      if Location."Bin Mandatory" then begin
                    //+NPR5.48 [335606]
                        Line := DOMxmlin.CreateElement('Line');
                        AddAttribute(Line,'Descrip','Split Line..');
                        AddAttribute(Line,'Type',Format(LineType::BUTTON));
                        AddAttribute(Line,'TableNo',Format(TableNo));
                        AddAttribute(Line,'RecordID',Format(CurrRecordID));
                        AddAttribute(Line,'FuncName','SPLITLINE');
                        Record.AppendChild(Line);
                    //-NPR5.48 [335606]
                    end;
                    //+NPR5.48 [335606]
                  end else begin
                  //+NPR5.49 [349554]
                    Line := DOMxmlin.CreateElement('Line');
                    AddAttribute(Line,'Descrip',WhseActivityLine.FieldCaption(Description));
                    AddAttribute(Line,'Indicator',Indicator);
                    AddAttribute(Line,'Type',Format(LineType::TEXT));
                    //-NPR5.49 [346224]
                    if WhseActivityLine."Variant Code" <> '' then
                      Line.InnerText := StrSubstNo(Text015,WhseActivityLine."Qty. to Handle",WhseActivityLine."Qty. Outstanding",WhseActivityLine."Item No."+'-'+WhseActivityLine."Variant Code",WhseActivityLine.Description)
                    else
                    //+NPR5.49 [346224]
                    Line.InnerText := StrSubstNo(Text015,WhseActivityLine."Qty. to Handle",WhseActivityLine."Qty. Outstanding",WhseActivityLine."Item No.",WhseActivityLine.Description);
                    Record.AppendChild(Line);

                    //-NPR5.48 [335606]
                    if Location.Get(WhseActivityLine."Location Code") then
                      if Location."Bin Mandatory" then begin
                    //+NPR5.48 [335606]
                        Line := DOMxmlin.CreateElement('Line');
                        AddAttribute(Line,'Descrip','Split Line..');
                        AddAttribute(Line,'Type',Format(LineType::BUTTON));
                        AddAttribute(Line,'TableNo',Format(TableNo));
                        AddAttribute(Line,'RecordID',Format(CurrRecordID));
                        AddAttribute(Line,'FuncName','SPLITLINE');
                        Record.AppendChild(Line);
                    //-NPR5.48 [335606]
                    end;
                    //+NPR5.48 [335606]

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
                  //-NPR5.49 [349554]
                  end;
                  //+NPR5.49 [349554]
                  Records.AppendChild(Record);
                end;
              until WhseActivityLine.Next = 0;
             end;
            //-NPR5.50 [247747]
            end;
            //+NPR5.50 [247747]
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
          CSWarehouseActivityHandling."Activity Type"::"Invt. Put-away" : StrMenuTxt := 'Receive,Receive and Invoice';
          //-NPR5.51
          //CSWarehouseActivityHandling."Activity Type"::"Invt. Pick" : StrMenuTxt := 'Ship,Ship and Invoice';
          CSWarehouseActivityHandling."Activity Type"::"Invt. Pick" : StrMenuTxt := 'Ship,Ship and Receive';
          //+NPR5.51
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
              //-NPR5.49 [346070]
              xRecQtyToHandle := WhseActivityLine."Qty. to Handle";
              //+NPR5.49 [346070]
              WhseActivityLine.Validate("Qty. to Handle",0);
              //-NPR5.50 [247747]
              //WhseActivityLine.VALIDATE("Bin Code",'');
              //+NPR5.50 [247747]
              WhseActivityLine.Modify;
              //-NPR5.52 [371682]
              /*
              //-NPR5.49 [346070]
              UpdateTakeLine(WhseActivityLine,xRecQtyToHandle,1);
              //+NPR5.49 [346070]
              */
              UpdateActivityLine(WhseActivityLine,1);
              //+NPR5.52 [371682]
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
    begin
        Remark := '';

        //-NPR5.52 [365967]
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
        //+NPR5.52 [365967]

        WhseActivityLine.SetRange("No.",CSWarehouseActivityHandling."No.");

        if WhseActivityLine.FindSet then begin

          //-#357577 [357577]
          if MiniformHeader."Update Posting Date" then begin
            WarehouseActivityHeader.Get(CSWarehouseActivityHandling."Activity Type",CSWarehouseActivityHandling."No.");
            WarehouseActivityHeader.Validate("Posting Date",Today);
            WarehouseActivityHeader.Modify(true);
          end;
          //+#357577 [357577]

          repeat
            case CSWarehouseActivityHandling."Activity Type" of
              CSWarehouseActivityHandling."Activity Type"::Pick,CSWarehouseActivityHandling."Activity Type"::"Put-away" : begin
                  if CheckBalanceQtyToHandle(WhseActivityLine) then begin
                    WhseActivityRegister.ShowHideDialog(true);
                    WhseActivityRegister.Run(WhseActivityLine);
                  end;
                end;
              CSWarehouseActivityHandling."Activity Type"::"Invt. Pick",CSWarehouseActivityHandling."Activity Type"::"Invt. Put-away" : begin
                  //-#359268 [359268]
                  if WhseActivityLine."Qty. to Handle" <> 0 then begin
                  //+#359268 [359268]
                    WhseActivityPost.SetInvoiceSourceDoc(Index = 2);
                    WhseActivityPost.Run(WhseActivityLine);
                    Clear(WhseActivityPost);
                  //-#359268 [359268]
                  end;
                  //+#359268 [359268]
                end;
            end;
          until WhseActivityLine.Next = 0;
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
        //-NPR5.50 [247747]
        if CSWarehouseActivityHandling."Variant Code" <> '' then
          WhseActivityLine.SetRange("Variant Code",CSWarehouseActivityHandling."Variant Code");
        //+NPR5.50 [247747]
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
        
        //UOM handling
        //    Item.GET(CSWarehouseActivityHandling."Item No.");
        //    IF (CSWarehouseActivityHandling."Unit of Measure" <> '') THEN BEGIN
        //      IF (Item."Base Unit of Measure" <> '') AND (CSWarehouseActivityHandling."Unit of Measure" <> Item."Base Unit of Measure") THEN BEGIN
        //        IF ItemUnitofMeasure.GET(Item."No.",CSWarehouseActivityHandling."Unit of Measure") THEN
        //          CurrQtytoHandle := CalcBaseQty(WhseActivityLine,ItemUnitofMeasure."Qty. per Unit of Measure");
        //      END;
        //    END;
        
          end;
        
          repeat
        
            //IF (WhseActivityLine."Qty. to Handle" < WhseActivityLine."Qty. Outstanding") THEN BEGIN
            if (QtytoHandle < QtyOutstanding) then begin
        
        //-NPR5.50 [247747]
        //      IF (CSWarehouseActivityHandling."Bin Code" <> WhseActivityLine."Bin Code") AND (WhseActivityLine."Bin Code" <> '') THEN BEGIN
        //        //ERROR(Text018,WhseActivityLine."Bin Code");
        //        Remark := STRSUBSTNO(Text018,WhseActivityLine."Bin Code");
        //        EXIT(FALSE);
        //      END;
        //+NPR5.50 [247747]
        
              FoundedRecToUpdate := true;
        
              //IF (WhseActivityLine."Qty. to Handle" + CSWarehouseActivityHandling.Qty) > WhseActivityLine."Qty. Outstanding" THEN BEGIN
              if ((QtytoHandle + CSWarehouseActivityHandling.Qty) > QtyOutstanding) or (CurrQtytoHandle > QtyOutstanding) then begin
                //-NPR5.48 [335606]
                //Qty := WhseActivityLine."Qty. Outstanding"
                Remark := Text016;
                exit(false);
                //-NPR5.48 [335606]
              end;// ELSE
        
        //      ERROR('QtytoHandle: ' + FORMAT(QtytoHandle) +
        //          '\' + 'QtyOutstanding: ' + FORMAT(QtyOutstanding) +
        //          '\' + 'CurrQtytoHandle: ' + FORMAT(CurrQtytoHandle));
        
              if (WhseActivityLine."Qty. to Handle" < WhseActivityLine."Qty. Outstanding") and (CurrQtytoHandle > 0) then begin
        
                //IF (WhseActivityLine."Qty. to Handle" + CSWarehouseActivityHandling.Qty) <= WhseActivityLine."Qty. Outstanding" THEN BEGIN
                if (WhseActivityLine."Qty. to Handle" + CurrQtytoHandle) <= WhseActivityLine."Qty. Outstanding" then begin
                  //-NPR5.52 [371682]
                  /*
                  //-NPR5.50 [247747]
                  //IF CurrQtytoHandle > 0 THEN BEGIN
                  //  Qty := CurrQtytoHandle;
                  //  CurrQtytoHandle := 0;
                  //END ELSE BEGIN
                    Qty := WhseActivityLine."Qty. to Handle" + CSWarehouseActivityHandling.Qty;
                    CurrQtytoHandle := CurrQtytoHandle - CSWarehouseActivityHandling.Qty;
                  //END;
                  //+NPR5.50 [247747]
                  */
                  Qty := WhseActivityLine."Qty. to Handle" + CurrQtytoHandle;
                  CurrQtytoHandle := 0;
                  //+NPR5.52 [371682]
                end else begin
                  Qty := WhseActivityLine."Qty. Outstanding" - WhseActivityLine."Qty. to Handle";
                  CurrQtytoHandle := CurrQtytoHandle - Qty;
                end;
        
        //        ERROR('QtytoHandle: ' + FORMAT(QtytoHandle) +
        //          '\' + 'QtyOutstanding: ' + FORMAT(QtyOutstanding) +
        //          '\' + 'Qty: ' + FORMAT(Qty) +
        //          '\' + 'CurrQtytoHandle: ' + FORMAT(CurrQtytoHandle) +
        //          '\' + 'CSWarehouseActivityHandling.Qty: ' + FORMAT(CSWarehouseActivityHandling.Qty));
        
                WhseActivityLine.Validate("Qty. to Handle", Qty);
                //-NPR5.50 [247747]
                if CSWarehouseActivityHandling."Bin Code" <> '' then
                  WhseActivityLine.Validate("Bin Code",CSWarehouseActivityHandling."Bin Code");
                //-NPR5.50 [247747]
                WhseActivityLine.Modify(true);
                //-NPR5.52 [371682]
                /*
                //-NPR5.49 [346070]
                UpdateTakeLine(WhseActivityLine,WhseActivityLine."Qty. to Handle",0);
                //+NPR5.49 [346070]
                */
                UpdateActivityLine(WhseActivityLine,0);
                //+NPR5.52 [371682]
              end;
            end;
        
          //UNTIL (WhseActivityLine.NEXT = 0) OR FoundedRecToUpdate;
          until (WhseActivityLine.Next = 0) or (CurrQtytoHandle = 0);
        
          if not FoundedRecToUpdate then begin
            //-NPR5.48 [335606]
            //ERROR(Text016);
            Remark := Text016;
            exit(false);
            //-NPR5.48 [335606]
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
          //WhseActivLine.FIELDERROR(
          //  "Qty. to Handle",STRSUBSTNO(Text003,WhseActivLine.FIELDCAPTION("Qty. Outstanding")));
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
        //-NPR5.49 [346070]
        /*
        NewWhseActivLine."Qty. to Handle" := NewWhseActivLine.Quantity;
        NewWhseActivLine."Qty. to Handle (Base)" := NewWhseActivLine."Qty. (Base)";
        */
        NewWhseActivLine."Qty. to Handle" := 0;
        NewWhseActivLine."Qty. to Handle (Base)" := 0;
        //+NPR5.49 [346070]
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
        //-NPR5.52 [371682]
        /*
        //-NPR5.50 [348151]
        IF NOT (WhseActivityLine."Action Type" = WhseActivityLine."Action Type"::Place) THEN
          EXIT;
        //+NPR5.50 [348151]
        
        //-NPR5.49 [346070]
        IF ActionToTake = ActionToTake::Decrease THEN
          QtyToHandle := -1 * QtyToHandle;
        WhseActivityLineTake.SETRANGE("Activity Type",WhseActivityLine."Activity Type");
        WhseActivityLineTake.SETRANGE("No.",WhseActivityLine."No.");
        WhseActivityLineTake.SETRANGE("Source Type",WhseActivityLine."Source Type");
        WhseActivityLineTake.SETRANGE("Source Subtype",WhseActivityLine."Source Subtype");
        WhseActivityLineTake.SETRANGE("Source No.",WhseActivityLine."Source No.");
        WhseActivityLineTake.SETRANGE("Source Line No.",WhseActivityLine."Source Line No.");
        WhseActivityLineTake.SETRANGE("Action Type",WhseActivityLineTake."Action Type"::Take);
        IF WhseActivityLineTake.FINDFIRST THEN BEGIN
          //-NPR5.50 [349530]
          IF ActionToTake = ActionToTake::Increase THEN
            WhseActivityLineTake.VALIDATE("Qty. to Handle",QtyToHandle)
          ELSE
          //-NPR5.50 [349530]
            WhseActivityLineTake.VALIDATE("Qty. to Handle",WhseActivityLineTake."Qty. to Handle" + QtyToHandle);
          WhseActivityLineTake.MODIFY(TRUE);
        END;
        //+NPR5.49 [346070]
        */
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
        //+NPR5.52 [371682]

    end;

    [EventSubscriber(ObjectType::Table, 7317, 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsertWhseReceiptLine(var Rec: Record "Warehouse Receipt Line";RunTrigger: Boolean)
    var
        CSSetup: Record "CS Setup";
    begin
        //-NPR5.50 [346066]
        if Rec.IsTemporary then
          exit;
        if not CSSetup.Get then
          exit;
        if not CSSetup."Zero Def. Qty. to Handle" then
          exit;
        Rec.Validate("Qty. to Receive",0);
        Rec.Modify(true);
        //+NPR5.50 [346066]
    end;

    [EventSubscriber(ObjectType::Codeunit, 7313, 'OnAfterWhseActivLineInsert', '', true, true)]
    local procedure CreatePutAwayOnAfterWhseActivLineInsert(var WarehouseActivityLine: Record "Warehouse Activity Line")
    var
        CSSetup: Record "CS Setup";
    begin
        //-NPR5.50 [346066]
        if not CSSetup.Get then
          exit;
        if not CSSetup."Zero Def. Qty. to Handle" then
          exit;
        WarehouseActivityLine.Validate("Qty. to Handle",0);
        WarehouseActivityLine.Modify(true);
        //+NPR5.50 [346066]
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

