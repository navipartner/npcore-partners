pageextension 6014492 "NPR Customer List" extends "Customer List"
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
                ToolTip = 'This search is optimized to search relevant columns only. To serach enter a value in the Searh box and click on this field.';
                trigger OnValidate()
                var
                    Customer: Record Customer;
                    SmartSearch: Codeunit "NPR Smart Search";
                begin
                    Rec.Reset();
                    Rec.ClearMarks();
                    Rec.MarkedOnly(false);

                    if TableView <> '' then begin
                        Rec.SetView(TableView);
                        Customer.SetView(TableView);
                    end;

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

        addlast(Control1)
        {
            field("NPR E-Mail"; Rec."E-Mail")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the customer''s e-mail address. Clicking on the e-mail address opens an e-mail application.';
            }
            field("NPR Mobile Phone No."; Rec."Mobile Phone No.")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the customer''s mobile phone no.';
            }
        }

        modify(Control1)
        {
            Editable = false;
        }
    }

    trigger OnOpenPage()
    begin
        TableView := Rec.GetView(false);
    end;

    var
        _SearchTerm: Text[100];
        TableView: Text;
}
