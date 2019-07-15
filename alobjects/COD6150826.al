codeunit 6150826 "POS Action - Sale Dimension"
{
    // 
    // NPR5.34/TSA /20170711 CASE 283019 Initial Version
    // NPR5.39/TSA /20180126 CASE 303399 Added ValueSelection parameters numpad and text pad and refactored to minimize code overhead
    // NPR5.39/TSA /20180126 CASE 303399 Added ShowConfirmMessage and WithCreate parameters
    // NPR5.44/MHA /20180702 CASE 320474 Added function LookupDimensionValue()
    // NPR5.44/TSA /20180709 CASE 321303 Added RequestRefreshData
    // NPR5.44/TSA /20180709 CASE 309900 Added StatisticsFrequency parameter to set on when this workflow is configured in the OnBeforePaymentView workflow


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This Action updates the POS Sale Dimension with either a fixed value or provides a list of valid value';
        ValueSelection: Option LIST,"FIXED",PROMPT_N,PROMPT_A;
        DimensionSource: Option SHORTCUT1,SHORTCUT2,ANY;
        DIMCHANGED: Label 'Dimension code %1 changed from %2 to %3.';
        DIMSET: Label 'Dimension code %1 set to %2.';
        TITLE: Label 'Dimension and Statistics';

    local procedure ActionCode(): Text
    begin
        exit ('SALE_DIMENSION');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.4');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        if Sender.DiscoverAction(
          ActionCode(),
          ActionDescription,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple)
        then begin

          //-NPR5.39 [303399]
          Sender.RegisterWorkflowStep ('numeric_input', 'if (param.ValueSelection == 2) {numpad ({title: labels.Title, caption: context.CaptionText, value: ""}).cancel(abort);};');
          Sender.RegisterWorkflowStep ('alpha_input',   'if (param.ValueSelection == 3) {input  ({title: labels.Title, caption: context.CaptionText, value: ""}).cancel(abort);};');

          //+NPR5.39 [303399]
          Sender.RegisterWorkflowStep ('step_1', 'respond();');

          Sender.RegisterOptionParameter ('ValueSelection', 'List,Fixed,Numpad,Textpad', 'List');
          Sender.RegisterOptionParameter ('DimensionSource', 'Shortcut1,Shortcut2,Any', 'Shortcut1');

          Sender.RegisterTextParameter ('DimensionCode', '');
          Sender.RegisterTextParameter ('DimensionValue', '');

          //-NPR5.44 [309900]
          Sender.RegisterIntegerParameter ('StatisticsFrequency', 1);
          //+NPR5.44 [309900]

          Sender.RegisterBooleanParameter ('ShowConfirmMessage', false);
          Sender.RegisterBooleanParameter ('CreateDimValue', false);

          Sender.RegisterWorkflow (true);

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
        Captions.AddActionCaption (ActionCode, 'Title', TITLE);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "POS Action";Parameters: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        Context: Codeunit "POS JSON Management";
        JSON: Codeunit "POS JSON Management";
        DimensionCode: Code[20];
        Dimension: Record Dimension;
        GeneralLedgerSetup: Record "General Ledger Setup";
        CaptionText: Text;
    begin

        if not Action.IsThisAction(ActionCode()) then
          exit;

        JSON.InitializeJObjectParser(Parameters,FrontEnd);
        GeneralLedgerSetup.Get ();

        DimensionSource := JSON.GetInteger('DimensionSource',true);
        case DimensionSource of
          DimensionSource::SHORTCUT1 : DimensionCode := GeneralLedgerSetup."Global Dimension 1 Code";
          DimensionSource::SHORTCUT2 : DimensionCode := GeneralLedgerSetup."Global Dimension 2 Code";
          DimensionSource::ANY : DimensionCode := CopyStr (JSON.GetString ('DimensionCode', true), 1, MaxStrLen (DimensionCode));
        end;

        CaptionText := DimensionCode;
        if (Dimension.Get (DimensionCode)) then
          CaptionText := Dimension.Name;

        Context.SetContext ('CaptionText', CaptionText);

        FrontEnd.SetActionContext (ActionCode, Context);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
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

        POSSession.GetSale (POSSale);
        POSSale.GetCurrentSale (SalePOS);

        JSON.InitializeJObjectParser (Context,FrontEnd);
        JSON.SetScope ('parameters', true);

        //-NPR5.44 [309900]
        Randomize();
        StatisticsFrequency := JSON.GetInteger('StatisticsFrequency',true);
        if (StatisticsFrequency < 1) then
          StatisticsFrequency := 1;
        if (Random (StatisticsFrequency) > 1) then
          exit;
        //+NPR5.44 [309900]


        ValueSelection := JSON.GetInteger('ValueSelection',true);
        if (ValueSelection = -1) then
          ValueSelection := ValueSelection::LIST;

        DimensionSource := JSON.GetInteger('DimensionSource',true);
        if (DimensionSource = -1) then
          DimensionSource := DimensionSource::SHORTCUT1;

        ShowMessage := JSON.GetBoolean ('ShowConfirmMessage', true);
        WithCreate := JSON.GetBoolean ('CreateDimValue', true);

        POSSale.RefreshCurrent ();

        case ValueSelection of
          ValueSelection::PROMPT_N : StrMessage := SetDimensionValue (JSON, POSSale, DimensionSource, WithCreate, CopyStr (GetNumpad (JSON, 'numeric_input'), 1, MaxStrLen (DimensionValue)));
          ValueSelection::PROMPT_A : StrMessage := SetDimensionValue (JSON, POSSale, DimensionSource, WithCreate, CopyStr (GetInput (JSON, 'alpha_input'), 1, MaxStrLen (DimensionValue)));
          ValueSelection::FIXED :    StrMessage := SetDimensionValue (JSON, POSSale, DimensionSource, WithCreate, CopyStr (GetParamterString (JSON, 'DimensionValue'), 1, MaxStrLen (DimensionValue)));
          ValueSelection::LIST :
            case DimensionSource of
              DimensionSource::SHORTCUT1 :
                begin
                  SalePOS.LookUpShortcutDimCode (1, DimensionValue);
                  POSSale.SetShortcutDimCode1 (DimensionValue);
                end;
              DimensionSource::SHORTCUT2 :
                begin
                  SalePOS.LookUpShortcutDimCode (2, DimensionValue);
                  POSSale.SetShortcutDimCode2 (DimensionValue);
                end;
              DimensionSource::ANY :
                begin
                  //-NPR5.44 [320474]
                  //SalePOS.ShowDocDim ();
                  //SalePOS.MODIFY ();
                  DimensionCode := CopyStr(GetParamterString(JSON, 'DimensionCode'),1,MaxStrLen(DimensionCode));
                  if DimensionCode = '' then begin
                    SalePOS.ShowDocDim ();
                    SalePOS.Modify ();
                  end else if LookupDimensionValue(DimensionCode,DimensionValue) then
                    SetDimensionValue(JSON,POSSale,DimensionSource,WithCreate,DimensionValue);
                  //+NPR5.44 [320474]
                end;
            end;
        end;

        POSSale.RefreshCurrent ();

        //-NPR5.44 [321303]
        POSSession.RequestRefreshData ();
        //+NPR5.44 [321303]

        if (ShowMessage) and (StrMessage <> '') then
          Message (StrMessage);
    end;

    local procedure LookupDimensionValue(DimensionCode: Code[20];var DimensionValueCode: Code[20]): Boolean
    var
        DimensionValue: Record "Dimension Value";
    begin
        //-NPR5.44 [320474]
        DimensionValue.FilterGroup(2);
        DimensionValue.SetRange("Dimension Code",DimensionCode);
        DimensionValue.FilterGroup(0);
        if PAGE.RunModal(0,DimensionValue) <> ACTION::LookupOK then
          exit(false);

        DimensionValueCode := DimensionValue.Code;
        exit(true);
        //+NPR5.44 [320474]
    end;

    local procedure SetDimensionValue(JSON: Codeunit "POS JSON Management";var POSSale: Codeunit "POS Sale";DimSource: Option;WithCreate: Boolean;DimensionValue: Code[20]) StrMessage: Text
    var
        SalePOS: Record "Sale POS";
        DimensionCode: Code[20];
        OldValue: Code[20];
    begin

        if (WithCreate) then
          CheckCreateDimensionValue (JSON, DimSource, DimensionValue);

        case DimSource of
          DimensionSource::SHORTCUT1 :
            begin
              OldValue := SalePOS."Shortcut Dimension 1 Code";
              POSSale.SetShortcutDimCode1 (DimensionValue);
              StrMessage := StrSubstNo (DIMSET, 1, DimensionValue);
            end;
          DimensionSource::SHORTCUT2 :
            begin
              OldValue := SalePOS."Shortcut Dimension 2 Code";
              POSSale.SetShortcutDimCode2 (DimensionValue);
              StrMessage := StrSubstNo (DIMSET, 2, DimensionValue);
            end;
          DimensionSource::ANY :
            begin
              DimensionCode := CopyStr (GetParamterString (JSON, 'DimensionCode'), 1, MaxStrLen (DimensionCode));
              POSSale.SetDimension (DimensionCode, DimensionValue);
              StrMessage := StrSubstNo (DIMSET, DimensionCode, DimensionValue);
            end;
        end;
    end;

    local procedure CheckCreateDimensionValue(JSON: Codeunit "POS JSON Management";DimSource: Option;DimValue: Code[20])
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        DimensionValue: Record "Dimension Value";
        DimCode: Code[20];
    begin

        GeneralLedgerSetup.Get ();
        case DimSource of
          DimensionSource::SHORTCUT1 : DimCode := GeneralLedgerSetup."Global Dimension 1 Code";
          DimensionSource::SHORTCUT2 : DimCode := GeneralLedgerSetup."Global Dimension 2 Code";
          DimensionSource::ANY : DimCode := CopyStr (GetParamterString (JSON, 'DimensionCode'), 1, MaxStrLen (DimCode));
        end;

        if (DimensionValue.Get (DimCode, DimValue)) then
          exit;

        DimensionValue.Init;
        DimensionValue."Dimension Code" := DimCode;
        DimensionValue.Code := DimValue;
        DimensionValue."Dimension Value Type" := DimensionValue."Dimension Value Type"::Standard;
        DimensionValue.Insert(true);
    end;

    local procedure GetNumpad(JSON: Codeunit "POS JSON Management";Path: Text): Text
    begin

        if (not JSON.SetScopeRoot (false)) then
          exit ('');

        if (not JSON.SetScope ('$'+Path, false)) then
          exit ('');

        exit (JSON.GetString ('numpad', false));
    end;

    local procedure GetInput(JSON: Codeunit "POS JSON Management";Path: Text): Text
    begin

        if (not JSON.SetScopeRoot (false)) then
          exit ('');

        if (not JSON.SetScope ('$'+Path, false)) then
          exit ('');

        exit (JSON.GetString ('input', false));
    end;

    local procedure GetParamterString(JSON: Codeunit "POS JSON Management";Path: Text): Text
    begin

        JSON.SetScopeRoot (true);
        JSON.SetScope ('parameters', true);
        exit (JSON.GetString (Path, true));
    end;
}

