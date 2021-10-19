#if not BC17
report 6014495 "NPR Whse. - Shipment"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/NP Whse. - ShipmentV18.rdl';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'Whse. - Shipment';
    DataAccessIntent = ReadOnly;

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
                    column(Barcode; BarCodeEncodedText)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        GetLocation("Location Code");

                        BarcodeSimbiology := BarcodeSimbiology::Code128;

                        BarCodeText := "Warehouse Shipment Line"."Source No.";
                        BarCodeEncodedText := BarcodeFontProviderMgt.EncodeText(BarCodeText, BarcodeSimbiology, BarcodeFontProviderMgt.SetBarcodeSettings(0, true, true, false));
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
        BarcodeFontProviderMgt: Codeunit "NPR Barcode Font Provider Mgt.";
        BarcodeSimbiology: Enum "Barcode Symbology";
        BarCodeText: Code[250];
        BarCodeEncodedText: Text;
        CurrReportPageNoCaptionLbl: Label 'Page';
        QtyPickedCaptionLbl: Label 'Qty. Picked';
        WarehouseShipmentCaptionLbl: Label 'Warehouse Shipment';

    local procedure GetLocation(LocationCode: Code[10])
    begin
        if LocationCode = '' then
            Location.Init()
        else
            if Location.Code <> LocationCode then
                Location.Get(LocationCode);
    end;
}


//  Purchased Font Name	Evaluation Font Name*	Font Height*	  N Dimension**
//  IDAutomationC128XXS	IDAutomationSC128XXS	 .10″ or .254 CM	  10
//  IDAutomationC128XS	IDAutomationSC128XS	     .20″ or .508 CM	  20
//  IDAutomationC128S	IDAutomationSC128S	     .35″ or .889 CM	  35
//  IDAutomationC128M	IDAutomationSC128M	     .50″ or 1.27 CM	  50
//  IDAutomationC128L	IDAutomationSC128L	     .60″ or 1.46 CM	  58
//  IDAutomationC128XL	IDAutomationSC128XL	     .75″ or 1.90 CM	  75
//  IDAutomationC128XXL	IDAutomationSC128XXL	   1″ or 2.54 CM	  100
#endif