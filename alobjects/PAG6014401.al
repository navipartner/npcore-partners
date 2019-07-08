page 6014401 "Debit sale info"
{
    // NPR5.39/TJ  /20180208 CASE 302634 Renamed functions to english

    Caption = 'Register/Debit Sale Information';
    SourceTable = "Sales Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                group(Control6150616)
                {
                    ShowCaption = false;
                    field("No.";"No.")
                    {
                        Editable = false;

                        trigger OnAssistEdit()
                        begin

                            if AssistEdit(xRec) then
                              CurrPage.Update;
                        end;
                    }
                    field("Sell-to Customer No.";"Sell-to Customer No.")
                    {
                    }
                    field("Sell-to Customer Name";"Sell-to Customer Name")
                    {
                    }
                    field("Sell-to Customer Name 2";"Sell-to Customer Name 2")
                    {
                    }
                    field("Sell-to Address";"Sell-to Address")
                    {
                    }
                    field("Sell-to Address 2";"Sell-to Address 2")
                    {
                    }
                    field("Sell-to Post Code";"Sell-to Post Code")
                    {
                    }
                    field("Sell-to City";"Sell-to City")
                    {
                    }
                    field("Sell-to Contact";"Sell-to Contact")
                    {
                    }
                    field("Your Reference";"Your Reference")
                    {
                    }
                }
                group(Control6150627)
                {
                    ShowCaption = false;
                    field("Posting Date";"Posting Date")
                    {
                    }
                    field("Document Date";"Document Date")
                    {
                    }
                    field("Salesperson Code";"Salesperson Code")
                    {
                        Editable = false;
                    }
                }
            }
            group(Invoice)
            {
                Caption = 'Invoice';
                group(Control6150633)
                {
                    ShowCaption = false;
                    field("Bill-to Customer No.";"Bill-to Customer No.")
                    {
                    }
                    field("Bill-to Name";"Bill-to Name")
                    {
                    }
                    field("Bill-to Name 2";"Bill-to Name 2")
                    {
                    }
                    field("Bill-to Address";"Bill-to Address")
                    {
                    }
                    field("Bill-to Address 2";"Bill-to Address 2")
                    {
                    }
                    field("Bill-to Post Code";"Bill-to Post Code")
                    {
                    }
                    field("Bill-to City";"Bill-to City")
                    {
                    }
                    field("Bill-to Contact";"Bill-to Contact")
                    {
                    }
                }
                group(Control6150642)
                {
                    ShowCaption = false;
                    field("Shortcut Dimension 1 Code";"Shortcut Dimension 1 Code")
                    {
                    }
                    field("Shortcut Dimension 2 Code";"Shortcut Dimension 2 Code")
                    {
                    }
                    field("Payment Terms Code";"Payment Terms Code")
                    {
                    }
                    field("Due Date";"Due Date")
                    {
                    }
                    field("Payment Discount %";"Payment Discount %")
                    {
                    }
                    field("Pmt. Discount Date";"Pmt. Discount Date")
                    {
                    }
                    field("Payment Method Code";"Payment Method Code")
                    {
                    }
                }
            }
            group(Delivery)
            {
                Caption = 'Delivery';
                group(Control6150652)
                {
                    ShowCaption = false;
                    field("Ship-to Code";"Ship-to Code")
                    {
                    }
                    field("Ship-to Name";"Ship-to Name")
                    {
                    }
                    field("Ship-to Name 2";"Ship-to Name 2")
                    {
                    }
                    field("Ship-to Address";"Ship-to Address")
                    {
                    }
                    field("Ship-to Address 2";"Ship-to Address 2")
                    {
                    }
                    field("Ship-to Post Code";"Ship-to Post Code")
                    {
                    }
                    field("Ship-to City";"Ship-to City")
                    {
                    }
                    field("Ship-to Contact";"Ship-to Contact")
                    {
                    }
                }
                group(Control6150662)
                {
                    ShowCaption = false;
                    field("Location Code";"Location Code")
                    {
                    }
                    field("Shipment Method Code";"Shipment Method Code")
                    {
                    }
                    field("Shipping Agent Code";"Shipping Agent Code")
                    {
                    }
                    field("Package Tracking No.";"Package Tracking No.")
                    {
                    }
                    field("Shipment Date";"Shipment Date")
                    {
                    }
                }
            }
        }
    }

    actions
    {
    }

    var
        Deb: Record Customer temporary;
        DebFak: Record Customer temporary;
        DebLev: Record Customer temporary;

    procedure SetCustomer(var Text: Text[30])
    begin
        "Your Reference" := Text;
    end;

    procedure GetCustomer(var Text: Text[30])
    begin
        Text := "Your Reference";
    end;
}

