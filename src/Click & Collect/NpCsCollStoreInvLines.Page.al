page 6151219 "NPR NpCs Coll. Store Inv.Lines"
{
    // NPR5.51/MHA /20190821  CASE 364557 Object created - Collect in Store
    // NPR5.53/MHA /20191106  CASE 376104 Replaced "No." with Text function GetNo() to increase column width a bit

    Caption = 'Lines';
    Editable = false;
    PageType = ListPart;
    SourceTable = "Sales Invoice Line";

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

    actions
    {
    }

    local procedure GetNo(): Text
    begin
        //-NPR5.53 [376104]
        exit("No.");
        //+NPR5.53 [376104]
    end;
}

