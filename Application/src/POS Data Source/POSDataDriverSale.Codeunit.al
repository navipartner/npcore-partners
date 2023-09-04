codeunit 6150711 "NPR POS Data Driver - Sale"
{
    Access = Internal;

    var
        Caption_CompanyName: Label 'Company Name';
        Caption_RegisterName: Label 'Register Name';
        Caption_CustomerName: Label 'Customer Name';
        Caption_ContactName: Label 'Contact Name';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnGetDataSource', '', false, false)]
    local procedure GetDataSource(Name: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        Sale: Record "NPR POS Sale";
        DataMgt: Codeunit "NPR POS Data Management";
        DataType: Enum "NPR Data Type";
    begin
        if Name <> DataMgt.POSDataSource_BuiltInSale() then
            exit;

        DataSource.Constructor();
        DataSource.SetId(Name);
        DataSource.SetTableNo(DATABASE::"NPR POS Sale");
        DataSource.SetPerSession(true);

        DataMgt.AddFieldToDataSource(DataSource, Sale, Sale.FieldNo("Register No."), false, true);
        DataMgt.AddFieldToDataSource(DataSource, Sale, Sale.FieldNo("Sales Ticket No."), false, true);
        DataMgt.AddFieldToDataSource(DataSource, Sale, Sale.FieldNo("Salesperson Code"), false, true);
        DataMgt.AddFieldToDataSource(DataSource, Sale, Sale.FieldNo("Customer No."), false, true);
        DataMgt.AddFieldToDataSource(DataSource, Sale, Sale.FieldNo(Name), false, true);
        DataMgt.AddFieldToDataSource(DataSource, Sale, Sale.FieldNo(Sale.Date), false, true);
        DataMgt.AddFieldToDataSource(DataSource, Sale, Sale.FieldNo("Contact No."), false, true);
        DataMgt.AddFieldToDataSource(DataSource, Sale, Sale.FieldNo("Customer Price Group"), false, true);
        DataMgt.AddFieldToDataSource(DataSource, Sale, Sale.FieldNo("Customer Disc. Group"), false, true);
        DataMgt.AddFieldToDataSource(DataSource, Sale, Sale.FieldNo("Responsibility Center"), false, false);

        DataSource.AddColumn(GetRegisterNameText(), Caption_RegisterName, DataType::String, false, true);
        DataSource.AddColumn(GetCustomerNameText(), Caption_CustomerName, DataType::String, false, true);
        DataSource.AddColumn(GetContactNameText(), Caption_ContactName, DataType::String, false, true);
        DataSource.AddColumn(GetLastSaleNoText(), '', DataType::String, false, true);
        DataSource.AddColumn(GetLastSaleTotalText(), '', DataType::Decimal, false, true);
        DataSource.AddColumn(GetLastSalePaidText(), '', DataType::Decimal, false, true);
        DataSource.AddColumn(GetLastSaleChangeText(), '', DataType::Decimal, false, true);
        DataSource.AddColumn(GetLastSaleDateText(), '', DataType::String, false, true);
        DataSource.AddColumn(GetCompanyNameText(), Caption_CompanyName, DataType::String, false, true);
        DataSource.AddColumn(GetSalespersonNameText(), '', DataType::String, false, true);
        DataSource.AddColumn(GetCustomerType(), '', DataType::String, false, true);
        DataSource.AddColumn(GetCustomerPostingGroup(), '', DataType::String, false, true);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnRefreshDataSet', '', false, false)]
    local procedure RefreshDataSet(POSSession: Codeunit "NPR POS Session"; DataSource: Codeunit "NPR Data Source"; var CurrDataSet: Codeunit "NPR Data Set"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        Sale: Codeunit "NPR POS Sale";
        DataMgt: Codeunit "NPR POS Data Management";
    begin
        if DataSource.Id() <> DataMgt.POSDataSource_BuiltInSale() then
            exit;

        POSSession.GetSale(Sale);
        Sale.ToDataset(CurrDataSet, DataSource, POSSession, FrontEnd);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnSetPosition', '', false, false)]
    local procedure SetPosition(DataSource: Text; Position: Text; POSSession: Codeunit "NPR POS Session"; var Handled: Boolean)
    var
        Sale: Codeunit "NPR POS Sale";
        DataMgt: Codeunit "NPR POS Data Management";
    begin
        if DataSource <> DataMgt.POSDataSource_BuiltInSale() then
            exit;

        POSSession.GetSale(Sale);
        Sale.SetPosition(Position);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnReadDataSourceVariables', '', false, false)]
    local procedure ReadDataSourceVariables(POSSession: Codeunit "NPR POS Session"; RecRef: RecordRef; DataSource: Text; DataRow: Codeunit "NPR Data Row"; var Handled: Boolean)
    var
        DataMgt: Codeunit "NPR POS Data Management";
        Sale: Codeunit "NPR POS Sale";
        LastSaleTotal: Decimal;
        LastSalePayment: Decimal;
        LastSaleDateText: Text;
        LastSaleReturnAmount: Decimal;
        LastReceiptNo: Text;
        SalePOS: Record "NPR POS Sale";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        Customer: Record Customer;
        Contact: Record Contact;
        POSUnit: Record "NPR POS Unit";
        ContactBusinessRelation: Record "Contact Business Relation";

    begin
        if DataSource <> DataMgt.POSDataSource_BuiltInSale() then
            exit;

        POSSession.GetSale(Sale);
        Sale.GetLastSaleInfo(LastSaleTotal, LastSalePayment, LastSaleDateText, LastSaleReturnAmount, LastReceiptNo);

        DataRow.Add(GetLastSaleNoText(), LastReceiptNo);
        DataRow.Add(GetLastSaleTotalText(), LastSaleTotal);
        DataRow.Add(GetLastSalePaidText(), LastSalePayment);
        DataRow.Add(GetLastSaleChangeText(), LastSaleReturnAmount);
        DataRow.Add(GetLastSaleDateText(), LastSaleDateText);
        DataRow.Add(GetCompanyNameText(), GetCompanyDisplayName());

        Sale.GetCurrentSale(SalePOS);

        SalespersonPurchaser.SetLoadFields(Name);
        if not SalespersonPurchaser.Get(SalePOS."Salesperson Code") then
            Clear(SalespersonPurchaser);

        POSUnit.SetLoadFields(Name);
        if not POSUnit.Get(SalePOS."Register No.") then
            clear(POSUnit);

        if SalePOS."Customer No." <> '' then begin
            Customer.SetLoadFields(Name, "Customer Posting Group");
            if not Customer.Get(SalePOS."Customer No.") then
                Clear(Customer);
        end;

        if SalePOS."Contact No." <> '' then begin
            Contact.SetLoadFields(Name);
            if not Contact.Get(CopyStr(SalePOS."Contact No.", 1, MaxStrLen(Contact."No."))) then
                if Customer."No." <> '' then begin
                    ContactBusinessRelation.SetCurrentKey("Link to Table", "No.");
                    ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
                    ContactBusinessRelation.SetRange("No.", Customer."No.");
                    if ContactBusinessRelation.FindFirst() then
                        if Contact.Get(ContactBusinessRelation."Contact No.") then;
                end;
        end;

        DataRow.Add(GetSalespersonNameText(), SalespersonPurchaser.Name);
        DataRow.Add(GetRegisterNameText(), POSUnit.Name);
        DataRow.Add(GetCustomerNameText(), Customer.Name);
        DataRow.Add(GetCustomerPostingGroup(), Customer."Customer Posting Group");
        DataRow.Add(GetContactNameText(), Contact.Name);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnIsDataSourceModified', '', false, false)]
    local procedure POSDataManagementModified(POSSession: Codeunit "NPR POS Session"; DataSource: Text; var Modified: Boolean)
    var
        Sale: Codeunit "NPR POS Sale";
        DataMgt: Codeunit "NPR POS Data Management";
    begin
        if DataSource <> DataMgt.POSDataSource_BuiltInSale() then
            exit;

        POSSession.GetSale(Sale);
        Modified := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Data Source Discovery", 'OnDiscoverDataSource', '', false, false)]
    local procedure OnDiscoverDataSource(var Rec: Record "NPR POS Data Source Discovery")
    var
        DataMgt: Codeunit "NPR POS Data Management";
    begin
        Rec.RegisterDataSource(DataMgt.POSDataSource_BuiltInSale(), '(Built-in data source)');
    end;

    local procedure GetLastSaleNoText(): Text
    begin
        exit('LastSaleNo');
    end;

    local procedure GetLastSaleTotalText(): Text
    begin
        exit('LastSaleTotal');
    end;

    local procedure GetLastSalePaidText(): Text
    begin
        exit('LastSalePaid');
    end;

    local procedure GetLastSaleChangeText(): Text
    begin
        exit('LastSaleChange');
    end;

    local procedure GetLastSaleDateText(): Text
    begin
        exit('LastSaleDate');
    end;

    local procedure GetCompanyNameText(): Text
    begin
        exit('CompanyName');
    end;

    local procedure GetSalespersonNameText(): Text
    begin
        exit('SalespersonName');
    end;

    local procedure GetRegisterNameText(): Text
    begin
        exit('RegisterName');
    end;

    local procedure GetCustomerNameText(): Text
    begin
        exit('CustomerName');
    end;

    local procedure GetContactNameText(): Text
    begin
        exit('ContactName');
    end;

    local procedure GetCustomerType(): Text
    begin
        exit('CustomerType');
    end;

    local procedure GetCustomerPostingGroup(): Text
    begin
        exit('CustomerPostingGroup');
    end;

    [Obsolete('Not used.', 'NPR23.0')]
    local procedure GetCustomerTypeString(SalePOS: Record "NPR POS Sale"): Text
    begin
    end;

    local procedure GetCompanyDisplayName(): Text
    var
        Company: Record Company;
    begin
        if Company.Get(CompanyName()) and (Company."Display Name" <> '') then
            exit(Company."Display Name");
        exit(CompanyName());
    end;
}
