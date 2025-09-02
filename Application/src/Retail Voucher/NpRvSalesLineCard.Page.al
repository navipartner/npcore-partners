page 6151018 "NPR NpRv Sales Line Card"
{
    Extensible = False;
    UsageCategory = None;
    Caption = 'Issue Retail Voucher Card';
    DataCaptionExpression = Rec.Description;
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "NPR NpRv Sales Line";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(Type; Rec.Type)
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Voucher Type"; Rec."Voucher Type")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Voucher Type field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Voucher No."; Rec."Voucher No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Voucher No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Reference No."; Rec."Reference No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Reference No. field';
                    ApplicationArea = NPRRetail;
                }
                group(Control6014419)
                {
                    ShowCaption = false;
                    Visible = (Rec.Type = Rec.Type::"New Voucher") OR (Rec.Type = Rec.Type::"Top-Up") OR (Rec.Type = Rec.Type::"Partner Issue voucher");
                    field("Starting Date"; Rec."Starting Date")
                    {
                        Editable = (Rec.Type = Rec.Type::"New Voucher") OR (Rec.Type = Rec.Type::"Top-Up") OR (Rec.Type = Rec.Type::"Partner Issue voucher");
                        ToolTip = 'Specifies the value of the Starting Date field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group(Contact)
            {
                Caption = 'Contact';
                Visible = (Rec.Type = Rec.Type::"New Voucher") OR (Rec.Type = Rec.Type::"Top-Up") OR (Rec.Type = Rec.Type::"Partner Issue voucher");
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Customer No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Contact No."; Rec."Contact No.")
                {
                    ToolTip = 'Specifies the value of the Contact No. field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Contact: Record Contact;
                    begin
                        if PAGE.RunModal(0, Contact) <> ACTION::LookupOK then
                            exit;

                        Rec.Validate("Contact No.", Contact."No.");
                    end;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Name 2"; Rec."Name 2")
                {
                    ToolTip = 'Specifies the value of the Name 2 field';
                    ApplicationArea = NPRRetail;
                    Importance = Additional;
                }
                field(Address; Rec.Address)
                {
                    ToolTip = 'Specifies the value of the Address field';
                    ApplicationArea = NPRRetail;
                    Importance = Additional;
                }
                field("Address 2"; Rec."Address 2")
                {
                    ToolTip = 'Specifies the value of the Address 2 field';
                    ApplicationArea = NPRRetail;
                    Importance = Additional;
                }
                field("Post Code"; Rec."Post Code")
                {
                    ToolTip = 'Specifies the value of the Post Code field';
                    ApplicationArea = NPRRetail;
                    Importance = Additional;
                }
                field(City; Rec.City)
                {
                    ToolTip = 'Specifies the value of the City field';
                    ApplicationArea = NPRRetail;
                    Importance = Additional;
                }
                field(County; Rec.County)
                {
                    ToolTip = 'Specifies the value of the County field';
                    ApplicationArea = NPRRetail;
                    Importance = Additional;
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ToolTip = 'Specifies the value of the Country/Region Code field';
                    ApplicationArea = NPRRetail;
                    Importance = Additional;
                }
                field("Send via Print"; Rec."Send via Print")
                {
                    ToolTip = 'Specifies the value of the Send via Print field';
                    ApplicationArea = NPRRetail;
                }
                field("Send via E-mail"; Rec."Send via E-mail")
                {
                    ToolTip = 'Specifies the value of the Send via E-mail field';
                    ApplicationArea = NPRRetail;
                }
                field("E-mail"; Rec."E-mail")
                {
                    ToolTip = 'Specifies the value of the E-mail field';
                    ApplicationArea = NPRRetail;
                }
                field("Send via SMS"; Rec."Send via SMS")
                {
                    ToolTip = 'Specifies the value of the Send via SMS field';
                    ApplicationArea = NPRRetail;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ToolTip = 'Specifies the value of the Phone No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Language Code"; Rec."Language Code")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Language Code field';
                    ApplicationArea = NPRRetail;
                }
#if not BC17                
                group(SendFromShopify)
                {
                    Caption = 'Send From Shopify';
                    Visible = Rec."Spfy Send from Shopify";
                    field("Spfy Recipient Name"; Rec."Spfy Recipient Name")
                    {
                        ToolTip = 'Specifies the name of the voucher recipient. If this field is empty, the system will use the customer name.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Spfy Recipient E-mail"; Rec."Spfy Recipient E-mail")
                    {
                        ToolTip = 'Specifies the email address of the voucher recipient. If this field is empty, the system will use the customer email address.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Spfy Send on"; Rec."Spfy Send on")
                    {
                        ToolTip = 'Specifies the date and time when Shopify should send the voucher to the recipient.';
                        ApplicationArea = NPRRetail;
                    }
                }
#endif
                field("Voucher Message"; Rec."Voucher Message")
                {
                    MultiLine = true;
                    ToolTip = 'Specifies the message to include with the voucher.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Document)
            {
                Caption = 'Document';
                group(Control6014429)
                {
                    Editable = false;
                    ShowCaption = false;
                    Visible = (Rec."Document Source" = Rec."Document Source"::POS) or (Rec."Document Source" = Rec."Document Source"::"POS Quote");
                    field("Register No."; Rec."Register No.")
                    {
                        ToolTip = 'Specifies the value of the POS Unit No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sales Ticket No."; Rec."Sales Ticket No.")
                    {
                        ToolTip = 'Specifies the value of the Sales Ticket No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sale Date"; Rec."Sale Date")
                    {
                        ToolTip = 'Specifies the value of the Sale Date field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sale Line No."; Rec."Sale Line No.")
                    {
                        ToolTip = 'Specifies the value of the Sale Line No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Retail ID"; Rec."Retail ID")
                    {
                        ToolTip = 'Specifies the value of the Retail ID field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6014435)
                {
                    Editable = false;
                    ShowCaption = false;
                    Visible = (Rec."Document Source" = Rec."Document Source"::"Sales Document") OR (Rec."Document Source" = Rec."Document Source"::"Payment Line");
                    field("Document Type"; Rec."Document Type")
                    {
                        ToolTip = 'Specifies the value of the Document Type field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Document No."; Rec."Document No.")
                    {
                        ToolTip = 'Specifies the value of the Document No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Document Line No."; Rec."Document Line No.")
                    {
                        ToolTip = 'Specifies the value of the Document Line No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("External Document No."; Rec."External Document No.")
                    {
                        ToolTip = 'Specifies the value of the External Document No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Posting No."; Rec."Posting No.")
                    {
                        ToolTip = 'Specifies the value of the Posting No. field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(References)
            {
                Caption = 'References';
                Image = BarCode;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Executes the References action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    SalesLine: Record "Sales Line";
                    SaleLinePOS: Record "NPR POS Sale Line";
                    NpRvSalesLineReferences: Page "NPR NpRv Sales Line Ref.";
                    Qty: Decimal;
                begin
                    Qty := 1;
                    case Rec."Document Source" of
                        Rec."Document Source"::POS:
                            begin
                                if SaleLinePOS.GetBySystemId(Rec."Retail ID") then
                                    Qty := SaleLinePOS.Quantity;
                            end;
                        Rec."Document Source"::"Sales Document":
                            begin
                                if SalesLine.Get(Rec."Document Type", Rec."Document No.", Rec."Document Line No.") then
                                    Qty := SalesLine.Quantity;
                            end;
                    end;

                    NpRvSalesLineReferences.SetNpRvSalesLine(Rec, Qty);
                    NpRvSalesLineReferences.Run();
                end;
            }
        }
    }
}
