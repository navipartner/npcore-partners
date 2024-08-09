codeunit 6150828 "NPR POS Action: ItemInv Overv." implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This built in function opens a page displaying the item inventory per location and variant.';
        ParamAllItemsCaptionLbl: Label 'All Items';
        ParamOnlyCurrentLocCaptionLbl: Label 'Only Current Location';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddBooleanParameter(AllItemsParTxt(), false, ParamAllItemsCaptionLbl, ParamAllItemsCaptionLbl);
        WorkflowConfig.AddBooleanParameter(OnlyCurrentLocParTxt(), false, ParamOnlyCurrentLocCaptionLbl, ParamOnlyCurrentLocCaptionLbl);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionItemInvOverv.js###
'let main=async({})=>await workflow.respond();'
        );
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        SalePOS: Record "NPR POS Sale";
        SalesLinePOS: Record "NPR POS Sale Line";
        BusinessLogicItemInv: Codeunit "NPR POS Action:ItemInv Over-B";
        AllItems: Boolean;
        OnlyCurrentLocation: Boolean;
    begin
        AllItems := Context.GetBooleanParameter(AllItemsParTxt());
        OnlyCurrentLocation := Context.GetBooleanParameter(OnlyCurrentLocParTxt());

        Sale.GetCurrentSale(SalePOS);
        SaleLine.GetCurrentSaleLine(SalesLinePOS);

        BusinessLogicItemInv.OpenItemInventoryOverviewPage(SalePOS, SalesLinePOS, AllItems, OnlyCurrentLocation);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDiscoverDataSourceExtensions', '', false, false)]
    local procedure OnDiscoverDataSourceExtensions(DataSourceName: Text; Extensions: List of [Text])
    var
        BinContent: Record "Bin Content";
        POSDataMgt: Codeunit "NPR POS Data Management";
    begin
        if POSDataMgt.POSDataSource_BuiltInSaleLine() <> DataSourceName then
            exit;

        if BinContent.IsEmpty() then
            exit;

        Extensions.Add(ThisExtension());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnGetDataSourceExtension', '', false, false)]
    local procedure OnGetDataSourceExtension(DataSourceName: Text; ExtensionName: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        POSDataMgt: Codeunit "NPR POS Data Management";
        DataType: Enum "NPR Data Type";
    begin
        if (DataSourceName <> POSDataMgt.POSDataSource_BuiltInSaleLine()) or (ExtensionName <> ThisExtension()) then
            exit;

        DataSource.AddColumn('Stock', 'Bin Stock', DataType::String, false);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDataSourceExtensionReadData', '', false, false)]
    local procedure OnDataSourceExtensionReadData(DataSourceName: Text; ExtensionName: Text; var RecRef: RecordRef; DataRow: Codeunit "NPR Data Row"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        BinContent: Record "Bin Content";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSDataMgt: Codeunit "NPR POS Data Management";
    begin
        if (DataSourceName <> POSDataMgt.POSDataSource_BuiltInSaleLine()) or (ExtensionName <> ThisExtension()) then
            exit;

        Handled := true;

        RecRef.SetTable(SaleLinePOS);

        BinContent.SetAutoCalcFields(Quantity);
        if BinContent.Get(SaleLinePOS."Location Code", SaleLinePOS."Bin Code", SaleLinePOS."No.", SaleLinePOS."Variant Code", SaleLinePOS."Unit of Measure Code") then
            DataRow.Add('Stock', BinContent.Quantity)
        else
            DataRow.Add('Stock', 0);
    end;

    local procedure ThisExtension(): Text
    begin
        exit('ITEMINVOV');
    end;

    local procedure AllItemsParTxt(): Text[30]
    begin
        exit('AllItems');
    end;

    local procedure OnlyCurrentLocParTxt(): Text[30]
    begin
        exit('OnlyCurrentLocation');
    end;
}
