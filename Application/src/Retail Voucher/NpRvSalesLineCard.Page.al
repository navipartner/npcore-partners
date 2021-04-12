page 6151018 "NPR NpRv Sales Line Card"
{
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
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Voucher Type"; Rec."Voucher Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Voucher Type field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Voucher No."; Rec."Voucher No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Voucher No. field';
                }
                field("Reference No."; Rec."Reference No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Reference No. field';
                }
                group(Control6014419)
                {
                    ShowCaption = false;
                    Visible = (Rec.Type = Rec.Type::"New Voucher") OR (Rec.Type = Rec.Type::"Top-Up") OR (Rec.Type = Rec.Type::"Partner Issue voucher");
                    field("Starting Date"; Rec."Starting Date")
                    {
                        ApplicationArea = All;
                        Editable = (Rec.Type = Rec.Type::"New Voucher") OR (Rec.Type = Rec.Type::"Top-Up") OR (Rec.Type = Rec.Type::"Partner Issue voucher");
                        ToolTip = 'Specifies the value of the Starting Date field';
                    }
                }
            }
            group(Contact)
            {
                Caption = 'Contact';
                Visible = (Rec.Type = Rec.Type::"New Voucher") OR (Rec.Type = Rec.Type::"Top-Up") OR (Rec.Type = Rec.Type::"Partner Issue voucher");
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
                field("Contact No."; Rec."Contact No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact No. field';

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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Name 2"; Rec."Name 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name 2 field';
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Address field';
                }
                field("Address 2"; Rec."Address 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Address 2 field';
                }
                field("Post Code"; Rec."Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Code field';
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the City field';
                }
                field(County; Rec.County)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the County field';
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Country/Region Code field';
                }
                field("Send via Print"; Rec."Send via Print")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Send via Print field';
                }
                field("Send via E-mail"; Rec."Send via E-mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Send via E-mail field';
                }
                field("E-mail"; Rec."E-mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-mail field';
                }
                field("Send via SMS"; Rec."Send via SMS")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Send via SMS field';
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Phone No. field';
                }
                field("Language Code"; Rec."Language Code")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Language Code field';
                }
                field("Voucher Message"; Rec."Voucher Message")
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
                    Visible = (Rec."Document Source" = Rec."Document Source"::POS);
                    field("Register No."; Rec."Register No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the POS Unit No. field';
                    }
                    field("Sales Ticket No."; Rec."Sales Ticket No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sales Ticket No. field';
                    }
                    field("Sale Type"; Rec."Sale Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sale Type field';
                    }
                    field("Sale Date"; Rec."Sale Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sale Date field';
                    }
                    field("Sale Line No."; Rec."Sale Line No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sale Line No. field';
                    }
                    field("Retail ID"; Rec."Retail ID")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Retail ID field';
                    }
                }
                group(Control6014435)
                {
                    Editable = false;
                    ShowCaption = false;
                    Visible = (Rec."Document Source" = Rec."Document Source"::"Sales Document") OR (Rec."Document Source" = Rec."Document Source"::"Payment Line");
                    field("Document Type"; Rec."Document Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Document Type field';
                    }
                    field("Document No."; Rec."Document No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Document No. field';
                    }
                    field("Document Line No."; Rec."Document Line No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Document Line No. field';
                    }
                    field("External Document No."; Rec."External Document No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the External Document No. field';
                    }
                    field("Posting No."; Rec."Posting No.")
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
                    SaleLinePOS: Record "NPR POS Sale Line";
                    NpRvSalesLineReferences: Page "NPR NpRv Sales Line Ref.";
                    Qty: Decimal;
                begin
                    Qty := 1;
                    case Rec."Document Source" of
                        Rec."Document Source"::POS:
                            begin
                                SaleLinePOS.SetRange("Retail ID", Rec."Retail ID");
                                if SaleLinePOS.FindFirst() then
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

