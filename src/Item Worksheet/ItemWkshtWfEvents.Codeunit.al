codeunit 6060053 "NPR Item Wksht. Wf Events"
{
    // NPR5.25\BR  \20160720  CASE 246088 Object Created


    trigger OnRun()
    begin
    end;

    local procedure NewItemWorksheetLineInserted(): Code[128]
    begin
        exit('NewItemWorksheetLineInserted');
    end;

    local procedure ItemStatusChanged(): Code[128]
    begin
        exit('ItemStatusChanged');
    end;

    [EventSubscriber(ObjectType::Codeunit, 1520, 'OnAddWorkflowEventsToLibrary', '', true, true)]
    local procedure AddItemWorksheetEventsToLibrary()
    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        TextDescrNewItemWorksheetLineInserted: Label 'A new Item Worksheet Line is inserted in the Item Worksheet.';
        TextDescrItemStatusChanged: Label 'The status of an Item was changed';
    begin
        WorkflowEventHandling.AddEventToLibrary(NewItemWorksheetLineInserted, DATABASE::"NPR Item Worksheet Line", TextDescrNewItemWorksheetLineInserted, 0, false);
        WorkflowEventHandling.AddEventToLibrary(ItemStatusChanged, DATABASE::Item, TextDescrItemStatusChanged, 0, false);
    end;

    [EventSubscriber(ObjectType::Table, 6060042, 'OnAfterInsertEvent', '', false, false)]
    local procedure RunWorkflowOnAfterInsertWorksheeLine(var Rec: Record "NPR Item Worksheet Line"; RunTrigger: Boolean)
    var
        WorkflowManagement: Codeunit "Workflow Management";
    begin
        WorkflowManagement.HandleEvent(NewItemWorksheetLineInserted, Rec);
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterModifyEvent', '', true, true)]
    local procedure RunWorkflowOnAfterModifyItemStatus(var Rec: Record Item; var xRec: Record Item; RunTrigger: Boolean)
    var
        WorkflowManagement: Codeunit "Workflow Management";
    begin
        if Rec."NPR Item Status" = xRec."NPR Item Status" then
            exit;
        WorkflowManagement.HandleEventWithxRec(ItemStatusChanged, Rec, xRec);
    end;
}

