﻿codeunit 6150711 "NPR POS Data Driver - Sale"
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
        if Name <> GetSourceNameText() then
            exit;

        DataSource.Constructor();
        DataSource.SetId(Name);
        DataSource.SetTableNo(DATABASE::"NPR POS Sale");
        DataSource.SetPerSession(true);

        DataMgt.AddFieldToDataSource(DataSource, Sale, Sale.FieldNo("Register No."), false);
        DataMgt.AddFieldToDataSource(DataSource, Sale, Sale.FieldNo("Sales Ticket No."), false);
        DataMgt.AddFieldToDataSource(DataSource, Sale, Sale.FieldNo("Salesperson Code"), false);
        DataMgt.AddFieldToDataSource(DataSource, Sale, Sale.FieldNo("Customer No."), false);
        DataMgt.AddFieldToDataSource(DataSource, Sale, Sale.FieldNo(Name), false);
        DataMgt.AddFieldToDataSource(DataSource, Sale, Sale.FieldNo(Sale.Date), false);
        DataMgt.AddFieldToDataSource(DataSource, Sale, Sale.FieldNo("Contact No."), false);
        DataMgt.AddFieldToDataSource(DataSource, Sale, Sale.FieldNo("Customer Price Group"), false);
        DataMgt.AddFieldToDataSource(DataSource, Sale, Sale.FieldNo("Customer Disc. Group"), false);

        DataSource.AddColumn(GetRegisterNameText(), Caption_RegisterName, DataType::String, false);
        DataSource.AddColumn(GetCustomerNameText(), Caption_CustomerName, DataType::String, false);
        DataSource.AddColumn(GetContactNameText(), Caption_ContactName, DataType::String, false);
        DataSource.AddColumn(GetLastSaleNoText(), '', DataType::String, false);
        DataSource.AddColumn(GetLastSaleTotalText(), '', DataType::Decimal, false);
        DataSource.AddColumn(GetLastSalePaidText(), '', DataType::Decimal, false);
        DataSource.AddColumn(GetLastSaleChangeText(), '', DataType::Decimal, false);
        DataSource.AddColumn(GetLastSaleDateText(), '', DataType::String, false);
        DataSource.AddColumn(GetCompanyNameText(), Caption_CompanyName, DataType::String, false);
        DataSource.AddColumn(GetSalespersonNameText(), '', DataType::String, false);
        DataSource.AddColumn(GetCustomerType(), '', DataType::String, false);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnRefreshDataSet', '', false, false)]
    local procedure RefreshDataSet(POSSession: Codeunit "NPR POS Session"; DataSource: Codeunit "NPR Data Source"; var CurrDataSet: Codeunit "NPR Data Set"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        Sale: Codeunit "NPR POS Sale";
    begin
        if DataSource.Id() <> GetSourceNameText() then
            exit;

        POSSession.GetSale(Sale);
        Sale.ToDataset(CurrDataSet, DataSource, POSSession, FrontEnd);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnSetPosition', '', false, false)]
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnReadDataSourceVariables', '', false, false)]
    local procedure ReadDataSourceVariables(POSSession: Codeunit "NPR POS Session"; RecRef: RecordRef; DataSource: Text; DataRow: Codeunit "NPR Data Row"; var Handled: Boolean)
    var
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

        if not POSUnit.Get(SalePOS."Register No.") then
            clear(POSUnit);
        if not Customer.Get(SalePOS."Customer No.") then
            Clear(Customer);
        Clear(Contact);
        if not Contact.Get(SalePOS."Contact No.") then
            if Customer."No." <> '' then begin
                ContactBusinessRelation.SetCurrentKey("Link to Table", "No.");
                ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
                ContactBusinessRelation.SetRange("No.", Customer."No.");
                if ContactBusinessRelation.FindFirst() then
                    if Contact.Get(ContactBusinessRelation."Contact No.") then;
            end;

        DataRow.Add(GetRegisterNameText(), POSUnit.Name);
        DataRow.Add(GetCustomerNameText(), Customer.Name);
        DataRow.Add(GetContactNameText(), Contact.Name);
        DataRow.Add(GetCustomerType(), GetCustomerTypeString(SalePOS));

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnIsDataSourceModified', '', false, false)]
    local procedure Modified(POSSession: Codeunit "NPR POS Session"; DataSource: Text; var Modified: Boolean)
    var
        Sale: Codeunit "NPR POS Sale";
    begin
        if DataSource <> GetSourceNameText() then
            exit;

        POSSession.GetSale(Sale);
        Modified := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Data Source Discovery", 'OnDiscoverDataSource', '', false, false)]
    local procedure OnDiscoverDataSource(var Rec: Record "NPR POS Data Source Discovery")
    begin
        Rec.RegisterDataSource(GetSourceNameText(), '(Built-in data source)');
    end;

    local procedure GetSourceNameText(): Text[50]
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

    local procedure GetCustomerType(): Text
    begin
        exit('CustomerType');
    end;


    local procedure GetCustomerTypeString(SalePOS: Record "NPR POS Sale"): Text
    begin
        if SalePOS."Customer No." = '' then
            exit('')
        else
            exit(Format(SalePOS."Customer Type"))
    end;
}
