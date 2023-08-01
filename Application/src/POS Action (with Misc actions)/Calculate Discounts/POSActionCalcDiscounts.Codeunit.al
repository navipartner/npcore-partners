codeunit 6151310 "NPR POS Action: Calc Discounts" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This is a built-in action for calculating the discounts in the transaction';
        CalculateLineDiscountsDesc: Label 'Specifies if the line discount is going to be calculated';
        CalculateLineDiscountsName: Label 'Calculate Line Discount';
        CalculateTotalDiscountsDesc: Label 'Specifies if the total discount is going to be calculated';
        CalculateTotalDiscountsName: Label 'Calculate Total Discount';
        HandleBenefitItemsDesc: Label 'Specifies if the benefit items popup is going to appear.';
        HandleBenefitItemsName: Label 'Handle Benefit Items';
        ParamBenefitItem_CaptionLbl: Label 'Please select benefit items';
    begin
        WorkflowConfig.SetNonBlockingUI();
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddLabel('benefitItemCaption', ParamBenefitItem_CaptionLbl);
        WorkflowConfig.AddBooleanParameter('calculateLineDiscounst', true, CalculateLineDiscountsName, CalculateLineDiscountsDesc);
        WorkflowConfig.AddBooleanParameter('calculateTotalDiscounst', true, CalculateTotalDiscountsName, CalculateTotalDiscountsDesc);
        WorkflowConfig.AddBooleanParameter('handleBenefitItems', true, HandleBenefitItemsName, HandleBenefitItemsDesc);
    end;

    procedure RunWorkflow(Step: Text;
                          Context: codeunit "NPR POS JSON Helper";
                          FrontEnd: codeunit "NPR POS Front End Management";
                          Sale: codeunit "NPR POS Sale";
                          SaleLine: codeunit "NPR POS Sale Line";
                          PaymentLine: codeunit "NPR POS Payment Line";
                          Setup: codeunit "NPR POS Setup");
    begin
        case step of
            'calculateDiscounts':
                FrontEnd.WorkflowResponse(CalculateDiscounts(Sale,
                                                             SaleLine,
                                                             Context));
            'processBenefitItems':
                ProcessBenefitItems(Sale,
                                   Context,
                                   FrontEnd);
        end;
    end;

    local procedure ProcessBenefitItems(Sale: codeunit "NPR POS Sale";
                                        Context: Codeunit "NPR POS JSON Helper";
                                        FrontEnd: Codeunit "NPR POS Front End Management")
    var
        SalePOS: Record "NPR POS Sale";
        NPRCalculateDiscountsB: Codeunit "NPR POS Action Calc DiscountsB";
    begin
        Sale.GetCurrentSale(SalePOS);
        if NPRCalculateDiscountsB.CheckIfBenefitItemsAddedToPOSSale(SalePOS) then
            exit;

        ProcessBenefitItemsFromPopup(SalePOS,
                                     Context,
                                     FrontEnd);

        ProcessNoPopUpBenefitItems(SalePOS,
                                   FrontEnd);
    end;

    local procedure ProcessBenefitItemsFromPopup(SalePOS: Record "NPR POS Sale";
                                                 Context: Codeunit "NPR POS JSON Helper";
                                                 FrontEnd: Codeunit "NPR POS Front End Management")
    var
        TempNPRTotalDiscBenItemBuffer: Record "NPR Total Disc Ben Item Buffer" temporary;
        NPRCalculateDiscountsB: Codeunit "NPR POS Action Calc DiscountsB";
        PopUpSettingsJsonObject: JsonObject;
        PopUpSettingsJsonToken: JsonToken;
    begin

        if not Context.HasProperty('popupSetup') then
            exit;

        Clear(PopUpSettingsJsonToken);
        PopUpSettingsJsonToken := Context.GetJToken('popupSetup');
        PopUpSettingsJsonObject := PopUpSettingsJsonToken.AsObject();

        ParseTotalDiscountItemsResponseToBuff(PopUpSettingsJsonObject,
                                              TempNPRTotalDiscBenItemBuffer);

        NPRCalculateDiscountsB.AddBenefitItems(SalePOS,
                                               TempNPRTotalDiscBenItemBuffer,
                                               FrontEnd);
    end;

    local procedure ProcessNoPopUpBenefitItems(SalePOS: Record "NPR POS Sale";
                                               FrontEnd: Codeunit "NPR POS Front End Management")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        TempNPRTotalDiscBenItemBuffer: Record "NPR Total Disc Ben Item Buffer" temporary;
        NPRCalculateDiscountsB: Codeunit "NPR POS Action Calc DiscountsB";
    begin

        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetFilter("Total Discount Code", '<>%1', '');
        if not SaleLinePOS.FindFirst() then
            exit;

        if not NPRCalculateDiscountsB.GetTotalDiscountBenefitItems(SalePOS,
                                                                    Enum::"NPR Benefit Items Collection"::"No Input Needed",
                                                                    TempNPRTotalDiscBenItemBuffer)
        then
            exit;

        NPRCalculateDiscountsB.AddBenefitItems(SalePOS,
                                             TempNPRTotalDiscBenItemBuffer,
                                             FrontEnd);
    end;

    local procedure ParseTotalDiscountItemsResponseToBuff(PopUpJsonObject: JsonObject;
                                                          var TempNPRTotalDiscBenItemBuffer: Record "NPR Total Disc Ben Item Buffer" temporary)
    var
        BenefitItemListSettingsJsonArray: JsonArray;
        PopUpSettingsJsonArray: JsonArray;
        BenefitItemJsonObject: JsonObject;
        PopUpSettingJsonObject: JsonObject;
        BenefitItemJsonToken: JsonToken;
        BenefitItemListSettingsJsonToken: JsonToken;
        PopUpSettingJsonToken: JsonToken;
        PopUpSettingsJsonToken: JsonToken;
        ValueJsonToken: JsonToken;
    begin
        if not TempNPRTotalDiscBenItemBuffer.IsTemporary then
            exit;

        TempNPRTotalDiscBenItemBuffer.Reset();
        if not TempNPRTotalDiscBenItemBuffer.IsEmpty then
            TempNPRTotalDiscBenItemBuffer.DeleteAll();

        Clear(PopUpSettingsJsonToken);
        if not PopUpJsonObject.Get('settings', PopUpSettingsJsonToken) then
            exit;

        PopUpSettingsJsonArray := PopUpSettingsJsonToken.AsArray();
        foreach PopUpSettingJsonToken in PopUpSettingsJsonArray do begin

            PopUpSettingJsonObject := PopUpSettingJsonToken.AsObject();
            if PopUpSettingJsonObject.Get('settings', BenefitItemListSettingsJsonToken) then begin
                BenefitItemListSettingsJsonArray := BenefitItemListSettingsJsonToken.AsArray();
                foreach BenefitItemJsonToken in BenefitItemListSettingsJsonArray do begin

                    Clear(BenefitItemJsonObject);
                    BenefitItemJsonObject := BenefitItemJsonToken.AsObject();

                    TempNPRTotalDiscBenItemBuffer.Init();

                    if BenefitItemJsonObject.Get('id', ValueJsonToken) then
                        TempNPRTotalDiscBenItemBuffer."Entry No." := ValueJsonToken.AsValue().AsInteger();
