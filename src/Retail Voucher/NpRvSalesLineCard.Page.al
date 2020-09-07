page 6151018 "NPR NpRv Sales Line Card"
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher
    // NPR5.48/MHA /20190123  CASE 341711 Added Send Method fields
    // NPR5.55/MHA /20200512  CASE 402015 Updated object name
    // NPR5.55/MHA /20200701  CASE 397527 Added field 270 "Language Code"

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
                }
                field("Voucher Type"; "Voucher Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Voucher No."; "Voucher No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Reference No."; "Reference No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                group(Control6014419)
                {
                    ShowCaption = false;
                    Visible = (Type = Type::"New Voucher") OR (Type = Type::"Top-Up") OR (Type = Type::"Partner Issue voucher");
                    field("Starting Date"; "Starting Date")
                    {
                        ApplicationArea = All;
                        Editable = (Type = Type::"New Voucher") OR (Type = Type::"Top-Up") OR (Type = Type::"Partner Issue voucher");
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
                }
                field("Contact No."; "Contact No.")
                {
                    ApplicationArea = All;

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
                }
                field("Name 2"; "Name 2")
                {
                    ApplicationArea = All;
                }
                field(Address; Address)
                {
                    ApplicationArea = All;
                }
                field("Address 2"; "Address 2")
                {
                    ApplicationArea = All;
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = All;
                }
                field(City; City)
                {
                    ApplicationArea = All;
                }
                field(County; County)
                {
                    ApplicationArea = All;
                }
                field("Country/Region Code"; "Country/Region Code")
                {
                    ApplicationArea = All;
                }
                field("Send via Print"; "Send via Print")
                {
                    ApplicationArea = All;
                }
                field("Send via E-mail"; "Send via E-mail")
                {
                    ApplicationArea = All;
                }
                field("E-mail"; "E-mail")
                {
                    ApplicationArea = All;
                }
                field("Send via SMS"; "Send via SMS")
                {
                    ApplicationArea = All;
                }
                field("Phone No."; "Phone No.")
                {
                    ApplicationArea = All;
                }
                field("Language Code"; "Language Code")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                }
                field("Voucher Message"; "Voucher Message")
                {
                    ApplicationArea = All;
                    MultiLine = true;
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
                    }
                    field("Sales Ticket No."; "Sales Ticket No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Sale Type"; "Sale Type")
                    {
                        ApplicationArea = All;
                    }
                    field("Sale Date"; "Sale Date")
                    {
                        ApplicationArea = All;
                    }
                    field("Sale Line No."; "Sale Line No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Retail ID"; "Retail ID")
                    {
                        ApplicationArea = All;
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
                    }
                    field("Document No."; "Document No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Document Line No."; "Document Line No.")
                    {
                        ApplicationArea = All;
                    }
                    field("External Document No."; "External Document No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Posting No."; "Posting No.")
                    {
                        ApplicationArea = All;
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea=All;

                trigger OnAction()
                var
                    SalesLine: Record "Sales Line";
                    SaleLinePOS: Record "NPR Sale Line POS";
                    NpRvSalesLineReferences: Page "NPR NpRv Sales Line Ref.";
                    Qty: Decimal;
                begin
                    //-NPR5.55 [402015]
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
                    //+NPR5.55 [402015]
                end;
            }
        }
    }
}

