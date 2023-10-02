codeunit 6150865 "NPR POS Action: Cust. Select" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        ParameterOperation_OptionsLbl: Label 'Attach,Remove', Locked = true;

    local procedure ActionCode(): Code[20]
    begin
        exit(Format(enum::"NPR POS Workflow"::CUSTOMER_SELECT));
    end;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This is a built-in action to attach or remove customer from POS sale.';
        ParameterCustomerLookupPage_NameCaptionLbl: Label 'Customer Lookup Page';
        ParameterCustomerLookupPage_NameDescriptionLbl: Label 'Custom customer lookup page';
        ParameterCustomerNo_NameCaptionLbl: Label 'Customer No.';
        ParameterCustomerNo_NameDescriptionLbl: Label 'Pre-defined customer number';
        ParameterCustomerTableView_NameCaptionLbl: Label 'Customer Table View';
        ParameterCustomerTableView_NameDescriptionLbl: Label 'Pre-filtered customer list';
        ParameterOperation_NameCaptionLbl: Label 'Operation';
        ParameterOperation_NameDescriptionLbl: Label 'Operation to perform';
        ParameterOperation_OptionCaptionsLbl: Label 'Attach,Remove';
        ParameterCheckCustBalanceCaptionLbl: Label 'Check Customer Balance Overdue';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddOptionParameter(
            ParameterOperation_Name(),
            ParameterOperation_OptionsLbl,
#pragma warning disable AA0139
            SelectStr(1, ParameterOperation_OptionsLbl),
#pragma warning restore 
            ParameterOperation_NameCaptionLbl,
            ParameterOperation_NameDescriptionLbl,
            ParameterOperation_OptionCaptionsLbl);
        WorkflowConfig.AddTextParameter(ParameterCustomerTableView_Name(), '', ParameterCustomerTableView_NameCaptionLbl, ParameterCustomerTableView_NameDescriptionLbl);
        WorkflowConfig.AddIntegerParameter(ParameterCustomerLookupPage_Name(), 0, ParameterCustomerLookupPage_NameCaptionLbl, ParameterCustomerLookupPage_NameDescriptionLbl);
        WorkflowConfig.AddTextParameter(ParameterCustomerNo_Name(), '', ParameterCustomerNo_NameCaptionLbl, ParameterCustomerNo_NameDescriptionLbl);
        WorkflowConfig.AddBooleanParameter(ParameterCheckCustomerBalance_Name(), false, ParameterCheckCustBalanceCaptionLbl, ParameterCheckCustBalanceCaptionLbl);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionCustSelect.js###
