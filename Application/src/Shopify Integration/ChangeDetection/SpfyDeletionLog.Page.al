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
                    ToolTip = 'Specifies the state of the delete: Pending (captured, not yet sent), Processed (a task to delete the object in Shopify was created), or Cancelled (the entity was reactivated in Business Central before the delete was sent).';
                    StyleExpr = StatusStyle;
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

    trigger OnAfterGetRecord()
    begin
        StatusStyle := StatusStyleExpr();
    end;

    var
        StatusStyle: Text;

    local procedure StatusStyleExpr(): Text
    begin
        case Rec.Status of
            Rec.Status::Pending:
                exit('Attention');
            Rec.Status::Cancelled:
                exit('Subordinate');
            Rec.Status::Processed:
                exit('Favorable');
        end;
        exit('Standard');
    end;
}
