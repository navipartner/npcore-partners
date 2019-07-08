codeunit 6060054 "Item Wksht. Workflow Responses"
{
    // NPR5.25\BR \20160707 CASE 246088 New Codeunit

    EventSubscriberInstance = StaticAutomatic;

    trigger OnRun()
    begin
    end;

    local procedure SetItemStatusCode(): Code[128]
    begin
        exit('SETITEMSTATUS');
    end;

    local procedure SetItemFieldCode(): Code[128]
    begin
        exit('SETITEMFIELD');
    end;

    [EventSubscriber(ObjectType::Codeunit, 1521, 'OnAddWorkflowResponsesToLibrary', '', true, true)]
    local procedure AddResponsesToLibrary()
    var
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
        WorkflowStepArgument: Record "Workflow Step Argument";
    begin
        WorkflowResponseHandling.AddResponseToLibrary(SetItemStatusCode,DATABASE::Item,'TEST2 Set the status of an item.','GROUP 7');
        WorkflowResponseHandling.AddResponseToLibrary(SetItemFieldCode,DATABASE::Item,'TEST2 Set a field on the item.','GROUP 7');
    end;

    [EventSubscriber(ObjectType::Codeunit, 1521, 'OnAddWorkflowResponsePredecessorsToLibrary', '', true, true)]
    local procedure AddResponseCombinations(ResponseFunctionName: Code[128])
    var
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
    begin
        case ResponseFunctionName of
          SetItemStatusCode:
            begin
              WorkflowResponseHandling.AddResponsePredecessor(SetItemStatusCode,WorkflowEventHandling.RunWorkflowOnItemChangedCode);
           end;
          SetItemFieldCode:
            begin
              WorkflowResponseHandling.AddResponsePredecessor(SetItemStatusCode,WorkflowEventHandling.RunWorkflowOnItemChangedCode);
           end;
        end;
    end;

    local procedure SetItemStatus(Item: Record Item;WorkflowStepInstance: Record "Workflow Step Instance")
    var
        WorkflowStepArgument: Record "Workflow Step Argument";
    begin
        if WorkflowStepArgument.Get(WorkflowStepInstance.Argument) then;
    end;

    local procedure SetItemField(Item: Record Item;WorkflowStepInstance: Record "Workflow Step Instance")
    var
        WorkflowStepArgument: Record "Workflow Step Argument";
    begin
        if WorkflowStepArgument.Get(WorkflowStepInstance.Argument) then;
    end;

    [EventSubscriber(ObjectType::Codeunit, 1521, 'OnExecuteWorkflowResponse', '', true, true)]
    local procedure ExcecuteSetItemStatusCode(var ResponseExecuted: Boolean;Variant: Variant;xVariant: Variant;ResponseWorkflowStepInstance: Record "Workflow Step Instance")
    var
        WorkflowResponse: Record "Workflow Response";
    begin
        if WorkflowResponse.Get(ResponseWorkflowStepInstance."Function Name") then
          case WorkflowResponse."Function Name" of
            SetItemStatusCode :
              begin
                SetItemStatus(Variant,ResponseWorkflowStepInstance);
                ResponseExecuted := true;
              end;
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 1521, 'OnExecuteWorkflowResponse', '', true, true)]
    local procedure ExcecuteSetItemField(var ResponseExecuted: Boolean;Variant: Variant;xVariant: Variant;ResponseWorkflowStepInstance: Record "Workflow Step Instance")
    var
        WorkflowResponse: Record "Workflow Response";
    begin
        if WorkflowResponse.Get(ResponseWorkflowStepInstance."Function Name") then
          case WorkflowResponse."Function Name" of
            SetItemFieldCode :
              begin
                SetItemField(Variant,ResponseWorkflowStepInstance);
                ResponseExecuted := true;
              end;
          end;
    end;
}

