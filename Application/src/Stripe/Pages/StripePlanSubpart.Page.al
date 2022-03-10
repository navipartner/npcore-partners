page 6059854 "NPR Stripe Plan Subpart"
{
    Caption = 'Plans';
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "NPR Stripe Plan";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(StripePlans)
            {
                field(Select; Rec.Select)
                {
                    ApplicationArea = NPRRetail;
                    ShowCaption = false;
                    ToolTip = 'Specifies the selected plan.';
                    Width = 2;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                        if Rec.Select then begin
                            Rec.SetRange(Select, true);
                            Rec.SetFilter(Id, '<>%1', Rec.Id);
                            if Rec.FindFirst() then begin
                                Rec.Select := false;
                                Rec.Modify();
                            end;
                            Rec.SetRange(Id);
                            Rec.FindFirst();
                            Rec.SetRange(Select);
                        end;
                    end;
                }
                field("Product Name"; Rec."Product Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the product name.';
                    Width = 10;
                }
                field("Unit Name"; Rec."Unit Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the unit name.';
                    Width = 6;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the price currency.';
                    Width = 8;
                }
                field(Amount; Rec.Amount / 100)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Starting Unit Price';
                    DecimalPlaces = 2 : 2;
                    Editable = false;
                    ToolTip = 'Specifies the starting price of the product per unit.';
                    Width = 10;
                }
                field(Interval; Rec.Interval)
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the billing period of the product.';
                    Width = 8;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetPlans();
        Rec.SetRange(Active, true);
    end;

    internal procedure HasSelectedPlan() ReturnValue: Boolean
    begin
        Rec.SetRange(Select, true);
        ReturnValue := not Rec.IsEmpty();
        Rec.SetRange(Select);
    end;

    internal procedure GetSelectedPlan(var StripePlan: Record "NPR Stripe Plan")
    begin
        Rec.SetRange(Select, true);
        Rec.FindFirst();
        StripePlan := Rec;
    end;
}