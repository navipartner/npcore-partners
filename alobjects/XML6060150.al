xmlport 6060150 "Event Import Optional Items"
{
    // NPR5.48/TJ  /20190124 CASE 263728 New object

    Caption = 'Event Import Optional Items';
    UseDefaultNamespace = true;

    schema
    {
        textelement(additionalitems)
        {
            tableelement("Job Planning Line";"Job Planning Line")
            {
                MinOccurs = Zero;
                XmlName = 'additionalitem';
                UseTemporary = true;
                fieldattribute(item_no;"Job Planning Line"."No.")
                {
                }
                fieldelement(description;"Job Planning Line".Description)
                {
                }
                fieldelement(quantity;"Job Planning Line".Quantity)
                {
                }
                fieldelement(unit_price;"Job Planning Line"."Unit Price")
                {
                }
                fieldelement(line_discount_pct;"Job Planning Line"."Line Discount %")
                {
                }

                trigger OnBeforeInsertRecord()
                begin
                    i += 1;
                    "Job Planning Line"."Line No." := i;
                end;
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    var
        i: Integer;

    procedure GetOptionalItems(var JobPlanningLine: Record "Job Planning Line")
    begin
        if "Job Planning Line".FindSet then
          repeat
            JobPlanningLine := "Job Planning Line";
            JobPlanningLine.Insert;
          until "Job Planning Line".Next = 0;
    end;
}

