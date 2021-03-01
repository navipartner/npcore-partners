page 6151262 "NPR SO Processor Act Ext"
{
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
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "Sales Quotes";

                    ToolTip = 'Specifies the number of sales quotes that are not yet converted to invoices or orders.';
                }
                field("Sales Orders - Open"; Rec."Sales Orders - Open")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "Sales Order List";
                    ToolTip = 'Specifies the number of sales orders that are not fully posted.';
                }
            }
            cuegroup("Sales Orders Released Not Shipped")
            {
                Caption = 'Sales Orders Released Not Shipped';
                field(ReadyToShip; Rec."Ready to Ship")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Ready To Ship';
                    DrillDownPageID = "Sales Order List";
                    ToolTip = 'Specifies the number of sales documents that are ready to ship.';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowOrders(Rec.FieldNo("Ready to Ship"));
                    end;
                }
                field(PartiallyShipped; Rec."Partially Shipped")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Partially Shipped';
                    DrillDownPageID = "Sales Order List";
                    ToolTip = 'Specifies the number of sales documents that are partially shipped.';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowOrders(Rec.FieldNo("Partially Shipped"));
                    end;
                }
                field(DelayedOrders; Rec.Delayed)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Delayed';
                    DrillDownPageID = "Sales Order List";
                    ToolTip = 'Specifies the number of sales documents where your delivery is delayed.';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowOrders(Rec.FieldNo(Delayed));
                    end;
                }
                field("Average Days Delayed"; Rec."Average Days Delayed")
                {
                    ApplicationArea = Basic, Suite;
                    DecimalPlaces = 0 : 1;
                    Image = Calendar;
                    ToolTip = 'Specifies the number of days that your order deliveries are delayed on average.';
                }
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    var
        RoleCenterNotificationMgt: Codeunit "Role Center Notification Mgt.";
    begin
        RoleCenterNotificationMgt.HideEvaluationNotificationAfterStartingTrial;
    end;

    trigger OnAfterGetRecord()
    var
        DocExchServiceSetup: Record "Doc. Exch. Service Setup";
    begin
        CalculateCueFieldValues;
        ShowDocumentsPendingDodExchService := false;
        if DocExchServiceSetup.Get then
            ShowDocumentsPendingDodExchService := DocExchServiceSetup.Enabled;
    end;

    trigger OnOpenPage()
    var
        RoleCenterNotificationMgt: Codeunit "Role Center Notification Mgt.";
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
    begin
        Rec.Reset;
        if not Rec.Get then begin
            Rec.Init;
            Rec.Insert;
        end;

        Rec.SetRespCenterFilter;
        Rec.SetRange("Date Filter", 0D, WorkDate - 1);
        Rec.SetFilter("Date Filter2", '>=%1', WorkDate);
        Rec.SetFilter("User ID Filter", UserId);

        RoleCenterNotificationMgt.ShowNotifications;
        ConfPersonalizationMgt.RaiseOnOpenRoleCenterEvent;
    end;

    var
        ShowDocumentsPendingDodExchService: Boolean;

    local procedure CalculateCueFieldValues()
    begin
        if Rec.FieldActive("Average Days Delayed") then
            Rec."Average Days Delayed" := Rec.CalculateAverageDaysDelayed;

        if Rec.FieldActive("Ready to Ship") then
            Rec."Ready to Ship" := Rec.CountOrders(Rec.FieldNo("Ready to Ship"));

        if Rec.FieldActive("Partially Shipped") then
            Rec."Partially Shipped" := Rec.CountOrders(Rec.FieldNo("Partially Shipped"));

        if Rec.FieldActive(Delayed) then
            Rec.Delayed := Rec.CountOrders(Rec.FieldNo(Delayed));
    end;
}
