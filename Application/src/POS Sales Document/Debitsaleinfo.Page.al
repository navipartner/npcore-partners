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

                        Editable = false;
                        ToolTip = 'Specifies the value of the No. field';
                        ApplicationArea = NPRRetail;

                        trigger OnAssistEdit()
                        begin

                            if Rec.AssistEdit(xRec) then
                                CurrPage.Update();
                        end;
                    }
                    field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                    {

                        ToolTip = 'Specifies the value of the Sell-to Customer No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                    {

                        ToolTip = 'Specifies the value of the Sell-to Customer Name field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sell-to Customer Name 2"; Rec."Sell-to Customer Name 2")
                    {

                        ToolTip = 'Specifies the value of the Sell-to Customer Name 2 field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sell-to Address"; Rec."Sell-to Address")
                    {

                        ToolTip = 'Specifies the value of the Sell-to Address field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sell-to Address 2"; Rec."Sell-to Address 2")
                    {

                        ToolTip = 'Specifies the value of the Sell-to Address 2 field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sell-to Post Code"; Rec."Sell-to Post Code")
                    {

                        ToolTip = 'Specifies the value of the Sell-to Post Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sell-to City"; Rec."Sell-to City")
                    {

                        ToolTip = 'Specifies the value of the Sell-to City field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sell-to Contact"; Rec."Sell-to Contact")
                    {

                        ToolTip = 'Specifies the value of the Sell-to Contact field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Your Reference"; Rec."Your Reference")
                    {

                        ToolTip = 'Specifies the value of the Your Reference field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6150627)
                {
                    ShowCaption = false;
                    field("Posting Date"; Rec."Posting Date")
                    {

                        ToolTip = 'Specifies the value of the Posting Date field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Document Date"; Rec."Document Date")
                    {

                        ToolTip = 'Specifies the value of the Document Date field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Salesperson Code"; Rec."Salesperson Code")
                    {

                        Editable = false;
                        ToolTip = 'Specifies the value of the Salesperson Code field';
                        ApplicationArea = NPRRetail;
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

                        ToolTip = 'Specifies the value of the Bill-to Customer No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Bill-to Name"; Rec."Bill-to Name")
                    {

                        ToolTip = 'Specifies the value of the Bill-to Name field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Bill-to Name 2"; Rec."Bill-to Name 2")
                    {

                        ToolTip = 'Specifies the value of the Bill-to Name 2 field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Bill-to Address"; Rec."Bill-to Address")
                    {

                        ToolTip = 'Specifies the value of the Bill-to Address field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Bill-to Address 2"; Rec."Bill-to Address 2")
                    {

                        ToolTip = 'Specifies the value of the Bill-to Address 2 field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Bill-to Post Code"; Rec."Bill-to Post Code")
                    {

                        ToolTip = 'Specifies the value of the Bill-to Post Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Bill-to City"; Rec."Bill-to City")
                    {

                        ToolTip = 'Specifies the value of the Bill-to City field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Bill-to Contact"; Rec."Bill-to Contact")
                    {

                        ToolTip = 'Specifies the value of the Bill-to Contact field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6150642)
                {
                    ShowCaption = false;
                    field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                    {

                        ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                    {

                        ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Payment Terms Code"; Rec."Payment Terms Code")
                    {

                        ToolTip = 'Specifies the value of the Payment Terms Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Due Date"; Rec."Due Date")
                    {

                        ToolTip = 'Specifies the value of the Due Date field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Payment Discount %"; Rec."Payment Discount %")
                    {

                        ToolTip = 'Specifies the value of the Payment Discount % field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Pmt. Discount Date"; Rec."Pmt. Discount Date")
                    {

                        ToolTip = 'Specifies the value of the Pmt. Discount Date field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Payment Method Code"; Rec."Payment Method Code")
                    {

                        ToolTip = 'Specifies the value of the Payment Method Code field';
                        ApplicationArea = NPRRetail;
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

                        ToolTip = 'Specifies the value of the Ship-to Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Ship-to Name"; Rec."Ship-to Name")
                    {

                        ToolTip = 'Specifies the value of the Ship-to Name field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Ship-to Name 2"; Rec."Ship-to Name 2")
                    {

                        ToolTip = 'Specifies the value of the Ship-to Name 2 field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Ship-to Address"; Rec."Ship-to Address")
                    {

                        ToolTip = 'Specifies the value of the Ship-to Address field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Ship-to Address 2"; Rec."Ship-to Address 2")
                    {

                        ToolTip = 'Specifies the value of the Ship-to Address 2 field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Ship-to Post Code"; Rec."Ship-to Post Code")
                    {

                        ToolTip = 'Specifies the value of the Ship-to Post Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Ship-to City"; Rec."Ship-to City")
                    {

                        ToolTip = 'Specifies the value of the Ship-to City field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Ship-to Contact"; Rec."Ship-to Contact")
                    {

                        ToolTip = 'Specifies the value of the Ship-to Contact field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6150662)
                {
                    ShowCaption = false;
                    field("Location Code"; Rec."Location Code")
                    {

                        ToolTip = 'Specifies the value of the Location Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Shipment Method Code"; Rec."Shipment Method Code")
                    {

                        ToolTip = 'Specifies the value of the Shipment Method Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Shipping Agent Code"; Rec."Shipping Agent Code")
                    {

                        ToolTip = 'Specifies the value of the Shipping Agent Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Package Tracking No."; Rec."Package Tracking No.")
                    {

                        ToolTip = 'Specifies the value of the Package Tracking No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Shipment Date"; Rec."Shipment Date")
                    {

                        ToolTip = 'Specifies the value of the Shipment Date field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }
    }

    actions
    {
    }


    procedure SetCustomer(Text: Text[30])
    begin
        Rec."Your Reference" := Text;
    end;

    procedure GetCustomer(var Text: Text[35])
    begin
        Text := Rec."Your Reference";
    end;
}

