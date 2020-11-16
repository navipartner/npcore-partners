codeunit 6151285 "NPR SS Action - Item AddOn"
{
    // 
    // NPR5.54/TSA /20200205 CASE 387912 Initial Version
    // NPR5.55/TSA /20200424 CASE 387912 Adjusted the workflow, added title to popup


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This built in function sets the item addon values';
        CommentCaption: Label 'Comment';
        PopupTitle: Label 'Select your options...';

    local procedure ActionCode(): Text
    begin

        exit('SS-ITEM-ADDON');
    end;

    local procedure ActionVersion(): Text
    begin

        exit('2.3');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin

        with Sender do
            if DiscoverAction20(
              ActionCode(),
              ActionDescription,
              ActionVersion())
            then begin
                RegisterWorkflow20(
                  'let addonJson = await workflow.respond("GetSalesLineAddonConfigJson");' +
                  'let addonConfig = JSON.parse (addonJson);' +
                  '$context.userSelectedAddons = await popup.configuration (addonConfig);' +
                  'if ($context.userSelectedAddons) {await workflow.respond ("SetItemAddons")};'
                  );

                RegisterTextParameter('ItemAddOnNo', '');
                SetWorkflowTypeUnattended();
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150733, 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode) then
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
        SalePOS: Record "NPR Sale POS";
        SaleLinePOS: Record "NPR Sale Line POS";
        ItemAddOn: Record "NPR NpIa Item AddOn";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if (not ItemAddOn.Get(Context.GetStringParameter('ItemAddOnNo', false))) then begin
            if (SaleLinePOS.Type <> SaleLinePOS.Type::Item) then
                exit;
            if (not Item.Get(SaleLinePOS."No.")) then
                exit;
            if (not ItemAddOn.Get(Item."NPR Item AddOn No.")) then
                exit;
        end;

        JsonText := GenerateAddonConfigJson(POSSale, SaleLinePOS, ItemAddOn);
        //IF (USERID = 'TSA') THEN MESSAGE(JsonText);
        exit(JsonText);

        // Debug
        // JsonText :=
        //  '{"caption":"Hello - Please, specify the following configuration settings","title":"Item configuration","settings":['+
        //  '  {"caption":"Burger configuration","type":"group","settings":['+
        //  '    {"type":"plusminus","id":"burgers","caption":"Burgers","value":7.00,"minvalue":1.1,"maxvalue":3.2},'+
        //  '    {"type":"switch","id":"xl","caption":"Extra large"},'+
        //  '    {"type":"text","id":"text2_value","caption":"Enter some text"},'+
        //  '    {"type":"switch","id":"cheese","caption":"Slice of cheese","value":true}'+
        //  '  ]},'+
        //  '  {"caption":"Sauces","type":"group","settings":['+
        //  '    {"type":"plusminus","id":"ketchup","caption":"Ketchup","value":0},'+
        //  '    {"type":"plusminus","id":"mayo","caption":"Mayonnaise","value":0},'+
        //  '    {"type":"radio","id":"sauce","caption":"Special sauce", "value":"bbq", "options":['+
        //  '      {"caption":"None","value":"none"},'+
        //  '      {"caption":"Barbecue","value":"bbq"},'+
        //  '      {"caption":"Bernaise","value":"bernaise"},'+
        //  '      {"caption":"Mushroom","value":"mushroom"}'+
        //  '    ]}'+
        //  '  ]},'+
        //  '  {"type":"switch","id":"takeaway","caption":"To take away"},'+
        //  '  {"type":"plusminus","id":"napkins","caption":"Extra napkins","minvalue":1,"maxvalue":10},'+
        //  '  {"type":"text","id":"text_value","caption":"Enter some text"},'+
        //  '  {"type":"decimal","id":"decimal_value","caption":"Enter a decimal number"},'+
        //  '  {"type":"integer","id":"integer_value","caption":"Enter an integer number"}'+
        //  ']}';
        //
        // MESSAGE ('%1', JsonText);
        // EXIT (JsonText);
    end;

    local procedure GenerateAddonConfigJson(POSSale: Codeunit "NPR POS Sale"; MasterSaleLinePOS: Record "NPR Sale Line POS"; ItemAddOn: Record "NPR NpIa Item AddOn") JsonString: Text
    var
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        ItemAddOnLineOption: Record "NPR NpIa ItemAddOn Line Opt.";
        SaleLinePOS: Record "NPR Sale Line POS";
        CommentText: Text;
        Quantity: Decimal;
        Value: Text;
    begin

        //-NPR5.55 [387912]
        //JsonString := STRSUBSTNO ('{"caption":"%1","title":"%2","settings":[', FormatJson (ItemAddOn.Description), '');
        JsonString := StrSubstNo('{"caption":"%1","title":"%2","settings":[', FormatJson(ItemAddOn.Description), FormatJson(PopupTitle));
        //+NPR5.55 [387912]

        ItemAddOnLine.SetRange("AddOn No.", ItemAddOn."No.");
        if (ItemAddOnLine.FindSet()) then begin
            repeat

                if (FindSaleLine(POSSale, MasterSaleLinePOS."Line No.", ItemAddOnLine, SaleLinePOS)) then
                    CommentText := '';

                if (ItemAddOnLine.Type = ItemAddOnLine.Type::Quantity) then begin

                    CommentText := '';
                    if (ItemAddOnLine."Comment Enabled") or (CommentText <> '') then
                        Append(JsonString, StrSubstNo('{"caption":"%1", "type":"group", "expanded":%2, "settings":[', FormatJson(ItemAddOnLine."Description 2"), 'true'));

                    Quantity := SaleLinePOS.Quantity;
                    if (Quantity = 0) then
                        Quantity := ItemAddOnLine.Quantity;
                    case (ItemAddOnLine."Fixed Quantity") of
                        false:
                            Append(JsonString, StrSubstNo('{"type":"plusminus","id":"%1","caption":"%2","value":%3}', ItemAddOnLine."Line No.", FormatJson(ItemAddOnLine.Description), Quantity));
                        true:
                            Append(JsonString, StrSubstNo('{"type":"switch","id":"%1","caption":"%2","value":%3}', ItemAddOnLine."Line No.", FormatJson(ItemAddOnLine.Description), 'false'));
                    end;

                    if (ItemAddOnLine."Comment Enabled") or (CommentText <> '') then begin
                        Append(JsonString, StrSubstNo('{"type":"text","id":"%1_text","caption":"%2","value":"%3"}', ItemAddOnLine."Line No.", CommentCaption, CommentText));
                        JsonString += ']}';
                    end;

                end;

                if (ItemAddOnLine.Type = ItemAddOnLine.Type::Select) then begin
                    ItemAddOnLineOption.SetFilter("AddOn No.", '=%1', ItemAddOnLine."AddOn No.");
                    ItemAddOnLineOption.SetFilter("AddOn Line No.", '=%1', ItemAddOnLine."Line No.");
                    ItemAddOnLineOption.SetFilter(Description, '<>%1', '');
                    if (ItemAddOnLineOption.FindSet()) then begin
                        CommentText := '';
                        if (ItemAddOnLine."Comment Enabled") or (CommentText <> '') then
                            Append(JsonString, StrSubstNo('{"caption":"%1", "type":"group", "expanded":%2, "settings":[', FormatJson(ItemAddOnLine."Description 2"), 'true'));

                        Value := StrSubstNo('{\"item\":\"%1\",\"variant\":\"%2\"}', FormatJson(SaleLinePOS."No."), FormatJson(SaleLinePOS."Variant Code"));
                        if ((SaleLinePOS."No." = '') and (SaleLinePOS."Variant Code" = '')) then
                            Value := StrSubstNo('{\"item\":\"%1\",\"variant\":\"%2\"}', FormatJson(ItemAddOnLineOption."Item No."), FormatJson(ItemAddOnLineOption."Variant Code"));
                        Append(JsonString, StrSubstNo('{"type":"radio", "id":"%1", "caption":"%2", "value":"%3", "options":[', ItemAddOnLine."Line No.", FormatJson(ItemAddOnLine.Description), Value));

                        repeat
                            Value := StrSubstNo('{\"item\":\"%1\",\"variant\":\"%2\"}', FormatJson(ItemAddOnLineOption."Item No."), FormatJson(ItemAddOnLineOption."Variant Code"));
                            Append(JsonString, StrSubstNo('{"caption":"%1","value":"%2"}', FormatJson(ItemAddOnLineOption.Description), Value));

                        until (ItemAddOnLineOption.Next() = 0);
                        JsonString += ']}';

                        if (ItemAddOnLine."Comment Enabled") or (CommentText <> '') then begin
                            Append(JsonString, StrSubstNo('{"type":"text","id":"%1_text","caption":"%2","value":"%3"}', ItemAddOnLine."Line No.", CommentCaption, CommentText));
                            JsonString += ']}';
                        end;

                    end;
                end;

            until (ItemAddOnLine.Next() = 0);
        end;
        JsonString += ']}';
    end;

    local procedure FormatJson(Value: Text) JsonValue: Text
    var
        JsonConvert: DotNet NPRNetJsonConvert;
        Formatting: DotNet NPRNetFormatting;
    begin

        JsonValue := JsonConvert.SerializeObject(Value, Formatting.None);
        JsonValue := CopyStr(JsonValue, 2);
        JsonValue := DelStr(JsonValue, StrLen(JsonValue));
        exit(JsonValue);
    end;

    local procedure Append(var Text: Text; AppendText: Text)
    begin

        if (Text[StrLen(Text)] = '}') then
            Text += ',';

        Text += AppendText;
    end;

    procedure UpdateOrder(POSSession: Codeunit "NPR POS Session"; Context: Codeunit "NPR POS JSON Management")
    var
        ItemAddOn: Record "NPR NpIa Item AddOn";
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        ItemAddOnLineOption: Record "NPR NpIa ItemAddOn Line Opt.";
        SalePOS: Record "NPR Sale POS";
        SaleLinePOS: Record "NPR Sale Line POS";
        Item: Record Item;
        UserValue: Text;
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        MasterLineNumber: Integer;
    begin

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);

        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);

        MasterLineNumber := 0;
        if (not ItemAddOn.Get(Context.GetStringParameter('ItemAddOnNo', false))) then begin
            POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
            if (SaleLinePOS.Type <> SaleLinePOS.Type::Item) then
                exit;
            if (not Item.Get(SaleLinePOS."No.")) then
                exit;
            if (not ItemAddOn.Get(Item."NPR Item AddOn No.")) then
                exit;
            MasterLineNumber := SaleLinePOS."Line No.";
        end;

        if (not Context.SetScope('userSelectedAddons', false)) then
            exit;

        ItemAddOnLine.SetRange("AddOn No.", ItemAddOn."No.");
        if (ItemAddOnLine.FindSet()) then begin
            repeat
                UserValue := Context.GetString(Format(ItemAddOnLine."Line No.", 0, 9), false);

                case ItemAddOnLine.Type of
                    ItemAddOnLine.Type::Quantity:
                        ApplyUserQuantity(UserValue, ItemAddOnLine, MasterLineNumber, POSSale, POSSaleLine);
                    ItemAddOnLine.Type::Select:
                        ApplyUserItem(UserValue, ItemAddOnLine, MasterLineNumber, POSSale, POSSaleLine);
                end;

                // Check if there is comment value
                UserValue := Context.GetString(StrSubstNo('%1_text', Format(ItemAddOnLine."Line No.", 0, 9)), false);
                ApplyUserComment(UserValue, ItemAddOn, POSSaleLine);

            until (ItemAddOnLine.Next() = 0);
        end;
    end;

    local procedure ApplyUserQuantity(Value: Text; ItemAddOnLine: Record "NPR NpIa Item AddOn Line"; MasterLineNumber: Integer; POSSale: Codeunit "NPR POS Sale"; POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        SaleLinePOS: Record "NPR Sale Line POS";
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
        SaleLinePOS: Record "NPR Sale Line POS";
        ItemAddOnLineOption: Record "NPR NpIa ItemAddOn Line Opt.";
        SelectionValue: DotNet NPRNetJToken;
        ItemNo: Code[20];
        VariantCode: Code[10];
    begin

        if (Value = '') then
            exit;

        SelectionValue := SelectionValue.Parse(Value);
        ItemNo := GetValueAsString(SelectionValue, 'item');
        VariantCode := GetValueAsString(SelectionValue, 'variant');

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

        //BeforeInsertPOSAddOnLine(SalePOS,AppliesToLineNo,NpIaItemAddOnLine);

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
        SaleLinePOS: Record "NPR Sale Line POS";
        EntryNo: Integer;
    begin

        if (NpIaItemAddOn."Comment POS Info Code" = '') then
            exit;

        if (not POSInfo.Get(NpIaItemAddOn."Comment POS Info Code")) then
            exit;

        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        POSInfoTransaction.SetCurrentKey("Entry No.");
        POSInfoTransaction.SetRange("POS Info Code", POSInfo.Code);
        POSInfoTransaction.SetRange("Register No.", SaleLinePOS."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        if (POSInfoTransaction.FindLast()) then;
        EntryNo := POSInfoTransaction."Entry No.";

        Clear(POSInfoTransaction);
        POSInfoTransaction.SetRange("POS Info Code", POSInfo.Code);
        POSInfoTransaction.SetRange("Register No.", SaleLinePOS."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        POSInfoTransaction.SetRange("Sales Line No.", SaleLinePOS."Line No.");
        POSInfoTransaction.SetRange("Sale Date", SaleLinePOS.Date);
        if (POSInfoTransaction.FindFirst()) then
            POSInfoTransaction.DeleteAll;

        if Comment = '' then
            exit;

        while Comment <> '' do begin
            EntryNo += 1;

            POSInfoTransaction.Init;
            POSInfoTransaction."Register No." := SaleLinePOS."Register No.";
            POSInfoTransaction."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
            POSInfoTransaction."Sales Line No." := SaleLinePOS."Line No.";
            POSInfoTransaction."Sale Date" := SaleLinePOS.Date;
            POSInfoTransaction."Receipt Type" := SaleLinePOS.Type;
            POSInfoTransaction."Entry No." := EntryNo;
            POSInfoTransaction."POS Info Code" := POSInfo.Code;
            POSInfoTransaction."POS Info" := CopyStr(Comment, 1, MaxStrLen(POSInfoTransaction."POS Info"));
            POSInfoTransaction.Insert(true);

            Comment := DelStr(Comment, 1, StrLen(POSInfoTransaction."POS Info"));
        end;
    end;

    local procedure FindSaleLine(POSSale: Codeunit "NPR POS Sale"; AppliesToLineNo: Integer; NpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line"; var SaleLinePOS: Record "NPR Sale Line POS"): Boolean
    var
        SalePOS: Record "NPR Sale POS";
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
    begin

        POSSale.GetCurrentSale(SalePOS);

        SaleLinePOSAddOn.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOSAddOn.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOSAddOn.SetRange("AddOn No.", NpIaItemAddOnLine."AddOn No.");
        SaleLinePOSAddOn.SetRange("AddOn Line No.", NpIaItemAddOnLine."Line No.");
        SaleLinePOSAddOn.SetRange("Applies-to Line No.", AppliesToLineNo);
        if not SaleLinePOSAddOn.FindFirst then
            exit(false);

        exit(SaleLinePOS.Get(SaleLinePOSAddOn."Register No.",
                               SaleLinePOSAddOn."Sales Ticket No.",
                               SaleLinePOSAddOn."Sale Date",
                               SaleLinePOSAddOn."Sale Type",
                               SaleLinePOSAddOn."Sale Line No."));
    end;

    local procedure InsertAddOn(SaleLinePOS: Record "NPR Sale Line POS"; NpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line"; AppliesToLineNo: Integer)
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

        SaleLinePOSAddOn.Init;
        SaleLinePOSAddOn."Applies-to Line No." := AppliesToLineNo;
        SaleLinePOSAddOn."AddOn No." := NpIaItemAddOnLine."AddOn No.";
        SaleLinePOSAddOn."AddOn Line No." := NpIaItemAddOnLine."Line No.";
        SaleLinePOSAddOn."Fixed Quantity" := NpIaItemAddOnLine."Fixed Quantity";
        SaleLinePOSAddOn."Per Unit" := NpIaItemAddOnLine."Per Unit";
        SaleLinePOSAddOn.Insert(true);
    end;

    local procedure GetValueAsString(JToken: DotNet NPRNetJToken; JPath: Text): Text
    var
        JToken2: DotNet NPRNetJToken;
    begin
        JToken2 := JToken.SelectToken(JPath);
        if IsNull(JToken2) then
            exit('');

        exit(Format(JToken2));
    end;
}

