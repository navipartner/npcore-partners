codeunit 6060045 "Item Wsht.-Check Line"
{
    // NPR4.18\BR\20160209  CASE 182391 Object Created
    // NPR4.19\BR\20160216  CASE 182391 Added Support for Tariff No.
    // NPR5.22\BR\20160316  CASE 182391 Fix check
    // NPR5.23\BR\20160513  CASE 241073 Added check on Item No. as alternative item no on create
    // NPR5.25\BR \20160705 CASE 246088 Added validations, andded parameter CalledFromRegister
    // NPR5.29\BR \20161229 CASE 262068 Moved barcode checks from validate on line
    // NPR5.29\TJ \20170119 CASE 263917 Changed how to call function GetFromVariety in function CheckItemWorksheetVariantLine
    // NPR5.35\BR \20170810  CASE 268786 Prevent errors with blank Variety values
    // NPR5.38/BR /20180112 CASE 268786 Only Create Item Worksheet Variety Value lines with "Create New" Item Worksheet Variant Lines
    // NPR5.50/THRO/20190515 CASE 355172 Removed error on internal/external barcode
    // NPR5.52/THRO/20191018 CASE 373596 Change error message for missing item. Added Line No. to error message when StopOnError


    trigger OnRun()
    begin
    end;

    var
        ItemworksheetVarietyValue: Record "Item Worksheet Variety Value";
        ItemWorksheetVariantLine: Record "Item Worksheet Variant Line";
        Text100: Label 'Field %1 on the table %2 record %3 %4 %5 %6 does not match the corresponding Item Worksheet Line record.';
        Text101: Label 'Field %1 on the table %2 record %3 %4 %5 %6 is not valid.';
        Text102: Label '%1 %2 %3 not found.';
        Text103: Label '%1 %2 %3 is locked. A copy needs to be created or the Variety value added manually. ';
        Text104: Label 'Field %1 must be filled.';
        Text105: Label 'Cannot create item %1 because item already exists';
        Text106: Label 'A Variant cannot be created because one already exists for the combination of Varieties: %1: %2, %3: %4, %5: %6, %7: %8.';
        ItemWorksheetTemplate: Record "Item Worksheet Template";
        Text107: Label 'Item No. should be specified in the worksheet line.';
        Text108: Label 'No. Series should be set up when creating items.';
        Text109: Label 'An Item  number must be specified or a No. Series must be manual when processing item no.''s';
        Text110: Label 'The Sales Price Currency Code does not match the Local Currency on line %1. Please set up sales prices on Item+Variant level on the Item Worksheet Template.';
        Text111: Label 'Please specify the Vendor No. for the purchase price registration on line %1.';
        Text112: Label 'Item Group should be specified for item to be created in line %1.';
        Text113: Label 'Description must be filled for all updates and create lines.';
        Text114: Label 'There are multiple Variety lines in the worksheet line with the combination of Varieties: %1: %2, %3: %4, %5: %6, %7: %8.';
        Text115: Label 'There are multiple Variety lines in the worksheet line with Vendors Barcode %1.';
        Text116: Label 'There are multiple Variety lines in the worksheet line with Internal Barcode %1.';
        Text118: Label 'The Purchase Price Currency Code does not match the Local Currency on line %1. Please set up purchase prices on Item+Variant level on the Item Worksheet Template.';
        Text119: Label 'Item Category not found';
        Text120: Label 'Product Group not found';
        Text121: Label 'Variety %1: %2 not specified.';
        Text122: Label 'Variety %2 specifed but not defined in Variety %1. ';
        Text123: Label 'Existing Item No. must be specified for updating.';
        Text124: Label 'Variety %1 does not match setup on item %1. Variety cannot be updated from the worksheet.';
        Text125: Label 'Variety Table %1 does not match setup on item %1. Variety Table cannot be updated from the worksheet.';
        Text126: Label 'Variety tables cannot be copied for existing items from the worksheet.';
        Text127: Label 'Field %1 could not be found in related table. ';
        TariffNumber: Record "Tariff Number";
        Text128: Label 'Item No. %1 is already used as a Barcode/Alternative No. for item %2. ';
        Text130: Label 'Internal Barcodes must start with 2.';
        TExt131: Label 'Vendor Barcodes must not start with 2.';
        Text132: Label '%1 %2 not found.';
        Text133: Label ' - %1: %2';

    [Scope('Personalization')]
    procedure RunCheck(ItemWkshtLine: Record "Item Worksheet Line";StopOnError: Boolean;CalledFromRegister: Boolean)
    var
        RecItem: Record Item;
        NoSeries: Record "No. Series";
        DefaultNoSeries: Code[10];
        ItemCategory: Record "Item Category";
        ProductGroup: Record "Product Group";
        AlternativeNo: Record "Alternative No.";
        ItemWkshtValidateTestRnr: Codeunit "Item Wksht. Validate Test Rnr.";
        ErrorText: Text;
        ItemWshtRegisterLine: Codeunit "Item Wsht.-Register Line";
        ItemWorksheetVariantLineToCreate: Record "Item Worksheet Variant Line";
        IsUpdated: Boolean;
    begin
        with ItemWkshtLine do begin
          if IsEmpty then
            exit;
          if Status = Status :: Error then
            "Status Comment" := '' ;
          Status := Status::Unvalidated;
          ItemWorksheetTemplate.Get("Worksheet Template Name");
          case Action of
            Action :: Skip:
                ;
            Action :: CreateNew :
              begin
                if "Item Group"  = '' then begin
                  ProcessError(ItemWkshtLine,StrSubstNo(Text112,"Line No."),StopOnError);
                end else begin
                  if not NoSeries.Get("No. Series") then begin
                    ProcessError(ItemWkshtLine,StrSubstNo(Text104,FieldCaption("No. Series")),StopOnError)
                  end else begin
                    if "Item No." = '' then begin
                       case ItemWorksheetTemplate."Item No. Creation by" of
                         ItemWorksheetTemplate."Item No. Creation by" :: VendorItemNo :
                           begin
                              ProcessError(ItemWkshtLine,Text107,StopOnError);
                           end;
                         ItemWorksheetTemplate."Item No. Creation by" :: NoSeriesInWorksheet :
                           begin
                             ProcessError(ItemWkshtLine,Text107,StopOnError);
                           end;
                         ItemWorksheetTemplate."Item No. Creation by" :: NoSeriesOnProcessing :
                           begin
                             if not NoSeries."Default Nos." then
                               ProcessError(ItemWkshtLine,Text108,StopOnError);
                           end;
                        end;
                    end else begin
                      if RecItem.Get("Item No.") then begin
                        ProcessError(ItemWkshtLine,StrSubstNo(Text105,"Item No."),StopOnError);
                      end else begin
                        case ItemWorksheetTemplate."Item No. Creation by" of
                          ItemWorksheetTemplate."Item No. Creation by" :: VendorItemNo :
                            begin
                              if not NoSeries."Manual Nos." then
                                ProcessError(ItemWkshtLine,Text109,StopOnError);
                            end;
                          ItemWorksheetTemplate."Item No. Creation by" :: NoSeriesOnProcessing :
                            begin
                              if not NoSeries."Manual Nos." then
                                ProcessError(ItemWkshtLine,Text109,StopOnError);
                            end;
                         end;
                      end;
                    end;
                  end;
                  //-NPR5.29
                  if Status <> Status :: Error then
                    CheckWorksheetLineBarcodes(ItemWkshtLine,StopOnError);
                  //+NPR5.29
                  if Status <> Status :: Error then
                    if "Item Category Code" <> '' then
                      if not ItemCategory.Get("Item Category Code") then
                        ProcessError(ItemWkshtLine,Text119,StopOnError);
                  if Status <> Status :: Error then
                    if "Product Group Code" <> '' then
                      if not ProductGroup.Get("Item Category Code","Product Group Code") then
                        ProcessError(ItemWkshtLine,Text120,StopOnError);
                  //-NPR4.19
                  if Status <> Status :: Error then
                    if "Tariff No." <> '' then
                      if not TariffNumber.Get("Tariff No.") then
                        ProcessError(ItemWkshtLine,StrSubstNo(Text127,FieldCaption("Tariff No.")),StopOnError);
                  //+NPR4.19
                end;
                //-NPR5.23
                if Status <> Status :: Error then begin
                   if "Item No."  <> '' then
                     AlternativeNo.Reset;
                     AlternativeNo.SetRange("Alt. No.","Item No.");
                     if AlternativeNo.FindFirst then
                        ProcessError(ItemWkshtLine,StrSubstNo(Text128,"Item No.",AlternativeNo.Code),StopOnError);
                end;
                //-NPR5.23
                if Status <> Status :: Error then
                  if Description = '' then
                    ProcessError(ItemWkshtLine,StrSubstNo(Text113),StopOnError);
                if Status <> Status :: Error then
                  CheckWorkSheetLinePrices(ItemWkshtLine,StopOnError);
                if Status <> Status :: Error then
                  CheckWorkSheetLineDirectUnitCost(ItemWkshtLine,StopOnError);
              end;

            Action :: UpdateOnly,Action :: UpdateAndCreateVariants :
              begin
                //-NPR5.29
                if Status <> Status :: Error then
                  CheckWorksheetLineBarcodes(ItemWkshtLine,StopOnError);
                //+NPR5.29
                if Status <> Status :: Error then
                  CheckWorkSheetLinePrices(ItemWkshtLine,StopOnError);
                if Status <> Status :: Error then
                  CheckWorkSheetLineDirectUnitCost(ItemWkshtLine,StopOnError);
                if Status <> Status :: Error then
                  if Description = '' then
                    ProcessError(ItemWkshtLine,StrSubstNo(Text113),StopOnError);
                if RecItem.Get("Existing Item No.") then begin
                  if "Variety 1" <>  RecItem."Variety 1" then
                    ProcessError(ItemWkshtLine,StrSubstNo(Text124,1),StopOnError);
                  if "Variety 2" <>  RecItem."Variety 2" then
                    ProcessError(ItemWkshtLine,StrSubstNo(Text124,1),StopOnError);
                  if "Variety 3" <>  RecItem."Variety 3" then
                    ProcessError(ItemWkshtLine,StrSubstNo(Text124,1),StopOnError);
                  if "Variety 4" <>  RecItem."Variety 4" then
                    ProcessError(ItemWkshtLine,StrSubstNo(Text124,1),StopOnError);
                  if "Variety 1 Table (Base)" <>  RecItem."Variety 1 Table" then
                    ProcessError(ItemWkshtLine,StrSubstNo(Text125,1),StopOnError);
                  if "Variety 2 Table (Base)" <>  RecItem."Variety 2 Table" then
                    ProcessError(ItemWkshtLine,StrSubstNo(Text125,1),StopOnError);
                  if "Variety 3 Table (Base)" <>  RecItem."Variety 3 Table" then
                    ProcessError(ItemWkshtLine,StrSubstNo(Text125,1),StopOnError);
                  if "Variety 4 Table (Base)" <>  RecItem."Variety 4 Table" then
                    ProcessError(ItemWkshtLine,StrSubstNo(Text125,1),StopOnError);
                  if "Create Copy of Variety 1 Table" or
                     "Create Copy of Variety 2 Table" or
                     "Create Copy of Variety 3 Table" or
                     "Create Copy of Variety 4 Table" then
                    ProcessError(ItemWkshtLine,Text126,StopOnError);
                  //-NPR5.22
                  //IF "Variety 1 Table (Base)" <>  RecItem."Variety 1 Table" THEN
                  //  ProcessError(ItemWkshtLine,STRSUBSTNO(Text125,1),StopOnError);
                  // IF "Variety 2 Table (Base)" <>  RecItem."Variety 2 Table" THEN
                  //   ProcessError(ItemWkshtLine,STRSUBSTNO(Text125,1),StopOnError);
                  // IF "Variety 3 Table (Base)" <>  RecItem."Variety 3 Table" THEN
                  //   ProcessError(ItemWkshtLine,STRSUBSTNO(Text125,1),StopOnError);
                  // IF "Variety 4 Table (Base)" <>  RecItem."Variety 4 Table" THEN
                  //   ProcessError(ItemWkshtLine,STRSUBSTNO(Text125,1),StopOnError);
                  // IF "Create Copy of Variety 1 Table" OR
                  //    "Create Copy of Variety 2 Table" OR
                  //    "Create Copy of Variety 3 Table" OR
                  //    "Create Copy of Variety 4 Table" THEN
                  //  ProcessError(ItemWkshtLine,Text126,StopOnError);
                  //+NPR5.22
                  //-NPR4.19
                  if Status <> Status :: Error then
                    if "Tariff No." <> '' then
                      if not TariffNumber.Get("Tariff No.") then
                        ProcessError(ItemWkshtLine,StrSubstNo(Text127,FieldCaption("Tariff No.")),StopOnError);
                  //+NPR4.19
                end else begin
                  //-NPR5.52 [373596]
                  if "Existing Item No." <> '' then
                    ProcessError(ItemWkshtLine,StrSubstNo(Text132,RecItem.TableCaption,"Existing Item No."),StopOnError)
                  else
                  //-NPR5.52 [373596]
                    ProcessError(ItemWkshtLine,StrSubstNo(Text123),StopOnError);
                end;
              end;

          end;
          //-NPR5.25 [246088]
          if Action in [Action::UpdateAndCreateVariants,Action::UpdateOnly] then
             ItemWshtRegisterLine.InsertChangeRecords(ItemWkshtLine);
          if ((CalledFromRegister = false) and (ItemWorksheetTemplate."Test Validation" = ItemWorksheetTemplate."Test Validation"::"On Check"))
            or
             ((CalledFromRegister = true) and (ItemWorksheetTemplate."Test Validation" = ItemWorksheetTemplate."Test Validation"::"On Check and On Register")) then begin
            ItemWkshtValidateTestRnr.SetItemWorksheetLine(ItemWkshtLine);
            ItemWkshtValidateTestRnr.Run;
            ErrorText := ItemWkshtValidateTestRnr.GetErrormessage;
            if ErrorText <> '' then begin
              ProcessError(ItemWkshtLine,ErrorText,StopOnError);
            end;
          end;
          //+NPR5.25 [246088]
          ItemWorksheetVariantLine.Reset;
          ItemWorksheetVariantLine.SetRange("Worksheet Template Name","Worksheet Template Name");
          ItemWorksheetVariantLine.SetRange("Worksheet Name","Worksheet Name");
          ItemWorksheetVariantLine.SetRange("Worksheet Line No.","Line No.");
          ItemWorksheetVariantLine.SetFilter("Heading Text",'%1','');
          if ItemWorksheetVariantLine.FindSet then repeat
            CheckItemWorksheetVariantLine(ItemWorksheetVariantLine,ItemWkshtLine,StopOnError);
          until ItemWorksheetVariantLine.Next = 0;

          ItemworksheetVarietyValue.Reset;
          ItemworksheetVarietyValue.SetRange("Worksheet Template Name","Worksheet Template Name");
          ItemworksheetVarietyValue.SetRange("Worksheet Name","Worksheet Name");
          ItemworksheetVarietyValue.SetRange("Worksheet Line No.","Line No.");
          if ItemworksheetVarietyValue.FindSet then repeat
            //-#NPR5.38 [268786]
            //CheckItemWorksheetVarietyLine(ItemworksheetVarietyValue,ItemWkshtLine,StopOnError);
            IsUpdated := false;
            ItemWorksheetVariantLineToCreate.SetRange("Worksheet Template Name",ItemWkshtLine."Worksheet Template Name");
            ItemWorksheetVariantLineToCreate.SetRange("Worksheet Name",ItemWkshtLine."Worksheet Name");
            ItemWorksheetVariantLineToCreate.SetRange("Worksheet Line No.",ItemWkshtLine."Line No.");
            ItemWorksheetVariantLineToCreate.SetRange(Action,ItemWorksheetVariantLineToCreate.Action::CreateNew);
            if ItemWorksheetVariantLineToCreate.FindSet then repeat
              if ((ItemWorksheetVariantLineToCreate."Variety 1" = ItemworksheetVarietyValue.Type) and
                  (ItemWorksheetVariantLineToCreate."Variety 1 Value" = ItemworksheetVarietyValue.Value)) or
                 ((ItemWorksheetVariantLineToCreate."Variety 2" = ItemworksheetVarietyValue.Type) and
                  (ItemWorksheetVariantLineToCreate."Variety 2 Value" = ItemworksheetVarietyValue.Value)) or
                  ((ItemWorksheetVariantLineToCreate."Variety 3" = ItemworksheetVarietyValue.Type) and
                  (ItemWorksheetVariantLineToCreate."Variety 3 Value" = ItemworksheetVarietyValue.Value)) or
                 ((ItemWorksheetVariantLineToCreate."Variety 4" = ItemworksheetVarietyValue.Type) and
                  (ItemWorksheetVariantLineToCreate."Variety 4 Value" = ItemworksheetVarietyValue.Value)) then
              IsUpdated := true;
            until (ItemWorksheetVariantLineToCreate.Next = 0) or IsUpdated;
            if IsUpdated then
              CheckItemWorksheetVarietyLine(ItemworksheetVarietyValue,ItemWkshtLine,StopOnError);
            //+NPR5.38 [268786]
          until ItemworksheetVarietyValue.Next = 0;

          if Status = Status:: Unvalidated then
            Status := Status:: Validated;
          Modify;
        end;
    end;

    local procedure CheckItemWorksheetVariantLine(ItemWorksheetVariantLine: Record "Item Worksheet Variant Line";var ItemWkshtLine: Record "Item Worksheet Line";StopOnError: Boolean)
    var
        ItemWorksheetVariantLine2: Record "Item Worksheet Variant Line";
        VarietyTable: Record "Variety Table";
        ItemVariant: Record "Item Variant";
        Item: Record Item;
        ItemNumberManagement: Codeunit "Item Number Management";
        VarietyCloneData: Codeunit "Variety Clone Data";
    begin
        with ItemWorksheetVariantLine do begin
          if Action = Action::Skip then
            exit;
          if "Item No."  <> ItemWkshtLine."Item No." then
             ProcessError(ItemWkshtLine,StrSubstNo(Text100,FieldCaption("Item No."),TableCaption,"Worksheet Template Name","Worksheet Name","Worksheet Line No.","Line No."),StopOnError);

          if Action = Action :: Update then
            if not ItemVariant.Get("Existing Item No.","Existing Variant Code") then
              ProcessError(ItemWkshtLine,StrSubstNo(Text101,FieldCaption("Item No."),TableCaption,"Worksheet Template Name","Worksheet Name","Worksheet Line No.","Line No."),StopOnError);

          if Action = Action :: CreateNew then
             //-NPR5.29 [263917]
             //IF ItemVariant.GetFromVariety("Item No.", "Variety 1 Value",
             if VarietyCloneData.GetFromVariety(ItemVariant, "Item No.", "Variety 1 Value",
             //+263917 [263917]
                                     "Variety 2 Value", "Variety 3 Value",
                                     "Variety 4 Value") then
                ProcessError(ItemWkshtLine,StrSubstNo(Text106,
                                         ItemWkshtLine."Variety 1","Variety 1 Value",
                                         ItemWkshtLine."Variety 2","Variety 2 Value",
                                         ItemWkshtLine."Variety 3","Variety 3 Value",
                                         ItemWkshtLine."Variety 4","Variety 4 Value"),StopOnError);
          if (Action <> Action ::Skip) and (ItemWkshtLine.Status <> ItemWkshtLine.Status::Error) then  begin
            ItemWorksheetVariantLine2.Reset;
            ItemWorksheetVariantLine2.SetRange("Worksheet Template Name","Worksheet Template Name");
            ItemWorksheetVariantLine2.SetRange("Worksheet Name","Worksheet Name");
            ItemWorksheetVariantLine2.SetRange("Worksheet Line No.","Worksheet Line No.");
            ItemWorksheetVariantLine2.SetFilter("Heading Text",'%1','');
            ItemWorksheetVariantLine2.SetFilter(Action,'<>%1',Action::Skip);
            ItemWorksheetVariantLine2.SetFilter("Line No.",'>%1',"Line No.");
            ItemWorksheetVariantLine2.SetRange("Variety 1 Value","Variety 1 Value");
            ItemWorksheetVariantLine2.SetRange("Variety 2 Value","Variety 2 Value");
            ItemWorksheetVariantLine2.SetRange("Variety 3 Value","Variety 3 Value");
            ItemWorksheetVariantLine2.SetRange("Variety 4 Value","Variety 4 Value");
            if ItemWorksheetVariantLine2.FindFirst then begin
                  ProcessError(ItemWkshtLine,StrSubstNo(Text114,
                                           ItemWkshtLine."Variety 1","Variety 1 Value",
                                           ItemWkshtLine."Variety 2","Variety 2 Value",
                                           ItemWkshtLine."Variety 3","Variety 3 Value",
                                           ItemWkshtLine."Variety 4","Variety 4 Value"),StopOnError);
            end else begin
              if "Vendors Bar Code" <> '' then  begin
                ItemWorksheetVariantLine2.SetRange("Variety 1 Value");
                ItemWorksheetVariantLine2.SetRange("Variety 2 Value");
                ItemWorksheetVariantLine2.SetRange("Variety 3 Value");
                ItemWorksheetVariantLine2.SetRange("Variety 4 Value");
                ItemWorksheetVariantLine2.SetRange("Vendors Bar Code","Vendors Bar Code");
                if ItemWorksheetVariantLine2.FindFirst then begin
                  ProcessError(ItemWkshtLine,StrSubstNo(Text115,"Vendors Bar Code"),StopOnError);
                end else begin
                  if "Internal Bar Code" <> '' then begin
                    ItemWorksheetVariantLine2.SetRange("Internal Bar Code","Internal Bar Code");
                    if ItemWorksheetVariantLine2.FindFirst then begin
                      ProcessError(ItemWkshtLine,StrSubstNo(Text116,"Internal Bar Code"),StopOnError);
                    end;
                  end;
                end;
              end;
            end;
            CalcFields("Variety 1","Variety 2","Variety 3","Variety 4");
            if ("Variety 1 Value" = '') and ("Variety 1" <> '') then
              ProcessError(ItemWkshtLine,StrSubstNo(Text121,1,"Variety 1"),StopOnError);
            if ("Variety 2 Value" = '') and ("Variety 2" <> '') then
              ProcessError(ItemWkshtLine,StrSubstNo(Text121,2,"Variety 2"),StopOnError);
            if ("Variety 3 Value" = '') and ("Variety 3" <> '') then
              ProcessError(ItemWkshtLine,StrSubstNo(Text121,3,"Variety 3"),StopOnError);
            if ("Variety 4 Value" = '') and ("Variety 4" <> '') then
              ProcessError(ItemWkshtLine,StrSubstNo(Text121,4,"Variety 4"),StopOnError);

            if ("Variety 1 Value" <> '') and ("Variety 1" = '') then
              ProcessError(ItemWkshtLine,StrSubstNo(Text122,1,"Variety 1 Value"),StopOnError);
            if ("Variety 2 Value" <> '') and ("Variety 2" = '') then
              ProcessError(ItemWkshtLine,StrSubstNo(Text122,2,"Variety 2 Value"),StopOnError);
            if ("Variety 3 Value" <> '') and ("Variety 3" = '') then
              ProcessError(ItemWkshtLine,StrSubstNo(Text122,3,"Variety 3 Value"),StopOnError);
            if ("Variety 4 Value" <> '') and ("Variety 4" = '') then
              ProcessError(ItemWkshtLine,StrSubstNo(Text122,4,"Variety 4 Value"),StopOnError);
          end;
          //-NPR5.29 [262068]
          //-NPR5.50 [355172]
          //IF (ItemWkshtLine.Status <> ItemWkshtLine.Status::Error) AND ("Internal Bar Code" <> '') THEN  BEGIN
          //  IF NOT ItemNumberManagement.IsInternalBarcode("Internal Bar Code") THEN
          //    ProcessError(ItemWkshtLine,Text130,StopOnError);
          //END;
          //IF (ItemWkshtLine.Status <> ItemWkshtLine.Status::Error) AND ("Vendors Bar Code" <> '') THEN  BEGIN
          //  IF ItemNumberManagement.IsInternalBarcode("Vendors Bar Code") THEN
          //    ProcessError(ItemWkshtLine,TExt131,StopOnError);
          //END;
          //+NPR5.50 [355172]
          //+NPR5.29 [262068]
        end;
    end;

    local procedure CheckItemWorksheetVarietyLine(ItemWorksheetVarietyLine: Record "Item Worksheet Variety Value";var ItemWkshtLine: Record "Item Worksheet Line";StopOnError: Boolean)
    var
        VarietyTable: Record "Variety Table";
        VarietyValue: Record "Variety Value";
        ItemVariant: Record "Item Variant";
        Item: Record Item;
    begin
        with ItemWorksheetVarietyLine do begin
          //-NPR5.35 [268786]
          //IF Type <>'' THEN BEGIN
          if (Type <>'') and (Table <> '') and (Value <> '') then begin
          //-NPR5.35 [268786]
            if not VarietyValue.Get(Type,Table,Value) then begin
              if not VarietyTable.Get(Type,Table) then begin
                ProcessError(ItemWkshtLine,StrSubstNo(Text102,VarietyTable.TableCaption,Type,Value),StopOnError)
              end else begin
                if VarietyTable."Lock Table" then begin
                  case VarietyTable.Type  of
                    ItemWkshtLine."Variety 1" :
                      begin
                        if not ItemWkshtLine."Create Copy of Variety 1 Table" then
                          ProcessError(ItemWkshtLine,StrSubstNo(Text103,VarietyTable.TableCaption,Type,Value),StopOnError);
                      end;
                    ItemWkshtLine."Variety 2" :
                      begin
                        if not ItemWkshtLine."Create Copy of Variety 2 Table" then
                          ProcessError(ItemWkshtLine,StrSubstNo(Text103,VarietyTable.TableCaption,Type,Value),StopOnError);
                      end;
                    ItemWkshtLine."Variety 3" :
                      begin
                        if not ItemWkshtLine."Create Copy of Variety 3 Table" then
                          ProcessError(ItemWkshtLine,StrSubstNo(Text103,VarietyTable.TableCaption,Type,Value),StopOnError);
                      end;
                    ItemWkshtLine."Variety 4" :
                      begin
                        if not ItemWkshtLine."Create Copy of Variety 4 Table" then
                          ProcessError(ItemWkshtLine,StrSubstNo(Text103,VarietyTable.TableCaption,Type,Value),StopOnError);
                      end;
                  end;
                end;
              end;
            end;
          end;
        end;
    end;

    local procedure CheckWorkSheetLinePrices(var ItemWkshtLine: Record "Item Worksheet Line";StopOnError: Boolean)
    var
        GLSetup: Record "General Ledger Setup";
    begin
        if ItemWorksheetTemplate."Sales Price Handling" = ItemWorksheetTemplate."Sales Price Handling" :: Item then begin
          if ItemWkshtLine."Sales Price Currency Code" <> '' then begin
            if GLSetup."LCY Code" <> ItemWkshtLine."Currency Code" then begin
               ProcessError(ItemWkshtLine,StrSubstNo(Text110,ItemWkshtLine."Currency Code"),StopOnError);
            end;
          end;
        end;
    end;

    local procedure CheckWorkSheetLineDirectUnitCost(var ItemWkshtLine: Record "Item Worksheet Line";StopOnError: Boolean)
    var
        GLSetup: Record "General Ledger Setup";
    begin
        if ItemWorksheetTemplate."Purchase Price Handling" = ItemWorksheetTemplate."Purchase Price Handling" :: Item then begin
          if (ItemWkshtLine."Purchase Price Currency Code" <> '') and (ItemWkshtLine."Direct Unit Cost" <> 0) then begin
            if GLSetup."LCY Code" <> ItemWkshtLine."Purchase Price Currency Code" then begin
               ProcessError(ItemWkshtLine,StrSubstNo(Text118,ItemWkshtLine."Line No."),StopOnError);
            end;
          end;
        end;
        if ItemWorksheetTemplate."Purchase Price Handling" = ItemWorksheetTemplate."Purchase Price Handling" :: "Item+Variant" then begin
          if ItemWkshtLine."Vendor No." = '' then begin
            if ItemWkshtLine."Direct Unit Cost" <> 0 then begin
               ProcessError(ItemWkshtLine,StrSubstNo(Text111,ItemWkshtLine."Line No."),StopOnError);
            end else begin
               ItemWorksheetVariantLine.Reset;
               ItemWorksheetVariantLine.SetRange("Worksheet Template Name",ItemWkshtLine."Worksheet Template Name");
               ItemWorksheetVariantLine.SetRange("Worksheet Name",ItemWkshtLine."Worksheet Name");
               ItemWorksheetVariantLine.SetRange("Worksheet Line No.",ItemWkshtLine."Line No.");
               ItemWorksheetVariantLine.SetFilter(Action,'<>%1',ItemWkshtLine.Action::Skip);
               ItemWorksheetVariantLine.SetFilter("Direct Unit Cost",'<>0');
               if ItemWorksheetVariantLine.FindFirst then begin
                 ProcessError(ItemWkshtLine,StrSubstNo(Text111,ItemWkshtLine."Line No."),StopOnError);
               end;
            end;
          end;
        end;
    end;

    local procedure CheckWorksheetLineBarcodes(var ItemWkshtLine: Record "Item Worksheet Line";StopOnError: Boolean)
    var
        ItemNumberManagement: Codeunit "Item Number Management";
    begin
        //-NPR5.29 [262068]
        //-NPR5.50 [355172]
        //IF (ItemWkshtLine.Status <> ItemWkshtLine.Status::Error) AND (ItemWkshtLine."Internal Bar Code" <> '') THEN  BEGIN
        //  IF NOT ItemNumberManagement.IsInternalBarcode(ItemWkshtLine."Internal Bar Code") THEN
        //    ProcessError(ItemWkshtLine,Text130,StopOnError);
        //END;
        //IF (ItemWkshtLine.Status <> ItemWkshtLine.Status::Error) AND (ItemWkshtLine."Vendors Bar Code" <> '') THEN  BEGIN
        //  IF ItemNumberManagement.IsInternalBarcode(ItemWkshtLine."Vendors Bar Code") THEN
        //    ProcessError(ItemWkshtLine,TExt131,StopOnError);
        //END;
        //+NPR5.50 [355172]
        //+NPR5.29 [262068]
    end;

    local procedure ProcessError(var ItemWkshtLine: Record "Item Worksheet Line";ErrorText: Text[1024];StopOnError: Boolean)
    begin
        if StopOnError then begin
          //-NPR5.52 [373596]
          if ItemWkshtLine."Line No." <> 0 then
            ErrorText += StrSubstNo(Text133,ItemWkshtLine.FieldCaption("Line No."),ItemWkshtLine."Line No.");
          //+NPR5.52 [373596]
          Error(ErrorText)
        end else begin
          if ItemWkshtLine.Status = ItemWkshtLine.Status::Error then begin
            ItemWkshtLine."Status Comment" := CopyStr(ItemWkshtLine."Status Comment" + ' - ' + ErrorText,1,MaxStrLen(ItemWkshtLine."Status Comment"));
          end else begin
            ItemWkshtLine.Status := ItemWkshtLine.Status::Error;
            ItemWkshtLine."Status Comment" := CopyStr(ErrorText,1,MaxStrLen(ItemWkshtLine."Status Comment"));
          end;
          //ItemWkshtLine.MODIFY;
        end;
    end;
}

