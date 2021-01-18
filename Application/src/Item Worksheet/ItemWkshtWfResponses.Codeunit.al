codeunit 6060054 "NPR Item Wksht. Wf Responses"
{
    EventSubscriberInstance = StaticAutomatic;

    local procedure SetItemField(Item: Record Item; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        WorkflowStepArgument: Record "Workflow Step Argument";
    begin
        if WorkflowStepArgument.Get(WorkflowStepInstance.Argument) then;
    end;

    local procedure SetItemFieldCode(): Code[128]
    begin
        exit('SETITEMFIELD');
    end;

    local procedure SetItemStatus(Item: Record Item; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        WorkflowStepArgument: Record "Workflow Step Argument";
    begin
        if WorkflowStepArgument.Get(WorkflowStepInstance.Argument) then;
    end;

    local procedure SetItemStatusCode(): Code[128]
    begin
        exit('SETITEMSTATUS');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsePredecessorsToLibrary', '', true, true)]
    local procedure AddResponseCombinations(ResponseFunctionName: Code[128])
    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
    begin
        case ResponseFunctionName of
            SetItemStatusCode:
                WorkflowResponseHandling.AddResponsePredecessor(
                    SetItemStatusCode, WorkflowEventHandling.RunWorkflowOnItemChangedCode);
            SetItemFieldCode:
                WorkflowResponseHandling.AddResponsePredecessor(
                    SetItemStatusCode, WorkflowEventHandling.RunWorkflowOnItemChangedCode);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsesToLibrary', '', true, true)]
    local procedure AddResponsesToLibrary()
    var
        WorkflowStepArgument: Record "Workflow Step Argument";
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
    begin
        WorkflowResponseHandling.AddResponseToLibrary(SetItemStatusCode, DATABASE::Item, 'TEST2 Set the status of an item.', 'GROUP 7');
        WorkflowResponseHandling.AddResponseToLibrary(SetItemFieldCode, DATABASE::Item, 'TEST2 Set a field on the item.', 'GROUP 7');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnExecuteWorkflowResponse', '', true, true)]
    local procedure ExcecuteSetItemField(var ResponseExecuted: Boolean; Variant: Variant; xVariant: Variant; ResponseWorkflowStepInstance: Record "Workflow Step Instance")
    var
        WorkflowResponse: Record "Workflow Response";
    begin
        if WorkflowResponse.Get(ResponseWorkflowStepInstance."Function Name") then
            case WorkflowResponse."Function Name" of
                SetItemFieldCode:
                    begin
                        SetItemField(Variant, ResponseWorkflowStepInstance);
                        ResponseExecuted := true;
                    end;
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnExecuteWorkflowResponse', '', true, true)]
    local procedure ExcecuteSetItemStatusCode(var ResponseExecuted: Boolean; Variant: Variant; xVariant: Variant; ResponseWorkflowStepInstance: Record "Workflow Step Instance")
    var
        WorkflowResponse: Record "Workflow Response";
    begin
        if WorkflowResponse.Get(ResponseWorkflowStepInstance."Function Name") then
            case WorkflowResponse."Function Name" of
                SetItemStatusCode:
                    begin
                        SetItemStatus(Variant, ResponseWorkflowStepInstance);
                        ResponseExecuted := true;
                    end;
            end;
    end;
}

