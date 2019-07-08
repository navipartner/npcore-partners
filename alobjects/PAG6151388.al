page 6151388 "CS Stock-Takes Approval"
{
    // NPR5.50/JAKUBV/20190603  CASE 332844 Transport NPR5.50 - 3 June 2019

    SourceTable = "Integer";

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field("CSRefillItems.Item_Group_Code";CSRefillItems.Item_Group_Code)
                {
                    ShowCaption = false;
                }
                field("CSRefillItems.Item_No";CSRefillItems.Item_No)
                {
                    ShowCaption = false;
                }
                field("CSRefillItems.Item_Description";CSRefillItems.Item_Description)
                {
                    ShowCaption = false;
                }
                field("CSRefillItems.Variant_Code";CSRefillItems.Variant_Code)
                {
                    ShowCaption = false;
                }
                field("CSRefillItems.Variant_Description";CSRefillItems.Variant_Description)
                {
                    ShowCaption = false;
                }
                field("CSRefillItems.Qty_in_Stock";CSRefillItems.Qty_in_Stock)
                {
                    ShowCaption = false;
                }
                field("CSRefillItems.Qty_in_Store";CSRefillItems.Qty_in_Store)
                {
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
        CSRefillItems: Query "CS Refill Items";
        NumberOfRows: Integer;
}

