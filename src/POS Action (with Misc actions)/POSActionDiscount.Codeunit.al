codeunit 6150792 "NPR POS Action - Discount"
{
    // NPR5.32.11/ANEN/20170619  CASE 274870 Added parameter for fixed discount from button without UI (upping version to 1.1)
    // NPR5.32.11/TSA /20170620  CASE 279495 Added DiscountType ClearLineDiscount and ClearTotalDiscount and restructured the input boundery testing
    // NPR5.36/TSA /20170703  CASE 282117 removed boundery check when changing Line Unit Price
    // NPR5.36/TSA /20171002 CASE 291290 Changed how and when the discount type was applied (and cleared)
    // NPR5.36/TSA /20171003 CASE 292311 same as 291290
    // NPR5.37/TSA /20171024 CASE 293113 Rounding when total amount is applied but when discounted amount per lines does not add up.
    // NPR5.38/CLVA/20180115 CASE 300172 Changed display handling to EventSubscriber
    // NPR5.38/MHA /20180116 CASE 302220 Added Reason Code functionality
    // NPR5.39/MHA /20180214 CASE 305139 Added Security functionality
    // NPR5.40/VB  /20180228 CASE 306347 Fixing bug with attempting to register an incorrect default value for DiscountType parameter.
    // NPR5.42/BHR /20180515 CASE 314774 Replace intpad with passwordpad
    // NPR5.42/CLVA/20180522 CASE 315824 Fixed wrong use of SaleLinePOS object
    // NPR5.43/CLVA/20180606 CASE 300254 Added display update
    // NPR5.44/MHA /20180724 CASE 323000 Refactored Calculations and Set-functions to not reference old Touch POS Objects  and deleted all outcommented lines
    // NPR5.44/MHA /20180724 CASE 300254 Deleted Publisher function OnAfterUpdatePOSSaleLine() [NPR5.43] and added trigger through OnAfterSetQuantity()
    // NPR5.45/MHA /20180807 CASE 317065 Added DiscountTypes DiscountPercentExtra,LineDiscountPercentExtra which will add extra flat Discount Percent
    // NPR5.48/TSA /20181214 CASE 338181 Use Amount field when doing final discount adjustment and price include vat is false, rounding on unit price and and reapply VAT on changed lines
    // NPR5.50/MHA /20190426 CASE 352178 POS Action Discount must not set Unit Price on Comment Lines
    // NPR5.52/ALPO/20190924 CASE 369499 Disallow negative discount amount
    // NPR5.55/ALST/20200417 CASE 399006 Added possibility to choose dimensions and add them to line
    // NPR5.55/ALPO/20200529 CASE 406357 Possibility to set discounts for returned items
    // NPR5.55/ALST/20200601 CASE 402144 Added discount group filtering
    // NPR5.55/ALPO/20200601 CASE 407793 Refresh xRec in POSSaleLine CU to avoid unexpected quantity change on Item AddOn dependent lines
    // NPR5.55/ALPO/20200701 CASE 328154 Adjust LineAmount and LineDiscountAmount for scenarios, when prices set to be VAT-excluding
    //                                   Do not allow negative LineAmount and TotalAmount to be specified
    //                                   Do not allow DiscountPercentExtra and LineDiscountPercentExtra outside 0..100 range
    // NPR5.55/TSA /20200720 CASE 414829 UpdateAmounts() on all lines to re-apply the accumulated VAT rounding error and distribute over all lines.
    // NPR5.55/ALPO/20200811 CASE 418824 Apply all additional parameters (Discount Authorised by, Reason Code, Dimension) together with discount, after target lines have been identified


    trigger OnRun()
    begin
    end;

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
        MultiLineDiscTarget: Option " ","Positive Only","Negative Only","Non-Zero";
        SelectDiscountTargetLbl: Label 'Please select discount target lines:';
        DiscTargetAllOptionLbl: Label 'All non-zero quantity lines';
        DiscTargetOtherOptionsLbl: Label 'Positive quantity lines only,Negative quantity lines only';
        DiscountGroupFilter: Text;
        NoDiscTargetFound: Label 'System couldn''t find lines the discount to be applied to.\The POS action is preset for discounts to be applied to %1.';
        AddDimensionCode: Code[20];
        AddDimensionValueCode: Code[20];
        ApprovedBySalespersonCode: Code[10];
        DiscountReasonCode: Code[10];

    local procedure ActionCode(): Text
    begin
        exit('DISCOUNT');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.5');  //NPR5.55 [406357]
        //-NPR5.55 [402144]
        exit('1.4');
        //+NPR5.55 [402144]
        //-NPR5.45 [317065]
        //-NPR5.55 [399006]
        exit('1.3');
        //+NPR5.55 [399006]
        exit('1.2');
        //+NPR5.45 [317065]
        exit('1.1');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do
            if DiscoverAction(
              ActionCode,
              ActionDescription,
              ActionVersion,
              Type::Generic,
              "Subscriber Instances Allowed"::Multiple)
            then begin
                //-NPR5.42 [314774]
                RegisterWorkflowStep('SalespersonPassword',
                  'if(param.Security == 1) {passwordpad({title: labels.DiscountAuthorisationTitle,caption: labels.SalespersonPasswordLabel,notBlank: true}).respond("SalespersonPassword").cancel(abort);}');
                RegisterWorkflowStep('CurrentSalespersonPassword',
                  'if(param.Security == 2) {passwordpad({title: labels.DiscountAuthorisationTitle,caption: labels.CurrentSalespersonPasswordLabel,notBlank: true}).respond("CurrentSalespersonPassword").cancel(abort);}');
                RegisterWorkflowStep('SupervisorPassword',
                  'if(param.Security == 3) {passwordpad({title: labels.DiscountAuthorisationTitle,caption: labels.SupervisorPasswordLabel,notBlank: true}).respond("SupervisorPassword").cancel(abort);}');
                //+NPR5.42 [314774]
                //-NPR5.55 [418824]
                RegisterWorkflowStep('FixedReasonCode', 'if (param.FixedReasonCode != "")  {respond()}');
                RegisterWorkflowStep('LookupReasonCode', 'if (param.LookupReasonCode)  {respond()}');
                RegisterWorkflowStep('AddDimensionValue', 'respond();');
                //+NPR5.55 [418824]
                //-NPR5.45 [317065]
                //RegisterWorkflowStep('1','if (param.FixedDiscountNumber == 0 && param.DiscountType < 9)  { numpad(labels["DiscountLabel" + param.DiscountType]).respond("quantity"); }');
                //RegisterWorkflowStep('2','if (param.FixedDiscountNumber != 0 || param.DiscountType >= 9) { context.quantity = param.FixedDiscountNumber; respond("quantity"); }');
                RegisterWorkflowStep('fixed_input', 'if (param.FixedDiscountNumber != 0) { context.quantity = param.FixedDiscountNumber; }');
                RegisterWorkflowStep('discount_input',
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
                //+NPR5.45 [317065]
                //-NPR5.55 [418824]-revoked (moved up)
                //    //-NPR5.38 [302220]
                //    RegisterWorkflowStep('FixedReasonCode','if (param.FixedReasonCode != "")  {respond()}');
                //    RegisterWorkflowStep('LookupReasonCode','if (param.LookupReasonCode)  {respond()}');
                //    //+NPR5.38 [302220]
                //    //-NPR5.55 [399006]
                //    RegisterWorkflowStep('AddDimensionValue','respond();');
                //    //+NPR5.55 [399006]
                //+NPR5.55 [418824]-revoked (moved up)

                //-NPR5.39 [305139]
                RegisterOptionParameter('Security', 'None,SalespersonPassword,CurrentSalespersonPassword,SupervisorPassword', 'None');
                //+NPR5.39 [305139]
                RegisterOptionParameter('DiscountType',
                  'TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,' +
                  //-NPR5.40 [306347]
                  'LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount'
                  //+NPR5.40 [306347]
                  //-NPR5.45 [317065]
                  + ',DiscountPercentExtra,LineDiscountPercentExtra'
                  //+NPR5.45 [317065]
                  , 'TotalDiscountAmount');
                //-NPR5.32.11
                RegisterDecimalParameter('FixedDiscountNumber', 0);
                //+NPR5.32.11
                //-NPR5.38 [302220]
                RegisterTextParameter('FixedReasonCode', '');
                RegisterBooleanParameter('LookupReasonCode', false);
                //+NPR5.38 [302220]
                //-NPR5.55 [399006]
                RegisterTextParameter('DimensionCode', '');
                RegisterTextParameter('DimensionValue', '');
                //+NPR5.55 [399006]
                //-NPR5.55 [402144]
                RegisterTextParameter('DiscountGroupFilter', '');
                //+NPR5.55 [402144]
                //-NPR5.55 [406357]
                RegisterOptionParameter('TotalDiscTargetLines', 'Auto,Positive,Negative,All,Ask', 'Positive');
                //+NPR5.55 [406357]
                RegisterDataBinding();
                RegisterWorkflow(true);
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', false, false)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
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
        //-NPR5.45 [317065]
        Captions.AddActionCaption(ActionCode(), 'DiscountLabel11', DiscountPercentExtraLabel);
        Captions.AddActionCaption(ActionCode(), 'DiscountLabel12', LineDiscountPercentExtraLabel);
        //+NPR5.45 [317065]
        //-NPR5.39 [305139]
        Captions.AddActionCaption(ActionCode(), 'DiscountAuthorisationTitle', Text000);
        Captions.AddActionCaption(ActionCode(), 'SalespersonPasswordLabel', Text001);
        Captions.AddActionCaption(ActionCode(), 'CurrentSalespersonPasswordLabel', Text002);
        Captions.AddActionCaption(ActionCode(), 'SupervisorPasswordLabel', Text003);
        //+NPR5.39 [305139]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        Quantity: Decimal;
        POSSale: Codeunit "NPR POS Sale";
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
        SalePOS: Record "NPR Sale POS";
        SaleLinePOS: Record "NPR Sale Line POS";
        View: DotNet NPRNetView0;
        TotalPrice: Decimal;
        PresetMultiLineDiscTarget: Integer;
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        //-NPR5.38 [302220]
        case WorkflowStep of
            //-NPR5.39 [305139]
            'SalespersonPassword':
                begin
                    Handled := true;
                    //OnActionSalespersonPassword(JSON,POSSession);  //NPR5.55 [418824]-revoked
                    OnActionSalespersonPassword(JSON, POSSession, FrontEnd);  //NPR5.55 [418824]
                    exit;
                end;
            'CurrentSalespersonPassword':
                begin
                    Handled := true;
                    //OnActionCurrentSalespersonPassword(JSON,POSSession);  //NPR5.55 [418824]-revoked
                    OnActionCurrentSalespersonPassword(JSON, POSSession, FrontEnd);  //NPR5.55 [418824]
                    exit;
                end;
            'SupervisorPassword':
                begin
                    Handled := true;
                    //OnActionSupervisorPassword(JSON,POSSession);  //NPR5.55 [418824]-revoked
                    OnActionSupervisorPassword(JSON, POSSession, FrontEnd);  //NPR5.55 [418824]
                    exit;
                end;
            //+NPR5.39 [305139]
            'FixedReasonCode':
                begin
                    Handled := true;
                    //OnActionFixedReasonCode(JSON,POSSession);  //NPR5.55 [418824]-revoked
                    OnActionFixedReasonCode(JSON, POSSession, FrontEnd);  //NPR5.55 [418824]
                    exit;
                end;
            'LookupReasonCode':
                begin
                    Handled := true;
                    //OnActionLookupReasonCode(JSON,POSSession);  //NPR5.55 [418824]-revoked
                    OnActionLookupReasonCode(JSON, POSSession, FrontEnd);  //NPR5.55 [418824]
                    exit;
                end;
            //-NPR5.55 [399006]
            'AddDimensionValue':
                begin
                    Handled := true;
                    //OnActionAddDimensionValue(JSON,POSSession);  //NPR5.55 [418824]-revoked
                    OnActionAddDimensionValue(JSON, POSSession, FrontEnd);  //NPR5.55 [418824]
                    exit;
                end;
        //+NPR5.55 [399006]
        end;
        //+NPR5.38 [302220]
        Quantity := JSON.GetDecimal('quantity', true);
        JSON.SetScope('parameters', true);
        DiscountType := JSON.GetInteger('DiscountType', true);
        PresetMultiLineDiscTarget := JSON.GetIntegerParameter('TotalDiscTargetLines', false);  //NPR5.55 [406357]
        //-NPR5.55 [402144]
        DiscountGroupFilter := JSON.GetStringParameter('DiscountGroupFilter', true);
        //+NPR5.55 [402144]

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        POSSaleLine.RefreshxRec();  //NPR5.55 [407793]
        POSSession.GetCurrentView(View);

        //-NPR5.55 [406357]-revoked
        /*
        TotalPrice  := GetLinesTotalDiscountableValue(SalePOS);
        
        //-NPR5.32.11 [279495]
        CASE DiscountType OF
          0,1,4,5 : // Amount based functions
            IF (TotalPrice < Quantity) THEN
              ERROR(DiscountAmountErr);
          2,3,6,7: // Percentage based functions
            IF (Quantity < 0) OR (Quantity > 100) THEN
              ERROR(DiscountPercentError);
          8: ;    // [282117] No check for unit price
          9,10: ; // Clear functions
        END;
        
        //-NPR5.52 [369499]
        //1 = TotalDiscountAmount, 5 = LineDiscountAmount
        IF (DiscountType IN [1,5]) AND (Quantity < 0) THEN
          ERROR(NegativeDiscAmtErr);
        //+NPR5.52 [369499]
        */
        //+NPR5.55 [406357]-revoked
        //-NPR5.55 [406357]
        if (Quantity < 0) and
           (DiscountType in
            [DiscountType::TotalAmount,  //NPR5.55 [328154]
             DiscountType::TotalDiscountAmount,
             DiscountType::LineAmount,  //NPR5.55 [328154]
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
                    if (TotalPrice < Quantity) then
                        Error(DiscountAmountErr);
                end;

            DiscountType::DiscountPercentABS,
            DiscountType::DiscountPercentREL,
            DiscountType::LineDiscountPercentABS,
            DiscountType::LineDiscountPercentREL,
            //-NPR5.55 [328154]
            DiscountType::DiscountPercentExtra,
            DiscountType::LineDiscountPercentExtra:
                //+NPR5.55 [328154]
                begin
                    if (Quantity < 0) or (Quantity > 100) then
                        Error(DiscountPercentError);
                end;
        end;
        //+NPR5.55 [406357]

        GetAdditionalParams(JSON);  //NPR5.55 [418824]

        case DiscountType of
            0:
                SetTotalAmount(SalePOS, Quantity);
            1:
                SetTotalDiscountAmount(SalePOS, Quantity);
            2:
                SetDiscountPctABS(SalePOS, Quantity);
            3:
                SetDiscountPctREL(SalePOS, Quantity);
            //-NPR5.44 [323000]
            //4 : SetLineAmount(SalePOS,SaleLinePOS,Quantity,View,0);
            4:
                SetLineAmount(SaleLinePOS, Quantity);
            //+NPR5.44 [323000]
            5:
                SetLineDiscountAmount(SaleLinePOS, Quantity);
            6:
                SetLineDiscountPctABS(SaleLinePOS, Quantity);
            7:
                SetLineDiscountPctREL(SaleLinePOS, Quantity);
            8:
                SetLineUnitPrice(SaleLinePOS, Quantity);
            9:
                SetLineDiscountAmount(SaleLinePOS, 0);
            10:
                SetTotalDiscountAmount(SalePOS, 0);
            //-NPR5.45 [317065]
            11:
                SetDiscountPctExtra(SalePOS, Quantity);
            12:
                SetLineDiscountPctExtra(SaleLinePOS, Quantity);
        //+NPR5.45 [317065]
        end;

        //-NPR5.44 [300254]
        POSSaleLine.RefreshCurrent();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        POSSaleLine.OnAfterSetQuantity(SaleLinePOS);
        //+NPR5.44 [300254]
        POSSession.RequestRefreshData();

        Handled := true;

    end;

    local procedure OnActionSalespersonPassword(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Salesperson: Record "Salesperson/Purchaser";
        SalespersonPassword: Text;
    begin
        //-NPR5.39 [305139]
        SalespersonPassword := JSON.GetString('SalespersonPassword', true);
        Salesperson.SetRange("NPR Register Password", SalespersonPassword);
        if not Salesperson.FindFirst then
            Error(Text004);

        //-NPR5.55 [418824]
        JSON.SetContext('approvedBySalesperson', Salesperson.Code);
        FrontEnd.SetActionContext(ActionCode(), JSON);
        //+NPR5.55 [418824]
        //-NPR5.55 [418824]-revoked
        /*
        JSON.SetScope('parameters',TRUE);
        DiscountType := JSON.GetInteger('DiscountType',TRUE);
        CASE DiscountType OF
          0,1,2,3,10:
            ApplyApprovedBy(Salesperson.Code,TRUE,POSSession);
          4,5,6,7,8,9:
            ApplyApprovedBy(Salesperson.Code,FALSE,POSSession);
        END;
        
        POSSession.RequestRefreshData();
        */
        //+NPR5.55 [418824]-revoked
        //+NPR5.39 [305139]

    end;

    local procedure OnActionCurrentSalespersonPassword(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Salesperson: Record "Salesperson/Purchaser";
        SalePOS: Record "NPR Sale POS";
        POSSale: Codeunit "NPR POS Sale";
        SalespersonPassword: Text;
    begin
        //-NPR5.39 [305139]
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalespersonPassword := JSON.GetString('CurrentSalespersonPassword', true);

        Salesperson.SetRange(Code, SalePOS."Salesperson Code");
        Salesperson.SetRange("NPR Register Password", SalespersonPassword);
        if not Salesperson.FindFirst then
            Error(Text004);

        //-NPR5.55 [418824]
        JSON.SetContext('approvedBySalesperson', Salesperson.Code);
        FrontEnd.SetActionContext(ActionCode(), JSON);
        //+NPR5.55 [418824]
        //-NPR5.55 [418824]-revoked
        /*
        JSON.SetScope('parameters',TRUE);
        DiscountType := JSON.GetInteger('DiscountType',TRUE);
        CASE DiscountType OF
          0,1,2,3,10:
            ApplyApprovedBy(Salesperson.Code,TRUE,POSSession);
          4,5,6,7,8,9:
            ApplyApprovedBy(Salesperson.Code,FALSE,POSSession);
        END;
        
        POSSession.RequestRefreshData();
        */
        //+NPR5.55 [418824]-revoked
        //+NPR5.39 [305139]

    end;

    local procedure OnActionSupervisorPassword(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Salesperson: Record "Salesperson/Purchaser";
        SupervisorPassword: Text;
    begin
        //-NPR5.39 [305139]
        SupervisorPassword := JSON.GetString('SupervisorPassword', true);
        Salesperson.SetRange("NPR Register Password", SupervisorPassword);
        Salesperson.SetRange("NPR Supervisor POS", true);
        if not Salesperson.FindFirst then
            Error(Text004);

        //-NPR5.55 [418824]
        JSON.SetContext('approvedBySalesperson', Salesperson.Code);
        FrontEnd.SetActionContext(ActionCode(), JSON);
        //+NPR5.55 [418824]
        //-NPR5.55 [418824]-revoked
        /*
        JSON.SetScope('parameters',TRUE);
        DiscountType := JSON.GetInteger('DiscountType',TRUE);
        CASE DiscountType OF
          0,1,2,3,10:
            ApplyApprovedBy(Salesperson.Code,TRUE,POSSession);
          4,5,6,7,8,9:
            ApplyApprovedBy(Salesperson.Code,FALSE,POSSession);
        END;
        
        POSSession.RequestRefreshData();
        */
        //+NPR5.55 [418824]-revoked
        //+NPR5.39 [305139]

    end;

    local procedure OnActionFixedReasonCode(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        ReasonCode: Code[10];
    begin
        //-NPR5.38 [302220]
        JSON.SetScope('parameters', true);
        ReasonCode := JSON.GetString('FixedReasonCode', true);
        //DiscountType := JSON.GetInteger('DiscountType',TRUE);  //NPR5.55 [418824]-revoked
        if ReasonCode = '' then
            exit;

        //-NPR5.55 [418824]
        JSON.SetContext('discountReasonCode', ReasonCode);
        FrontEnd.SetActionContext(ActionCode(), JSON);
        //+NPR5.55 [418824]
        //-NPR5.55 [418824]-revoked
        /*
        CASE DiscountType OF
          0,1,2,3,10:
            ApplyReasonCode(ReasonCode,TRUE,POSSession);
          4,5,6,7,8,9:
            ApplyReasonCode(ReasonCode,FALSE,POSSession);
        END;
        */
        //+NPR5.55 [418824]-revoked
        //+NPR5.38 [302220]

    end;

    local procedure OnActionLookupReasonCode(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        ReasonCode: Record "Reason Code";
    begin
        //-NPR5.38 [302220]
        if PAGE.RunModal(0, ReasonCode) <> ACTION::LookupOK then
            exit;

        //-NPR5.55 [418824]
        JSON.SetContext('discountReasonCode', ReasonCode.Code);
        FrontEnd.SetActionContext(ActionCode(), JSON);
        //+NPR5.55 [418824]
        //-NPR5.55 [418824]-revoked
        /*
        JSON.SetScope('parameters',TRUE);
        DiscountType := JSON.GetInteger('DiscountType',TRUE);
        CASE DiscountType OF
          0,1,2,3,10:
            ApplyReasonCode(ReasonCode.Code,TRUE,POSSession);
          4,5,6,7,8,9:
            ApplyReasonCode(ReasonCode.Code,FALSE,POSSession);
        END;
        */
        //+NPR5.55 [418824]-revoked
        //+NPR5.38 [302220]

    end;

    local procedure OnActionAddDimensionValue(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        DimensionValue: Record "Dimension Value";
        DimensionCodeParameter: Text;
        DimensionValueParameter: Text;
    begin
        //-NPR5.55 [399006]
        JSON.SetScope('parameters', true);
        //DiscountType := JSON.GetInteger('DiscountType',TRUE);  //NPR5.55 [418824]-revoked
        DimensionCodeParameter := JSON.GetStringParameter('DimensionCode', true);
        if DimensionCodeParameter = '' then
            exit;

        DimensionValueParameter := JSON.GetStringParameter('DimensionValue', true);
        if DimensionValueParameter = '' then begin
            DimensionValue.SetRange("Dimension Code", DimensionCodeParameter);
            if PAGE.RunModal(0, DimensionValue) <> ACTION::LookupOK then
                exit;
            DimensionValueParameter := DimensionValue.Code;
        end;

        //-NPR5.55 [418824]
        JSON.SetContext('addDimensionCode', DimensionCodeParameter);
        JSON.SetContext('addDimensionValueCode', DimensionValueParameter);
        FrontEnd.SetActionContext(ActionCode(), JSON);
        //+NPR5.55 [418824]
        //-NPR5.55 [418824]-revoked
        /*
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        
        CASE DiscountType OF
          0,1,2,3,10:
            BEGIN
              SaleLinePOS.SETRECFILTER;
              SaleLinePOS.SETRANGE("Line No.");
              SaleLinePOS.FINDSET;
              REPEAT
                AddDimensionToDimensionSet(SaleLinePOS, DimensionCodeParameter, DimensionValueParameter);
              UNTIL SaleLinePOS.NEXT = 0;
            END;
          4,5,6,7,8,9:
            AddDimensionToDimensionSet(SaleLinePOS, DimensionCodeParameter, DimensionValueParameter);
        END;
        */
        //+NPR5.55 [418824]-revoked
        //+NPR5.55 [399006]

    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterNameCaption', '', true, false)]
    local procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    var
        CaptionTotalDiscTargetLines: Label 'Total Discount Target';
    begin
        //-NPR5.55 [406357]
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        case POSParameterValue.Name of
            'TotalDiscTargetLines':
                Caption := CaptionTotalDiscTargetLines;
        end;
        //+NPR5.55 [406357]
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterDescriptionCaption', '', true, false)]
    local procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    var
        DescTotalDiscTargetLines: Label 'Select target lines multi-line discounts to be applied to';
    begin
        //-NPR5.55 [406357]
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        case POSParameterValue.Name of
            'TotalDiscTargetLines':
                Caption := DescTotalDiscTargetLines;
        end;
        //+NPR5.55 [406357]
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterOptionStringCaption', '', true, false)]
    local procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    var
        OptionTotalDiscTargetLines: Label 'Auto,Positive quantity lines only,Negative quantity lines only,All non-zero quantity lines,Ask';
    begin
        //-NPR5.55 [406357]
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        case POSParameterValue.Name of
            'TotalDiscTargetLines':
                Caption := OptionTotalDiscTargetLines;
        end;
        //+NPR5.55 [406357]
    end;

    local procedure "-- Locals --"()
    begin
    end;

    local procedure ApplyDiscountOnLines(var SalePOS: Record "NPR Sale POS"; DiscountType: Option DiscountAmt,DiscountPct,LineAmt; Discount: Decimal)
    var
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        //-NPR5.44 [323000]
        ApplyFilterOnLines(SalePOS, SaleLinePOS);
        if not SaleLinePOS.FindSet then
            exit;

        repeat
            ApplyDiscountOnLine(SaleLinePOS, DiscountType, Discount);
        until SaleLinePOS.Next = 0;
        //+NPR5.44 [323000]
    end;

    local procedure ApplyDiscountOnLine(var SaleLinePOS: Record "NPR Sale Line POS"; DiscountType: Option DiscountAmt,DiscountPct,LineAmt; Discount: Decimal)
    var
        PrevRec: Text;
    begin
        //-NPR5.44 [323000]
        if SaleLinePOS."Custom Disc Blocked" then
            exit;
        //-NPR5.55 [406357]-revoked
        //IF SaleLinePOS."Amount Including VAT" < 0 THEN
        //  EXIT;
        //+NPR5.55 [406357]-revoked
        //-NPR5.55 [406357]
        if DiscountType in [DiscountType::DiscountAmt, DiscountType::LineAmt] then
            Discount := Discount * GetSignFactor(SaleLinePOS);
        //+NPR5.55 [406357]
        //-NPR5.55 [328154]
        if not SaleLinePOS."Price Includes VAT" and
           (SaleLinePOS."VAT %" > 0) and
           (DiscountType in [DiscountType::DiscountAmt, DiscountType::LineAmt])
        then
            Discount := Round(Discount / (1 + SaleLinePOS."VAT %" / 100));
        //+NPR5.55 [328154]

        PrevRec := Format(SaleLinePOS);

        SaleLinePOS."Discount Type" := SaleLinePOS."Discount Type"::" ";
        SaleLinePOS."Discount Code" := '';
        if Discount <> 0 then
            SaleLinePOS."Discount Type" := SaleLinePOS."Discount Type"::Manual;

        case DiscountType of
            DiscountType::DiscountAmt:
                begin
                    SaleLinePOS."Discount %" := 0;
                    SaleLinePOS."Discount Amount" := Discount;
                end;
            DiscountType::DiscountPct:
                begin
                    //-NPR5.45 [317065]
                    if Discount < 0 then
                        Discount := 0;
                    //+NPR5.45 [317065]
                    if Discount > 100 then
                        Discount := 100;
                    SaleLinePOS."Discount %" := Discount;
                    SaleLinePOS."Discount Amount" := 0;
                end;
            DiscountType::LineAmt:
                begin
                    SaleLinePOS."Discount %" := 0;
                    SaleLinePOS."Discount Amount" := SaleLinePOS."Unit Price" * SaleLinePOS.Quantity - Discount;
                end;
        end;

        ApplyAdditionalParams(SaleLinePOS);  //NPR5.55 [418824]
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        if PrevRec <> Format(SaleLinePOS) then
            SaleLinePOS.Modify;
        //+NPR5.44 [323000]

        //-NPR5.55 [414829] // Recalculate VAT Difference rounding error distribution on all lines
        UpdateSalesVAT(SaleLinePOS."Orig. POS Sale ID");
        //+NPR5.55 [414829]
    end;

    local procedure ApplyFilterOnLines(var SalePOS: Record "NPR Sale POS"; var SaleLinePOS: Record "NPR Sale Line POS")
    var
        UnexpectedFilterType: Label 'Unexpected quantity type filter. This is a critical programming error. Please contact system vendor.';
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Sale);
        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Item);
        //-NPR5.55 [406357]
        case MultiLineDiscTarget of
            MultiLineDiscTarget::" ":
                Error(UnexpectedFilterType);
            MultiLineDiscTarget::"Non-Zero":
                SaleLinePOS.SetFilter(Quantity, '<>%1', 0);
            MultiLineDiscTarget::"Negative Only":
                SaleLinePOS.SetFilter(Quantity, '<%1', 0);
            MultiLineDiscTarget::"Positive Only":
                //+NPR5.55 [406357]
                SaleLinePOS.SetFilter(Quantity, '>%1', 0);
        end;  //NPR5.55 [406357]
        //-NPR5.44 [323000]
        SaleLinePOS.SetRange("Custom Disc Blocked", false);
        //+NPR5.44 [323000]

        //-NPR5.55 [402144]
        if DiscountGroupFilter > '' then
            SaleLinePOS.SetFilter("Item Disc. Group", DiscountGroupFilter);
        //+NPR5.55 [402144]
    end;

    local procedure GetLinesTotalDiscountableValue(var SalePOS: Record "NPR Sale POS") TotalLineValue: Decimal
    var
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        ApplyFilterOnLines(SalePOS, SaleLinePOS);

        if SaleLinePOS.FindSet then
            repeat
                //-NPR5.55 [406357]-revoked (moved to a subfunction)
                /*
                IF NOT (SaleLinePOS."Custom Disc Blocked") THEN BEGIN

                  IF SaleLinePOS."Price Includes VAT" THEN
                    TotalLineValue +=  SaleLinePOS.Quantity * SaleLinePOS."Unit Price"
                  ELSE
                    TotalLineValue += SaleLinePOS.Quantity * ( SaleLinePOS."Unit Price" * ( ( 100 + SaleLinePOS."VAT %" ) / 100) );

                END ELSE BEGIN

                  IF SaleLinePOS."Price Includes VAT" THEN
                    TotalLineValue += SaleLinePOS."Amount Including VAT"
                  ELSE
                    //-NPR5.48 [338181]
                    //TotalLineValue += SaleLinePOS."Amount Including VAT" * ( 100 + SaleLinePOS."VAT %" ) / 100;
                    TotalLineValue += SaleLinePOS.Amount * ( 100 + SaleLinePOS."VAT %" ) / 100;
                    //+NPR5.48 [338181]

                END;
                */
                //+NPR5.55 [406357]-revoked
                TotalLineValue += GetSingleLineTotalDiscountableValue(SaleLinePOS, false);  //NPR5.55 [406357]
            until SaleLinePOS.Next = 0;

    end;

    local procedure GetSingleLineTotalDiscountableValue(SaleLinePOS: Record "NPR Sale Line POS"; IncludeDiscount: Boolean) LineValue: Decimal
    begin
        //-NPR5.55 [406357]
        if not IncludeDiscount then
            SaleLinePOS."Discount Amount" := 0;

        if not SaleLinePOS."Custom Disc Blocked" then begin
            if SaleLinePOS."Price Includes VAT" then
                LineValue := SaleLinePOS.Quantity * SaleLinePOS."Unit Price" - SaleLinePOS."Discount Amount"
            else
                LineValue := SaleLinePOS.Quantity * SaleLinePOS."Unit Price" * (1 + SaleLinePOS."VAT %" / 100) - SaleLinePOS."Discount Amount" * (1 + SaleLinePOS."VAT %" / 100);
        end else begin
            if SaleLinePOS."Price Includes VAT" then
                LineValue := SaleLinePOS."Amount Including VAT"
            else
                LineValue := SaleLinePOS.Amount * (1 + SaleLinePOS."VAT %" / 100);
        end;

        if SaleLinePOS.Quantity < 0 then
            LineValue := -LineValue;
        //+NPR5.55 [406357]
    end;

    local procedure SetTotalDiscountAmount(var SalePOS: Record "NPR Sale POS"; TotalDiscountAmount: Decimal)
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        TotalPrice: Decimal;
        DiscountPct: Decimal;
    begin
        ApplyFilterOnLines(SalePOS, SaleLinePOS);

        TotalPrice := GetLinesTotalDiscountableValue(SalePOS);
        DiscountPct := TotalDiscountAmount / TotalPrice * 100;

        //-NPR5.44 [323000]
        ApplyDiscountOnLines(SalePOS, "DiscType.DiscountPct", DiscountPct);
        //+NPR5.44 [323000]

        //-NPR5.37 [293113]
        AdjustRoundingForTotalAmountDiscount(SalePOS, (TotalPrice - TotalDiscountAmount));
        //+NPR5.37 [293113]
    end;

    local procedure SetTotalAmount(var SalePOS: Record "NPR Sale POS"; Amount: Decimal)
    var
        t001: Label 'Total Amount entered must be less than the Sale Total!';
        DiscountPct: Decimal;
        TotalPrice: Decimal;
    begin
        TotalPrice := GetLinesTotalDiscountableValue(SalePOS);
        DiscountPct := (TotalPrice - Amount) / TotalPrice * 100;
        if DiscountPct < 0 then
            Error(t001);

        //-NPR5.44 [323000]
        ApplyDiscountOnLines(SalePOS, "DiscType.DiscountPct", DiscountPct);
        //+NPR5.44 [323000]

        //-NPR5.37 [293113]
        AdjustRoundingForTotalAmountDiscount(SalePOS, Amount);
        //+NPR5.37 [293113]
    end;

    local procedure SetDiscountPctABS(SalePOS: Record "NPR Sale POS"; DiscountPct: Decimal)
    begin
        //-NPR5.44 [323000]
        ApplyDiscountOnLines(SalePOS, "DiscType.DiscountPct", DiscountPct);
        //+NPR5.44 [323000]
    end;

    local procedure SetDiscountPctREL(SalePOS: Record "NPR Sale POS"; DiscountPct: Decimal)
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        RelativeDiscountPct: Decimal;
    begin
        //-NPR5.44 [323000]
        ApplyFilterOnLines(SalePOS, SaleLinePOS);
        if not SaleLinePOS.FindSet then
            exit;

        repeat
            RelativeDiscountPct := (1 - (1 - SaleLinePOS."Discount %" / 100) * (1 - DiscountPct / 100)) * 100;
            ApplyDiscountOnLine(SaleLinePOS, "DiscType.DiscountPct", RelativeDiscountPct);
        until SaleLinePOS.Next = 0;
        //+NPR5.44 [323000]
    end;

    local procedure SetDiscountPctExtra(SalePOS: Record "NPR Sale POS"; ExtraDiscountPct: Decimal)
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        NewDiscountPct: Decimal;
    begin
        //-NPR5.45 [317065]
        ApplyFilterOnLines(SalePOS, SaleLinePOS);
        if not SaleLinePOS.FindSet then
            exit;

        repeat
            NewDiscountPct := SaleLinePOS."Discount %" + ExtraDiscountPct;
            ApplyDiscountOnLine(SaleLinePOS, "DiscType.DiscountPct", NewDiscountPct);
        until SaleLinePOS.Next = 0;
        //+NPR5.45 [317065]
    end;

    procedure SetLineAmount(var SaleLinePOS: Record "NPR Sale Line POS"; LineAmount: Decimal)
    begin
        //-NPR5.44 [323000]
        ApplyDiscountOnLine(SaleLinePOS, "DiscType.LineAmt", LineAmount);
        //+NPR5.44 [323000]
    end;

    local procedure SetLineDiscountAmount(var SaleLinePOS: Record "NPR Sale Line POS"; DiscountAmount: Decimal)
    begin
        //-NPR5.44 [323000]
        ApplyDiscountOnLine(SaleLinePOS, "DiscType.DiscountAmt", DiscountAmount);
        //+NPR5.44 [323000]
    end;

    local procedure SetLineDiscountPctABS(var SaleLinePOS: Record "NPR Sale Line POS"; DiscountPct: Decimal)
    begin
        //-NPR5.44 [323000]
        ApplyDiscountOnLine(SaleLinePOS, "DiscType.DiscountPct", DiscountPct);
        //+NPR5.44 [323000]
    end;

    local procedure SetLineDiscountPctREL(var SaleLinePOS: Record "NPR Sale Line POS"; DiscountPct: Decimal)
    var
        RelativeDiscountPct: Decimal;
    begin
        //-NPR5.44 [323000]
        RelativeDiscountPct := (1 - (1 - SaleLinePOS."Discount %" / 100) * (1 - DiscountPct / 100)) * 100;
        ApplyDiscountOnLine(SaleLinePOS, "DiscType.DiscountPct", RelativeDiscountPct);
        //+NPR5.44 [323000]
    end;

    local procedure SetLineDiscountPctExtra(var SaleLinePOS: Record "NPR Sale Line POS"; ExtraDiscountPct: Decimal)
    var
        NewDiscountPct: Decimal;
    begin
        //+NPR5.45 [317065]
        NewDiscountPct := SaleLinePOS."Discount %" + ExtraDiscountPct;
        ApplyDiscountOnLine(SaleLinePOS, "DiscType.DiscountPct", NewDiscountPct);
        //+NPR5.45 [317065]
    end;

    local procedure SetLineUnitPrice(var SaleLinePOS: Record "NPR Sale Line POS"; UnitPrice: Decimal)
    var
        PrevRec: Text;
    begin
        //-NPR5.50 [352178]
        if not (SaleLinePOS."Sale Type" in [SaleLinePOS."Sale Type"::Sale, SaleLinePOS."Sale Type"::"Debit Sale"]) then
            Error(Text005, SaleLinePOS."Sale Type");
        if SaleLinePOS.Type = SaleLinePOS.Type::Comment then
            Error(Text005, SaleLinePOS.Type);
        //+NPR5.50 [352178]
        //-NPR5.44 [323000]
        PrevRec := Format(SaleLinePOS);

        SaleLinePOS."Unit Price" := UnitPrice;
        ApplyAdditionalParams(SaleLinePOS);  //NPR5.55 [418824]
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        if PrevRec <> Format(SaleLinePOS) then
            SaleLinePOS.Modify;
        //+NPR5.44 [323000]

        //-NPR5.55 [414829] // Recalculate VAT Difference rounding error distribution on all lines
        UpdateSalesVAT(SaleLinePOS."Orig. POS Sale ID");
        //+NPR5.55 [414829]
    end;

    local procedure AdjustRoundingForTotalAmountDiscount(var SalePOS: Record "NPR Sale POS"; Amount: Decimal)
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        TotalLineValue: Decimal;
    begin

        //-NPR5.37 [293113]
        ApplyFilterOnLines(SalePOS, SaleLinePOS);
        if (SaleLinePOS.FindSet()) then begin
            repeat
                //-NPR5.55 [406357]-revoked (moved to a subfunction)
                /*
                //-NPR5.48 [338181]
                //    IF SaleLinePOS."Price Includes VAT" THEN
                //      TotalLineValue += SaleLinePOS."Amount Including VAT"
                //    ELSE
                //      TotalLineValue += SaleLinePOS."Amount Including VAT" * ( 100 + SaleLinePOS."VAT %" ) / 100;

                IF NOT (SaleLinePOS."Custom Disc Blocked") THEN BEGIN

                  IF SaleLinePOS."Price Includes VAT" THEN
                    TotalLineValue +=  SaleLinePOS.Quantity * SaleLinePOS."Unit Price" - SaleLinePOS."Discount Amount"
                  ELSE
                    TotalLineValue += SaleLinePOS.Quantity * ( SaleLinePOS."Unit Price" * ( ( 100 + SaleLinePOS."VAT %" ) / 100) ) - (SaleLinePOS."Discount Amount" * ( ( 100 + SaleLinePOS."VAT %" ) / 100) )

                END ELSE BEGIN

                  // Amount fields on all lines need to reflect the applied discount before adjusting last line
                  //RecalculateVatOnLines (SalePOS);

                  IF SaleLinePOS."Price Includes VAT" THEN
                    TotalLineValue += SaleLinePOS."Amount Including VAT"
                  ELSE
                    TotalLineValue += SaleLinePOS.Amount * ( 100 + SaleLinePOS."VAT %" ) / 100;
                END;
                //+NPR5.48 [338181]
                */
                //+NPR5.55 [406357]-revoked
                TotalLineValue += GetSingleLineTotalDiscountableValue(SaleLinePOS, true);  //NPR5.55 [406357]
            until (SaleLinePOS.Next() = 0);

            if (TotalLineValue <> Amount) then
                //SetLineDiscountAmount (SaleLinePOS, SaleLinePOS."Discount Amount" + (TotalLineValue - Amount));  //NPR5.55 [406357]-revoked
                SetLineDiscountAmount(SaleLinePOS, SaleLinePOS."Discount Amount" * GetSignFactor(SaleLinePOS) + (TotalLineValue - Amount));  //NPR5.55 [406357]
        end;
        //+NPR5.37 [293113]

    end;

    local procedure ApplyApprovedBy(SalespersonCode: Code[10]; ApplyOnAllLines: Boolean; POSSession: Codeunit "NPR POS Session")
    var
        SalePOS: Record "NPR Sale POS";
        SaleLinePOS: Record "NPR Sale Line POS";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
    begin
        //-NPR5.55 [418824]-revoked
        Error('Obsolete function was called.');
        /*
        //-NPR5.39 [305139]
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        
        SaleLinePOS.SetSkipCalcDiscount(TRUE);
        IF NOT ApplyOnAllLines THEN BEGIN
          SaleLinePOS."Discount Authorised by" := SalespersonCode;
          SaleLinePOS.MODIFY(TRUE);
          EXIT;
        END;
        
        ApplyFilterOnLines(SalePOS,SaleLinePOS);
        SaleLinePOS.MODIFYALL("Discount Authorised by",SalespersonCode,TRUE);
        //+NPR5.39 [305139]
        */
        //+NPR5.55 [418824]-revoked

    end;

    local procedure ApplyReasonCode(ReasonCode: Code[10]; ApplyOnAllLines: Boolean; var POSSession: Codeunit "NPR POS Session")
    var
        SalePOS: Record "NPR Sale POS";
        SaleLinePOS: Record "NPR Sale Line POS";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
    begin
        //-NPR5.55 [418824]-revoked
        Error('Obsolete function was called.');
        /*
        //-NPR5.38 [302220]
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        
        SaleLinePOS.SetSkipCalcDiscount(TRUE);
        IF NOT ApplyOnAllLines THEN BEGIN
          SaleLinePOS."Reason Code" := ReasonCode;
          SaleLinePOS.MODIFY(TRUE);
          EXIT;
        END;
        
        ApplyFilterOnLines(SalePOS,SaleLinePOS);
        SaleLinePOS.MODIFYALL("Reason Code",ReasonCode,TRUE);
        //+NPR5.38 [302220]
        */
        //+NPR5.55 [418824]-revoked

    end;

    local procedure AddDimensionToDimensionSet(var SaleLinePOS: Record "NPR Sale Line POS"; DimensionCode: Code[20]; DimensionValueCode: Code[20])
    var
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        DimensionManagement: Codeunit DimensionManagement;
    begin
        //-NPR5.55 [399006]
        DimensionManagement.GetDimensionSet(TempDimensionSetEntry, SaleLinePOS."Dimension Set ID");
        ValidateDimValue(DimensionCode, DimensionValueCode);
        UpdateDimensionSet(TempDimensionSetEntry, DimensionCode, DimensionValueCode);

        SaleLinePOS."Dimension Set ID" := DimensionManagement.GetDimensionSetID(TempDimensionSetEntry);
        DimensionManagement.UpdateGlobalDimFromDimSetID(SaleLinePOS."Dimension Set ID", SaleLinePOS."Shortcut Dimension 1 Code", SaleLinePOS."Shortcut Dimension 2 Code");

        //SaleLinePOS.MODIFY;  //NPR5.55 [418824]-revoked
        //+NPR5.55 [399006]
    end;

    local procedure UpdateDimensionSet(var DimensionSetEntry: Record "Dimension Set Entry"; DimensionCode: Code[20]; DimensionValueCode: Code[20])
    var
        DimensionValue: Record "Dimension Value";
    begin
        //-NPR5.55 [399006]
        if DimensionSetEntry.Get(DimensionSetEntry."Dimension Set ID", DimensionCode) then begin
            if not ((DimensionSetEntry."Dimension Value Code" <> DimensionValueCode) or (DimensionValueCode = '')) then
                exit;

            DimensionSetEntry.Delete;
        end;

        if DimensionValueCode <> '' then begin
            DimensionValue.Get(DimensionCode, DimensionValueCode);

            DimensionSetEntry."Dimension Set ID" := DimensionSetEntry."Dimension Set ID";
            DimensionSetEntry."Dimension Code" := DimensionCode;
            DimensionSetEntry."Dimension Value Code" := DimensionValueCode;
            DimensionSetEntry."Dimension Value ID" := DimensionValue."Dimension Value ID";

            DimensionSetEntry.Insert;
        end;
        //+NPR5.55 [399006]
    end;

    local procedure ValidateDimValue(DimCode: Code[20]; var DimValueCode: Code[20]): Boolean
    var
        DimValue: Record "Dimension Value";
    begin
        //-NPR5.55 [399006]
        if DimValueCode = '' then
            exit;

        DimValue."Dimension Code" := DimCode;
        DimValue.Code := DimValueCode;
        DimValue.Find('=><');
        if DimValueCode <> CopyStr(DimValue.Code, 1, StrLen(DimValueCode)) then
            Error(WrongDimensionValueErr, DimValueCode, DimCode);
        DimValueCode := DimValue.Code;
        //+NPR5.55 [399006]
    end;

    local procedure GetMultiLineDiscountTarget(SalePOS: Record "NPR Sale POS"; SaleLinePOS: Record "NPR Sale Line POS"; PresetMultiLineDiscTarget: Option Auto,"Positive Only","Negative Only",All,Ask; AllowAllLines: Boolean)
    var
        DefaultOptionNo: Integer;
        NoOfNegativeLines: Integer;
        NoOfPositiveLines: Integer;
        SelectedOptionNo: Integer;
        RequestMsgTxt: Text;
    begin
        //-NPR5.55 [406357]
        if PresetMultiLineDiscTarget = PresetMultiLineDiscTarget::All then begin
            MultiLineDiscTarget := MultiLineDiscTarget::"Non-Zero";
            exit;
        end;

        MultiLineDiscTarget := MultiLineDiscTarget::"Positive Only";
        ApplyFilterOnLines(SalePOS, SaleLinePOS);
        NoOfPositiveLines := SaleLinePOS.Count;

        MultiLineDiscTarget := MultiLineDiscTarget::"Negative Only";
        ApplyFilterOnLines(SalePOS, SaleLinePOS);
        NoOfNegativeLines := SaleLinePOS.Count;

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
        //+NPR5.55 [406357]
    end;

    local procedure GetSignFactor(SaleLinePOS: Record "NPR Sale Line POS"): Integer
    begin
        //-NPR5.55 [406357]
        if SaleLinePOS.Quantity < 0 then
            exit(-1);
        exit(1);
        //+NPR5.55 [406357]
    end;

    local procedure UpdateSalesVAT(POSSaleID: Integer)
    var
        SaleLinePOS: Record "NPR Sale Line POS";
    begin

        //-NPR5.55 [414829]
        if (not SaleLinePOS.SetCurrentKey("Orig. POS Sale ID")) then;

        SaleLinePOS.SetFilter("Orig. POS Sale ID", '=%1', POSSaleID);
        if (SaleLinePOS.FindSet()) then begin
            repeat
                SaleLinePOS.UpdateAmounts(SaleLinePOS);
                SaleLinePOS.Modify();
            until (SaleLinePOS.Next() = 0);
        end;
        //+NPR5.55 [414829]
    end;

    local procedure GetAdditionalParams(JSON: Codeunit "NPR POS JSON Management")
    begin
        //-NPR5.55 [418824]
        JSON.SetScope('/', true);
        ApprovedBySalespersonCode := JSON.GetString('approvedBySalesperson', false);
        DiscountReasonCode := JSON.GetString('discountReasonCode', false);
        AddDimensionCode := JSON.GetString('addDimensionCode', false);
        AddDimensionValueCode := JSON.GetString('addDimensionValueCode', false);
        //+NPR5.55 [418824]
    end;

    local procedure ApplyAdditionalParams(var SaleLinePOS: Record "NPR Sale Line POS")
    begin
        //-NPR5.55 [418824]
        if ApprovedBySalespersonCode <> '' then
            SaleLinePOS."Discount Authorised by" := ApprovedBySalespersonCode;
        if DiscountReasonCode <> '' then
            SaleLinePOS."Reason Code" := DiscountReasonCode;
        if (AddDimensionCode <> '') and (AddDimensionValueCode <> '') then
            AddDimensionToDimensionSet(SaleLinePOS, AddDimensionCode, AddDimensionValueCode);
        //+NPR5.55 [418824]
    end;

    local procedure "--- Constants"()
    begin
    end;

    local procedure "DiscType.DiscountAmt"(): Integer
    begin
        //-NPR5.44 [323000]
        exit(0);
        //+NPR5.44 [323000]
    end;

    local procedure "DiscType.DiscountPct"(): Integer
    begin
        //-NPR5.44 [323000]
        exit(1);
        //+NPR5.44 [323000]
    end;

    local procedure "DiscType.LineAmt"(): Integer
    begin
        //-NPR5.44 [323000]
        exit(2);
        //+NPR5.44 [323000]
    end;
}

