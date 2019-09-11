codeunit 6150792 "POS Action - Discount"
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

    local procedure ActionCode(): Text
    begin
        exit ('DISCOUNT');
    end;

    local procedure ActionVersion(): Text
    begin
        //-NPR5.45 [317065]
        exit('1.2');
        //+NPR5.45 [317065]
        exit ('1.1');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
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
            //-NPR5.45 [317065]
            //RegisterWorkflowStep('1','if (param.FixedDiscountNumber == 0 && param.DiscountType < 9)  { numpad(labels["DiscountLabel" + param.DiscountType]).respond("quantity"); }');
            //RegisterWorkflowStep('2','if (param.FixedDiscountNumber != 0 || param.DiscountType >= 9) { context.quantity = param.FixedDiscountNumber; respond("quantity"); }');
            RegisterWorkflowStep('fixed_input','if (param.FixedDiscountNumber != 0) { context.quantity = param.FixedDiscountNumber; }');
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
            //-NPR5.38 [302220]
            RegisterWorkflowStep('FixedReasonCode','if (param.FixedReasonCode != "")  {respond()}');
            RegisterWorkflowStep('LookupReasonCode','if (param.LookupReasonCode)  {respond()}');
            //+NPR5.38 [302220]

            //-NPR5.39 [305139]
            RegisterOptionParameter('Security','None,SalespersonPassword,CurrentSalespersonPassword,SupervisorPassword','None');
            //+NPR5.39 [305139]
            RegisterOptionParameter('DiscountType',
              'TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,' +
              //-NPR5.40 [306347]
              'LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount'
              //+NPR5.40 [306347]
              //-NPR5.45 [317065]
              + ',DiscountPercentExtra,LineDiscountPercentExtra'
              //+NPR5.45 [317065]
              ,'TotalDiscountAmount');
            //-NPR5.32.11
            RegisterDecimalParameter('FixedDiscountNumber', 0);
            //+NPR5.32.11
            //-NPR5.38 [302220]
            RegisterTextParameter('FixedReasonCode','');
            RegisterBooleanParameter('LookupReasonCode',false);
            //+NPR5.38 [302220]
            RegisterDataBinding();
            RegisterWorkflow(true);
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', false, false)]
    local procedure OnBeforeWorkflow("Action": Record "POS Action";POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
        Captions.AddActionCaption (ActionCode(), 'DiscountLabel0', TotalAmountLabel);
        Captions.AddActionCaption (ActionCode(), 'DiscountLabel1', TotalDiscountAmountLabel);
        Captions.AddActionCaption (ActionCode(), 'DiscountLabel2', DiscountPercentABSLabel);
        Captions.AddActionCaption (ActionCode(), 'DiscountLabel3', DiscountPercentRELLabel);
        Captions.AddActionCaption (ActionCode(), 'DiscountLabel4', LineAmountLabel);
        Captions.AddActionCaption (ActionCode(), 'DiscountLabel5', LineDiscountAmountLabel);
        Captions.AddActionCaption (ActionCode(), 'DiscountLabel6', LineDiscountPercentABSLabel);
        Captions.AddActionCaption (ActionCode(), 'DiscountLabel7', LineDiscountPercentRELLabel);
        Captions.AddActionCaption (ActionCode(), 'DiscountLabel8', LineUnitPriceLabel);
        //-NPR5.45 [317065]
        Captions.AddActionCaption(ActionCode(),'DiscountLabel11',DiscountPercentExtraLabel);
        Captions.AddActionCaption(ActionCode(),'DiscountLabel12',LineDiscountPercentExtraLabel);
        //+NPR5.45 [317065]
        //-NPR5.39 [305139]
        Captions.AddActionCaption(ActionCode(),'DiscountAuthorisationTitle',Text000);
        Captions.AddActionCaption(ActionCode(),'SalespersonPasswordLabel',Text001);
        Captions.AddActionCaption(ActionCode(),'CurrentSalespersonPasswordLabel',Text002);
        Captions.AddActionCaption(ActionCode(),'SupervisorPasswordLabel',Text003);
        //+NPR5.39 [305139]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        POSSaleLine: Codeunit "POS Sale Line";
        Quantity: Decimal;
        POSSale: Codeunit "POS Sale";
        DiscountType: Integer;
        SalePOS: Record "Sale POS";
        SaleLinePOS: Record "Sale Line POS";
        View: DotNet npNetView0;
        TotalPrice: Decimal;
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        //-NPR5.38 [302220]
        case WorkflowStep of
          //-NPR5.39 [305139]
          'SalespersonPassword':
            begin
              Handled := true;
              OnActionSalespersonPassword(JSON,POSSession);
              exit;
            end;
          'CurrentSalespersonPassword':
            begin
              Handled := true;
              OnActionCurrentSalespersonPassword(JSON,POSSession);
              exit;
            end;
          'SupervisorPassword':
            begin
              Handled := true;
              OnActionSupervisorPassword(JSON,POSSession);
              exit;
            end;
          //+NPR5.39 [305139]
          'FixedReasonCode':
            begin
              Handled := true;
              OnActionFixedReasonCode(JSON,POSSession);
              exit;
            end;
          'LookupReasonCode':
            begin
              Handled := true;
              OnActionLookupReasonCode(JSON,POSSession);
              exit;
            end;
        end;
        //+NPR5.38 [302220]
        Quantity := JSON.GetDecimal('quantity',true);
        JSON.SetScope('parameters',true);
        DiscountType := JSON.GetInteger('DiscountType',true);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        POSSession.GetCurrentView(View);

        TotalPrice  := GetLinesTotalDiscountableValue(SalePOS);

        //-NPR5.32.11 [279495]
        case DiscountType of
          0,1,4,5 : // Amount based functions
            if (TotalPrice < Quantity) then
              Error(DiscountAmountErr);
          2,3,6,7: // Percentage based functions
            if (Quantity < 0) or (Quantity > 100) then
              Error(DiscountPercentError);
          8: ;    // [282117] No check for unit price
          9,10: ; // Clear functions
        end;

        case DiscountType of
          0 : SetTotalAmount(SalePOS,Quantity);
          1 : SetTotalDiscountAmount(SalePOS,Quantity);
          2 : SetDiscountPctABS(SalePOS,Quantity);
          3 : SetDiscountPctREL(SalePOS,Quantity);
          //-NPR5.44 [323000]
          //4 : SetLineAmount(SalePOS,SaleLinePOS,Quantity,View,0);
          4 : SetLineAmount(SaleLinePOS,Quantity);
          //+NPR5.44 [323000]
          5 : SetLineDiscountAmount(SaleLinePOS,Quantity);
          6 : SetLineDiscountPctABS(SaleLinePOS,Quantity);
          7 : SetLineDiscountPctREL(SaleLinePOS,Quantity);
          8 : SetLineUnitPrice(SaleLinePOS,Quantity);
          9 : SetLineDiscountAmount (SaleLinePOS, 0);
          10: SetTotalDiscountAmount (SalePOS, 0);
          //-NPR5.45 [317065]
          11: SetDiscountPctExtra(SalePOS,Quantity);
          12: SetLineDiscountPctExtra(SaleLinePOS,Quantity);
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

    local procedure OnActionSalespersonPassword(JSON: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session")
    var
        Salesperson: Record "Salesperson/Purchaser";
        SalespersonPassword: Text;
        DiscountType: Integer;
    begin
        //-NPR5.39 [305139]
        SalespersonPassword := JSON.GetString('SalespersonPassword',true);
        Salesperson.SetRange("Register Password",SalespersonPassword);
        if not Salesperson.FindFirst then
          Error(Text004);

        JSON.SetScope('parameters',true);
        DiscountType := JSON.GetInteger('DiscountType',true);
        case DiscountType of
          0,1,2,3,10:
            ApplyApprovedBy(Salesperson.Code,true,POSSession);
          4,5,6,7,8,9:
            ApplyApprovedBy(Salesperson.Code,false,POSSession);
        end;

        POSSession.RequestRefreshData();
        //+NPR5.39 [305139]
    end;

    local procedure OnActionCurrentSalespersonPassword(JSON: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session")
    var
        Salesperson: Record "Salesperson/Purchaser";
        SalePOS: Record "Sale POS";
        POSSale: Codeunit "POS Sale";
        SalespersonPassword: Text;
        DiscountType: Integer;
    begin
        //-NPR5.39 [305139]
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalespersonPassword := JSON.GetString('CurrentSalespersonPassword',true);

        Salesperson.SetRange(Code,SalePOS."Salesperson Code");
        Salesperson.SetRange("Register Password",SalespersonPassword);
        if not Salesperson.FindFirst then
          Error(Text004);

        JSON.SetScope('parameters',true);
        DiscountType := JSON.GetInteger('DiscountType',true);
        case DiscountType of
          0,1,2,3,10:
            ApplyApprovedBy(Salesperson.Code,true,POSSession);
          4,5,6,7,8,9:
            ApplyApprovedBy(Salesperson.Code,false,POSSession);
        end;

        POSSession.RequestRefreshData();
        //+NPR5.39 [305139]
    end;

    local procedure OnActionSupervisorPassword(JSON: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session")
    var
        Salesperson: Record "Salesperson/Purchaser";
        SupervisorPassword: Text;
        DiscountType: Integer;
    begin
        //-NPR5.39 [305139]
        SupervisorPassword := JSON.GetString('SupervisorPassword',true);
        Salesperson.SetRange("Register Password",SupervisorPassword);
        Salesperson.SetRange("Supervisor POS",true);
        if not Salesperson.FindFirst then
          Error(Text004);

        JSON.SetScope('parameters',true);
        DiscountType := JSON.GetInteger('DiscountType',true);
        case DiscountType of
          0,1,2,3,10:
            ApplyApprovedBy(Salesperson.Code,true,POSSession);
          4,5,6,7,8,9:
            ApplyApprovedBy(Salesperson.Code,false,POSSession);
        end;

        POSSession.RequestRefreshData();
        //+NPR5.39 [305139]
    end;

    local procedure OnActionFixedReasonCode(JSON: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session")
    var
        ReasonCode: Code[10];
        DiscountType: Integer;
    begin
        //-NPR5.38 [302220]
        JSON.SetScope('parameters',true);
        ReasonCode := JSON.GetString('FixedReasonCode',true);
        DiscountType := JSON.GetInteger('DiscountType',true);
        if ReasonCode = '' then
          exit;
        case DiscountType of
          0,1,2,3,10:
            ApplyReasonCode(ReasonCode,true,POSSession);
          4,5,6,7,8,9:
            ApplyReasonCode(ReasonCode,false,POSSession);
        end;
        //+NPR5.38 [302220]
    end;

    local procedure OnActionLookupReasonCode(JSON: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session")
    var
        ReasonCode: Record "Reason Code";
        DiscountType: Integer;
    begin
        //-NPR5.38 [302220]
        if PAGE.RunModal(0,ReasonCode) <> ACTION::LookupOK then
          exit;

        JSON.SetScope('parameters',true);
        DiscountType := JSON.GetInteger('DiscountType',true);
        case DiscountType of
          0,1,2,3,10:
            ApplyReasonCode(ReasonCode.Code,true,POSSession);
          4,5,6,7,8,9:
            ApplyReasonCode(ReasonCode.Code,false,POSSession);
        end;
        //+NPR5.38 [302220]
    end;

    local procedure "-- Locals --"()
    begin
    end;

    local procedure ApplyDiscountOnLines(var SalePOS: Record "Sale POS";DiscountType: Option DiscountAmt,DiscountPct,LineAmt;Discount: Decimal)
    var
        SaleLinePOS: Record "Sale Line POS";
    begin
        //-NPR5.44 [323000]
        ApplyFilterOnLines(SalePOS,SaleLinePOS);
        if not SaleLinePOS.FindSet then
          exit;

        repeat
          ApplyDiscountOnLine(SaleLinePOS,DiscountType,Discount);
        until SaleLinePOS.Next = 0;
        //+NPR5.44 [323000]
    end;

    local procedure ApplyDiscountOnLine(var SaleLinePOS: Record "Sale Line POS";DiscountType: Option DiscountAmt,DiscountPct,LineAmt;Discount: Decimal)
    var
        PrevRec: Text;
    begin
        //-NPR5.44 [323000]
        if SaleLinePOS."Custom Disc Blocked" then
          exit;
        if SaleLinePOS."Amount Including VAT" < 0 then
          exit;

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

        SaleLinePOS.UpdateAmounts(SaleLinePOS);

        if PrevRec <> Format(SaleLinePOS) then
          SaleLinePOS.Modify;
        //+NPR5.44 [323000]
    end;

    local procedure ApplyFilterOnLines(var SalePOS: Record "Sale POS";var SaleLinePOS: Record "Sale Line POS")
    begin
        SaleLinePOS.SetRange( "Register No.", SalePOS."Register No." );
        SaleLinePOS.SetRange( "Sales Ticket No.", SalePOS."Sales Ticket No." );
        SaleLinePOS.SetRange( "Sale Type", SaleLinePOS."Sale Type"::Sale );
        SaleLinePOS.SetRange( Type, SaleLinePOS.Type::Item );
        SaleLinePOS.SetFilter(Quantity,'>%1',0);
        //-NPR5.44 [323000]
        SaleLinePOS.SetRange("Custom Disc Blocked",false);
        //+NPR5.44 [323000]
    end;

    local procedure RecalculateVatOnLines(var SalePOS: Record "Sale POS")
    var
        SaleLinePOS: Record "Sale Line POS";
        PrevRec: Text;
    begin

        //-NPR5.48 [338181]
        ApplyFilterOnLines (SalePOS, SaleLinePOS);
        if (not SaleLinePOS.FindSet()) then
          exit;

        repeat
          PrevRec := Format (SaleLinePOS);
          SaleLinePOS.UpdateAmounts (SaleLinePOS);

          if (PrevRec <> Format (SaleLinePOS)) then
            SaleLinePOS.Modify;

        until (SaleLinePOS.Next() = 0);
        //+NPR5.48 [338181]
    end;

    local procedure GetLinesTotalValue(var SalePOS: Record "Sale POS") TotalLineValue: Decimal
    var
        SaleLinePOS: Record "Sale Line POS";
    begin
        ApplyFilterOnLines(SalePOS,SaleLinePOS);

        if SaleLinePOS.FindSet then repeat
          if SaleLinePOS."Price Includes VAT" then
            TotalLineValue +=  SaleLinePOS.Quantity * SaleLinePOS."Unit Price"
          else
            TotalLineValue += SaleLinePOS.Quantity * ( SaleLinePOS."Unit Price" * ( ( 100 + SaleLinePOS."VAT %" ) / 100) );
        until SaleLinePOS.Next = 0;
    end;

    local procedure GetLinesTotalDiscountableValue(var SalePOS: Record "Sale POS") TotalLineValue: Decimal
    var
        SaleLinePOS: Record "Sale Line POS";
    begin
        ApplyFilterOnLines(SalePOS,SaleLinePOS);

        if SaleLinePOS.FindSet then repeat
          if not (SaleLinePOS."Custom Disc Blocked") then begin

            if SaleLinePOS."Price Includes VAT" then
              TotalLineValue +=  SaleLinePOS.Quantity * SaleLinePOS."Unit Price"
            else
              TotalLineValue += SaleLinePOS.Quantity * ( SaleLinePOS."Unit Price" * ( ( 100 + SaleLinePOS."VAT %" ) / 100) );

          end else begin

            if SaleLinePOS."Price Includes VAT" then
              TotalLineValue += SaleLinePOS."Amount Including VAT"
            else
              //-NPR5.48 [338181]
              //TotalLineValue += SaleLinePOS."Amount Including VAT" * ( 100 + SaleLinePOS."VAT %" ) / 100;
              TotalLineValue += SaleLinePOS.Amount * ( 100 + SaleLinePOS."VAT %" ) / 100;
              //+NPR5.48 [338181]

          end;
        until SaleLinePOS.Next = 0;
    end;

    local procedure SetTotalDiscountAmount(var SalePOS: Record "Sale POS";TotalDiscountAmount: Decimal)
    var
        SaleLinePOS: Record "Sale Line POS";
        TotalPrice: Decimal;
        DiscountPct: Decimal;
    begin
        ApplyFilterOnLines(SalePOS,SaleLinePOS);

        TotalPrice  := GetLinesTotalDiscountableValue(SalePOS);
        DiscountPct := TotalDiscountAmount / TotalPrice * 100;

        //-NPR5.44 [323000]
        ApplyDiscountOnLines(SalePOS,"DiscType.DiscountPct",DiscountPct);
        //+NPR5.44 [323000]

        //-NPR5.37 [293113]
        AdjustRoundingForTotalAmountDiscount (SalePOS, (TotalPrice - TotalDiscountAmount));
        //+NPR5.37 [293113]
    end;

    local procedure SetTotalAmount(var SalePOS: Record "Sale POS";Amount: Decimal)
    var
        t001: Label 'Total Amount entered must be less than the Sale Total!';
        DiscountPct: Decimal;
        TotalPrice: Decimal;
    begin
        TotalPrice  := GetLinesTotalDiscountableValue(SalePOS);
        DiscountPct := (TotalPrice - Amount) / TotalPrice * 100;
        if DiscountPct < 0 then
          Error(t001);

        //-NPR5.44 [323000]
        ApplyDiscountOnLines(SalePOS,"DiscType.DiscountPct",DiscountPct);
        //+NPR5.44 [323000]

        //-NPR5.37 [293113]
        AdjustRoundingForTotalAmountDiscount (SalePOS, Amount);
        //+NPR5.37 [293113]
    end;

    local procedure SetDiscountPctABS(SalePOS: Record "Sale POS";DiscountPct: Decimal)
    begin
        //-NPR5.44 [323000]
        ApplyDiscountOnLines(SalePOS,"DiscType.DiscountPct",DiscountPct);
        //+NPR5.44 [323000]
    end;

    local procedure SetDiscountPctREL(SalePOS: Record "Sale POS";DiscountPct: Decimal)
    var
        SaleLinePOS: Record "Sale Line POS";
        RelativeDiscountPct: Decimal;
    begin
        //-NPR5.44 [323000]
        ApplyFilterOnLines(SalePOS,SaleLinePOS);
        if not SaleLinePOS.FindSet then
          exit;

        repeat
          RelativeDiscountPct := (1 - (1 - SaleLinePOS."Discount %" / 100) * (1 - DiscountPct / 100)) * 100;
          ApplyDiscountOnLine(SaleLinePOS,"DiscType.DiscountPct",RelativeDiscountPct);
        until SaleLinePOS.Next = 0;
        //+NPR5.44 [323000]
    end;

    local procedure SetDiscountPctExtra(SalePOS: Record "Sale POS";ExtraDiscountPct: Decimal)
    var
        SaleLinePOS: Record "Sale Line POS";
        NewDiscountPct: Decimal;
    begin
        //-NPR5.45 [317065]
        ApplyFilterOnLines(SalePOS,SaleLinePOS);
        if not SaleLinePOS.FindSet then
          exit;

        repeat
          NewDiscountPct := SaleLinePOS."Discount %" + ExtraDiscountPct;
          ApplyDiscountOnLine(SaleLinePOS,"DiscType.DiscountPct",NewDiscountPct);
        until SaleLinePOS.Next = 0;
        //+NPR5.45 [317065]
    end;

    procedure SetLineAmount(var SaleLinePOS: Record "Sale Line POS";LineAmount: Decimal)
    begin
        //-NPR5.44 [323000]
        ApplyDiscountOnLine(SaleLinePOS,"DiscType.LineAmt",LineAmount);
        //+NPR5.44 [323000]
    end;

    local procedure SetLineDiscountAmount(var SaleLinePOS: Record "Sale Line POS";DiscountAmount: Decimal)
    begin
        //-NPR5.44 [323000]
        ApplyDiscountOnLine(SaleLinePOS,"DiscType.DiscountAmt",DiscountAmount);
        //+NPR5.44 [323000]
    end;

    local procedure SetLineDiscountPctABS(var SaleLinePOS: Record "Sale Line POS";DiscountPct: Decimal)
    begin
        //-NPR5.44 [323000]
        ApplyDiscountOnLine(SaleLinePOS,"DiscType.DiscountPct",DiscountPct);
        //+NPR5.44 [323000]
    end;

    local procedure SetLineDiscountPctREL(var SaleLinePOS: Record "Sale Line POS";DiscountPct: Decimal)
    var
        RelativeDiscountPct: Decimal;
    begin
        //-NPR5.44 [323000]
        RelativeDiscountPct := (1 - (1 - SaleLinePOS."Discount %" / 100) * (1 - DiscountPct / 100)) * 100;
        ApplyDiscountOnLine(SaleLinePOS,"DiscType.DiscountPct",RelativeDiscountPct);
        //+NPR5.44 [323000]
    end;

    local procedure SetLineDiscountPctExtra(var SaleLinePOS: Record "Sale Line POS";ExtraDiscountPct: Decimal)
    var
        NewDiscountPct: Decimal;
    begin
        //+NPR5.45 [317065]
        NewDiscountPct := SaleLinePOS."Discount %" + ExtraDiscountPct;
        ApplyDiscountOnLine(SaleLinePOS,"DiscType.DiscountPct",NewDiscountPct);
        //+NPR5.45 [317065]
    end;

    local procedure SetLineUnitPrice(var SaleLinePOS: Record "Sale Line POS";UnitPrice: Decimal)
    var
        PrevRec: Text;
    begin
        //-NPR5.50 [352178]
        if not (SaleLinePOS."Sale Type" in [SaleLinePOS."Sale Type"::Sale,SaleLinePOS."Sale Type"::"Debit Sale"]) then
          Error(Text005,SaleLinePOS."Sale Type");
        if SaleLinePOS.Type = SaleLinePOS.Type::Comment then
          Error(Text005,SaleLinePOS.Type);
        //+NPR5.50 [352178]
        //-NPR5.44 [323000]
        PrevRec := Format(SaleLinePOS);

        SaleLinePOS."Unit Price" := UnitPrice;
        SaleLinePOS.UpdateAmounts(SaleLinePOS);

        if PrevRec <> Format(SaleLinePOS) then
          SaleLinePOS.Modify;
        //+NPR5.44 [323000]
    end;

    local procedure AdjustRoundingForTotalAmountDiscount(var SalePOS: Record "Sale POS";Amount: Decimal)
    var
        SaleLinePOS: Record "Sale Line POS";
        TotalLineValue: Decimal;
    begin

        //-NPR5.37 [293113]
        ApplyFilterOnLines(SalePOS,SaleLinePOS);
        if (SaleLinePOS.FindSet ()) then begin
          repeat

            //-NPR5.48 [338181]
            //    IF SaleLinePOS."Price Includes VAT" THEN
            //      TotalLineValue += SaleLinePOS."Amount Including VAT"
            //    ELSE
            //      TotalLineValue += SaleLinePOS."Amount Including VAT" * ( 100 + SaleLinePOS."VAT %" ) / 100;

            if not (SaleLinePOS."Custom Disc Blocked") then begin

              if SaleLinePOS."Price Includes VAT" then
                TotalLineValue +=  SaleLinePOS.Quantity * SaleLinePOS."Unit Price" - SaleLinePOS."Discount Amount"
              else
                TotalLineValue += SaleLinePOS.Quantity * ( SaleLinePOS."Unit Price" * ( ( 100 + SaleLinePOS."VAT %" ) / 100) ) - (SaleLinePOS."Discount Amount" * ( ( 100 + SaleLinePOS."VAT %" ) / 100) )

            end else begin

              // Amount fields on all lines need to reflect the applied discount before adjusting last line
              //RecalculateVatOnLines (SalePOS);

              if SaleLinePOS."Price Includes VAT" then
                TotalLineValue += SaleLinePOS."Amount Including VAT"
              else
                TotalLineValue += SaleLinePOS.Amount * ( 100 + SaleLinePOS."VAT %" ) / 100;
            end;
            //+NPR5.48 [338181]

          until (SaleLinePOS.Next () = 0);

          if (TotalLineValue <> Amount) then
            SetLineDiscountAmount (SaleLinePOS, SaleLinePOS."Discount Amount" + (TotalLineValue - Amount));
        end;
        //+NPR5.37 [293113]
    end;

    local procedure ApplyApprovedBy(SalespersonCode: Code[10];ApplyOnAllLines: Boolean;POSSession: Codeunit "POS Session")
    var
        SalePOS: Record "Sale POS";
        SaleLinePOS: Record "Sale Line POS";
        POSSaleLine: Codeunit "POS Sale Line";
        POSSale: Codeunit "POS Sale";
    begin
        //-NPR5.39 [305139]
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        SaleLinePOS.SetSkipCalcDiscount(true);
        if not ApplyOnAllLines then begin
          SaleLinePOS."Discount Authorised by" := SalespersonCode;
          SaleLinePOS.Modify(true);
          exit;
        end;

        ApplyFilterOnLines(SalePOS,SaleLinePOS);
        SaleLinePOS.ModifyAll("Discount Authorised by",SalespersonCode,true);
        //+NPR5.39 [305139]
    end;

    local procedure ApplyReasonCode(ReasonCode: Code[10];ApplyOnAllLines: Boolean;var POSSession: Codeunit "POS Session")
    var
        SalePOS: Record "Sale POS";
        SaleLinePOS: Record "Sale Line POS";
        POSSaleLine: Codeunit "POS Sale Line";
        POSSale: Codeunit "POS Sale";
    begin
        //-NPR5.38 [302220]
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        SaleLinePOS.SetSkipCalcDiscount(true);
        if not ApplyOnAllLines then begin
          SaleLinePOS."Reason Code" := ReasonCode;
          SaleLinePOS.Modify(true);
          exit;
        end;

        ApplyFilterOnLines(SalePOS,SaleLinePOS);
        SaleLinePOS.ModifyAll("Reason Code",ReasonCode,true);
        //+NPR5.38 [302220]
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

