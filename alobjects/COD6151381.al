codeunit 6151381 "CS UI Whse. Activity"
{
    // NPR5.41/CLVA/20180313 CASE 306407 Object created - NP Capture Service
    // NPR5.43/NPKNAV/20180629  CASE 304872 Transport NPR5.43 - 29 June 2018
    // NPR5.48/CLVA  /20181109  CASE 335606 Handling Splitline and UOM

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
        CSManagement: Codeunit "CS Management";
        RecRef: RecordRef;
        DOMxmlin: DotNet XmlDocument;
        ReturnedNode: DotNet XmlNode;
        RootNode: DotNet XmlNode;
        CSUserId: Text[250];
        Remark: Text[250];
        WhseEmpId: Text[250];
        LocationFilter: Text[250];
        CurrentCode: Text[250];
        StackCode: Text[250];
        ActiveInputField: Integer;
        MiniformHeader2: Record "CS UI Header";
        Text000: Label 'Function not Found.';
        Text002: Label 'Failed to add the attribute: %1.';
        Text004: Label 'Invalid %1.';
        Text005: Label '%1 = ''%2'', %3 = ''%4'':\The total base quantity to take %5 must be equal to the total base quantity to place %6.';
        Text006: Label 'No input Node found.';
        Text007: Label 'Record not found.';
        Text008: Label 'End of Document.';
        Text009: Label 'Qty. does not match.';
        Text011: Label 'Invalid Quantity.';
        Text012: Label 'No Lines available.';
        Text013: Label 'Item %1 not found on doc. %2';
        Text014: Label 'Item %1 doesn''t exist';
        Text015: Label '%1/%2 : %3 %4';
        Text016: Label 'Qty. to Handle exceed Outstanding Qty.';
        Text017: Label 'Bin Code %1 is not valid';
        Text018: Label 'Bin Code %1 is already selected for this line';
        CSSessionId: Text;
        Text019: Label '%1 = ''%2'', %3 = ''%4'', %5 = ''%6'', %7 = ''%8'': The total base quantity to take %9 must be equal to the total base quantity to place %10.';

    local procedure ProcessInput()
    var
        WhseActivityHeader: Record "Warehouse Activity Header";
        WhseActivityLine: Record "Warehouse Activity Line";
        FuncGroup: Record "CS UI Function Group";
        RecId: RecordID;
        TextValue: Text[250];
        TableNo: Integer;
        FldNo: Integer;
        Lookup: Integer;
        Item: Record Item;
        BarcodeLibrary: Codeunit "Barcode Library";
        ItemNo2: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
        BinCode: Text;
        Bin: Record Bin;
        FoundedRecToUpdate: Boolean;
        Qty: Integer;
        QtyTxt: Text;
        QtyVal: Integer;
        FuncRecId: RecordID;
        FuncTableNo: Integer;
        FuncRecRef: RecordRef;
        ItemCrossReference: Record "Item Cross Reference";
    begin
        if XMLDOMMgt.FindNode(RootNode,'Header/Input',ReturnedNode) then
          TextValue := ReturnedNode.InnerText
        else
          Error(Text006);

        Evaluate(TableNo,CSCommunication.GetNodeAttribute(ReturnedNode,'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId,CSCommunication.GetNodeAttribute(ReturnedNode,'RecordID'));
        if RecRef.Get(RecId) then begin
          RecRef.SetTable(WhseActivityHeader);
          CSCommunication.SetRecRef(RecRef);
        end else begin
          CSCommunication.RunPreviousUI(DOMxmlin);
          exit;
        end;

        FuncGroup.KeyDef := CSCommunication.GetFunctionKey(MiniformHeader.Code,TextValue);
        ActiveInputField := 1;

        case FuncGroup.KeyDef of
          FuncGroup.KeyDef::Esc:
            CSCommunication.RunPreviousUI(DOMxmlin);
          FuncGroup.KeyDef::Reset:
            Reset(WhseActivityHeader);
          FuncGroup.KeyDef::Register:
            begin
              Register(WhseActivityHeader);
              if Remark = '' then
                CSCommunication.RunPreviousUI(DOMxmlin)
              else
                SendForm(ActiveInputField);
            end;
          FuncGroup.KeyDef::"Function":
            begin
              Evaluate(FuncTableNo,CSCommunication.GetNodeAttribute(ReturnedNode,'FuncTableNo'));
              FuncRecRef.Open(FuncTableNo);
              Evaluate(FuncRecId,CSCommunication.GetNodeAttribute(ReturnedNode,'FuncRecordID'));
              if FuncRecRef.Get(FuncRecId) then begin
                FuncRecRef.SetTable(WhseActivityLine);
                WhseActivityLine.SplitLine(WhseActivityLine);
              end;
            end;
          FuncGroup.KeyDef::Input:
            begin

              BinCode := CSCommunication.GetNodeAttribute(ReturnedNode,'valueOne');
              if (BinCode <> '') and (StrLen(BinCode) <= MaxStrLen(Bin.Code)) then begin
                if not Bin.Get(WhseActivityHeader."Location Code",BinCode) then
                  Error(Text017,BinCode);
              end else
                Error(Text017,BinCode);

              Qty := 1;
              QtyTxt := CSCommunication.GetNodeAttribute(ReturnedNode,'valueTwo');
              if QtyTxt <> '' then
                if Evaluate(QtyVal,QtyTxt) then
                  if QtyVal > 0 then
                    Qty := QtyVal;

              if TextValue <> '' then
                if StrLen(TextValue) <= MaxStrLen(Item."No.") then
                  if BarcodeLibrary.TranslateBarcodeToItemVariant(TextValue, ItemNo2, VariantCode, ResolvingTable, true) then
                    if not Item.Get(ItemNo2) then
                      Remark := StrSubstNo(Text014,TextValue);

              if Remark = '' then begin
                WhseActivityLine.SetCurrentKey("Activity Type","No.","Sorting Sequence No.");
                WhseActivityLine.SetRange("No.",WhseActivityHeader."No.");
                WhseActivityLine.SetRange("Item No.",Item."No.");
                case WhseActivityHeader.Type of
                  WhseActivityHeader.Type::Pick : WhseActivityLine.SetRange("Action Type",WhseActivityLine."Action Type"::Take);
                  WhseActivityHeader.Type::"Put-away" : WhseActivityLine.SetRange("Action Type",WhseActivityLine."Action Type"::Place);
                end;
                if WhseActivityLine.FindSet then begin
                  repeat

                    if (WhseActivityLine."Qty. to Handle" < WhseActivityLine."Qty. Outstanding") then begin

                      if (BinCode <> WhseActivityLine."Bin Code") and (WhseActivityLine."Bin Code" <> '') then
                        Error(Text018,WhseActivityLine."Bin Code");

                      FoundedRecToUpdate := true;

                      if (WhseActivityLine."Qty. to Handle" + Qty) > WhseActivityLine."Qty. Outstanding" then
                        Qty := WhseActivityLine."Qty. Outstanding"
                      else
                        Qty := WhseActivityLine."Qty. to Handle" + Qty;

                      //ERROR(FORMAT(Qty));

                      WhseActivityLine.Validate("Qty. to Handle", Qty);
                      WhseActivityLine.Validate("Bin Code",BinCode);

                      //-NPR5.48 [335606]
                      if (ResolvingTable = DATABASE::"Item Cross Reference") then begin
                        with ItemCrossReference do begin
                          if (StrLen(TextValue) <= MaxStrLen("Cross-Reference No.")) then begin
                            SetCurrentKey("Cross-Reference Type", "Cross-Reference No.");
                            SetFilter("Cross-Reference Type", '=%1', "Cross-Reference Type"::"Bar Code");
                            SetFilter("Cross-Reference No.", '=%1', UpperCase (TextValue));
                            if FindFirst() then
                              WhseActivityLine.Validate("Unit of Measure Code",ItemCrossReference."Unit of Measure");
                          end;
                        end;
                      end;
                      //+NPR5.48 [335606]

                      WhseActivityLine.Modify(true);
                    end;

                  until (WhseActivityLine.Next = 0) or FoundedRecToUpdate;

                  if not FoundedRecToUpdate then
                    Error(Text016);

                end else
                  Remark := StrSubstNo(Text013,ItemNo2,WhseActivityHeader."No.");
              end;
            end;
          else
            Error(Text000);
        end;

        if not (FuncGroup.KeyDef in [FuncGroup.KeyDef::Esc,FuncGroup.KeyDef::Register]) then
          SendForm(ActiveInputField);
    end;

    local procedure Reset(var WhseActivityHeader: Record "Warehouse Activity Header")
    var
        WhseActivityLine: Record "Warehouse Activity Line";
    begin
        Remark := '';
        WhseActivityLine.SetRange("No.",WhseActivityHeader."No.");
        case WhseActivityHeader.Type of
          WhseActivityHeader.Type::Pick : WhseActivityLine.SetRange("Action Type",WhseActivityLine."Action Type"::Take);
          WhseActivityHeader.Type::"Put-away" : WhseActivityLine.SetRange("Action Type",WhseActivityLine."Action Type"::Place);
        end;
        if WhseActivityLine.FindSet then begin
          repeat
              WhseActivityLine.Validate("Qty. to Handle",0);
              WhseActivityLine.Validate("Bin Code",'');
              //-NPR5.48 [335606]
              WhseActivityLine.Validate("Unit of Measure Code",'');
              //+NPR5.48 [335606]
              WhseActivityLine.Modify;
          until WhseActivityLine.Next = 0;
        end else
          Error(Text007);

        CSCommunication.SetRecRef(RecRef);
        ActiveInputField := 1;
    end;

    local procedure Register(var WhseActivityHeader: Record "Warehouse Activity Header")
    var
        WhseActivityLine: Record "Warehouse Activity Line";
        WhseActivityRegister: Codeunit "Whse.-Activity-Register";
    begin
        Remark := '';
        WhseActivityLine.SetRange("No.",WhseActivityHeader."No.");

        // CASE WhseActivityHeader.Type OF
        //  WhseActivityHeader.Type::Pick : WhseActivityLine.SETRANGE("Action Type",WhseActivityLine."Action Type"::Take);
        //  WhseActivityHeader.Type::"Put-away" : WhseActivityLine.SETRANGE("Action Type",WhseActivityLine."Action Type"::Place);
        // END;

        if WhseActivityLine.FindSet then begin
          repeat
            if CheckBalanceQtyToHandle(WhseActivityLine) then begin
              WhseActivityRegister.ShowHideDialog(true);
              WhseActivityRegister.Run(WhseActivityLine);
            end;
          until WhseActivityLine.Next = 0;
        end else
          Error(Text007);
    end;

    local procedure PrepareData()
    var
        WhseActivityLine: Record "Warehouse Activity Line";
        WhseActivityHeader: Record "Warehouse Activity Header";
        RecId: RecordID;
        TableNo: Integer;
        Lookup: Integer;
    begin
        XMLDOMMgt.FindNode(RootNode,'Header/Input',ReturnedNode);

        Evaluate(TableNo,CSCommunication.GetNodeAttribute(ReturnedNode,'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId,CSCommunication.GetNodeAttribute(ReturnedNode,'RecordID'));
        if RecRef.Get(RecId) then begin
          RecRef.SetTable(WhseActivityHeader);
          WhseActivityLine.SetRange("Activity Type",WhseActivityHeader.Type);
          WhseActivityLine.SetRange("No.",WhseActivityHeader."No.");
          if not WhseActivityLine.FindFirst then begin
            CSManagement.SendError(Text012);
            exit;
          end;
          CSCommunication.SetRecRef(RecRef);
          ActiveInputField := 1;
          SendForm(ActiveInputField);
        end else
          Error(Text007);
    end;

    local procedure SendForm(InputField: Integer)
    var
        Records: DotNet XmlElement;
    begin
        // Prepare Miniform
        CSCommunication.EncodeUI(MiniformHeader,StackCode,DOMxmlin,InputField,Remark,CSUserId);
        CSCommunication.GetReturnXML(DOMxmlin);

        if AddSummarize(Records) then
          DOMxmlin.DocumentElement.AppendChild(Records);

        CSManagement.SendXMLReply(DOMxmlin);
    end;

    local procedure AddAttribute(var NewChild: DotNet XmlNode;AttribName: Text[250];AttribValue: Text[250])
    begin
        if XMLDOMMgt.AddAttribute(NewChild,AttribName,AttribValue) > 0 then
          Error(Text002,AttribName);
    end;

    local procedure AddSummarize(var Records: DotNet XmlElement): Boolean
    var
        "Record": DotNet XmlElement;
        Line: DotNet XmlElement;
        Indicator: Text;
        WhseActivityLine: Record "Warehouse Activity Line";
        WhseActivityHeader: Record "Warehouse Activity Header";
        LineType: Option TEXT,BUTTON;
        CurrRecordID: RecordID;
        TableNo: Integer;
        Location: Record Location;
    begin
        RecRef.SetTable(WhseActivityHeader);
        WhseActivityLine.SetRange("Activity Type",WhseActivityHeader.Type);
        WhseActivityLine.SetRange("No.",WhseActivityHeader."No.");
        case WhseActivityHeader.Type of
          WhseActivityHeader.Type::Pick : WhseActivityLine.SetRange("Action Type",WhseActivityLine."Action Type"::Take);
          WhseActivityHeader.Type::"Put-away" : WhseActivityLine.SetRange("Action Type",WhseActivityLine."Action Type"::Place);
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
              Line := DOMxmlin.CreateElement('Line');
              AddAttribute(Line,'Descrip',WhseActivityLine.FieldCaption(Description));
              AddAttribute(Line,'Indicator',Indicator);
              AddAttribute(Line,'Type',Format(LineType::TEXT));
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

              Records.AppendChild(Record);
            end;
          until WhseActivityLine.Next = 0;

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
                Line := DOMxmlin.CreateElement('Line');
                AddAttribute(Line,'Descrip',WhseActivityLine.FieldCaption(Description));
                AddAttribute(Line,'Indicator',Indicator);
                AddAttribute(Line,'Type',Format(LineType::TEXT));
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

                Records.AppendChild(Record);
              end;
            until WhseActivityLine.Next = 0;
           end;
          exit(true);
        end else
          exit(false);
    end;

    local procedure CheckBinNo(var WhseActLine: Record "Warehouse Activity Line";InputValue: Text[250])
    begin
        if InputValue = WhseActLine."Bin Code" then
          exit;

        Remark := StrSubstNo(Text004,WhseActLine.FieldCaption("Bin Code"));
    end;

    local procedure CheckItemNo(var WhseActLine: Record "Warehouse Activity Line";InputValue: Text[250])
    var
        ItemIdent: Record "Item Identifier";
    begin
        if InputValue = WhseActLine."Item No." then
          exit;

        if not ItemIdent.Get(InputValue) then
          Remark := StrSubstNo(Text004,ItemIdent.FieldCaption("Item No."));

        if ItemIdent."Item No." <> WhseActLine."Item No." then
          Remark := StrSubstNo(Text004,ItemIdent.FieldCaption("Item No."));

        if (ItemIdent."Variant Code" <> '') and (ItemIdent."Variant Code" <> WhseActLine."Variant Code") then
          Remark := StrSubstNo(Text004,ItemIdent.FieldCaption("Variant Code"));

        if (ItemIdent."Unit of Measure Code" <> '') and (ItemIdent."Unit of Measure Code" <> WhseActLine."Unit of Measure Code") then
          Remark := StrSubstNo(Text004,ItemIdent.FieldCaption("Unit of Measure Code"));
    end;

    local procedure CheckQty(var WhseActLine: Record "Warehouse Activity Line";InputValue: Text[250])
    var
        QtyToHandle: Decimal;
    begin
        if InputValue = '' then begin
          Remark := Text011;
          exit;
        end;

        with WhseActLine do begin
          Evaluate(QtyToHandle,InputValue);
          if QtyToHandle = Abs(QtyToHandle) then begin
            CheckItemNo(WhseActLine,"Item No.");
            if QtyToHandle <= "Qty. Outstanding" then
              Validate("Qty. to Handle",QtyToHandle)
            else
              Remark := Text011;
          end else
            Remark := Text011;
        end;
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
                        Text019,
                        FieldCaption("Item No."),"Item No.",
                        FieldCaption("Variant Code"),"Variant Code",
                        FieldCaption("Lot No."),"Lot No.",
                        FieldCaption("Serial No."),"Serial No.",
                        QtyToPick,QtyToPutAway)
                  else
                    Remark :=
                      StrSubstNo(
                        Text005,
                        FieldCaption("Item No."),"Item No.",FieldCaption("Variant Code"),
                        "Variant Code",QtyToPick,QtyToPutAway);
                  exit(false);
                end;

                //IF QtyToPick <> QtyToPutAway THEN
                //  EXIT(FALSE);

                QtyToPick := 0;
                QtyToPutAway := 0;
              end;
            until Next = 0;
        end;
    end;

    trigger DOMxmlin::NodeInserting(sender: Variant;e: DotNet XmlNodeChangedEventArgs)
    begin
    end;

    trigger DOMxmlin::NodeInserted(sender: Variant;e: DotNet XmlNodeChangedEventArgs)
    begin
    end;

    trigger DOMxmlin::NodeRemoving(sender: Variant;e: DotNet XmlNodeChangedEventArgs)
    begin
    end;

    trigger DOMxmlin::NodeRemoved(sender: Variant;e: DotNet XmlNodeChangedEventArgs)
    begin
    end;

    trigger DOMxmlin::NodeChanging(sender: Variant;e: DotNet XmlNodeChangedEventArgs)
    begin
    end;

    trigger DOMxmlin::NodeChanged(sender: Variant;e: DotNet XmlNodeChangedEventArgs)
    begin
    end;
}

