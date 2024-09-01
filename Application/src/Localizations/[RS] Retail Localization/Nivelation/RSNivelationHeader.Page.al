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
                    ToolTip = 'Specifies the Nivelation Document Number.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Nivelation Type.';
                    trigger OnValidate()
                    begin
                        IsPriceChange := Rec.Type = "NPR RS Nivelation Type"::"Price Change"
                    end;
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Nivelation Document Source.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = NPRRSRLocal;
                    Editable = IsPriceChange;
                    ToolTip = 'Specifies the Retail Location Code.';
                }
                field("Location Name"; Rec."Location Name")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Location Name - Store Name.';
                }
                field("Price List Code"; Rec."Price List Code")
                {
                    ApplicationArea = NPRRSRLocal;
                    Editable = IsPriceChange;
                    ToolTip = 'Specifies the Price List Code if the Source Type is Sales Price List.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Posting Date.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the total value to be adjusted.';
                }
                field("Price Valid Date"; Rec."Price Valid Date")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the date when the given Sales Price list is valid from.';
                }
                field("Referring Document Code"; Rec."Referring Document Code")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Referring Document Code.';
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
    actions
    {
        area(Processing)
        {
#if not (BC17 or BC18 or BC19)
            group(Posting)
            {
                Caption = 'Posting';
                Image = Post;
                action(Post)
                {
                    ApplicationArea = NPRRSRLocal;
                    Caption = 'Post';
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
                        CheckIsDataSet();
                        NivelationPost.RunNivelationPosting(Rec, true)
                    end;
                }
            }
#endif
            action("Init")
            {
                ApplicationArea = NPRRSRLocal;
                Caption = 'Init Price List Lines';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = PostOrder;
                Enabled = IsPriceChange;
                ToolTip = 'Initialize Nivelation Lines from the chosen Price List.';

                trigger OnAction()
                begin
                    InitializeLinesFromPriceList();
                end;
            }
        }
    }

    trigger OnInit()
    begin
        IsPriceChange := Rec.Type = "NPR RS Nivelation Type"::"Price Change";
    end;

    trigger OnAfterGetRecord()
    begin
        IsPriceChange := Rec.Type = "NPR RS Nivelation Type"::"Price Change";
    end;

#if not (BC17 or BC18 or BC19)
    local procedure CheckIsDataSet()
    begin
        Rec.TestField("Location Code");
        Rec.TestField("Posting Date");
    end;
#endif
    local procedure InitializeLinesFromPriceList()
    var
        NivelationLines: Record "NPR RS Nivelation Lines";
        PriceListLines: Record "Price List Line";
        EndingDateFilter: Label '>=%1|''''', Comment = '%1 = Ending Date', Locked = true;
        StartingDateFilter: Label '<=%1', Comment = '%1 = Starting Date', Locked = true;
        LineNo: Integer;
    begin
        if Rec."Price List Code" = '' then
            exit;
        PriceListLines.SetRange("Price List Code", Rec."Price List Code");
        PriceListLines.SetFilter("Starting Date", StrSubstNo(StartingDateFilter, Rec."Price Valid Date"));
        PriceListLines.SetFilter("Ending Date", StrSubstNo(EndingDateFilter, Rec."Price Valid Date"));
        PriceListLines.SetRange("Price List Code", Rec."Price List Code");

        if not PriceListLines.FindSet() then
            exit;

        LineNo := NivelationLines.GetInitialLine() + 10000;

        NivelationLines.SetRange("Document No.", Rec."No.");
        repeat
            NivelationLines.SetRange("Item No.", PriceListLines."Asset No.");
            if not NivelationLines.FindFirst() then begin
                NivelationLines.Init();
                NivelationLines."Document No." := Rec."No.";
                NivelationLines."Line No." := LineNo;
                NivelationLines.Validate("Item No.", PriceListLines."Asset No.");
                NivelationLines.Validate("Old Price", PriceListLines."Unit Price");
                NivelationLines.Insert(true);
                LineNo += 10000;
            end else begin
                NivelationLines.Validate("Old Price", PriceListLines."Unit Price");
                NivelationLines.Modify();
            end;
        until PriceListLines.Next() = 0;
    end;

    var
        IsPriceChange: Boolean;
}