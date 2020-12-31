page 6151207 "NPR NpCs Coll. StoreOrderLines"
{
    Caption = 'Lines';
    Editable = false;
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "Sales Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("GetNo()"; GetNo())
                {
                    ApplicationArea = All;
                    Caption = 'No.';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure"; "Unit of Measure")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                }
                field("Line Amount"; "Line Amount")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    local procedure GetNo(): Text
    begin
        exit("No.");
    end;
}

