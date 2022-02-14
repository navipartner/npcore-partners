codeunit 6150826 "NPR POS Action: Sale Dimension"
{
    Access = Internal;

    var
        DimensionSourceOptions: Option SHORTCUT1,SHORTCUT2,ANY;
        ValueSelectionOptions: Option "LIST","FIXED",PROMPT_N,PROMPT_A;
        ActionDescription: Label 'This Action updates the POS Sale Dimension with either a fixed value or provides a list of valid value';
        DIMSET: Label 'Dimension code %1 set to %2.';
        ParameterValueIncorrectErr: Label 'Please assign value ''%1'' to parameter "%2" before selecting "%3"', Comment = '%1 - required related parameter value, %2 - related parameter name, %3 - changed parameter name';
        ParameterValueMissingErr: Label 'Please select a value for parameter "%1"', Comment = '%1 - parameter name';
        ReadingErr: Label 'reading in %1';
        TITLE: Label 'Dimension and Statistics';

    local procedure ActionCode(): Code[20]
    begin
        exit('SALE_DIMENSION');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.5');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
          ActionCode(),
          ActionDescription,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple)
        then begin
            Sender.RegisterWorkflowStep('numeric_input', 'if (param.ValueSelection == 2) {numpad ({title: labels.Title, caption: context.CaptionText, value: ""}).cancel(abort);};');
            Sender.RegisterWorkflowStep('alpha_input', 'if (param.ValueSelection == 3) {input  ({title: labels.Title, caption: context.CaptionText, value: ""}).cancel(abort);};');
            Sender.RegisterWorkflowStep('step_1', 'respond();');

            Sender.RegisterOptionParameter(ParameterValueSelection_Name(), 'List,Fixed,Numpad,Textpad', 'List');
            Sender.RegisterOptionParameter(ParameterDimensionSource_Name(), 'Shortcut1,Shortcut2,Any', 'Shortcut1');
            Sender.RegisterOptionParameter(ParameterApplyTo_Name(), 'Sale,CurrentLine,LinesOfTypeSale', 'Sale');
            Sender.RegisterTextParameter(ParameterDimensionCode_Name(), '');
            Sender.RegisterTextParameter(ParameterDimensionValue_Name(), '');
            Sender.RegisterIntegerParameter(ParameterStatisticsFrequency_Name(), 1);
            Sender.RegisterBooleanParameter(ParameterShowConfirmMessage_Name(), false);
            Sender.RegisterBooleanParameter(ParameterCreateDimValue_Name(), false);

            Sender.RegisterWorkflow(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'Title', TITLE);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; Parameters: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        Context: Codeunit "NPR POS JSON Management";
        JSON: Codeunit "NPR POS JSON Management";
        DimCode: Code[20];
        Dimension: Record Dimension;
        CaptionText: Text;
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        JSON.InitializeJObjectParser(Parameters, FrontEnd);

        DimCode := GetDimensionCode(JSON);
        CaptionText := DimCode;
        if (Dimension.Get(DimCode)) then
            CaptionText := Dimension.Name;

        Context.SetContext('CaptionText', CaptionText);

        FrontEnd.SetActionContext(ActionCode(), Context);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        DimCode: Code[20];
        DimValueCode: Code[20];
        StrMessage: Text;
        ApplyDimTo: Option Sale,CurrentLine,LinesOfTypeSale;
        StatisticsFrequency: Integer;
        ValueSelection: Integer;
        ShowMessage: Boolean;
        WithCreate: Boolean;
        MissingParameterErr: Label 'POS action parameter ''%1'' must be specified.', Comment = '%1 - parameter name';
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScopeParameters(ActionCode());

        Randomize();
        StatisticsFrequency := JSON.GetIntegerParameter(ParameterStatisticsFrequency_Name());
        if (StatisticsFrequency < 1) then
            StatisticsFrequency := 1;
        if (Random(StatisticsFrequency) > 1) then
            exit;

        ValueSelection := JSON.GetIntegerParameter(ParameterValueSelection_Name());
        if (ValueSelection < 0) then
            ValueSelection := ValueSelectionOptions::"LIST";

        DimCode := GetDimensionCode(JSON);
        if (DimCode = '') and (ValueSelection <> ValueSelectionOptions::"LIST") then
            Error(MissingParameterErr, ParameterDimensionCode_Caption());

        ApplyDimTo := JSON.GetIntegerParameter(ParameterApplyTo_Name());
        if ApplyDimTo < 0 then
            ApplyDimTo := ApplyDimTo::Sale;

        ShowMessage := JSON.GetBooleanParameter(ParameterShowConfirmMessage_Name());
        WithCreate := JSON.GetBooleanParameter(ParameterCreateDimValue_Name());

        case ValueSelection of
            ValueSelectionOptions::PROMPT_N:
                DimValueCode := CopyStr(GetNumpad(JSON, 'numeric_input'), 1, MaxStrLen(DimValueCode));
            ValueSelectionOptions::PROMPT_A:
                DimValueCode := CopyStr(GetInput(JSON, 'alpha_input'), 1, MaxStrLen(DimValueCode));
            ValueSelectionOptions::"FIXED":
                DimValueCode := CopyStr(JSON.GetStringParameterOrFail(ParameterDimensionValue_Name(), StrSubstNo(ReadingErr, ActionCode())), 1, MaxStrLen(DimValueCode));
            ValueSelectionOptions::"LIST":
                if DimCode <> '' then
                    if not LookupDimensionValue(DimCode, DimValueCode) then
                        Error('');
        end;

        if ApplyDimTo = ApplyDimTo::Sale then
            StrMessage := AdjustHeaderDimensions(POSSession, DimCode, DimValueCode, WithCreate)
        else
            StrMessage := AdjustLineDimensions(POSSession, DimCode, DimValueCode, ApplyDimTo, WithCreate);

        POSSession.RequestRefreshData();

        if (ShowMessage) and (StrMessage <> '') then
            Message(StrMessage);
    end;

    local procedure AdjustHeaderDimensions(POSSession: Codeunit "NPR POS Session"; DimCode: Code[20]; DimValueCode: Code[20]; WithCreate: Boolean) StrMessage: Text
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        if DimCode = '' then
            SalePOS.ShowDocDim()
        else
            StrMessage := SetHeaderDimensionValue(POSSale, DimCode, DimValueCode, WithCreate);

        POSSale.RefreshCurrent();
        POSSale.SetModified();
    end;

    local procedure AdjustLineDimensions(POSSession: Codeunit "NPR POS Session"; DimCode: Code[20]; DimValueCode: Code[20]; ApplyDimTo: Option Sale,CurrentLine,LinesOfTypeSale; WithCreate: Boolean) StrMessage: Text
    var
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        MultiLineDimensionEditNotSupportedErr: Label 'Multi-line dimension edit is not supported. Please select a specific Dimension Code for the POS action.';
    begin
        if ApplyDimTo = ApplyDimTo::Sale then
            exit;

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        case ApplyDimTo of
            ApplyDimTo::CurrentLine:
                SaleLinePOS.SetRecFilter();
            ApplyDimTo::LinesOfTypeSale:
                begin
                    SaleLinePOS.SetRange("Register No.", SaleLinePOS."Register No.");
                    SaleLinePOS.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
                    SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Sale);
                end;
        end;

        if DimCode = '' then begin
            if SaleLinePOS.Count = 1 then begin
                if SaleLinePOS.ShowDimensions() then
                    SaleLinePOS.Modify();
            end else
                //TODO: multi-line dimension edit
                Error(MultiLineDimensionEditNotSupportedErr);
        end else
            StrMessage := SetLineDimensionValue(SaleLinePOS, DimCode, DimValueCode, WithCreate);

        POSSession.GetSale(POSSale);
        POSSale.SetModified();
    end;

    local procedure GetDimensionCode(JSON: Codeunit "NPR POS JSON Management") DimCode: Code[20]
    var
        DimSource: Option;
    begin
        DimSource := JSON.GetIntegerOrFail(ParameterDimensionSource_Name(), StrSubstNo(ReadingErr, ActionCode()));
        if DimSource < 0 then
            DimSource := DimensionSourceOptions::SHORTCUT1;

        case DimSource of
            DimensionSourceOptions::SHORTCUT1,
            DimensionSourceOptions::SHORTCUT2:
                DimCode := GetGlobalDimensionCode(DimSource);
            DimensionSourceOptions::ANY:
                DimCode := CopyStr(JSON.GetStringParameter(ParameterDimensionCode_Name()), 1, MaxStrLen(DimCode));
        end;
    end;

    local procedure LookupDimensionValue(DimCode: Code[20]; var DimValueCode: Code[20]): Boolean
    var
        DimensionValue: Record "Dimension Value";
    begin
        DimensionValue.FilterGroup(2);
        DimensionValue.SetRange("Dimension Code", DimCode);
        DimensionValue.FilterGroup(0);
        if DimValueCode <> '' then begin
            DimensionValue."Dimension Code" := DimCode;
            DimensionValue.Code := DimValueCode;
            if DimensionValue.Find('=><') then;
        end;
        if PAGE.RunModal(0, DimensionValue) <> ACTION::LookupOK then
            exit(false);

        DimValueCode := DimensionValue.Code;
        exit(true);
    end;

    local procedure SetHeaderDimensionValue(POSSale: Codeunit "NPR POS Sale"; DimCode: Code[20]; DimValueCode: Code[20]; WithCreate: Boolean) StrMessage: Text
    begin
        if WithCreate then
            CheckCreateDimensionValue(DimCode, DimValueCode);

        POSSale.SetDimension(DimCode, DimValueCode);
        StrMessage := StrSubstNo(DIMSET, DimCode, DimValueCode);
    end;

    local procedure SetLineDimensionValue(var SaleLinePOS: Record "NPR POS Sale Line"; DimCode: Code[20]; DimValueCode: Code[20]; WithCreate: Boolean) StrMessage: Text
    var
        SaleLinePOS2: Record "NPR POS Sale Line";
    begin
        if SaleLinePOS.IsEmpty() then
            exit;

        if WithCreate then
            CheckCreateDimensionValue(DimCode, DimValueCode);

        SaleLinePOS.FindSet(true);
        repeat
            SaleLinePOS2 := SaleLinePOS;
            SaleLinePOS2.SetDimension(DimCode, DimValueCode);
        until SaleLinePOS.Next() = 0;

        StrMessage := StrSubstNo(DIMSET, DimCode, DimValueCode);
    end;

    local procedure CheckCreateDimensionValue(DimCode: Code[20]; DimValueCode: Code[20])
    var
        DimensionValue: Record "Dimension Value";
    begin
        if DimensionValue.Get(DimCode, DimValueCode) then
            exit;

        DimensionValue.Init();
        DimensionValue."Dimension Code" := DimCode;
        DimensionValue.Code := DimValueCode;
        DimensionValue."Dimension Value Type" := DimensionValue."Dimension Value Type"::Standard;
        DimensionValue.Insert(true);
    end;

    local procedure GetNumpad(JSON: Codeunit "NPR POS JSON Management"; Path: Text): Text
    begin
        JSON.SetScopeRoot();
        if (not JSON.SetScope('$' + Path)) then
            exit('');

        exit(JSON.GetString('numpad'));
    end;

    local procedure GetInput(JSON: Codeunit "NPR POS JSON Management"; Path: Text): Text
    begin
        JSON.SetScopeRoot();
        if (not JSON.SetScope('$' + Path)) then
            exit('');

        exit(JSON.GetString('input'));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        Dimension: Record Dimension;
        SelectedValue: Code[20];
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            ParameterDimensionCode_Name():
                begin
                    SelectedValue := CopyStr(POSParameterValue.Value, 1, MaxStrLen(SelectedValue));
                    if SelectedValue <> '' then begin
                        Dimension.Code := SelectedValue;
                        if Dimension.Find('=><') then;
                    end;
                    if Page.RunModal(0, Dimension) = Action::LookupOK then
                        POSParameterValue.Validate(Value, Dimension.Code);
                end;

            ParameterDimensionValue_Name():
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
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            ParameterDimensionSource_Name():
                begin
                    TryGetParameterOptionNo(POSParameterValue, SelectedOptionNo);
                    if SelectedOptionNo <> DimensionSourceOptions::ANY then begin
                        POSParameterValue2 := POSParameterValue;
                        POSParameterValue2.SetRecFilter();
                        POSParameterValue2.SetRange(Name, ParameterDimensionCode_Name());
                        if POSParameterValue2.FindFirst() then
                            if POSParameterValue2.Value <> '' then begin
                                POSParameterValue2.Validate(Value, '');
                                POSParameterValue2.Modify();
                            end;
                    end;
                    POSParameterValue.Modify();

                    GetDimension(POSParameterValue, Dimension, false);
                    ReevaluateDimensionValueCodeParameter(POSParameterValue, Dimension);
                end;

            ParameterDimensionCode_Name():
                begin
                    Clear(Dimension);
                    GetDimensionSourceParameter(POSParameterValue, SelectedOptionNo, true);
                    if POSParameterValue.Value <> '' then begin
                        if SelectedOptionNo <> DimensionSourceOptions::ANY then
                            Error(ParameterValueIncorrectErr, SelectStr(DimensionSourceOptions::ANY + 1, ParameterDimensionSource_OptionCaptions()), ParameterDimensionSource_Caption(), ParameterDimensionCode_Caption());
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

            ParameterDimensionValue_Name():
                begin
                    if POSParameterValue.Value = '' then
                        exit;

                    GetValueSelectionParameter(POSParameterValue, SelectedOptionNo, true);
                    if SelectedOptionNo <> ValueSelectionOptions::"FIXED" then
                        Error(ParameterValueIncorrectErr, SelectStr(ValueSelectionOptions::"FIXED" + 1, ParameterValueSelection_OptionCaptions()), ParameterValueSelection_Caption(), ParameterDimensionValue_Caption());

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

            ParameterValueSelection_Name():
                begin
                    TryGetParameterOptionNo(POSParameterValue, SelectedOptionNo);
                    if SelectedOptionNo <> ValueSelectionOptions::"FIXED" then begin
                        POSParameterValue2 := POSParameterValue;
                        POSParameterValue2.SetRecFilter();
                        POSParameterValue2.SetRange(Name, ParameterDimensionValue_Name());
                        if POSParameterValue2.FindFirst() then
                            if POSParameterValue2.Value <> '' then begin
                                POSParameterValue2.Validate(Value, '');
                                POSParameterValue2.Modify();
                            end;
                    end;
                end;
        end;
    end;

    local procedure ReevaluateDimensionValueCodeParameter(POSParameterValue: Record "NPR POS Parameter Value"; Dimension: Record Dimension)
    var
        DimensionValue: Record "Dimension Value";
        ClearValue: Boolean;
    begin
        POSParameterValue.SetRecFilter();
        POSParameterValue.SetRange(Name, ParameterDimensionValue_Name());
        if not POSParameterValue.FindFirst() or (POSParameterValue.Value = '') then
            exit;

        ClearValue := Dimension.Code = '';
        if not ClearValue then
            ClearValue := not DimensionValue.Get(Dimension.Code, CopyStr(POSParameterValue.Value, 1, MaxStrLen(DimensionValue.Code)));
        if not ClearValue then
            exit;

        POSParameterValue.Validate(Value, '');
        POSParameterValue.Modify();
    end;

    local procedure GetDimension(POSParameterValue: Record "NPR POS Parameter Value"; var Dimension: Record Dimension; WithError: Boolean): Boolean
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

    local procedure GetDimensionCodeParameter(POSParameterValue: Record "NPR POS Parameter Value"; var DimCode: Code[20]; WithError: Boolean): Boolean
    begin
        POSParameterValue.SetRecFilter();
        POSParameterValue.SetRange(Name, ParameterDimensionCode_Name());
        if not (POSParameterValue.FindFirst() and (POSParameterValue.Value <> '')) then begin
            if WithError then
                Error(ParameterValueMissingErr, ParameterDimensionCode_Caption());
            DimCode := '';
            exit(false);
        end;
        DimCode := CopyStr(POSParameterValue.Value, 1, MaxStrLen(DimCode));
        exit(true);
    end;

    local procedure GetDimensionSourceParameter(POSParameterValue: Record "NPR POS Parameter Value"; var DimSource: Integer; WithError: Boolean): Boolean
    begin
        DimSource := 0;
        POSParameterValue.SetRecFilter();
        POSParameterValue.SetRange(Name, ParameterDimensionSource_Name());
        if not (POSParameterValue.FindFirst() and TryGetParameterOptionNo(POSParameterValue, DimSource)) then begin
            if WithError then
                Error(ParameterValueMissingErr, ParameterDimensionSource_Caption());
            exit(false);
        end;
        exit(true);
    end;

    local procedure GetValueSelectionParameter(POSParameterValue: Record "NPR POS Parameter Value"; var ValueSelection: Integer; WithError: Boolean): Boolean
    begin
        ValueSelection := 0;
        POSParameterValue.SetRecFilter();
        POSParameterValue.SetRange(Name, ParameterValueSelection_Name());
        if not (POSParameterValue.FindFirst() and TryGetParameterOptionNo(POSParameterValue, ValueSelection)) then begin
            if WithError then
                Error(ParameterValueMissingErr, ParameterValueSelection_Caption());
            exit(false);
        end;
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

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterNameCaption', '', true, false)]
    local procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    var
        CaptionApplyTo: Label 'Apply-To';
        CaptionCreateDimValue: Label 'Create Value';
        CaptionShowConfirmMessage: Label 'Confirm';
        CaptionStatisticsFrequency: Label 'Statistics Frequency';
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            ParameterDimensionCode_Name():
                Caption := ParameterDimensionCode_Caption();
            ParameterDimensionValue_Name():
                Caption := ParameterDimensionValue_Caption();
            ParameterDimensionSource_Name():
                Caption := ParameterDimensionSource_Caption();
            ParameterCreateDimValue_Name():
                Caption := CaptionCreateDimValue;
            ParameterValueSelection_Name():
                Caption := ParameterValueSelection_Caption();
            ParameterApplyTo_Name():
                Caption := CaptionApplyTo;
            ParameterStatisticsFrequency_Name():
                Caption := CaptionStatisticsFrequency;
            ParameterShowConfirmMessage_Name():
                Caption := CaptionShowConfirmMessage;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterDescriptionCaption', '', true, false)]
    local procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    var
        DescApplyTo: Label 'Specifies the scope the dimension is to be applied to. ''All Sales Items'' means all lines of type ''Sale''';
        DescCreateDimValue: Label 'Specifies if the system will automatically create missing dimension values';
        DescDimensionCode: Label 'Specifies the code of the dimension you want to assign to the sale';
        DescDimensionSource: Label 'Specifies the source of the dimension code to be used for the POS action';
        DescDimensionValue: Label 'Specifies the dimention value you want to assign to the sale';
        DescShowConfirmMessage: Label 'Specifies whether system should acknowledge successful dimension assignment with a confirmation message';
        DescStatisticsFrequency: Label 'Specifies the probability system will run the POS action. 1 - means 100% (always), 2 - 50%, 4 - 25% etc.';
        DescValueSelection: Label 'Specifies the way system will ask user to specify a dimension value';
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            ParameterDimensionCode_Name():
                Caption := DescDimensionCode;
            ParameterDimensionValue_Name():
                Caption := DescDimensionValue;
            ParameterDimensionSource_Name():
                Caption := DescDimensionSource;
            ParameterCreateDimValue_Name():
                Caption := DescCreateDimValue;
            ParameterValueSelection_Name():
                Caption := DescValueSelection;
            ParameterApplyTo_Name():
                Caption := DescApplyTo;
            ParameterStatisticsFrequency_Name():
                Caption := DescStatisticsFrequency;
            ParameterShowConfirmMessage_Name():
                Caption := DescShowConfirmMessage;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterOptionStringCaption', '', true, false)]
    local procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    var
        OptionApplyTo: Label 'Entire Sale,Current Line,All Sales Items';
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            ParameterDimensionSource_Name():
                Caption := ParameterDimensionSource_OptionCaptions();
            ParameterValueSelection_Name():
                Caption := ParameterValueSelection_OptionCaptions();
            ParameterApplyTo_Name():
                Caption := OptionApplyTo;
        end;
    end;

    local procedure ParameterDimensionCode_Name(): Text[30]
    begin
        exit('DimensionCode');
    end;

    local procedure ParameterDimensionCode_Caption(): Text
    var
        DimensionCodeLbl: Label 'Dimension Code';
    begin
        exit(DimensionCodeLbl);
    end;

    local procedure ParameterDimensionValue_Name(): Text[30]
    begin
        exit('DimensionValue');
    end;

    local procedure ParameterDimensionValue_Caption(): Text
    var
        DimensionValueCodeLbl: Label 'Dimension Value Code';
    begin
        exit(DimensionValueCodeLbl);
    end;

    local procedure ParameterDimensionSource_Name(): Text[30]
    begin
        exit('DimensionSource');
    end;

    local procedure ParameterDimensionSource_Caption(): Text
    var
        DimensionSourceLbl: Label 'Dimension Source';
    begin
        exit(DimensionSourceLbl);
    end;

    local procedure ParameterDimensionSource_OptionCaptions(): Text
    var
        DimensionSourceOptionsLbl: Label '1st Global Dimension,2nd Global Dimension,Any';
    begin
        exit(DimensionSourceOptionsLbl);
    end;

    local procedure ParameterCreateDimValue_Name(): Text[30]
    begin
        exit('CreateDimValue');
    end;

    local procedure ParameterValueSelection_Name(): Text[30]
    begin
        exit('ValueSelection');
    end;

    local procedure ParameterValueSelection_Caption(): Text
    var
        ValueSelectionLbl: Label 'Value Selection';
    begin
        exit(ValueSelectionLbl);
    end;

    local procedure ParameterValueSelection_OptionCaptions(): Text
    var
        OptionValueSelectionLbl: Label 'List,Fixed,Numpad,Textpad';
    begin
        exit(OptionValueSelectionLbl);
    end;

    local procedure ParameterApplyTo_Name(): Text[30]
    begin
        exit('ApplyTo');
    end;

    local procedure ParameterStatisticsFrequency_Name(): Text[30]
    begin
        exit('StatisticsFrequency');
    end;

    local procedure ParameterShowConfirmMessage_Name(): Text[30]
    begin
        exit('ShowConfirmMessage');
    end;
}
