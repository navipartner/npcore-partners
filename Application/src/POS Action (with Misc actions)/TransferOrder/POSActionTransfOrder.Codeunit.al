codeunit 6059967 "NPR POS Action: Transf. Order" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        POSDataMgt: Codeunit "NPR POS Data Management";
        ActionDescription: Label 'This is a built-in action for handling Transfer Orders';
        DefaultTransferToCode_CaptionLbl: Label 'Default Transfer-To Code';
        DefaultTransferToCode_DescLbl: Label 'Specifies Default Transfer-to location code for newly created transfer orders';
        TransferHeader: Record "Transfer Header";
        NewRecord_CaptionLbl: Label 'New Record';
        NewRecord_DescLbl: Label 'Gives option to create a new record of type "%1" directly';
        RegisterLocationOption_OptionCptLbl: Label ' ,Use as Transfer-from filter,Use as Transfer-to filter';
        RegisterLocationOption_OptionNameLbl: Label ' ,UseAsTransferFromFilter,UseAsTransferToFilter', Locked = true;
        RegisterLocation_CaptionLbl: Label 'Register Location';
        RegisterLocation_DescrLbl: Label 'Specifies the location for the register';
        TransferFromFilter_CptLbl: Label 'Transfer-from Filter';
        TransferToFilter_CptLbl: Label 'Transfer-to Filter';
        TransferFilter_DescrLbl: Label 'Set filter on "%1" of the "%2"';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.SetDataSourceBinding(POSDataMgt.POSDataSource_BuiltInSale());
        WorkflowConfig.AddTextParameter('DefaultTransferToCode', '', DefaultTransferToCode_CaptionLbl, DefaultTransferToCode_DescLbl);
        WorkflowConfig.AddBooleanParameter('NewRecord', false, NewRecord_CaptionLbl, StrSubstNo(NewRecord_DescLbl, TransferHeader.TableCaption));
        WorkflowConfig.AddOptionParameter('RegisterLocation',
            RegisterLocationOption_OptionNameLbl,
#pragma warning disable AA0139
            SelectStr(1, RegisterLocationOption_OptionNameLbl),
#pragma warning restore 
            RegisterLocation_CaptionLbl,
            RegisterLocation_DescrLbl,
            RegisterLocationOption_OptionCptLbl);
        WorkflowConfig.AddTextParameter('TransferFromFilter', '', TransferFromFilter_CptLbl, StrSubstNo(TransferFilter_DescrLbl, TransferHeader.FieldCaption("Transfer-from Code"), TransferHeader.TableCaption));
        WorkflowConfig.AddTextParameter('TransferToFilter', '', TransferToFilter_CptLbl, StrSubstNo(TransferFilter_DescrLbl, TransferHeader.FieldCaption("Transfer-to Code"), TransferHeader.TableCaption));

    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        TransferHeader: Record "Transfer Header";
        CreateNewRecordConfirmLbl: Label 'Create new Transfer Order with "%1" and "%2"';
    begin
        Setup.GetPOSStore(POSStore);
        setup.GetPOSUnit(POSUnit);

        if Context.GetBooleanParameter('NewRecord') then begin
            if Confirm(CreateNewRecordConfirmLbl, true, TransferHeader.FieldCaption("Transfer-from Code"), TransferHeader.FieldCaption("Shortcut Dimension 1 Code")) then
                FrontEnd.WorkflowResponse(InsertNewRecord(POSStore, POSUnit, Context));
        end else
            FrontEnd.WorkflowResponse(FilterAndRunTransferOrderList(POSStore, Context));

    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionTransferOrder.js###
        'let main=async({})=>await workflow.respond();'
        );
    end;

    local procedure InsertNewRecord(POSStore: Record "NPR POS Store"; POSUnit: Record "NPR POS Unit"; Context: Codeunit "NPR POS JSON Helper"): JsonObject
    var
        POSActionBusinessLogic: Codeunit "NPR POS Action Transfer Order";
    begin
        POSActionBusinessLogic.CreateTransferOrder(POSStore, POSUnit, Context.GetStringParameter('DefaultTransferToCode'));
    end;

    local procedure FilterAndRunTransferOrderList(POSStore: Record "NPR POS Store"; Context: Codeunit "NPR POS JSON Helper"): JsonObject
    var
        TransferHeader: Record "Transfer Header";
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        UsePOSLocationAs: Option "",UseAsTransferFromFilter,UseAsTransferToFilter;
        TransferOrderList: Page "Transfer Orders";
        TransferOrderPostPrint: Codeunit "NPR TransferOrder-Post + Print";
        TransferFromFilter: Text;
        TransferToFilter: Text;
    begin
        UsePOSLocationAs := Context.GetIntegerParameter('RegisterLocation');
        case UsePOSLocationAs of
            UsePOSLocationAs::UseAsTransferFromFilter:
                TransferFromFilter := POSStore."Location Code";
            UsePOSLocationAs::UseAsTransferToFilter:
                TransferToFilter := POSStore."Location Code";
        end;

        if TransferFromFilter = '' then
            TransferFromFilter := Context.GetStringParameter('TransferFromFilter');
        if TransferToFilter = '' then
            TransferToFilter := Context.GetStringParameter('TransferToFilter');

        if TransferFromFilter <> '' then
            TransferHeader.SetFilter("Transfer-from Code", TransferFromFilter);
        if TransferToFilter <> '' then
            TransferHeader.SetFilter("Transfer-to Code", TransferToFilter);

        ReportSelectionRetail.Reset();
        ReportSelectionRetail.SetRange("Report Type", ReportSelectionRetail."Report Type"::"Transfer Order");
        if ReportSelectionRetail.FindFirst() then
            TransferOrderPostPrint.SetValues(true);

        Clear(TransferOrderList);
        TransferOrderList.SetTableView(TransferHeader);
        TransferOrderList.Run();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        Location: Record Location;
        LocationList: Page "Location List";
    begin
        if POSParameterValue."Action Code" <> Format(Enum::"NPR POS Workflow"::TRANSFER_ORDER) then
            exit;

        if POSParameterValue.Name in ['TransferFromFilter', 'TransferToFilter', 'DefaultTransferToCode'] then begin
            Location.FilterGroup(2);
            Location.SetRange("Use As In-Transit", false);
            Location.FilterGroup(0);
        end;

        case POSParameterValue.Name of
            'TransferFromFilter', 'TransferToFilter':
                begin
                    Clear(LocationList);
                    LocationList.LookupMode(true);
                    LocationList.SetTableView(Location);
                    if LocationList.RunModal() = ACTION::LookupOK then
                        POSParameterValue.Value := CopyStr(LocationList.GetSelectionFilter(), 1, MaxStrLen(POSParameterValue.Value));
                end;
            'DefaultTransferToCode':
                begin
                    if POSParameterValue.Value <> '' then begin
                        Location.Code := CopyStr(POSParameterValue.Value, 1, MaxStrLen(Location.Code));
                        IF Location.FindFirst() then;
                    end;
                    if PAGE.RunModal(0, Location) = ACTION::LookupOK then
                        POSParameterValue.Value := Location.Code;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', false, false)]
    local procedure OnValidateValue(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        Location: Record Location;
    begin
        if POSParameterValue."Action Code" <> Format(Enum::"NPR POS Workflow"::TRANSFER_ORDER) then
            exit;

        case POSParameterValue.Name of
            'DefaultTransferToCode':
                begin
                    if POSParameterValue.Value = '' then
                        exit;
                    Location.SetRange("Use As In-Transit", false);
                    Location.Code := CopyStr(POSParameterValue.Value, 1, MaxStrLen(Location.Code));
                    Location.Find();
                end;
        end;
    end;
}
