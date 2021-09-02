pageextension 6014492 "NPR Customer List" extends "Customer List"
{
    Editable = true;

    layout
    {
        addfirst(content)
        {
            field("NPR Search"; _TurboSearch)
            {
                Editable = true;
                Caption = 'Fast Search';
                ApplicationArea = NPRRetail;
                ToolTip = 'This search is optimized to search relevant columns only.';
                trigger OnValidate()
                var
                    Customer: Record Customer;
                begin
                    Rec.Reset();
                    Rec.ClearMarks();
                    Rec.MarkedOnly(false);
                    if (_TurboSearch = '') then begin
                        CurrPage.Update(false);
                        exit;
                    end;

                    Customer.FilterGroup := -1;
                    Customer.SetFilter("No.", '%1', UpperCase(_TurboSearch));
                    Customer.SetFilter("Name", '%1', _TurboSearch);
                    Customer.SetFilter("Address", '%1', _TurboSearch);
                    Customer.SetFilter("Contact", '%1', _TurboSearch);
                    Customer.SetFilter("Phone No.", '%1', _TurboSearch);
                    Customer.SetFilter("E-Mail", '%1', LowerCase(ConvertStr(_TurboSearch, '@', '?')));
                    Customer.SetFilter("Search Name", '%1', _TurboSearch);
                    Customer.SetFilter("VAT Registration No.", '%1', _TurboSearch);
                    Customer.FilterGroup := 0;

                    Customer.SetLoadFields("No.");
                    if (Customer.FindSet()) then
                        repeat
                            Customer.Mark(true);
                        until (Customer.Next() = 0);

                    Rec.Copy(Customer);
                    Rec.SetLoadFields();
                    Rec.MarkedOnly(true);
                    CurrPage.Update(false);
                end;
            }
        }

        addlast(Control1)
        {
            field("NPR E-Mail"; Rec."E-Mail")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies Email.';
            }
        }

        modify(Control1)
        {
            Editable = false;
        }
    }

    var
        _TurboSearch: Text[100];
}
