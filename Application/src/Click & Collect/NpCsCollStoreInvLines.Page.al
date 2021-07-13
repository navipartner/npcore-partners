page 6151219 "NPR NpCs Coll. Store Inv.Lines"
{
    Caption = 'Lines';
    Editable = false;
    PageType = ListPart;
    UsageCategory = Administration;

    SourceTable = "Sales Invoice Line";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("No."; GetNo())
                {

                    Caption = 'No.';
                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Description 2"; Rec."Description 2")
                {

                    ToolTip = 'Specifies the value of the Description 2 field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Unit of Measure field';
                    ApplicationArea = NPRRetail;
                }
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
                field("Line Amount"; Rec."Line Amount")
                {

                    ToolTip = 'Specifies the value of the Line Amount field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    local procedure GetNo(): Text
    begin
        exit(Rec."No.");
    end;
}

