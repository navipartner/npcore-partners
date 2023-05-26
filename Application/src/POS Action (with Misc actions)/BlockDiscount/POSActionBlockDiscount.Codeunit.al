codeunit 6150838 "NPR POS Action: Block Discount" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Enable or disable the Custom Disc Block field.';
        TitleLbl: Label 'Block / Unblock Discount';
        PasswordPromptLbl: Label 'Enter Administrator Password';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddLabel('TitleLbl', TitleLbl);
        WorkflowConfig.AddLabel('PasswordPromptLbl', PasswordPromptLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'ShowPassPrompt':
                FrontEnd.WorkflowResponse(ShowPassPropmt(Setup));
            'VerifyPassword':
                FrontEnd.WorkflowResponse(VerifyPassword(Context, Setup));
            'ToggleBlockState':
                FrontEnd.WorkflowResponse(ToggleBlockState(SaleLine));
        end;

    end;

    local procedure ToggleBlockState(POSSaleLine: Codeunit "NPR POS Sale Line"): JsonObject
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin

        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLinePOS."Custom Disc Blocked" := not SaleLinePOS."Custom Disc Blocked";
        SaleLinePOS."Discount Type" := SaleLinePOS."Discount Type"::Manual;
        if (not SaleLinePOS."Custom Disc Blocked") then
            SaleLinePOS."Discount Type" := SaleLinePOS."Discount Type"::" ";

        SaleLinePOS.Modify();
    end;

    local procedure VerifyPassword(Context: Codeunit "NPR POS JSON Helper"; POSSetup: Codeunit "NPR POS Setup"): JsonObject
    var
        POSUnit: Record "NPR POS Unit";
        SecurityProfile: Codeunit "NPR POS Security Profile";
        Password: Text;
    begin

        Password := Context.GetString('password');

        POSSetup.GetPOSUnit(POSUnit);
        if not SecurityProfile.IsUnblockDiscountPasswordValidIfProfileExist(POSUnit."POS Security Profile", Password) then
            Error('');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Ext.: Line Format.", 'OnGetLineStyle', '', false, false)]
    local procedure OnGetStyle(var Color: Text; var Weight: Text; var Style: Text; SaleLinePOS: Record "NPR POS Sale Line"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
        if (SaleLinePOS."Custom Disc Blocked") then begin
            Color := 'blue';
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Ext.: Line Format.", 'OnGetLineFormat', '', false, false)]
    local procedure OnGetLineFormat(var Highlighted: Boolean; var Indented: Boolean; SaleLinePOS: Record "NPR POS Sale Line")
    begin
        if (SaleLinePOS."Custom Disc Blocked") then begin
            Highlighted := true;
        end;
    end;

    local procedure ShowPassPropmt(Setup: Codeunit "NPR POS Setup") Response: JsonObject;
    var
        POSUnit: Record "NPR POS Unit";
        SecurityProfile: Codeunit "NPR POS Security Profile";
    begin
        Setup.GetPOSUnit(POSUnit);

        Response.ReadFrom('{}');
        Response.Add('ShowPasswordPrompt', SecurityProfile.IsUnblockDiscountPasswordSetIfProfileExist(POSUnit."POS Security Profile"));
        exit(Response);
    end;

    local procedure GetActionScript(): Text
    begin

        exit(
        //###NPR_INJECT_FROM_FILE:POSActionBlockDiscount.js###
'let main=async({workflow:a,captions:t})=>{const{ShowPasswordPrompt:o}=await a.respond("ShowPassPrompt");if(o){var s=await popup.input({title:t.title,caption:t.PasswordPromptLbl});if(s===null)return" ";await a.respond("VerifyPassword",{password:s})}await a.respond("ToggleBlockState")};'

        );
    end;
}
