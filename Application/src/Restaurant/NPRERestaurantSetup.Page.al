page 6150669 "NPR NPRE Restaurant Setup"
{
    Extensible = False;
    Caption = 'Restaurant Setup';
    PageType = Card;
    SourceTable = "NPR NPRE Restaurant Setup";
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Waiter Pad No. Series"; Rec."Waiter Pad No. Serie")
                {
                    ToolTip = 'Specifies the value of the Waiter Pad No. Serie field';
                    ApplicationArea = NPRRetail;
                }
                field("Default Service Flow Profile"; Rec."Default Service Flow Profile")
                {
                    ToolTip = 'Specifies the value of the Default Service Flow Profile field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Seating)
            {
                Caption = 'Seating';
                group(Statuses)
                {
                    Caption = 'Statuses';
                    field("Seat.Status: Ready"; Rec."Seat.Status: Ready")
                    {
                        Caption = 'Ready for New Guests';
                        ToolTip = 'Specifies the value of the Ready for New Guests field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Seat.Status: Occupied"; Rec."Seat.Status: Occupied")
                    {
                        Caption = 'Occupied';
                        ToolTip = 'Specifies the value of the Occupied field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Seat.Status: Reserved"; Rec."Seat.Status: Reserved")
                    {
                        Caption = 'Reserved';
                        ToolTip = 'Specifies the value of the Reserved field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Seat.Status: Cleaning Required"; Rec."Seat.Status: Cleaning Required")
                    {
                        Caption = 'Cleaning Required';
                        ToolTip = 'Specifies the value of the Cleaning Required field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group(KitchenInegration)
            {
                Caption = 'Kitchen Integration';
                field("Auto-Send Kitchen Order"; Rec."Auto-Send Kitchen Order")
                {
                    ToolTip = 'Specifies whether system will automatically send kitchen orders as soon as items are saved to waiter pad';
                    ApplicationArea = NPRRetail;
                }
                field("Serving Step Discovery Method"; Rec."Serving Step Discovery Method")
                {
                    ToolTip = 'Specifies the value of the Serving Step Discovery Method field';
                    ApplicationArea = NPRRetail;
                }
                group(Print)
                {
                    Caption = 'Print';
                    field("Kitchen Printing Active"; Rec."Kitchen Printing Active")
                    {
                        ToolTip = 'Specifies the value of the Kitchen Printing Active field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Re-send All on New Lines"; Rec."Re-send All on New Lines")
                    {
                        Enabled = Rec."Kitchen Printing Active";
                        ToolTip = 'Specifies whether full kitchen order with all items, including those previously existed on the waiter pad, should be sent to kitchen, when new items are added';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(KDS)
                {
                    Caption = 'KDS';
                    Visible = ShowKDS;
                    field("KDS Active"; Rec."KDS Active")
                    {
                        ToolTip = 'Specifies the value of the KDS Active field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Order ID Assignment Method"; Rec."Order ID Assignment Method")
                    {
                        ToolTip = 'Specifies whether system should amend previously created kitchen order for the waiter pad with newly added items, or create a new order';
                        ApplicationArea = NPRRetail;
                    }
                    field("Kitchen Req. Handl. On Serving"; Rec."Kitchen Req. Handl. On Serving")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies how existing kitchen station production requests should be handled, if an item has been served prior to finishing production';
                    }
                    field("Order Is Ready For Serving"; Rec."Order Is Ready For Serving")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies when kitchen order is assigned "Ready for Serving" status';
                    }
                }
            }
            group(POSActions)
            {
                Caption = 'POS Actions';

                field("Save Layout Action"; Rec."Save Layout Action")
                {
                    ToolTip = 'Specifies the value of the Save Layout Action field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        ParamMgt.EditParametersForField(Rec."Save Layout Action", Rec.RecordId, Rec.FieldNo("Save Layout Action"));
                    end;
                }
                field("Select Restaurant Action"; Rec."Select Restaurant Action")
                {
                    ToolTip = 'Specifies the value of the Select Restaurant Action field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        ParamMgt.EditParametersForField(Rec."Select Restaurant Action", Rec.RecordId, Rec.FieldNo("Select Restaurant Action"));
                    end;
                }
                field("Select Table Action"; Rec."Select Table Action")
                {
                    ToolTip = 'Specifies the value of the Select Table Action field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        ParamMgt.EditParametersForField(Rec."Select Table Action", Rec.RecordId, Rec.FieldNo("Select Table Action"));
                    end;
                }
                field("Go to POS Action"; Rec."Go to POS Action")
                {
                    ToolTip = 'Specifies the value of the Go to POS Action field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        ParamMgt.EditParametersForField(Rec."Go to POS Action", Rec.RecordId, Rec.FieldNo("Go to POS Action"));
                    end;
                }
                field("New Waiter Pad Action"; Rec."New Waiter Pad Action")
                {
                    ToolTip = 'Specifies the value of the New Waiter Pad Action field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        ParamMgt.EditParametersForField(Rec."New Waiter Pad Action", Rec.RecordId, Rec.FieldNo("New Waiter Pad Action"));
                    end;
                }
                field("Select Waiter Pad Action"; Rec."Select Waiter Pad Action")
                {
                    ToolTip = 'Specifies the value of the Select Waiter Pad Action field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        ParamMgt.EditParametersForField(Rec."Select Waiter Pad Action", Rec.RecordId, Rec.FieldNo("Select Waiter Pad Action"));
                    end;
                }
                field("Set Waiter Pad Status Action"; Rec."Set Waiter Pad Status Action")
                {
                    ToolTip = 'Specifies the value of the Set Waiter Pad Status Action field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        ParamMgt.EditParametersForField(Rec."Set Waiter Pad Status Action", Rec.RecordId, Rec.FieldNo("Set Waiter Pad Status Action"));
                    end;
                }
                field("Set Table Status Action"; Rec."Set Table Status Action")
                {
                    ToolTip = 'Specifies the value of the Set Table Status Action field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        ParamMgt.EditParametersForField(Rec."Set Table Status Action", Rec.RecordId, Rec.FieldNo("Set Table Status Action"));
                    end;
                }
                field("Set Number of Guests Action"; Rec."Set Number of Guests Action")
                {
                    ToolTip = 'Specifies the value of the Set Number of Guests Action field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        ParamMgt.EditParametersForField(Rec."Set Number of Guests Action", Rec.RecordId, Rec.FieldNo("Set Number of Guests Action"));
                    end;
                }
            }
            part(PrintTemplates; "NPR NPRE Print Templ. Subpage")
            {
                Caption = 'Print Templates';
                ApplicationArea = NPRRetail;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Print Categories")
            {
                Caption = 'Print Categories';
                Image = PrintForm;
                RunObject = Page "NPR NPRE Slct Prnt Cat.";
                ToolTip = 'Executes the Print Categories action';
                ApplicationArea = NPRRetail;
            }
            action(Restaurants)
            {
                Caption = 'Restaurants';
                Image = NewBranch;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR NPRE Restaurants";
                ToolTip = 'Executes the Restaurants action';
                ApplicationArea = NPRRetail;
            }
            group(Kitchen)
            {
                Caption = 'Kitchen';
                Image = Departments;
                action(KitchenStations)
                {
                    Caption = 'Stations';
                    Image = Category;
                    RunObject = Page "NPR NPRE Kitchen Stations";
                    RunPageLink = "Restaurant Code" = CONST('');
                    ToolTip = 'Executes the Stations action';
                    ApplicationArea = NPRRetail;
                }
                action(KitchenStationSelection)
                {
                    Caption = 'Station Selection Setup';
                    Image = Flow;
                    RunObject = Page "NPR NPRE Kitchen Station Slct.";
                    RunPageLink = "Restaurant Code" = CONST('');
                    ToolTip = 'Executes the Station Selection Setup action';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
    begin
        if not Rec.Get() then
            Rec.Insert();

        ShowKDS := KitchenOrderMgt.KDSAvailable();
    end;

    var
        ParamMgt: Codeunit "NPR POS Action Param. Mgt.";
        ShowKDS: Boolean;
}
