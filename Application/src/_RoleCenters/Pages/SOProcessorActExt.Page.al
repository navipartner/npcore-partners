page 6151262 "NPR SO Processor Act Ext"
{
    Extensible = False;
    Caption = 'Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    UsageCategory = None;
    SourceTable = "Sales Cue";

    layout
    {
        area(content)
        {
            cuegroup("For Release")
            {
                Caption = 'For Release';
                field("Sales Quotes - Open"; Rec."Sales Quotes - Open")
                {

                    DrillDownPageID = "Sales Quotes";

                    ToolTip = 'Specifies the number of sales quotes that are not yet converted to invoices or orders.';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Orders - Open"; Rec."Sales Orders - Open")
                {

                    DrillDownPageID = "Sales Order List";
                    ToolTip = 'Specifies the number of sales orders that are not fully posted.';
                    ApplicationArea = NPRRetail;
                }
            }
            cuegroup(Control6014404)
            {
                Caption = 'Actions';
                actions
                {
                    action("New Sales Quote")
                    {

                        Caption = 'New Sales Quote';
                        RunObject = Page "Sales Quote";
                        RunPageMode = Create;
                        Image = TileNew;
                        ToolTip = 'Offer items or services to a customer.';
                        ApplicationArea = NPRRetail;
                    }
                    action("New Sales Order")
                    {

                        Caption = 'New Sales Order';
                        RunObject = Page "Sales Order";
                        RunPageMode = Create;
                        Image = TileNew;
                        ToolTip = 'Create a new sales order for items or services that require partial posting.';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            cuegroup("Sales Orders Released Not Shipped")
            {
                Caption = 'Sales Orders Released Not Shipped';
                field(ReadyToShip; Rec."Ready to Ship")
                {

                    Caption = 'Ready To Ship';
                    DrillDownPageID = "Sales Order List";
                    ToolTip = 'Specifies the number of sales documents that are ready to ship.';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        Rec.ShowOrders(Rec.FieldNo("Ready to Ship"));
                    end;
                }
                field(PartiallyShipped; Rec."Partially Shipped")
                {

                    Caption = 'Partially Shipped';
                    DrillDownPageID = "Sales Order List";
                    ToolTip = 'Specifies the number of sales documents that are partially shipped.';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        Rec.ShowOrders(Rec.FieldNo("Partially Shipped"));
                    end;
                }
                field(DelayedOrders; Rec.Delayed)
                {

                    Caption = 'Delayed';
                    DrillDownPageID = "Sales Order List";
                    ToolTip = 'Specifies the number of sales documents where your delivery is delayed.';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        Rec.ShowOrders(Rec.FieldNo(Delayed));
                    end;
                }
                field("Average Days Delayed"; Rec."Average Days Delayed")
                {

                    DecimalPlaces = 0 : 1;
                    Image = Calendar;
                    ToolTip = 'Specifies the number of days that your order deliveries are delayed on average.';
                    ApplicationArea = NPRRetail;
                }
            }
            cuegroup(Control555)
            {
                Caption = 'Actions';
                actions
                {
                    action(Navigate)
                    {

                        Caption = 'Navigate';
                        RunObject = Page Navigate;
                        Image = TileHelp;
                        ToolTip = 'Find all entries and documents that exist for the document number and posting date on the selected entry or document.';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    var
        RoleCenterNotificationMgt: Codeunit "Role Center Notification Mgt.";
    begin
        RoleCenterNotificationMgt.HideEvaluationNotificationAfterStartingTrial();
    end;

    trigger OnAfterGetRecord()
    begin
        CalculateCueFieldValues();
    end;

    trigger OnOpenPage()
    var
        RoleCenterNotificationMgt: Codeunit "Role Center Notification Mgt.";
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;

        Rec.SetRespCenterFilter();
        Rec.SetRange("Date Filter", 0D, WorkDate() - 1);
        Rec.SetFilter("Date Filter2", '>=%1', WorkDate());
        Rec.SetFilter("User ID Filter", UserId);

        RoleCenterNotificationMgt.ShowNotifications();
        ConfPersonalizationMgt.RaiseOnOpenRoleCenterEvent();
    end;

    var

    local procedure CalculateCueFieldValues()
    begin
        if Rec.FieldActive("Average Days Delayed") then
            Rec."Average Days Delayed" := Rec.CalculateAverageDaysDelayed();

        if Rec.FieldActive("Ready to Ship") then
            Rec."Ready to Ship" := Rec.CountOrders(Rec.FieldNo("Ready to Ship"));

        if Rec.FieldActive("Partially Shipped") then
            Rec."Partially Shipped" := Rec.CountOrders(Rec.FieldNo("Partially Shipped"));

        if Rec.FieldActive(Delayed) then
            Rec.Delayed := Rec.CountOrders(Rec.FieldNo(Delayed));
    end;
}
