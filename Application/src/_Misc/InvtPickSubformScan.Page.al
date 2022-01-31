page 6014461 "NPR Invt. Pick Subform Scan"
{
    Extensible = False;
    Caption = 'Lines';
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Warehouse Activity Line";
    SourceTableView = WHERE("Activity Type" = CONST("Invt. Pick"));
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Action Type"; Rec."Action Type")
                {

                    Visible = false;
                    ToolTip = 'Specifies the action type.';
                    ApplicationArea = NPRRetail;
                }
                field("Source Document"; Rec."Source Document")
                {

                    BlankZero = true;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Source Document field';
                    ApplicationArea = NPRRetail;
                }
                field("Source No."; Rec."Source No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Source No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Item No."; Rec."Item No.")
                {

                    ToolTip = 'Specifies the value of the Item No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Serial No."; Rec."Serial No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Serial No. field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        SerialNoOnAfterValidate();
                    end;
                }
                field("Serial No. Blocked"; Rec."Serial No. Blocked")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Serial No. Blocked field';
                    ApplicationArea = NPRRetail;
                }
                field("Lot No."; Rec."Lot No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Lot No. field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        LotNoOnAfterValidate();
                    end;
                }
                field("Lot No. Blocked"; Rec."Lot No. Blocked")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Lot No. Blocked field';
                    ApplicationArea = NPRRetail;
                }
                field("Expiration Date"; Rec."Expiration Date")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Expiration Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Location Code"; Rec."Location Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Location Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Bin Code"; Rec."Bin Code")
                {

                    ToolTip = 'Specifies the value of the Bin Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        BinCodeOnAfterValidate();
                    end;
                }
                field("Shelf No."; Rec."Shelf No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Shelf No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {

                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Qty. (Base)"; Rec."Qty. (Base)")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Qty. (Base) field';
                    ApplicationArea = NPRRetail;
                }
                field("Qty. to Handle"; Rec."Qty. to Handle")
                {

                    ToolTip = 'Specifies the value of the Qty. to Handle field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        QtytoHandleOnAfterValidate();
                    end;
                }
                field("Qty. Handled"; Rec."Qty. Handled")
                {

                    Visible = true;
                    ToolTip = 'Specifies the value of the Qty. Handled field';
                    ApplicationArea = NPRRetail;
                }
                field("Qty. to Handle (Base)"; Rec."Qty. to Handle (Base)")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Qty. to Handle (Base) field';
                    ApplicationArea = NPRRetail;
                }
                field("Qty. Handled (Base)"; Rec."Qty. Handled (Base)")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Qty. Handled (Base) field';
                    ApplicationArea = NPRRetail;
                }
                field("Qty. Outstanding"; Rec."Qty. Outstanding")
                {

                    Visible = true;
                    ToolTip = 'Specifies the value of the Qty. Outstanding field';
                    ApplicationArea = NPRRetail;
                }
                field("Qty. Outstanding (Base)"; Rec."Qty. Outstanding (Base)")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Qty. Outstanding (Base) field';
                    ApplicationArea = NPRRetail;
                }
                field("Due Date"; Rec."Due Date")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Due Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {

                    ToolTip = 'Specifies the value of the Unit of Measure Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Qty. per Unit of Measure field';
                    ApplicationArea = NPRRetail;
                }
                field("Shipping Advice"; Rec."Shipping Advice")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Shipping Advice field';
                    ApplicationArea = NPRRetail;
                }
                field("Destination Type"; Rec."Destination Type")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Destination Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Destination No."; Rec."Destination No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Destination No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Shipping Agent Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Shipping Agent Service Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Shipment Method Code"; Rec."Shipment Method Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Shipment Method Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Special Equipment Code"; Rec."Special Equipment Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Special Equipment Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Assemble to Order"; Rec."Assemble to Order")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Assemble to Order field';
                    ApplicationArea = NPRRetail;
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

                    ToolTip = 'Executes the &Split Line action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        WhseActivityHeader: Record "Warehouse Activity Header";
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

                    ToolTip = 'Executes the Source &Document Line action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ShowSourceLine();
                    end;
                }
                action("Bin Contents List")
                {
                    Caption = 'Bin Contents List';
                    Image = BinContent;

                    ToolTip = 'Executes the Bin Contents List action';
                    ApplicationArea = NPRRetail;

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

                        ToolTip = 'Executes the Event action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        begin
                            Rec.ShowItemAvailabilityByEvent();
                        end;
                    }
                    action(Period)
                    {
                        Caption = 'Period';
                        Image = Period;

                        ToolTip = 'Executes the Period action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        begin
                            Rec.ShowItemAvailabilityByPeriod();
                        end;
                    }
                    action("Variant")
                    {
                        Caption = 'Variant';
                        Image = ItemVariant;

                        ToolTip = 'Executes the Variant action';
                        ApplicationArea = NPRRetail;

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

                        ToolTip = 'Executes the Location action';
                        ApplicationArea = NPRRetail;

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
#IF NOT BC17
        WhseItemTrackingSetup: Record "Item Tracking Setup";
#ENDIF
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        ExpDate: Date;
        EntriesExist: Boolean;
    begin
        if Rec."Serial No." <> '' then begin
#IF BC17
            ExpDate := ItemTrackingMgt.ExistingExpirationDate(Rec."Item No.", Rec."Variant Code",
                Rec."Lot No.", Rec."Serial No.", false, EntriesExist);
#ELSE
            ItemTrackingMgt.GetWhseItemTrkgSetup(Rec."Item No.", WhseItemTrackingSetup);
            ExpDate := ItemTrackingMgt.ExistingExpirationDate(Rec."Item No.", Rec."Variant Code",
                WhseItemTrackingSetup, false, EntriesExist);
#ENDIF
        end;

        if ExpDate <> 0D then
            Rec."Expiration Date" := ExpDate;
    end;

    local procedure LotNoOnAfterValidate()
    var
#IF NOT BC17
        WhseItemTrackingSetup: Record "Item Tracking Setup";
#ENDIF
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        ExpDate: Date;
        EntriesExist: Boolean;
    begin
        if Rec."Lot No." <> '' then begin
#IF BC17
            ExpDate := ItemTrackingMgt.ExistingExpirationDate(Rec."Item No.", Rec."Variant Code",
                Rec."Lot No.", Rec."Serial No.", false, EntriesExist);
#ELSE
            ItemTrackingMgt.GetWhseItemTrkgSetup(Rec."Item No.", WhseItemTrackingSetup);
            ExpDate := ItemTrackingMgt.ExistingExpirationDate(Rec."Item No.", Rec."Variant Code",
                WhseItemTrackingSetup, false, EntriesExist);
#ENDIF
        end;

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

