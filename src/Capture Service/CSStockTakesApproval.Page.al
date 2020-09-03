page 6151388 "NPR CS Stock-Takes Approval"
{
    // NPR5.50/JAKUBV/20190603  CASE 332844 Transport NPR5.50 - 3 June 2019
    // NPR5.51/CLVA/20190902 CASE 365659 Added captions

    Caption = 'CS Stock-Takes Approval';
    SourceTable = "Integer";

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field("CSRefillItems.Item_Group_Code"; CSRefillItems.Item_Group_Code)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                }
                field("CSRefillItems.Item_No"; CSRefillItems.Item_No)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                }
                field("CSRefillItems.Item_Description"; CSRefillItems.Item_Description)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                }
                field("CSRefillItems.Variant_Code"; CSRefillItems.Variant_Code)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                }
                field("CSRefillItems.Variant_Description"; CSRefillItems.Variant_Description)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                }
                field("CSRefillItems.Qty_in_Stock"; CSRefillItems.Qty_in_Stock)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                }
                field("CSRefillItems.Qty_in_Store"; CSRefillItems.Qty_in_Store)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        if not CSRefillItems.Read then
            exit;
    end;

    trigger OnOpenPage()
    begin
        CSRefillItems.Open;
    end;

    var
        CSRefillItems: Query "NPR CS Refill Items";
        NumberOfRows: Integer;
}