#pragma warning disable AA0139
                    if BenefitItemJsonObject.Get('itemNo', ValueJsonToken) then
                        TempNPRTotalDiscBenItemBuffer."Item No." := ValueJsonToken.AsValue().AsCode();

                    if BenefitItemJsonObject.Get('variantCode', ValueJsonToken) then
                        TempNPRTotalDiscBenItemBuffer."Variant Code" := ValueJsonToken.AsValue().AsCode();


                    if BenefitItemJsonObject.Get('unitOfMeasureCode', ValueJsonToken) then
                        TempNPRTotalDiscBenItemBuffer."Unit of Measure Code" := ValueJsonToken.AsValue().AsCode();

                    if BenefitItemJsonObject.Get('totalDiscountCode', ValueJsonToken) then
                        TempNPRTotalDiscBenItemBuffer."Total Discount Code" := ValueJsonToken.AsValue().AsCode();

                    if BenefitItemJsonObject.Get('benefitListCode', ValueJsonToken) then
                        TempNPRTotalDiscBenItemBuffer."Benefit List Code" := ValueJsonToken.AsValue().AsCode();
#pragma warning restore AA0139

                    if BenefitItemJsonObject.Get('unitPrice', ValueJsonToken) then
                        TempNPRTotalDiscBenItemBuffer."Unit Price" := ValueJsonToken.AsValue().AsDecimal();

                    if BenefitItemJsonObject.Get('value', ValueJsonToken) then
                        TempNPRTotalDiscBenItemBuffer.Quantity := ValueJsonToken.AsValue().AsDecimal();

                    if BenefitItemJsonObject.Get('totalDiscountStep', ValueJsonToken) then
                        TempNPRTotalDiscBenItemBuffer."Total Discount Step" := ValueJsonToken.AsValue().AsDecimal();

                    TempNPRTotalDiscBenItemBuffer.Insert();
                end;
            end;
        end;
    end;

    local procedure CalculateDiscounts(Sale: Codeunit "NPR POS Sale";
                                       SaleLine: codeunit "NPR POS Sale Line";
                                       Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        xSaleLinePOS: Record "NPR POS Sale Line";
        NPRPOSSalesDiscCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        CalculateLineDiscount: Boolean;
        CalculateTotalDiscount: Boolean;
        HandleBenefitItems: Boolean;
        PopUpSetupJsonObject: JsonObject;
    begin
        if Context.GetBooleanParameter('calculateLineDiscounst', CalculateLineDiscount) then;
        if Context.GetBooleanParameter('calculateTotalDiscounst', CalculateTotalDiscount) then;
        if Context.GetBooleanParameter('handleBenefitItems', HandleBenefitItems) then;

        Sale.GetCurrentSale(SalePOS);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        if CalculateLineDiscount then begin
            xSaleLinePOS := SaleLinePOS;
            NPRPOSSalesDiscCalcMgt.OnAfterModifySaleLinePOS(SaleLinePOS,
                                                            xSaleLinePOS);
        end;

        if CalculateTotalDiscount then
            NPRPOSSalesDiscCalcMgt.OnAfterTotalPressedPOS(SaleLinePOS);


        if HandleBenefitItems then begin
            Clear(PopUpSetupJsonObject);
            GetTotalDiscountBenefitItemsAsSetup(SalePOS,
                                                PopUpSetupJsonObject);
            Response.Add('popupSetup', PopUpSetupJsonObject);
        end;


    end;


    local procedure GetTotalDiscountBenefitItemsAsSetup(SalePOS: Record "NPR POS Sale";
                                                        var PopUpJosnObject: JsonObject);
    var
        TempNPRItemBenefitListHeader: Record "NPR Item Benefit List Header" temporary;
        TempNPRTotalDiscBenItemBuffer: Record "NPR Total Disc Ben Item Buffer" temporary;
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRCalculateDiscountsB: Codeunit "NPR POS Action Calc DiscountsB";
        EntryNo: Integer;
        OptionJsonArray: JsonArray;
        OptionSettingsJsonArray: JsonArray;
        OptionJsonObject: JsonObject;
        OptionSettingsJsonObject: JsonObject;
        DescriptionLbl: Label 'Item: %1   Unit Price: %2   Maximum Quantity: %3', Comment = '%1 - Description, %2 - Unit Price, %3- Maximum Quantity';
        SelectItemTitleLbl: Label 'Please select an item.';
    begin
        if NPRCalculateDiscountsB.CheckIfBenefitItemsAddedToPOSSale(SalePOS) then
            exit;

        NPRCalculateDiscountsB.GetTotalDiscountBenefitItems(SalePOS,
                                                            Enum::"NPR Benefit Items Collection"::"Input Needed",
                                                            TempNPRTotalDiscBenItemBuffer);

        NPRCalculateDiscountsB.CreateBenefitListBufferFromDiscountBenefitItemBuffer(TempNPRTotalDiscBenItemBuffer,
                                                                                    TempNPRItemBenefitListHeader);
        EntryNo := 0;
        TempNPRItemBenefitListHeader.Reset();
        if not TempNPRItemBenefitListHeader.FindSet(false) then
            exit;

        repeat
            Clear(OptionSettingsJsonArray);

            TempNPRTotalDiscBenItemBuffer.Reset();
            TempNPRTotalDiscBenItemBuffer.SetRange("Benefit List Code", TempNPRItemBenefitListHeader.Code);
            if TempNPRTotalDiscBenItemBuffer.FindSet(false) then
                repeat

                    if not NPRTotalDiscountHeader.Get(TempNPRTotalDiscBenItemBuffer."Total Discount Code") then
                        Clear(NPRTotalDiscountHeader);

                    EntryNo += 1;

                    Clear(OptionSettingsJsonObject);
                    OptionSettingsJsonObject.Add('type', 'plusminus');
                    OptionSettingsJsonObject.Add('id', EntryNo);
                    OptionSettingsJsonObject.Add('minValue', 0);
                    OptionSettingsJsonObject.Add('maxValue', TempNPRTotalDiscBenItemBuffer.Quantity);
                    OptionSettingsJsonObject.Add('value', 0);
                    OptionSettingsJsonObject.Add('caption', StrSubstNo(DescriptionLbl,
                                                                 TempNPRTotalDiscBenItemBuffer.Description,
                                                                 Format(TempNPRTotalDiscBenItemBuffer."Unit Price", 0, '<Precision,2:2><Standard Format,0>'),
                                                                 TempNPRTotalDiscBenItemBuffer.Quantity));

                    OptionSettingsJsonObject.Add('itemNo', TempNPRTotalDiscBenItemBuffer."Item No.");
                    OptionSettingsJsonObject.Add('variantCode', TempNPRTotalDiscBenItemBuffer."Variant Code");
                    OptionSettingsJsonObject.Add('unitPrice', TempNPRTotalDiscBenItemBuffer."Unit Price");
                    OptionSettingsJsonObject.Add('totalDiscountCode', TempNPRTotalDiscBenItemBuffer."Total Discount Code");
                    OptionSettingsJsonObject.Add('totalDiscountStep', TempNPRTotalDiscBenItemBuffer."Total Discount Step");
                    OptionSettingsJsonObject.Add('unitOfMeasureCode', TempNPRTotalDiscBenItemBuffer."Unit of Measure Code");
                    OptionSettingsJsonObject.Add('benefitListCode', TempNPRTotalDiscBenItemBuffer."Benefit List Code");
                    OptionSettingsJsonArray.Add(OptionSettingsJsonObject);

                until TempNPRTotalDiscBenItemBuffer.Next() = 0;

            Clear(OptionJsonObject);
            OptionJsonObject.Add('caption', TempNPRItemBenefitListHeader.Description);
            OptionJsonObject.Add('type', 'group');
            OptionJsonObject.Add('expanded', 'true');
            OptionJsonObject.Add('settings', OptionSettingsJsonArray);

            OptionJsonArray.Add(OptionJsonObject);
        until TempNPRItemBenefitListHeader.Next() = 0;

        PopUpJosnObject.Add('caption', SelectItemTitleLbl);
        PopUpJosnObject.Add('title', NPRTotalDiscountHeader.Description);
        PopUpJosnObject.Add('settings', OptionJsonArray);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Payment Processing Events", 'OnAddPreWorkflowsToRun', '', true, true)]
    local procedure PaymentProcessingOnAddPreWorkflowsToRun(Context: Codeunit "NPR POS JSON Helper";
                                                            SalePOS: Record "NPR POS Sale";
                                                            var PreWorkflows: JsonObject)
    var
        ActionParameters: JsonObject;
    begin
        ActionParameters.Add('calculateLineDiscounst', false);
        ActionParameters.Add('calculateTotalDiscounst', true);
        ActionParameters.Add('handleBenefitItems', true);
        PreWorkflows.Add(GetCalculateDiscountsHandler(), ActionParameters);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Action Doc Exp Events", 'OnAddPreWorkflowsToRun', '', true, true)]
    local procedure NPRPOSActionDocExpEventsOnAddPreWorkflowsToRun(Context: Codeunit "NPR POS JSON Helper";
                                                                   SalePOS: Record "NPR POS Sale";
                                                                   var PreWorkflows: JsonObject)
    var
        ActionParameters: JsonObject;
    begin
        ActionParameters.Add('calculateLineDiscounst', false);
        ActionParameters.Add('calculateTotalDiscounst', true);
        ActionParameters.Add('handleBenefitItems', true);
        PreWorkflows.Add(GetCalculateDiscountsHandler(), ActionParameters);
    end;


    internal procedure GetCalculateDiscountsHandler(): Code[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::CALCULATE_DISCOUNTS));
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionCalcDiscounts.js###
'let main=async({popup:i,context:s,parameters:e,workflow:t})=>{debugger;const{popupSetup:n}=await t.respond("calculateDiscounts");e.handleBenefitItems&&(s.popupSetup=await getBenefitItemsResponse(i,n),await t.respond("processBenefitItems"))};async function getBenefitItemsResponse(i,s){if(!!s.settings){var e=await i.configuration(s);if(e!==null){for(var t=0;t<s.settings.length;t++)if(s.settings[t].settings)for(var n=0;n<s.settings[t].settings.length;n++){var a=e[s.settings[t].settings[n].id];a!=null&&(s.settings[t].settings[n].value=a)}return s}}}'
        );
    end;
}
