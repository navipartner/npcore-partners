codeunit 6059884 "NPR POS Action: EFTGiftCard 2" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        DiscPromptLbl: Label 'Discount Percent Prompt';
        DiscPercentDescLbl: Label 'Prompt for discount percentage to use for gift card';
        DescPaymentTypeLbl: Label 'The payment type to use for EFT & G/L Account setup';
        CaptionPaymentTypeLbl: Label 'Payment Type';
        QuantityPromptLbl: Label 'Quantity Prompt';
        QuantityPromptDescLbl: Label 'Prompt for number of gift cards to load';
        ActionDescription: Label 'Sale of EFT Gift Cards';
        AmountLbl: Label 'Gift Card Amount';
        QuantityLbl: Label 'Number of Gift Cards';
        DiscountLbl: Label 'Gift Card Discount Percentage';
        InvalidQuantityLbl: Label 'Number of giftcards must be between 1 and 100';
        InvalidDiscountLbl: Label 'Discount percent must be between 0 and 100';
        InvalidAmountLbl: Label 'Amount must be positive';
    begin
        WorkflowConfig.AddJavascript(GetActionJavascript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddBooleanParameter('PromptDiscountPct', false, DiscPromptLbl, DiscPercentDescLbl);
        WorkflowConfig.AddTextParameter('PaymentType', '', CaptionPaymentTypeLbl, DescPaymentTypeLbl);
        WorkflowConfig.AddBooleanParameter('PromptQuantity', false, QuantityPromptLbl, QuantityPromptDescLbl);
        WorkflowConfig.AddLabel('VoucherAmount', AmountLbl);
        WorkflowConfig.AddLabel('VoucherDiscount', DiscountLbl);
        WorkflowConfig.AddLabel('VoucherQuantity', QuantityLbl);
        WorkflowConfig.AddLabel('InvalidQuantity', InvalidQuantityLbl);
        WorkflowConfig.AddLabel('InvalidDiscount', InvalidDiscountLbl);
        WorkflowConfig.AddLabel('InvalidAmount', InvalidAmountLbl);
    end;

#pragma warning disable AA0139
    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        EFTGiftCardBusinessLogic: Codeunit "NPR POS Action: EFTGiftCard B.";
    begin
        case Step of
            'PrepareGiftCardLoad':
                FrontEnd.WorkflowResponse(EFTGiftCardBusinessLogic.PrepareGiftCardLoad(Sale, Context.GetDecimal('amount'), Context.GetStringParameter('PaymentType')));
            'InsertDiscountLine':
                EFTGiftCardBusinessLogic.InsertVoucherDiscountLine(Context.GetInteger('eftEntryNo'), Context.GetDecimal('discountPct'), Context.GetDecimal('amount'));
        end;
    end;
#pragma warning restore AA0139

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupParameter(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin
        if POSParameterValue."Action Code" <> Format(Enum::"NPR POS Workflow"::EFT_GIFT_CARD_2) then
            exit;

        case POSParameterValue.Name of
            'PaymentType':
                begin
                    POSPaymentMethod.SetRange("Processing Type", POSPaymentMethod."Processing Type"::Voucher);
                    if PAGE.RunModal(0, POSPaymentMethod) = ACTION::LookupOK then
                        POSParameterValue.Validate(Value, POSPaymentMethod.Code);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', false, false)]
    local procedure OnValidateParameter(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin
        if POSParameterValue."Action Code" <> Format(Enum::"NPR POS Workflow"::EFT_GIFT_CARD_2) then
            exit;

        case POSParameterValue.Name of
            'PaymentType':
                begin
                    if POSParameterValue.Value <> '' then begin
                        POSPaymentMethod.Get(POSParameterValue.Value);
                        POSPaymentMethod.TestField("Processing Type", POSPaymentMethod."Processing Type"::Voucher);
                    end;
                end;
        end;
    end;

    local procedure GetActionJavascript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionEFTGiftCard2.Codeunit.js###
'let main=async({workflow:r,context:u,captions:a,parameters:t})=>{if(u.quantity=1,t.PromptQuantity&&(u.quantity=await popup.numpad(a.VoucherQuantity)),!u.quantity||u.quantity>100||u.quantity<1){await popup.error(a.InvalidQuantity);return}if(u.amount=await popup.numpad(a.VoucherAmount),!u.amount||u.amount<0){await popup.error(a.InvalidAmount);return}if(u.discountPct=0,t.PromptDiscountPct&&(u.discountPct=await popup.numpad(a.VoucherDiscount)),u.discountPct<0||u.discountPct>100){await popup.error(a.InvalidDiscount);return}for(i=1;i<u.quantity+1;i++){debugger;u.voucherNumber=i;let{workflowName:p,integrationRequest:n,synchronousRequest:o}=await r.respond("PrepareGiftCardLoad");if(!o){let{success:d}=await r.run(p,{context:{request:n,amount:u.amount}});if(!d)return}u.discountPct!==0&&(u.eftEntryNo=n.EntryNo,await r.respond("InsertDiscountLine"))}};'
        );

    end;
}
