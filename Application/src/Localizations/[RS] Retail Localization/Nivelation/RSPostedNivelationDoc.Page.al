page 6151096 "NPR RS Posted Nivelation Doc"
{
    Caption = 'Posted Nivelation Document';
    PageType = Document;
    SourceTable = "NPR RS Posted Nivelation Hdr";
    RefreshOnActivate = true;
    UsageCategory = None;
    Editable = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Nivelation Document Number.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Nivelation Type.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Retail Location Code.';
                    Visible = IsPriceChange;
                }
                field("Location Name"; Rec."Location Name")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Location Name - Store Name.';
                    Visible = IsPriceChange;
                }
                field("Price List Code"; Rec."Price List Code")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Price List Code from which the Nivelation is created from.';
                    Visible = IsPriceChange;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Posting Date of the Nivelation.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the total value to be adjusted.';
                }
                field("Referring Document Code"; Rec."Referring Document Code")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Referring Document Code field.';
                    Editable = false;
                }
                field("UserID"; UserId())
                {
                    Caption = 'Created by User';
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the User.';
                }
            }
            group(Parts)
            {
                ShowCaption = false;
                part("Nivelation Subpart"; "NPR RS Posted Niv. Lines Subp.")
                {
                    ApplicationArea = NPRRSRLocal;
                    SubPageLink = "Document No." = field("No.");
                    UpdatePropagation = Both;
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action("NPR Nivelation")
            {
                Caption = 'Print Nivelation';
                ToolTip = 'Runs a Nivelation report.';
                ApplicationArea = NPRRSRLocal;
                Image = Print;

                trigger OnAction()
                var
                    Nivelation: Record "NPR RS Posted Nivelation Hdr";
                begin
                    Nivelation.SetRange("Posting Date", Rec."Posting Date");
                    Nivelation.SetRange("No.", Rec."No.");
                    Report.RunModal(Report::"NPR RS Nivelation Document", true, false, Nivelation);
                end;
            }
            action(Navigate)
            {
                ApplicationArea = NPRRSRLocal;
                Caption = 'Find entries...';
                Image = Navigate;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Find entries and documents that exist for the document number and posting date on the selected document.';

                trigger OnAction()
                begin
                    Rec.Navigate();
                end;
            }

            action("Open Related Document")
            {
                ApplicationArea = NPRRSRLocal;
                Caption = 'Open Related Document';
                Image = Open;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = Repeater;
                ToolTip = 'Executes the Open Related Document action.';

                trigger OnAction()
                var
                    POSEntry: Record "NPR POS Entry";
                    SalesPriceList: Record "Price List Header";
                    PostedSalesCrMemo: Record "Sales Cr.Memo Header";
                    PostedSalesInvoice: Record "Sales Invoice Header";
                begin
                    case Rec."Source Type" of
                        Rec."Source Type"::"POS Entry":
                            begin
                                POSEntry.SetCurrentKey("Document No.");
                                POSEntry.SetRange("Document No.", Rec."Referring Document Code");
                                POSEntry.FindFirst();
                                Page.RunModal(Page::"NPR POS Entry Card", POSEntry);
                            end;
                        Rec."Source Type"::"Posted Sales Invoice":
                            begin
                                PostedSalesInvoice.Get(Rec."Referring Document Code");
                                Page.RunModal(Page::"Posted Sales Invoice", PostedSalesInvoice);
                            end;
                        Rec."Source Type"::"Posted Sales Credit Memo":
                            begin
                                PostedSalesCrMemo.Get(Rec."Referring Document Code");
                                Page.RunModal(Page::"Posted Sales Credit Memo", PostedSalesCrMemo);
                            end;
                        Rec."Source Type"::"Sales Price List":
                            begin
                                SalesPriceList.Get(Rec."Referring Document Code");
                                Page.RunModal(Page::"Sales Price List", SalesPriceList);
                            end;
                    end;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        IsPriceChange := Rec.Type in ["NPR RS Nivelation Type"::"Price Change"];
    end;

    var
        IsPriceChange: Boolean;
}