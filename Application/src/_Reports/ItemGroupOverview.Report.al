report 6014408 "NPR Item Group Overview"
{
DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Item Group Overview.rdlc';
    Caption = 'Item Group Overview';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    dataset
    {
        dataitem("Item Group"; "NPR Item Group")
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Main Item Group";
            column(PageNoCaptionLbl; PageNoCaptionLbl)
            {
            }
            column(Report_Caption; Report_Caption_Lbl)
            {
            }
            column(COMPANYNAME; CompanyName)
            {
            }
            column(Item_Group_No_; "Item Group"."No.")
            {
            }
            column(Item_Group_Description_; "Item Group".Description)
            {
                IncludeCaption = true;
            }
            column(Item_Group_Belongs_in_Main_Item_Group_; "Item Group"."Belongs In Main Item Group")
            {
            }
            column(Item_Group_VAT_Prod_Posting_Group_; "Item Group"."VAT Prod. Posting Group")
            {
            }
            column(Item_Group_VAT_Bus_Posting_Group_; "Item Group"."VAT Bus. Posting Group")
            {
            }
            column(Item_Group_Gen_Bus_Posting_Group_; "Item Group"."Gen. Bus. Posting Group")
            {
            }
            column(Item_Group_Gen_Prod_Posting_Group_; "Item Group"."Gen. Prod. Posting Group")
            {
            }
            column(Item_Group_Inventory_Posting_Group_; "Item Group"."Inventory Posting Group")
            {
            }
            column(ItemGroupCaption; ItemGroupCaptionLbl)
            {
            }
            column(DescriptionCaption; DescriptionCaptionLbl)
            {
            }
            column(Picture_CompanyInformation; CompanyInformation.Picture)
            {
            }
        }
    }

    labels
    {
        BelongInMainItemGrp_Caption = 'Belongs in Main Item Group';
        VATProdPostingGrp_Caption = 'VAT Prod. Posting Group';
        VATBusPostingGrp_Caption = 'VAT Bus. Posting Group';
        GenBusPostingGrp_Caption = 'Gen. Bus. Posting Group';
        GenProdPostingGrp_Caption = 'Gen. Prod. Posting Group';
        InventoryPostingGrp_Caption = 'Inventory Posting Group';
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture);
    end;
    var
        CompanyInformation: Record "Company Information";
        DescriptionCaptionLbl: Label 'Description';
        ItemGroupCaptionLbl: Label 'Item Group';
        Report_Caption_Lbl: Label 'Item Group Overview';
        PageNoCaptionLbl: Label 'Page';
}

