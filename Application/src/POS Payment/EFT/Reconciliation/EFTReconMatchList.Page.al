page 6059835 "NPR EFT Recon. Match List"
{
    Extensible = False;
    Caption = 'EFT Recon. Match List';
    CardPageID = "NPR EFT Recon. Match Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR EFT Recon. Match/Score";
    SourceTableView = sorting(Type, "Provider Code", ID);
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = NPRRetail;
                    Visible = (ShowMatch = ShowScore);
                    ToolTip = 'Specifies the value of the Type field';
                }
                field(ProviderCode; Rec."Provider Code")
                {
                    ApplicationArea = NPRRetail;
                    Visible = ShowProviderCode;
                    ToolTip = 'Specifies the value of the Provider Code field';
                }
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
                field(SequenceNo; Rec."Sequence No.")
                {
                    ApplicationArea = NPRRetail;
                    Visible = ShowMatch;
                    ToolTip = 'Specifies the value of the Sequence No. field';
                }
                field(Score; Rec.Score)
                {
                    ApplicationArea = NPRRetail;
                    Visible = ShowScore;
                    ToolTip = 'Specifies the value of the Score field';
                }
                field(MaxAdditionalScore; Rec."Max. Additional Score")
                {
                    ApplicationArea = NPRRetail;
                    Visible = ShowScore;
                    ToolTip = 'Specifies the value of the Max. Additional Score field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        ShowProviderCode := Rec.GetFilter("Provider Code") = '';
        SetFieldControl();
    end;

    var
        ShowProviderCode: Boolean;
        ShowScore: Boolean;
        ShowMatch: Boolean;

    local procedure SetFieldControl()
    var
        TempRec: Record "NPR EFT Recon. Match/Score" temporary;
    begin
        TempRec.Type := TempRec.Type::Score;
        TempRec.Insert(false);
        Rec.FilterGroup(3);
        if Rec.GetFilter(Type) = '' then begin
            ShowMatch := true;
            ShowScore := true;
        end else begin
            Rec.Copyfilter(Type, TempRec.Type);
            ShowMatch := TempRec.IsEmpty;
            ShowScore := not ShowMatch;
        end;
        Rec.FilterGroup(0);
    end;
}

