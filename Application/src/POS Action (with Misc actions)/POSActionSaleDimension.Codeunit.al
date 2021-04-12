codeunit 6150826 "NPR POS Action: Sale Dimension"
{
    var
        ActionDescription: Label 'This Action updates the POS Sale Dimension with either a fixed value or provides a list of valid value';
        ValueSelection: Option LIST,"FIXED",PROMPT_N,PROMPT_A;
        DimensionSource: Option SHORTCUT1,SHORTCUT2,ANY;
        DIMSET: Label 'Dimension code %1 set to %2.';
        TITLE: Label 'Dimension and Statistics';
        ReadingErr: Label 'reading in %1';

    local procedure ActionCode(): Text
    begin
        exit('SALE_DIMENSION');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.4');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
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

            Sender.RegisterOptionParameter('ValueSelection', 'List,Fixed,Numpad,Textpad', 'List');
            Sender.RegisterOptionParameter('DimensionSource', 'Shortcut1,Shortcut2,Any', 'Shortcut1');

            Sender.RegisterTextParameter('DimensionCode', '');
            Sender.RegisterTextParameter('DimensionValue', '');

            Sender.RegisterIntegerParameter('StatisticsFrequency', 1);

            Sender.RegisterBooleanParameter('ShowConfirmMessage', false);
            Sender.RegisterBooleanParameter('CreateDimValue', false);

            Sender.RegisterWorkflow(true);

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'Title', TITLE);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; Parameters: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        Context: Codeunit "NPR POS JSON Management";
        JSON: Codeunit "NPR POS JSON Management";
        DimensionCode: Code[20];
        Dimension: Record Dimension;
        GeneralLedgerSetup: Record "General Ledger Setup";
        CaptionText: Text;
    begin

        if not Action.IsThisAction(ActionCode()) then
            exit;

        JSON.InitializeJObjectParser(Parameters, FrontEnd);
        GeneralLedgerSetup.Get();

        DimensionSource := JSON.GetIntegerOrFail('DimensionSource', StrSubstNo(ReadingErr, ActionCode()));
        case DimensionSource of
            DimensionSource::SHORTCUT1:
                DimensionCode := GeneralLedgerSetup."Global Dimension 1 Code";
            DimensionSource::SHORTCUT2:
                DimensionCode := GeneralLedgerSetup."Global Dimension 2 Code";
            DimensionSource::ANY:
                DimensionCode := CopyStr(JSON.GetStringOrFail('DimensionCode', StrSubstNo(ReadingErr, ActionCode())), 1, MaxStrLen(DimensionCode));
        end;

        CaptionText := DimensionCode;
        if (Dimension.Get(DimensionCode)) then
            CaptionText := Dimension.Name;

        Context.SetContext('CaptionText', CaptionText);

        FrontEnd.SetActionContext(ActionCode(), Context);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        DimensionCode: Code[20];
        DimensionValue: Code[20];
        StrMessage: Text;
        ShowMessage: Boolean;
        WithCreate: Boolean;
        StatisticsFrequency: Integer;
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScopeParameters(ActionCode());

        Randomize();
        StatisticsFrequency := JSON.GetIntegerOrFail('StatisticsFrequency', StrSubstNo(ReadingErr, ActionCode()));
        if (StatisticsFrequency < 1) then
            StatisticsFrequency := 1;
        if (Random(StatisticsFrequency) > 1) then
            exit;

        ValueSelection := JSON.GetIntegerOrFail('ValueSelection', StrSubstNo(ReadingErr, ActionCode()));
        if (ValueSelection = -1) then
            ValueSelection := ValueSelection::LIST;

        DimensionSource := JSON.GetIntegerOrFail('DimensionSource', StrSubstNo(ReadingErr, ActionCode()));
        if (DimensionSource = -1) then
            DimensionSource := DimensionSource::SHORTCUT1;

        ShowMessage := JSON.GetBooleanOrFail('ShowConfirmMessage', StrSubstNo(ReadingErr, ActionCode()));
        WithCreate := JSON.GetBooleanOrFail('CreateDimValue', StrSubstNo(ReadingErr, ActionCode()));

        POSSale.RefreshCurrent();

        case ValueSelection of
            ValueSelection::PROMPT_N:
                StrMessage := SetDimensionValue(JSON, POSSale, DimensionSource, WithCreate, CopyStr(GetNumpad(JSON, 'numeric_input'), 1, MaxStrLen(DimensionValue)));
            ValueSelection::PROMPT_A:
                StrMessage := SetDimensionValue(JSON, POSSale, DimensionSource, WithCreate, CopyStr(GetInput(JSON, 'alpha_input'), 1, MaxStrLen(DimensionValue)));
            ValueSelection::FIXED:
                StrMessage := SetDimensionValue(JSON, POSSale, DimensionSource, WithCreate, CopyStr(GetParamterString(JSON, 'DimensionValue'), 1, MaxStrLen(DimensionValue)));
            ValueSelection::LIST:
                case DimensionSource of
                    DimensionSource::SHORTCUT1:
                        begin
                            SalePOS.LookUpShortcutDimCode(1, DimensionValue);
                            POSSale.SetShortcutDimCode1(DimensionValue);
                        end;
                    DimensionSource::SHORTCUT2:
                        begin
                            SalePOS.LookUpShortcutDimCode(2, DimensionValue);
                            POSSale.SetShortcutDimCode2(DimensionValue);
                        end;
                    DimensionSource::ANY:
                        begin
                            DimensionCode := CopyStr(GetParamterString(JSON, 'DimensionCode'), 1, MaxStrLen(DimensionCode));
                            if DimensionCode = '' then begin
                                SalePOS.ShowDocDim();
                                SalePOS.Modify();
                            end else
                                if LookupDimensionValue(DimensionCode, DimensionValue) then
                                    SetDimensionValue(JSON, POSSale, DimensionSource, WithCreate, DimensionValue);
                        end;
                end;
        end;

        POSSale.RefreshCurrent();

        POSSale.SetModified;
        POSSession.RequestRefreshData();

        if (ShowMessage) and (StrMessage <> '') then
            Message(StrMessage);
    end;

    local procedure LookupDimensionValue(DimensionCode: Code[20]; var DimensionValueCode: Code[20]): Boolean
    var
        DimensionValue: Record "Dimension Value";
    begin
        DimensionValue.FilterGroup(2);
        DimensionValue.SetRange("Dimension Code", DimensionCode);
        DimensionValue.FilterGroup(0);
        if PAGE.RunModal(0, DimensionValue) <> ACTION::LookupOK then
            exit(false);

        DimensionValueCode := DimensionValue.Code;
        exit(true);
    end;

    local procedure SetDimensionValue(JSON: Codeunit "NPR POS JSON Management"; var POSSale: Codeunit "NPR POS Sale"; DimSource: Option; WithCreate: Boolean; DimensionValue: Code[20]) StrMessage: Text
    var
        SalePOS: Record "NPR POS Sale";
        DimensionCode: Code[20];
    begin

        if (WithCreate) then
            CheckCreateDimensionValue(JSON, DimSource, DimensionValue);

        case DimSource of
            DimensionSource::SHORTCUT1:
                begin
                    POSSale.SetShortcutDimCode1(DimensionValue);
                    StrMessage := StrSubstNo(DIMSET, 1, DimensionValue);
                end;
            DimensionSource::SHORTCUT2:
                begin
                    POSSale.SetShortcutDimCode2(DimensionValue);
                    StrMessage := StrSubstNo(DIMSET, 2, DimensionValue);
                end;
            DimensionSource::ANY:
                begin
                    DimensionCode := CopyStr(GetParamterString(JSON, 'DimensionCode'), 1, MaxStrLen(DimensionCode));
                    POSSale.SetDimension(DimensionCode, DimensionValue);
                    StrMessage := StrSubstNo(DIMSET, DimensionCode, DimensionValue);
                end;
        end;
    end;

    local procedure CheckCreateDimensionValue(JSON: Codeunit "NPR POS JSON Management"; DimSource: Option; DimValue: Code[20])
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        DimensionValue: Record "Dimension Value";
        DimCode: Code[20];
    begin

        GeneralLedgerSetup.Get();
        case DimSource of
            DimensionSource::SHORTCUT1:
                DimCode := GeneralLedgerSetup."Global Dimension 1 Code";
            DimensionSource::SHORTCUT2:
                DimCode := GeneralLedgerSetup."Global Dimension 2 Code";
            DimensionSource::ANY:
                DimCode := CopyStr(GetParamterString(JSON, 'DimensionCode'), 1, MaxStrLen(DimCode));
        end;

        if (DimensionValue.Get(DimCode, DimValue)) then
            exit;

        DimensionValue.Init();
        DimensionValue."Dimension Code" := DimCode;
        DimensionValue.Code := DimValue;
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

    local procedure GetParamterString(JSON: Codeunit "NPR POS JSON Management"; Path: Text): Text
    begin
        JSON.SetScopeRoot();
        JSON.SetScopeParameters(ActionCode());
        exit(JSON.GetStringOrFail(Path, StrSubstNo(ReadingErr, ActionCode())));
    end;
}
