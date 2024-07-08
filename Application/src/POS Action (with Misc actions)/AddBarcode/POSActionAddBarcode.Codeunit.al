codeunit 6014576 "NPR POS Action Add Barcode" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        Title: Label 'Add Barcode to Item';
        BarcodePrompt: Label 'Barcode Number';
        BarCode: Code[50];

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This is a function for adding barcode to item.';
        TooLongErr: Label 'Bar Code cannot have more than 50 characters.';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddLabel('title', Title);
        WorkflowConfig.AddLabel('barcodeprompt', BarcodePrompt);
        WorkflowConfig.AddLabel('lengtherror', TooLongErr);
    end;


    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'InsertBarCode':
                FrontEnd.WorkflowResponse(InsertBarCode(Context));
        end;
    end;

    local procedure InsertBarcode(Context: Codeunit "NPR POS JSON Helper"): JsonObject
    var
        ConfirmQst: Label 'Bar Code %1 already exists for item %2. Do you want to continue?';
        MultipleItemQst: Label 'Bar Code %1 already exists for multiple items. Do you want to continue?';
        POSActionBusinessLogic: Codeunit "NPR POS Action: Add Barcode B";
        ItemReference: Record "Item Reference";
        InputItem: Page "NPR Input Item";
        ItemNo: Code[20];
        ItemUOM: Code[10];
        VariantCode: Code[10];
    begin
        BarCode := CopyStr(UpperCase(Context.GetString('BarCode')), 1, MaxStrLen(BarCode));

        ItemReference.SetRange("Reference No.", BarCode);
        if ItemReference.FindFirst() then
            if ItemReference.Count > 1 then begin
                if not Confirm(MultipleItemQst, false, BarCode, ItemReference."Item No.") then
                    exit;
            end else
                if not Confirm(ConfirmQst, false, BarCode, ItemReference."Item No.") then
                    exit;

        InputItem.LookupMode(true);
        if InputItem.RunModal() <> Action::LookupOk then
            Error('');
        InputItem.GetValues(ItemNo, VariantCode, ItemUOM);

        POSActionBusinessLogic.InputBarcode(BarCode, ItemNo, VariantCode, ItemUOM);
    end;


    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionAddBarcode.js###
'let main=async({workflow:a,popup:t,captions:r})=>{let e=await t.input({title:r.title,caption:r.barcodeprompt});if(e===null)return" ";if(e.length>50)return await t.error(r.lengtherror)," ";await a.respond("InsertBarCode",{BarCode:e})};'
        );
    end;


}
