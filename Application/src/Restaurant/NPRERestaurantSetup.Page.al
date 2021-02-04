page 6150669 "NPR NPRE Restaurant Setup"
{
    Caption = 'Restaurant Setup';
    PageType = Card;
    SourceTable = "NPR NPRE Restaurant Setup";
    UsageCategory = Administration;
    ApplicationArea = All;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Waiter Pad No. Series"; Rec."Waiter Pad No. Serie")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Waiter Pad No. Serie field';
                }
                field("Default Service Flow Profile"; Rec."Default Service Flow Profile")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default Service Flow Profile field';
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
                        ApplicationArea = All;
                        Caption = 'Ready for New Guests';
                        ToolTip = 'Specifies the value of the Ready for New Guests field';
                    }
                    field("Seat.Status: Occupied"; Rec."Seat.Status: Occupied")
                    {
                        ApplicationArea = All;
                        Caption = 'Occupied';
                        ToolTip = 'Specifies the value of the Occupied field';
                    }
                    field("Seat.Status: Reserved"; Rec."Seat.Status: Reserved")
                    {
                        ApplicationArea = All;
                        Caption = 'Reserved';
                        ToolTip = 'Specifies the value of the Reserved field';
                    }
                    field("Seat.Status: Cleaning Required"; Rec."Seat.Status: Cleaning Required")
                    {
                        ApplicationArea = All;
                        Caption = 'Cleaning Required';
                        ToolTip = 'Specifies the value of the Cleaning Required field';
                    }
                }
            }
            group(KitchenInegration)
            {
                Caption = 'Kitchen Integration';
                field("Auto Send Kitchen Order"; Rec."Auto Send Kitchen Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auto Send Kitchen Order field';
                }
                field("Resend All On New Lines"; Rec."Resend All On New Lines")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Resend All On New Lines field';
                }
                field("Serving Step Discovery Method"; Rec."Serving Step Discovery Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Serving Step Discovery Method field';
                }
                group(Print)
                {
                    Caption = 'Print';
                    field("Kitchen Printing Active"; Rec."Kitchen Printing Active")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Kitchen Printing Active field';
                    }
                }
                group(KDS)
                {
                    Caption = 'KDS';
                    Visible = ShowKDS;
                    field("KDS Active"; Rec."KDS Active")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the KDS Active field';
                    }
                    field("Order ID Assign. Method"; Rec."Order ID Assign. Method")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Order ID Assign. Method field';
                    }
                }
            }
            group(POSActions)
            {
                Caption = 'POS Actions';

                field("Save Layout Action"; Rec."Save Layout Action")
                {
                    ApplicationArea = All;

                    trigger OnAssistEdit()
                    begin
                        ParamMgt.EditParametersForField(Rec."Save Layout Action", Rec.RecordId, Rec.FieldNo("Save Layout Action"));
                    end;
                }
                field("Select Restaurant Action"; Rec."Select Restaurant Action")
                {
                    ApplicationArea = All;

                    trigger OnAssistEdit()
                    begin
                        ParamMgt.EditParametersForField(Rec."Select Restaurant Action", Rec.RecordId, Rec.FieldNo("Select Restaurant Action"));
                    end;
                }
                field("Select Table Action"; Rec."Select Table Action")
                {
                    ApplicationArea = All;

                    trigger OnAssistEdit()
                    begin
                        ParamMgt.EditParametersForField(Rec."Select Table Action", Rec.RecordId, Rec.FieldNo("Select Table Action"));
                    end;
                }
                field("New Waiter Pad Action"; Rec."New Waiter Pad Action")
                {
                    ApplicationArea = All;

                    trigger OnAssistEdit()
                    begin
                        ParamMgt.EditParametersForField(Rec."New Waiter Pad Action", Rec.RecordId, Rec.FieldNo("New Waiter Pad Action"));
                    end;
                }
                field("Select Waiter Pad Action"; Rec."Select Waiter Pad Action")
                {
                    ApplicationArea = All;

                    trigger OnAssistEdit()
                    begin
                        ParamMgt.EditParametersForField(Rec."Select Waiter Pad Action", Rec.RecordId, Rec.FieldNo("Select Waiter Pad Action"));
                    end;
                }
                field("Set Waiter Pad Status Action"; Rec."Set Waiter Pad Status Action")
                {
                    ApplicationArea = All;

                    trigger OnAssistEdit()
                    begin
                        ParamMgt.EditParametersForField(Rec."Set Waiter Pad Status Action", Rec.RecordId, Rec.FieldNo("Set Waiter Pad Status Action"));
                    end;
                }
                field("Set Table Status Action"; Rec."Set Table Status Action")
                {
                    ApplicationArea = All;

                    trigger OnAssistEdit()
                    begin
                        ParamMgt.EditParametersForField(Rec."Set Table Status Action", Rec.RecordId, Rec.FieldNo("Set Table Status Action"));
                    end;
                }
                field("Set Number of Guests Action"; Rec."Set Number of Guests Action")
                {
                    ApplicationArea = All;

                    trigger OnAssistEdit()
                    begin
                        ParamMgt.EditParametersForField(Rec."Set Number of Guests Action", Rec.RecordId, Rec.FieldNo("Set Number of Guests Action"));
                    end;
                }
            }
            part(PrintTemplates; "NPR NPRE Print Templ. Subpage")
            {
                Caption = 'Print Templates';
                ApplicationArea = All;
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
                ApplicationArea = All;
                ToolTip = 'Executes the Print Categories action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Restaurants action';
            }
            group(Kitchen)
            {
                Caption = 'Kitchen';
                action(KitchenStations)
                {
                    Caption = 'Stations';
                    Image = Departments;
                    RunObject = Page "NPR NPRE Kitchen Stations";
                    RunPageLink = "Restaurant Code" = CONST('');
                    ApplicationArea = All;
                    ToolTip = 'Executes the Stations action';
                }
                action(KitchenStationSelection)
                {
                    Caption = 'Station Selection Setup';
                    Image = Troubleshoot;
                    RunObject = Page "NPR NPRE Kitchen Station Slct.";
                    RunPageLink = "Restaurant Code" = CONST('');
                    ApplicationArea = All;
                    ToolTip = 'Executes the Station Selection Setup action';
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