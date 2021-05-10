codeunit 6060045 "NPR Item Wsht.-Check Line"
{
    var
        ItemWorksheetTemplate: Record "NPR Item Worksh. Template";
        ItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line";
        ItemworksheetVarietyValue: Record "NPR Item Worksh. Variety Value";
        TariffNumber: Record "Tariff Number";
        Text103: Label '%1 %2 %3 is locked. A copy needs to be created or the Variety value added manually. ';
        Text102: Label '%1 %2 %3 not found.';
        Text132: Label '%1 %2 not found.';
        Text133: Label ' - %1: %2';
        Text109: Label 'An Item  number must be specified or a No. Series must be manual when processing item no.''s';
        Text106: Label 'A Variant cannot be created because one already exists for the combination of Varieties: %1: %2, %3: %4, %5: %6, %7: %8.';
        Text105: Label 'Cannot create item %1 because item already exists';
        Text113: Label 'Description must be filled for all updates and create lines.';
        Text123: Label 'Existing Item No. must be specified for updating.';
        Text127: Label 'Field %1 could not be found in related table. ';
        Text104: Label 'Field %1 must be filled.';
        Text100: Label 'Field %1 on the table %2 record %3 %4 %5 %6 does not match the corresponding Item Worksheet Line record.';
        Text101: Label 'Field %1 on the table %2 record %3 %4 %5 %6 is not valid.';
        Text119: Label 'Item Category not found';
        Text112: Label 'Item Group should be specified for item to be created in line %1.';
        Text107: Label 'Item No. should be specified in the worksheet line.';
        Text108: Label 'No. Series should be set up when creating items.';
        Text111: Label 'Please specify the Vendor No. for the purchase price registration on line %1.';
        Text118: Label 'The Purchase Price Currency Code does not match the Local Currency on line %1. Please set up purchase prices on Item+Variant level on the Item Worksheet Template.';
        Text116: Label 'There are multiple Variety lines in the worksheet line with Internal Barcode %1.';
        Text114: Label 'There are multiple Variety lines in the worksheet line with the combination of Varieties: %1: %2, %3: %4, %5: %6, %7: %8.';
        Text115: Label 'There are multiple Variety lines in the worksheet line with Vendors Barcode %1.';
        Text110: Label 'The Sales Price Currency Code does not match the Local Currency on line %1. Please set up sales prices on Item+Variant level on the Item Worksheet Template.';
        Text121: Label 'Variety %1: %2 not specified.';
        Text124: Label 'Variety %1 does not match setup on item %1. Variety cannot be updated from the worksheet.';
        Text122: Label 'Variety %2 specifed but not defined in Variety %1. ';
        Text125: Label 'Variety Table %1 does not match setup on item %1. Variety Table cannot be updated from the worksheet.';
        Text126: Label 'Variety tables cannot be copied for existing items from the worksheet.';

    procedure RunCheck(ItemWkshtLine: Record "NPR Item Worksheet Line"; StopOnError: Boolean; CalledFromRegister: Boolean)
    var
        RecItem: Record Item;
        ItemCategory: Record "Item Category";
        NoSeries: Record "No. Series";
        ItemWorksheetVariantLineToCreate: Record "NPR Item Worksh. Variant Line";
        ItemWkshtValidateTestRnr: Codeunit "NPR Item Wksht.Valid.Test Rnr.";
        ItemWshtRegisterLine: Codeunit "NPR Item Wsht.Register Line";
        IsUpdated: Boolean;
        ErrorText: Text;
    begin
        if ItemWkshtLine.IsEmpty then
            exit;
        if ItemWkshtLine.Status = ItemWkshtLine.Status::Error then
            ItemWkshtLine."Status Comment" := '';
        ItemWkshtLine.Status := ItemWkshtLine.Status::Unvalidated;
        ItemWorksheetTemplate.Get(ItemWkshtLine."Worksheet Template Name");
        case ItemWkshtLine.Action of
            ItemWkshtLine.Action::Skip:
                ;
            ItemWkshtLine.Action::CreateNew:
                begin
                    if ItemWkshtLine."Item Category Code" = '' then begin
                        ProcessError(ItemWkshtLine, StrSubstNo(Text112, ItemWkshtLine."Line No."), StopOnError);
                    end else begin
                        if not NoSeries.Get(ItemWkshtLine."No. Series") then begin
                            ProcessError(ItemWkshtLine, StrSubstNo(Text104, ItemWkshtLine.FieldCaption("No. Series")), StopOnError)
                        end else begin
                            if ItemWkshtLine."Item No." = '' then begin
                                case ItemWorksheetTemplate."Item No. Creation by" of
                                    ItemWorksheetTemplate."Item No. Creation by"::VendorItemNo:
                                        ProcessError(ItemWkshtLine, Text107, StopOnError);
                                    ItemWorksheetTemplate."Item No. Creation by"::NoSeriesInWorksheet:
                                        ProcessError(ItemWkshtLine, Text107, StopOnError);
                                    ItemWorksheetTemplate."Item No. Creation by"::NoSeriesOnProcessing:
                                        begin
                                            if not NoSeries."Default Nos." then
                                                ProcessError(ItemWkshtLine, Text108, StopOnError);
                                        end;
                                end;
                            end else begin
                                if RecItem.Get(ItemWkshtLine."Item No.") then
                                    ProcessError(ItemWkshtLine, StrSubstNo(Text105, ItemWkshtLine."Item No."), StopOnError)
                                else begin
                                    case ItemWorksheetTemplate."Item No. Creation by" of
                                        ItemWorksheetTemplate."Item No. Creation by"::VendorItemNo:
                                            begin
                                                if not NoSeries."Manual Nos." then
                                                    ProcessError(ItemWkshtLine, Text109, StopOnError);
                                            end;
                                        ItemWorksheetTemplate."Item No. Creation by"::NoSeriesOnProcessing:
                                            begin
                                                if not NoSeries."Manual Nos." then
                                                    ProcessError(ItemWkshtLine, Text109, StopOnError);
                                            end;
                                    end;
                                end;
                            end;
                        end;
                        if ItemWkshtLine.Status <> ItemWkshtLine.Status::Error then
                            if ItemWkshtLine."Item Category Code" <> '' then
                                if not ItemCategory.Get(ItemWkshtLine."Item Category Code") then
                                    ProcessError(ItemWkshtLine, Text119, StopOnError);
                        if ItemWkshtLine.Status <> ItemWkshtLine.Status::Error then
                            if ItemWkshtLine."Tariff No." <> '' then
                                if not TariffNumber.Get(ItemWkshtLine."Tariff No.") then
                                    ProcessError(ItemWkshtLine, StrSubstNo(Text127, ItemWkshtLine.FieldCaption("Tariff No.")), StopOnError);
                    end;
                    if ItemWkshtLine.Status <> ItemWkshtLine.Status::Error then
                        if ItemWkshtLine.Description = '' then
                            ProcessError(ItemWkshtLine, StrSubstNo(Text113), StopOnError);
                    if ItemWkshtLine.Status <> ItemWkshtLine.Status::Error then
                        CheckWorkSheetLinePrices(ItemWkshtLine, StopOnError);
                    if ItemWkshtLine.Status <> ItemWkshtLine.Status::Error then
                        CheckWorkSheetLineDirectUnitCost(ItemWkshtLine, StopOnError);
                end;

            ItemWkshtLine.Action::UpdateOnly, ItemWkshtLine.Action::UpdateAndCreateVariants:
                begin
                    if ItemWkshtLine.Status <> ItemWkshtLine.Status::Error then
                        CheckWorkSheetLinePrices(ItemWkshtLine, StopOnError);
                    if ItemWkshtLine.Status <> ItemWkshtLine.Status::Error then
                        CheckWorkSheetLineDirectUnitCost(ItemWkshtLine, StopOnError);
                    if ItemWkshtLine.Status <> ItemWkshtLine.Status::Error then
                        if ItemWkshtLine.Description = '' then
                            ProcessError(ItemWkshtLine, StrSubstNo(Text113), StopOnError);
                    if RecItem.Get(ItemWkshtLine."Existing Item No.") then begin
                        if ItemWkshtLine."Variety 1" <> RecItem."NPR Variety 1" then
                            ProcessError(ItemWkshtLine, StrSubstNo(Text124, 1), StopOnError);
                        if ItemWkshtLine."Variety 2" <> RecItem."NPR Variety 2" then
                            ProcessError(ItemWkshtLine, StrSubstNo(Text124, 1), StopOnError);
                        if ItemWkshtLine."Variety 3" <> RecItem."NPR Variety 3" then
                            ProcessError(ItemWkshtLine, StrSubstNo(Text124, 1), StopOnError);
                        if ItemWkshtLine."Variety 4" <> RecItem."NPR Variety 4" then
                            ProcessError(ItemWkshtLine, StrSubstNo(Text124, 1), StopOnError);
                        if ItemWkshtLine."Variety 1 Table (Base)" <> RecItem."NPR Variety 1 Table" then
                            ProcessError(ItemWkshtLine, StrSubstNo(Text125, 1), StopOnError);
                        if ItemWkshtLine."Variety 2 Table (Base)" <> RecItem."NPR Variety 2 Table" then
                            ProcessError(ItemWkshtLine, StrSubstNo(Text125, 1), StopOnError);
                        if ItemWkshtLine."Variety 3 Table (Base)" <> RecItem."NPR Variety 3 Table" then
                            ProcessError(ItemWkshtLine, StrSubstNo(Text125, 1), StopOnError);
                        if ItemWkshtLine."Variety 4 Table (Base)" <> RecItem."NPR Variety 4 Table" then
                            ProcessError(ItemWkshtLine, StrSubstNo(Text125, 1), StopOnError);
                        if ItemWkshtLine."Create Copy of Variety 1 Table" or
                           ItemWkshtLine."Create Copy of Variety 2 Table" or
                           ItemWkshtLine."Create Copy of Variety 3 Table" or
                           ItemWkshtLine."Create Copy of Variety 4 Table" then
                            ProcessError(ItemWkshtLine, Text126, StopOnError);
                        if ItemWkshtLine.Status <> ItemWkshtLine.Status::Error then
                            if ItemWkshtLine."Tariff No." <> '' then
                                if not TariffNumber.Get(ItemWkshtLine."Tariff No.") then
                                    ProcessError(ItemWkshtLine, StrSubstNo(Text127, ItemWkshtLine.FieldCaption("Tariff No.")), StopOnError);
                    end else begin
                        if ItemWkshtLine."Existing Item No." <> '' then
                            ProcessError(ItemWkshtLine, StrSubstNo(Text132, RecItem.TableCaption, ItemWkshtLine."Existing Item No."), StopOnError)
                        else
                            ProcessError(ItemWkshtLine, StrSubstNo(Text123), StopOnError);
                    end;
                end;

        end;
        if ItemWkshtLine.Action in [ItemWkshtLine.Action::UpdateAndCreateVariants, ItemWkshtLine.Action::UpdateOnly] then
            ItemWshtRegisterLine.InsertChangeRecords(ItemWkshtLine);
        if ((CalledFromRegister = false) and (ItemWorksheetTemplate."Test Validation" = ItemWorksheetTemplate."Test Validation"::"On Check"))
          or
           ((CalledFromRegister = true) and (ItemWorksheetTemplate."Test Validation" = ItemWorksheetTemplate."Test Validation"::"On Check and On Register")) then begin
            ItemWkshtValidateTestRnr.SetItemWorksheetLine(ItemWkshtLine);
            ItemWkshtValidateTestRnr.Run();
            ErrorText := ItemWkshtValidateTestRnr.GetErrormessage();
            if ErrorText <> '' then begin
                ProcessError(ItemWkshtLine, ErrorText, StopOnError);
            end;
        end;
        ItemWorksheetVariantLine.Reset();
        ItemWorksheetVariantLine.SetRange("Worksheet Template Name", ItemWkshtLine."Worksheet Template Name");
        ItemWorksheetVariantLine.SetRange("Worksheet Name", ItemWkshtLine."Worksheet Name");
        ItemWorksheetVariantLine.SetRange("Worksheet Line No.", ItemWkshtLine."Line No.");
        ItemWorksheetVariantLine.SetFilter("Heading Text", '%1', '');
        if ItemWorksheetVariantLine.FindSet() then
            repeat
                CheckItemWorksheetVariantLine(ItemWorksheetVariantLine, ItemWkshtLine, StopOnError);
            until ItemWorksheetVariantLine.Next() = 0;

        ItemworksheetVarietyValue.Reset();
        ItemworksheetVarietyValue.SetRange("Worksheet Template Name", ItemWkshtLine."Worksheet Template Name");
        ItemworksheetVarietyValue.SetRange("Worksheet Name", ItemWkshtLine."Worksheet Name");
        ItemworksheetVarietyValue.SetRange("Worksheet Line No.", ItemWkshtLine."Line No.");
        if ItemworksheetVarietyValue.FindSet() then
            repeat
                IsUpdated := false;
                ItemWorksheetVariantLineToCreate.SetRange("Worksheet Template Name", ItemWkshtLine."Worksheet Template Name");
                ItemWorksheetVariantLineToCreate.SetRange("Worksheet Name", ItemWkshtLine."Worksheet Name");
                ItemWorksheetVariantLineToCreate.SetRange("Worksheet Line No.", ItemWkshtLine."Line No.");
                ItemWorksheetVariantLineToCreate.SetRange(Action, ItemWorksheetVariantLineToCreate.Action::CreateNew);
                if ItemWorksheetVariantLineToCreate.FindSet() then
                    repeat
                        if ((ItemWorksheetVariantLineToCreate."Variety 1" = ItemworksheetVarietyValue.Type) and
                            (ItemWorksheetVariantLineToCreate."Variety 1 Value" = ItemworksheetVarietyValue.Value)) or
                           ((ItemWorksheetVariantLineToCreate."Variety 2" = ItemworksheetVarietyValue.Type) and
                            (ItemWorksheetVariantLineToCreate."Variety 2 Value" = ItemworksheetVarietyValue.Value)) or
                            ((ItemWorksheetVariantLineToCreate."Variety 3" = ItemworksheetVarietyValue.Type) and
                            (ItemWorksheetVariantLineToCreate."Variety 3 Value" = ItemworksheetVarietyValue.Value)) or
                           ((ItemWorksheetVariantLineToCreate."Variety 4" = ItemworksheetVarietyValue.Type) and
                            (ItemWorksheetVariantLineToCreate."Variety 4 Value" = ItemworksheetVarietyValue.Value)) then
                            IsUpdated := true;
                    until (ItemWorksheetVariantLineToCreate.Next() = 0) or IsUpdated;
                if IsUpdated then
                    CheckItemWorksheetVarietyLine(ItemworksheetVarietyValue, ItemWkshtLine, StopOnError);
            until ItemworksheetVarietyValue.Next() = 0;

        if ItemWkshtLine.Status = ItemWkshtLine.Status::Unvalidated then
            ItemWkshtLine.Status := ItemWkshtLine.Status::Validated;
        ItemWkshtLine.Modify();
    end;

    local procedure CheckItemWorksheetVariantLine(ItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line"; var ItemWkshtLine: Record "NPR Item Worksheet Line"; StopOnError: Boolean)
    var
        ItemVariant: Record "Item Variant";
        ItemWorksheetVariantLine2: Record "NPR Item Worksh. Variant Line";
        VarietyCloneData: Codeunit "NPR Variety Clone Data";
    begin
        if ItemWorksheetVariantLine.Action = ItemWorksheetVariantLine.Action::Skip then
            exit;
        if ItemWorksheetVariantLine."Item No." <> ItemWkshtLine."Item No." then
            ProcessError(ItemWkshtLine, StrSubstNo(Text100, ItemWorksheetVariantLine.FieldCaption("Item No."), ItemWorksheetVariantLine.TableCaption, ItemWorksheetVariantLine."Worksheet Template Name", ItemWorksheetVariantLine."Worksheet Name", ItemWorksheetVariantLine."Worksheet Line No.", ItemWorksheetVariantLine."Line No."), StopOnError);

        if ItemWorksheetVariantLine.Action = ItemWorksheetVariantLine.Action::Update then
            if not ItemVariant.Get(ItemWorksheetVariantLine."Existing Item No.", ItemWorksheetVariantLine."Existing Variant Code") then
                ProcessError(ItemWkshtLine, StrSubstNo(Text101, ItemWorksheetVariantLine.FieldCaption("Item No."), ItemWorksheetVariantLine.TableCaption, ItemWorksheetVariantLine."Worksheet Template Name", ItemWorksheetVariantLine."Worksheet Name", ItemWorksheetVariantLine."Worksheet Line No.", ItemWorksheetVariantLine."Line No."), StopOnError);

        if ItemWorksheetVariantLine.Action = ItemWorksheetVariantLine.Action::CreateNew then
            if VarietyCloneData.GetFromVariety(ItemVariant, ItemWorksheetVariantLine."Item No.", ItemWorksheetVariantLine."Variety 1 Value",
                                 ItemWorksheetVariantLine."Variety 2 Value", ItemWorksheetVariantLine."Variety 3 Value",
                                 ItemWorksheetVariantLine."Variety 4 Value") then
                ProcessError(ItemWkshtLine, StrSubstNo(Text106,
                                         ItemWkshtLine."Variety 1", ItemWorksheetVariantLine."Variety 1 Value",
                                         ItemWkshtLine."Variety 2", ItemWorksheetVariantLine."Variety 2 Value",
                                         ItemWkshtLine."Variety 3", ItemWorksheetVariantLine."Variety 3 Value",
                                         ItemWkshtLine."Variety 4", ItemWorksheetVariantLine."Variety 4 Value"), StopOnError);
        if (ItemWorksheetVariantLine.Action <> ItemWorksheetVariantLine.Action::Skip) and (ItemWkshtLine.Status <> ItemWkshtLine.Status::Error) then begin
            ItemWorksheetVariantLine2.Reset();
            ItemWorksheetVariantLine2.SetRange("Worksheet Template Name", ItemWorksheetVariantLine."Worksheet Template Name");
            ItemWorksheetVariantLine2.SetRange("Worksheet Name", ItemWorksheetVariantLine."Worksheet Name");
            ItemWorksheetVariantLine2.SetRange("Worksheet Line No.", ItemWorksheetVariantLine."Worksheet Line No.");
            ItemWorksheetVariantLine2.SetFilter("Heading Text", '%1', '');
            ItemWorksheetVariantLine2.SetFilter(Action, '<>%1', ItemWorksheetVariantLine.Action::Skip);
            ItemWorksheetVariantLine2.SetFilter("Line No.", '>%1', ItemWorksheetVariantLine."Line No.");
            ItemWorksheetVariantLine2.SetRange("Variety 1 Value", ItemWorksheetVariantLine."Variety 1 Value");
            ItemWorksheetVariantLine2.SetRange("Variety 2 Value", ItemWorksheetVariantLine."Variety 2 Value");
            ItemWorksheetVariantLine2.SetRange("Variety 3 Value", ItemWorksheetVariantLine."Variety 3 Value");
            ItemWorksheetVariantLine2.SetRange("Variety 4 Value", ItemWorksheetVariantLine."Variety 4 Value");
            if ItemWorksheetVariantLine2.FindFirst() then begin
                ProcessError(ItemWkshtLine, StrSubstNo(Text114,
                                         ItemWkshtLine."Variety 1", ItemWorksheetVariantLine."Variety 1 Value",
                                         ItemWkshtLine."Variety 2", ItemWorksheetVariantLine."Variety 2 Value",
                                         ItemWkshtLine."Variety 3", ItemWorksheetVariantLine."Variety 3 Value",
                                         ItemWkshtLine."Variety 4", ItemWorksheetVariantLine."Variety 4 Value"), StopOnError);
            end else begin
                if ItemWorksheetVariantLine."Vendors Bar Code" <> '' then begin
                    ItemWorksheetVariantLine2.SetRange("Variety 1 Value");
                    ItemWorksheetVariantLine2.SetRange("Variety 2 Value");
                    ItemWorksheetVariantLine2.SetRange("Variety 3 Value");
                    ItemWorksheetVariantLine2.SetRange("Variety 4 Value");
                    ItemWorksheetVariantLine2.SetRange("Vendors Bar Code", ItemWorksheetVariantLine."Vendors Bar Code");
                    if ItemWorksheetVariantLine2.FindFirst() then begin
                        ProcessError(ItemWkshtLine, StrSubstNo(Text115, ItemWorksheetVariantLine."Vendors Bar Code"), StopOnError);
                    end else begin
                        if ItemWorksheetVariantLine."Internal Bar Code" <> '' then begin
                            ItemWorksheetVariantLine2.SetRange("Internal Bar Code", ItemWorksheetVariantLine."Internal Bar Code");
                            if ItemWorksheetVariantLine2.FindFirst() then begin
                                ProcessError(ItemWkshtLine, StrSubstNo(Text116, ItemWorksheetVariantLine."Internal Bar Code"), StopOnError);
                            end;
                        end;
                    end;
                end;
            end;
            ItemWorksheetVariantLine.CalcFields("Variety 1", "Variety 2", "Variety 3", "Variety 4");
            if (ItemWorksheetVariantLine."Variety 1 Value" = '') and (ItemWorksheetVariantLine."Variety 1" <> '') then
                ProcessError(ItemWkshtLine, StrSubstNo(Text121, 1, ItemWorksheetVariantLine."Variety 1"), StopOnError);
            if (ItemWorksheetVariantLine."Variety 2 Value" = '') and (ItemWorksheetVariantLine."Variety 2" <> '') then
                ProcessError(ItemWkshtLine, StrSubstNo(Text121, 2, ItemWorksheetVariantLine."Variety 2"), StopOnError);
            if (ItemWorksheetVariantLine."Variety 3 Value" = '') and (ItemWorksheetVariantLine."Variety 3" <> '') then
                ProcessError(ItemWkshtLine, StrSubstNo(Text121, 3, ItemWorksheetVariantLine."Variety 3"), StopOnError);
            if (ItemWorksheetVariantLine."Variety 4 Value" = '') and (ItemWorksheetVariantLine."Variety 4" <> '') then
                ProcessError(ItemWkshtLine, StrSubstNo(Text121, 4, ItemWorksheetVariantLine."Variety 4"), StopOnError);

            if (ItemWorksheetVariantLine."Variety 1 Value" <> '') and (ItemWorksheetVariantLine."Variety 1" = '') then
                ProcessError(ItemWkshtLine, StrSubstNo(Text122, 1, ItemWorksheetVariantLine."Variety 1 Value"), StopOnError);
            if (ItemWorksheetVariantLine."Variety 2 Value" <> '') and (ItemWorksheetVariantLine."Variety 2" = '') then
                ProcessError(ItemWkshtLine, StrSubstNo(Text122, 2, ItemWorksheetVariantLine."Variety 2 Value"), StopOnError);
            if (ItemWorksheetVariantLine."Variety 3 Value" <> '') and (ItemWorksheetVariantLine."Variety 3" = '') then
                ProcessError(ItemWkshtLine, StrSubstNo(Text122, 3, ItemWorksheetVariantLine."Variety 3 Value"), StopOnError);
            if (ItemWorksheetVariantLine."Variety 4 Value" <> '') and (ItemWorksheetVariantLine."Variety 4" = '') then
                ProcessError(ItemWkshtLine, StrSubstNo(Text122, 4, ItemWorksheetVariantLine."Variety 4 Value"), StopOnError);
        end;
    end;

    local procedure CheckItemWorksheetVarietyLine(ItemWorksheetVarietyLine: Record "NPR Item Worksh. Variety Value"; var ItemWkshtLine: Record "NPR Item Worksheet Line"; StopOnError: Boolean)
    var
        VarietyTable: Record "NPR Variety Table";
        VarietyValue: Record "NPR Variety Value";
    begin
        if (ItemWorksheetVarietyLine.Type <> '') and (ItemWorksheetVarietyLine.Table <> '') and (ItemWorksheetVarietyLine.Value <> '') then begin
            if not VarietyValue.Get(ItemWorksheetVarietyLine.Type, ItemWorksheetVarietyLine.Table, ItemWorksheetVarietyLine.Value) then begin
                if not VarietyTable.Get(ItemWorksheetVarietyLine.Type, ItemWorksheetVarietyLine.Table) then begin
                    ProcessError(ItemWkshtLine, StrSubstNo(Text102, VarietyTable.TableCaption, ItemWorksheetVarietyLine.Type, ItemWorksheetVarietyLine.Value), StopOnError)
                end else begin
                    if VarietyTable."Lock Table" then begin
                        case VarietyTable.Type of
                            ItemWkshtLine."Variety 1":
                                begin
                                    if not ItemWkshtLine."Create Copy of Variety 1 Table" then
                                        ProcessError(ItemWkshtLine, StrSubstNo(Text103, VarietyTable.TableCaption, ItemWorksheetVarietyLine.Type, ItemWorksheetVarietyLine.Value), StopOnError);
                                end;
                            ItemWkshtLine."Variety 2":
                                begin
                                    if not ItemWkshtLine."Create Copy of Variety 2 Table" then
                                        ProcessError(ItemWkshtLine, StrSubstNo(Text103, VarietyTable.TableCaption, ItemWorksheetVarietyLine.Type, ItemWorksheetVarietyLine.Value), StopOnError);
                                end;
                            ItemWkshtLine."Variety 3":
                                begin
                                    if not ItemWkshtLine."Create Copy of Variety 3 Table" then
                                        ProcessError(ItemWkshtLine, StrSubstNo(Text103, VarietyTable.TableCaption, ItemWorksheetVarietyLine.Type, ItemWorksheetVarietyLine.Value), StopOnError);
                                end;
                            ItemWkshtLine."Variety 4":
                                begin
                                    if not ItemWkshtLine."Create Copy of Variety 4 Table" then
                                        ProcessError(ItemWkshtLine, StrSubstNo(Text103, VarietyTable.TableCaption, ItemWorksheetVarietyLine.Type, ItemWorksheetVarietyLine.Value), StopOnError);
                                end;
                        end;
                    end;
                end;
            end;
        end;
    end;

    local procedure CheckWorkSheetLinePrices(var ItemWkshtLine: Record "NPR Item Worksheet Line"; StopOnError: Boolean)
    var
        GLSetup: Record "General Ledger Setup";
    begin
        if ItemWorksheetTemplate."Sales Price Handling" = ItemWorksheetTemplate."Sales Price Handling"::Item then begin
            if ItemWkshtLine."Sales Price Currency Code" <> '' then begin
                GLSetup.Get();
                if GLSetup."LCY Code" <> ItemWkshtLine."Currency Code" then begin
                    ProcessError(ItemWkshtLine, StrSubstNo(Text110, ItemWkshtLine."Currency Code"), StopOnError);
                end;
            end;
        end;
    end;

    local procedure CheckWorkSheetLineDirectUnitCost(var ItemWkshtLine: Record "NPR Item Worksheet Line"; StopOnError: Boolean)
    var
        GLSetup: Record "General Ledger Setup";
    begin
        if ItemWorksheetTemplate."Purchase Price Handling" = ItemWorksheetTemplate."Purchase Price Handling"::Item then begin
            if (ItemWkshtLine."Purchase Price Currency Code" <> '') and (ItemWkshtLine."Direct Unit Cost" <> 0) then begin
                GLSetup.Get();
                if GLSetup."LCY Code" <> ItemWkshtLine."Purchase Price Currency Code" then begin
                    ProcessError(ItemWkshtLine, StrSubstNo(Text118, ItemWkshtLine."Line No."), StopOnError);
                end;
            end;
        end;
        if ItemWorksheetTemplate."Purchase Price Handling" = ItemWorksheetTemplate."Purchase Price Handling"::"Item+Variant" then begin
            if ItemWkshtLine."Vendor No." = '' then begin
                if ItemWkshtLine."Direct Unit Cost" <> 0 then begin
                    ProcessError(ItemWkshtLine, StrSubstNo(Text111, ItemWkshtLine."Line No."), StopOnError);
                end else begin
                    ItemWorksheetVariantLine.Reset();
                    ItemWorksheetVariantLine.SetRange("Worksheet Template Name", ItemWkshtLine."Worksheet Template Name");
                    ItemWorksheetVariantLine.SetRange("Worksheet Name", ItemWkshtLine."Worksheet Name");
                    ItemWorksheetVariantLine.SetRange("Worksheet Line No.", ItemWkshtLine."Line No.");
                    ItemWorksheetVariantLine.SetFilter(Action, '<>%1', ItemWkshtLine.Action::Skip);
                    ItemWorksheetVariantLine.SetFilter("Direct Unit Cost", '<>0');
                    if ItemWorksheetVariantLine.FindFirst() then begin
                        ProcessError(ItemWkshtLine, StrSubstNo(Text111, ItemWkshtLine."Line No."), StopOnError);
                    end;
                end;
            end;
        end;
    end;


    local procedure ProcessError(var ItemWkshtLine: Record "NPR Item Worksheet Line"; ErrorText: Text[1024]; StopOnError: Boolean)
    begin
        if StopOnError then begin
            if ItemWkshtLine."Line No." <> 0 then
                ErrorText += StrSubstNo(Text133, ItemWkshtLine.FieldCaption("Line No."), ItemWkshtLine."Line No.");
            Error(ErrorText)
        end else begin
            if ItemWkshtLine.Status = ItemWkshtLine.Status::Error then begin
                ItemWkshtLine."Status Comment" := CopyStr(ItemWkshtLine."Status Comment" + ' - ' + ErrorText, 1, MaxStrLen(ItemWkshtLine."Status Comment"));
            end else begin
                ItemWkshtLine.Status := ItemWkshtLine.Status::Error;
                ItemWkshtLine."Status Comment" := CopyStr(ErrorText, 1, MaxStrLen(ItemWkshtLine."Status Comment"));
            end;
        end;
    end;
}

