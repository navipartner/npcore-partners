codeunit 6060056 "Item Wksht. Doc. Exchange"
{
    // NPR5.25/BR /20160727 CASE 246088 Object Created
    // NPR5.27/BR /20160930 CASE 252817 Support all fields transferred from Incoming Document Error message to NAV
    // NPR5.27/BR /20161004 CASE 252817 Do not create line if a line with the same Vendor Item No. is already in the Item Worksheet
    // NPR5.29/TJ/20161128 CASE 257500 Fixed a problem with wrong decimal formatting when writing into field from FieldRef
    // NPR5.29/BR /20161129 CASE 257500 Fixed issue with using log to create item worksheet
    // NPR5.55/ALST/20200717 CASE 411831 added event after inserting worksheet line


    trigger OnRun()
    begin
    end;

    procedure GetItemWorksheetDocExchange(VendorNo: Code[20];var ItemWorksheet: Record "Item Worksheet";var AutomProcess: Boolean;var AutomQuery: Boolean): Boolean
    var
        DocExchSetup: Record "Doc. Exch. Setup";
        DocExchPath: Record "Doc. Exchange Path";
    begin
        DocExchPath.Reset;
        DocExchPath.SetRange(Direction,DocExchPath.Direction::Import);
        DocExchPath.SetRange(Type,DocExchPath.Type::Vendor);
        DocExchPath.SetRange("No.",VendorNo);
        if DocExchPath.FindFirst then begin
          if ItemWorksheet.Get(DocExchPath."Unmatched Items Wsht. Template",DocExchPath."Unmatched Items Wsht. Name") then begin
            AutomProcess := DocExchPath."Autom. Create Unmatched Items";
            AutomQuery := DocExchPath."Autom. Query Item Information";
            exit(true);
          end;
        end;

        DocExchPath.Reset;
        DocExchPath.SetRange(Direction,DocExchPath.Direction::Import);
        DocExchPath.SetRange(Type,DocExchPath.Type::All);
        if DocExchPath.FindFirst then begin
          if ItemWorksheet.Get(DocExchPath."Unmatched Items Wsht. Template",DocExchPath."Unmatched Items Wsht. Name") then begin
            AutomProcess := DocExchPath."Autom. Create Unmatched Items";
            AutomQuery := DocExchPath."Autom. Query Item Information";
            exit(true);
          end;
        end;

        if not DocExchSetup.Get then
          exit(false);
        if ItemWorksheet.Get(DocExchSetup."Unmatched Items Wsht. Template",DocExchSetup."Unmatched Items Wsht. Name") then begin
          AutomProcess := DocExchSetup."Autom. Create Unmatched Items";
          AutomQuery := DocExchSetup."Autom. Query Item Information";
          exit(true);
        end;
        exit(false);
    end;

    procedure InsertItemWorksheetLine(ItemWorksheet: Record "Item Worksheet";var ItemWorksheetLine: Record "Item Worksheet Line";VendorNo: Code[20];VendorItemNo: Text;VendorItemDescription: Text;ItemGroupText: Text;DirectUnitCost: Decimal)
    var
        LastItemWorksheetLine: Record "Item Worksheet Line";
        ItemGroup: Record "Item Group";
        ItemWorksheetLineNo: Integer;
    begin
        with ItemWorksheetLine do begin
          Reset;
          SetRange("Worksheet Template Name",ItemWorksheet."Item Template Name");
          SetRange("Worksheet Name",ItemWorksheet.Name);
          if FindLast then begin
            LastItemWorksheetLine := ItemWorksheetLine;
            ItemWorksheetLineNo := "Line No." + 10000
          end else begin
            LastItemWorksheetLine.Init;
            ItemWorksheetLineNo := 10000;
          end;
          Init;
          Validate("Worksheet Template Name",ItemWorksheet."Item Template Name");
          Validate("Worksheet Name",ItemWorksheet.Name);
          Validate("Line No.",ItemWorksheetLineNo);
          Insert(true);
          "Created Date Time" := CurrentDateTime ();
          Validate("Vendor No.",VendorNo);
          SetUpNewLine(LastItemWorksheetLine);
          Action := Action :: CreateNew;
          if (ItemGroupText <> '') and (StrLen(ItemGroupText) <= MaxStrLen(ItemGroup."No."))then begin
            if ItemGroup.Get(ItemGroupText) then begin
              Validate("Item Group",ItemGroupText);
            end;
          end;
          Validate("Vendor Item No.", CopyStr(VendorItemNo,1,MaxStrLen("Vendor Item No.")));
          Validate(Description, CopyStr(VendorItemDescription,1,MaxStrLen(Description)));
          Validate("Direct Unit Cost",DirectUnitCost);
          Modify(true);
        end;

        //-NPR5.55 [411831]
        OnAfterInsertItemWorksheetLine(ItemWorksheetLine);
        //+NPR5.55 [411831]
    end;

    local procedure InsertItemWorksheetAttributeValues(ItemWorksheetLine: Record "Item Worksheet Line")
    begin
        //-NPR5.27 [252817]
        InsertItemWorksheetAttributeValue(ItemWorksheetLine."Custom Text 1",1,ItemWorksheetLine);
        InsertItemWorksheetAttributeValue(ItemWorksheetLine."Custom Text 2",2,ItemWorksheetLine);
        InsertItemWorksheetAttributeValue(ItemWorksheetLine."Custom Text 3",3,ItemWorksheetLine);
        InsertItemWorksheetAttributeValue(ItemWorksheetLine."Custom Text 4",4,ItemWorksheetLine);
        InsertItemWorksheetAttributeValue(ItemWorksheetLine."Custom Text 5",5,ItemWorksheetLine);
        //+NPR5.27 [252817]
    end;

    local procedure InsertItemWorksheetAttributeValue(AttributeValue: Text;AttributeNo: Integer;ItemWorksheetLine: Record "Item Worksheet Line")
    var
        NPRAttributeID: Record "NPR Attribute ID";
        NPRAttributeManagement: Codeunit "NPR Attribute Management";
    begin
        //-NPR5.27 [252817]
        if AttributeValue = '' then
          exit;
        NPRAttributeID.Reset;
        NPRAttributeID.SetRange("Table ID",DATABASE::"Item Worksheet Line");
        NPRAttributeID.SetRange("Shortcut Attribute ID",AttributeNo);
        if NPRAttributeID.FindFirst then begin
          NPRAttributeManagement.SetWorksheetLineAttributeValue (NPRAttributeID."Table ID", NPRAttributeID."Shortcut Attribute ID",
                ItemWorksheetLine."Worksheet Template Name",ItemWorksheetLine."Worksheet Name",ItemWorksheetLine."Line No." , AttributeValue);
        end;
        //+NPR5.27 [252817]
    end;

    local procedure InsertItemWorksheetVariantLine(IncomingDocument: Record "Incoming Document";ItemWorksheetLine: Record "Item Worksheet Line")
    var
        ErrorMessage: Record "Error Message";
        ErrorMessage2: Record "Error Message";
        ItemWorksheetVariantLine: Record "Item Worksheet Variant Line";
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        ErrorMessage.Reset;
        ErrorMessage.SetRange("Context Record ID",IncomingDocument.RecordId);
        ErrorMessage.SetRange("Table Number",DATABASE::"Item Worksheet Variant Line");
        ErrorMessage.SetRange("Field Number",ItemWorksheetVariantLine.FieldNo(Description));
        ErrorMessage.SetRange(Description,ItemWorksheetLine."Vendor Item No.");
        if not ErrorMessage.FindFirst then
          exit;

        ItemWorksheetVariantLine.Init;
        ItemWorksheetVariantLine.Validate("Worksheet Template Name",ItemWorksheetLine."Worksheet Template Name");
        ItemWorksheetVariantLine.Validate("Worksheet Name",ItemWorksheetLine."Worksheet Name");
        ItemWorksheetVariantLine.Validate("Worksheet Line No.",ItemWorksheetLine."Line No.");
        ItemWorksheetVariantLine.Validate("Line No.",10000);
        ItemWorksheetVariantLine.Insert(true);
        ItemWorksheetVariantLine.Action := ItemWorksheetVariantLine.Action :: CreateNew;
        ItemWorksheetVariantLine.Validate("Item No.",ItemWorksheetLine."Item No.");
        ItemWorksheetVariantLine.Validate("Sales Price",ItemWorksheetLine."Sales Price");
        ItemWorksheetVariantLine.Validate("Direct Unit Cost",ItemWorksheetLine."Direct Unit Cost");
        ItemWorksheetVariantLine.Modify(true);
        ErrorMessage2.Reset;
        ErrorMessage2.SetRange("Context Record ID",IncomingDocument.RecordId);
        ErrorMessage2.SetRange("Table Number",DATABASE::"Item Worksheet Variant Line");
        ErrorMessage2.SetRange("Record ID",ErrorMessage2."Record ID");
        if ErrorMessage2.FindSet then repeat
          if ErrorMessage2."Field Number" <> ItemWorksheetVariantLine.FieldNo(Description) then begin
            RecRef.Get(ItemWorksheetVariantLine.RecordId);
            FldRef := RecRef.Field(ErrorMessage2."Field Number");
            FldRef.Value := CopyStr(ErrorMessage2.Description,1,FldRef.Length);
            RecRef.Modify;
          end;
        until ErrorMessage2.Next = 0;
    end;

    procedure ItemWorksheetExists(ItemWorksheet: Record "Item Worksheet";ItemWorksheetLine: Record "Item Worksheet Line";VendorNo: Text;VendorItemNo: Text): Boolean
    var
        ItemWorksheetLine2: Record "Item Worksheet Line";
    begin
        //-NPR5.27 [252817]
        with ItemWorksheetLine2 do begin
          Reset;
          SetRange("Worksheet Template Name",ItemWorksheet."Item Template Name");
          SetRange("Worksheet Name",ItemWorksheet.Name);
          SetFilter("Vendor No.",VendorNo);
          SetFilter("Vendor Item No.",VendorItemNo);
          if FindLast then
            exit(true)
          else
            exit(false);
        end;
        //+NPR5.27 [252817]
    end;

    [EventSubscriber(ObjectType::Codeunit, 132, 'OnAfterCreateDocFromIncomingDocFail', '', true, true)]
    local procedure OnAfterCreateDocFromIncomingDocFailCreateItemWorksheetLines(var IncomingDocument: Record "Incoming Document")
    begin
        CreateItemWorksheetLinesFromIncomingDocument(IncomingDocument);
    end;

    local procedure CreateItemWorksheetLinesFromIncomingDocument(IncomingDocument: Record "Incoming Document")
    var
        ErrorMessage: Record "Error Message";
        ErrorMessage2: Record "Error Message";
        ErrorMessage3: Record "Error Message";
        ItemWorksheetLine: Record "Item Worksheet Line";
        ItemWorksheetVariantLine: Record "Item Worksheet Variant Line";
        ItemGroupText: Text;
        VendorItemNo: Text;
        VendorItemDescription: Text;
        DirectUnitCost: Decimal;
        ConfigValidateMgt: Codeunit "Config. Validate Management";
        VendorNo: Text;
        AutomaticQuery: Boolean;
        AutomaticProcessing: Boolean;
        ItemWorksheet: Record "Item Worksheet";
        Item: Record Item;
        NoOfMissingItems: Integer;
        ErrorItemWSLinesNotCreated: Label 'Item Worksheet Lines could not be created.';
        ItemCouldNotBeMatched: Label 'The item with %1 %2 could not be matched to an existing item and has been added to Item Worksheet %3 %4. ';
        ItemWshtRegisterBatch: Codeunit "Item Wsht.-Register Batch";
        ItemsCreated: Label 'The item with %1 %2 could not be matched and has been created as Item %3. Please Check before creating the Purchase Invoice.';
        ItemNo: Text;
        RecRef: RecordRef;
        FldRef: FieldRef;
        ErrorItemWSLineAlreadyCreated: Label 'The item with %1 %2 could not be matched to an existing item but has already been added to Item Worksheet %3 %4. ';
        Size: Text;
        Color: Text;
    begin
        NoOfMissingItems := 0;
        ErrorMessage.Reset;
        ErrorMessage.SetRange("Context Record ID",IncomingDocument.RecordId);
        ErrorMessage.SetRange("Table Number",DATABASE::"Item Worksheet Line");
        ErrorMessage.SetRange("Field Number",ItemWorksheetLine.FieldNo("Vendor Item No."));
        if ErrorMessage.FindSet then repeat
          NoOfMissingItems := NoOfMissingItems + 1;
          ErrorMessage2.Reset;
          ErrorMessage2.SetRange("Context Record ID",IncomingDocument.RecordId);
          ErrorMessage2.SetRange("Table Number",DATABASE::"Item Worksheet Line");
          if ErrorMessage2.FindSet then repeat
            if Format(ErrorMessage2."Record ID") = Format(ErrorMessage."Record ID") then begin
              case ErrorMessage2."Field Number" of
                ItemWorksheetLine.FieldNo("Vendor Item No.") : VendorItemNo := ErrorMessage2.Description;
                ItemWorksheetLine.FieldNo("Item Group") : ItemGroupText := ErrorMessage2.Description;
                ItemWorksheetLine.FieldNo(Description) : VendorItemDescription := ErrorMessage2.Description;
                ItemWorksheetLine.FieldNo("Direct Unit Cost") : Evaluate(DirectUnitCost,ErrorMessage2.Description,9);
                ItemWorksheetLine.FieldNo("Vendor No.") : VendorNo := ErrorMessage2.Description;
              end;
            end;
          until ErrorMessage2.Next = 0;
          if GetItemWorksheetDocExchange(VendorNo,ItemWorksheet,AutomaticProcessing,AutomaticQuery) then begin
            //-NPR5.27 [252817]
            if not ItemWorksheetExists(ItemWorksheet,ItemWorksheetLine,VendorNo,VendorItemNo) then begin
              //+NPR5.27 [252817]
              InsertItemWorksheetLine(ItemWorksheet,ItemWorksheetLine,VendorNo,VendorItemNo,VendorItemDescription,ItemGroupText,DirectUnitCost);
              ItemWorksheetLine.Get(ItemWorksheetLine."Worksheet Template Name",ItemWorksheetLine."Worksheet Name",ItemWorksheetLine."Line No.");
              //-NPR5.27 [252817]
              ErrorMessage2.Reset;
              ErrorMessage2.SetRange("Context Record ID",IncomingDocument.RecordId);
              if ErrorMessage2.FindSet then repeat
                if Format(ErrorMessage2."Record ID") = Format(ErrorMessage."Record ID") then begin
                  case ErrorMessage2."Table Number" of
                     DATABASE::"Item Worksheet Line" :
                       begin
                         RecRef.Get(ItemWorksheetLine.RecordId);
                         FldRef := RecRef.Field(ErrorMessage2."Field Number");
        //-NPR5.29 [257500]
        //                 FldRef.VALUE := COPYSTR(ErrorMessage2.Description,1,FldRef.LENGTH);
                         if ConfigValidateMgt.EvaluateValue(FldRef,ErrorMessage2.Description,false) = '' then
        //+NPR5.29 [257500]

                         RecRef.Modify;
                       end;
                  end;
                end;
              until ErrorMessage2.Next = 0;
              InsertItemWorksheetAttributeValues(ItemWorksheetLine);
              InsertItemWorksheetVariantLine(IncomingDocument,ItemWorksheetLine);
              //+NPR5.27 [252817]
              if AutomaticQuery then begin
                ItemWorksheetLine.CreateQueryItemInformation(false);
              end;
              if AutomaticProcessing then begin
                ItemWorksheetLine.Get(ItemWorksheetLine."Worksheet Template Name",ItemWorksheetLine."Worksheet Name",ItemWorksheetLine."Line No.");
                ItemNo := ItemWorksheetLine."Item No.";
                ItemWorksheetLine.SetRecFilter;
                Clear(ItemWshtRegisterBatch);
                ItemWshtRegisterBatch.Run(ItemWorksheetLine);
                if ItemWshtRegisterBatch.Run(ItemWorksheetLine) then begin
                  ErrorMessage.Validate(Description,StrSubstNo(ItemsCreated, ItemWorksheetLine.FieldCaption("Vendor Item No."),VendorItemNo,ItemNo));
                  if Item.Get(ItemNo) then begin
                    ErrorMessage.Validate("Record ID",Item.RecordId);
                    ErrorMessage.Validate("Message Type",ErrorMessage."Message Type"::Warning);
                  end;
                end else begin
                  ErrorMessage.Validate(Description,StrSubstNo(ItemCouldNotBeMatched, ItemWorksheetLine.FieldCaption("Vendor Item No."),VendorItemNo,ItemWorksheetLine."Worksheet Template Name",ItemWorksheetLine."Worksheet Name"));
                end;
              end else begin
                ErrorMessage.Validate(Description,StrSubstNo(ItemCouldNotBeMatched, ItemWorksheetLine.FieldCaption("Vendor Item No."),VendorItemNo,ItemWorksheetLine."Worksheet Template Name",ItemWorksheetLine."Worksheet Name"));
              end;
            //-NPR5.27 [252817]
            end else begin
              ErrorMessage.Validate(Description,StrSubstNo(ErrorItemWSLineAlreadyCreated, ItemWorksheetLine.FieldCaption("Vendor Item No."),VendorItemNo,ItemWorksheetLine."Worksheet Template Name",ItemWorksheetLine."Worksheet Name"));
            end;
            //+NPR5.27 [252817]
          end else begin
            ErrorMessage.Validate(Description,StrSubstNo(ErrorItemWSLinesNotCreated, ItemWorksheetLine.FieldCaption("Vendor Item No."),VendorItemNo,ItemWorksheetLine."Worksheet Template Name",ItemWorksheetLine."Worksheet Name"));
          end;
          ErrorMessage.Modify(true);
        until ErrorMessage.Next = 0;
        ErrorMessage.Reset;
        ErrorMessage.SetRange("Context Record ID",IncomingDocument.RecordId);
        ErrorMessage.SetRange("Table Number",DATABASE::"Item Worksheet Line");
        ErrorMessage.SetFilter("Field Number",'<>%1',ItemWorksheetLine.FieldNo("Vendor Item No."));
        ErrorMessage.DeleteAll(true);
    end;

    local procedure "--- Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 130, 'OnCheckIncomingDocCreateDocRestrictions', '', true, true)]
    local procedure OnCheckIncomingDocCreateDocRestrictionsCheckReopen(var Sender: Record "Incoming Document")
    var
        ErrorMessage: Record "Error Message";
    begin
        //-NPR5.29 [257500]
        ErrorMessage.Reset;
        ErrorMessage.SetRange("Context Record ID",Sender.RecordId);
        ErrorMessage.SetRange("Table Number",DATABASE::"Item Worksheet Line");
        if not ErrorMessage.FindFirst then
          exit;
        Sender.TestField(Released,false);
        //+NPR5.29 [257500]
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterInsertItemWorksheetLine(var ItemWorksheetLine: Record "Item Worksheet Line")
    begin
    end;
}

