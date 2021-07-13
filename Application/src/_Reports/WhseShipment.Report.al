#if BC17
report 6014495 "NPR Whse. - Shipment"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/NP Whse. - Shipment.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'Whse. - Shipment';
    dataset
    {
        dataitem("Warehouse Shipment Header"; "Warehouse Shipment Header")
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.";
            column(HeaderNo_WhseShptHeader; "No.")
            {
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                column(CompanyName; CompanyName)
                {
                }
                column(TodayFormatted; Format(Today, 0, 4))
                {
                }
                column(AssUid__WhseShptHeader; "Warehouse Shipment Header"."Assigned User ID")
                {
                    IncludeCaption = true;
                }
                column(HrdLocCode_WhseShptHeader; "Warehouse Shipment Header"."Location Code")
                {
                    IncludeCaption = true;
                }
                column(HeaderNo1_WhseShptHeader; "Warehouse Shipment Header"."No.")
                {
                    IncludeCaption = true;
                }
                column(Show1; not Location."Bin Mandatory")
                {
                }
                column(Show2; Location."Bin Mandatory")
                {
                }
                column(CurrReportPageNoCaption; CurrReportPageNoCaptionLbl)
                {
                }
                column(WarehouseShipmentCaption; WarehouseShipmentCaptionLbl)
                {
                }
                dataitem("Warehouse Shipment Line"; "Warehouse Shipment Line")
                {
                    DataItemLink = "No." = FIELD("No.");
                    DataItemLinkReference = "Warehouse Shipment Header";
                    DataItemTableView = SORTING("No.", "Source Document", "Source No.");
                    column(ShelfNo_WhseShptLine; "Shelf No.")
                    {
                        IncludeCaption = true;
                    }
                    column(ItemNo_WhseShptLine; "Item No.")
                    {
                        IncludeCaption = true;
                    }
                    column(Desc_WhseShptLine; Description)
                    {
                        IncludeCaption = true;
                    }
                    column(UomCode_WhseShptLine; "Unit of Measure Code")
                    {
                        IncludeCaption = true;
                    }
                    column(LocCode_WhseShptLine; "Location Code")
                    {
                        IncludeCaption = true;
                    }
                    column(Qty_WhseShptLine; Quantity)
                    {
                        IncludeCaption = true;
                    }
                    column(SourceNo_WhseShptLine; "Source No.")
                    {
                        IncludeCaption = true;
                    }
                    column(SourceDoc_WhseShptLine; "Source Document")
                    {
                        IncludeCaption = true;
                    }
                    column(ZoneCode_WhseShptLine; "Zone Code")
                    {
                        IncludeCaption = true;
                    }
                    column(BinCode_WhseShptLine; "Bin Code")
                    {
                        IncludeCaption = true;
                    }
                    column(QtyPicked_WhseShptLineCaption; QtyPickedCaptionLbl)
                    {
                    }
                    column(QtyPicked_WhseShptLine; "Qty. Picked")
                    {
                    }
                    column(Barcode; TempBlobBuffer."Buffer 1")
                    {
                    }

                    trigger OnAfterGetRecord()
                    var
                        Code128Lbl: Label 'CODE128', Locked = true;
                    begin
                        GetLocation("Location Code");

                        BarcodeLib.SetShowText(true);
                        BarcodeLib.SetAntiAliasing(false);
                        BarcodeLib.SetBarcodeType(Code128Lbl);
                        BarcodeLib.GenerateBarcode("Warehouse Shipment Line"."Source No.", TmpBarcode);
                        TmpBarcode.CreateInStream(InStr);
                        TmpBarcode.CreateOutStream(OuStr);
                        TempBlobBuffer.GetFromTempBlob(TmpBarcode, 1);
                    end;
                }
            }

            trigger OnAfterGetRecord()
            begin
                GetLocation("Location Code");
            end;
        }
    }

    var
        Location: Record Location;
        TempBlobBuffer: Record "NPR BLOB buffer" temporary;
        BarcodeLib: Codeunit "NPR Barcode Image Library";
        TmpBarcode: Codeunit "Temp Blob";
        InStr: InStream;
        CurrReportPageNoCaptionLbl: Label 'Page';
        QtyPickedCaptionLbl: Label 'Qty. Picked';
        WarehouseShipmentCaptionLbl: Label 'Warehouse Shipment';
        OuStr: OutStream;

    local procedure GetLocation(LocationCode: Code[10])
    begin
        if LocationCode = '' then
            Location.Init()
        else
            if Location.Code <> LocationCode then
                Location.Get(LocationCode);
    end;
}
#endif