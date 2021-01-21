page 6151018 "NPR NpRv Sales Line Card"
{
    UsageCategory = None;
    Caption = 'Issue Retail Voucher Card';
    DataCaptionExpression = Description;
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
                field(Type; Type)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Voucher Type"; "Voucher Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Voucher Type field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Voucher No."; "Voucher No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Voucher No. field';
                }
                field("Reference No."; "Reference No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Reference No. field';
                }
                group(Control6014419)
                {
                    ShowCaption = false;
                    Visible = (Type = Type::"New Voucher") OR (Type = Type::"Top-Up") OR (Type = Type::"Partner Issue voucher");
                    field("Starting Date"; "Starting Date")
                    {
                        ApplicationArea = All;
                        Editable = (Type = Type::"New Voucher") OR (Type = Type::"Top-Up") OR (Type = Type::"Partner Issue voucher");
                        ToolTip = 'Specifies the value of the Starting Date field';
                    }
                }
            }
            group(Contact)
            {
                Caption = 'Contact';
                Visible = (Type = Type::"New Voucher") OR (Type = Type::"Top-Up") OR (Type = Type::"Partner Issue voucher");
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
                field("Contact No."; "Contact No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact No. field';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Contact: Record Contact;
                    begin
                        if PAGE.RunModal(PAGE::"NPR Touch Screen: CRM Contacts", Contact) <> ACTION::LookupOK then
                            exit;

                        Validate("Contact No.", Contact."No.");
                    end;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Name 2"; "Name 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name 2 field';
                }
                field(Address; Address)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Address field';
                }
                field("Address 2"; "Address 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Address 2 field';
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Code field';
                }
                field(City; City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the City field';
                }
                field(County; County)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the County field';
                }
                field("Country/Region Code"; "Country/Region Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Country/Region Code field';
                }
                field("Send via Print"; "Send via Print")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Send via Print field';
                }
                field("Send via E-mail"; "Send via E-mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Send via E-mail field';
                }
                field("E-mail"; "E-mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-mail field';
                }
                field("Send via SMS"; "Send via SMS")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Send via SMS field';
                }
                field("Phone No."; "Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Phone No. field';
                }
                field("Language Code"; "Language Code")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Language Code field';
                }
                field("Voucher Message"; "Voucher Message")
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ToolTip = 'Specifies the value of the Voucher Message field';
                }
            }
            group(Document)
            {
                Caption = 'Document';
                group(Control6014429)
                {
                    Editable = false;
                    ShowCaption = false;
                    Visible = ("Document Source" = "Document Source"::POS);
                    field("Register No."; "Register No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Cash Register No. field';
                    }
                    field("Sales Ticket No."; "Sales Ticket No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sales Ticket No. field';
                    }
                    field("Sale Type"; "Sale Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sale Type field';
                    }
                    field("Sale Date"; "Sale Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sale Date field';
                    }
                    field("Sale Line No."; "Sale Line No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sale Line No. field';
                    }
                    field("Retail ID"; "Retail ID")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Retail ID field';
                    }
                }
                group(Control6014435)
                {
                    Editable = false;
                    ShowCaption = false;
                    Visible = ("Document Source" = "Document Source"::"Sales Document") OR ("Document Source" = "Document Source"::"Payment Line");
                    field("Document Type"; "Document Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Document Type field';
                    }
                    field("Document No."; "Document No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Document No. field';
                    }
                    field("Document Line No."; "Document Line No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Document Line No. field';
                    }
                    field("External Document No."; "External Document No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the External Document No. field';
                    }
                    field("Posting No."; "Posting No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Posting No. field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the References action';

                trigger OnAction()
                var
                    SalesLine: Record "Sales Line";
                    SaleLinePOS: Record "NPR Sale Line POS";
                    NpRvSalesLineReferences: Page "NPR NpRv Sales Line Ref.";
                    Qty: Decimal;
                begin
                    Qty := 1;
                    case "Document Source" of
                        "Document Source"::POS:
                            begin
                                SaleLinePOS.SetRange("Retail ID", "Retail ID");
                                if SaleLinePOS.FindFirst then
                                    Qty := SaleLinePOS.Quantity;
                            end;
                        "Document Source"::"Sales Document":
                            begin
                                if SalesLine.Get("Document Type", "Document No.", "Document Line No.") then
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

