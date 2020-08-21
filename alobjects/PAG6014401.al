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
                    field("No."; "No.")
                    {
                        ApplicationArea = All;
                        Editable = false;

                        trigger OnAssistEdit()
                        begin

                            if AssistEdit(xRec) then
                                CurrPage.Update;
                        end;
                    }
                    field("Sell-to Customer No."; "Sell-to Customer No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Sell-to Customer Name"; "Sell-to Customer Name")
                    {
                        ApplicationArea = All;
                    }
                    field("Sell-to Customer Name 2"; "Sell-to Customer Name 2")
                    {
                        ApplicationArea = All;
                    }
                    field("Sell-to Address"; "Sell-to Address")
                    {
                        ApplicationArea = All;
                    }
                    field("Sell-to Address 2"; "Sell-to Address 2")
                    {
                        ApplicationArea = All;
                    }
                    field("Sell-to Post Code"; "Sell-to Post Code")
                    {
                        ApplicationArea = All;
                    }
                    field("Sell-to City"; "Sell-to City")
                    {
                        ApplicationArea = All;
                    }
                    field("Sell-to Contact"; "Sell-to Contact")
                    {
                        ApplicationArea = All;
                    }
                    field("Your Reference"; "Your Reference")
                    {
                        ApplicationArea = All;
                    }
                }
                group(Control6150627)
                {
                    ShowCaption = false;
                    field("Posting Date"; "Posting Date")
                    {
                        ApplicationArea = All;
                    }
                    field("Document Date"; "Document Date")
                    {
                        ApplicationArea = All;
                    }
                    field("Salesperson Code"; "Salesperson Code")
                    {
                        ApplicationArea = All;
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
                    field("Bill-to Customer No."; "Bill-to Customer No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Bill-to Name"; "Bill-to Name")
                    {
                        ApplicationArea = All;
                    }
                    field("Bill-to Name 2"; "Bill-to Name 2")
                    {
                        ApplicationArea = All;
                    }
                    field("Bill-to Address"; "Bill-to Address")
                    {
                        ApplicationArea = All;
                    }
                    field("Bill-to Address 2"; "Bill-to Address 2")
                    {
                        ApplicationArea = All;
                    }
                    field("Bill-to Post Code"; "Bill-to Post Code")
                    {
                        ApplicationArea = All;
                    }
                    field("Bill-to City"; "Bill-to City")
                    {
                        ApplicationArea = All;
                    }
                    field("Bill-to Contact"; "Bill-to Contact")
                    {
                        ApplicationArea = All;
                    }
                }
                group(Control6150642)
                {
                    ShowCaption = false;
                    field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                    {
                        ApplicationArea = All;
                    }
                    field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                    {
                        ApplicationArea = All;
                    }
                    field("Payment Terms Code"; "Payment Terms Code")
                    {
                        ApplicationArea = All;
                    }
                    field("Due Date"; "Due Date")
                    {
                        ApplicationArea = All;
                    }
                    field("Payment Discount %"; "Payment Discount %")
                    {
                        ApplicationArea = All;
                    }
                    field("Pmt. Discount Date"; "Pmt. Discount Date")
                    {
                        ApplicationArea = All;
                    }
                    field("Payment Method Code"; "Payment Method Code")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group(Delivery)
            {
                Caption = 'Delivery';
                group(Control6150652)
                {
                    ShowCaption = false;
                    field("Ship-to Code"; "Ship-to Code")
                    {
                        ApplicationArea = All;
                    }
                    field("Ship-to Name"; "Ship-to Name")
                    {
                        ApplicationArea = All;
                    }
                    field("Ship-to Name 2"; "Ship-to Name 2")
                    {
                        ApplicationArea = All;
                    }
                    field("Ship-to Address"; "Ship-to Address")
                    {
                        ApplicationArea = All;
                    }
                    field("Ship-to Address 2"; "Ship-to Address 2")
                    {
                        ApplicationArea = All;
                    }
                    field("Ship-to Post Code"; "Ship-to Post Code")
                    {
                        ApplicationArea = All;
                    }
                    field("Ship-to City"; "Ship-to City")
                    {
                        ApplicationArea = All;
                    }
                    field("Ship-to Contact"; "Ship-to Contact")
                    {
                        ApplicationArea = All;
                    }
                }
                group(Control6150662)
                {
                    ShowCaption = false;
                    field("Location Code"; "Location Code")
                    {
                        ApplicationArea = All;
                    }
                    field("Shipment Method Code"; "Shipment Method Code")
                    {
                        ApplicationArea = All;
                    }
                    field("Shipping Agent Code"; "Shipping Agent Code")
                    {
                        ApplicationArea = All;
                    }
                    field("Package Tracking No."; "Package Tracking No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Shipment Date"; "Shipment Date")
                    {
                        ApplicationArea = All;
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

