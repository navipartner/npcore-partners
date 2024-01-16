codeunit 6150852 "NPR POS Action - Item Price" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ParamItemIdentifierType_CaptionLbl: Label 'Item Identifier Type';
        ParamItemIdentifierType_DescLbl: Label 'Specifies the Item Identifier Type';
        ParamItemIdentifierOptionsLbl: Label 'ItemNo,ItemCrossReference,ItemSearch', Locked = true;
        ParamItemIdentifierOptions_CaptionLbl: Label 'Item No,Item Cross Reference,Item Search';
        ParamExclVat_CaptionLbl: Label 'Price Excluding VAT';
        ParamExclVat_DescLbl: Label 'Enable/Disable Price Excluding VAT';
        Title: Label 'We need more information.';
        Caption: Label 'Item Number';
        ActionDescription: Label 'This action prompts for a numeric item number, and shows the price';
        PriceQuery: Label 'Price Query';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddOptionParameter(
               'itemIdentifierType',
               ParamItemIdentifierOptionsLbl,
#pragma warning disable AA0139
               SelectStr(1, ParamItemIdentifierOptionsLbl),
#pragma warning restore 
               ParamItemIdentifierType_CaptionLbl,
               ParamItemIdentifierType_DescLbl,
               ParamItemIdentifierOptions_CaptionLbl);
        WorkflowConfig.AddBooleanParameter('priceExclVat', false, ParamExclVat_CaptionLbl, ParamExclVat_DescLbl);
        WorkflowConfig.AddLabel('title', Title);
        WorkflowConfig.AddLabel('caption', Caption);
        WorkflowConfig.AddLabel('confirm_title', PriceQuery);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'createitem':
                FrontEnd.WorkflowResponse(CreateItem(Context));
            'gatherinfo':
                FrontEnd.WorkflowResponse(GatherInfo(Context));
        end;
    end;

    local procedure CreateItem(var Context: Codeunit "NPR POS JSON Helper") Response: JsonObject;
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSActionItemPriceB: Codeunit "NPR POS Action - Item Price B";
        POSSession: Codeunit "NPR POS Session";
    begin
        POSActionItemPriceB.GetSalesLineNo(POSSession, SaleLinePOS);

        Context.SetContext('LastSaleLineNoBeforeAddItem', SaleLinePOS."Line No.");

        Response.Add('workflowName', 'ITEM');
    end;

    local procedure GatherInfo(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject;
    var
        POSSession: Codeunit "NPR POS Session";
        POSActionItemPriceB: Codeunit "NPR POS Action - Item Price B";
        SaleLinePOS: Record "NPR POS Sale Line";
        LineNumber: Integer;
        PriceExclVat: Boolean;
        HtmlTagLbl: Label '%1<br><h4>%2</h4>', Locked = true;
        PriceInfoHtml: Label '<center><table border="0"><tr><td align="left">%1</td><td align="right"><h2>%2</h2></td></tr><tr><td align="left">%3</td><td align="right"><h2>%4</h2></td></tr><tr><td align="left">%5</td><td align="right"><h2>%6</h2></td></tr></table>';
    begin
        LineNumber := Context.GetInteger('LastSaleLineNoBeforeAddItem');

        if not POSActionItemPriceB.GetSalesLine(POSSession, SaleLinePOS, LineNumber) then
            exit;

        PriceExclVat := Context.GetBooleanParameter('priceExclVat');

        if PriceExclVat then
            Response.Add('confirm_message', StrSubstNo(PriceInfoHtml,
              SaleLinePOS.FieldCaption("No."), SaleLinePOS."No.",
              SaleLinePOS.FieldCaption(Description), StrSubstNo(HtmlTagLbl, SaleLinePOS.Description, SaleLinePOS."Description 2"),
              SaleLinePOS.FieldCaption(Amount), SaleLinePOS.Amount))
        else
            Response.Add('confirm_message', StrSubstNo(PriceInfoHtml,
              SaleLinePOS.FieldCaption("No."), SaleLinePOS."No.",
              SaleLinePOS.FieldCaption(Description), StrSubstNo(HtmlTagLbl, SaleLinePOS.Description, SaleLinePOS."Description 2"),
              SaleLinePOS.FieldCaption("Amount Including VAT"), SaleLinePOS."Amount Including VAT"));

        OnGatherInfoOnBeforeDeleteLines(SaleLinePOS, PriceExclVat);

        // Delete the lines from the end until we find the last line before inserting
        POSActionItemPriceB.DeleteLines(POSSession, LineNumber);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGatherInfoOnBeforeDeleteLines(SaleLinePOS: Record "NPR POS Sale Line"; PriceExclVAT: Boolean)
    begin
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionItemPrice.js###
'let main=async({workflow:t,captions:e,parameters:a})=>{let i=await popup.input({title:e.title,caption:e.caption});if(i===null)return" ";const{workflowName:n}=await t.respond("createitem");await t.run(n,{parameters:{itemNo:i,itemQuantity:1,itemIdentifierType:a.itemIdentifierType}});const{confirm_message:m}=await t.respond("gatherinfo");popup.message({title:e.confirm_title,caption:m})};'
        )
    end;
}
