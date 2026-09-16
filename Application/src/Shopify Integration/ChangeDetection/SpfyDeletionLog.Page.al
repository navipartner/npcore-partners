page 6150971 "NPR Spfy Deletion Log"
{
    ApplicationArea = NPRShopify;
    Caption = 'Shopify Deletion Log';
    PageType = List;
    SourceTable = "NPR Spfy Deletion Log";
    UsageCategory = None;
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the entry number of the deletion log record.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the state of the delete: Pending (captured, not yet sent), Processed (a task to delete the object in Shopify was created), Cancelled (the entity was reactivated in Business Central before the delete was sent), or Quarantined (dispatch kept failing and the delete is parked until it is requeued).';
                    StyleExpr = StatusStyle;
                }
                field("Dispatch Failure Count"; Rec."Dispatch Failure Count")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies how many consecutive detection cycles this delete failed to dispatch. When the failure threshold is reached, the entry is quarantined.';
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ApplicationArea = NPRShopify;
                    Caption = 'Created At';
                    ToolTip = 'Specifies when the delete was captured in Business Central.';
                }
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the Business Central table the deleted entity belonged to.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the item number of the deleted entity, when applicable.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the variant code of the deleted entity, when applicable.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the customer number of the deleted entity, when applicable.';
                }
                field("Shopify Store Code"; Rec."Shopify Store Code")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the Shopify store the delete targets.';
                }
                field("Shopify ID Type"; Rec."Shopify ID Type")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the type of Shopify identifier being deleted.';
                }
                field("Shopify ID"; Rec."Shopify ID")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the identifier of the object to delete in Shopify.';
                }
                field("NC Task Entry No."; Rec."NC Task Entry No.")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the task that carries the delete request to Shopify, once the entry has been processed.';
                }
                field("Record ID"; Format(Rec."Record ID"))
                {
                    ApplicationArea = NPRShopify;
                    Caption = 'Record ID';
                    ToolTip = 'Specifies the Business Central record the deleted entity referred to.';
                    Importance = Additional;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Requeue)
            {
                ApplicationArea = NPRShopify;
                Caption = 'Requeue';
                Image = ResetStatus;
                ToolTip = 'Returns the selected quarantined deletes to Pending so the next detection cycle sends them again. Use this after the cause of the failure has been resolved.';

                trigger OnAction()
                begin
                    RequeueSelected();
                end;
            }
        }
        area(Promoted)
        {
            actionref(Requeue_Promoted; Requeue) { }
        }
    }

    trigger OnAfterGetRecord()
    begin
        StatusStyle := StatusStyleExpr();
    end;

    var
        StatusStyle: Text;

    local procedure RequeueSelected()
    var
        SelectedEntry: Record "NPR Spfy Deletion Log";
        DeletionLog: Record "NPR Spfy Deletion Log";
        SpfyDeletionLogMgt: Codeunit "NPR Spfy Deletion Log Mgt";
        RequeuedCount: Integer;
        RequeuedMsg: Label '%1 entry(-ies) returned to Pending. The next detection cycle sends them again.', Comment = '%1 = the number of entries requeued';
        NoneRequeueableMsg: Label 'None of the selected entries can be requeued. Only a quarantined entry can be.';
    begin
        CurrPage.SetSelectionFilter(SelectedEntry);
        if SelectedEntry.FindSet() then
            repeat
                DeletionLog := SelectedEntry;
                if SpfyDeletionLogMgt.Requeue(DeletionLog) then
                    RequeuedCount += 1;
            until SelectedEntry.Next() = 0;
        if RequeuedCount = 0 then begin
            Message(NoneRequeueableMsg);
            exit;
        end;
        Message(RequeuedMsg, RequeuedCount);
        CurrPage.Update(false);
    end;

    local procedure StatusStyleExpr(): Text
    begin
        case Rec.Status of
            Rec.Status::Pending:
                exit('Attention');
            Rec.Status::Cancelled:
                exit('Subordinate');
            Rec.Status::Processed:
                exit('Favorable');
            Rec.Status::Quarantined:
                exit('Unfavorable');
        end;
        exit('Standard');
    end;
}
