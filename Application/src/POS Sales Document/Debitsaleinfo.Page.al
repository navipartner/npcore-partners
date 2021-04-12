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
                    field("No."; Rec."No.")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the No. field';

                        trigger OnAssistEdit()
                        begin

                            if Rec.AssistEdit(xRec) then
                                CurrPage.Update();
                        end;
                    }
                    field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-to Customer No. field';
                    }
                    field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-to Customer Name field';
                    }
                    field("Sell-to Customer Name 2"; Rec."Sell-to Customer Name 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-to Customer Name 2 field';
                    }
                    field("Sell-to Address"; Rec."Sell-to Address")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-to Address field';
                    }
                    field("Sell-to Address 2"; Rec."Sell-to Address 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-to Address 2 field';
                    }
                    field("Sell-to Post Code"; Rec."Sell-to Post Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-to Post Code field';
                    }
                    field("Sell-to City"; Rec."Sell-to City")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-to City field';
                    }
                    field("Sell-to Contact"; Rec."Sell-to Contact")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-to Contact field';
                    }
                    field("Your Reference"; Rec."Your Reference")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Your Reference field';
                    }
                }
                group(Control6150627)
                {
                    ShowCaption = false;
                    field("Posting Date"; Rec."Posting Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Posting Date field';
                    }
                    field("Document Date"; Rec."Document Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Document Date field';
                    }
                    field("Salesperson Code"; Rec."Salesperson Code")
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
                    field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Bill-to Customer No. field';
                    }
                    field("Bill-to Name"; Rec."Bill-to Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Bill-to Name field';
                    }
                    field("Bill-to Name 2"; Rec."Bill-to Name 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Bill-to Name 2 field';
                    }
                    field("Bill-to Address"; Rec."Bill-to Address")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Bill-to Address field';
                    }
                    field("Bill-to Address 2"; Rec."Bill-to Address 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Bill-to Address 2 field';
                    }
                    field("Bill-to Post Code"; Rec."Bill-to Post Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Bill-to Post Code field';
                    }
                    field("Bill-to City"; Rec."Bill-to City")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Bill-to City field';
                    }
                    field("Bill-to Contact"; Rec."Bill-to Contact")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Bill-to Contact field';
                    }
                }
                group(Control6150642)
                {
                    ShowCaption = false;
                    field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field';
                    }
                    field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field';
                    }
                    field("Payment Terms Code"; Rec."Payment Terms Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Payment Terms Code field';
                    }
                    field("Due Date"; Rec."Due Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Due Date field';
                    }
                    field("Payment Discount %"; Rec."Payment Discount %")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Payment Discount % field';
                    }
                    field("Pmt. Discount Date"; Rec."Pmt. Discount Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Pmt. Discount Date field';
                    }
                    field("Payment Method Code"; Rec."Payment Method Code")
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
                    field("Ship-to Code"; Rec."Ship-to Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ship-to Code field';
                    }
                    field("Ship-to Name"; Rec."Ship-to Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ship-to Name field';
                    }
                    field("Ship-to Name 2"; Rec."Ship-to Name 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ship-to Name 2 field';
                    }
                    field("Ship-to Address"; Rec."Ship-to Address")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ship-to Address field';
                    }
                    field("Ship-to Address 2"; Rec."Ship-to Address 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ship-to Address 2 field';
                    }
                    field("Ship-to Post Code"; Rec."Ship-to Post Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ship-to Post Code field';
                    }
                    field("Ship-to City"; Rec."Ship-to City")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ship-to City field';
                    }
                    field("Ship-to Contact"; Rec."Ship-to Contact")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ship-to Contact field';
                    }
                }
                group(Control6150662)
                {
                    ShowCaption = false;
                    field("Location Code"; Rec."Location Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Location Code field';
                    }
                    field("Shipment Method Code"; Rec."Shipment Method Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Shipment Method Code field';
                    }
                    field("Shipping Agent Code"; Rec."Shipping Agent Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Shipping Agent Code field';
                    }
                    field("Package Tracking No."; Rec."Package Tracking No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Package Tracking No. field';
                    }
                    field("Shipment Date"; Rec."Shipment Date")
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


    procedure SetCustomer(var Text: Text[30])
    begin
        Rec."Your Reference" := Text;
    end;

    procedure GetCustomer(var Text: Text[30])
    begin
        Text := Rec."Your Reference";
    end;
}

