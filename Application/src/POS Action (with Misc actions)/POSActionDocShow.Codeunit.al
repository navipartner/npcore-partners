codeunit 6150867 "NPR POS Action: Doc. Show"
{
    var
        ActionDescription: Label 'Open sales document via list or from selected POS line.';
        CaptionSelectCustomer: Label 'Select Customer';
        CaptionSelectType: Label 'SelectionMethod';
        CaptionSalesView: Label 'Doc. View';
        DescSelectCustomer: Label 'Prompt for customer selection if none on sale';
        DescSelectType: Label 'Select via list or attempt to open any POS line related document.';
        DescSalesView: Label 'Pre-filtered list of sales documents';
        OptionSelectType: Label 'List,Selected Line';

    local procedure ActionCode(): Code[20]
    begin
        exit('SALES_DOC_SHOW');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
            ActionCode(),
            ActionDescription,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple) then begin
            Sender.RegisterWorkflowStep('ShowDoc', 'respond();');
            Sender.RegisterWorkflow(false);

            Sender.RegisterOptionParameter('SelectType', 'List,SelectedLine', 'List');
            Sender.RegisterTextParameter('SalesOrderViewString', '');
            Sender.RegisterBooleanParameter('SelectCustomer', true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        SelectType: Integer;
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        SalesHeader: Record "Sales Header";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalesOrderViewString: Text;
        SelectCustomer: Boolean;
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        SelectType := JSON.GetIntegerParameterOrFail('SelectType', ActionCode());
        SalesOrderViewString := JSON.GetStringParameterOrFail('SalesOrderViewString', ActionCode());
        SelectCustomer := JSON.GetBooleanParameterOrFail('SelectCustomer', ActionCode());

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

    local procedure CheckCustomer(POSSession: Codeunit "NPR POS Session"; SelectCustomer: Boolean): Boolean
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
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
        Commit();
        exit(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterNameCaption', '', false, false)]
    local procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'SelectType':
                Caption := CaptionSelectType;
            'SalesOrderViewString':
                Caption := CaptionSalesView;
            'SelectCustomer':
                Caption := CaptionSelectCustomer;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterDescriptionCaption', '', false, false)]
    local procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'SelectType':
                Caption := DescSelectType;
            'SalesOrderViewString':
                Caption := DescSalesView;
            'SelectCustomer':
                Caption := DescSelectCustomer;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterOptionStringCaption', '', false, false)]
    local procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'SelectType':
                Caption := OptionSelectType;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        SalesHeader: Record "Sales Header";
        FilterPageBuilder: FilterPageBuilder;
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'SalesOrderViewString':
                begin
                    FilterPageBuilder.AddRecord(SalesHeader.TableCaption, SalesHeader);
                    if POSParameterValue.Value <> '' then begin
                        SalesHeader.SetView(POSParameterValue.Value);
                        FilterPageBuilder.SetView(SalesHeader.TableCaption, SalesHeader.GetView(false));
                    end;
                    if FilterPageBuilder.RunModal() then
                        POSParameterValue.Value := CopyStr(FilterPageBuilder.GetView(SalesHeader.TableCaption, false), 1, MaxStrLen(POSParameterValue.Value));
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', false, false)]
    local procedure OnValidateValue(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        SalesHeader: Record "Sales Header";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'SalesOrderViewString':
                if POSParameterValue.Value <> '' then
                    SalesHeader.SetView(POSParameterValue.Value);
        end;
    end;
}
