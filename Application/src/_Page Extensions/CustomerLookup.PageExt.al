pageextension 6014493 "NPR Customer Lookup" extends "Customer Lookup"
{
    Editable = true;

    layout
    {
        addfirst(content)
        {
            field("NPR Search"; _SearchTerm)
            {
                Editable = true;
                Caption = 'Smart Search';
                ApplicationArea = NPRRetail;
                ToolTip = 'This search is optimized to search relevant columns only.';
                trigger OnValidate()
                var
                    Customer: Record Customer;
                    SmartSearch: Codeunit "NPR Smart Search";
                begin
                    Rec.Reset();
                    Rec.ClearMarks();
                    Rec.MarkedOnly(false);
                    if (_SearchTerm = '') then begin
                        CurrPage.Update(false);
                        exit;
                    end;

                    SmartSearch.SearchCustomer(_SearchTerm, Customer);

                    Rec.Copy(Customer);
                    Rec.SetLoadFields();
                    Rec.MarkedOnly(true);
                    CurrPage.Update(false);
                end;
            }
        }

        addlast(Group)
        {
            field("NPR E-Mail"; Rec."E-Mail")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies Email.';
            }
        }

        modify(Group)
        {
            Editable = false;
        }
    }

    var
        _SearchTerm: Text[100];
}
