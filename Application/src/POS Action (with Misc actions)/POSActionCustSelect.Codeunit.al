codeunit 6150865 "NPR POS Action: Cust. Select"
{
    var
        ActionDescription: Label 'Attach or remove customer from POS sale.';
        CAPTION_OPERATION: Label 'Operation';
        CAPTION_TABLEVIEW: Label 'Customer Table View';
        CAPTION_CUSTOMERPAGE: Label 'Customer Lookup Page';
        DESC_OPERATION: Label 'Operation to perform';
        DESC_TABLEVIEW: Label 'Pre-filtered customer list';
        DESC_CUSTOMERPAGE: Label 'Custom customer lookup page';
        OPTION_OPERATION: Label 'Attach,Remove';

    local procedure ActionCode(): Text
    begin
        exit('CUSTOMER_SELECT');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.1');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
  ActionCode(),
  ActionDescription,
  ActionVersion(),
  Sender.Type::Generic,
  Sender."Subscriber Instances Allowed"::Multiple) then begin
            Sender.RegisterWorkflowStep('Select', 'respond();');
            Sender.RegisterWorkflow(false);

            Sender.RegisterOptionParameter('Operation', 'Attach,Remove', 'Attach');
            Sender.RegisterTextParameter('CustomerTableView', '');
            Sender.RegisterIntegerParameter('CustomerLookupPage', 0);
            Sender.RegisterTextParameter('customerNo', '');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        Operation: Option Attach,Remove;
        JSON: Codeunit "NPR POS JSON Management";
        CustomerTableView: Text;
        CustomerLookupPage: Integer;
        SpecificCustomerNo: Text;
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);

        CustomerTableView := JSON.GetStringParameterOrFail('CustomerTableView', ActionCode());
        CustomerLookupPage := JSON.GetIntegerParameterOrFail('CustomerLookupPage', ActionCode());
        Operation := JSON.GetIntegerParameterOrFail('Operation', ActionCode());
        SpecificCustomerNo := JSON.GetStringParameterOrFail('customerNo', ActionCode());

        case Operation of
            Operation::Attach:
                AttachCustomer(POSSession, CustomerTableView, CustomerLookupPage, SpecificCustomerNo);
            Operation::Remove:
                RemoveCustomer(POSSession);
        end;

        POSSession.RequestRefreshData();
    end;

    procedure AttachCustomer(var POSSession: Codeunit "NPR POS Session"; CustomerTableView: Text; CustomerLookupPage: Integer; SpecificCustomerNo: Text)
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        Customer: Record Customer;
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        if SpecificCustomerNo = '' then begin
            if CustomerTableView <> '' then
                Customer.SetView(CustomerTableView);

            if PAGE.RunModal(CustomerLookupPage, Customer) <> ACTION::LookupOK then
                exit;
        end else begin
            Customer."No." := SpecificCustomerNo;
        end;

        SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);
        POSSale.SetModified();
        POSSale.RefreshCurrent();
    end;

    local procedure RemoveCustomer(var POSSession: Codeunit "NPR POS Session")
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
        SalePOS.Validate("Customer No.", '');
        SalePOS.Modify(true);
        POSSale.SetModified();
        POSSale.RefreshCurrent();
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterNameCaption', '', false, false)]
    local procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'Operation':
                Caption := CAPTION_OPERATION;
            'CustomerLookupPage':
                Caption := CAPTION_CUSTOMERPAGE;
            'CustomerTableView':
                Caption := CAPTION_TABLEVIEW;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterDescriptionCaption', '', false, false)]
    local procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'Operation':
                Caption := DESC_OPERATION;
            'CustomerLookupPage':
                Caption := DESC_CUSTOMERPAGE;
            'CustomerTableView':
                Caption := DESC_TABLEVIEW;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterOptionStringCaption', '', false, false)]
    local procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'Operation':
                Caption := OPTION_OPERATION;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', false, false)]
    local procedure OnLookupParameter(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        FilterPageBuilder: FilterPageBuilder;
        Customer: Record Customer;
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'CustomerTableView':
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
    local procedure OnValidateParameter(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        PageMetadata: Record "Page Metadata";
        PageId: Integer;
        Customer: Record Customer;
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'CustomerLookupPage':
                begin
                    if (POSParameterValue.Value in ['', '0']) then
                        exit;
                    Evaluate(PageId, POSParameterValue.Value);
                    PageMetadata.SetRange(ID, PageId);
                    PageMetadata.SetRange(SourceTable, DATABASE::Customer);
                    PageMetadata.FindFirst();
                end;
            'CustomerTableView':
                begin
                    if POSParameterValue.Value <> '' then
                        Customer.SetView(POSParameterValue.Value);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    var
        Customer: Record Customer;
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if not EanBoxEvent.Get(EventCodeCustNo()) then begin
            EanBoxEvent.Init();
            EanBoxEvent.Code := EventCodeCustNo();
            EanBoxEvent."Module Name" := Customer.TableCaption;
            EanBoxEvent.Description := CopyStr(CustLedgerEntry.FieldCaption("Customer No."), 1, MaxStrLen(EanBoxEvent.Description));
            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CODEUNIT::"NPR POS Action: Cust. Select";
            EanBoxEvent.Insert(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "NPR POS Input Box Setup Mgt."; EanBoxEvent: Record "NPR Ean Box Event")
    begin
        case EanBoxEvent.Code of
            EventCodeCustNo():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'customerNo', true, '');
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'Operation', false, 'Attach');
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060107, 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeCustNo(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        Customer: Record Customer;
    begin
        if EanBoxSetupEvent."Event Code" <> EventCodeCustNo() then
            exit;
        if StrLen(EanBoxValue) > MaxStrLen(Customer."No.") then
            exit;

        if Customer.Get(UpperCase(EanBoxValue)) then
            InScope := true;
    end;

    local procedure EventCodeCustNo(): Code[20]
    begin
        exit('CUSTOMERNO');
    end;
}
