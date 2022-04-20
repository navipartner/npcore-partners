codeunit 6151285 "NPR SS Action - Item AddOn"
{
    Access = Internal;

    var
        ActionDescription: Label 'This built in function sets the item addon values';
        CommentCaption: Label 'Comment';
        PopupTitle: Label 'Select your options...';

    local procedure ActionCode(): Text[20]
    begin

        exit('SS-ITEM-ADDON');
    end;

    local procedure ActionVersion(): Text[30]
    begin

        exit('2.3');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction20(
          ActionCode(),
          ActionDescription,
          ActionVersion())
        then begin
            Sender.RegisterWorkflow20(
              'let addonJson = await workflow.respond("GetSalesLineAddonConfigJson");' +
              'let addonConfig = JSON.parse (addonJson);' +
              '$context.userSelectedAddons = await popup.configuration (addonConfig);' +
              'if ($context.userSelectedAddons) {await workflow.respond ("SetItemAddons")};'
              );

            Sender.RegisterTextParameter('ItemAddOnNo', '');
            Sender.SetWorkflowTypeUnattended();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        case WorkflowStep of
            'GetSalesLineAddonConfigJson':
                FrontEnd.WorkflowResponse(GetAddonConfigJson(POSSession, Context));
            'SetItemAddons':
                UpdateOrder(POSSession, Context);
        end;

        POSSession.RequestRefreshData();
    end;

    procedure GetAddonConfigJson(POSSession: Codeunit "NPR POS Session"; Context: Codeunit "NPR POS JSON Management") JsonText: Text
    var
        Item: Record Item;
        AuxItem: Record "NPR Auxiliary Item";
        ItemAddOn: Record "NPR NpIa Item AddOn";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if (not ItemAddOn.Get(Context.GetStringParameter('ItemAddOnNo'))) then begin
            if (SaleLinePOS.Type <> SaleLinePOS.Type::Item) then
                exit;
            if (not Item.Get(SaleLinePOS."No.")) then
                exit;
            Item.NPR_GetAuxItem(AuxItem);
            if (not ItemAddOn.Get(AuxItem."Item AddOn No.")) then
                exit;
        end;

        JsonText := FORMAT(GenerateAddonConfigJson(POSSale, SaleLinePOS, ItemAddOn));


        exit(JsonText);
    end;

    local procedure GenerateAddonConfigJson(POSSale: Codeunit "NPR POS Sale"; MasterSaleLinePOS: Record "NPR POS Sale Line"; ItemAddOn: Record "NPR NpIa Item AddOn") ConfigJObject: JsonObject
    var
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        ItemAddOnLineOption: Record "NPR NpIa ItemAddOn Line Opt.";
        SaleLinePOS: Record "NPR POS Sale Line";
        CommentText: Text;
        Quantity: Decimal;
        ItemAddOn_LinesJArray: JsonArray;
        ItemAddOn_GroupLineSettingsJArray: JsonArray;
        ItemAddOn_GroupLineJObject: JsonObject;
        ItemAddOn_LineJObject: JsonObject;
        ValueJObject: JsonObject;
    begin

        ItemAddOnLine.SetRange("AddOn No.", ItemAddOn."No.");
        if (ItemAddOnLine.FindSet()) then begin
            repeat

                if (FindSaleLine(POSSale, MasterSaleLinePOS."Line No.", ItemAddOnLine, SaleLinePOS)) then
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

    procedure UpdateOrder(POSSession: Codeunit "NPR POS Session"; Context: Codeunit "NPR POS JSON Management")
    var
        Item: Record Item;
        ItemAddOn: Record "NPR NpIa Item AddOn";
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        AuxItem: Record "NPR Auxiliary Item";
        UserValue: Text;
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        MasterLineNumber: Integer;
        ItemAddOnLineNoLbl: Label '%1_text', Locked = true;
    begin

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);

        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);

        MasterLineNumber := 0;
        if (not ItemAddOn.Get(Context.GetStringParameter('ItemAddOnNo'))) then begin
            POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
            if (SaleLinePOS.Type <> SaleLinePOS.Type::Item) then
                exit;
            if (not Item.Get(SaleLinePOS."No.")) then
                exit;
            Item.NPR_GetAuxItem(AuxItem);
            if (not ItemAddOn.Get(AuxItem."Item AddOn No.")) then
                exit;
            MasterLineNumber := SaleLinePOS."Line No.";
        end;

        if (not Context.SetScope('userSelectedAddons')) then
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

                // Check if there is comment value
                UserValue := Context.GetString(StrSubstNo(ItemAddOnLineNoLbl, Format(ItemAddOnLine."Line No.", 0, 9)));
                ApplyUserComment(UserValue, ItemAddOn, POSSaleLine);

            until (ItemAddOnLine.Next() = 0);
        end;
    end;

    local procedure ApplyUserQuantity(Value: Text; ItemAddOnLine: Record "NPR NpIa Item AddOn Line"; MasterLineNumber: Integer; POSSale: Codeunit "NPR POS Sale"; POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        DecVal: Decimal;
        BooleanValue: Boolean;
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

        if (DecVal <= 0) then
            exit;

        if (not FindSaleLine(POSSale, MasterLineNumber, ItemAddOnLine, SaleLinePOS)) then begin
            POSSaleLine.GetNewSaleLine(SaleLinePOS);

            // Should be refactored and use ITEM WF2.0 with sequences
            SaleLinePOS.Type := SaleLinePOS.Type::Item;
            SaleLinePOS."Variant Code" := ItemAddOnLine."Variant Code";
            SaleLinePOS.Validate("No.", ItemAddOnLine."Item No.");
            SaleLinePOS.Description := ItemAddOnLine.Description;

            SaleLinePOS.Validate(Quantity, ItemAddOnLine.Quantity);
            if (ItemAddOnLine."Unit Price" <> 0) then begin
                SaleLinePOS."Manual Item Sales Price" := true;
                SaleLinePOS.Validate("Unit Price", ItemAddOnLine."Unit Price");
            end;

            SaleLinePOS.Validate(Quantity, DecVal);
            SaleLinePOS.Validate("Discount %", ItemAddOnLine."Discount %");
            POSSaleLine.InsertLine(SaleLinePOS);

            InsertAddOn(SaleLinePOS, ItemAddOnLine, MasterLineNumber);
        end;

        SaleLinePOS.Validate(Quantity, DecVal);
        SaleLinePOS.Validate("Discount %", ItemAddOnLine."Discount %");
        SaleLinePOS.Modify(true);
    end;

    local procedure ApplyUserItem(Value: Text; NpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line"; MasterLineNumber: Integer; POSSale: Codeunit "NPR POS Sale"; POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        ItemAddOnLineOption: Record "NPR NpIa ItemAddOn Line Opt.";
        SelectionValue: JsonToken;
        ItemNo: Code[20];
        VariantCode: Code[10];
    begin

        if (Value = '') then
            exit;

        SelectionValue.ReadFrom(Value);
        ItemNo := CopyStr(GetValueAsString(SelectionValue, 'item'), 1, MaxStrLen(ItemNo));
        VariantCode := CopyStr(GetValueAsString(SelectionValue, 'variant'), 1, MaxStrLen(VariantCode));

        ItemAddOnLineOption.SetFilter("AddOn No.", '=%1', NpIaItemAddOnLine."AddOn No.");
        ItemAddOnLineOption.SetFilter("AddOn Line No.", '=%1', NpIaItemAddOnLine."Line No.");
        ItemAddOnLineOption.SetFilter("Item No.", '=%1', ItemNo);
        ItemAddOnLineOption.SetFilter("Variant Code", '=%1', VariantCode);
        ItemAddOnLineOption.FindFirst();

        if (not FindSaleLine(POSSale, MasterLineNumber, NpIaItemAddOnLine, SaleLinePOS)) then begin
            POSSaleLine.GetNewSaleLine(SaleLinePOS);

            // Should be refactored and use ITEM WF2.0 with sequences
            SaleLinePOS.Type := SaleLinePOS.Type::Item;
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

        SaleLinePOS.Type := SaleLinePOS.Type::Item;
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
            POSInfoTransaction."Receipt Type" := SaleLinePOS.Type;
            POSInfoTransaction."Entry No." := 0;
            POSInfoTransaction."POS Info Code" := POSInfo.Code;
            POSInfoTransaction."POS Info" := CopyStr(Comment, 1, MaxStrLen(POSInfoTransaction."POS Info"));
            POSInfoTransaction.Insert(true);

            Comment := DelStr(Comment, 1, StrLen(POSInfoTransaction."POS Info"));
        end;
    end;

    local procedure FindSaleLine(POSSale: Codeunit "NPR POS Sale"; AppliesToLineNo: Integer; NpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line"; var SaleLinePOS: Record "NPR POS Sale Line"): Boolean
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
    begin

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
        SaleLinePOSAddOn.SetRange("Sale Type", SaleLinePOS."Sale Type");
        SaleLinePOSAddOn.SetRange("Sale Date", SaleLinePOS.Date);
        SaleLinePOSAddOn.SetRange("Sale Line No.", SaleLinePOS."Line No.");
        SaleLinePOSAddOn."Line No." := 0;

        if (SaleLinePOSAddOn.FindLast()) then
            SaleLinePOSAddOn."Line No." := SaleLinePOSAddOn."Line No." + 10000;

        SaleLinePOSAddOn."Register No." := SaleLinePOS."Register No.";
        SaleLinePOSAddOn."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
        SaleLinePOSAddOn."Sale Type" := SaleLinePOS."Sale Type";
        SaleLinePOSAddOn."Sale Date" := SaleLinePOS.Date;
        SaleLinePOSAddOn."Sale Line No." := SaleLinePOS."Line No.";

        SaleLinePOSAddOn.Init();
        SaleLinePOSAddOn."Applies-to Line No." := AppliesToLineNo;
        SaleLinePOSAddOn."AddOn No." := NpIaItemAddOnLine."AddOn No.";
        SaleLinePOSAddOn."AddOn Line No." := NpIaItemAddOnLine."Line No.";
        SaleLinePOSAddOn."Fixed Quantity" := NpIaItemAddOnLine."Fixed Quantity";
        SaleLinePOSAddOn."Per Unit" := NpIaItemAddOnLine."Per Unit";
        SaleLinePOSAddOn.Mandatory := NpIaItemAddOnLine.Mandatory;
        SaleLinePOSAddOn.Insert(true);
    end;

    local procedure GetValueAsString(JToken: JsonToken; JPath: Text): Text
    begin
        if not JToken.AsObject().SelectToken(JPath, JToken) then
            exit('');

        exit(Format(JToken.AsValue().AsText()));
    end;
}

