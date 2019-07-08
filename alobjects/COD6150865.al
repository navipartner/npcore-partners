codeunit 6150865 "POS Action - Customer Select"
{
    // NPR5.50/MMV /20181105 CASE 300557 Created object


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Attach or remove customer from POS sale.';
        ERRDOCTYPE: Label 'Wrong Document Type. Document Type is set to %1. It must be one of %2, %3, %4 or %5';
        ERRPARSED: Label 'SalesDocumentToPOS and SalesDocumentAmountToPOS can not be used simultaneously. This is an error in parameter setting on menu button for action %1.';
        ERRPARSEDCOMB: Label 'Import of amount is only supported for Document Type Order. This is an error in parameter setting on menu button for action %1.';
        CAPTION_OPERATION: Label 'Operation';
        CAPTION_TABLEVIEW: Label 'Customer Table View';
        CAPTION_CUSTOMERPAGE: Label 'Customer Lookup Page';
        DESC_OPERATION: Label 'Operation to perform';
        DESC_TABLEVIEW: Label 'Pre-filtered customer list';
        DESC_CUSTOMERPAGE: Label 'Custom customer lookup page';
        OPTION_OPERATION: Label 'Attach,Remove';

    local procedure ActionCode(): Text
    begin
        exit ('CUSTOMER_SELECT');
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
            RegisterWorkflowStep('Select','respond();');
            RegisterWorkflow(false);

            RegisterOptionParameter('Operation', 'Attach,Remove', 'Attach');
            RegisterTextParameter('CustomerTableView', '');
            RegisterIntegerParameter('CustomerLookupPage', 0);
          end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        Operation: Option Attach,Remove;
        JSON: Codeunit "POS JSON Management";
        CustomerTableView: Text;
        CustomerLookupPage: Integer;
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context,FrontEnd);

        CustomerTableView := JSON.GetStringParameter('CustomerTableView', true);
        CustomerLookupPage := JSON.GetIntegerParameter('CustomerLookupPage', true);
        Operation := JSON.GetIntegerParameter('Operation', true);
        case Operation of
          Operation::Attach : AttachCustomer(POSSession, CustomerTableView, CustomerLookupPage);
          Operation::Remove : RemoveCustomer(POSSession);
        end;

        POSSession.RequestRefreshData();
    end;

    procedure AttachCustomer(var POSSession: Codeunit "POS Session";CustomerTableView: Text;CustomerLookupPage: Integer)
    var
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
        Customer: Record Customer;
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        if CustomerTableView <> '' then
          Customer.SetView(CustomerTableView);

        if PAGE.RunModal(CustomerLookupPage, Customer) <> ACTION::LookupOK then
          exit;

        SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);
        POSSale.RefreshCurrent();
    end;

    local procedure RemoveCustomer(var POSSession: Codeunit "POS Session")
    var
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
        SalePOS.Validate("Customer No.", '');
        SalePOS.Modify(true);
        POSSale.RefreshCurrent();
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterNameCaption', '', false, false)]
    procedure OnGetParameterNameCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'Operation' : Caption := CAPTION_OPERATION;
          'CustomerLookupPage' : Caption := CAPTION_CUSTOMERPAGE;
          'CustomerTableView' : Caption := CAPTION_TABLEVIEW;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterDescriptionCaption', '', false, false)]
    procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'Operation' : Caption := DESC_OPERATION;
          'CustomerLookupPage' : Caption := DESC_CUSTOMERPAGE;
          'CustomerTableView' : Caption := DESC_TABLEVIEW;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterOptionStringCaption', '', false, false)]
    procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'Operation' : Caption := OPTION_OPERATION;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', false, false)]
    local procedure OnLookupParameter(var POSParameterValue: Record "POS Parameter Value";Handled: Boolean)
    var
        FilterPageBuilder: FilterPageBuilder;
        Customer: Record Customer;
        AllObj: Record AllObj;
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'CustomerTableView' :
            begin
              FilterPageBuilder.AddRecord(Customer.TableCaption, Customer);
              if POSParameterValue.Value <> '' then begin
                Customer.SetView(POSParameterValue.Value);
                FilterPageBuilder.SetView(Customer.TableCaption, Customer.GetView(false));
              end;
              if FilterPageBuilder.RunModal() then
                POSParameterValue.Value := FilterPageBuilder.GetView(Customer.TableCaption, false);
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnValidateValue', '', false, false)]
    local procedure OnValidateParameter(var POSParameterValue: Record "POS Parameter Value")
    var
        PageMetadata: Record "Page Metadata";
        PageId: Integer;
        Customer: Record Customer;
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'CustomerLookupPage' :
            begin
              if POSParameterValue.Value = '' then
                exit;
              Evaluate(PageId, POSParameterValue.Value);
              PageMetadata.SetRange(ID, PageId);
              PageMetadata.SetRange(SourceTable, DATABASE::Customer);
              PageMetadata.FindFirst;
            end;
          'CustomerTableView' :
            begin
              if POSParameterValue.Value <> '' then
                Customer.SetView(POSParameterValue.Value);
            end;
        end;
    end;
}

