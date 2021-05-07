report 6014408 "NPR Item Group Overview"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Item Group Overview.rdlc';
    Caption = 'Item Group Overview';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    dataset
    {
        dataitem("Item Category"; "Item Category")
        {
            DataItemTableView = SORTING("Code");
            RequestFilterFields = "Code", "NPR Main Category";
            column(PageNoCaptionLbl; PageNoCaptionLbl)
            {
            }
            column(Report_Caption; Report_Caption_Lbl)
            {
            }
            column(COMPANYNAME; CompanyName)
            {
            }
            column(Item_Group_No_; "Item Category"."Code")
            {
            }
            column(Item_Group_Description_; "Item Category".Description)
            {
                IncludeCaption = true;
            }
            column(Item_Group_Belongs_in_Main_Item_Group_; "Item Category"."NPR Main Category Code")
            {
            }
            column(Item_Group_VAT_Prod_Posting_Group_; VATProdPostingGroupCode)
            {
            }
            column(Item_Group_VAT_Bus_Posting_Group_; VATBusPostingGroupCode)
            {
            }
            column(Item_Group_Gen_Prod_Posting_Group_; GenProdPostingGroupCode)
            {
            }
            column(Item_Group_Inventory_Posting_Group_; InventoryPostingGroupCode)
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

            trigger OnAfterGetRecord()
            var
                TempItem: Record Item temporary;
                ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
            begin
                GenProdPostingGroupCode := '';

                if ItemCategoryMgt.ApplyTemplateToTempItem(TempItem, "Item Category") then begin
                    GenProdPostingGroupCode := TempItem."Gen. Prod. Posting Group";
                    VATProdPostingGroupCode := TempItem."VAT Prod. Posting Group";
                    VATBusPostingGroupCode := TempItem."VAT Bus. Posting Gr. (Price)";
                    InventoryPostingGroupCode := TempItem."Inventory Posting Group";
                end;
            end;
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
        GenProdPostingGroupCode: Code[20];
        VATProdPostingGroupCode: Code[20];
        VATBusPostingGroupCode: Code[20];
        InventoryPostingGroupCode: Code[20];
        DescriptionCaptionLbl: Label 'Description';
        ItemGroupCaptionLbl: Label 'Item Group';
        Report_Caption_Lbl: Label 'Item Group Overview';
        PageNoCaptionLbl: Label 'Page';
}

