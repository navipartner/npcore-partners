codeunit 6151125 "NPR NpIa Item AddOn Mgt."
{
    Access = Internal;

    var
        IsAutoSplitKeyRecord: Boolean;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sale Line", 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeletePOSSaleLine(var Rec: Record "NPR POS Sale Line"; RunTrigger: Boolean)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
        MandatoryDependentLineCannotBeDeletedErr: Label 'You cannot delete this line because it is a mandatory Item AddOn line. Please delete the main line, and this line will be deleted automatically by the system.';
    begin
        if Rec.IsTemporary() then
            exit;

        FilterSaleLinePOS2ItemAddOnPOSLine(Rec, SaleLinePOSAddOn);
        SaleLinePOSAddOn.SetRange(Mandatory, true);
        if SaleLinePOSAddOn.FindFirst() then
            if SaleLinePOS.Get(
                SaleLinePOSAddOn."Register No.",
                SaleLinePOSAddOn."Sales Ticket No.",
                SaleLinePOSAddOn."Sale Date",
                SaleLinePOSAddOn."Sale Type",
                SaleLinePOSAddOn."Applies-to Line No.")
               and (Rec."Line No." <> SaleLinePOS."Line No.")
            then
                Error(MandatoryDependentLineCannotBeDeletedErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POSAction: Delete POS Line", 'OnBeforeDeleteSaleLinePOS', '', true, false)]
    local procedure OnBeforeManualDeletePOSSaleLine(POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        ConfirmDeleteAllDependentLinesQst: Label 'There are one or more Item AddOn dependent lines, linked with the current line. Those will be deleted as well. Are you sure you want to continue?';
    begin
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        if AttachedIteamAddonLinesExist(SaleLinePOS) then
            if not Confirm(ConfirmDeleteAllDependentLinesQst, true) then
                Error('');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sale Line", 'OnAfterDeleteEvent', '', true, false)]
    local procedure OnAfterDeletePOSSaleLine(var Rec: Record "NPR POS Sale Line"; RunTrigger: Boolean)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
    begin
        if Rec.IsTemporary() then
            exit;

        FilterSaleLinePOS2ItemAddOnPOSLine(Rec, SaleLinePOSAddOn);
        if not SaleLinePOSAddOn.IsEmpty() then
            SaleLinePOSAddOn.DeleteAll();

        SaleLinePOSAddOn.SetRange("Sale Line No.");
        SaleLinePOSAddOn.SetRange("Applies-to Line No.", Rec."Line No.");
        if SaleLinePOSAddOn.FindSet() then
            repeat
                if SaleLinePOS.Get(
                    SaleLinePOSAddOn."Register No.",
                    SaleLinePOSAddOn."Sales Ticket No.",
                    SaleLinePOSAddOn."Sale Date",
                    SaleLinePOSAddOn."Sale Type",
                    SaleLinePOSAddOn."Sale Line No.")
                then
                    SaleLinePOS.Delete(true);
            until SaleLinePOSAddOn.Next() = 0;

        SaleLinePOSAddOn.DeleteAll();
        if Rec.Find() then;
    end;

    local procedure BuiltInSaleLine(): Text
    begin
        exit('BUILTIN_SALELINE');
    end;

    local procedure DataSourceExtensionName(): Text
    begin
        exit('ItemAddOn');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDiscoverDataSourceExtensions', '', false, false)]
    local procedure OnDiscover(DataSourceName: Text; Extensions: List of [Text])
    begin
        if DataSourceName <> BuiltInSaleLine() then
            exit;
        if not ItemAddOnEnabled() then
            exit;

        Extensions.Add(DataSourceExtensionName());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnGetDataSourceExtension', '', false, false)]
    local procedure OnGetExtension(DataSourceName: Text; ExtensionName: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        DataType: Enum "NPR Data Type";
    begin
        if DataSourceName <> BuiltInSaleLine() then
            exit;
        if ExtensionName <> DataSourceExtensionName() then
            exit;

        Handled := true;

        DataSource.AddColumn(DataSourceExtensionName(), 'Item AddOn', DataType::Boolean, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDataSourceExtensionReadData', '', false, false)]
    local procedure OnReadData(DataSourceName: Text; ExtensionName: Text; var RecRef: RecordRef; DataRow: Codeunit "NPR Data Row"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        ItemAddOn: Record "NPR NpIa Item AddOn";
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        if DataSourceName <> BuiltInSaleLine() then
            exit;
        if ExtensionName <> DataSourceExtensionName() then
            exit;

        Handled := true;

        RecRef.SetTable(SaleLinePOS);
        DataRow.Fields().Add(DataSourceExtensionName(), FindItemAddOn(SaleLinePOS, ItemAddOn));
    end;

    procedure GenerateItemAddOnConfigJson(SalePOS: Record "NPR POS Sale"; MasterSaleLinePOS: Record "NPR POS Sale Line"; ItemAddOn: Record "NPR NpIa Item AddOn") ConfigJObject: JsonObject
    var
        AddOnSaleLinePOS: Record "NPR POS Sale Line";
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        ItemAddOnLineOption: Record "NPR NpIa ItemAddOn Line Opt.";
        ItemAddOn_LineOptionJObject: JsonObject;
        ItemAddOn_LineOptionsJArray: JsonArray;
        ItemAddOn_GroupLineJObject: JsonObject;
        ItemAddOn_GroupLineSettingsJArray: JsonArray;
        ItemAddOn_LineJObject: JsonObject;
        ItemAddOn_LinesJArray: JsonArray;
        ValueJObject: JsonObject;
        Quantity: Decimal;
        CommentText: Text;
        IncludeComment: Boolean;
        CommentLbl: Label 'Comment';
        PopupTitleLbl: Label 'Select your options...';
        UnsupportedErr: Label 'Unsupported entity %1';
        PlaceHolder3Lbl: Label '%1 %3 %2', Locked = true;
    begin
        ItemAddOnLine.SetRange("AddOn No.", ItemAddOn."No.");
        if ItemAddOnLine.FindSet() then
            repeat
                ItemAddOnLineOption.SetRange("AddOn No.", ItemAddOnLine."AddOn No.");
                ItemAddOnLineOption.SetRange("AddOn Line No.", ItemAddOnLine."Line No.");
                ItemAddOnLineOption.SetFilter("Item No.", '<>%1', '');
                if ((ItemAddOnLine.Type = ItemAddOnLine.Type::Quantity) and (ItemAddOnLine."Item No." <> '')) or
                   ((ItemAddOnLine.Type = ItemAddOnLine.Type::Select) and ItemAddOnLineOption.FindSet())
                then begin
                    CommentText := '';
                    Clear(AddOnSaleLinePOS);
                    if FindAddOnSaleLinePOS(SalePOS, MasterSaleLinePOS."Line No.", ItemAddOnLine, AddOnSaleLinePOS) then
                        CommentText := GetItemAddOnComment(ItemAddOn, AddOnSaleLinePOS);
                    IncludeComment := (ItemAddOnLine."Comment Enabled" and (ItemAddOn."Comment POS Info Code" <> '')) or (CommentText <> '');

                    Clear(ItemAddOn_LineJObject);
                    ItemAddOn_LineJObject.Add('id', ItemAddOnLine."Line No.");
                    ItemAddOn_LineJObject.Add('caption', GetLineCaption(ItemAddOnLine, 0));
                    case ItemAddOnLine.Type of
                        ItemAddOnLine.Type::Quantity:
                            begin
                                if not (ItemAddOnLine.Mandatory and ItemAddOnLine."Fixed Quantity") then begin
                                    if ItemAddOnLine."Fixed Quantity" then begin
                                        ItemAddOn_LineJObject.Add('type', 'switch');
                                        ItemAddOn_LineJObject.Add('value', AddOnSaleLinePOS.Quantity <> 0);
                                    end else begin
                                        if AddOnSaleLinePOS.Quantity = 0 then begin
                                            if AttachedIteamAddonLinesExist(MasterSaleLinePOS) and not ItemAddOnLine.Mandatory then
                                                Quantity := 0
                                            else
                                                Quantity := ItemAddOnLine.Quantity;
                                            if ItemAddOnLine."Per Unit" then begin
                                                if MasterSaleLinePOS."Quantity (Base)" = 0 then
                                                    MasterSaleLinePOS."Quantity (Base)" := 1;
                                                Quantity := Round(Quantity * MasterSaleLinePOS."Quantity (Base)", 0.00001);
                                            end;
                                        end else
                                            Quantity := AddOnSaleLinePOS.Quantity;
                                        ItemAddOn_LineJObject.Add('type', 'plusminus');
                                        if ItemAddOnLine.Mandatory then
                                            ItemAddOn_LineJObject.Add('minValue', 1);
                                        ItemAddOn_LineJObject.Add('value', Quantity);
                                    end;
                                end;
                            end;

                        ItemAddOnLine.Type::Select:
                            begin
                                ItemAddOn_LineJObject.Add('type', 'radio');
                                if AddOnSaleLinePOS."No." <> '' then begin
                                    Clear(ValueJObject);
                                    ValueJObject.Add('item', AddOnSaleLinePOS."No.");
                                    ValueJObject.Add('variant', AddOnSaleLinePOS."Variant Code");
                                    ItemAddOn_LineJObject.Add('value', ValueJObject);
                                end;

                                Clear(ItemAddOn_LineOptionsJArray);
                                repeat
                                    Clear(ValueJObject);
                                    ValueJObject.Add('item', ItemAddOnLineOption."Item No.");
                                    ValueJObject.Add('variant', ItemAddOnLineOption."Variant Code");

                                    Clear(ItemAddOn_LineOptionJObject);
                                    if ItemAddOnLineOption.Description = '' then
                                        ItemAddOnLineOption.Description :=
                                            CopyStr(ItemNoAndVariantCodeAsDescription(ItemAddOnLineOption."Item No.", ItemAddOnLineOption."Variant Code"), 1, MaxStrLen(ItemAddOnLineOption.Description));
                                    ItemAddOn_LineOptionJObject.Add('caption', ItemAddOnLineOption.Description);
                                    ItemAddOn_LineOptionJObject.Add('value', ValueJObject);
                                    ItemAddOn_LineOptionsJArray.Add(ItemAddOn_LineOptionJObject);
                                until ItemAddOnLineOption.Next() = 0;
                                ItemAddOn_LineJObject.Add('options', ItemAddOn_LineOptionsJArray);
                            end;

                        else
                            Error(UnsupportedErr, StrSubstNo(PlaceHolder3Lbl, ItemAddOnLine.TableCaption, ItemAddOnLine.FieldCaption(Type), ItemAddOnLine.Type));
                    end;

                    if IncludeComment then begin
                        Clear(ItemAddOn_GroupLineSettingsJArray);
                        if not (ItemAddOnLine.Mandatory and ItemAddOnLine."Fixed Quantity") then
                            ItemAddOn_GroupLineSettingsJArray.Add(ItemAddOn_LineJObject);

                        Clear(ItemAddOn_LineJObject);
                        ItemAddOn_LineJObject.Add('type', 'text');
                        ItemAddOn_LineJObject.Add('id', CommentLineID(ItemAddOnLine."Line No."));
                        ItemAddOn_LineJObject.Add('caption', CommentLbl);
                        ItemAddOn_LineJObject.Add('value', CommentText);
                        ItemAddOn_GroupLineSettingsJArray.Add(ItemAddOn_LineJObject);

                        Clear(ItemAddOn_GroupLineJObject);
                        ItemAddOn_GroupLineJObject.Add('caption', GetLineCaption(ItemAddOnLine, 1));
                        ItemAddOn_GroupLineJObject.Add('type', 'group');
                        ItemAddOn_GroupLineJObject.Add('expanded', true);
                        ItemAddOn_GroupLineJObject.Add('settings', ItemAddOn_GroupLineSettingsJArray);

                        ItemAddOn_LinesJArray.Add(ItemAddOn_GroupLineJObject);
                    end else
                        if not (ItemAddOnLine.Mandatory and ItemAddOnLine."Fixed Quantity") then
                            ItemAddOn_LinesJArray.Add(ItemAddOn_LineJObject);
                end;
            until ItemAddOnLine.Next() = 0;

        ConfigJObject.Add('caption', ItemAddOn.Description);
        ConfigJObject.Add('title', PopupTitleLbl);
        ConfigJObject.Add('settings', ItemAddOn_LinesJArray);
    end;

    local procedure GetLineCaption(ItemAddOnLine: Record "NPR NpIa Item AddOn Line"; UseField: Option Description,"Description 2",Both) LineCaption: Text
    var
        PerUnitLbl: Label 'per unit';
        QuantityLbl: Label 'quantity';
        SelectOptionsLbl: Label 'Select one';
        PlaceHolder2Lbl: Label '; %1 = %2', Locked = true;
    begin
        case UseField of
            UseField::Description:
                LineCaption := ItemAddOnLine.Description;
            UseField::"Description 2":
                begin
                    if ItemAddOnLine."Description 2" = '' then
                        ItemAddOnLine."Description 2" := CopyStr(ItemAddOnLine.Description, 1, MaxStrLen(ItemAddOnLine."Description 2"));
                    LineCaption := ItemAddOnLine."Description 2";
                end;
            UseField::Both:
                begin
                    LineCaption := ItemAddOnLine.Description;
                    if ItemAddOnLine."Description 2" <> '' then
                        LineCaption := LineCaption + ' ' + ItemAddOnLine."Description 2";
                end;
        end;
        if LineCaption = '' then begin
            case ItemAddOnLine.Type of
                ItemAddOnLine.Type::Quantity:
                    LineCaption := ItemNoAndVariantCodeAsDescription(ItemAddOnLine."Item No.", ItemAddOnLine."Variant Code");
                ItemAddOnLine.Type::Select:
                    LineCaption := SelectOptionsLbl;
            end;
        end;
        if ItemAddOnLine."Fixed Quantity" then
            LineCaption := LineCaption + StrSubstNo(PlaceHolder2Lbl, QuantityLbl, ItemAddOnLine.Quantity);
        if ItemAddOnLine."Per Unit" then
            LineCaption := LineCaption + '/' + PerUnitLbl;
    end;

    local procedure ItemNoAndVariantCodeAsDescription(ItemNo: Code[20]; VariantCode: Code[10]): Text
    var
        ItemNoLbl: Label 'Item: %1';
        VariantCodeLbl: Label '%1, Variant %2';
        Description: Text;
    begin
        Description := StrSubstNo(ItemNoLbl, ItemNo);
        if VariantCode <> '' then
            Description := StrSubstNo(VariantCodeLbl, Description, VariantCode);
        exit(Description);
    end;

    local procedure CommentLineID(LineNo: Integer): Text
    var
        CommentLbl: Label '%1_Comment', Locked = true;
    begin
        exit(StrSubstNo(CommentLbl, LineNo));
    end;

    procedure UserInterfaceIsRequired(ItemAddOn: Record "NPR NpIa Item AddOn"): Boolean
    var
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
    begin
        ItemAddOnLine.SetRange("AddOn No.", ItemAddOn."No.");
        ItemAddOnLine.FilterGroup(-1);
        ItemAddOnLine.SetRange(Mandatory, false);
        ItemAddOnLine.SetRange("Comment Enabled", true);
        ItemAddOnLine.SetRange(Type, ItemAddOnLine.Type::Select);
        ItemAddOnLine.FilterGroup(0);
        exit(not ItemAddOnLine.IsEmpty());
    end;

    procedure InsertPOSAddOnLines(ItemAddOn: Record "NPR NpIa Item AddOn"; SelectedAddOnLines: JsonToken; POSSession: Codeunit "NPR POS Session"; AppliesToLineNo: Integer; CompulsoryAddOn: Boolean): Boolean
    var
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        TempItemAddOnLine: Record "NPR NpIa Item AddOn Line" temporary;
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        JToken: JsonToken;
        AddonLineKey: Text;
        SelectedAddonLineKeys: List of [Text];
    begin
        if SelectedAddOnLines.IsValue then
            if SelectedAddOnLines.AsValue().IsNull then
                exit(InsertMandatoryPOSAddOnLines(ItemAddOn, POSSession, AppliesToLineNo, false, CompulsoryAddOn));

        TempItemAddOnLine.Reset();
        TempItemAddOnLine.DeleteAll();

        SelectedAddonLineKeys := SelectedAddOnLines.AsObject().Keys;
        foreach AddonLineKey in SelectedAddonLineKeys do begin
            SelectedAddOnLines.AsObject().Get(AddonLineKey, JToken);
            if ParsePOSAddOnLine(ItemAddOn, JToken, AddonLineKey, ItemAddOnLine) then begin
                TempItemAddOnLine := ItemAddOnLine;
                TempItemAddOnLine.Insert();
            end;
        end;

        ItemAddOnLine.SetRange("AddOn No.", ItemAddOn."No.");
        ItemAddOnLine.SetRange(Mandatory, true);
        ItemAddOnLine.SetRange(Type, ItemAddOnLine.Type::Quantity);
        if not ItemAddOnLine.IsEmpty then
            CopyItemAddOnLinesToTemp(ItemAddOnLine, TempItemAddOnLine, false);

        if TempItemAddOnLine.IsEmpty then
            exit(false);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        if not AskForVariants(SalePOS, AppliesToLineNo, TempItemAddOnLine) then begin
            if CompulsoryAddOn then
                RemoveBaseLine(POSSession, AppliesToLineNo);
            exit(false);
        end;

        POSSession.GetSaleLine(POSSaleLine);
        TempItemAddOnLine.FindSet();
        repeat
            if InsertPOSAddOnLine(TempItemAddOnLine, SalePOS, POSSaleLine, AppliesToLineNo, SaleLinePOS) then
                if SelectedAddOnLines.AsObject().Get(CommentLineID(TempItemAddOnLine."Line No."), JToken) then
                    InsertPOSAddOnLineComment(JToken, ItemAddOn, SaleLinePOS);
        until TempItemAddOnLine.Next() = 0;

        exit(true);
    end;

    procedure InsertMandatoryPOSAddOnLinesSilent(ItemAddOn: Record "NPR NpIa Item AddOn"; POSSession: Codeunit "NPR POS Session"; AppliesToLineNo: Integer; CompulsoryAddOn: Boolean): Boolean
    begin
        exit(InsertMandatoryPOSAddOnLines(ItemAddOn, POSSession, AppliesToLineNo, true, CompulsoryAddOn));
    end;

    local procedure InsertMandatoryPOSAddOnLines(ItemAddOn: Record "NPR NpIa Item AddOn"; POSSession: Codeunit "NPR POS Session"; AppliesToLineNo: Integer; NotRequiringComments: Boolean; CompulsoryAddOn: Boolean): Boolean
    var
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        TempItemAddOnLine: Record "NPR NpIa Item AddOn Line" temporary;
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        ItemAddOnLine.SetRange("AddOn No.", ItemAddOn."No.");
        ItemAddOnLine.SetRange(Mandatory, true);
        if NotRequiringComments then
            ItemAddOnLine.SetRange("Comment Enabled", false);
        ItemAddOnLine.SetRange(Type, ItemAddOnLine.Type::Quantity);
        if ItemAddOnLine.IsEmpty() then
            exit(false);
        CopyItemAddOnLinesToTemp(ItemAddOnLine, TempItemAddOnLine, true);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if not AskForVariants(SalePOS, AppliesToLineNo, TempItemAddOnLine) then begin
            if CompulsoryAddOn then
                RemoveBaseLine(POSSession, AppliesToLineNo);
            exit(false);
        end;

        POSSession.GetSaleLine(POSSaleLine);
        if TempItemAddOnLine.FindSet() then begin
            repeat
                InsertPOSAddOnLine(TempItemAddOnLine, SalePOS, POSSaleLine, AppliesToLineNo, SaleLinePOS);
            until TempItemAddOnLine.Next() = 0;

            if SaleLinePOS.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Sale Type", AppliesToLineNo) then
                POSSaleLine.SetPosition(SaleLinePOS.GetPosition());
        end;
        exit(true);
    end;

    local procedure InsertPOSAddOnLine(ItemAddOnLine: Record "NPR NpIa Item AddOn Line"; SalePOS: Record "NPR POS Sale"; POSSaleLine: Codeunit "NPR POS Sale Line"; AppliesToLineNo: Integer; var SaleLinePOS: Record "NPR POS Sale Line"): Boolean
    var
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
        LineNo: Integer;
        PrevRec: Text;
    begin
        if not FindAddOnSaleLinePOS(SalePOS, AppliesToLineNo, ItemAddOnLine, SaleLinePOS) then begin
            if ItemAddOnLine.Quantity <= 0 then
                exit(false);

            //Find last dependent line of current base line in order to insert new lines after it
            POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
            FilterAttachedItemAddonLines(SaleLinePOS, AppliesToLineNo, SaleLinePOSAddOn);
            if SaleLinePOSAddOn.FindLast() then begin
                SaleLinePOS.Get(
                  SaleLinePOSAddOn."Register No.",
                  SaleLinePOSAddOn."Sales Ticket No.",
                  SaleLinePOSAddOn."Sale Date",
                  SaleLinePOSAddOn."Sale Type",
                  SaleLinePOSAddOn."Sale Line No.");
                POSSaleLine.SetPosition(SaleLinePOS.GetPosition());
            end;
            POSSaleLine.ForceInsertWithAutoSplitKey(true);
            POSSaleLine.GetNewSaleLine(SaleLinePOS);

            BeforeInsertPOSAddOnLine(SalePOS, AppliesToLineNo, ItemAddOnLine);
            SaleLinePOS.Type := SaleLinePOS.Type::Item;
            SaleLinePOS."Variant Code" := ItemAddOnLine."Variant Code";
            SaleLinePOS.Validate("No.", ItemAddOnLine."Item No.");
            SaleLinePOS.Description := ItemAddOnLine.Description;
            SaleLinePOS.Validate(Quantity, ItemAddOnLine.Quantity);
            if (ItemAddOnLine."Unit Price" <> 0) or (ItemAddOnLine."Use Unit Price" = ItemAddOnLine."Use Unit Price"::Always) then begin
                SaleLinePOS."Manual Item Sales Price" := true;
                SaleLinePOS.Validate("Unit Price", ItemAddOnLine."Unit Price");
            end;
            SaleLinePOS.Validate(Quantity, ItemAddOnLine.Quantity);
            SaleLinePOS.Validate("Discount %", ItemAddOnLine."Discount %");

            POSSaleLine.SetUsePresetLineNo(true);
            POSSaleLine.InsertLine(SaleLinePOS);
            POSSaleLine.SetUsePresetLineNo(false);
            if not IsAutoSplitKeyRecord then
                IsAutoSplitKeyRecord := POSSaleLine.InsertedWithAutoSplitKey();
            POSSaleLine.ForceInsertWithAutoSplitKey(false);

            FilterSaleLinePOS2ItemAddOnPOSLine(SaleLinePOS, SaleLinePOSAddOn);
            if not SaleLinePOSAddOn.FindLast() then
                SaleLinePOSAddOn."Line No." := 0;
            LineNo := SaleLinePOSAddOn."Line No." + 10000;
            SaleLinePOSAddOn.Init();
            SaleLinePOSAddOn."Register No." := SaleLinePOS."Register No.";
            SaleLinePOSAddOn."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
            SaleLinePOSAddOn."Sale Type" := SaleLinePOS."Sale Type";
            SaleLinePOSAddOn."Sale Date" := SaleLinePOS.Date;
            SaleLinePOSAddOn."Sale Line No." := SaleLinePOS."Line No.";
            SaleLinePOSAddOn."Line No." := LineNo;
            SaleLinePOSAddOn."Applies-to Line No." := AppliesToLineNo;
            SaleLinePOSAddOn."AddOn No." := ItemAddOnLine."AddOn No.";
            SaleLinePOSAddOn."AddOn Line No." := ItemAddOnLine."Line No.";
            SaleLinePOSAddOn."Fixed Quantity" := ItemAddOnLine."Fixed Quantity";
            SaleLinePOSAddOn."Per Unit" := ItemAddOnLine."Per Unit";
            SaleLinePOSAddOn.Mandatory := ItemAddOnLine.Mandatory;
            SaleLinePOSAddOn.Insert(true);
            exit(true);
        end;

        if ItemAddOnLine.Quantity <= 0 then begin
            SaleLinePOS.Delete(true);
            exit(false);
        end;

        PrevRec := Format(SaleLinePOS);

        BeforeInsertPOSAddOnLine(SalePOS, AppliesToLineNo, ItemAddOnLine);
        SaleLinePOS.Type := SaleLinePOS.Type::Item;
        SaleLinePOS."Variant Code" := ItemAddOnLine."Variant Code";
        SaleLinePOS.Validate("No.", ItemAddOnLine."Item No.");
        SaleLinePOS.Description := ItemAddOnLine.Description;
        if (ItemAddOnLine."Unit Price" <> 0) or (ItemAddOnLine."Use Unit Price" = ItemAddOnLine."Use Unit Price"::Always) then begin
            SaleLinePOS."Manual Item Sales Price" := true;
            SaleLinePOS.Validate("Unit Price", ItemAddOnLine."Unit Price");
        end;
        SaleLinePOS.Validate(Quantity, ItemAddOnLine.Quantity);
        SaleLinePOS.Validate("Discount %", ItemAddOnLine."Discount %");
        if PrevRec <> Format(SaleLinePOS) then begin
            SaleLinePOS.Modify(true);
            POSSaleLine.RefreshCurrent();
        end;

        exit(true);
    end;

    local procedure InsertPOSAddOnLineComment(AddOnLineComment: JsonToken; ItemAddOn: Record "NPR NpIa Item AddOn"; var SaleLinePOS: Record "NPR POS Sale Line")
    var
        POSInfo: Record "NPR POS Info";
        POSInfoTransaction: Record "NPR POS Info Transaction";
        Comment: Text;
    begin
        if not AddOnLineComment.IsValue then
            exit;
        Comment := AddOnLineComment.AsValue().AsText();
        if Comment = '' then
            exit;

        ItemAddOn.TestField("Comment POS Info Code");
        POSInfo.Get(ItemAddOn."Comment POS Info Code");

        POSInfoTransaction.SetRange("POS Info Code", POSInfo.Code);
        POSInfoTransaction.SetRange("Register No.", SaleLinePOS."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        POSInfoTransaction.SetRange("Sales Line No.", SaleLinePOS."Line No.");
        POSInfoTransaction.SetRange("Sale Date", SaleLinePOS.Date);
        if POSInfoTransaction.FindFirst() then
            POSInfoTransaction.DeleteAll();

        while Comment <> '' do begin
            POSInfoTransaction.Init();
            POSInfoTransaction."Register No." := SaleLinePOS."Register No.";
            POSInfoTransaction."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
            POSInfoTransaction."Sales Line No." := SaleLinePOS."Line No.";
            POSInfoTransaction."Sale Date" := SaleLinePOS.Date;
            POSInfoTransaction."Receipt Type" := SaleLinePOS.Type;
            POSInfoTransaction."Entry No." := 0;
            POSInfoTransaction."POS Info Code" := POSInfo.Code;
            POSInfoTransaction."POS Info" := CopyStr(Comment, 1, MaxStrLen(POSInfoTransaction."POS Info"));
            POSInfoTransaction.Insert(true);

            Comment := DelStr(Comment, 1, StrLen(POSInfoTransaction."POS Info"));
        end;
    end;

    local procedure ParsePOSAddOnLine(ItemAddOn: Record "NPR NpIa Item AddOn"; SelectedAddOnLine: JsonToken; AddonLineKey: Text; var ItemAddOnLine: Record "NPR NpIa Item AddOn Line"): Boolean
    var
        ItemAddOnLineOption: Record "NPR NpIa ItemAddOn Line Opt.";
        ItemNo: Code[20];
        VariantCode: Code[10];
        LineNo: Integer;
    begin
        if not Evaluate(LineNo, AddonLineKey) or (LineNo = 0) then
            exit(false);
        ItemAddOnLine.Get(ItemAddOn."No.", LineNo);
        case ItemAddOnLine.Type of
            ItemAddOnLine.Type::Quantity:
                begin
                    if SelectedAddOnLine.IsValue then begin
                        if ItemAddOnLine."Fixed Quantity" then begin
                            if not SelectedAddOnLine.AsValue().AsBoolean() then
                                ItemAddOnLine.Quantity := 0;
                        end else
                            ItemAddOnLine.Quantity := SelectedAddOnLine.AsValue().AsDecimal();
                    end else
                        ItemAddOnLine.Quantity := 0;
                end;

            ItemAddOnLine.Type::Select:
                begin
                    ItemAddOnLine.Quantity := 0;
                    if SelectedAddOnLine.IsObject then begin
                        ItemNo := GetJCode(SelectedAddOnLine, 'item', MaxStrLen(ItemNo), false);
                        VariantCode := GetJCode(SelectedAddOnLine, 'variant', MaxStrLen(VariantCode), false);
                        if ItemNo <> '' then begin
                            ItemAddOnLineOption.SetRange("AddOn No.", ItemAddOnLine."AddOn No.");
                            ItemAddOnLineOption.SetRange("AddOn Line No.", ItemAddOnLine."Line No.");
                            ItemAddOnLineOption.SetRange("Item No.", ItemNo);
                            ItemAddOnLineOption.SetRange("Variant Code", VariantCode);
                            ItemAddOnLineOption.FindFirst();

                            ItemAddOnLine."Item No." := ItemAddOnLineOption."Item No.";
                            ItemAddOnLine."Variant Code" := ItemAddOnLineOption."Variant Code";
                            ItemAddOnLine.Description := ItemAddOnLineOption.Description;
                            ItemAddOnLine.Quantity := ItemAddOnLineOption.Quantity;
                            ItemAddOnLine."Fixed Quantity" := ItemAddOnLineOption."Fixed Quantity";
                            ItemAddOnLine.Mandatory := false;
                            ItemAddOnLine."Unit Price" := ItemAddOnLineOption."Unit Price";
                            ItemAddOnLine."Discount %" := ItemAddOnLineOption."Discount %";
                            ItemAddOnLine."Per Unit" := ItemAddOnLineOption."Per Unit";
                            ItemAddOnLine."Use Unit Price" := ItemAddOnLineOption."Use Unit Price";
                        end;
                    end;
                end;
        end;
        exit((ItemAddOnLine.Quantity <> 0) or ItemAddOnLine."Fixed Quantity");
    end;

    local procedure RemoveBaseLine(POSSession: Codeunit "NPR POS Session"; AppliesToLineNo: Integer)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        if AppliesToLineNo <> 0 then begin
            POSSession.GetSaleLine(POSSaleLine);
            POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
            if SaleLinePOS."Line No." <> AppliesToLineNo then begin
                if not SaleLinePOS.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Sale Type", AppliesToLineNo) then
                    exit;
                POSSaleLine.SetPosition(SaleLinePOS.GetPosition());
            end;
            POSSaleLine.DeleteLine();
            POSSession.GetSale(POSSale);
            POSSale.SetModified();
            POSSession.RequestRefreshData();
            Commit();
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure BeforeInsertPOSAddOnLine(SalePOS: Record "NPR POS Sale"; AppliesToLineNo: Integer; var NpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure HasBeforeInsertSetup(NpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line"; var HasSetup: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure RunBeforeInsertSetup(NpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line"; var Handled: Boolean)
    begin
    end;

    local procedure GetItemAddOnComment(ItemAddOn: Record "NPR NpIa Item AddOn"; SaleLinePOS: Record "NPR POS Sale Line") Comment: Text
    var
        POSInfoTransaction: Record "NPR POS Info Transaction";
    begin
        POSInfoTransaction.SetRange("POS Info Code", ItemAddOn."Comment POS Info Code");
        POSInfoTransaction.SetRange("Register No.", SaleLinePOS."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        POSInfoTransaction.SetRange("Sales Line No.", SaleLinePOS."Line No.");
        POSInfoTransaction.SetRange("Sale Date", SaleLinePOS.Date);
        if not POSInfoTransaction.FindSet() then
            exit('');

        repeat
            Comment += POSInfoTransaction."POS Info";
        until POSInfoTransaction.Next() = 0;

        exit(Comment);
    end;

    procedure FilterSaleLinePOS2ItemAddOnPOSLine(SaleLinePOS: Record "NPR POS Sale Line"; var SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn")
    begin
        Clear(SaleLinePOSAddOn);
        SaleLinePOSAddOn.SetRange("Register No.", SaleLinePOS."Register No.");
        SaleLinePOSAddOn.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        SaleLinePOSAddOn.SetRange("Sale Type", SaleLinePOS."Sale Type");
        SaleLinePOSAddOn.SetRange("Sale Date", SaleLinePOS.Date);
        SaleLinePOSAddOn.SetRange("Sale Line No.", SaleLinePOS."Line No.");
    end;

    procedure FilterAttachedItemAddonLines(SaleLinePOS: Record "NPR POS Sale Line"; AppliesToLineNo: Integer; var SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn")
    begin
        Clear(SaleLinePOSAddOn);
        SaleLinePOSAddOn.SetRange("Register No.", SaleLinePOS."Register No.");
        SaleLinePOSAddOn.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        SaleLinePOSAddOn.SetRange("Sale Type", SaleLinePOS."Sale Type");
        SaleLinePOSAddOn.SetRange("Sale Date", SaleLinePOS.Date);
        SaleLinePOSAddOn.SetRange("Applies-to Line No.", AppliesToLineNo);
    end;

    procedure AttachedIteamAddonLinesExist(SaleLinePOS: Record "NPR POS Sale Line"): Boolean
    var
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
    begin
        FilterAttachedItemAddonLines(SaleLinePOS, SaleLinePOS."Line No.", SaleLinePOSAddOn);
        exit(not SaleLinePOSAddOn.IsEmpty);
    end;

    procedure FindItemAddOn(var SaleLinePOS: Record "NPR POS Sale Line"; var ItemAddOn: Record "NPR NpIa Item AddOn"): Boolean
    var
        Item: Record Item;
        SaleLinePOS2: Record "NPR POS Sale Line";
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
        ItemAdditionalFields: Record "NPR Item Additional Fields";
    begin
        Clear(ItemAddOn);

        if SaleLinePOS.Type <> SaleLinePOS.Type::Item then
            exit(false);

        if SaleLinePOS."No." in ['', '*'] then
            exit(false);

        FilterSaleLinePOS2ItemAddOnPOSLine(SaleLinePOS, SaleLinePOSAddOn);
        SaleLinePOSAddOn.SetFilter("Applies-to Line No.", '>%1', 0);
        if SaleLinePOSAddOn.FindSet() then
            repeat
                if SaleLinePOS2.Get(
                    SaleLinePOSAddOn."Register No.",
                    SaleLinePOSAddOn."Sales Ticket No.",
                    SaleLinePOSAddOn."Sale Date",
                    SaleLinePOSAddOn."Sale Type",
                    SaleLinePOSAddOn."Applies-to Line No.")
                then begin
                    SaleLinePOS := SaleLinePOS2;
                    if ItemAddOn.Get(SaleLinePOS2."No.") and ItemAddOn.Enabled then
                        exit(true);
                end;
            until SaleLinePOSAddOn.Next() = 0;

        SaleLinePOS2 := SaleLinePOS;
        if SaleLinePOS.Accessory then begin
            if not SaleLinePOS2.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Sale Type", SaleLinePOS."Main Line No.") then
                exit(false);
        end;

        if not Item.Get(SaleLinePOS2."No.") then
            exit(false);

        Item.NPR_GetItemAdditionalFields(ItemAdditionalFields);
        if ItemAdditionalFields."Item AddOn No." = '' then
            exit(false);
        if not ItemAddOn.Get(ItemAdditionalFields."Item AddOn No.") then
            exit(false);

        exit(ItemAddOn.Enabled);
    end;

    local procedure FindAddOnSaleLinePOS(SalePOS: Record "NPR POS Sale"; AppliesToLineNo: Integer; ItemAddOnLine: Record "NPR NpIa Item AddOn Line"; var SaleLinePOS: Record "NPR POS Sale Line"): Boolean
    var
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
    begin
        SaleLinePOSAddOn.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOSAddOn.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOSAddOn.SetRange("AddOn No.", ItemAddOnLine."AddOn No.");
        SaleLinePOSAddOn.SetRange("AddOn Line No.", ItemAddOnLine."Line No.");
        SaleLinePOSAddOn.SetRange("Applies-to Line No.", AppliesToLineNo);
        if not SaleLinePOSAddOn.FindFirst() then
            exit(false);

        exit(SaleLinePOS.Get(SaleLinePOSAddOn."Register No.", SaleLinePOSAddOn."Sales Ticket No.", SaleLinePOSAddOn."Sale Date", SaleLinePOSAddOn."Sale Type", SaleLinePOSAddOn."Sale Line No."));
    end;

    procedure ItemAddOnEnabled(): Boolean
    var
        ItemAddOn: Record "NPR NpIa Item AddOn";
    begin
        if ItemAddOn.IsEmpty() then
            exit(false);

        ItemAddOn.SetRange(Enabled, true);
        exit(ItemAddOn.FindFirst());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Create Entry", 'OnBeforeInsertPOSSalesLine', '', true, true)]
    local procedure OnBeforeInsertPOSSalesLine(SalePOS: Record "NPR POS Sale"; SaleLinePOS: Record "NPR POS Sale Line"; POSEntry: Record "NPR POS Entry"; var POSSalesLine: Record "NPR POS Entry Sales Line")
    begin
        if POSSalesLine."Serial No." <> '' then
            exit;

        SetSerialNo(SaleLinePOS);
        POSSalesLine."Serial No." := SaleLinePOS."Serial No.";
    end;

    local procedure SetSerialNo(var SaleLinePOS: Record "NPR POS Sale Line")
    var
        SaleLinePOS2: Record "NPR POS Sale Line";
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
    begin
        if SaleLinePOS."Serial No." <> '' then
            exit;

        if SaleLinePOSAddOn.IsEmpty() then
            exit;

        FilterSaleLinePOS2ItemAddOnPOSLine(SaleLinePOS, SaleLinePOSAddOn);
        if not SaleLinePOSAddOn.FindSet() then
            exit;

        repeat
            if SaleLinePOS2.Get(SaleLinePOSAddOn."Register No.", SaleLinePOSAddOn."Sales Ticket No.", SaleLinePOSAddOn."Sale Date", SaleLinePOSAddOn."Sale Type", SaleLinePOSAddOn."Applies-to Line No.") then
                SaleLinePOS."Serial No." := SaleLinePOS2."Serial No.";
        until (SaleLinePOS."Serial No." <> '') or (SaleLinePOSAddOn.Next() = 0);
    end;

    local procedure IsFixedQty(SaleLinePOS: Record "NPR POS Sale Line"): Boolean
    var
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
    begin
        FilterSaleLinePOS2ItemAddOnPOSLine(SaleLinePOS, SaleLinePOSAddOn);
        SaleLinePOSAddOn.SetRange("Fixed Quantity", true);
        exit(not SaleLinePOSAddOn.IsEmpty());
    end;

    local procedure IsMandatory(SaleLinePOS: Record "NPR POS Sale Line"): Boolean
    var
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
    begin
        FilterSaleLinePOS2ItemAddOnPOSLine(SaleLinePOS, SaleLinePOSAddOn);
        SaleLinePOSAddOn.SetRange(Mandatory, true);
        exit(not SaleLinePOSAddOn.IsEmpty());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale Line", 'OnBeforeSetQuantity', '', true, false)]
    local procedure CheckFixedQtyOnBeforePOSSaleLineSetQty(var Sender: Codeunit "NPR POS Sale Line"; var SaleLinePOS: Record "NPR POS Sale Line"; var NewQuantity: Decimal)
    var
        QtyIsFixedErr: Label 'The quantity of Item AddOn dependent line is fixed and cannot be changed in this way.';
        LineIsMandatoryErr: Label 'The line is mandatory. Quantity cannot be set to zero.';
    begin
        if IsFixedQty(SaleLinePOS) then
            Error(QtyIsFixedErr);
        if NewQuantity = 0 then
            if IsMandatory(SaleLinePOS) then
                Error(LineIsMandatoryErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale Line", 'OnAfterSetQuantity', '', true, false)]
    local procedure UpdateDependentLineQty(var Sender: Codeunit "NPR POS Sale Line"; var SaleLinePOS: Record "NPR POS Sale Line")
    var
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
        SaleLinePOS2: Record "NPR POS Sale Line";
        xSaleLinePOS: Record "NPR POS Sale Line";
    begin
        Sender.GetxRec(xSaleLinePOS);
        if xSaleLinePOS."Quantity (Base)" = 0 then
            exit;

        FilterAttachedItemAddonLines(SaleLinePOS, SaleLinePOS."Line No.", SaleLinePOSAddOn);
        SaleLinePOSAddOn.SetRange("Per Unit", true);
        if SaleLinePOSAddOn.FindSet() then
            repeat
                if SaleLinePOS2.Get(
                    SaleLinePOSAddOn."Register No.",
                    SaleLinePOSAddOn."Sales Ticket No.",
                    SaleLinePOSAddOn."Sale Date",
                    SaleLinePOSAddOn."Sale Type",
                    SaleLinePOSAddOn."Sale Line No.")
                then begin
                    SaleLinePOS2.Validate(Quantity, Round(SaleLinePOS2.Quantity * SaleLinePOS."Quantity (Base)" / xSaleLinePOS."Quantity (Base)", 0.00001));
                    SaleLinePOS2.Modify();
                end;
            until SaleLinePOSAddOn.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Ext.: Line Format.", 'OnGetLineStyle', '', false, false)]
    local procedure FormatDependentSaleLine(var Color: Text; var Weight: Text; var Style: Text; SaleLinePOS: Record "NPR POS Sale Line"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
    begin
        FilterSaleLinePOS2ItemAddOnPOSLine(SaleLinePOS, SaleLinePOSAddOn);
        if not SaleLinePOSAddOn.IsEmpty() then
            Style := 'italic';
        POSSession.RequestRefreshData();
    end;

    [TryFunction]
    local procedure AskForVariants(SalePOS: Record "NPR POS Sale"; AppliesToLineNo: Integer; var ItemAddOnLine: Record "NPR NpIa Item AddOn Line")
    var
        AddOnSaleLinePOS: Record "NPR POS Sale Line";
        TempItemVariantRequestBuffer: Record "NPR NpIa Item AddOn Line" temporary;
    begin
        if ItemAddOnLine.FindSet() then
            repeat
                if (ItemAddOnLine."Item No." <> '') and
                   (ItemAddOnLine."Variant Code" = '') and
                   (ItemAddOnLine.Quantity > 0) and
                   ItemVariantIsRequired(ItemAddOnLine."Item No.")
                then begin
                    TempItemVariantRequestBuffer := ItemAddOnLine;
                    if FindAddOnSaleLinePOS(SalePOS, AppliesToLineNo, ItemAddOnLine, AddOnSaleLinePOS) then
                        if AddOnSaleLinePOS."Variant Code" <> '' then
                            TempItemVariantRequestBuffer."Variant Code" := AddOnSaleLinePOS."Variant Code";
                    TempItemVariantRequestBuffer.Insert();
                end;
            until ItemAddOnLine.Next() = 0;

        if TempItemVariantRequestBuffer.IsEmpty() then
            exit;

        if Page.RunModal(Page::"NPR NpIa ItemAddOn Sel. Vars.", TempItemVariantRequestBuffer) <> Action::LookupOK then
            Error('');

        if TempItemVariantRequestBuffer.FindSet() then
            repeat
                TempItemVariantRequestBuffer.TestField("Variant Code");
                ItemAddOnLine.Get(TempItemVariantRequestBuffer."AddOn No.", TempItemVariantRequestBuffer."Line No.");
                if ItemAddOnLine."Variant Code" <> TempItemVariantRequestBuffer."Variant Code" then begin
                    ItemAddOnLine."Variant Code" := TempItemVariantRequestBuffer."Variant Code";
                    ItemAddOnLine.Description := TempItemVariantRequestBuffer."Description 2";
                    ItemAddOnLine.Modify();
                end;
            until TempItemVariantRequestBuffer.Next() = 0;
    end;

    local procedure ItemVariantIsRequired(ItemNo: Code[20]): Boolean
    var
        ItemVariant: Record "Item Variant";
    begin
        ItemVariant.SetRange("Item No.", ItemNo);
        ItemVariant.SetRange("NPR Blocked", false);
        exit(not ItemVariant.IsEmpty());
    end;

    local procedure CopyItemAddOnLinesToTemp(var FromItemAddOnLine: Record "NPR NpIa Item AddOn Line"; var ToItemAddOnLine: Record "NPR NpIa Item AddOn Line"; NewDataSet: Boolean)
    var
        MustBeTempMsg: Label '%1: function call on a non-temporary variable. This is a programming bug, not a user error. Please contact system vendor.';
    begin
        if not ToItemAddOnLine.IsTemporary then
            Error(MustBeTempMsg, 'CU6151125.CopyItemAddOnLinesToTemp');

        ToItemAddOnLine.Reset();
        if NewDataSet then
            ToItemAddOnLine.DeleteAll();

        if FromItemAddOnLine.FindSet() then
            repeat
                ToItemAddOnLine := FromItemAddOnLine;
                if not ToItemAddOnLine.Find() then
                    ToItemAddOnLine.Insert();
            until FromItemAddOnLine.Next() = 0;
    end;

    procedure InsertedWithAutoSplitKey(): Boolean
    begin
        exit(IsAutoSplitKeyRecord);
    end;

    #region Json helper functions
    procedure GetJCode(Token: JsonToken; Path: Text; MaxLength: Integer; Required: Boolean) Value: Text
    var
        JValue: JsonValue;
    begin
        if GetJValue(Token, Path, JValue) then begin
            Value := JValue.AsCode();
            if MaxLength > 0 then
                Value := CopyStr(Value, 1, MaxLength);
            Value := UpperCase(Value);
            exit(Value);
        end;
        if Required then
            Error(GetLastErrorText());
        exit('');
    end;

    [TryFunction]
    local procedure GetJValue(Token: JsonToken; Path: Text; var JValue: JsonValue)
    var
        Token2: JsonToken;
        ValueMissingErr: Label 'Required value missing: %1';
    begin
        if not Token.SelectToken(Path, Token2) then
            Error(ValueMissingErr, GetAbsolutePath(Token, Path));

        JValue := Token2.AsValue();
        if JValue.IsNull() or JValue.IsUndefined() then
            Error(ValueMissingErr, GetAbsolutePath(Token, Path));
    end;

    local procedure GetAbsolutePath(Token: JsonToken; Path: Text) AbsolutePath: Text
    begin
        AbsolutePath := Token.Path();
        if (AbsolutePath <> '') and (Path <> '') then
            AbsolutePath += '/';
        AbsolutePath += Path;
        exit(AbsolutePath);
    end;
    #endregion
}
