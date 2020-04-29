codeunit 6150711 "POS Data Driver - Sale"
{
    // NPR5.32.10/TSA/20170619  CASE 279495 Added Name (field 8) to data management
    // NPR5.36/TJ  /20170825  CASE 287688 Text constants with nontranslatable text are now functions with hardcoded values
    // NPR5.38/TSA /20171113  CASE 295327 Added SalespersonName as a field, to make it available in POS footer.
    // NPR5.38/MHA /20180105  CASE 301053 Updated signature of RefreshDataSet() to match new publisher signature
    // NPR5.40/JC  /20180222 CASE 302192 Added Register, Customer, Contact names in POS info


    trigger OnRun()
    begin
    end;

    var
        Caption_CompanyName: Label 'Company Name';
        Caption_SalespersonName: Label 'Salesperson Name';
        Caption_RegisterName: Label 'Register Name';
        Caption_CustomerName: Label 'Customer Name';
        Caption_ContactName: Label 'Contact Name';

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnGetDataSource', '', false, false)]
    local procedure GetDataSource(Name: Text;var DataSource: DotNet npNetDataSource0;var Handled: Boolean;Setup: Codeunit "POS Setup")
    var
        Sale: Record "Sale POS";
        DataMgt: Codeunit "POS Data Management";
        DataType: DotNet npNetDataType;
    begin
        //-NPR5.36 [287688]
        //IF Name <> SourceName THEN
        if Name <> GetSourceNameText() then
        //+NPR5.36 [287688]
          exit;
        
        DataSource := DataSource.DataSource();
        DataSource.Id := Name;
        DataSource.TableNo := DATABASE::"Sale POS";
        DataSource.PerSession := true;
        
        DataMgt.AddFieldToDataSource(DataSource,Sale,Sale.FieldNo("Register No."),false);
        DataMgt.AddFieldToDataSource(DataSource,Sale,Sale.FieldNo("Sales Ticket No."),false);
        DataMgt.AddFieldToDataSource(DataSource,Sale,Sale.FieldNo("Salesperson Code"),false);
        DataMgt.AddFieldToDataSource(DataSource,Sale,Sale.FieldNo("Customer No."),false);
        DataMgt.AddFieldToDataSource(DataSource,Sale,Sale.FieldNo(Name),false);
        DataMgt.AddFieldToDataSource(DataSource,Sale,Sale.FieldNo(Sale.Date),false);
        
        //-NPR5.40 [302192]
        DataMgt.AddFieldToDataSource(DataSource,Sale,Sale.FieldNo("Contact No."),false);
        DataSource.AddColumn(GetRegisterNameText,Caption_RegisterName,DataType.String,false);
        DataSource.AddColumn(GetCustomerNameText,Caption_CustomerName,DataType.String,false);
        DataSource.AddColumn(GetContactNameText,Caption_ContactName,DataType.String,false);
        //+NPR5.40
        
        //-NPR5.36 [287688]
        /*
        DataSource.AddColumn(Field_LastSaleNo,'',DataType.String,FALSE);
        DataSource.AddColumn(Field_LastSaleTotal,'',DataType.Decimal,FALSE);
        DataSource.AddColumn(Field_LastSalePaid,'',DataType.Decimal,FALSE);
        DataSource.AddColumn(Field_LastSaleChange,'',DataType.Decimal,FALSE);
        DataSource.AddColumn(Field_LastSaleDate,'',DataType.String,FALSE);
        DataSource.AddColumn(Field_CompanyName,Caption_CompanyName,DataType.String,FALSE);
        */
        DataSource.AddColumn(GetLastSaleNoText(),'',DataType.String,false);
        DataSource.AddColumn(GetLastSaleTotalText(),'',DataType.Decimal,false);
        DataSource.AddColumn(GetLastSalePaidText(),'',DataType.Decimal,false);
        DataSource.AddColumn(GetLastSaleChangeText(),'',DataType.Decimal,false);
        DataSource.AddColumn(GetLastSaleDateText(),'',DataType.String,false);
        DataSource.AddColumn(GetCompanyNameText(),Caption_CompanyName,DataType.String,false);
        //+NPR5.36 [287688]
        
        //-NPR5.38 [295327]
        DataSource.AddColumn(GetSalespersonNameText(),'',DataType.String,false);
        //+NPR5.38 [295327]
        
        Handled := true;

    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnRefreshDataSet', '', false, false)]
    local procedure RefreshDataSet(POSSession: Codeunit "POS Session";DataSource: DotNet npNetDataSource0;var CurrDataSet: DotNet npNetDataSet;FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        Sale: Codeunit "POS Sale";
    begin
        //-NPR5.36 [287688]
        //IF DataSource.Id <> SourceName THEN
        if DataSource.Id <> GetSourceNameText() then
        //+NPR5.36 [287688]
          exit;

        POSSession.GetSale(Sale);
        //-NPR5.38 [301053]
        //Sale.ToDataset(DataSet,DataSource,POSSession,FrontEnd);
        Sale.ToDataset(CurrDataSet,DataSource,POSSession,FrontEnd);
        //+NPR5.38 [301053]
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnSetPosition', '', false, false)]
    local procedure SetPosition(DataSource: Text;Position: Text;POSSession: Codeunit "POS Session";var Handled: Boolean)
    var
        Sale: Codeunit "POS Sale";
    begin
        //-NPR5.36 [287688]
        //IF DataSource <> SourceName THEN
        if DataSource <> GetSourceNameText() then
        //+NPR5.36 [287688]
          exit;

        POSSession.GetSale(Sale);
        Sale.SetPosition(Position);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnReadDataSourceVariables', '', false, false)]
    local procedure ReadDataSourceVariables(POSSession: Codeunit "POS Session";RecRef: RecordRef;DataSource: Text;DataRow: DotNet npNetDataRow0;var Handled: Boolean)
    var
        Sale: Codeunit "POS Sale";
        LastSaleTotal: Decimal;
        LastSalePayment: Decimal;
        LastSaleDateText: Text;
        LastSaleReturnAmount: Decimal;
        LastReceiptNo: Text;
        SalePOS: Record "Sale POS";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        Customer: Record Customer;
        Contact: Record Contact;
        Register: Record Register;
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        //-NPR5.36 [287688]
        //IF DataSource <> SourceName THEN
        if DataSource <> GetSourceNameText() then
        //+NPR5.36 [287688]
          exit;
        
        POSSession.GetSale(Sale);
        Sale.GetLastSaleInfo(LastSaleTotal,LastSalePayment,LastSaleDateText,LastSaleReturnAmount,LastReceiptNo);
        
        //-NPR5.36 [287688]
        /*
        DataRow.Add(Field_LastSaleNo,LastReceiptNo);
        DataRow.Add(Field_LastSaleTotal,LastSaleTotal);
        DataRow.Add(Field_LastSalePaid,LastSalePayment);
        DataRow.Add(Field_LastSaleChange,LastSaleReturnAmount);
        DataRow.Add(Field_LastSaleDate,LastSaleDateText);
        DataRow.Add(Field_CompanyName,COMPANYNAME);
        */
        DataRow.Add(GetLastSaleNoText(),LastReceiptNo);
        DataRow.Add(GetLastSaleTotalText(),LastSaleTotal);
        DataRow.Add(GetLastSalePaidText(),LastSalePayment);
        DataRow.Add(GetLastSaleChangeText(),LastSaleReturnAmount);
        DataRow.Add(GetLastSaleDateText(),LastSaleDateText);
        DataRow.Add(GetCompanyNameText(),CompanyName);
        //+NPR5.36 [287688]
        
        //-NPR5.38 [295327]
        Sale.GetCurrentSale (SalePOS);
        if (not SalespersonPurchaser.Get (SalePOS."Salesperson Code")) then
          SalespersonPurchaser.Name := 'Unknown';
        DataRow.Add (GetSalespersonNameText(), SalespersonPurchaser.Name);
        //+NPR5.38 [295327]
        
        //-NPR5.40 [302192]
        Sale.GetCurrentSale(SalePOS);
        Clear(Register);
        if Register.Get(SalePOS."Register No.") then;
        Clear(Customer);
        if Customer.Get(SalePOS."Customer No.") then;
        Clear(Contact);
        if Contact.Get(SalePOS."Contact No.") then begin
        end else if Customer."No." <> '' then begin
          ContactBusinessRelation.SetRange("Link to Table"  , ContactBusinessRelation."Link to Table"::Customer);
          ContactBusinessRelation.SetRange("No.", Customer."No.");
          if ContactBusinessRelation.FindFirst then
            if Contact.Get(ContactBusinessRelation."Contact No.") then;
        end;
        
        DataRow.Add(GetRegisterNameText(), Register.Description);
        DataRow.Add(GetCustomerNameText(), Customer.Name);
        DataRow.Add(GetContactNameText(), Contact.Name);
        //+NPR5.40
        
        Handled := true;

    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnIsDataSourceModified', '', false, false)]
    local procedure Modified(POSSession: Codeunit "POS Session";DataSource: Text;var Modified: Boolean)
    var
        Sale: Codeunit "POS Sale";
    begin
        //-NPR5.36 [287688]
        //IF DataSource <> SourceName THEN
        if DataSource <> GetSourceNameText() then
        //+NPR5.36 [287688]
          exit;

        POSSession.GetSale(Sale);
        Modified := Sale.GetModified();
    end;

    [EventSubscriber(ObjectType::Table, 6150708, 'OnDiscoverDataSource', '', false, false)]
    local procedure OnDiscoverDataSource(var Rec: Record "POS Data Source (Discovery)")
    begin
        //-NPR5.36 [287688]
        //Rec.RegisterDataSource(SourceName,'(Built-in data source)');
        Rec.RegisterDataSource(GetSourceNameText(),'(Built-in data source)');
        //+NPR5.36 [287688]
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
        //-NPR5.38 [295327]
        exit ('SalespersonName');
        //+NPR5.38 [295327]
    end;

    local procedure GetRegisterNameText(): Text
    begin
        //-NPR5.40 [302192]
        exit('RegisterName');
        //+NPR5.40
    end;

    local procedure GetCustomerNameText(): Text
    begin
        //-NPR5.40 [302192]
        exit('CustomerName');
        //+NPR5.40
    end;

    local procedure GetContactNameText(): Text
    begin
        //-NPR5.40 [302192]
        exit('ContactName');
        //+NPR5.40
    end;
}

