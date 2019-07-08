codeunit 6151364 "CS UI Item Reclass. Handling"
{
    // NPR5.50/CLVA/20190527  CASE 355694 Object created

    TableNo = "CS UI Header";

    trigger OnRun()
    var
        MiniformMgmt: Codeunit "CS UI Management";
    begin
        MiniformMgmt.Initialize(
          CSUIHeader,Rec,DOMxmlin,ReturnedNode,
          RootNode,XMLDOMMgt,CSCommunication,CSUserId,
          CurrentCode,StackCode,WhseEmpId,LocationFilter,CSSessionId);

        if Code <> CurrentCode then
          PrepareData
        else
          ProcessInput;

        Clear(DOMxmlin);
    end;

    var
        CSUIHeader: Record "CS UI Header";
        XMLDOMMgt: Codeunit "XML DOM Management";
        CSCommunication: Codeunit "CS Communication";
        CSMgt: Codeunit "CS Management";
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

    local procedure ProcessInput()
    var
        FuncGroup: Record "CS UI Function Group";
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
        CSItemReclassHandling: Record "CS Item Reclass. Handling";
        CSItemReclassHandling2: Record "CS Item Reclass. Handling";
        CSFieldDefaults: Record "CS Field Defaults";
        CommaString: DotNet String;
        Values: DotNet Array;
        Separator: DotNet String;
        Value: Text;
        ItemJournalLine: Record "Item Journal Line";
    begin
        if XMLDOMMgt.FindNode(RootNode,'Header/Input',ReturnedNode) then
          TextValue := ReturnedNode.InnerText
        else
          Error(Text006);

        Evaluate(TableNo,CSCommunication.GetNodeAttribute(ReturnedNode,'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId,CSCommunication.GetNodeAttribute(ReturnedNode,'RecordID'));
        if RecRef.Get(RecId) then begin
          RecRef.SetTable(CSItemReclassHandling);
          RecRef.SetRecFilter;
          CSCommunication.SetRecRef(RecRef);
        end else begin
          CSCommunication.RunPreviousUI(DOMxmlin);
          exit;
        end;

        FuncGroup.KeyDef := CSCommunication.GetFunctionKey(CSUIHeader.Code,TextValue);

        ActiveInputField := 1;

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
              Evaluate(FldNo,CSCommunication.GetNodeAttribute(ReturnedNode,'FieldID'));

              CommaString := TextValue;
              Separator := ',';
              Values := CommaString.Split(Separator.ToCharArray());

              foreach Value in Values do begin

                if Value <> '' then begin

                  case FldNo of
                    CSItemReclassHandling.FieldNo(Barcode):
                      CheckBarcode(CSItemReclassHandling,Value);
                    CSItemReclassHandling.FieldNo("Bin Code"):
                      CheckBinCode(CSItemReclassHandling,Value);
                    CSItemReclassHandling.FieldNo("New Bin Code"):
                      CheckNewBinCode(CSItemReclassHandling,Value);
                    CSItemReclassHandling.FieldNo(Qty):
                      CheckQty(CSItemReclassHandling,Value);
                    else begin
                      CSCommunication.FieldSetvalue(RecRef,FldNo,Value);
                    end;
                  end;

                  CSItemReclassHandling.Modify;

                  RecRef.GetTable(CSItemReclassHandling);
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
                          RecRef.SetTable(CSItemReclassHandling);
                          RecRef.SetRecFilter;
                          CSCommunication.SetRecRef(RecRef);
                        until CSFieldDefaults.Next = 0;
                      end;

                      UpdateDataLine(CSItemReclassHandling);
                      CreateDataLine(CSItemReclassHandling2,CSItemReclassHandling."Location Code");
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

        if not (FuncGroup.KeyDef in [FuncGroup.KeyDef::Esc,FuncGroup.KeyDef::Register]) then
          SendForm(ActiveInputField);
    end;

    local procedure PrepareData()
    var
        CSItemReclassHandling: Record "CS Item Reclass. Handling";
        Location: Record Location;
        RecId: RecordID;
        TableNo: Integer;
    begin
        XMLDOMMgt.FindNode(RootNode,'Header/Input',ReturnedNode);

        Evaluate(TableNo,CSCommunication.GetNodeAttribute(ReturnedNode,'TableNo'));
        Evaluate(RecId,CSCommunication.GetNodeAttribute(ReturnedNode,'RecordID'));

        RecRef.Open(TableNo);
        RecRef.Get(RecId);
        RecRef.SetTable(Location);

        DeleteEmptyDataLines(CSItemReclassHandling);
        CreateDataLine(CSItemReclassHandling,Location.Code);

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
        Records: DotNet XmlElement;
        CSSetup: Record "CS Setup";
    begin
        CSCommunication.EncodeUI(CSUIHeader,StackCode,DOMxmlin,InputField,Remark,CSUserId);
        CSCommunication.GetReturnXML(DOMxmlin);

        if AddSummarize(Records) then
          DOMxmlin.DocumentElement.AppendChild(Records);

        CSMgt.SendXMLReply(DOMxmlin);
    end;

    local procedure CheckBarcode(var CSItemReclassHandling: Record "CS Item Reclass. Handling";InputValue: Text)
    var
        BarcodeLibrary: Codeunit "Barcode Library";
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
        Item: Record Item;
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
            Remark := StrSubstNo(Text014,InputValue);
            exit;
          end;

          CSItemReclassHandling."Item No." := ItemNo;
          CSItemReclassHandling."Variant Code" := VariantCode;

        end else begin
          Remark := StrSubstNo(Text010,InputValue);
          exit;
        end;

        CSItemReclassHandling.Barcode := InputValue;
    end;

    local procedure CheckBinCode(var CSItemReclassHandlingPlaceholder: Record "CS Item Reclass. Handling";InputValue: Text)
    var
        QtyToHandle: Decimal;
        BinContent: Record "Bin Content";
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
        BinContent.SetRange("Location Code",CSItemReclassHandlingPlaceholder."Location Code");
        BinContent.SetRange("Item No.",CSItemReclassHandlingPlaceholder."Item No.");
        BinContent.SetRange("Variant Code",CSItemReclassHandlingPlaceholder."Variant Code");
        if not BinContent.FindSet then
          Remark := Text021;

        CSItemReclassHandlingPlaceholder."Bin Code" := InputValue;
    end;

    local procedure CheckNewBinCode(var CSItemReclassHandlingPlaceholder: Record "CS Item Reclass. Handling";InputValue: Text)
    var
        QtyToHandle: Decimal;
        BinContent: Record "Bin Content";
    begin
        if InputValue = '' then begin
          Remark := Text009;
          exit;
        end;

        if StrLen(InputValue) > MaxStrLen(CSItemReclassHandlingPlaceholder."New Bin Code") then begin
          Remark := Text008;
          exit;
        end;

        Clear(BinContent);
        BinContent.SetRange("Location Code",CSItemReclassHandlingPlaceholder."Location Code");
        BinContent.SetRange("Item No.",CSItemReclassHandlingPlaceholder."Item No.");
        BinContent.SetRange("Variant Code",CSItemReclassHandlingPlaceholder."Variant Code");
        if not BinContent.FindSet then
          Remark := Text021;

        CSItemReclassHandlingPlaceholder."New Bin Code" := InputValue;
    end;

    local procedure CheckQty(var CSItemReclassHandlingPlaceholder: Record "CS Item Reclass. Handling";InputValue: Text)
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

        CSItemReclassHandlingPlaceholder.Qty := Qty;
    end;

    local procedure CreateDataLine(var CSItemReclassHandling: Record "CS Item Reclass. Handling";LocationCode: Code[10])
    var
        NewCSItemReclassHandling: Record "CS Item Reclass. Handling";
        LineNo: Integer;
        CSUIHeader: Record "CS UI Header";
        RecRef: RecordRef;
        CSSetup: Record "CS Setup";
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

    local procedure UpdateDataLine(var CSItemReclassHandling: Record "CS Item Reclass. Handling")
    var
        LineNo: Integer;
        CSSetup: Record "CS Setup";
    begin
        CSSetup.Get;

        CSItemReclassHandling.Handled := true;
        CSItemReclassHandling.Modify(true);

        if TransferDataLine(CSItemReclassHandling,CSSetup) then begin
          CSItemReclassHandling."Transferred to Worksheet" := true;
          CSItemReclassHandling.Modify(true);
        end;
    end;

    local procedure DeleteEmptyDataLines(var CurrCSItemReclassHandling: Record "CS Item Reclass. Handling")
    var
        CSItemReclassHandling: Record "CS Item Reclass. Handling";
    begin
        CSItemReclassHandling.SetRange(Id,CSSessionId);
        CSItemReclassHandling.SetRange(Handled,false);
        CSItemReclassHandling.SetRange("Transferred to Worksheet",false);
        CSItemReclassHandling.DeleteAll(true);
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
        LineType: Option TEXT,BUTTON;
        CurrRecordID: RecordID;
        TableNo: Integer;
        CSItemReclassHandling: Record "CS Item Reclass. Handling";
        CSSetup: Record "CS Setup";
        ItemJournalLine: Record "Item Journal Line";
    begin
        //CLEAR(CSItemReclassHandling);
        //CSItemReclassHandling.SETRANGE(Id,CSSessionId);
        //IF NOT CSItemReclassHandling.FINDLAST THEN
        //  EXIT(FALSE);

        CSSetup.Get;

        Clear(ItemJournalLine);
        ItemJournalLine.SetRange("Journal Template Name", CSSetup."Item Reclass. Jour Temp Name");
        ItemJournalLine.SetRange("Journal Batch Name", CSSetup."Item Reclass. Jour Batch Name");
        ItemJournalLine.SetRange("External Document No.", CSSessionId);
        if ItemJournalLine.FindSet then begin
          Records := DOMxmlin.CreateElement('Records');
          repeat
            Record := DOMxmlin.CreateElement('Record');

            CurrRecordID := ItemJournalLine.RecordId;
            TableNo := CurrRecordID.TableNo;

            Indicator := 'ok';

            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line,'Descrip','Description');
            AddAttribute(Line,'Indicator',Indicator);
            Line.InnerText := StrSubstNo(Text015,ItemJournalLine.Quantity,ItemJournalLine."Item No.",ItemJournalLine.Description);
            Record.AppendChild(Line);

            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line,'Descrip','Delete..');
            AddAttribute(Line,'Type',Format(LineType::BUTTON));
            AddAttribute(Line,'TableNo',Format(TableNo));
            AddAttribute(Line,'RecordID',Format(CurrRecordID));
            AddAttribute(Line,'FuncName','DELETELINE');
            Record.AppendChild(Line);

            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line,'Descrip',ItemJournalLine.FieldCaption("Item No."));
            AddAttribute(Line,'Type',Format(LineType::TEXT));
            Line.InnerText := ItemJournalLine."Item No.";
            Record.AppendChild(Line);

            if (ItemJournalLine."Variant Code" <> '') then begin
              Line := DOMxmlin.CreateElement('Line');
              AddAttribute(Line,'Descrip',ItemJournalLine.FieldCaption("Variant Code"));
              AddAttribute(Line,'Type',Format(LineType::TEXT));
              Line.InnerText := ItemJournalLine."Variant Code";
              Record.AppendChild(Line);
            end;

            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line,'Descrip',ItemJournalLine.FieldCaption("Bin Code"));
            AddAttribute(Line,'Type',Format(LineType::TEXT));
            Line.InnerText := ItemJournalLine."Bin Code";
            Record.AppendChild(Line);

            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line,'Descrip',ItemJournalLine.FieldCaption("New Bin Code"));
            AddAttribute(Line,'Type',Format(LineType::TEXT));
            Line.InnerText := ItemJournalLine."New Bin Code";
            Record.AppendChild(Line);

            Records.AppendChild(Record);
          until ItemJournalLine.Next = 0;
          exit(true);
        end else
          exit(false);
    end;

    local procedure AddAggSummarize(var Records: DotNet XmlElement) NotEmptyResult: Boolean
    var
        "Record": DotNet XmlElement;
        Line: DotNet XmlElement;
        Indicator: Text;
        LineType: Option TEXT,BUTTON;
        CurrRecordID: RecordID;
        TableNo: Integer;
        SummarizeCounting: Query "CS Stock-Take Summarize";
    begin
        Records := DOMxmlin.CreateElement('Records');

        SummarizeCounting.SetRange(Id,CSSessionId);
        SummarizeCounting.SetRange(Handled,true);
        SummarizeCounting.SetRange(Transferred_to_Worksheet,false);
        SummarizeCounting.Open;
        while SummarizeCounting.Read do
        begin

            NotEmptyResult := true;
            Record := DOMxmlin.CreateElement('Record');

            //CurrRecordID := SummarizeCounting.RECORDID;
            //TableNo := CurrRecordID.TABLENO;

            if SummarizeCounting.Item_No = '' then
              Indicator := 'minus'
            else
              Indicator := 'ok';

            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line,'Descrip','Description');
            AddAttribute(Line,'Indicator',Indicator);
            if (Indicator = 'ok') then
              Line.InnerText := StrSubstNo(Text015,SummarizeCounting.Count_,SummarizeCounting.Item_No,SummarizeCounting.Item_Description)
            else
              Line.InnerText := StrSubstNo(Text016,SummarizeCounting.Count_, 'Unknown Tag Id');
            Record.AppendChild(Line);

        //    Line := DOMxmlin.CreateElement('Line');
        //    AddAttribute(Line,'Descrip','Delete..');
        //    AddAttribute(Line,'Type',FORMAT(LineType::BUTTON));
        //    AddAttribute(Line,'TableNo',FORMAT(TableNo));
        //    AddAttribute(Line,'RecordID',FORMAT(CurrRecordID));
        //    AddAttribute(Line,'FuncName','DELETELINE');
        //    Record.AppendChild(Line);

            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line,'Descrip','No.');
            AddAttribute(Line,'Type',Format(LineType::TEXT));
            Line.InnerText := SummarizeCounting.Item_No;
            Record.AppendChild(Line);

            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line,'Descrip','Name');
            AddAttribute(Line,'Type',Format(LineType::TEXT));
            Line.InnerText := SummarizeCounting.Item_Description;
            Record.AppendChild(Line);

            if (SummarizeCounting.Variant_Code <> '') then begin
              Line := DOMxmlin.CreateElement('Line');
              AddAttribute(Line,'Descrip','Variant');
              AddAttribute(Line,'Type',Format(LineType::TEXT));
              Line.InnerText := SummarizeCounting.Variant_Code + ' - ' + SummarizeCounting.Variant_Description;
              Record.AppendChild(Line);
            end;

            Records.AppendChild(Record);
        end;

        SummarizeCounting.Close;

        exit(NotEmptyResult);
    end;

    local procedure Reset(var CurrCSItemReclassHandling: Record "CS Item Reclass. Handling")
    var
        CSItemReclassHandling: Record "CS Item Reclass. Handling";
        CSSetup: Record "CS Setup";
        ItemJournalLine: Record "Item Journal Line";
    begin
        // CLEAR(CSItemReclassHandling);
        // CSItemReclassHandling.SETRANGE(Id,CSSessionId);
        // CSItemReclassHandling.SETRANGE("Journal Template Name",CurrCSItemReclassHandling."Journal Template Name");
        // CSItemReclassHandling.SETRANGE("Journal Batch Name",CurrCSItemReclassHandling."Journal Batch Name");
        // CSItemReclassHandling.SETRANGE(Handled,FALSE);
        // CSItemReclassHandling.SETRANGE("Transferred to Worksheet",FALSE);
        // CSItemReclassHandling.DELETEALL(TRUE);

        CSSetup.Get;

        Clear(ItemJournalLine);
        ItemJournalLine.SetRange("Journal Template Name",CSSetup."Item Reclass. Jour Temp Name");
        ItemJournalLine.SetRange("Journal Batch Name",CSSetup."Item Reclass. Jour Batch Name");
        ItemJournalLine.SetRange("External Document No.",CSSessionId);
        ItemJournalLine.DeleteAll(true);

        CSCommunication.SetRecRef(RecRef);
        ActiveInputField := 1;
    end;

    local procedure Register()
    var
        CSSetup: Record "CS Setup";
        ItemJnlTemplate: Record "Item Journal Template";
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
        ItemJournalLine: Record "Item Journal Line";
    begin
        CSSetup.Get;

        ItemJnlTemplate.Get(CSSetup."Item Reclass. Jour Temp Name");
        ItemJnlTemplate.TestField("Force Posting Report",false);

        Clear(ItemJournalLine);
        ItemJournalLine.SetRange("Journal Template Name",CSSetup."Item Reclass. Jour Temp Name");
        ItemJournalLine.SetRange("Journal Batch Name",CSSetup."Item Reclass. Jour Batch Name");
        ItemJournalLine.SetRange("External Document No.",CSSessionId);
        if ItemJournalLine.FindSet then begin
          repeat
            ItemJnlPostBatch.Run(ItemJournalLine);
          until ItemJournalLine.Next = 0;
        end;
    end;

    local procedure TransferDataLine(var CSItemReclassHandling: Record "CS Item Reclass. Handling";CSSetup: Record "CS Setup"): Boolean
    var
        ItemJournalLine: Record "Item Journal Line";
        NewItemJournalLine: Record "Item Journal Line";
        LineNo: Integer;
        ItemJnlTemplate: Record "Item Journal Template";
        ItemJnlBatch: Record "Item Journal Batch";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        Clear(NewItemJournalLine);
        NewItemJournalLine.SetRange("Journal Template Name", CSSetup."Item Reclass. Jour Temp Name");
        NewItemJournalLine.SetRange("Journal Batch Name", CSSetup."Item Reclass. Jour Batch Name");
        LineNo := 0;
        if NewItemJournalLine.FindLast then
          LineNo := NewItemJournalLine."Line No." + 1000
        else
          LineNo := 1000;

        Clear(ItemJournalLine);
        ItemJournalLine.Validate("Journal Template Name",CSSetup."Item Reclass. Jour Temp Name");
        ItemJournalLine.Validate("Journal Batch Name",CSSetup."Item Reclass. Jour Batch Name");
        ItemJournalLine."Line No." := LineNo;
        ItemJournalLine.Insert(true);

        ItemJournalLine.Validate("Entry Type",ItemJournalLine."Entry Type"::Transfer);
        ItemJournalLine.Validate("Item No.", CSItemReclassHandling."Item No.");
        ItemJournalLine.Validate("Variant Code",CSItemReclassHandling."Variant Code");
        ItemJournalLine.Validate("Location Code",CSItemReclassHandling."Location Code");
        ItemJournalLine.Validate("New Location Code",CSItemReclassHandling."Location Code");
        ItemJournalLine.Validate(Quantity,CSItemReclassHandling.Qty);
        ItemJournalLine.Validate("Bin Code",CSItemReclassHandling."Bin Code");
        ItemJournalLine.Validate("New Bin Code",CSItemReclassHandling."New Bin Code");
        ItemJournalLine."Posting Date" := WorkDate;
        ItemJournalLine."Document Date" := WorkDate;

        ItemJnlTemplate.Get(ItemJournalLine."Journal Template Name");
        ItemJnlBatch.Get(ItemJournalLine."Journal Template Name",ItemJournalLine."Journal Batch Name");

        Clear(NoSeriesMgt);
        ItemJournalLine."Document No." := NoSeriesMgt.GetNextNo(ItemJnlBatch."No. Series",ItemJournalLine."Posting Date",false);
        ItemJournalLine."Source Code" := ItemJnlTemplate."Source Code";
        ItemJournalLine."Reason Code" := ItemJnlBatch."Reason Code";
        ItemJournalLine."Posting No. Series" := ItemJnlBatch."Posting No. Series";
        ItemJournalLine."External Document No." := CSSessionId;
        ItemJournalLine.Modify(true);

        exit(true);
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

