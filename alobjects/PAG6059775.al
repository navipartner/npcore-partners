page 6059775 "Member Card Issued Cards"
{
    Caption = 'Point Card - Issued Cards';
    CardPageID = "Member Card Issued Card";
    Editable = false;
    PageType = List;
    SourceTable = "Member Card Issued Cards";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No.";"No.")
                {
                }
                field("Customer No";"Customer No")
                {
                }
                field("Customer Type";"Customer Type")
                {
                }
                field("Issue Date";"Issue Date")
                {
                }
                field("Card Type";"Card Type")
                {
                }
                field(Salesperson;Salesperson)
                {
                }
                field("Points (Total)";"Points (Total)")
                {
                }
                field(Status;Status)
                {
                }
                field(Name;Name)
                {
                }
                field(Address;Address)
                {
                }
                field("ZIP Code";"ZIP Code")
                {
                }
                field(City;City)
                {
                }
                field("Valid Until";"Valid Until")
                {
                }
                field(Reference;Reference)
                {
                }
                field("Canceling Salesperson";"Canceling Salesperson")
                {
                }
                field("Created in Company";"Created in Company")
                {
                }
                field("No. Printed";"No. Printed")
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    var
        PointCardTypes: Record "Member Card Types";
    begin

        PointCardTypes.Get("Card Type");
        SetFilter("Expiration Date Filter",'%1..%2',CalcDate(PointCardTypes."Expiration Calculation",Today),Today);
        CalcFields("Points (Total)");
    end;
}

