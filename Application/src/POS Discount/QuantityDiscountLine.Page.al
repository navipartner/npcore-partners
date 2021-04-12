page 6014444 "NPR Quantity Discount Line"
{
    Caption = 'Multiple Unit Price';
    PageType = CardPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Quantity Discount Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Price field';
                }
                field(Total; Rec.Total)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Total field';
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

