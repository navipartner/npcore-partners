codeunit 6150813 "NPR POS Action: Item Lookup" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        LookupType: Option Item,SKU;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This is a built in function for handling lookup';
        ParamLookupTypeCaption_Lbl: Label 'Lookup Type';
        ParamLookupTypeDesc_Lbl: Label 'Defines the lookup type';
        ParamLookupTypeOptions_Lbl: Label 'Item,SKU', Locked = true;
        ParamView_Lbl: Label 'View';
        ParamLocationFilterCaption_Lbl: Label 'Location Filter';
        ParamLocationFilterDesc_Lbl: Label 'Defines location filter';
        ParamLocationFilterOptions_Lbl: Label 'POS Store,POS Unit,Use View', Locked = true;
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddOptionParameter(
                       'LookupType',
                       ParamLookupTypeOptions_Lbl,
#pragma warning disable AA0139
                       SelectStr(1, ParamLookupTypeOptions_Lbl),
#pragma warning restore 
                       ParamLookupTypeCaption_Lbl,
                       ParamLookupTypeDesc_Lbl,
                       ParamLookupTypeOptions_Lbl
                       );
        WorkflowConfig.AddTextParameter('View', '', ParamView_Lbl, ParamView_Lbl);
        WorkflowConfig.AddOptionParameter(
          'LocationFilter',
          ParamLocationFilterOptions_Lbl,
#pragma warning disable AA0139
          SelectStr(1, ParamLocationFilterOptions_Lbl),
#pragma warning restore 
          ParamLocationFilterCaption_Lbl,
          ParamLocationFilterDesc_Lbl,
          ParamLocationFilterOptions_Lbl
        );

    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'do_lookup':
                FrontEnd.WorkflowResponse(OnLookup(Context, SaleLine, Setup));
            'prepareWorkflow':
                FrontEnd.WorkflowResponse(PrepareWorkflow(Setup));
            'complete_lookup':
                FrontEnd.WorkflowResponse(CompleteLookup(Context));
            'doLegacyWorkflow':
                FrontEnd.WorkflowResponse(DoLegacyWorkflow(Setup, Context, FrontEnd));
        end;
    end;


    local procedure OnLookup(Context: Codeunit "NPR POS JSON Helper"; SaleLine: Codeunit "NPR POS Sale Line"; Setup: Codeunit "NPR POS Setup") Response: JsonObject
    var
        SelectedItem: Code[20];
    begin
        LookupType := Context.GetIntegerParameter('LookupType');

        case LookupType of
            LookupType::Item:
                SelectedItem := OnLookupItem(SaleLine, Setup, Context);
            LookupType::SKU:
                SelectedItem := OnLookupSKU(Setup, Context);
            else begin
                    Error('LookUp type %1 is not supported.', Format(LookupType));
                end;
        end;

        if SelectedItem = '' then
            Error('');

        Response.ReadFrom('{}');
        Response.Add('itemno', SelectedItem);
    end;

    local procedure OnLookupItem(POSSaleLine: Codeunit "NPR POS Sale Line"; Setup: Codeunit "NPR POS Setup"; Context: Codeunit "NPR POS JSON Helper") ItemNo: Code[20]
    var
        POSActionItemLookupB: Codeunit "NPR POS Action: Item Lookup B";
        ItemView: Text;
        LocationFilterOption: Integer;
    begin
        ItemView := Context.GetStringParameter('View');
        LocationFilterOption := Context.GetIntegerParameter('LocationFilter');
        ItemNo := POSActionItemLookupB.LookupItem(POSSaleLine, Setup, ItemView, LocationFilterOption);
    end;

    local procedure CompleteLookup(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        ItemNo: Code[20];
    begin
        ItemNo := CopyStr(Context.GetString('selected_itemno'), 1, MaxStrLen(ItemNo));
        if ItemNo <> '' then begin
            Response.ReadFrom('{}');
            Response.Add('itemno', ItemNo);
            Response.Add('itemQuantity', 1);
            Response.Add('itemIdentifierType', 0); //0 = ItemNumber
        end;
    end;

    local procedure PrepareWorkflow(Setup: Codeunit "NPR POS Setup") Response: JsonObject
    var
        POSSetup: Record "NPR POS Setup";
        POSAction: Record "NPR POS Action";
        POSSession: Codeunit "NPR POS Session";
        WorkflowVersion: Integer;
    begin
        Setup.GetNamedActionSetup(POSSetup);

        if not POSSession.RetrieveSessionAction(POSSetup."Item Insert Action Code", POSAction) then
            POSAction.Get(POSSetup."Item Insert Action Code");

        // WorkflowVersion is used to determine processing flow in front-end. 
        // 1: is Legacy

        WorkflowVersion := 3;
        if (POSAction."Workflow Implementation" = POSAction."Workflow Implementation"::LEGACY) then
            WorkflowVersion := 1;

        Response.ReadFrom('{}');
        Response.Add('workflowName', POSSetup."Item Insert Action Code");
        Response.Add('workflowVersion', WorkflowVersion);
    end;

    local procedure DoLegacyWorkflow(Setup: Codeunit "NPR POS Setup"; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management") Response: JsonObject
    var
        ItemNo: Code[20];
        POSSetup: Record "NPR POS Setup";
        POSAction: Record "NPR POS Action";
        POSSession: Codeunit "NPR POS Session";
    begin
        ItemNo := CopyStr(Context.GetString('selected_itemno'), 1, MaxStrLen(ItemNo));
        if ItemNo <> '' then begin
            Setup.GetNamedActionSetup(POSSetup);

            if not POSSession.RetrieveSessionAction(POSSetup."Item Insert Action Code", POSAction) then
                POSAction.Get(POSSetup."Item Insert Action Code");

            POSAction.SetWorkflowInvocationParameterUnsafe('itemNo', ItemNo);
            POSAction.SetWorkflowInvocationParameterUnsafe('itemQuantity', 1);
            POSAction.SetWorkflowInvocationParameterUnsafe('itemIdentifierType', 0); //0 = ItemNumber
            FrontEnd.InvokeWorkflow(POSAction);

            Response.ReadFrom('{}');
            exit(Response);
        end;
    end;

    local procedure OnLookupSKU(POSSetup: Codeunit "NPR POS Setup"; Context: Codeunit "NPR POS JSON Helper") ItemNo: Code[20]
    var
        POSActionItemLookupB: Codeunit "NPR POS Action: Item Lookup B";
        SKUView: Text;
        LocationFilterOption: Integer;
    begin
        SKUView := Context.GetStringParameter('View');
        LocationFilterOption := Context.GetIntegerParameter('LocationFilter');
        ItemNo := POSActionItemLookupB.LookupSKU(POSSetup, SKUView, LocationFilterOption);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionItemLookup.js###
'let main=async({workflow:e,context:r,parameters:m})=>{const{itemno:t}=await e.respond("do_lookup"),{workflowName:a,workflowVersion:i}=await e.respond("prepareWorkflow");if(i==1&&await e.respond("doLegacyWorkflow",{selected_itemno:t}),i>=2){const{itemQuantity:o,itemIdentifierType:n}=await e.respond("complete_lookup",{selected_itemno:t});await e.run(a,{parameters:{itemNo:t,itemQuantity:o,itemIdentifierType:n}})}};'
       );
    end;
}