'let main=async({})=>await workflow.respond();'
        );
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        SalePOS: Record "NPR POS Sale";
        PosActionBusinessLogic: Codeunit "NPR POS Action: Cust. Select-B";
        Operation: Option Attach,Remove;
        CustomerLookupPage: Integer;
        CustomerTableView: Text;
        SpecificCustomerNo: Text;
        CustomerOverdueCheck: Boolean;
        SelectReq: Boolean;

    begin
        CustomerTableView := Context.GetStringParameter(ParameterCustomerTableView_Name());
        CustomerLookupPage := Context.GetIntegerParameter(ParameterCustomerLookupPage_Name());
        Operation := Context.GetIntegerParameter(ParameterOperation_Name());
        SpecificCustomerNo := Context.GetStringParameter(ParameterCustomerNo_Name());
        CustomerOverdueCheck := Context.GetBooleanParameter(ParameterCheckCustomerBalance_Name());

        GetCustomParam(Context, SelectReq);

        Sale.GetCurrentSale(SalePOS);
        case Operation of
            Operation::Attach:
                If SelectReq then
                    PosActionBusinessLogic.AttachCustomerRequired(SalePOS)
                else
                    PosActionBusinessLogic.AttachCustomer(SalePOS, CustomerTableView, CustomerLookupPage, SpecificCustomerNo, CustomerOverdueCheck);
            Operation::Remove:
                PosActionBusinessLogic.RemoveCustomer(SalePOS);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupParameter(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        FilterPageBuilder: FilterPageBuilder;
        AllObjwithCap: Record AllObjWithCaption;
        Customer: Record Customer;
        PageMetadata: Record "Page Metadata";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            ParameterCustomerTableView_Name():
                begin
                    FilterPageBuilder.AddRecord(Customer.TableCaption, Customer);
                    if POSParameterValue.Value <> '' then begin
                        Customer.SetView(POSParameterValue.Value);
                        FilterPageBuilder.SetView(Customer.TableCaption, Customer.GetView(false));
                    end;
                    if FilterPageBuilder.RunModal() then
                        POSParameterValue.Value := CopyStr(FilterPageBuilder.GetView(Customer.TableCaption, false), 1, MaxStrLen(POSParameterValue.Value));
                end;

            ParameterCustomerNo_Name():
                begin
                    if POSParameterValue.Value <> '' then begin
                        Customer."No." := CopyStr(POSParameterValue.Value, 1, MaxStrLen(Customer."No."));
                        if Customer.Find('=><') then;
                    end;
                    if Page.RunModal(0, Customer) = Action::LookupOK then
                        POSParameterValue.Value := Customer."No.";
                end;

            ParameterCustomerLookupPage_Name():
                begin
                    PageMetadata.SetRange(SourceTable, DATABASE::Customer);
                    PageMetadata.SetFilter(PageType, '%1|%2', PageMetadata.PageType::List, PageMetadata.PageType::ListPlus);
                    if PageMetadata.FindSet() then
                        repeat
                            AllObjwithCap."Object Type" := AllObjwithCap."Object Type"::Page;
                            AllObjwithCap."Object ID" := PageMetadata.ID;
                            if AllObjwithCap.Find() then
                                AllObjwithCap.Mark(true);
                        until PageMetadata.Next() = 0;
                    AllObjwithCap.MarkedOnly(true);

                    if POSParameterValue.Value <> '' then
                        if Evaluate(AllObjwithCap."Object ID", POSParameterValue.Value) then begin
                            AllObjwithCap."Object Type" := AllObjwithCap."Object Type"::Page;
                            if AllObjwithCap.Find('=><') then;
                        end;
                    if Page.RunModal(Page::Objects, AllObjwithCap) = Action::LookupOK then
                        POSParameterValue.Value := Format(AllObjwithCap."Object ID");
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', false, false)]
    local procedure OnValidateParameter(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        PageMetadata: Record "Page Metadata";
        PageId: Integer;
        Customer: Record Customer;
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            ParameterCustomerLookupPage_Name():
                begin
                    if (POSParameterValue.Value in ['', '0']) then
                        exit;
                    Evaluate(PageId, POSParameterValue.Value);
                    PageMetadata.SetRange(ID, PageId);
                    PageMetadata.SetRange(SourceTable, DATABASE::Customer);
                    PageMetadata.FindFirst();
                end;

            ParameterCustomerTableView_Name():
                begin
                    if POSParameterValue.Value <> '' then
                        Customer.SetView(POSParameterValue.Value);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    var
        Customer: Record Customer;
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if not EanBoxEvent.Get(EventCodeCustNo()) then begin
            EanBoxEvent.Init();
            EanBoxEvent.Code := EventCodeCustNo();
            EanBoxEvent."Module Name" := CopyStr(Customer.TableCaption, 1, MaxStrLen(EanBoxEvent."Module Name"));
            EanBoxEvent.Description := CopyStr(CustLedgerEntry.FieldCaption("Customer No."), 1, MaxStrLen(EanBoxEvent.Description));
            EanBoxEvent."Action Code" := CopyStr(ActionCode(), 1, MaxStrLen(EanBoxEvent."Action Code"));
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CODEUNIT::"NPR POS Action: Cust. Select";
            EanBoxEvent.Insert(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "NPR POS Input Box Setup Mgt."; EanBoxEvent: Record "NPR Ean Box Event")
    begin
        case EanBoxEvent.Code of
            EventCodeCustNo():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, ParameterCustomerNo_Name(), true, '');
                    Sender.SetNonEditableParameterValues(EanBoxEvent, ParameterOperation_Name(), false, SelectStr(1, ParameterOperation_OptionsLbl));
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Evt Handler", 'SetEanBoxEventInScope', '', true, true)]
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

    local procedure ParameterOperation_Name(): Text[30]
    begin
        exit('Operation');
    end;

    local procedure ParameterCustomerNo_Name(): Text[30]
    begin
        exit('CustomerNo');
    end;

    local procedure ParameterCustomerTableView_Name(): Text[30]
    begin
        exit('CustomerTableView');
    end;

    local procedure ParameterCustomerLookupPage_Name(): Text[30]
    begin
        exit('CustomerLookupPage');
    end;

    local procedure ParameterCheckCustomerBalance_Name(): Text[30]
    begin
        exit('CheckCustomerBalance');
    end;

    local procedure GetCustomParam(var Context: Codeunit "NPR POS JSON Helper"; var SelectReq: Boolean)
    var
        PrevScopeID: Guid;
    begin
        if Context.HasProperty('customParameters') then begin
            PrevScopeID := Context.StoreScope();

            Context.SetScope('customParameters');
            if not Context.GetBoolean('SelectionRequired', SelectReq) then
                SelectReq := false;

            Context.RestoreScope(PrevScopeID);
        end;
    end;
}
