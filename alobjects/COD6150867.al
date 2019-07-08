codeunit 6150867 "POS Action - Doc. Show"
{
    // NPR5.50/MMV /20181105 CASE 300557 Created object


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Open sales document via list or from selected POS line.';
        CaptionSelectCustomer: Label 'Select Customer';
        CaptionSelectType: Label 'SelectionMethod';
        CaptionSalesView: Label 'Doc. View';
        DescSelectCustomer: Label 'Prompt for customer selection if none on sale';
        DescSelectType: Label 'Select via list or attempt to open any POS line related document.';
        DescSalesView: Label 'Pre-filtered list of sales documents';
        OptionSelectType: Label 'List,Selected Line';

    local procedure ActionCode(): Text
    begin
        exit ('SALES_DOC_SHOW');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do begin
          if DiscoverAction(
            ActionCode(),
            ActionDescription,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple) then
          begin
            RegisterWorkflowStep('ShowDoc','respond();');
            RegisterWorkflow(false);

            RegisterOptionParameter('SelectType', 'List,SelectedLine', 'List');
            RegisterTextParameter('SalesOrderViewString', '');
            RegisterBooleanParameter('SelectCustomer', true);
          end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        SelectType: Integer;
        POSSale: Codeunit "POS Sale";
        POSSaleLine: Codeunit "POS Sale Line";
        SalePOS: Record "Sale POS";
        SalesHeader: Record "Sales Header";
        SaleLinePOS: Record "Sale Line POS";
        SalesOrderViewString: Text;
        SelectCustomer: Boolean;
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        SelectType := JSON.GetIntegerParameter('SelectType', true);
        SalesOrderViewString := JSON.GetStringParameter('SalesOrderViewString', true);
        SelectCustomer := JSON.GetBooleanParameter('SelectCustomer', true);

        if not CheckCustomer(POSSession, SelectCustomer) then
          exit;

        POSSession.GetSaleLine(POSSaleLine);
        POSSession.GetSale(POSSale);

        if SelectType = 1 then begin
          POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
          if SaleLinePOS."Sales Document No." = '' then
            exit;
          SalesHeader.Get(SaleLinePOS."Sales Document Type", SaleLinePOS."Sales Document No.");
        end else begin
          POSSale.GetCurrentSale(SalePOS);
          if SalesOrderViewString <> '' then
            SalesHeader.SetView(SalesOrderViewString);
          if SalePOS."Customer No." <> '' then
            SalesHeader.SetRange("Bill-to Customer No.", SalePOS."Customer No.");
          if not LookupSalesDoc(SalesHeader) then
            exit;
        end;

        PAGE.RunModal(SalesHeader.GetCardpageID(), SalesHeader);
    end;

    local procedure LookupSalesDoc(var SalesHeader: Record "Sales Header"): Boolean
    begin
        exit(PAGE.RunModal(0, SalesHeader) = ACTION::LookupOK);
    end;

    local procedure CheckCustomer(POSSession: Codeunit "POS Session";SelectCustomer: Boolean): Boolean
    var
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
        Customer: Record Customer;
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if SalePOS."Customer No." <> '' then begin
          SalePOS.TestField("Customer Type", SalePOS."Customer Type"::Ord);
          exit(true);
        end;

        if not SelectCustomer then
          exit(true);

        if PAGE.RunModal(0, Customer) <> ACTION::LookupOK then
          exit(false);

        SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);
        POSSale.RefreshCurrent();
        Commit;
        exit(true);
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterNameCaption', '', false, false)]
    procedure OnGetParameterNameCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'SelectType' : Caption := CaptionSelectType;
          'SalesOrderViewString' : Caption := CaptionSalesView;
          'SelectCustomer' : Caption := CaptionSelectCustomer;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterDescriptionCaption', '', false, false)]
    procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'SelectType' : Caption := DescSelectType;
          'SalesOrderViewString' : Caption := DescSalesView;
          'SelectCustomer' : Caption := DescSelectCustomer;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterOptionStringCaption', '', false, false)]
    procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'SelectType' : Caption := OptionSelectType;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', false, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "POS Parameter Value";Handled: Boolean)
    var
        SalesHeader: Record "Sales Header";
        FilterPageBuilder: FilterPageBuilder;
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'SalesOrderViewString' :
            begin
              FilterPageBuilder.AddRecord(SalesHeader.TableCaption, SalesHeader);
              if POSParameterValue.Value <> '' then begin
                SalesHeader.SetView(POSParameterValue.Value);
                FilterPageBuilder.SetView(SalesHeader.TableCaption, SalesHeader.GetView(false));
              end;
              if FilterPageBuilder.RunModal then
                POSParameterValue.Value := FilterPageBuilder.GetView(SalesHeader.TableCaption, false);
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnValidateValue', '', false, false)]
    local procedure OnValidateValue(var POSParameterValue: Record "POS Parameter Value")
    var
        SalesHeader: Record "Sales Header";
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'SalesOrderViewString' :
            if POSParameterValue.Value <> '' then
              SalesHeader.SetView(POSParameterValue.Value);
        end;
    end;
}

