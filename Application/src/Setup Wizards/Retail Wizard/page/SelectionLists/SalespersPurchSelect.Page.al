page 6059800 "NPR Salespers/PurchSelect"
{
    Caption = 'Salespeople';
    PageType = List;
    SourceTable = "Salesperson/Purchaser";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the code of the record.';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the name of the record.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    procedure GetSelectionFilter(): Text
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
    begin
        CurrPage.SetSelectionFilter(SalespersonPurchaser);
        exit(SelectionFilterManagement.GetSelectionFilterForSalesPersonPurchaser(SalespersonPurchaser));
    end;
}