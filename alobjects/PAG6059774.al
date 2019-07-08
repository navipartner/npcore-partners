page 6059774 "Member Card Issued Card"
{
    // NPR5.41/TS  /20180105 CASE 300893 Removed Caption on ActionContainer

    Caption = 'Point Card - Issued Card';
    PageType = Card;
    SourceTable = "Member Card Issued Cards";

    layout
    {
        area(content)
        {
            grid(General)
            {
                group(Control6150615)
                {
                    ShowCaption = false;
                    field("No.";"No.")
                    {
                        Editable = false;
                    }
                    field("Customer No";"Customer No")
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
                    field(Status;Status)
                    {
                    }
                    field(Reference;Reference)
                    {
                    }
                }
                group(Control6150624)
                {
                    ShowCaption = false;
                    field("Valid Until";"Valid Until")
                    {
                        Caption = 'Valid Until';
                    }
                    field("Points (Total)";"Points (Total)")
                    {
                    }
                    field("Canceling Salesperson";"Canceling Salesperson")
                    {
                        Editable = false;
                    }
                    field("Created in Company";"Created in Company")
                    {
                        Editable = false;
                    }
                    field("Card Type";"Card Type")
                    {
                    }
                    field("Issue Date";"Issue Date")
                    {
                        Editable = false;
                    }
                    field(Salesperson;Salesperson)
                    {
                        Editable = false;
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(List)
            {
                Caption = 'List';
                Image = List;
                RunObject = Page "Member Card Issued Cards";
            }
        }
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

