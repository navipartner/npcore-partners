codeunit 6150711 "NPR POS Data Driver - Sale"
{
    var
        Caption_CompanyName: Label 'Company Name';
        Caption_SalespersonName: Label 'Salesperson Name';
        Caption_RegisterName: Label 'Register Name';
        Caption_CustomerName: Label 'Customer Name';
        Caption_ContactName: Label 'Contact Name';

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnGetDataSource', '', false, false)]
    local procedure GetDataSource(Name: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        Sale: Record "NPR Sale POS";
        DataMgt: Codeunit "NPR POS Data Management";
        DataType: Enum "NPR Data Type";
    begin
        if Name <> GetSourceNameText() then
            exit;

        DataSource.Constructor();
        DataSource.SetId(Name);
        DataSource.SetTableNo(DATABASE::"NPR Sale POS");
        DataSource.SetPerSession(true);

        DataMgt.AddFieldToDataSource(DataSource, Sale, Sale.FieldNo("Register No."), false);
        DataMgt.AddFieldToDataSource(DataSource, Sale, Sale.FieldNo("Sales Ticket No."), false);
        DataMgt.AddFieldToDataSource(DataSource, Sale, Sale.FieldNo("Salesperson Code"), false);
        DataMgt.AddFieldToDataSource(DataSource, Sale, Sale.FieldNo("Customer No."), false);
        DataMgt.AddFieldToDataSource(DataSource, Sale, Sale.FieldNo(Name), false);
        DataMgt.AddFieldToDataSource(DataSource, Sale, Sale.FieldNo(Sale.Date), false);
        DataMgt.AddFieldToDataSource(DataSource, Sale, Sale.FieldNo("Contact No."), false);

        DataSource.AddColumn(GetRegisterNameText, Caption_RegisterName, DataType::String, false);
        DataSource.AddColumn(GetCustomerNameText, Caption_CustomerName, DataType::String, false);
        DataSource.AddColumn(GetContactNameText, Caption_ContactName, DataType::String, false);
        DataSource.AddColumn(GetLastSaleNoText(), '', DataType::String, false);
        DataSource.AddColumn(GetLastSaleTotalText(), '', DataType::Decimal, false);
        DataSource.AddColumn(GetLastSalePaidText(), '', DataType::Decimal, false);
        DataSource.AddColumn(GetLastSaleChangeText(), '', DataType::Decimal, false);
        DataSource.AddColumn(GetLastSaleDateText(), '', DataType::String, false);
        DataSource.AddColumn(GetCompanyNameText(), Caption_CompanyName, DataType::String, false);
        DataSource.AddColumn(GetSalespersonNameText(), '', DataType::String, false);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnRefreshDataSet', '', false, false)]
    local procedure RefreshDataSet(POSSession: Codeunit "NPR POS Session"; DataSource: Codeunit "NPR Data Source"; var CurrDataSet: Codeunit "NPR Data Set"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        Sale: Codeunit "NPR POS Sale";
    begin
        if DataSource.Id <> GetSourceNameText() then
            exit;

        POSSession.GetSale(Sale);
        Sale.ToDataset(CurrDataSet, DataSource, POSSession, FrontEnd);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnSetPosition', '', false, false)]
    local procedure SetPosition(DataSource: Text; Position: Text; POSSession: Codeunit "NPR POS Session"; var Handled: Boolean)
    var
        Sale: Codeunit "NPR POS Sale";
    begin
        if DataSource <> GetSourceNameText() then
            exit;

        POSSession.GetSale(Sale);
        Sale.SetPosition(Position);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnReadDataSourceVariables', '', false, false)]
    local procedure ReadDataSourceVariables(POSSession: Codeunit "NPR POS Session"; RecRef: RecordRef; DataSource: Text; DataRow: Codeunit "NPR Data Row"; var Handled: Boolean)
    var
        Sale: Codeunit "NPR POS Sale";
        LastSaleTotal: Decimal;
        LastSalePayment: Decimal;
        LastSaleDateText: Text;
        LastSaleReturnAmount: Decimal;
        LastReceiptNo: Text;
        SalePOS: Record "NPR Sale POS";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        Customer: Record Customer;
        Contact: Record Contact;
        Register: Record "NPR Register";
        POSUnit: Record "NPR POS Unit";
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        if DataSource <> GetSourceNameText() then
            exit;

        POSSession.GetSale(Sale);
        Sale.GetLastSaleInfo(LastSaleTotal, LastSalePayment, LastSaleDateText, LastSaleReturnAmount, LastReceiptNo);

        DataRow.Add(GetLastSaleNoText(), LastReceiptNo);
        DataRow.Add(GetLastSaleTotalText(), LastSaleTotal);
        DataRow.Add(GetLastSalePaidText(), LastSalePayment);
        DataRow.Add(GetLastSaleChangeText(), LastSaleReturnAmount);
        DataRow.Add(GetLastSaleDateText(), LastSaleDateText);
        DataRow.Add(GetCompanyNameText(), CompanyName);

        Sale.GetCurrentSale(SalePOS);
        if (not SalespersonPurchaser.Get(SalePOS."Salesperson Code")) then
            SalespersonPurchaser.Name := 'Unknown';
        DataRow.Add(GetSalespersonNameText(), SalespersonPurchaser.Name);

        Sale.GetCurrentSale(SalePOS);
        Clear(Register);
        if Register.Get(SalePOS."Register No.") then;
        Clear(Customer);
        if POSUnit.Get(SalePOS."Register No.") then;
        if Customer.Get(SalePOS."Customer No.") then;
        Clear(Contact);
        if Contact.Get(SalePOS."Contact No.") then begin
        end else
            if Customer."No." <> '' then begin
                ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
                ContactBusinessRelation.SetRange("No.", Customer."No.");
                if ContactBusinessRelation.FindFirst then
                    if Contact.Get(ContactBusinessRelation."Contact No.") then;
            end;

        DataRow.Add(GetRegisterNameText(), POSUnit.Name);
        DataRow.Add(GetCustomerNameText(), Customer.Name);
        DataRow.Add(GetContactNameText(), Contact.Name);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnIsDataSourceModified', '', false, false)]
    local procedure Modified(POSSession: Codeunit "NPR POS Session"; DataSource: Text; var Modified: Boolean)
    var
        Sale: Codeunit "NPR POS Sale";
    begin
        if DataSource <> GetSourceNameText() then
            exit;

        POSSession.GetSale(Sale);
        Modified := Sale.GetModified();
    end;

    [EventSubscriber(ObjectType::Table, 6150708, 'OnDiscoverDataSource', '', false, false)]
    local procedure OnDiscoverDataSource(var Rec: Record "NPR POS Data Source Discovery")
    begin
        Rec.RegisterDataSource(GetSourceNameText(), '(Built-in data source)');
    end;

    local procedure GetSourceNameText(): Text
    begin
        exit('BUILTIN_SALE');
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
}
