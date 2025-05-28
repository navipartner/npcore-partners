codeunit 6059951 "NPR POSAction: Ins. Customer-B"
{
    Access = Internal;

    [Obsolete('Not Used.', '2023-06-28')]
    procedure OnActionCreateContact(CardPageId: Integer; var SalePOS: Record "NPR POS Sale")
    var
        Contact: Record Contact;
    begin

    end;

    internal procedure OnActionCreateCustomer(CardPageId: Integer; var SalePOS: Record "NPR POS Sale"; UseCustTempl: Boolean; CustTemplateCode: Code[20])
    var
        Customer: Record Customer;
    begin
        if SalePOS."Customer No." <> '' then
            Customer.Get(SalePOS."Customer No.")
        else
#if not BC17
            CreateCustomer(Customer, UseCustTempl, CustTemplateCode);
#else
            InitCustomer(Customer);
#endif
        if CardPageId > 0 then
            PAGE.RunModal(CardPageId, Customer)
        else
            PageRunModalWithFieldFocus(Customer, Customer.FieldNo(Name));

        SalePOS.Validate("Customer No.", Customer."No.");
    end;

    internal procedure PageRunModalWithFieldFocus(RecRelatedVariant: Variant; FieldNumber: Integer): Boolean
    var
        RecordRef: RecordRef;
        RecordRefVariant: Variant;
        PageID: Integer;
        PageMgt: Codeunit "Page Management";
        DataTypeManagement: Codeunit "Data Type Management";
    begin
        if not GuiAllowed then
            exit(false);

        if not DataTypeManagement.GetRecordRef(RecRelatedVariant, RecordRef) then
            exit(false);

        PageID := PageMgt.GetPageID(RecordRef);

        if PageID <> 0 then begin
            RecordRefVariant := RecordRef;
            PAGE.RunModal(PageID, RecordRefVariant, FieldNumber);
            exit(true);
        end;

        exit(false);
    end;
#if not BC17
    local procedure CreateCustomer(var Customer: Record Customer; UseCustTempl: Boolean; CustTemplateCode: Code[20])
    var
        CustTemplate: Record "Customer Templ.";
        CustomerTemplMgt: Codeunit "Customer Templ. Mgt.";
    begin
        if UseCustTempl then begin
            if CustTemplateCode <> '' then
                CustTemplate.Get(CustTemplateCode)
            else begin
                if not SelectCustomerTemplate(CustTemplate) then begin
                    InitCustomer(Customer);
                    exit;
                end;
            end;

            Customer.SetInsertFromTemplate(true);
            Customer.Init();
            InitCustomerNo(Customer, CustTemplate);
            Customer."Contact Type" := CustTemplate."Contact Type";
            Customer.Insert(true);
            Customer.SetInsertFromTemplate(false);
            CustomerTemplMgt.ApplyCustomerTemplate(Customer, CustTemplate);
            Commit();
        end else
            InitCustomer(Customer);
    end;

    local procedure SelectCustomerTemplate(var CustomerTempl: Record "Customer Templ."): Boolean
    var
        SelectCustomerTemplList: Page "Select Customer Templ. List";
    begin
        if CustomerTempl.Count = 1 then begin
            CustomerTempl.FindFirst();
            exit(true);
        end;

        if (CustomerTempl.Count > 1) and GuiAllowed then begin
            SelectCustomerTemplList.SetTableView(CustomerTempl);
            SelectCustomerTemplList.LookupMode(true);
            if SelectCustomerTemplList.RunModal() = Action::LookupOK then begin
                SelectCustomerTemplList.GetRecord(CustomerTempl);
                exit(true);
            end;
        end;

        exit(false);
    end;

    local procedure InitCustomerNo(var Customer: Record Customer; CustomerTempl: Record "Customer Templ.")
    var
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesManagement: Codeunit "No. Series";
#ELSE
        NoSeriesManagement: Codeunit NoSeriesManagement;
#ENDIF
    begin
        if CustomerTempl."No. Series" = '' then
            exit;

#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        Customer."No. Series" := CustomerTempl."No. Series";
        Customer."No." := NoSeriesManagement.GetNextNo(Customer."No. Series");
#ELSE
        NoSeriesManagement.InitSeries(CustomerTempl."No. Series", '', 0D, Customer."No.", Customer."No. Series");
#ENDIF
    end;
#endif
    local procedure InitCustomer(var Customer: Record Customer)
    begin
        Customer.Init();
        Customer."No." := '';
        Customer.Insert(true);
        Commit();
    end;
}
