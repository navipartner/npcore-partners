page 6150941 "NPR CMOrderLineSubpage"
{
    Extensible = false;
    Caption = 'Order Lines';
    PageType = ListPart;
    SourceTable = "NPR CMOrderLine";
    UsageCategory = None;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(LineNo; Rec.LineNo)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Line number within the order. Drill down to see the wallets issued for this line.';

                    trigger OnDrillDown()
                    var
                        OrderWallet: Record "NPR CMOrderWallet";
                    begin
                        OrderWallet.SetFilter(OrderId, '=%1', Rec.OrderId);
                        OrderWallet.SetFilter(LineNo, '=%1', Rec.LineNo);
                        Page.Run(Page::"NPR CMOrderWallets", OrderWallet);
                    end;
                }
                field(ItemNo; Rec.ItemNo)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Item number ordered.';
                }
                field(IsPackage; Rec.IsPackage)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Whether the item is a package (contains multiple components) or a single ticket item.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Number of wallets requested for this line.';
                }
                field(VisitDate; Rec.VisitDate)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Local visit date for the line (default for components without a schedule override).';
                }
                field(VisitTime; Rec.VisitTime)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Local visit time for the line (default for components without a schedule override).';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Holder name on the line (overrides the order''s sell-to name).';
                }
                field(NotificationAddress; Rec.NotificationAddress)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Notification address for the line.';
                }
                field(Language; Rec.Language)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Language for notifications on this line.';
                }
            }
        }
    }
}
