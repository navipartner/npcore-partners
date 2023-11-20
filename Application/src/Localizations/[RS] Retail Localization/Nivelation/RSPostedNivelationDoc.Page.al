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
                    ToolTip = 'Specifies the value of the No. field.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Type field.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Location Code field.';
                    Visible = Rec.Type = "NPR RS Nivelation Type"::"Price Change";
                    ;
                }
                field("Location Name"; Rec."Location Name")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the LocationName field.';
                    Visible = Rec.Type = "NPR RS Nivelation Type"::"Price Change";
                    ;
                }
                field("Price List Code"; Rec."Price List Code")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Price List Code field.';
                    Visible = Rec.Type = "NPR RS Nivelation Type"::"Price Change";
                    ;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Posting Date field.';
                }
                field("UserID"; UserId())
                {
                    Caption = 'Created by User';
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Created by User field.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Amount field.';
                }
                field("Referring Document Code"; Rec."Referring Document Code")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Referring Document Code field.';
                    Visible = not (Rec.Type = "NPR RS Nivelation Type"::"Price Change");
                    Editable = false;
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
        }
    }
}