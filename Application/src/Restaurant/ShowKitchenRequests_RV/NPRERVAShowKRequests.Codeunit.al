codeunit 6151070 "NPR NPRE RVA: Show K.Requests" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        _ParamFilterByLbl: Label 'FilterBy', MaxLength = 30, Locked = true;
        _ParamRestaurantCodeLbl: Label 'RestaurantCode', MaxLength = 30, Locked = true;
        _ParamSeatingCodeLbl: Label 'SeatingCode', MaxLength = 30, Locked = true;
        _ParamWaiterPadCodeLbl: Label 'WaiterPadCode', MaxLength = 30, Locked = true;

    internal procedure ActionCode(): Code[20]
    begin
        exit(Format("NPR POS Workflow"::"RV_K/REQUESTS"));
    end;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This built-in action shows outstanding KDS kitchen requests (expedite view) from both Restaurant and Sales View';
        ParamFilterBy_OptionLbl: Label 'Restaurant,Salesperson,Seating,Waiterpad', Locked = true;
        ParamFilterBy_CptLbl: Label 'Filter by';
        ParamFilterBy_DescLbl: Label 'Specifies the object you want the requests to be shown for.';
        ParamFilterBy_OptionCptLbl: Label 'Restaurant,Salesperson,Seating,Waiterpad';
        ParamRestaurantCode_CptLbl: Label 'Restaurant Code';
        ParamRestaurantCode_DescLbl: Label 'Selected restaurant code.';
        ParamSeatingCode_CptLbl: Label 'Seating Code';
        ParamSeatingCode_DescLbl: Label 'Selected seating code.';
        ParamWaiterPadCode_CptLbl: Label 'Waiter Pad Code';
        ParamWaiterPadCode_DescLbl: Label 'Selected waiter pad code.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddOptionParameter(_ParamFilterByLbl,
                                        ParamFilterBy_OptionLbl,
                                        CopyStr(SelectStr(2, ParamFilterBy_OptionLbl), 1, 250),  //Filter by salesperson (waiter) by default
                                        ParamFilterBy_CptLbl,
                                        ParamFilterBy_DescLbl,
                                        ParamFilterBy_OptionCptLbl);
        WorkflowConfig.AddTextParameter(_ParamRestaurantCodeLbl, '', ParamRestaurantCode_CptLbl, ParamRestaurantCode_DescLbl);
        WorkflowConfig.AddTextParameter(_ParamSeatingCodeLbl, '', ParamSeatingCode_CptLbl, ParamSeatingCode_DescLbl);
        WorkflowConfig.AddTextParameter(_ParamWaiterPadCodeLbl, '', ParamWaiterPadCode_CptLbl, ParamWaiterPadCode_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        BusinessLogic: Codeunit "NPR NPRE RVA: Show K.Request-B";
        FilterBy: Option Restaurant,Salesperson,Seating,Waiterpad;
        FilterByEntityCode: Code[20];
        RestaurantCode: Code[20];
        StringParameterValue: Text;
    begin
        if Context.GetStringParameter(_ParamRestaurantCodeLbl, StringParameterValue) and (StringParameterValue <> '') then
            RestaurantCode := CopyStr(StringParameterValue, 1, MaxStrLen(RestaurantCode));

        FilterBy := Context.GetIntegerParameter(_ParamFilterByLbl);
        case FilterBy of
            FilterBy::Seating:
                if Context.GetStringParameter(_ParamSeatingCodeLbl, StringParameterValue) and (StringParameterValue <> '') then
                    FilterByEntityCode := CopyStr(StringParameterValue, 1, MaxStrLen(FilterByEntityCode));
            FilterBy::Waiterpad:
                if Context.GetStringParameter(_ParamWaiterPadCodeLbl, StringParameterValue) and (StringParameterValue <> '') then
                    FilterByEntityCode := CopyStr(StringParameterValue, 1, MaxStrLen(FilterByEntityCode));
        end;

        BusinessLogic.ShowKitchenRequests(Sale, Setup, RestaurantCode, FilterBy, FilterByEntityCode);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        SelectedObjectCode: Code[20];
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            _ParamRestaurantCodeLbl:
                begin
                    SelectedObjectCode := CopyStr(POSParameterValue.Value, 1, MaxStrLen(SelectedObjectCode));
                    if LookupRestaurantCode(SelectedObjectCode) then
                        POSParameterValue.Value := SelectedObjectCode;
                end;
            _ParamSeatingCodeLbl:
                begin
                    SelectedObjectCode := CopyStr(POSParameterValue.Value, 1, MaxStrLen(SelectedObjectCode));
                    if LookupSeatingCode(SelectedObjectCode) then
                        POSParameterValue.Value := SelectedObjectCode;
                end;
            _ParamWaiterPadCodeLbl:
                begin
                    SelectedObjectCode := CopyStr(POSParameterValue.Value, 1, MaxStrLen(SelectedObjectCode));
                    if LookupWaiterPadNo(SelectedObjectCode) then
                        POSParameterValue.Value := SelectedObjectCode;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', false, false)]
    local procedure OnValidateValue(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        Restaurant: Record "NPR NPRE Restaurant";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
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
            _ParamSeatingCodeLbl:
                begin
                    if POSParameterValue.Value = '' then
                        exit;
                    Seating.Code := CopyStr(POSParameterValue.Value, 1, MaxStrLen(Seating.Code));
                    if not Seating.Find() then begin
                        Seating.SetFilter(Code, CopyStr(StrSubstNo(CodeFilterTok, POSParameterValue.Value), 1, MaxStrLen(Seating.Code)));
                        Seating.FindFirst();
                    end;
                    POSParameterValue.Value := Seating.Code;
                end;
            _ParamWaiterPadCodeLbl:
                begin
                    if POSParameterValue.Value = '' then
                        exit;
                    WaiterPad."No." := CopyStr(POSParameterValue.Value, 1, MaxStrLen(WaiterPad."No."));
                    if not WaiterPad.Find() then begin
                        WaiterPad.SetFilter("No.", CopyStr(StrSubstNo(CodeFilterTok, POSParameterValue.Value), 1, MaxStrLen(WaiterPad."No.")));
                        WaiterPad.FindFirst();
                    end;
                    POSParameterValue.Value := WaiterPad."No.";
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

    local procedure LookupSeatingCode(var SelectedSeatingCode: Code[20]): Boolean
    var
        Seating: Record "NPR NPRE Seating";
    begin
        if SelectedSeatingCode <> '' then begin
            Seating.Code := SelectedSeatingCode;
            if Seating.Find('=><') then;
        end;
        if Page.RunModal(0, Seating) = Action::LookupOK then begin
            SelectedSeatingCode := Seating.Code;
            exit(true);
        end;
        exit(false);
    end;

    local procedure LookupWaiterPadNo(var SelectedWaiterPadNo: Code[20]): Boolean
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        if SelectedWaiterPadNo <> '' then begin
            WaiterPad."No." := SelectedWaiterPadNo;
            if WaiterPad.Find('=><') then;
        end;
        if Page.RunModal(0, WaiterPad) = Action::LookupOK then begin
            SelectedWaiterPadNo := WaiterPad."No.";
            exit(true);
        end;
        exit(false);

    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:NPRERVAShowKRequests.js###
'let main=async({workflow:a})=>{await a.respond()};'
        );
    end;
}
