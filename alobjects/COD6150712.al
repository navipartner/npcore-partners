codeunit 6150712 "POS Data Driver - Sale Line"
{
    // NPR5.36/TJ  /20170825 CASE 287688 Text constants with nontranslatable text are now functions with hardcoded values
    // NPR5.38/MHA /20180105  CASE 301053 Updated signature of RefreshDataSet() to match new publisher signature
    // NPR5.41/TSA /20180417 CASE 311374 Added field "Description 2" to become available for frontent to display.
    // NPR5.48/JC  /20190110 CASE 335967 Added field "Unit of Measure Code" to be displayed in UI grid
    // NPR5.53/TSA /20191219 CASE 382035 Added field LineCount


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnGetDataSource', '', false, false)]
    local procedure GetDataSource(Name: Text;var DataSource: DotNet npNetDataSource0;var Handled: Boolean;Setup: Codeunit "POS Setup")
    var
        SaleLine: Record "Sale Line POS";
        DataMgt: Codeunit "POS Data Management";
    begin
        //-NPR5.36 [287688]
        //IF Name <> SourceName THEN
        if Name <> GetSourceNameText() then
        //+NPR5.36 [287688]
          exit;

        DataSource := DataSource.DataSource();
        DataSource.Id := Name;
        DataSource.TableNo := DATABASE::"Sale Line POS";

        DataMgt.AddFieldToDataSource(DataSource,SaleLine,SaleLine.FieldNo("No."),false);
        DataMgt.AddFieldToDataSource(DataSource,SaleLine,SaleLine.FieldNo(Type),false);
        DataMgt.AddFieldToDataSource(DataSource,SaleLine,SaleLine.FieldNo(Description),true);

        //-NPR5.41 [311374]
        DataMgt.AddFieldToDataSource(DataSource,SaleLine,SaleLine.FieldNo("Description 2"),false);
        //+NPR5.41 [311374]

        DataMgt.AddFieldToDataSource(DataSource,SaleLine,SaleLine.FieldNo(Quantity),true);
        //-NPR5.48 [335967]
        DataMgt.AddFieldToDataSource(DataSource,SaleLine,SaleLine.FieldNo("Unit of Measure Code"),false);
        //+NPR5.48 [335967]
        DataMgt.AddFieldToDataSource(DataSource,SaleLine,SaleLine.FieldNo("Unit Price"),true);
        if Setup.ShowDiscountFieldsInSaleView then begin
          DataMgt.AddFieldToDataSource(DataSource,SaleLine,SaleLine.FieldNo("Discount %"),true);
          DataMgt.AddFieldToDataSource(DataSource,SaleLine,SaleLine.FieldNo("Discount Amount"),true);
        end;
        DataMgt.AddFieldToDataSource(DataSource,SaleLine,SaleLine.FieldNo("Amount Including VAT"),true);

        DataSource.Totals.Add('AmountExclVAT');
        DataSource.Totals.Add('VATAmount');
        DataSource.Totals.Add('TotalAmount');

        //-NPR5.53 [382035]
        DataSource.Totals.Add('ItemCount');
        //+NPR5.53 [382035]

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnRefreshDataSet', '', false, false)]
    local procedure RefreshDataSet(POSSession: Codeunit "POS Session";DataSource: DotNet npNetDataSource0;var CurrDataSet: DotNet npNetDataSet;FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        SaleLine: Codeunit "POS Sale Line";
    begin
        //-NPR5.36 [287688]
        //IF DataSource.Id <> SourceName THEN
        if DataSource.Id <> GetSourceNameText() then
        //+NPR5.36 [287688]
          exit;

        POSSession.GetSaleLine(SaleLine);
        //-NPR5.38 [301053]
        //SaleLine.ToDataset(DataSet,DataSource,POSSession,FrontEnd);
        SaleLine.ToDataset(CurrDataSet,DataSource,POSSession,FrontEnd);
        //+NPR5.38 [301053]

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnSetPosition', '', false, false)]
    local procedure SetPosition(DataSource: Text;Position: Text;POSSession: Codeunit "POS Session";var Handled: Boolean)
    var
        SaleLine: Codeunit "POS Sale Line";
    begin
        //-NPR5.36 [287688]
        //IF DataSource <> SourceName THEN
        if DataSource <> GetSourceNameText() then
        //+NPR5.36 [287688]
          exit;

        POSSession.GetSaleLine(SaleLine);
        SaleLine.SetPosition(Position);

        Handled := true;
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
        exit('BUILTIN_SALELINE');
    end;
}

