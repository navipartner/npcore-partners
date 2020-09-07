page 6014461 "NPR Invt. Pick Subform Scan"
{
    // NPR5.33/NPKNAV/20170630  CASE 268412 Transport NPR5.33 - 30 June 2017

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
                field("Action Type"; "Action Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Source Document"; "Source Document")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    OptionCaption = ' ,Sales Order,,,,,,,Purchase Return Order,,Outbound Transfer,Prod. Consumption';
                    Visible = false;
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Serial No."; "Serial No.")
                {
                    ApplicationArea = All;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        SerialNoOnAfterValidate;
                    end;
                }
                field("Serial No. Blocked"; "Serial No. Blocked")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = All;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        LotNoOnAfterValidate;
                    end;
                }
                field("Lot No. Blocked"; "Lot No. Blocked")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Expiration Date"; "Expiration Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Bin Code"; "Bin Code")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        BinCodeOnAfterValidate;
                    end;
                }
                field("Shelf No."; "Shelf No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Qty. (Base)"; "Qty. (Base)")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Qty. to Handle"; "Qty. to Handle")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        QtytoHandleOnAfterValidate;
                    end;
                }
                field("Qty. Handled"; "Qty. Handled")
                {
                    ApplicationArea = All;
                    Visible = true;
                }
                field("Qty. to Handle (Base)"; "Qty. to Handle (Base)")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Qty. Handled (Base)"; "Qty. Handled (Base)")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Qty. Outstanding"; "Qty. Outstanding")
                {
                    ApplicationArea = All;
                    Visible = true;
                }
                field("Qty. Outstanding (Base)"; "Qty. Outstanding (Base)")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Qty. per Unit of Measure"; "Qty. per Unit of Measure")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Shipping Advice"; "Shipping Advice")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Destination Type"; "Destination Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Destination No."; "Destination No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Shipping Agent Code"; "Shipping Agent Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Shipping Agent Service Code"; "Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Shipment Method Code"; "Shipment Method Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Special Equipment Code"; "Special Equipment Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Assemble to Order"; "Assemble to Order")
                {
                    ApplicationArea = All;
                    Visible = false;
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
                    ApplicationArea=All;

                    trigger OnAction()
                    var
                        WhseActivityHeader: Record "Warehouse Activity Header";
                        InventoryPickScan: Page "NPR Inventory Pick Scan";
                    begin
                        CallSplitLine;
                        WhseActivityHeader.Get(Rec."Activity Type", Rec."No.");
                        InventoryPickScan.UpdateRemQtyToPick(WhseActivityHeader);
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
                    ApplicationArea=All;

                    trigger OnAction()
                    begin
                        ShowSourceLine;
                    end;
                }
                action("Bin Contents List")
                {
                    Caption = 'Bin Contents List';
                    Image = BinContent;
                    ApplicationArea=All;

                    trigger OnAction()
                    begin
                        ShowBinContents;
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
                        ApplicationArea=All;

                        trigger OnAction()
                        begin
                            ShowItemAvailabilityByEvent;
                        end;
                    }
                    action(Period)
                    {
                        Caption = 'Period';
                        Image = Period;
                        ApplicationArea=All;

                        trigger OnAction()
                        begin
                            ShowItemAvailabilityByPeriod;
                        end;
                    }
                    action("Variant")
                    {
                        Caption = 'Variant';
                        Image = ItemVariant;
                        ApplicationArea=All;

                        trigger OnAction()
                        begin
                            ShowItemAvailabilityByVariant;
                        end;
                    }
                    action(Location)
                    {
                        AccessByPermission = TableData Location = R;
                        Caption = 'Location';
                        Image = Warehouse;
                        ApplicationArea=All;

                        trigger OnAction()
                        begin
                            ShowItemAvailabilityByLocation;
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
        "Activity Type" := xRec."Activity Type";
    end;

    var
        WMSMgt: Codeunit "WMS Management";

    local procedure ShowSourceLine()
    begin
        WMSMgt.ShowSourceDocLine("Source Type", "Source Subtype", "Source No.", "Source Line No.", "Source Subline No.");
    end;

    local procedure ShowBinContents()
    var
        BinContent: Record "Bin Content";
    begin
        BinContent.ShowBinContents("Location Code", "Item No.", "Variant Code", '')
    end;

    procedure AutofillQtyToHandle()
    var
        WhseActivLine: Record "Warehouse Activity Line";
    begin
        WhseActivLine.Copy(Rec);
        AutofillQtyToHandle(WhseActivLine);
    end;

    procedure DeleteQtyToHandle()
    var
        WhseActivLine: Record "Warehouse Activity Line";
    begin
        WhseActivLine.Copy(Rec);
        DeleteQtyToHandle(WhseActivLine);
    end;

    local procedure CallSplitLine()
    var
        WhseActivLine: Record "Warehouse Activity Line";
    begin
        WhseActivLine.Copy(Rec);
        SplitLine(WhseActivLine);
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
        CurrPage.Update;
    end;

    local procedure SerialNoOnAfterValidate()
    var
        ExpDate: Date;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        EntriesExist: Boolean;
    begin
        if "Serial No." <> '' then
            ExpDate := ItemTrackingMgt.ExistingExpirationDate("Item No.", "Variant Code",
                "Lot No.", "Serial No.", false, EntriesExist);

        if ExpDate <> 0D then
            "Expiration Date" := ExpDate;
    end;

    local procedure LotNoOnAfterValidate()
    var
        ExpDate: Date;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        EntriesExist: Boolean;
    begin
        if "Lot No." <> '' then
            ExpDate := ItemTrackingMgt.ExistingExpirationDate("Item No.", "Variant Code",
                "Lot No.", "Serial No.", false, EntriesExist);

        if ExpDate <> 0D then
            "Expiration Date" := ExpDate;
    end;

    local procedure BinCodeOnAfterValidate()
    begin
        CurrPage.Update;
    end;

    local procedure QtytoHandleOnAfterValidate()
    begin
        CurrPage.SaveRecord;
    end;
}

