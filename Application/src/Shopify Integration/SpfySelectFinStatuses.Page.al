#if not BC17
page 6184956 "NPR Spfy Select Fin. Statuses"
{
    Extensible = False;
    Caption = 'Select Financial Statuses';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    SourceTable = "NPR Spfy Allowed Fin. Status";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Selected; Selected)
                {
                    Caption = 'Selected';
                    Editable = true;
                    ToolTip = 'Specifies if this line is selected.';
                    ApplicationArea = NPRShopify;

                    trigger OnValidate()
                    begin
                        Rec.Mark(Selected);
                    end;
                }
                field("Order Financial Status"; Rec."Order Financial Status")
                {
                    Editable = false;
                    ToolTip = 'Specifies the Shopify order financial status you want to allow.';
                    ApplicationArea = NPRShopify;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Selected := Rec.Mark();
    end;

    internal procedure SetDataset(var SpfyAllowedFinStatusIn: Record "NPR Spfy Allowed Fin. Status")
    begin
        Rec.Copy(SpfyAllowedFinStatusIn, true);
    end;

    internal procedure GetDataset(var SpfyAllowedFinStatusOut: Record "NPR Spfy Allowed Fin. Status")
    begin
        SpfyAllowedFinStatusOut.Copy(Rec, true);
    end;

    var
        Selected: Boolean;
}
#endif