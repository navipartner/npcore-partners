codeunit 6151071 "NPR NPRE RVA: SelectRestaurant" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        _ParamRestaurantCodeLbl: Label 'RestaurantCode', MaxLength = 30, Locked = true;

    local procedure ActionCode(): Code[20]
    begin
        exit(Format("NPR POS Workflow"::RV_SELECT_RESTAURANT));
    end;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This built-in action can be run when a restaurant is selected in Restaurant View.';
        ParamRestaurantCode_CptLbl: Label 'Restaurant Code';
        ParamRestaurantCode_DescLbl: Label 'Selected restaurant code.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddTextParameter(_ParamRestaurantCodeLbl, '', ParamRestaurantCode_CptLbl, ParamRestaurantCode_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        POSSession: Codeunit "NPR POS Session";
        NPREFrontendAssistant: Codeunit "NPR NPRE Frontend Assistant";
        RestaurantCode: Code[20];
    begin
        RestaurantCode := CopyStr(Context.GetStringParameter(_ParamRestaurantCodeLbl), 1, MaxStrLen(RestaurantCode));
        NPREFrontendAssistant.SetRestaurant(POSSession, FrontEnd, RestaurantCode);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        SelectedRestaurantCode: Code[20];
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            _ParamRestaurantCodeLbl:
                begin
                    SelectedRestaurantCode := CopyStr(POSParameterValue.Value, 1, MaxStrLen(SelectedRestaurantCode));
                    if LookupRestaurantCode(SelectedRestaurantCode) then
                        POSParameterValue.Value := SelectedRestaurantCode;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', false, false)]
    local procedure OnValidateValue(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        Restaurant: Record "NPR NPRE Restaurant";
        CodeFilterTok: Label '@%1*', Locked = true;
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            _ParamRestaurantCodeLbl:
                begin
                    if POSParameterValue.Value = '' then
                        exit;
                    Restaurant.Code := CopyStr(POSParameterValue.Value, 1, MaxStrLen(Restaurant.Code));
                    if not Restaurant.Find() then begin
                        Restaurant.SetFilter(Code, CopyStr(StrSubstNo(CodeFilterTok, POSParameterValue.Value), 1, MaxStrLen(Restaurant.Code)));
                        Restaurant.FindFirst();
                    end;
                    POSParameterValue.Value := Restaurant.Code;
                end;
        end;
    end;

    local procedure LookupRestaurantCode(var SelectedRestaurantCode: Code[20]): Boolean
    var
        Restaurant: Record "NPR NPRE Restaurant";
    begin
        if SelectedRestaurantCode <> '' then begin
            Restaurant.Code := SelectedRestaurantCode;
            if Restaurant.Find('=><') then;
        end;
        if Page.RunModal(0, Restaurant) = Action::LookupOK then begin
            SelectedRestaurantCode := Restaurant.Code;
            exit(true);
        end;
        exit(false);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:NPRERVASelectRestaurant.js###
'let main=async({workflow:a})=>{await a.respond()};'
        );
    end;
}
