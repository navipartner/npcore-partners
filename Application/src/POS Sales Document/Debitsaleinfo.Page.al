page 6014401 "NPR Debit sale info"
{
    // NPR5.39/TJ  /20180208 CASE 302634 Renamed functions to english

    UsageCategory = None;
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
                        ToolTip = 'Specifies the value of the No. field';

                        trigger OnAssistEdit()
                        begin

                            if AssistEdit(xRec) then
                                CurrPage.Update;
                        end;
                    }
                    field("Sell-to Customer No."; "Sell-to Customer No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-to Customer No. field';
                    }
                    field("Sell-to Customer Name"; "Sell-to Customer Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-to Customer Name field';
                    }
                    field("Sell-to Customer Name 2"; "Sell-to Customer Name 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-to Customer Name 2 field';
                    }
                    field("Sell-to Address"; "Sell-to Address")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-to Address field';
                    }
                    field("Sell-to Address 2"; "Sell-to Address 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-to Address 2 field';
                    }
                    field("Sell-to Post Code"; "Sell-to Post Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-to Post Code field';
                    }
                    field("Sell-to City"; "Sell-to City")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-to City field';
                    }
                    field("Sell-to Contact"; "Sell-to Contact")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-to Contact field';
                    }
                    field("Your Reference"; "Your Reference")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Your Reference field';
                    }
                }
                group(Control6150627)
                {
                    ShowCaption = false;
                    field("Posting Date"; "Posting Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Posting Date field';
                    }
                    field("Document Date"; "Document Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Document Date field';
                    }
                    field("Salesperson Code"; "Salesperson Code")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Salesperson Code field';
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
                        ToolTip = 'Specifies the value of the Bill-to Customer No. field';
                    }
                    field("Bill-to Name"; "Bill-to Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Bill-to Name field';
                    }
                    field("Bill-to Name 2"; "Bill-to Name 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Bill-to Name 2 field';
                    }
                    field("Bill-to Address"; "Bill-to Address")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Bill-to Address field';
                    }
                    field("Bill-to Address 2"; "Bill-to Address 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Bill-to Address 2 field';
                    }
                    field("Bill-to Post Code"; "Bill-to Post Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Bill-to Post Code field';
                    }
                    field("Bill-to City"; "Bill-to City")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Bill-to City field';
                    }
                    field("Bill-to Contact"; "Bill-to Contact")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Bill-to Contact field';
                    }
                }
                group(Control6150642)
                {
                    ShowCaption = false;
                    field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field';
                    }
                    field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field';
                    }
                    field("Payment Terms Code"; "Payment Terms Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Payment Terms Code field';
                    }
                    field("Due Date"; "Due Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Due Date field';
                    }
                    field("Payment Discount %"; "Payment Discount %")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Payment Discount % field';
                    }
                    field("Pmt. Discount Date"; "Pmt. Discount Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Pmt. Discount Date field';
                    }
                    field("Payment Method Code"; "Payment Method Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Payment Method Code field';
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
                        ToolTip = 'Specifies the value of the Ship-to Code field';
                    }
                    field("Ship-to Name"; "Ship-to Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ship-to Name field';
                    }
                    field("Ship-to Name 2"; "Ship-to Name 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ship-to Name 2 field';
                    }
                    field("Ship-to Address"; "Ship-to Address")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ship-to Address field';
                    }
                    field("Ship-to Address 2"; "Ship-to Address 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ship-to Address 2 field';
                    }
                    field("Ship-to Post Code"; "Ship-to Post Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ship-to Post Code field';
                    }
                    field("Ship-to City"; "Ship-to City")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ship-to City field';
                    }
                    field("Ship-to Contact"; "Ship-to Contact")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ship-to Contact field';
                    }
                }
                group(Control6150662)
                {
                    ShowCaption = false;
                    field("Location Code"; "Location Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Location Code field';
                    }
                    field("Shipment Method Code"; "Shipment Method Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Shipment Method Code field';
                    }
                    field("Shipping Agent Code"; "Shipping Agent Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Shipping Agent Code field';
                    }
                    field("Package Tracking No."; "Package Tracking No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Package Tracking No. field';
                    }
                    field("Shipment Date"; "Shipment Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Shipment Date field';
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

