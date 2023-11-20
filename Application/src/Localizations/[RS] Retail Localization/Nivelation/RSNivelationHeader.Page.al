page 6151084 "NPR RS Nivelation Header"
{
    Caption = 'Nivelation Document';
    Extensible = false;
    PageType = Document;
    SourceTable = "NPR RS Nivelation Header";
    UsageCategory = None;

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
                    Editable = Rec.Type = "NPR RS Nivelation Type"::"Price Change";
                    ToolTip = 'Specifies the value of the Location Code field.';
                }
                field("Location Name"; Rec."Location Name")
                {
                    ApplicationArea = NPRRSRLocal;
                    Editable = false;
                    ToolTip = 'Specifies the value of the LocationName field.';
                }
                field("Price List Code"; Rec."Price List Code")
                {
                    ApplicationArea = NPRRSRLocal;
                    Editable = Rec.Type = "NPR RS Nivelation Type"::"Price Change";
                    ToolTip = 'Specifies the value of the Price List Code field.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Posting Date field.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = NPRRSRLocal;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Amount field.';
                }
                field("Price Valid Date"; Rec."Price Valid Date")
                {
                    ApplicationArea = NPRRSRLocal;
                    Editable = Rec.Type = "NPR RS Nivelation Type"::"Price Change";
                    ToolTip = 'Specifies the value of the Price Valid Date field.';
                }
                field("Referring Document Code"; Rec."Referring Document Code")
                {
                    ApplicationArea = NPRRSRLocal;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Referring Document Code field.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = NPRRSRLocal;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Status field.';
                }
            }
            group(Parts)
            {
                ShowCaption = false;
                part("Nivelation Subpart"; "NPR RS Nivelation Lines Part")
                {
                    ApplicationArea = NPRRSRLocal;
                    SubPageLink = "Document No." = field("No.");
                    UpdatePropagation = Both;
                }
            }
        }
    }

#if not (BC17 or BC18 or BC19)
    actions
    {
        area(Processing)
        {
            group(Posting)
            {
                Caption = 'Posting';
                Image = Post;
                action(Post)
                {
                    ApplicationArea = NPRRSRLocal;
                    Caption = 'Post';
                    Enabled = not IsPosted;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    Image = PostOrder;
                    ToolTip = 'Finalize the document or journal by posting the amounts and quantities to the related accounts in your company books.';

                    trigger OnAction()
                    var
                        NivelationPost: Codeunit "NPR RS Nivelation Post";
                    begin
                        NivelationPost.RunNivelationPosting(Rec)
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetActionEnabled();
    end;

    local procedure SetActionEnabled()
    begin
        IsPosted := false;
        if Rec.Status in ["NPR RS Nivelation Status"::Posted] then
            IsPosted := true;
    end;

    var
        IsPosted: Boolean;
#endif
}