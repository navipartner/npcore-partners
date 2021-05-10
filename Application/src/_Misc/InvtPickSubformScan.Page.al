page 6014461 "NPR Invt. Pick Subform Scan"
{
    Caption = 'Lines';
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Warehouse Activity Line";
    SourceTableView = WHERE("Activity Type" = CONST("Invt. Pick"));

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Action Type"; Rec."Action Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the action type.';
                }
                field("Source Document"; Rec."Source Document")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Source Document field';
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Source No. field';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Serial No. field';

                    trigger OnValidate()
                    begin
                        SerialNoOnAfterValidate();
                    end;
                }
                field("Serial No. Blocked"; Rec."Serial No. Blocked")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Serial No. Blocked field';
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Lot No. field';

                    trigger OnValidate()
                    begin
                        LotNoOnAfterValidate();
                    end;
                }
                field("Lot No. Blocked"; Rec."Lot No. Blocked")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Lot No. Blocked field';
                }
                field("Expiration Date"; Rec."Expiration Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Expiration Date field';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Location Code field';
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bin Code field';

                    trigger OnValidate()
                    begin
                        BinCodeOnAfterValidate();
                    end;
                }
                field("Shelf No."; Rec."Shelf No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Shelf No. field';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Qty. (Base)"; Rec."Qty. (Base)")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Qty. (Base) field';
                }
                field("Qty. to Handle"; Rec."Qty. to Handle")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Qty. to Handle field';

                    trigger OnValidate()
                    begin
                        QtytoHandleOnAfterValidate();
                    end;
                }
                field("Qty. Handled"; Rec."Qty. Handled")
                {
                    ApplicationArea = All;
                    Visible = true;
                    ToolTip = 'Specifies the value of the Qty. Handled field';
                }
                field("Qty. to Handle (Base)"; Rec."Qty. to Handle (Base)")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Qty. to Handle (Base) field';
                }
                field("Qty. Handled (Base)"; Rec."Qty. Handled (Base)")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Qty. Handled (Base) field';
                }
                field("Qty. Outstanding"; Rec."Qty. Outstanding")
                {
                    ApplicationArea = All;
                    Visible = true;
                    ToolTip = 'Specifies the value of the Qty. Outstanding field';
                }
                field("Qty. Outstanding (Base)"; Rec."Qty. Outstanding (Base)")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Qty. Outstanding (Base) field';
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Due Date field';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit of Measure Code field';
                }
                field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Qty. per Unit of Measure field';
                }
                field("Shipping Advice"; Rec."Shipping Advice")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Shipping Advice field';
                }
                field("Destination Type"; Rec."Destination Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Destination Type field';
                }
                field("Destination No."; Rec."Destination No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Destination No. field';
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Shipping Agent Code field';
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Shipping Agent Service Code field';
                }
                field("Shipment Method Code"; Rec."Shipment Method Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Shipment Method Code field';
                }
                field("Special Equipment Code"; Rec."Special Equipment Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Special Equipment Code field';
                }
                field("Assemble to Order"; Rec."Assemble to Order")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Assemble to Order field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("&Split Line")
                {
                    Caption = '&Split Line';
                    Image = Split;
                    ShortCutKey = 'Ctrl+F11';
                    ApplicationArea = All;
                    ToolTip = 'Executes the &Split Line action';

                    trigger OnAction()
                    var
                        WhseActivityHeader: Record "Warehouse Activity Header";
                        InventoryPickScan: Page "NPR Inventory Pick Scan";
                    begin
                        CallSplitLine();
                        WhseActivityHeader.Get(Rec."Activity Type", Rec."No.");
                    end;
                }
            }
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action("Source &Document Line")
                {
                    Caption = 'Source &Document Line';
                    Image = SourceDocLine;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Source &Document Line action';

                    trigger OnAction()
                    begin
                        ShowSourceLine();
                    end;
                }
                action("Bin Contents List")
                {
                    Caption = 'Bin Contents List';
                    Image = BinContent;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Bin Contents List action';

                    trigger OnAction()
                    begin
                        ShowBinContents();
                    end;
                }
                group("Item Availability by")
                {
                    Caption = 'Item Availability by';
                    Image = ItemAvailability;
                    action("NPR Event")
                    {
                        Caption = 'Event';
                        Image = "Event";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Event action';

                        trigger OnAction()
                        begin
                            Rec.ShowItemAvailabilityByEvent();
                        end;
                    }
                    action(Period)
                    {
                        Caption = 'Period';
                        Image = Period;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Period action';

                        trigger OnAction()
                        begin
                            Rec.ShowItemAvailabilityByPeriod();
                        end;
                    }
                    action("Variant")
                    {
                        Caption = 'Variant';
                        Image = ItemVariant;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Variant action';

                        trigger OnAction()
                        begin
                            Rec.ShowItemAvailabilityByVariant();
                        end;
                    }
                    action(Location)
                    {
                        AccessByPermission = TableData Location = R;
                        Caption = 'Location';
                        Image = Warehouse;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Location action';

                        trigger OnAction()
                        begin
                            Rec.ShowItemAvailabilityByLocation();
                        end;
                    }
                }
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    begin
        CurrPage.Update(false);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Activity Type" := xRec."Activity Type";
    end;

    var
        WMSMgt: Codeunit "WMS Management";

    local procedure ShowSourceLine()
    begin
        WMSMgt.ShowSourceDocLine(Rec."Source Type", Rec."Source Subtype", Rec."Source No.", Rec."Source Line No.", Rec."Source Subline No.");
    end;

    local procedure ShowBinContents()
    var
        BinContent: Record "Bin Content";
    begin
        BinContent.ShowBinContents(Rec."Location Code", Rec."Item No.", Rec."Variant Code", '')
    end;

    procedure AutofillQtyToHandle()
    var
        WhseActivLine: Record "Warehouse Activity Line";
    begin
        WhseActivLine.Copy(Rec);
        Rec.AutofillQtyToHandle(WhseActivLine);
    end;

    procedure DeleteQtyToHandle()
    var
        WhseActivLine: Record "Warehouse Activity Line";
    begin
        WhseActivLine.Copy(Rec);
        Rec.DeleteQtyToHandle(WhseActivLine);
    end;

    local procedure CallSplitLine()
    var
        WhseActivLine: Record "Warehouse Activity Line";
    begin
        WhseActivLine.Copy(Rec);
        Rec.SplitLine(WhseActivLine);
        CurrPage.Update(false);
    end;

    procedure PostPickYesNo()
    var
        WhseActivLine: Record "Warehouse Activity Line";
        WhseActivPostYesNo: Codeunit "Whse.-Act.-Post (Yes/No)";
    begin
        WhseActivLine.Copy(Rec);
        WhseActivPostYesNo.Run(WhseActivLine);
        CurrPage.Update(false);
    end;

    procedure PostAndPrint()
    var
        WhseActivLine: Record "Warehouse Activity Line";
        WhseActivPostYesNo: Codeunit "Whse.-Act.-Post (Yes/No)";
    begin
        WhseActivLine.Copy(Rec);
        WhseActivPostYesNo.PrintDocument(true);
        WhseActivPostYesNo.Run(WhseActivLine);
        CurrPage.Update(false);
    end;

    procedure UpdateForm()
    begin
        CurrPage.Update();
    end;

    local procedure SerialNoOnAfterValidate()
    var
        ExpDate: Date;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        EntriesExist: Boolean;
    begin
        if Rec."Serial No." <> '' then
            ExpDate := ItemTrackingMgt.ExistingExpirationDate(Rec."Item No.", Rec."Variant Code",
                Rec."Lot No.", Rec."Serial No.", false, EntriesExist);

        if ExpDate <> 0D then
            Rec."Expiration Date" := ExpDate;
    end;

    local procedure LotNoOnAfterValidate()
    var
        ExpDate: Date;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        EntriesExist: Boolean;
    begin
        if Rec."Lot No." <> '' then
            ExpDate := ItemTrackingMgt.ExistingExpirationDate(Rec."Item No.", Rec."Variant Code",
                Rec."Lot No.", Rec."Serial No.", false, EntriesExist);

        if ExpDate <> 0D then
            Rec."Expiration Date" := ExpDate;
    end;

    local procedure BinCodeOnAfterValidate()
    begin
        CurrPage.Update();
    end;

    local procedure QtytoHandleOnAfterValidate()
    begin
        CurrPage.SaveRecord();
    end;
}

