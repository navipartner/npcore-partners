page 6150669 "NPR NPRE Restaurant Setup"
{
    Extensible = False;
    Caption = 'Restaurant Setup';
    ContextSensitiveHelpPage = 'docs/restaurant/reference/setup/';
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
                    ToolTip = 'Specifies the code for the number series that will be used to assign numbers to waiter pads.';
                    ApplicationArea = NPRRetail;
                }
                field("Default Service Flow Profile"; Rec."Default Service Flow Profile")
                {
                    ToolTip = 'Specifies the default service flow profile, which is used for all restaurants not having their own profile assigned. Service flow profiles define general restaurant servise flow options, such as at what stage waiter pads should be closed, or when seating should be cleared.';
                    ApplicationArea = NPRRetail;
                }
                field("Default Number of Guests"; Rec."Default Number of Guests")
                {
                    ToolTip = 'Specifies the default number of guests, when a new waiter pad is created. Please note that the value may be overriden for each restaurant and each seating location.';
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
                        ToolTip = 'Specifies the status that is assigned to tables, when they become available for the next guests. The status can be assigned automatically by the system depending on selected service flow profile.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Seat.Status: Occupied"; Rec."Seat.Status: Occupied")
                    {
                        Caption = 'Occupied';
                        ToolTip = 'Specifies the status that is assigned to occupied tables. The status is assigned automatically, when a new waiter pad is created for an unoccupied table.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Seat.Status: Reserved"; Rec."Seat.Status: Reserved")
                    {
                        Caption = 'Reserved';
                        ToolTip = 'Specifies the status that is assigned to reserved tables.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Seat.Status: Cleaning Required"; Rec."Seat.Status: Cleaning Required")
                    {
                        Caption = 'Cleaning Required';
                        ToolTip = 'Specifies the status that can be assigned to tables, when cleanig is required.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Seat.Status: Blocked"; Rec."Seat.Status: Blocked")
                    {
                        Caption = 'Blocked';
                        ToolTip = 'Specifies the status that is automatically assigned to blocked tables.';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group(KitchenInegration)
            {
                Caption = 'Kitchen Integration';
                field("Auto-Send Kitchen Order"; Rec."Auto-Send Kitchen Order")
                {
                    ToolTip = 'Specifies if system should automatically create or update kitchen orders as soon as new products are saved to waiter pads. Please note that this setting may be overridden for each individual restaurant on Restaurant Card page.';
                    ApplicationArea = NPRRetail;
                }
                field("Serving Step Discovery Method"; Rec."Serving Step Discovery Method")
                {
                    ToolTip = 'Specifies the serving step discovery method. Recommended method involves usage of item routing profiles. Please avoid using the legacy method, which requires setting up print tags, as it may be discontinued at any moment.';
                    ApplicationArea = NPRRetail;
                }
                group(Print)
                {
                    Caption = 'Print';
                    field("Kitchen Printing Active"; Rec."Kitchen Printing Active")
                    {
                        ToolTip = 'Specifies whether the kitchen printing is active. Please note that this setting may be overridden for each individual restaurant on Restaurant Card page.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Re-send All on New Lines"; Rec."Re-send All on New Lines")
                    {
                        Enabled = Rec."Kitchen Printing Active";
                        ToolTip = 'Specifies if each time, when a new set of products are saved to a waiter pad, system should resend to kitchen both new and existing products from the waiter pad. Please note that this setting may be overridden for each individual restaurant on Restaurant Card page.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Print on POS Sale Cancel"; Rec."Print on POS Sale Cancel")
                    {
                        Enabled = Rec."Kitchen Printing Active";
                        ToolTip = 'Specifies whether quantity updates for items included in a cancelled POS sale should be sent (printed) to kitchen. Typically, in this scenario, requests for items with zero quantity will be printed to kitchen after the sale is cancelled. Please note that this setting may be overridden for each individual restaurant on Restaurant Card page.';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(KDS)
                {
                    Caption = 'KDS';
                    Visible = ShowKDS;
                    field("KDS Active"; Rec."KDS Active")
                    {
                        ToolTip = 'Specifies whether the Kitchen Display Systme (KDS) is active by default. Please note that this setting may be overridden for each individual restaurant on Restaurant Card page.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Order ID Assignment Method"; Rec."Order ID Assignment Method")
                    {
                        ToolTip = 'Specifies whether system should update existing kitchen order or create a new one, when a new set of products is added to an existing waiter pad. This can affect the order products are prepared at kitchen stations. Please note that this setting may be overridden for each individual restaurant on Restaurant Card page.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Kitchen Req. Handl. On Serving"; Rec."Kitchen Req. Handl. On Serving")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies how existing kitchen station production requests should be handled, if a product has been served prior to finishing production. Please note that this setting may be overridden for each individual restaurant on Restaurant Card page.';
                    }
                    field("Order Is Ready For Serving"; Rec."Order Is Ready For Serving")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies when kitchen order is assigned "Ready for Serving" status. Please note that this setting may be overridden for each individual restaurant on Restaurant Card page.';
                    }
                    group(TimeThresholds)
                    {
                        Caption = 'Delayed Order Time Thresholds';
                        field("Delayed Ord. Threshold 1 (min)"; Rec."Delayed Ord. Threshold 1 (min)")
                        {
                            ApplicationArea = NPRRetail;
                            Caption = 'Threshold 1 (min)';
                            ToolTip = 'Specifies the number of minutes after which the system will send 1st delayed kitchen order notifications and change the colour of each such order on the KDS to yellow.';
                        }
                        field("Delayed Ord. Threshold 2 (min)"; Rec."Delayed Ord. Threshold 2 (min)")
                        {
                            ApplicationArea = NPRRetail;
                            Caption = 'Threshold 2 (min)';
                            ToolTip = 'Specifies the number of minutes after which the system will send 2nd delayed kitchen order notifications and change the colour of each such order on the KDS to red.';
                        }
                        field("Notif. Resend Delay (min)"; Rec."Notif. Resend Delay (min)")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the number of minutes that the system will wait before sending another delayed order notification of the same level. Please set the field value to zero if you only want delayed order notifications to be sent once per level (threshold).';
                        }
                    }
                }
            }
            group(POSActions)
            {
                Caption = 'POS Actions (Restaurant View)';

                field("Save Layout Action"; Rec."Save Layout Action")
                {
                    ToolTip = 'Specifies the code for the POS action that is used, when restaurant layout is modified on restaurant view. Recommended value is "RV_SAVE_LAYOUT"';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        ParamMgt.EditParametersForField(Rec."Save Layout Action", Rec.RecordId, Rec.FieldNo("Save Layout Action"));
                    end;
                }
                field("Select Restaurant Action"; Rec."Select Restaurant Action")
                {
                    ToolTip = 'Specifies the code for the POS action that is used, when a restaurant is selected on restaurant view. Recommended value is "RV_SELECT_RESTAURANT"';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        ParamMgt.EditParametersForField(Rec."Select Restaurant Action", Rec.RecordId, Rec.FieldNo("Select Restaurant Action"));
                    end;
                }
                field("Select Table Action"; Rec."Select Table Action")
                {
                    ToolTip = 'Specifies the code for the POS action that is used, when a seating (table) is selected on restaurant view. Recommended value is "RV_SELECT_TABLE"';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        ParamMgt.EditParametersForField(Rec."Select Table Action", Rec.RecordId, Rec.FieldNo("Select Table Action"));
                    end;
                }
                field("Go to POS Action"; Rec."Go to POS Action")
                {
                    ToolTip = 'The field is not used.';
                    Visible = false;
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        ParamMgt.EditParametersForField(Rec."Go to POS Action", Rec.RecordId, Rec.FieldNo("Go to POS Action"));
                    end;
                }
                field("New Waiter Pad Action"; Rec."New Waiter Pad Action")
                {
                    ToolTip = 'Specifies the code for the POS action that is used, when a new waiter pad is created on restaurant view. Recommended value is "RV_NEW_WAITER_PAD"';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        ParamMgt.EditParametersForField(Rec."New Waiter Pad Action", Rec.RecordId, Rec.FieldNo("New Waiter Pad Action"));
                    end;
                }
                field("Select Waiter Pad Action"; Rec."Select Waiter Pad Action")
                {
                    ToolTip = 'Specifies the code for the POS action that is used, when a waiter pad is selected on restaurant view.';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        ParamMgt.EditParametersForField(Rec."Select Waiter Pad Action", Rec.RecordId, Rec.FieldNo("Select Waiter Pad Action"));
                    end;
                }
                field("Set Waiter Pad Status Action"; Rec."Set Waiter Pad Status Action")
                {
                    ToolTip = 'Specifies the code for the POS action that is used, when waiter pad status is changed on restaurant view. Recommended value is "RV_SET_W/PAD_STATUS"';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        ParamMgt.EditParametersForField(Rec."Set Waiter Pad Status Action", Rec.RecordId, Rec.FieldNo("Set Waiter Pad Status Action"));
                    end;
                }
                field("Set Table Status Action"; Rec."Set Table Status Action")
                {
                    ToolTip = 'Specifies the code for the POS action that is used, when table status is changed on restaurant view. Recommended value is "RV_SET_TABLE_STATUS"';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        ParamMgt.EditParametersForField(Rec."Set Table Status Action", Rec.RecordId, Rec.FieldNo("Set Table Status Action"));
                    end;
                }
                field("Set Number of Guests Action"; Rec."Set Number of Guests Action")
                {
                    ToolTip = 'Specifies the code for the POS action that is used, when party size (number of guests) is changed for a waiter pad on restaurant view. Recommended value is "RV_SET_PARTYSIZE"';
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
                ToolTip = 'View or edit item print/production categories.';
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
                ToolTip = 'View restaurants created in the database.';
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
                    ToolTip = 'View kitchen stations created in the database.';
                    ApplicationArea = NPRRetail;
                }
                action(KitchenStationSelection)
                {
                    Caption = 'Station Selection Setup';
                    Image = Flow;
                    RunObject = Page "NPR NPRE Kitchen Station Slct.";
                    ToolTip = 'View or edit kitchen station selection setup. You can define which kitchen stations should be used to prepare products depending on item categories, serving steps etc.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(Processing)
        {
            group(InitialSetup)
            {
                Caption = 'Initial Setup';
                group("MS Entra OAuth")
                {
                    Caption = 'Microsoft Entra OAuth';
                    Image = XMLSetup;
                    Visible = HasAzureADConnection and ShowKDS;
                    action("Create MS Entra App")
                    {
                        Caption = 'Create Microsoft Entra App';
                        ToolTip = 'Running this action will create a Microsoft Entra Application and a accompaning client secret. You’ll need this if you want to use the NaviParter KDS display functionality.';
                        ApplicationArea = NPRRetail;
                        Image = Setup;

                        trigger OnAction()
                        var
                            SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
                        begin
                            SetupProxy.CreateAzureADApplication();
                        end;
                    }
                    action("Create MS Entra App Secret")
                    {
                        Caption = 'Create Microsoft Entra App Secret';
                        ToolTip = 'Running this action will create a client secret for an existing Microsoft Entra Application.';
                        ApplicationArea = NPRRetail;
                        Image = Setup;

                        trigger OnAction()
                        var
                            SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
                        begin
                            SetupProxy.CreateAzureADApplicationSecret();
                        end;
                    }
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
    begin
        if not Rec.Get() then
            Rec.Insert(true);

        ShowKDS := KitchenOrderMgt.KDSAvailable();
        HasAzureADConnection := AzureADTenant.GetAadTenantId() <> '';
    end;

    var
        ParamMgt: Codeunit "NPR POS Action Param. Mgt.";
        HasAzureADConnection: Boolean;
        ShowKDS: Boolean;
}
