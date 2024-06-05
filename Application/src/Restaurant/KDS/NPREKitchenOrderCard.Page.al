page 6150696 "NPR NPRE Kitchen Order Card"
{
    Extensible = False;
    Caption = 'Kitchen Order Card';
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR NPRE Kitchen Order";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Order ID"; Rec."Order ID")
                {
                    Editable = false;
                    ToolTip = 'Specifies the order unique Id, assigned by the system according to an automatically maintained number series.';
                    ApplicationArea = NPRRetail;
                }
                field("Restaurant Code"; Rec."Restaurant Code")
                {
                    Editable = false;
                    ToolTip = 'Specifies the restaurant the ordered was created for.';
                    ApplicationArea = NPRRetail;
                }
                field("Order Status"; Rec."Order Status")
                {
                    Editable = false;
                    ToolTip = 'Specifies current status of the order.';
                    ApplicationArea = NPRRetail;
                }
                field(Priority; Rec.Priority)
                {
                    ToolTip = 'Specifies the priority of the order. The higher the number, the lower the priority. This priority is going to be assigned by default to all kitchen requests created under this order.';
                    ApplicationArea = NPRRetail;
                }
                field("Created Date-Time"; Rec."Created Date-Time")
                {
                    Editable = false;
                    ToolTip = 'Specifies the date-time the order was created at.';
                    ApplicationArea = NPRRetail;
                }
                field("Expected Dine Date-Time"; Rec."Expected Dine Date-Time")
                {
                    ToolTip = 'Specifies the date-time the customer requested the order be ready at.';
                    ApplicationArea = NPRRetail;
                }
                field("Finished Date-Time"; Rec."Finished Date-Time")
                {
                    Editable = false;
                    ToolTip = 'Specifies the date-time the order was finished at.';
                    ApplicationArea = NPRRetail;
                }
                field("On Hold"; Rec."On Hold")
                {
                    ToolTip = 'Specifies if the order is put on hold. The field has no impact on the way the order is handled by the system currently. However, orders put on hold won’t be deleted by the retention policy.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014409; Notes)
            {
                Visible = false;
                ApplicationArea = NPRRetail;
            }
            systempart(Control6014408; Links)
            {
                Visible = false;
                ApplicationArea = NPRRetail;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Show Requests")
            {
                Caption = 'Show Requests';
                Image = ExpandDepositLine;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR NPRE Kitchen Req.";
                RunPageLink = "Order ID" = FIELD("Order ID"), "Restaurant Code" = field("Restaurant Code");
                RunPageView = SORTING("Order ID");
                ToolTip = 'View outstaning kitchen requests for the order.';
                ApplicationArea = NPRRetail;
            }
            action(Cancel)
            {
                Caption = 'Cancel';
                Image = CloseDocument;
                ToolTip = 'Executes the cancel order function. Note that the system will also cancel any unfinished kitchen requests associated with the order. However, it won’t cancel the source document, from which the order was created (usually a waiter pad). You’ll need to do this manually.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
                    ConfirmCancelQst: Label 'This action will cancel kitchen order #%1. Note that the system will also cancel any unfinished kitchen requests associated with the order. However, it won’t cancel the source document, from which the order was created (usually a waiter pad). You’ll need to do this manually.\Are you sure you want to proceed?', Comment = '%1 - order number';
                begin
                    CurrPage.SaveRecord();
                    if not Confirm(ConfirmCancelQst, false, Rec."Order ID") then
                        exit;
                    KitchenOrderMgt.CancelKitchenOrder(Rec);
                end;
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        LinkedRequestsError: Label 'Cannot delete the order as there are kitchen requests associated with it.';
    begin
        KitchenRequest.SetRange("Order ID", Rec."Order ID");
        if not KitchenRequest.IsEmpty() then begin
            Error(LinkedRequestsError);
        end;
    end;
}
