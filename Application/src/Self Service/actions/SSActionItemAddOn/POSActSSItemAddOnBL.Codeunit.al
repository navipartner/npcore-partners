codeunit 6060027 "NPR POSAct. SS Item AddOn-BL"
{
    Access = Internal;
    procedure GenerateAddonConfigJson(POSSale: Codeunit "NPR POS Sale"; MasterSaleLinePOS: Record "NPR POS Sale Line"; ItemAddOn: Record "NPR NpIa Item AddOn") ConfigJObject: JsonObject
    var
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        ItemAddOnLineOption: Record "NPR NpIa ItemAddOn Line Opt.";
        SaleLinePOS: Record "NPR POS Sale Line";
        Quantity: Decimal;
        AppliesToLineNo: Integer;
        ItemAddOn_GroupLineSettingsJArray: JsonArray;
        ItemAddOn_LinesJArray: JsonArray;
        ItemAddOn_GroupLineJObject: JsonObject;
        ItemAddOn_LineJObject: JsonObject;
        ValueJObject: JsonObject;
        CommentCaption: Label 'Comment';
        PopupTitle: Label 'Select your options...';
        CommentText: Text;
    begin
        ItemAddOnLine.SetRange("AddOn No.", ItemAddOn."No.");
        if (ItemAddOnLine.FindSet()) then begin
            repeat

                AppliesToLineNo := FindAppliesToLineNo(MasterSaleLinePOS);

                if (FindSaleLine(POSSale, AppliesToLineNo, ItemAddOnLine, SaleLinePOS)) then
                    CommentText := '';

                if (ItemAddOnLine.Type = ItemAddOnLine.Type::Quantity) then begin

                    CommentText := '';
                    if (ItemAddOnLine."Comment Enabled") or (CommentText <> '') then
                        ItemAddOn_LineJObject.Add('caption', ItemAddOnLine."Description 2");


                    Quantity := SaleLinePOS.Quantity;
                    if (Quantity = 0) then
                        Quantity := ItemAddOnLine.Quantity;
                    case (ItemAddOnLine."Fixed Quantity") of
                        false:
                            begin
                                Clear(ItemAddOn_GroupLineJObject);
                                ItemAddOn_GroupLineJObject.Add('id', ItemAddOnLine."Line No.");
                                ItemAddOn_GroupLineJObject.Add('caption', ItemAddOnLine.Description);
                                ItemAddOn_GroupLineJObject.Add('type', 'plusminus');
                                ItemAddOn_GroupLineJObject.Add('value', Quantity);
                                ItemAddOn_LinesJArray.Add(ItemAddOn_GroupLineJObject);
                            end;
                        true:
                            begin
                                Clear(ItemAddOn_GroupLineJObject);
                                ItemAddOn_GroupLineJObject.Add('id', ItemAddOnLine."Line No.");
                                ItemAddOn_GroupLineJObject.Add('caption', ItemAddOnLine.Description);
                                ItemAddOn_GroupLineJObject.Add('type', 'switch');
                                ItemAddOn_LinesJArray.Add(ItemAddOn_GroupLineJObject);
                            end;

                    end;

                    if (ItemAddOnLine."Comment Enabled") or (CommentText <> '') then begin

                        Clear(ItemAddOn_LineJObject);
                        ItemAddOn_LineJObject.Add('type', 'text');
                        ItemAddOn_LineJObject.Add('id', ItemAddOnLine."Line No.");
                        ItemAddOn_LineJObject.Add('caption', CommentCaption);
                        ItemAddOn_LineJObject.Add('value', CommentText);
                        ItemAddOn_GroupLineSettingsJArray.Add(ItemAddOn_LineJObject);

                    end;

                end;

                if (ItemAddOnLine.Type = ItemAddOnLine.Type::Select) then begin
                    ItemAddOnLineOption.SetRange("AddOn No.", ItemAddOnLine."AddOn No.");
                    ItemAddOnLineOption.SetRange("AddOn Line No.", ItemAddOnLine."Line No.");
                    ItemAddOnLineOption.SetFilter(Description, '<>%1', '');
                    if (ItemAddOnLineOption.FindSet()) then begin
                        CommentText := '';
                        if (ItemAddOnLine."Comment Enabled") or (CommentText <> '') then begin
                            ItemAddOn_LineJObject.Add('caption', ItemAddOnLineOption."Description 2");
                            ItemAddOn_LineJObject.Add('type', 'group');
                            ItemAddOn_LineJObject.Add('expanded', 'true');
                        end;

                        ItemAddOn_LineJObject.Add('type', 'radio');

                        Clear(ValueJObject);
                        ValueJObject.Add('item', SaleLinePOS."No.");
                        ValueJObject.Add('variant', SaleLinePOS."Variant Code");
                        ItemAddOn_LineJObject.Add('value', ValueJObject);

                        if ((SaleLinePOS."No." = '') and (SaleLinePOS."Variant Code" = '')) then begin
                            Clear(ValueJObject);
                            ValueJObject.Add('item', SaleLinePOS."No.");
                            ValueJObject.Add('variant', SaleLinePOS."Variant Code");
                            ItemAddOn_LineJObject.Add('value', ValueJObject);
                        end;
                        ItemAddOn_LineJObject.Add('id', ItemAddOnLine."Line No.");
                        ItemAddOn_LineJObject.Add('caption', ItemAddOnLine.Description);
                        ItemAddOn_LineJObject.Add('value', ValueJObject);

                        repeat
                            Clear(ValueJObject);
                            ValueJObject.Add('item', SaleLinePOS."No.");
                            ValueJObject.Add('variant', SaleLinePOS."Variant Code");
                            ItemAddOn_LineJObject.Add('value', ValueJObject);

                            ItemAddOn_GroupLineJObject.Add('caption', ItemAddOnLine.Description);
                            ItemAddOn_GroupLineJObject.Add('value', ItemAddOn_LineJObject);
                        until (ItemAddOnLineOption.Next() = 0);

                        if (ItemAddOnLine."Comment Enabled") or (CommentText <> '') then begin
                            Clear(ItemAddOn_GroupLineJObject);
                            ItemAddOn_GroupLineJObject.Add('type', 'text');
                            ItemAddOn_GroupLineJObject.Add('id', ItemAddOnLine."Line No.");
                            ItemAddOn_GroupLineJObject.Add('caption', CommentCaption);
                            ItemAddOn_GroupLineJObject.Add('value', CommentText);
                            ItemAddOn_LinesJArray.Add(ItemAddOn_GroupLineJObject);
                        end;
                    end;
                end;

            until (ItemAddOnLine.Next() = 0);
        end;
        ConfigJObject.Add('caption', ItemAddOn.Description);
        ConfigJObject.Add('title', PopupTitle);
        ConfigJObject.Add('settings', ItemAddOn_LinesJArray)
    end;

    procedure UpdateOrder(Context: Codeunit "NPR POS JSON Helper"; POSSale: Codeunit "NPR POS Sale"; POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        Item: Record Item;
        ItemAddOn: Record "NPR NpIa Item AddOn";
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        MasterLineNumber: Integer;
        ItemAddOnLineNoLbl: Label '%1_text', Locked = true;
        UserValue: Text;
    begin
        POSSale.GetCurrentSale(SalePOS);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        MasterLineNumber := 0;
        if (not ItemAddOn.Get(Context.GetStringParameter('ItemAddOnNo'))) then begin
            POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
            if (SaleLinePOS."Line Type" <> SaleLinePOS."Line Type"::Item) then
                exit;
            if (not Item.Get(SaleLinePOS."No.")) then
                exit;
            if (not ItemAddOn.Get(Item."NPR Item AddOn No.")) then
                exit;
            MasterLineNumber := SaleLinePOS."Line No.";
        end;

        if not Context.TrySetScope('userSelectedAddons') then
            exit;

        ItemAddOnLine.SetRange("AddOn No.", ItemAddOn."No.");
        if (ItemAddOnLine.FindSet()) then begin
            repeat
                UserValue := Context.GetString(Format(ItemAddOnLine."Line No.", 0, 9));

                case ItemAddOnLine.Type of
                    ItemAddOnLine.Type::Quantity:
                        ApplyUserQuantity(UserValue, ItemAddOnLine, MasterLineNumber, POSSale, POSSaleLine);
                    ItemAddOnLine.Type::Select:
                        ApplyUserItem(UserValue, ItemAddOnLine, MasterLineNumber, POSSale, POSSaleLine);
                end;

                // Check if there is comment value/ Comment will never have value looking at this code
                Context.GetString(StrSubstNo(ItemAddOnLineNoLbl, Format(ItemAddOnLine."Line No.", 0, 9)), UserValue);
                ApplyUserComment(UserValue, ItemAddOn, POSSaleLine);

            until (ItemAddOnLine.Next() = 0);
        end;
    end;

    procedure ApplyUserQuantity(Value: Text; ItemAddOnLine: Record "NPR NpIa Item AddOn Line"; MasterLineNumber: Integer; POSSale: Codeunit "NPR POS Sale"; POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        BooleanValue: Boolean;
        DecVal: Decimal;
    begin

        if (Value = '') then
            exit;

        DecVal := 0;
        if (not Evaluate(DecVal, Value)) then begin
            if (not Evaluate(BooleanValue, Value)) then
                exit;

            if (BooleanValue) then
                DecVal := 1;
        end;

        if (DecVal < 0) then
            exit;

        if (DecVal = 0) then begin
            if FindSaleLine(POSSale, MasterLineNumber, ItemAddOnLine, SaleLinePOS) then begin
                POSSaleLine.SetPosition(SaleLinePOS.GetPosition());
                POSSaleLine.DeleteLine();
            end;
            exit;
        end;


        if (not FindSaleLine(POSSale, MasterLineNumber, ItemAddOnLine, SaleLinePOS)) then begin
            POSSaleLine.GetNewSaleLine(SaleLinePOS);

            // Should be refactored and use ITEM WF2.0 with sequences
            SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Item;
            SaleLinePOS."Variant Code" := ItemAddOnLine."Variant Code";
            SaleLinePOS.Validate("No.", ItemAddOnLine."Item No.");
            SaleLinePOS.Description := ItemAddOnLine.Description;

            SaleLinePOS.Validate(Quantity, ItemAddOnLine.Quantity);
            if (ItemAddOnLine."Unit Price" <> 0) then begin
                SaleLinePOS."Manual Item Sales Price" := true;
                SaleLinePOS.Validate("Unit Price", ItemAddOnLine."Unit Price");
            end;

            SaleLinePOS.Validate(Quantity, DecVal);
            if (ItemAddOnLine."Discount %" <> 0) and (ItemAddOnLine.DiscountAmount = 0) then
                SaleLinePOS.Validate("Discount %", ItemAddOnLine."Discount %");
            if (ItemAddOnLine."Discount %" = 0) and (ItemAddOnLine.DiscountAmount <> 0) then
                SaleLinePOS.Validate("Discount Amount", ItemAddOnLine.DiscountAmount);

            POSSaleLine.InsertLine(SaleLinePOS);

            InsertAddOn(SaleLinePOS, ItemAddOnLine, MasterLineNumber);
        end;

        SaleLinePOS.Validate(Quantity, DecVal);
        if (ItemAddOnLine."Discount %" <> 0) and (ItemAddOnLine.DiscountAmount = 0) then
            SaleLinePOS.Validate("Discount %", ItemAddOnLine."Discount %");
        if (ItemAddOnLine."Discount %" = 0) and (ItemAddOnLine.DiscountAmount <> 0) then
            SaleLinePOS.Validate("Discount Amount", ItemAddOnLine.DiscountAmount);

        SaleLinePOS.Modify(true);
    end;

    local procedure ApplyUserItem(Value: Text; NpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line"; MasterLineNumber: Integer; POSSale: Codeunit "NPR POS Sale"; POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        ItemAddOnLineOption: Record "NPR NpIa ItemAddOn Line Opt.";
        SaleLinePOS: Record "NPR POS Sale Line";
        VariantCode: Code[10];
        ItemNo: Code[20];
        SelectionValue: JsonToken;
    begin

        if (Value = '') then
            exit;

        SelectionValue.ReadFrom(Value);
        ItemNo := CopyStr(GetValueAsString(SelectionValue, 'item'), 1, MaxStrLen(ItemNo));
        VariantCode := CopyStr(GetValueAsString(SelectionValue, 'variant'), 1, MaxStrLen(VariantCode));

        ItemAddOnLineOption.SetRange("AddOn No.", NpIaItemAddOnLine."AddOn No.");
        ItemAddOnLineOption.SetRange("AddOn Line No.", NpIaItemAddOnLine."Line No.");
        ItemAddOnLineOption.SetRange("Item No.", ItemNo);
        ItemAddOnLineOption.SetRange("Variant Code", VariantCode);
        ItemAddOnLineOption.FindFirst();

        if (not FindSaleLine(POSSale, MasterLineNumber, NpIaItemAddOnLine, SaleLinePOS)) then begin
            POSSaleLine.GetNewSaleLine(SaleLinePOS);

            // Should be refactored and use ITEM WF2.0 with sequences
            SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Item;
            SaleLinePOS."Variant Code" := VariantCode;
            SaleLinePOS.Validate("No.", ItemNo);
            SaleLinePOS.Description := ItemAddOnLineOption.Description;

            SaleLinePOS.Validate(Quantity, ItemAddOnLineOption.Quantity);
            if NpIaItemAddOnLine."Unit Price" <> 0 then begin
                SaleLinePOS."Manual Item Sales Price" := true;
                SaleLinePOS.Validate("Unit Price", ItemAddOnLineOption."Unit Price");
            end;

            SaleLinePOS.Validate(Quantity, ItemAddOnLineOption.Quantity);
            SaleLinePOS.Validate("Discount %", ItemAddOnLineOption."Discount %");
            POSSaleLine.InsertLine(SaleLinePOS);

            InsertAddOn(SaleLinePOS, NpIaItemAddOnLine, MasterLineNumber);
        end;

        SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Item;
        SaleLinePOS."Variant Code" := ItemAddOnLineOption."Variant Code";
        SaleLinePOS.Validate("No.", ItemAddOnLineOption."Item No.");
        SaleLinePOS.Description := ItemAddOnLineOption.Description;
        if ItemAddOnLineOption."Unit Price" <> 0 then begin
            SaleLinePOS."Manual Item Sales Price" := true;
            SaleLinePOS.Validate("Unit Price", ItemAddOnLineOption."Unit Price");
        end;
        SaleLinePOS.Validate(Quantity, ItemAddOnLineOption.Quantity);
        SaleLinePOS.Validate("Discount %", ItemAddOnLineOption."Discount %");
        SaleLinePOS.Modify(true);
    end;

    local procedure ApplyUserComment(Comment: Text; NpIaItemAddOn: Record "NPR NpIa Item AddOn"; POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        POSInfo: Record "NPR POS Info";
        POSInfoTransaction: Record "NPR POS Info Transaction";
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        if (NpIaItemAddOn."Comment POS Info Code" = '') then
            exit;

        if (not POSInfo.Get(NpIaItemAddOn."Comment POS Info Code")) then
            exit;

        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        POSInfoTransaction.SetRange("POS Info Code", POSInfo.Code);
        POSInfoTransaction.SetRange("Register No.", SaleLinePOS."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        POSInfoTransaction.SetRange("Sales Line No.", SaleLinePOS."Line No.");
        POSInfoTransaction.SetRange("Sale Date", SaleLinePOS.Date);
        if (POSInfoTransaction.FindFirst()) then
            POSInfoTransaction.DeleteAll();

        if Comment = '' then
            exit;

        while Comment <> '' do begin
            POSInfoTransaction.Init();
            POSInfoTransaction."Register No." := SaleLinePOS."Register No.";
            POSInfoTransaction."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
            POSInfoTransaction."Sales Line No." := SaleLinePOS."Line No.";
            POSInfoTransaction."Sale Date" := SaleLinePOS.Date;
            POSInfoTransaction."Line Type" := SaleLinePOS."Line Type";
            POSInfoTransaction."Entry No." := 0;
            POSInfoTransaction."POS Info Code" := POSInfo.Code;
            POSInfoTransaction."POS Info" := CopyStr(Comment, 1, MaxStrLen(POSInfoTransaction."POS Info"));
            POSInfoTransaction.Insert(true);

            Comment := DelStr(Comment, 1, StrLen(POSInfoTransaction."POS Info"));
        end;
    end;

    local procedure FindAppliesToLineNo(SaleLinePOS: Record "NPR POS Sale Line"): Integer
    var
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
        ItemAddOnMgt: Codeunit "NPR NpIa Item AddOn Mgt.";
    begin
        ItemAddOnMgt.FilterSaleLinePOS2ItemAddOnPOSLine(SaleLinePOS, SaleLinePOSAddOn);
        if SaleLinePOSAddOn.FindFirst() then
            exit(SaleLinePOSAddOn."Applies-to Line No.");

        exit(SaleLinePOS."Line No.");
    end;


    local procedure FindSaleLine(POSSale: Codeunit "NPR POS Sale"; AppliesToLineNo: Integer; NpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line"; var SaleLinePOS: Record "NPR POS Sale Line"): Boolean
    var
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
        SalePOS: Record "NPR POS Sale";

    begin
        Clear(SaleLinePOS);

        POSSale.GetCurrentSale(SalePOS);

        SaleLinePOSAddOn.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOSAddOn.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOSAddOn.SetRange("AddOn No.", NpIaItemAddOnLine."AddOn No.");
        SaleLinePOSAddOn.SetRange("AddOn Line No.", NpIaItemAddOnLine."Line No.");
        SaleLinePOSAddOn.SetRange("Applies-to Line No.", AppliesToLineNo);
        if not SaleLinePOSAddOn.FindFirst() then
            exit(false);

        exit(SaleLinePOS.Get(SaleLinePOSAddOn."Register No.",
                             SaleLinePOSAddOn."Sales Ticket No.",
                             SaleLinePOSAddOn."Sale Date",
                             SaleLinePOSAddOn."Sale Type",
                             SaleLinePOSAddOn."Sale Line No."));

    end;

    local procedure InsertAddOn(SaleLinePOS: Record "NPR POS Sale Line"; NpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line"; AppliesToLineNo: Integer)
    var
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
    begin

        // Register No., Sales Ticket No., Sale Type, Sale Date, Sale Line No., Line No.
        SaleLinePOSAddOn.SetRange("Register No.", SaleLinePOS."Register No.");
        SaleLinePOSAddOn.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        SaleLinePOSAddOn.SetRange("Sale Date", SaleLinePOS.Date);
        SaleLinePOSAddOn.SetRange("Sale Line No.", SaleLinePOS."Line No.");
        SaleLinePOSAddOn."Line No." := 0;

        if (SaleLinePOSAddOn.FindLast()) then
            SaleLinePOSAddOn."Line No." := SaleLinePOSAddOn."Line No." + 10000;

        SaleLinePOSAddOn."Register No." := SaleLinePOS."Register No.";
        SaleLinePOSAddOn."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
        SaleLinePOSAddOn."Sale Date" := SaleLinePOS.Date;
        SaleLinePOSAddOn."Sale Line No." := SaleLinePOS."Line No.";

        SaleLinePOSAddOn.Init();
        SaleLinePOSAddOn."Applies-to Line No." := AppliesToLineNo;
        SaleLinePOSAddOn."AddOn No." := NpIaItemAddOnLine."AddOn No.";
        SaleLinePOSAddOn."AddOn Line No." := NpIaItemAddOnLine."Line No.";
        SaleLinePOSAddOn."Fixed Quantity" := NpIaItemAddOnLine."Fixed Quantity";
        SaleLinePOSAddOn."Per Unit" := NpIaItemAddOnLine."Per Unit";
        SaleLinePOSAddOn.Mandatory := NpIaItemAddOnLine.Mandatory;
        SaleLinePOSAddOn.AddToWallet := NpIaItemAddOnLine.AddToWallet;
        SaleLinePOSAddOn.AddOnItemNo := NpIaItemAddOnLine."Item No.";
        SaleLinePOSAddOn.Insert(true);
    end;

    local procedure GetValueAsString(JToken: JsonToken; JPath: Text): Text
    begin
        if not JToken.AsObject().SelectToken(JPath, JToken) then
            exit('');

        exit(Format(JToken.AsValue().AsText()));
    end;

    procedure LookupItemAddOn(var AddOnNo: Code[20]): Boolean
    var
        ItemAddOn: Record "NPR NpIa Item AddOn";
    begin
        ItemAddOn.FilterGroup(2);
        ItemAddOn.SetRange(Enabled, true);
        ItemAddOn.FilterGroup(0);
        if AddOnNo <> '' then begin
            ItemAddOn."No." := AddOnNo;
            if ItemAddOn.Find('=><') then;
        end;
        if Page.RunModal(0, ItemAddOn) = Action::LookupOK then begin
            AddOnNo := ItemAddOn."No.";
            exit(true);
        end;
        exit(false);
    end;
}