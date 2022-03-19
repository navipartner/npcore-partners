codeunit 6060053 "NPR Item Wksht. Wf Events"
{
    Access = Internal;
    local procedure ItemStatusChanged(): Code[128]
    begin
        exit('ItemStatusChanged');
    end;

    local procedure NewItemWorksheetLineInserted(): Code[128]
    begin
        exit('NewItemWorksheetLineInserted');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', true, true)]
    local procedure AddItemWorksheetEventsToLibrary()
    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        DescrNewItemWorksheetLineInsertedTxt: Label 'A new Item Worksheet Line is inserted in the Item Worksheet.';
        DescrItemStatusChangedTxt: Label 'The status of an Item was changed.';
    begin
        WorkflowEventHandling.AddEventToLibrary(
            NewItemWorksheetLineInserted(), DATABASE::"NPR Item Worksheet Line",
            DescrNewItemWorksheetLineInsertedTxt, 0, false);
        WorkflowEventHandling.AddEventToLibrary(
            ItemStatusChanged(), DATABASE::Item,
            DescrItemStatusChangedTxt, 0, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Item Worksheet Line", 'OnAfterInsertEvent', '', false, false)]
    local procedure RunWorkflowOnAfterInsertWorksheeLine(var Rec: Record "NPR Item Worksheet Line"; RunTrigger: Boolean)
    var
        WorkflowManagement: Codeunit "Workflow Management";
    begin
        WorkflowManagement.HandleEvent(NewItemWorksheetLineInserted(), Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterModifyEvent', '', true, true)]
    local procedure RunWorkflowOnAfterModifyItemStatus(var Rec: Record Item; var xRec: Record Item; RunTrigger: Boolean)
    var
        AuxItem: Record "NPR Auxiliary Item";
        xAuxItem: Record "NPR Auxiliary Item";
        WorkflowManagement: Codeunit "Workflow Management";
    begin
        Rec.NPR_GetAuxItem(AuxItem);
        xRec.NPR_GetAuxItem(xAuxItem);
        if AuxItem."Item Status" = xAuxItem."Item Status" then
            exit;
        WorkflowManagement.HandleEventWithxRec(ItemStatusChanged(), Rec, xRec);
    end;
}

