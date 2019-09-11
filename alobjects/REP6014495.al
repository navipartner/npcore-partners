report 6014495 "NP Whse. - Shipment"
{
    // NPR5.51/ZESO/20190724 CASE 355486 Object Created
    DefaultLayout = RDLC;
    RDLCLayout = './NP Whse. - Shipment.rdlc';

    Caption = 'Whse. - Shipment';

    dataset
    {
        dataitem("Warehouse Shipment Header";"Warehouse Shipment Header")
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.";
            column(HeaderNo_WhseShptHeader;"No.")
            {
            }
            dataitem("Integer";"Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number=CONST(1));
                column(CompanyName;CompanyName)
                {
                }
                column(TodayFormatted;Format(Today,0,4))
                {
                }
                column(AssUid__WhseShptHeader;"Warehouse Shipment Header"."Assigned User ID")
                {
                    IncludeCaption = true;
                }
                column(HrdLocCode_WhseShptHeader;"Warehouse Shipment Header"."Location Code")
                {
                    IncludeCaption = true;
                }
                column(HeaderNo1_WhseShptHeader;"Warehouse Shipment Header"."No.")
                {
                    IncludeCaption = true;
                }
                column(Show1;not Location."Bin Mandatory")
                {
                }
                column(Show2;Location."Bin Mandatory")
                {
                }
                column(CurrReportPageNoCaption;CurrReportPageNoCaptionLbl)
                {
                }
                column(WarehouseShipmentCaption;WarehouseShipmentCaptionLbl)
                {
                }
                dataitem("Warehouse Shipment Line";"Warehouse Shipment Line")
                {
                    DataItemLink = "No."=FIELD("No.");
                    DataItemLinkReference = "Warehouse Shipment Header";
                    DataItemTableView = SORTING("No.","Source Document","Source No.");
                    column(ShelfNo_WhseShptLine;"Shelf No.")
                    {
                        IncludeCaption = true;
                    }
                    column(ItemNo_WhseShptLine;"Item No.")
                    {
                        IncludeCaption = true;
                    }
                    column(Desc_WhseShptLine;Description)
                    {
                        IncludeCaption = true;
                    }
                    column(UomCode_WhseShptLine;"Unit of Measure Code")
                    {
                        IncludeCaption = true;
                    }
                    column(LocCode_WhseShptLine;"Location Code")
                    {
                        IncludeCaption = true;
                    }
                    column(Qty_WhseShptLine;Quantity)
                    {
                        IncludeCaption = true;
                    }
                    column(SourceNo_WhseShptLine;"Source No.")
                    {
                        IncludeCaption = true;
                    }
                    column(SourceDoc_WhseShptLine;"Source Document")
                    {
                        IncludeCaption = true;
                    }
                    column(ZoneCode_WhseShptLine;"Zone Code")
                    {
                        IncludeCaption = true;
                    }
                    column(BinCode_WhseShptLine;"Bin Code")
                    {
                        IncludeCaption = true;
                    }
                    column(QtyPicked_WhseShptLineCaption;QtyPickedCaptionLbl)
                    {
                    }
                    column(QtyPicked_WhseShptLine;"Qty. Picked")
                    {
                    }
                    column(Barcode;TmpBarcode.Blob)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        GetLocation("Location Code");

                        //CALCFIELDS("Warehouse Shipment Line"."Source No.");
                        BarcodeLib.SetShowText(true);
                        BarcodeLib.SetAntiAliasing(false);
                        BarcodeLib.SetBarcodeType('CODE128');
                        BarcodeLib.GenerateBarcode("Warehouse Shipment Line"."Source No.",TmpBarcode);
                        TmpBarcode.Blob.CreateInStream(InStr);
                        TmpBarcode.Blob.CreateOutStream(OuStr);
                        GenerateBitmap(InStr,OuStr);
                    end;
                }
            }

            trigger OnAfterGetRecord()
            begin
                GetLocation("Location Code");
            end;
        }
    }

    requestpage
    {
        Caption = 'Whse. - Posted Shipment';

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        Location: Record Location;
        CurrReportPageNoCaptionLbl: Label 'Page';
        WarehouseShipmentCaptionLbl: Label 'Warehouse Shipment';
        BarcodeLib: Codeunit "Barcode Library";
        TmpBarcode: Record TempBlob;
        PictureFormat: DotNet npNetImageFormat;
        Bitmap: DotNet npNetBitmap;
        InStr: InStream;
        OuStr: OutStream;
        QtyPickedCaptionLbl: Label 'Qty. Picked';

    local procedure GetLocation(LocationCode: Code[10])
    begin
        if LocationCode = '' then
          Location.Init
        else
          if Location.Code <> LocationCode then
            Location.Get(LocationCode);
    end;

    local procedure GenerateBitmap(var SourceStream: InStream;var BitmapStream: OutStream)
    begin
        Bitmap := Bitmap.Bitmap(SourceStream);
        PictureFormat := PictureFormat.Png;
        Bitmap.Save(BitmapStream,PictureFormat);
    end;
}

