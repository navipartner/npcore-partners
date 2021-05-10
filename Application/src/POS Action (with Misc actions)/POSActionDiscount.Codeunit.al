codeunit 6150792 "NPR POS Action - Discount"
{
    var
        ActionDescription: Label 'This is a built-in action for handling discount';
        TotalAmountLabel: Label 'Type in the total amount that you want for the whole sales';
        DiscountAmountErr: Label 'Total discount amount entered must be less than the Sale Total!';
        DiscountPercentError: Label 'Discount percentage must be between 0 and 100.';
        LineAmountLabel: Label 'Type in the total amount for the sales line';
        LineDiscountAmountLabel: Label 'Type in the discount amount that you want to give on the current sales line';
        LineDiscountPercentABSLabel: Label 'Type in the discount % that you want to give on the current sales line';
        LineDiscountPercentRELLabel: Label 'Type in the extra discount % that you want to give on the current sales line';
        LineDiscountPercentExtraLabel: Label 'Type in flat extra discount % that you want to give on the current sales line';
        TotalDiscountAmountLabel: Label 'Type in the discount amount that you want to give on the whole sales';
        DiscountPercentABSLabel: Label 'Type in the discount % that you want to give on the whole sales';
        DiscountPercentRELLabel: Label 'Type in the extra discount % that you want to give on the whole sales';
        DiscountPercentExtraLabel: Label 'Type in flat extra discount % that you want to give on the whole sales';
        LineUnitPriceLabel: Label 'Type in the unit price for the current sales line';
        Text000: Label 'Discount Authorisation';
        Text001: Label 'Salesperson Password';
        Text002: Label 'Current Salesperson Password';
        Text003: Label 'Supervisor Password';
        Text004: Label 'Invalid Password';
        Text005: Label 'Unit Price may not be changed when Line Type is %1';
        NegativeAmtErr: Label 'Negative amount is not allowed. Please specify a positive figure.';
        WrongDimensionValueErr: Label 'The dimension value %1 has not been set up for dimension %2.';
        InputIncludesTax: Option Always,IfPricesInclTax,Never;
        MultiLineDiscTarget: Option " ","Positive Only","Negative Only","Non-Zero";
        SelectDiscountTargetLbl: Label 'Please select discount target lines:';
        DiscTargetAllOptionLbl: Label 'All non-zero quantity lines';
        DiscTargetOtherOptionsLbl: Label 'Positive quantity lines only,Negative quantity lines only';
        DiscountGroupFilter: Text;
        NoDiscTargetFound: Label 'System couldn''t find lines the discount to be applied to.\The POS action is preset for discounts to be applied to %1.';
        AddDimensionCode: Code[20];
        AddDimensionValueCode: Code[20];
        ApprovedBySalespersonCode: Code[20];
        DiscountReasonCode: Code[10];
        ReadingErr: Label 'reading in %1 of %2';

    local procedure ActionCode(): Text
    begin
        exit('DISCOUNT');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.7');
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
            Sender.RegisterWorkflowStep('SalespersonPassword',
              'if(param.Security == 1) {passwordpad({title: labels.DiscountAuthorisationTitle,caption: labels.SalespersonPasswordLabel,notBlank: true}).respond("SalespersonPassword").cancel(abort);}');
            Sender.RegisterWorkflowStep('CurrentSalespersonPassword',
              'if(param.Security == 2) {passwordpad({title: labels.DiscountAuthorisationTitle,caption: labels.CurrentSalespersonPasswordLabel,notBlank: true}).respond("CurrentSalespersonPassword").cancel(abort);}');
            Sender.RegisterWorkflowStep('SupervisorPassword',
              'if(param.Security == 3) {passwordpad({title: labels.DiscountAuthorisationTitle,caption: labels.SupervisorPasswordLabel,notBlank: true}).respond("SupervisorPassword").cancel(abort);}');
            Sender.RegisterWorkflowStep('FixedReasonCode', 'if (param.FixedReasonCode != "")  {respond()}');
            Sender.RegisterWorkflowStep('LookupReasonCode', 'if ((param.LookupReasonCode) || (param.ReasonCodeMandatory) && (!context.discountReasonCode)) {respond()}');
            Sender.RegisterWorkflowStep('AddDimensionValue', 'respond();');
            Sender.RegisterWorkflowStep('fixed_input', 'if (param.FixedDiscountNumber != 0) { context.quantity = param.FixedDiscountNumber; }');
            Sender.RegisterWorkflowStep('discount_input',
              'switch(param.DiscountType + "") {' +
              '  case "0":' +
              '  case "1":' +
              '  case "2":' +
              '  case "3":' +
              '  case "4":' +
              '  case "5":' +
              '  case "6":' +
              '  case "7":' +
              '  case "8":' +
              '  case "11":' +
              '  case "12":' +
              '    if (param.FixedDiscountNumber == 0){' +
              '      numpad(labels["DiscountLabel" + param.DiscountType]).respond("quantity");' +
              '    } else {' +
              '      context.quantity = param.FixedDiscountNumber;' +
              '      respond("quantity");' +
              '    }' +
              '    break;' +
              '  default:' +
              '    context.quantity = param.FixedDiscountNumber;' +
              '    respond("quantity");' +
              '}');

            Sender.RegisterOptionParameter('Security', 'None,SalespersonPassword,CurrentSalespersonPassword,SupervisorPassword', 'None');
            Sender.RegisterOptionParameter('DiscountType',
              'TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,' +
              'LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra',
              'TotalDiscountAmount');
            Sender.RegisterDecimalParameter('FixedDiscountNumber', 0);
            Sender.RegisterTextParameter('FixedReasonCode', '');
            Sender.RegisterBooleanParameter('LookupReasonCode', false);
            Sender.RegisterBooleanParameter('ReasonCodeMandatory', false);
            Sender.RegisterTextParameter('DimensionCode', '');
            Sender.RegisterTextParameter('DimensionValue', '');
            Sender.RegisterTextParameter('DiscountGroupFilter', '');
            Sender.RegisterOptionParameter('TotalDiscTargetLines', 'Auto,Positive,Negative,All,Ask', 'Positive');
            Sender.RegisterOptionParameter('AmtIncludesTax', 'Always,IfPricesInclTax,Never', 'Always');
            Sender.RegisterDataBinding();
            Sender.RegisterWorkflow(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnBeforeWorkflow', '', false, false)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'DiscountLabel0', TotalAmountLabel);
        Captions.AddActionCaption(ActionCode(), 'DiscountLabel1', TotalDiscountAmountLabel);
        Captions.AddActionCaption(ActionCode(), 'DiscountLabel2', DiscountPercentABSLabel);
        Captions.AddActionCaption(ActionCode(), 'DiscountLabel3', DiscountPercentRELLabel);
        Captions.AddActionCaption(ActionCode(), 'DiscountLabel4', LineAmountLabel);
        Captions.AddActionCaption(ActionCode(), 'DiscountLabel5', LineDiscountAmountLabel);
        Captions.AddActionCaption(ActionCode(), 'DiscountLabel6', LineDiscountPercentABSLabel);
        Captions.AddActionCaption(ActionCode(), 'DiscountLabel7', LineDiscountPercentRELLabel);
        Captions.AddActionCaption(ActionCode(), 'DiscountLabel8', LineUnitPriceLabel);
        Captions.AddActionCaption(ActionCode(), 'DiscountLabel11', DiscountPercentExtraLabel);
        Captions.AddActionCaption(ActionCode(), 'DiscountLabel12', LineDiscountPercentExtraLabel);
        Captions.AddActionCaption(ActionCode(), 'DiscountAuthorisationTitle', Text000);
        Captions.AddActionCaption(ActionCode(), 'SalespersonPasswordLabel', Text001);
        Captions.AddActionCaption(ActionCode(), 'CurrentSalespersonPasswordLabel', Text002);
        Captions.AddActionCaption(ActionCode(), 'SupervisorPasswordLabel', Text003);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        InputValue: Decimal;
        POSSale: Codeunit "NPR POS Sale";
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        View: Codeunit "NPR POS View";
        TotalPrice: Decimal;
        PresetMultiLineDiscTarget: Integer;
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        case WorkflowStep of
            'SalespersonPassword':
                begin
                    Handled := true;
                    OnActionSalespersonPassword(JSON, POSSession, FrontEnd);
                    exit;
                end;
            'CurrentSalespersonPassword':
                begin
                    Handled := true;
                    OnActionCurrentSalespersonPassword(JSON, POSSession, FrontEnd);
                    exit;
                end;
            'SupervisorPassword':
                begin
                    Handled := true;
                    OnActionSupervisorPassword(JSON, POSSession, FrontEnd);
                    exit;
                end;
            'FixedReasonCode':
                begin
                    Handled := true;
                    OnActionFixedReasonCode(JSON, POSSession, FrontEnd);
                    exit;
                end;
            'LookupReasonCode':
                begin
                    Handled := true;
                    OnActionLookupReasonCode(JSON, POSSession, FrontEnd);
                    exit;
                end;
            'AddDimensionValue':
                begin
                    Handled := true;
                    OnActionAddDimensionValue(JSON, POSSession, FrontEnd);
                    exit;
                end;
        end;
        InputValue := JSON.GetDecimalOrFail('quantity', StrSubstNo(ReadingErr, 'OnAction', ActionCode()));
        JSON.SetScopeParameters(ActionCode());
        DiscountType := JSON.GetIntegerOrFail('DiscountType', StrSubstNo(ReadingErr, 'OnAction', ActionCode()));
        PresetMultiLineDiscTarget := JSON.GetIntegerParameter('TotalDiscTargetLines');
        DiscountGroupFilter := JSON.GetStringParameterOrFail('DiscountGroupFilter', ActionCode());
        InputIncludesTax := JSON.GetIntegerParameter('AmtIncludesTax');

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        POSSaleLine.RefreshxRec();
        POSSession.GetCurrentView(View);

        if (InputValue < 0) and
           (DiscountType in
            [DiscountType::TotalAmount,
             DiscountType::TotalDiscountAmount,
             DiscountType::LineAmount,
             DiscountType::LineDiscountAmount])
        then
            Error(NegativeAmtErr);

        if DiscountType in
           [DiscountType::TotalAmount,
            DiscountType::TotalDiscountAmount,
            DiscountType::DiscountPercentABS,
            DiscountType::DiscountPercentREL,
            DiscountType::DiscountPercentExtra,
            DiscountType::ClearTotalDiscount]
        then
            GetMultiLineDiscountTarget(
              SalePOS, SaleLinePOS,
              PresetMultiLineDiscTarget,
              not (DiscountType in [DiscountType::TotalAmount, DiscountType::TotalDiscountAmount]));

        case DiscountType of
            DiscountType::TotalAmount,
            DiscountType::TotalDiscountAmount,
            DiscountType::LineAmount,
            DiscountType::LineDiscountAmount:
                begin
                    if DiscountType in [DiscountType::TotalAmount, DiscountType::TotalDiscountAmount] then
                        TotalPrice := GetLinesTotalDiscountableValue(SalePOS)
                    else
                        TotalPrice := GetSingleLineTotalDiscountableValue(SaleLinePOS, false);
                    if (TotalPrice < InputValue) then
                        Error(DiscountAmountErr);
                end;

            DiscountType::DiscountPercentABS,
            DiscountType::DiscountPercentREL,
            DiscountType::LineDiscountPercentABS,
            DiscountType::LineDiscountPercentREL,
            DiscountType::DiscountPercentExtra,
            DiscountType::LineDiscountPercentExtra:
                begin
                    if (InputValue < 0) or (InputValue > 100) then
                        Error(DiscountPercentError);
                end;
        end;

        GetAdditionalParams(JSON);

        case DiscountType of
            DiscountType::TotalAmount:
                SetTotalAmount(SalePOS, InputValue);
            DiscountType::TotalDiscountAmount:
                SetTotalDiscountAmount(SalePOS, InputValue);
            DiscountType::DiscountPercentABS:
                SetDiscountPctABS(SalePOS, InputValue);
            DiscountType::DiscountPercentREL:
                SetDiscountPctREL(SalePOS, InputValue);
            DiscountType::LineAmount:
                SetLineAmount(SaleLinePOS, InputValue);
            DiscountType::LineDiscountAmount:
                SetLineDiscountAmount(SaleLinePOS, InputValue);
            DiscountType::LineDiscountPercentABS:
                SetLineDiscountPctABS(SaleLinePOS, InputValue);
            DiscountType::LineDiscountPercentREL:
                SetLineDiscountPctREL(SaleLinePOS, InputValue);
            DiscountType::LineUnitPrice:
                SetLineUnitPrice(SaleLinePOS, InputValue);
            DiscountType::ClearLineDiscount:
                SetLineDiscountAmount(SaleLinePOS, 0);
            DiscountType::ClearTotalDiscount:
                SetTotalDiscountAmount(SalePOS, 0);
            DiscountType::DiscountPercentExtra:
                SetDiscountPctExtra(SalePOS, InputValue);
            DiscountType::LineDiscountPercentExtra:
                SetLineDiscountPctExtra(SaleLinePOS, InputValue);
        end;

        POSSaleLine.RefreshCurrent();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        POSSaleLine.OnAfterSetQuantity(SaleLinePOS);
        POSSession.RequestRefreshData();

        Handled := true;
    end;

    local procedure OnActionSalespersonPassword(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Salesperson: Record "Salesperson/Purchaser";
        SalespersonPassword: Text;
    begin
        SalespersonPassword := JSON.GetStringOrFail('SalespersonPassword', StrSubstNo(ReadingErr, 'OnActionSalespersonPassword', ActionCode()));
        Salesperson.SetRange("NPR Register Password", SalespersonPassword);
        if not Salesperson.FindFirst() then
            Error(Text004);

        JSON.SetContext('approvedBySalesperson', Salesperson.Code);
        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure OnActionCurrentSalespersonPassword(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Salesperson: Record "Salesperson/Purchaser";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        SalespersonPassword: Text;
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalespersonPassword := JSON.GetStringOrFail('CurrentSalespersonPassword', StrSubstNo(ReadingErr, 'OnActionCurrentSalespersonPassword', ActionCode()));

        Salesperson.SetRange(Code, SalePOS."Salesperson Code");
        Salesperson.SetRange("NPR Register Password", SalespersonPassword);
        if not Salesperson.FindFirst() then
            Error(Text004);

        JSON.SetContext('approvedBySalesperson', Salesperson.Code);
        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure OnActionSupervisorPassword(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Salesperson: Record "Salesperson/Purchaser";
        SupervisorPassword: Text;
    begin
        SupervisorPassword := JSON.GetStringOrFail('SupervisorPassword', StrSubstNo(ReadingErr, 'OnActionSupervisorPassword', ActionCode()));
        Salesperson.SetRange("NPR Register Password", SupervisorPassword);
        Salesperson.SetRange("NPR Supervisor POS", true);
        if not Salesperson.FindFirst() then
            Error(Text004);

        JSON.SetContext('approvedBySalesperson', Salesperson.Code);
        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure OnActionFixedReasonCode(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        ReasonCode: Code[10];
    begin
        JSON.SetScopeParameters(ActionCode());
        ReasonCode := JSON.GetStringOrFail('FixedReasonCode', StrSubstNo(ReadingErr, 'OnActionFixedReasonCode', ActionCode()));
        if ReasonCode = '' then
            exit;

        JSON.SetContext('discountReasonCode', ReasonCode);
        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure OnActionLookupReasonCode(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        ReasonCode: Record "Reason Code";
        ReasonCodeMandatoryErr: Label 'Reason Code is mandatory for this discount';
    begin
        if PAGE.RunModal(0, ReasonCode) <> ACTION::LookupOK then begin
            if JSON.GetBooleanParameter('ReasonCodeMandatory') then
                Error(ReasonCodeMandatoryErr);
            exit;
        end;

        JSON.SetContext('discountReasonCode', ReasonCode.Code);
        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure OnActionAddDimensionValue(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        DimensionValue: Record "Dimension Value";
        DimensionCodeParameter: Text;
        DimensionValueParameter: Text;
    begin
        JSON.SetScopeParameters(ActionCode());
        DimensionCodeParameter := JSON.GetStringParameterOrFail('DimensionCode', ActionCode());
        if DimensionCodeParameter = '' then
            exit;

        DimensionValueParameter := JSON.GetStringParameterOrFail('DimensionValue', ActionCode());
        if DimensionValueParameter = '' then begin
            DimensionValue.SetRange("Dimension Code", DimensionCodeParameter);
            if PAGE.RunModal(0, DimensionValue) <> ACTION::LookupOK then
                exit;
            DimensionValueParameter := DimensionValue.Code;
        end;

        JSON.SetContext('addDimensionCode', DimensionCodeParameter);
        JSON.SetContext('addDimensionValueCode', DimensionValueParameter);
        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterNameCaption', '', true, false)]
    local procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    var
        CaptionAmtIncludesTax: Label 'Amount Incl. VAT/Tax';
        CaptionFixedReasonCode: Label 'Reason: Fixed Code';
        CaptionLookupReasonCode: Label 'Reason: Lookup';
        CaptionReasonCodeMandatory: Label 'Reason: Mandatory';
        CaptionTotalDiscTargetLines: Label 'Total Discount Target';
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'TotalDiscTargetLines':
                Caption := CaptionTotalDiscTargetLines;
            'FixedReasonCode':
                Caption := CaptionFixedReasonCode;
            'LookupReasonCode':
                Caption := CaptionLookupReasonCode;
            'ReasonCodeMandatory':
                Caption := CaptionReasonCodeMandatory;
            'AmtIncludesTax':
                Caption := CaptionAmtIncludesTax;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterDescriptionCaption', '', true, false)]
    local procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    var
        DescAmtIncludesTax: Label 'Specifies whether amount entered is VAT/tax inclusive. The parameter is ignored if DiscountType is set to "LineUnitPrice"';
        DescFixedReasonCode: Label 'Select a reason code, which will be assigned automatically to sale lines';
        DescLookupReasonCode: Label 'Ask user to select a reason code, when the action is run';
        DescReasonCodeMandatory: Label 'Defines whether a reason code must be selected in order for the discount to be successfully applied to sale lines';
        DescTotalDiscTargetLines: Label 'Select target lines multi-line discounts to be applied to';
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'TotalDiscTargetLines':
                Caption := DescTotalDiscTargetLines;
            'FixedReasonCode':
                Caption := DescFixedReasonCode;
            'LookupReasonCode':
                Caption := DescLookupReasonCode;
            'ReasonCodeMandatory':
                Caption := DescReasonCodeMandatory;
            'AmtIncludesTax':
                Caption := DescAmtIncludesTax;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterOptionStringCaption', '', true, false)]
    local procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    var
        OptionAmtIncludesTax: Label 'Always,If prices incl. VAT/tax,Never';
        OptionTotalDiscTargetLines: Label 'Auto,Positive quantity lines only,Negative quantity lines only,All non-zero quantity lines,Ask';
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'TotalDiscTargetLines':
                Caption := OptionTotalDiscTargetLines;
            'AmtIncludesTax':
                Caption := OptionAmtIncludesTax;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        Reason: Record "Reason Code";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'FixedReasonCode':
                begin
                    if PAGE.RunModal(0, Reason) = ACTION::LookupOK then
                        POSParameterValue.Value := Reason.Code;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', false, false)]
    local procedure OnValidateValue(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        Reason: Record "Reason Code";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'FixedReasonCode':
                begin
                    if POSParameterValue.Value = '' then
                        exit;
                    Reason.Code := CopyStr(POSParameterValue.Value, 1, MaxStrLen(Reason.Code));
                    Reason.Find();
                end;
        end;
    end;

    #region Locals

    local procedure ApplyDiscountOnLines(var SalePOS: Record "NPR POS Sale"; DiscountType: Option DiscountAmt,DiscountPct,LineAmt; Discount: Decimal)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        ApplyFilterOnLines(SalePOS, SaleLinePOS);
        if not SaleLinePOS.FindSet() then
            exit;

        repeat
            ApplyDiscountOnLine(SaleLinePOS, DiscountType, Discount);
        until SaleLinePOS.Next() = 0;
    end;

    local procedure ApplyDiscountOnLine(var SaleLinePOS: Record "NPR POS Sale Line"; DiscountType: Option DiscountAmt,DiscountPct,LineAmt; InputValue: Decimal)
    var
        PrevRec: Text;
    begin
        if SaleLinePOS."Custom Disc Blocked" then
            exit;
        if DiscountType in [DiscountType::DiscountAmt, DiscountType::LineAmt] then begin
            InputValue := InputValue * GetSignFactor(SaleLinePOS);
            AdjustAmountForVat(SaleLinePOS, InputValue);
        end;

        PrevRec := Format(SaleLinePOS);

        SaleLinePOS."Discount Type" := SaleLinePOS."Discount Type"::" ";
        SaleLinePOS."Discount Code" := '';
        if InputValue <> 0 then
            SaleLinePOS."Discount Type" := SaleLinePOS."Discount Type"::Manual;

        case DiscountType of
            DiscountType::DiscountAmt:
                begin
                    SaleLinePOS."Discount %" := 0;
                    SaleLinePOS."Discount Amount" := InputValue;
                end;
            DiscountType::DiscountPct:
                begin
                    if InputValue < 0 then
                        InputValue := 0;
                    if InputValue > 100 then
                        InputValue := 100;
                    SaleLinePOS."Discount %" := InputValue;
                    SaleLinePOS."Discount Amount" := 0;
                end;
            DiscountType::LineAmt:
                begin
                    SaleLinePOS."Discount %" := 0;
                    SaleLinePOS."Discount Amount" := SaleLinePOS."Unit Price" * SaleLinePOS.Quantity - InputValue;
                end;
        end;

        ApplyAdditionalParams(SaleLinePOS);
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        if PrevRec <> Format(SaleLinePOS) then
            SaleLinePOS.Modify();

        // Recalculate VAT Difference rounding error distribution on all lines
        UpdateSalesVAT(SaleLinePOS."Orig. POS Sale ID");
    end;

    local procedure ApplyFilterOnLines(var SalePOS: Record "NPR POS Sale"; var SaleLinePOS: Record "NPR POS Sale Line")
    var
        UnexpectedFilterType: Label 'Unexpected quantity type filter. This is a critical programming error. Please contact system vendor.';
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Sale);
        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Item);
        case MultiLineDiscTarget of
            MultiLineDiscTarget::" ":
                Error(UnexpectedFilterType);
            MultiLineDiscTarget::"Non-Zero":
                SaleLinePOS.SetFilter(Quantity, '<>%1', 0);
            MultiLineDiscTarget::"Negative Only":
                SaleLinePOS.SetFilter(Quantity, '<%1', 0);
            MultiLineDiscTarget::"Positive Only":
                SaleLinePOS.SetFilter(Quantity, '>%1', 0);
        end;
        SaleLinePOS.SetRange("Custom Disc Blocked", false);

        if DiscountGroupFilter > '' then
            SaleLinePOS.SetFilter("Item Disc. Group", DiscountGroupFilter);
    end;

    local procedure GetLinesTotalDiscountableValue(var SalePOS: Record "NPR POS Sale") TotalLineValue: Decimal
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        ApplyFilterOnLines(SalePOS, SaleLinePOS);

        if SaleLinePOS.FindSet() then
            repeat
                TotalLineValue += GetSingleLineTotalDiscountableValue(SaleLinePOS, false);
            until SaleLinePOS.Next() = 0;

    end;

    local procedure GetSingleLineTotalDiscountableValue(SaleLinePOS: Record "NPR POS Sale Line"; IncludeDiscount: Boolean) LineValue: Decimal
    begin
        if not IncludeDiscount then
            SaleLinePOS."Discount Amount" := 0;

        if not SaleLinePOS."Custom Disc Blocked" then
            LineValue := SaleLinePOS.Quantity * SaleLinePOS."Unit Price" - SaleLinePOS."Discount Amount"
        else begin
            if SaleLinePOS."Price Includes VAT" then
                LineValue := SaleLinePOS."Amount Including VAT"
            else
                LineValue := SaleLinePOS.Amount;
        end;

        if SaleLinePOS."Price Includes VAT" and (InputIncludesTax = InputIncludesTax::Never) then
            LineValue := Round(LineValue / (1 + SaleLinePOS."VAT %" / 100))
        else
            if not SaleLinePOS."Price Includes VAT" and (InputIncludesTax = InputIncludesTax::Always) then
                LineValue := Round(LineValue * (1 + SaleLinePOS."VAT %" / 100));

        if SaleLinePOS.Quantity < 0 then
            LineValue := -LineValue;
    end;

    local procedure SetTotalDiscountAmount(var SalePOS: Record "NPR POS Sale"; TotalDiscountAmount: Decimal)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        TotalPrice: Decimal;
        DiscountPct: Decimal;
    begin
        ApplyFilterOnLines(SalePOS, SaleLinePOS);

        TotalPrice := GetLinesTotalDiscountableValue(SalePOS);
        DiscountPct := TotalDiscountAmount / TotalPrice * 100;

        ApplyDiscountOnLines(SalePOS, "DiscType.DiscountPct"(), DiscountPct);

        AdjustRoundingForTotalAmountDiscount(SalePOS, (TotalPrice - TotalDiscountAmount));
    end;

    local procedure SetTotalAmount(var SalePOS: Record "NPR POS Sale"; Amount: Decimal)
    var
        t001: Label 'Total Amount entered must be less than the Sale Total!';
        DiscountPct: Decimal;
        TotalPrice: Decimal;
    begin
        TotalPrice := GetLinesTotalDiscountableValue(SalePOS);
        DiscountPct := (TotalPrice - Amount) / TotalPrice * 100;
        if DiscountPct < 0 then
            Error(t001);

        ApplyDiscountOnLines(SalePOS, "DiscType.DiscountPct"(), DiscountPct);

        AdjustRoundingForTotalAmountDiscount(SalePOS, Amount);
    end;

    local procedure SetDiscountPctABS(SalePOS: Record "NPR POS Sale"; DiscountPct: Decimal)
    begin
        ApplyDiscountOnLines(SalePOS, "DiscType.DiscountPct"(), DiscountPct);
    end;

    local procedure SetDiscountPctREL(SalePOS: Record "NPR POS Sale"; DiscountPct: Decimal)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        RelativeDiscountPct: Decimal;
    begin
        ApplyFilterOnLines(SalePOS, SaleLinePOS);
        if not SaleLinePOS.FindSet() then
            exit;

        repeat
            RelativeDiscountPct := (1 - (1 - SaleLinePOS."Discount %" / 100) * (1 - DiscountPct / 100)) * 100;
            ApplyDiscountOnLine(SaleLinePOS, "DiscType.DiscountPct"(), RelativeDiscountPct);
        until SaleLinePOS.Next() = 0;
    end;

    local procedure SetDiscountPctExtra(SalePOS: Record "NPR POS Sale"; ExtraDiscountPct: Decimal)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        NewDiscountPct: Decimal;
    begin
        ApplyFilterOnLines(SalePOS, SaleLinePOS);
        if not SaleLinePOS.FindSet() then
            exit;

        repeat
            NewDiscountPct := SaleLinePOS."Discount %" + ExtraDiscountPct;
            ApplyDiscountOnLine(SaleLinePOS, "DiscType.DiscountPct"(), NewDiscountPct);
        until SaleLinePOS.Next() = 0;
    end;

    procedure SetLineAmount(var SaleLinePOS: Record "NPR POS Sale Line"; LineAmount: Decimal)
    begin
        ApplyDiscountOnLine(SaleLinePOS, "DiscType.LineAmt"(), LineAmount);
    end;

    local procedure SetLineDiscountAmount(var SaleLinePOS: Record "NPR POS Sale Line"; DiscountAmount: Decimal)
    begin
        ApplyDiscountOnLine(SaleLinePOS, "DiscType.DiscountAmt"(), DiscountAmount);
    end;

    procedure SetLineDiscountPctABS(var SaleLinePOS: Record "NPR POS Sale Line"; DiscountPct: Decimal)
    begin
        ApplyDiscountOnLine(SaleLinePOS, "DiscType.DiscountPct"(), DiscountPct);
    end;

    local procedure SetLineDiscountPctREL(var SaleLinePOS: Record "NPR POS Sale Line"; DiscountPct: Decimal)
    var
        RelativeDiscountPct: Decimal;
    begin
        RelativeDiscountPct := (1 - (1 - SaleLinePOS."Discount %" / 100) * (1 - DiscountPct / 100)) * 100;
        ApplyDiscountOnLine(SaleLinePOS, "DiscType.DiscountPct"(), RelativeDiscountPct);
    end;

    local procedure SetLineDiscountPctExtra(var SaleLinePOS: Record "NPR POS Sale Line"; ExtraDiscountPct: Decimal)
    var
        NewDiscountPct: Decimal;
    begin
        NewDiscountPct := SaleLinePOS."Discount %" + ExtraDiscountPct;
        ApplyDiscountOnLine(SaleLinePOS, "DiscType.DiscountPct"(), NewDiscountPct);
    end;

    local procedure SetLineUnitPrice(var SaleLinePOS: Record "NPR POS Sale Line"; UnitPrice: Decimal)
    var
        PrevRec: Text;
    begin
        if not (SaleLinePOS."Sale Type" in [SaleLinePOS."Sale Type"::Sale, SaleLinePOS."Sale Type"::"Debit Sale"]) then
            Error(Text005, SaleLinePOS."Sale Type");
        if SaleLinePOS.Type = SaleLinePOS.Type::Comment then
            Error(Text005, SaleLinePOS.Type);
        PrevRec := Format(SaleLinePOS);

        SaleLinePOS."Unit Price" := UnitPrice;
        SaleLinePOS."Custom Price" := true;
        ApplyAdditionalParams(SaleLinePOS);
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        if PrevRec <> Format(SaleLinePOS) then
            SaleLinePOS.Modify();

        // Recalculate VAT Difference rounding error distribution on all lines
        UpdateSalesVAT(SaleLinePOS."Orig. POS Sale ID");
    end;

    local procedure AdjustAmountForVat(SaleLinePOS: Record "NPR POS Sale Line"; var UserInputAmount: Decimal)
    begin
        if (InputIncludesTax = InputIncludesTax::IfPricesInclTax) or
           (SaleLinePOS."VAT %" = 0)
        then
            exit;

        if SaleLinePOS."Price Includes VAT" and (InputIncludesTax = InputIncludesTax::Never) then
            UserInputAmount := Round(UserInputAmount * (1 + SaleLinePOS."VAT %" / 100))
        else
            if not SaleLinePOS."Price Includes VAT" and (InputIncludesTax = InputIncludesTax::Always) then
                UserInputAmount := Round(UserInputAmount / (1 + SaleLinePOS."VAT %" / 100));
    end;

    local procedure AdjustRoundingForTotalAmountDiscount(var SalePOS: Record "NPR POS Sale"; Amount: Decimal)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        TotalLineValue: Decimal;
    begin
        ApplyFilterOnLines(SalePOS, SaleLinePOS);
        if (SaleLinePOS.FindSet()) then begin
            repeat
                TotalLineValue += GetSingleLineTotalDiscountableValue(SaleLinePOS, true);
            until (SaleLinePOS.Next() = 0);

            if (TotalLineValue <> Amount) then
                SetLineDiscountAmount(SaleLinePOS, SaleLinePOS."Discount Amount" * GetSignFactor(SaleLinePOS) + (TotalLineValue - Amount));
        end;
    end;

    local procedure AddDimensionToDimensionSet(var SaleLinePOS: Record "NPR POS Sale Line"; DimensionCode: Code[20]; DimensionValueCode: Code[20])
    var
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        DimensionManagement: Codeunit DimensionManagement;
    begin
        DimensionManagement.GetDimensionSet(TempDimensionSetEntry, SaleLinePOS."Dimension Set ID");
        ValidateDimValue(DimensionCode, DimensionValueCode);
        UpdateDimensionSet(TempDimensionSetEntry, DimensionCode, DimensionValueCode);

        SaleLinePOS."Dimension Set ID" := DimensionManagement.GetDimensionSetID(TempDimensionSetEntry);
        DimensionManagement.UpdateGlobalDimFromDimSetID(SaleLinePOS."Dimension Set ID", SaleLinePOS."Shortcut Dimension 1 Code", SaleLinePOS."Shortcut Dimension 2 Code");
    end;

    local procedure UpdateDimensionSet(var DimensionSetEntry: Record "Dimension Set Entry"; DimensionCode: Code[20]; DimensionValueCode: Code[20])
    var
        DimensionValue: Record "Dimension Value";
    begin
        if DimensionSetEntry.Get(DimensionSetEntry."Dimension Set ID", DimensionCode) then begin
            if not ((DimensionSetEntry."Dimension Value Code" <> DimensionValueCode) or (DimensionValueCode = '')) then
                exit;

            DimensionSetEntry.Delete();
        end;

        if DimensionValueCode <> '' then begin
            DimensionValue.Get(DimensionCode, DimensionValueCode);

            DimensionSetEntry."Dimension Set ID" := DimensionSetEntry."Dimension Set ID";
            DimensionSetEntry."Dimension Code" := DimensionCode;
            DimensionSetEntry."Dimension Value Code" := DimensionValueCode;
            DimensionSetEntry."Dimension Value ID" := DimensionValue."Dimension Value ID";

            DimensionSetEntry.Insert();
        end;
    end;

    local procedure ValidateDimValue(DimCode: Code[20]; var DimValueCode: Code[20]): Boolean
    var
        DimValue: Record "Dimension Value";
    begin
        if DimValueCode = '' then
            exit;

        DimValue."Dimension Code" := DimCode;
        DimValue.Code := DimValueCode;
        DimValue.Find('=><');
        if DimValueCode <> CopyStr(DimValue.Code, 1, StrLen(DimValueCode)) then
            Error(WrongDimensionValueErr, DimValueCode, DimCode);
        DimValueCode := DimValue.Code;
    end;

    local procedure GetMultiLineDiscountTarget(SalePOS: Record "NPR POS Sale"; SaleLinePOS: Record "NPR POS Sale Line"; PresetMultiLineDiscTarget: Option Auto,"Positive Only","Negative Only",All,Ask; AllowAllLines: Boolean)
    var
        DefaultOptionNo: Integer;
        NoOfNegativeLines: Integer;
        NoOfPositiveLines: Integer;
        SelectedOptionNo: Integer;
        RequestMsgTxt: Text;
    begin
        if PresetMultiLineDiscTarget = PresetMultiLineDiscTarget::All then begin
            MultiLineDiscTarget := MultiLineDiscTarget::"Non-Zero";
            exit;
        end;

        MultiLineDiscTarget := MultiLineDiscTarget::"Positive Only";
        ApplyFilterOnLines(SalePOS, SaleLinePOS);
        NoOfPositiveLines := SaleLinePOS.Count();

        MultiLineDiscTarget := MultiLineDiscTarget::"Negative Only";
        ApplyFilterOnLines(SalePOS, SaleLinePOS);
        NoOfNegativeLines := SaleLinePOS.Count();

        if PresetMultiLineDiscTarget in [PresetMultiLineDiscTarget::"Positive Only", PresetMultiLineDiscTarget::"Negative Only"] then begin
            MultiLineDiscTarget := PresetMultiLineDiscTarget;
            if ((MultiLineDiscTarget = MultiLineDiscTarget::"Positive Only") and (NoOfPositiveLines = 0)) or
               ((MultiLineDiscTarget = MultiLineDiscTarget::"Negative Only") and (NoOfNegativeLines = 0))
            then
                Error(NoDiscTargetFound, LowerCase(SelectStr(MultiLineDiscTarget, DiscTargetOtherOptionsLbl)));
            exit;
        end;

        case true of
            (NoOfNegativeLines = 0) and (NoOfPositiveLines = 0):
                MultiLineDiscTarget := MultiLineDiscTarget::"Non-Zero";

            (NoOfNegativeLines <> 0) xor (NoOfPositiveLines <> 0):
                if NoOfPositiveLines <> 0 then
                    MultiLineDiscTarget := MultiLineDiscTarget::"Positive Only"
                else
                    MultiLineDiscTarget := MultiLineDiscTarget::"Negative Only";

            PresetMultiLineDiscTarget = PresetMultiLineDiscTarget::Auto:
                if SaleLinePOS.Quantity >= 0 then
                    MultiLineDiscTarget := MultiLineDiscTarget::"Positive Only"
                else
                    MultiLineDiscTarget := MultiLineDiscTarget::"Negative Only";

            else begin
                    RequestMsgTxt := DiscTargetOtherOptionsLbl;
                    if AllowAllLines then
                        RequestMsgTxt := RequestMsgTxt + ',' + DiscTargetAllOptionLbl;
                    if SaleLinePOS.Quantity >= 0 then
                        DefaultOptionNo := 1
                    else
                        DefaultOptionNo := 2;
                    SelectedOptionNo := StrMenu(RequestMsgTxt, DefaultOptionNo, SelectDiscountTargetLbl);
                    if SelectedOptionNo = 0 then
                        Error('');
                    MultiLineDiscTarget := SelectedOptionNo;
                end;
        end;
    end;

    local procedure GetSignFactor(SaleLinePOS: Record "NPR POS Sale Line"): Integer
    begin
        if SaleLinePOS.Quantity < 0 then
            exit(-1);
        exit(1);
    end;

    local procedure UpdateSalesVAT(POSSaleID: Integer)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        if (not SaleLinePOS.SetCurrentKey("Orig. POS Sale ID")) then;

        SaleLinePOS.SetFilter("Orig. POS Sale ID", '=%1', POSSaleID);
        SaleLinePOS.SetFilter("Sale Type", '%1|%2', SaleLinePOS."Sale Type"::Sale, SaleLinePOS."Sale Type"::"Debit Sale");
        SaleLinePOS.SetFilter(Type, '<>%1', SaleLinePOS.type::Comment);
        if (SaleLinePOS.FindSet()) then begin
            repeat
                SaleLinePOS.UpdateAmounts(SaleLinePOS);
                SaleLinePOS.Modify();
            until (SaleLinePOS.Next() = 0);
        end;
    end;

    local procedure GetAdditionalParams(JSON: Codeunit "NPR POS JSON Management")
    begin
        JSON.SetScopeRoot();
        ApprovedBySalespersonCode := JSON.GetString('approvedBySalesperson');
        DiscountReasonCode := JSON.GetString('discountReasonCode');
        AddDimensionCode := JSON.GetString('addDimensionCode');
        AddDimensionValueCode := JSON.GetString('addDimensionValueCode');
    end;

    local procedure ApplyAdditionalParams(var SaleLinePOS: Record "NPR POS Sale Line")
    begin
        if ApprovedBySalespersonCode <> '' then
            SaleLinePOS."Discount Authorised by" := ApprovedBySalespersonCode;
        if DiscountReasonCode <> '' then
            SaleLinePOS."Reason Code" := DiscountReasonCode;
        if (AddDimensionCode <> '') and (AddDimensionValueCode <> '') then
            AddDimensionToDimensionSet(SaleLinePOS, AddDimensionCode, AddDimensionValueCode);
    end;

    #endregion
    #region Constants

    local procedure "DiscType.DiscountAmt"(): Integer
    begin
        exit(0);
    end;

    local procedure "DiscType.DiscountPct"(): Integer
    begin
        exit(1);
    end;

    local procedure "DiscType.LineAmt"(): Integer
    begin
        exit(2);
    end;

    #endregion
}