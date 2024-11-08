codeunit 6150826 "NPR POS Action: Sale Dimension" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        DimensionSourceOptions: Option SHORTCUT1,SHORTCUT2,ANY;
        ValueSelectionOptions: Option "LIST","FIXED",PROMPT_N,PROMPT_A;
        ParameterValueIncorrectErr: Label 'Please assign value ''%1'' to parameter "%2" before selecting "%3"', Comment = '%1 - required related parameter value, %2 - related parameter name, %3 - changed parameter name';
        ParameterValueMissingErr: Label 'Please select a value for parameter "%1"', Comment = '%1 - parameter name';
        DimensionSourceOptionsLbl: Label '1st Global Dimension,2nd Global Dimension,Any';
        OptionValueSelectionLbl: Label 'List,Fixed,Numpad,Textpad';


    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This Action updates the POS Sale Dimension with either a fixed value or provides a list of valid value';
        ParamValueSelection_OptionsLbl: Label 'List,Fixed,Numpad,Textpad', Locked = true;
        ParamValueSelection_CptLbl: Label 'Value Selection';
        ParamValueSelection_DescrLbl: Label 'Specifies the way system will ask user to specify a dimension value';
        ParamDimensionSource_CptLbl: Label 'Dimension Source';
        ParamDimensionSource_OptionsLbl: Label 'Shortcut1,Shortcut2,Any', Locked = true;
        ParamDimensionSource_DescrLbl: Label 'Specifies the source of the dimension code to be used for the POS action';
        ParamApplyTo_OptionsLbl: Label 'Sale,CurrentLine,LinesOfTypeSale', Locked = true;
        ParamApplyToOption_CptLbl: Label 'Entire Sale,Current Line,All Sales Items';
        ParamApplyTo_CptLbl: Label 'Apply-To';
        ParamApplyTo_DescrLbl: Label 'Specifies the scope the dimension is to be applied to. ''All Sales Items'' means all lines of type ''Sale''';
        ParamDimensionCode_CptLbl: Label 'Dimension Code';
        ParamDimensionCode_DescrLbl: Label 'Specifies the code of the dimension you want to assign to the sale';
        ParamDimensionValue_CptLbl: Label 'Dimension Value';
        ParamDimensionValue_DescrLbl: Label 'Specifies the dimention value you want to assign to the sale';
        ParamStatisticsFrequency_CptLbl: Label 'Statistics Frequency';
        ParamStatisticsFrequency_DescrLbl: Label 'Specifies the probability system will run the POS action. 1 - means 100% (always), 2 - 50%, 4 - 25% etc.';
        ParamShowConfirmMessage_CptLbl: Label 'Confirm';
        ParamShowConfirmMessage_DescLbl: Label 'Specifies whether system should acknowledge successful dimension assignment with a confirmation message';
        ParamCreateDimValue_CptLbl: Label 'Create Value';
        ParamCreateDimValue_DescLbl: Label 'Specifies if the system will automatically create missing dimension values';
        DimTitle: Label 'Dimension and Statistics';
        ParamHeadlineTxt_CptLbl: Label 'Headline text';
        ParamHealineTxt_DescLbl: Label 'Specifies popup Headline text';
        ParmDimensionMandatory_CptLbl: Label 'Dimension Mandatory';
        ParmDimensionMandatory_DescLbl: Label 'Specifies if it is necessary to insert a dimension.';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddOptionParameter('ValueSelection',
                                         ParamValueSelection_OptionsLbl,
#pragma warning disable AA0139
                                         SelectStr(1, ParamValueSelection_OptionsLbl),
#pragma warning restore 
                                         ParamValueSelection_CptLbl,
                                         ParamValueSelection_DescrLbl,
                                         OptionValueSelectionLbl
                                         );

        WorkflowConfig.AddOptionParameter('DimensionSource',
                                         ParamDimensionSource_OptionsLbl,
#pragma warning disable AA0139
                                         SelectStr(1, ParamDimensionSource_OptionsLbl),
#pragma warning restore 
                                         ParamDimensionSource_CptLbl,
                                         ParamDimensionSource_DescrLbl,
                                         DimensionSourceOptionsLbl
                                         );

        WorkflowConfig.AddOptionParameter('ApplyTo',
                                          ParamApplyTo_OptionsLbl,
#pragma warning disable AA0139
                                         SelectStr(1, ParamApplyTo_OptionsLbl),
#pragma warning restore 
                                         ParamApplyTo_CptLbl,
                                         ParamApplyTo_DescrLbl,
                                         ParamApplyToOption_CptLbl
                                         );

        WorkflowConfig.AddTextParameter('DimensionCode', '', ParamDimensionCode_CptLbl, ParamDimensionCode_DescrLbl);
        WorkflowConfig.AddTextParameter('DimensionValue', '', ParamDimensionValue_CptLbl, ParamDimensionValue_DescrLbl);
        WorkflowConfig.AddIntegerParameter('StatisticsFrequency', 1, ParamStatisticsFrequency_CptLbl, ParamStatisticsFrequency_DescrLbl);
        WorkflowConfig.AddBooleanParameter('ShowConfirmMessage', false, ParamShowConfirmMessage_CptLbl, ParamShowConfirmMessage_DescLbl);
        WorkflowConfig.AddBooleanParameter('CreateDimValue', false, ParamCreateDimValue_CptLbl, ParamCreateDimValue_DescLbl);
        WorkflowConfig.AddTextParameter('HeadlineTxt', DimTitle, ParamHeadlineTxt_CptLbl, ParamHealineTxt_DescLbl);
        WorkflowConfig.AddBooleanParameter('DimensionMandatory', false, ParmDimensionMandatory_CptLbl, ParmDimensionMandatory_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var

    begin
        case Step of
            'GetCaptions':
                FrontEnd.WorkflowResponse(GetCaptios(Context));
            'InsertDim':
                FrontEnd.WorkflowResponse(InsertDim(Context));
        end;
    end;

    local procedure GetCaptios(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        HeadLineTxt: Text;
        DimCode: Code[20];
        Dimension: Record Dimension;
        CaptionText: Text;
    begin
        HeadLineTxt := Context.GetStringParameter('HeadlineTxt');
        Response.Add('HeadlineTxt', HeadLineTxt);

        DimCode := GetDimensionCode(Context);
        CaptionText := DimCode;
        if (Dimension.Get(DimCode)) then
            CaptionText := Dimension.Name;

        Response.Add('CaptionText', CaptionText);
    end;

    local procedure InsertDim(Context: Codeunit "NPR POS JSON Helper"): JsonObject
    var
        DimCode: Code[20];
        DimValueCode: Code[20];
        StrMessage: Text;
        ApplyDimTo: Option Sale,CurrentLine,LinesOfTypeSale;
        StatisticsFrequency: Integer;
        ValueSelection: Integer;
        ShowMessage: Boolean;
        WithCreate: Boolean;
        DimensionMandatory: Boolean;
        MissingParameterErr: Label 'POS action parameter ''%1'' must be specified.', Comment = '%1 - parameter name';
        DimensionMandatoryErr: Label 'Dimension must be inserted.';
        POSSession: Codeunit "NPR POS Session";
        POActSaleDimB: Codeunit "NPR POS Action: Sale Dim. B";
    begin

        Randomize();
        StatisticsFrequency := Context.GetIntegerParameter('StatisticsFrequency');
        if (StatisticsFrequency < 1) then
            StatisticsFrequency := 1;
        if (Random(StatisticsFrequency) > 1) then
            exit;

        ValueSelection := Context.GetIntegerParameter('ValueSelection');
        if (ValueSelection < 0) then
            ValueSelection := ValueSelectionOptions::"LIST";

        DimCode := GetDimensionCode(Context);
        if (DimCode = '') and (ValueSelection <> ValueSelectionOptions::"LIST") then
            Error(MissingParameterErr, 'Dimension Code');

        ApplyDimTo := Context.GetIntegerParameter('ApplyTo');
        if ApplyDimTo < 0 then
            ApplyDimTo := ApplyDimTo::Sale;

        ShowMessage := Context.GetBooleanParameter('ShowConfirmMessage');
        WithCreate := Context.GetBooleanParameter('CreateDimValue');
        DimensionMandatory := Context.GetBooleanParameter('DimensionMandatory');

        case ValueSelection of
            ValueSelectionOptions::PROMPT_N:
                begin
                    DimValueCode := CopyStr(Context.GetString('DimCode'), 1, MaxStrLen(DimValueCode));
                    if DimensionMandatory and (DimValueCode = '') then
                        Error(DimensionMandatoryErr);
                end;
            ValueSelectionOptions::PROMPT_A:
                begin
                    DimValueCode := CopyStr(Context.GetString('DimCode'), 1, MaxStrLen(DimValueCode));
                    if DimensionMandatory and (DimValueCode = '') then
                        Error(DimensionMandatoryErr);
                end;
            ValueSelectionOptions::"FIXED":
                DimValueCode := CopyStr(Context.GetStringParameter('DimensionValue'), 1, MaxStrLen(DimValueCode));
            ValueSelectionOptions::"LIST":
                if DimCode <> '' then
                    if not LookupDimensionValue(DimCode, DimValueCode) then
                        if not DimensionMandatory then
                            exit
                        else
                            Error(DimensionMandatoryErr)
        end;

        if ApplyDimTo = ApplyDimTo::Sale then
            StrMessage := POActSaleDimB.AdjustHeaderDimensions(POSSession, DimCode, DimValueCode, WithCreate)
        else
            StrMessage := POActSaleDimB.AdjustLineDimensions(POSSession, DimCode, DimValueCode, ApplyDimTo, WithCreate);

        if (ShowMessage) and (StrMessage <> '') then
            Message(StrMessage);
    end;

    local procedure GetDimensionCode(Context: Codeunit "NPR POS JSON Helper") DimCode: Code[20]
    var
        DimSource: Option;
    begin
        DimSource := Context.GetIntegerParameter('DimensionSource');
        if DimSource < 0 then
            DimSource := DimensionSourceOptions::SHORTCUT1;

        case DimSource of
            DimensionSourceOptions::SHORTCUT1,
            DimensionSourceOptions::SHORTCUT2:
                DimCode := GetGlobalDimensionCode(DimSource);
            DimensionSourceOptions::ANY:
                DimCode := CopyStr(Context.GetStringParameter('DimensionCode'), 1, MaxStrLen(DimCode));
        end;
    end;

    local procedure LookupDimensionValue(DimCode: Code[20]; var DimValueCode: Code[20]): Boolean
    var
        DimensionValue: Record "Dimension Value";
    begin
        DimensionValue.FilterGroup(2);
        DimensionValue.SetRange("Dimension Code", DimCode);
        DimensionValue.SetRange(Blocked, false);
        DimensionValue.FilterGroup(0);
        if DimValueCode <> '' then begin
            DimensionValue."Dimension Code" := DimCode;
            DimensionValue.Code := DimValueCode;
            if DimensionValue.Find('=><') then;
        end;

        if Page.RunModal(Page::"NPR Dimension Value List", DimensionValue) <> ACTION::LookupOK then
            exit(false);

        DimValueCode := DimensionValue.Code;
        exit(true);
    end;


    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        Dimension: Record Dimension;
        SelectedValue: Code[20];
    begin
        if POSParameterValue."Action Code" <> 'SALE_DIMENSION' then
            exit;
        case POSParameterValue.Name of
            'DimensionCode':
                begin
                    SelectedValue := CopyStr(POSParameterValue.Value, 1, MaxStrLen(SelectedValue));
                    if SelectedValue <> '' then begin
                        Dimension.Code := SelectedValue;
                        if Dimension.Find('=><') then;
                    end;
                    if Page.RunModal(0, Dimension) = Action::LookupOK then
                        POSParameterValue.Validate(Value, Dimension.Code);
                end;

            'DimensionValue':
                begin
                    if not GetDimension(POSParameterValue, Dimension, false) then
                        exit;
                    SelectedValue := CopyStr(POSParameterValue.Value, 1, MaxStrLen(SelectedValue));
                    If LookupDimensionValue(Dimension.Code, SelectedValue) then
                        POSParameterValue.Validate(Value, SelectedValue);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', false, false)]
    local procedure OnValidateValue(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        Dimension: Record Dimension;
        DimensionValue: Record "Dimension Value";
        POSParameterValue2: Record "NPR POS Parameter Value";
        DimMgt: Codeunit DimensionManagement;
        SelectedOptionNo: Integer;
        FilterMaskLbl: Label '@%1*', Locked = true;
    begin
        if POSParameterValue."Action Code" <> 'SALE_DIMENSION' then
            exit;

        case POSParameterValue.Name of
            'DimensionSource':
                begin
                    TryGetParameterOptionNo(POSParameterValue, SelectedOptionNo);
                    if SelectedOptionNo <> DimensionSourceOptions::ANY then begin
                        POSParameterValue2 := POSParameterValue;
                        POSParameterValue2.CopyFilters(POSParameterValue);
                        POSParameterValue.SetRange(Name, 'DimensionCode');
                        if POSParameterValue.FindFirst() then
                            if POSParameterValue.Value <> '' then begin
                                POSParameterValue.Validate(Value, '');
                                POSParameterValue.Modify();
                            end;
                        POSParameterValue := POSParameterValue2;
                        POSParameterValue.CopyFilters(POSParameterValue2);
                    end;
                    GetDimension(POSParameterValue, Dimension, false);
                    ReevaluateDimensionValueCodeParameter(POSParameterValue, Dimension);
                end;

            'DimensionCode':
                begin
                    Clear(Dimension);
                    GetDimensionSourceParameter(POSParameterValue, SelectedOptionNo, true);
                    if POSParameterValue.Value <> '' then begin
                        if SelectedOptionNo <> DimensionSourceOptions::ANY then
                            Error(ParameterValueIncorrectErr, SelectStr(DimensionSourceOptions::ANY + 1, DimensionSourceOptionsLbl), 'Dimension Source', 'Dimension Code');
                        Dimension.Code := CopyStr(POSParameterValue.Value, 1, MaxStrLen(Dimension.Code));
                        if not Dimension.Find() then begin
                            Dimension.SetFilter(Code, StrSubstNo(FilterMaskLbl, POSParameterValue.Value));
                            Dimension.FindFirst();
                        end;
                        POSParameterValue.Value := Dimension.Code;
                    end;
                    if SelectedOptionNo = DimensionSourceOptions::ANY then
                        ReevaluateDimensionValueCodeParameter(POSParameterValue, Dimension);
                end;

            'DimensionValue':
                begin
                    if POSParameterValue.Value = '' then
                        exit;

                    GetValueSelectionParameter(POSParameterValue, SelectedOptionNo, true);
                    if SelectedOptionNo <> ValueSelectionOptions::"FIXED" then
                        Error(ParameterValueIncorrectErr, SelectStr(ValueSelectionOptions::"FIXED" + 1, OptionValueSelectionLbl), 'Value Selection', 'Dimension Value Code');

                    GetDimension(POSParameterValue, Dimension, true);
                    DimensionValue."Dimension Code" := Dimension.Code;
                    DimensionValue.Code := CopyStr(POSParameterValue.Value, 1, MaxStrLen(DimensionValue.Code));
                    if not DimensionValue.Find() then begin
                        DimensionValue.SetRange("Dimension Code", Dimension.Code);
                        DimensionValue.SetFilter(Code, StrSubstNo(FilterMaskLbl, POSParameterValue.Value));
                        DimensionValue.FindFirst();
                    end;
                    if not DimMgt.CheckDimValue(DimensionValue."Dimension Code", DimensionValue.Code) then
                        Error(DimMgt.GetDimErr());
                    POSParameterValue.Value := DimensionValue.Code;
                end;

            'ValueSelection':
                begin
                    TryGetParameterOptionNo(POSParameterValue, SelectedOptionNo);
                    if SelectedOptionNo <> ValueSelectionOptions::"FIXED" then begin
                        POSParameterValue2 := POSParameterValue;
                        POSParameterValue2.CopyFilters(POSParameterValue);
                        POSParameterValue.SetRange(Name, 'DimensionValue');
                        if POSParameterValue.FindFirst() then
                            if POSParameterValue.Value <> '' then begin
                                POSParameterValue.Validate(Value, '');
                                POSParameterValue.Modify();
                            end;
                        POSParameterValue := POSParameterValue2;
                        POSParameterValue.CopyFilters(POSParameterValue2);
                    end;
                end;
        end;
    end;

    local procedure ReevaluateDimensionValueCodeParameter(var POSParameterValue: Record "NPR POS Parameter Value"; Dimension: Record Dimension)
    var
        DimensionValue: Record "Dimension Value";
        TempPOSParameterValue: Record "NPR POS Parameter Value" temporary;
        ClearValue: Boolean;
    begin
        TempPOSParameterValue := POSParameterValue;
        TempPOSParameterValue.CopyFilters(POSParameterValue);
        POSParameterValue.SetRange(Name, 'DimensionValue');
        if not POSParameterValue.FindFirst() or (POSParameterValue.Value = '') then begin
            POSParameterValue := TempPOSParameterValue;
            POSParameterValue.CopyFilters(TempPOSParameterValue);
            exit;
        end;

        ClearValue := Dimension.Code = '';
        if not ClearValue then
            ClearValue := not DimensionValue.Get(Dimension.Code, CopyStr(POSParameterValue.Value, 1, MaxStrLen(DimensionValue.Code)));
        if not ClearValue then begin
            POSParameterValue := TempPOSParameterValue;
            POSParameterValue.CopyFilters(TempPOSParameterValue);
            exit;
        end;

        POSParameterValue.Validate(Value, '');
        POSParameterValue.Modify();
        POSParameterValue := TempPOSParameterValue;
        POSParameterValue.CopyFilters(TempPOSParameterValue);
    end;

    local procedure GetDimension(var POSParameterValue: Record "NPR POS Parameter Value"; var Dimension: Record Dimension; WithError: Boolean): Boolean
    var
        DimSource: Integer;
        DimCode: Code[20];
    begin
        if not GetDimensionSourceParameter(POSParameterValue, DimSource, WithError) then
            exit(false);
        case DimSource of
            DimensionSourceOptions::SHORTCUT1,
            DimensionSourceOptions::SHORTCUT2:
                DimCode := GetGlobalDimensionCode(DimSource);
            DimensionSourceOptions::ANY:
                if not GetDimensionCodeParameter(POSParameterValue, DimCode, WithError) then
                    exit(false);
        end;

        if WithError then begin
            Dimension.Get(DimCode);
            exit(true);
        end else
            exit(Dimension.Get(DimCode));
    end;

    local procedure GetGlobalDimensionCode(DimSource: Integer) DimCode: Code[20]
    var
        FailErr: Label '%1\AL stack trace:\%2';
    begin
        if not TryGetGlobalDimensionCode(DimSource, DimCode) then
            Error(FailErr, GetLastErrorText(), GetLastErrorCallStack());
    end;

    [TryFunction]
    local procedure TryGetGlobalDimensionCode(DimSource: Integer; var DimCode: Code[20])
    var
        GLSetup: Record "General Ledger Setup";
        IncorrectCallErr: Label 'Function call with an incorrect parameter (DimSource = ''%1''). This is a programming bug, not a user error. Please contact system vendor.';
    begin
        if not (DimSource in [DimensionSourceOptions::SHORTCUT1, DimensionSourceOptions::SHORTCUT2]) then
            error(IncorrectCallErr, DimSource);

        GLSetup.Get();
        case DimSource of
            DimensionSourceOptions::SHORTCUT1:
                begin
                    GLSetup.TestField("Global Dimension 1 Code");
                    DimCode := GLSetup."Global Dimension 1 Code";
                end;
            DimensionSourceOptions::SHORTCUT2:
                begin
                    GLSetup.TestField("Global Dimension 2 Code");
                    DimCode := GLSetup."Global Dimension 2 Code";
                end;
        end;
    end;

    local procedure GetDimensionCodeParameter(var POSParameterValue: Record "NPR POS Parameter Value"; var DimCode: Code[20]; WithError: Boolean): Boolean
    var
        TempPOSParameterValue: Record "NPR POS Parameter Value" temporary;
    begin
        TempPOSParameterValue := POSParameterValue;
        TempPOSParameterValue.CopyFilters(POSParameterValue);
        POSParameterValue.SetRange(Name, 'DimensionCode');
        if not (POSParameterValue.FindFirst() and (POSParameterValue.Value <> '')) then begin
            if WithError then
                Error(ParameterValueMissingErr, 'Dimension Code');
            POSParameterValue := TempPOSParameterValue;
            POSParameterValue.CopyFilters(TempPOSParameterValue);
            DimCode := '';
            exit(false);
        end;
        DimCode := CopyStr(POSParameterValue.Value, 1, MaxStrLen(DimCode));
        POSParameterValue := TempPOSParameterValue;
        POSParameterValue.CopyFilters(TempPOSParameterValue);
        exit(true);
    end;

    local procedure GetDimensionSourceParameter(var POSParameterValue: Record "NPR POS Parameter Value"; var DimSource: Integer; WithError: Boolean): Boolean
    var
        TempPOSParameterValue: Record "NPR POS Parameter Value" temporary;
    begin
        DimSource := 0;
        TempPOSParameterValue := POSParameterValue;
        TempPOSParameterValue.CopyFilters(POSParameterValue);
        POSParameterValue.SetRange(Name, 'DimensionSource');
        if not (POSParameterValue.FindFirst() and TryGetParameterOptionNo(POSParameterValue, DimSource)) then begin
            if WithError then
                Error(ParameterValueMissingErr, 'Dimension Source');
            POSParameterValue := TempPOSParameterValue;
            POSParameterValue.CopyFilters(TempPOSParameterValue);
            exit(false);
        end;
        POSParameterValue := TempPOSParameterValue;
        POSParameterValue.CopyFilters(TempPOSParameterValue);
        exit(true);
    end;

    local procedure GetValueSelectionParameter(var POSParameterValue: Record "NPR POS Parameter Value"; var ValueSelection: Integer; WithError: Boolean): Boolean
    var
        TempPOSParameterValue: Record "NPR POS Parameter Value" temporary;
    begin
        ValueSelection := 0;
        TempPOSParameterValue := POSParameterValue;
        TempPOSParameterValue.CopyFilters(POSParameterValue);
        POSParameterValue.SetRange(Name, 'ValueSelection');
        if not (POSParameterValue.FindFirst() and TryGetParameterOptionNo(POSParameterValue, ValueSelection)) then begin
            if WithError then
                Error(ParameterValueMissingErr, 'Value Selection');
            POSParameterValue := TempPOSParameterValue;
            POSParameterValue.CopyFilters(TempPOSParameterValue);
            exit(false);
        end;
        POSParameterValue := TempPOSParameterValue;
        POSParameterValue.CopyFilters(TempPOSParameterValue);
        exit(true);
    end;

    [TryFunction]
    local procedure TryGetParameterOptionNo(POSParameterValue: Record "NPR POS Parameter Value"; var SelectedOptionNo: Integer)
    var
        POSActionParameter: Record "NPR POS Action Parameter";
    begin
        POSActionParameter.Get(POSParameterValue."Action Code", POSParameterValue.Name);
        SelectedOptionNo := POSActionParameter.GetOptionInt(POSParameterValue.Value);
        if SelectedOptionNo < 0 then
            SelectedOptionNo := 0;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionSaleDimension.js###
'const main=async({parameters:n})=>{const{HeadlineTxt:o,DimCaption:t}=await workflow.respond("GetCaptions");if(n.ValueSelection==2){var i=await popup.numpad({title:o,caption:t});if(i===null)if(n.DimensionMandatory)i="";else return" "}if(n.ValueSelection==3){var i=await popup.input({title:o,caption:t});if(i===null)if(n.DimensionMandatory)i="";else return" "}await workflow.respond("InsertDim",{DimCode:i})};'
        );
    end;
}
