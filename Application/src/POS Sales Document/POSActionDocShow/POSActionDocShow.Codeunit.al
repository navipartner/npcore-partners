codeunit 6150867 "NPR POS Action: Doc. Show" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Open sales document via list or from selected POS line.';
        CaptionSalesView: Label 'Doc. View';
        CaptionSelectCustomer: Label 'Select Customer';
        CaptionSelectType: Label 'Selection Method';
        CaptionGroupCodeFilter: Label 'Group Code Filter';
        DescSalesView: Label 'Pre-filtered list of sales documents';
        DescSelectCustomer: Label 'Prompt for customer selection if none on sale';
        DescSelectType: Label 'Select via list or attempt to open any POS line related document.';
        DescGroupCodeFilter: Label 'Specifies the group code filter on the sales list';
        OptionSelectType: Label 'List,SelectedLine', Locked = true;
        OptionSelectType_Caption: Label 'List,Selected Line';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddBooleanParameter(ParameterSelectCustomer_Name(), true, CaptionSelectCustomer, DescSelectCustomer);
        WorkflowConfig.AddOptionParameter(
            ParameterSelectType_Name(),
            OptionSelectType,
#pragma warning disable AA0139
            SelectStr(1, OptionSelectType),
# pragma warning restore
            CaptionSelectType,
            DescSelectType,
            OptionSelectType_Caption);
        WorkflowConfig.AddTextParameter(ParameterGroupCodeFilter_Name(), '', CaptionGroupCodeFilter, DescGroupCodeFilter);
        WorkflowConfig.AddTextParameter(ParameterSOViewString_Name(), '', CaptionSalesView, DescSalesView);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'ShowDoc':
                FrontEnd.WorkflowResponse(ShowDocument(Context, Sale, SaleLine));
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionDocShow.js###
'let main=async({})=>await workflow.respond("ShowDoc");'
                );
    end;

    local procedure ShowDocument(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"): JsonObject
    var
        POSActionDocShowB: Codeunit "NPR POS Action: Doc. Show-B";
        SelectCustomer: Boolean;
        GroupCodeFilter: Text;
        SelectType: Integer;
        SalesOrderViewString: Text;
    begin
        SelectType := Context.GetIntegerParameter(ParameterSelectType_Name());
        SalesOrderViewString := Context.GetStringParameter(ParameterSOViewString_Name());
        SelectCustomer := Context.GetBooleanParameter(ParameterSelectCustomer_Name());
        GroupCodeFilter := Context.GetStringParameter(ParameterGroupCodeFilter_Name());

        POSActionDocShowB.ShowSaleDocument(Sale, SaleLine, SelectCustomer, SelectType, SalesOrderViewString, GroupCodeFilter);
    end;

    local procedure ActionCode(): Code[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::SALES_DOC_SHOW));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        SalesHeader: Record "Sales Header";
        NPRGroupCodeUtils: Codeunit "NPR Group Code Utils";
        FilterPageBuilder: FilterPageBuilder;
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            ParameterSOViewString_Name():
                begin
                    FilterPageBuilder.AddRecord(SalesHeader.TableCaption, SalesHeader);
                    if POSParameterValue.Value <> '' then begin
                        SalesHeader.SetView(POSParameterValue.Value);
                        FilterPageBuilder.SetView(SalesHeader.TableCaption, SalesHeader.GetView(false));
                    end;
                    if FilterPageBuilder.RunModal() then
                        POSParameterValue.Value := CopyStr(FilterPageBuilder.GetView(SalesHeader.TableCaption, false), 1, MaxStrLen(POSParameterValue.Value));
                end;
            ParameterGroupCodeFilter_Name():
                begin
                    NPRGroupCodeUtils.LookUpGroupCodeValue(POSParameterValue.Value);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', false, false)]
    local procedure OnValidateValue(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        SalesHeader: Record "Sales Header";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            ParameterSOViewString_Name():
                if POSParameterValue.Value <> '' then
                    SalesHeader.SetView(POSParameterValue.Value);
        end;
    end;

    local procedure ParameterSelectType_Name(): Text[30]
    begin
        exit('SelectType');
    end;

    local procedure ParameterSOViewString_Name(): Text[30]
    begin
        exit('SalesOrderViewString');
    end;

    local procedure ParameterSelectCustomer_Name(): Text[30]
    begin
        exit('SelectCustomer');
    end;

    local procedure ParameterGroupCodeFilter_Name(): Text[30]
    begin
        exit('GroupCodeFilter');
    end;


}
