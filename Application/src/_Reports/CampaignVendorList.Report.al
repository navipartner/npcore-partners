report 6014497 "NPR Campaign Vendor List"
{
    #IF NOT BC17 
    Extensible = False; 
    #ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Campaign Vendor List.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'Campaign Vendor List';
    PreviewMode = PrintLayout;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            MaxIteration = 1;
            column(CompanyInfoName; CompanyInfo.Name)
            {
            }
            column(CompanyInfoPicture; CompanyInfo.Picture)
            {
            }
            column(VendorNo; "No.")
            {
            }
            column(VendorName; Name)
            {
            }
            column(Inventory; Item.Inventory)
            {
            }
            column(Inventory_caption; Item.FieldCaption(Inventory))
            {
            }
            column(QuantitySold; Item."Sales (Qty.)")
            {
            }
            column(QuantitySold_caption; Item.FieldCaption("Sales (Qty.)"))
            {
            }
            dataitem("Period Discount Line"; "NPR Period Discount Line")
            {
                CalcFields = "Quantity Sold", Turnover;
                RequestFilterFields = "Vendor No.";
                column(PeriodLineItemNo; "Item No.")
                {
                    AutoFormatType = 1;
                }
                column(Code_PeriodDiscountLine; Code)
                {
                }
                column(PeriodLineDesc; Description)
                {
                    AutoFormatType = 1;
                }
                column(UnitCostPurchase_PeriodDiscountLine; "Unit Cost Purchase")
                {
                }
                column(VariantCode_PeriodDiscountLine; "Variant Code")
                {
                }
                column(PeriodLineUnitPrice; "Unit Price")
                {
                    AutoFormatType = 1;
                }
                column(PeriodLineCampaignUnitPrice; "Campaign Unit Price")
                {
                    AutoFormatType = 1;
                }
                column(QuantitySold_PeriodDiscountLine; "Quantity Sold")
                {
                }
                column(QuantitySold_PeriodDiscountLine_caption; FieldCaption("Quantity Sold"))
                {
                }
                dataitem("Retail Comment"; "NPR Retail Comment")
                {
                    DataItemLink = "No." = FIELD(Code), "No. 2" = FIELD("Item No.");
                    DataItemTableView = SORTING("Table ID", "No.", "No. 2", Option, "Option 2", Integer, "Integer 2", "Line No.") WHERE("Table ID" = CONST(6014414));
                    column(TableID_RetailComment; "Retail Comment"."Table ID")
                    {
                    }
                    column(No_RetailComment; "Retail Comment"."No.")
                    {
                    }
                    column(No2_RetailComment; "Retail Comment"."No. 2")
                    {
                    }
                    column(Comment_RetailComment; "Retail Comment".Comment)
                    {
                    }
                    column(Date_RetailComment; "Retail Comment".Date)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if "Retail Comment"."Hide on printout" then
                            CurrReport.Skip();
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    Clear(Vendor1);
                    if Vendor1.Get("Vendor No.") then;

                    Item.Get("Period Discount Line"."Item No.");
                    Item.SetFilter("Variant Filter", "Period Discount Line"."Variant Code");
                    Item.SetFilter("Location Filter", LocationFilter);
                    Item.CalcFields(Inventory, "Sales (Qty.)");
                end;

                trigger OnPreDataItem()
                begin
                    if VendorFilter <> '' then
                        "Period Discount Line".SetFilter("Vendor No.", VendorFilter);
                end;
            }
            dataitem("Mixed Discount Line"; "NPR Mixed Discount Line")
            {
                DataItemTableView = WHERE("Disc. Grouping Type" = FILTER(Item));
                column(No_MixedDiscountLine; "No.")
                {
                }
                column(Code_MixedDiscountLine; Code)
                {
                }
                column(Unitcost_MixedDiscountLine; "Unit cost")
                {
                }
                column(Unitprice_MixedDiscountLine; "Unit price")
                {
                }
                column(UnitpriceinclVAT_MixedDiscountLine; "Unit price incl. VAT")
                {
                }
                column(VariantCode_MixedDiscountLine; "Variant Code")
                {
                }
                column(Description_MixedDiscountLine; Description)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    Clear(Vendor1);
                    if Vendor1.Get("Vendor No.") then;

                    Item.Get("Mixed Discount Line"."No.");
                    Item.SetFilter("Variant Filter", "Period Discount Line"."Variant Code");
                    Item.SetFilter("Location Filter", LocationFilter);
                    Item.CalcFields(Inventory, "Sales (Qty.)");
                end;

                trigger OnPreDataItem()
                begin
                    if VendorFilter <> '' then
                        "Mixed Discount Line".SetFilter("Vendor No.", VendorFilter);
                end;
            }

            trigger OnPreDataItem()
            begin
                VendorFilter := GetFilter("No.");
            end;
        }
    }

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(content)
            {
                field("Location Filter"; LocationFilter)
                {
                    Caption = 'Location Filter';
                    TableRelation = Location.Code;

                    ToolTip = 'Specifies the value of the Location Filter field';
                    ApplicationArea = NPRRetail;
                }
                field("Dimension 1 Filter"; Dimension1Filter)
                {
                    CaptionClass = '1,3,1';
                    Caption = 'Dimension Filter';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

                    ToolTip = 'Specifies the value of the Dimension Filter field';
                    ApplicationArea = NPRRetail;
                }
            }
        }

    }

    labels
    {
        Report_Lbl = 'Campaign Vendor List';
        Page_Lbl = 'Page';
        ItemNo_Lbl = 'No.';
        ItemDescription_Lbl = 'Description';
        ItemCost_Lbl = 'Cost';
        UnitPrice_Lbl = 'Unit Price';
        CampainUnitPrice_Lbl = 'Period price incl. tax';
        QuantitySold_Lbl = 'Sales in pieces';
        Vendor_LBL = 'Vendor:';
        Campaign_Lbl = 'Campaign Discount';
        MixLbl = 'Mix Discount';
        Variant_Lbl = 'Variant Code';
        Comment_Lbl = '-';
    }

    trigger OnInitReport()
    begin
        CompanyInfo.Get();
    end;

    var
        CompanyInfo: Record "Company Information";
        Item: Record Item;
        Vendor1: Record Vendor;
        VendorFilter: Text;
        Dimension1Filter: Text[200];
        LocationFilter: Text[200];
}

