page 6059824 "NPR EFT Recon. Match Card"
{
    Extensible = False;
    Caption = 'EFT Recon. Match Card';
    PageType = Card;
    SourceTable = "NPR EFT Recon. Match/Score";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(ID; Rec.ID)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the ID field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Enabled field';
                }
                group(Control6014410)
                {
                    Visible = Rec.Type = Rec.Type::Match;
                    field(SequenceNo; Rec."Sequence No.")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Sequence No. field';
                    }
                }
                group(Control6014411)
                {
                    Visible = Rec.Type = Rec.Type::Score;
                    field(Score; Rec.Score)
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Score field';
                    }
                    field(MaxAdditionalScore; Rec."Max. Additional Score")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Max. Additional Score field';
                    }
                }
            }
            part(Filters; "NPR EFT Recon. Match Lines")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Filters';
                SubPageLink = Type = field(Type),
                              "Provider Code" = field("Provider Code"),
                              ID = field(ID);
                SubPageView = where(LineType = const(Filter));
            }
            part(AdditionalScore; "NPR EFT Recon. Match Lines")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Additional Score';
                SubPageLink = Type = field(Type),
                              "Provider Code" = field("Provider Code"),
                              ID = field(ID);
                SubPageView = where(LineType = const(AdditionalScore));
                UpdatePropagation = Both;
                Visible = Rec.Type = Rec.Type::Score;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Copy Lines")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Copy Lines';
                Image = Copy;
                ToolTip = 'Executes the Copy Lines action';

                trigger OnAction()
                var
                    EFTReconMatchingMgt: Codeunit "NPR EFT Rec. Match/Score Mgt.";
                begin
                    EFTReconMatchingMgt.CopyLines(Rec);
                end;
            }
        }
    }
}

