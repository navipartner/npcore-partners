page 6014462 "Invt. Pick Subform Scan 2"
{
    // NPR5.33/NPKNAV/20170630  CASE 268412 Transport NPR5.33 - 30 June 2017

    Caption = 'Remaining Lines';
    Editable = false;
    LinksAllowed = false;
    PageType = ListPart;
    ShowFilter = false;
    SourceTable = "Warehouse Activity Line";
    SourceTableView = WHERE("Activity Type"=CONST("Invt. Pick"),
                            "Rem. Qty. to Pick (Base)"=FILTER(>0));

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Action Type";"Action Type")
                {
                    Visible = false;
                }
                field("Source Document";"Source Document")
                {
                    BlankZero = true;
                    OptionCaption = ' ,Sales Order,,,,,,,Purchase Return Order,,Outbound Transfer,Prod. Consumption';
                    Visible = false;
                }
                field("Source No.";"Source No.")
                {
                    Visible = false;
                }
                field("Item No.";"Item No.")
                {
                }
                field("Variant Code";"Variant Code")
                {
                    Visible = false;
                }
                field(Description;Description)
                {
                }
                field("Serial No.";"Serial No.")
                {
                    Visible = false;

                    trigger OnValidate()
                    begin
                        SerialNoOnAfterValidate;
                    end;
                }
                field("Serial No. Blocked";"Serial No. Blocked")
                {
                    Visible = false;
                }
                field("Lot No.";"Lot No.")
                {
                    Visible = false;

                    trigger OnValidate()
                    begin
                        LotNoOnAfterValidate;
                    end;
                }
                field("Lot No. Blocked";"Lot No. Blocked")
                {
                    Visible = false;
                }
                field("Expiration Date";"Expiration Date")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Location Code";"Location Code")
                {
                    Visible = false;
                }
                field("Bin Code";"Bin Code")
                {

                    trigger OnValidate()
                    begin
                        BinCodeOnAfterValidate;
                    end;
                }
                field("Shelf No.";"Shelf No.")
                {
                    Visible = false;
                }
                field(Quantity;Quantity)
                {
                }
                field("Qty. (Base)";"Qty. (Base)")
                {
                    Visible = false;
                }
                field("Qty. to Handle";"Qty. to Handle")
                {

                    trigger OnValidate()
                    begin
                        QtytoHandleOnAfterValidate;
                    end;
                }
                field("Qty. Handled";"Qty. Handled")
                {
                    Visible = true;
                }
                field("Qty. to Handle (Base)";"Qty. to Handle (Base)")
                {
                    Visible = false;
                }
                field("Qty. Handled (Base)";"Qty. Handled (Base)")
                {
                    Visible = false;
                }
                field("Qty. Outstanding";"Qty. Outstanding")
                {
                    Visible = true;
                }
                field("Qty. Outstanding (Base)";"Qty. Outstanding (Base)")
                {
                    Visible = false;
                }
                field("Due Date";"Due Date")
                {
                    Visible = false;
                }
                field("Unit of Measure Code";"Unit of Measure Code")
                {
                }
                field("Qty. per Unit of Measure";"Qty. per Unit of Measure")
                {
                    Visible = false;
                }
                field("Shipping Advice";"Shipping Advice")
                {
                    Visible = false;
                }
                field("Destination Type";"Destination Type")
                {
                    Visible = false;
                }
                field("Destination No.";"Destination No.")
                {
                    Visible = false;
                }
                field("Shipping Agent Code";"Shipping Agent Code")
                {
                    Visible = false;
                }
                field("Shipping Agent Service Code";"Shipping Agent Service Code")
                {
                    Visible = false;
                }
                field("Shipment Method Code";"Shipment Method Code")
                {
                    Visible = false;
                }
                field("Special Equipment Code";"Special Equipment Code")
                {
                    Visible = false;
                }
                field("Assemble to Order";"Assemble to Order")
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
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
        WMSMgt.ShowSourceDocLine("Source Type","Source Subtype","Source No.","Source Line No.","Source Subline No.");
    end;

    local procedure ShowBinContents()
    var
        BinContent: Record "Bin Content";
    begin
        BinContent.ShowBinContents("Location Code","Item No.","Variant Code",'')
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
          ExpDate := ItemTrackingMgt.ExistingExpirationDate("Item No.","Variant Code",
              "Lot No.","Serial No.",false,EntriesExist);

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
          ExpDate := ItemTrackingMgt.ExistingExpirationDate("Item No.","Variant Code",
              "Lot No.","Serial No.",false,EntriesExist);

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

