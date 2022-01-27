page 6014444 "NPR Quantity Discount Line"
{
    Extensible = False;
    Caption = 'Multiple Unit Price';
    PageType = CardPart;
    UsageCategory = Administration;

    SourceTable = "NPR Quantity Discount Line";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Quantity; Rec.Quantity)
                {

                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Price"; Rec."Unit Price")
                {

                    ToolTip = 'Specifies the value of the Unit Price field';
                    ApplicationArea = NPRRetail;
                }
                field(Total; Rec.Total)
                {

                    ToolTip = 'Specifies the value of the Total field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        Rec.CalcFields("Price Includes VAT");
    end;

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Price Includes VAT");
    end;

}

