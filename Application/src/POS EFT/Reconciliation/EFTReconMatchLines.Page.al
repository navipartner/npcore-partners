page 6059828 "NPR EFT Recon. Match Lines"
{
    AutoSplitKey = true;
    PageType = ListPart;
    SourceTable = "NPR EFT Rec. Match/Score Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(TransactionFieldNo; Rec."Transaction Field No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Transaction Field No. field';
                }
                field(TransactionFieldName; Rec."Transaction Field Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Transaction Field Name field';
                }
                field(FilterType; Rec."Filter Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Filter Type field';
                }
                field(FieldNo; Rec."Field No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Field No. field';
                }
                field(FieldName; Rec."Field Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Field Name field';
                }
                field(FilterValue; Rec."Filter Value")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Filter Value field';
                }
                field(AdditionalScore; Rec."Additional Score")
                {
                    ApplicationArea = NPRRetail;
                    Visible = ShowAdditionalScore;
                    ToolTip = 'Specifies the value of the Additional Score field';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Test Filter")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Executes the Test Filter action';
                Image = Filter;

                trigger OnAction()
                var
                    EFTReconMatchingMgt: Codeunit "NPR EFT Rec. Match/Score Mgt.";
                begin
                    EFTReconMatchingMgt.TestFilterLine(Rec);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        SetFieldControl();
    end;

    var
        ShowAdditionalScore: Boolean;

    local procedure SetFieldControl()
    var
        TempRec: Record "NPR EFT Rec. Match/Score Line" temporary;
    begin
        TempRec.LineType := TempRec.Linetype::AdditionalScore;
        TempRec.Insert(false);
        Rec.FilterGroup(3);
        Rec.Copyfilter(LineType, TempRec.LineType);
        ShowAdditionalScore := not TempRec.IsEmpty;
        Rec.FilterGroup(0);
    end;
}

