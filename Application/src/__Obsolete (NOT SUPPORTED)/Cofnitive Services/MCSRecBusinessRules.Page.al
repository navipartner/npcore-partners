page 6060083 "NPR MCS Rec. Business Rules"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'On February 15, 2018, “Recommendations API is no longer under active development”';
    Caption = 'MCS Rec. Business Rules';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR MCS Rec. Bus. Rule";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Model No."; Rec."Model No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Model No. field';
                }
                field("Rule No."; Rec."Rule No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rule No. field';
                }
                field(Active; Rec.Active)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Active field';
                }
                field("Rule Type"; Rec."Rule Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rule Type field';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Block Seed Item No."; Rec."Block Seed Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Block Seed Item No. field';
                }
                field("Last Sent Date Time"; Rec."Last Sent Date Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Sent Date Time field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(InsertItemRules)
            {
                Caption = 'Batch insert rules for items';
                Image = AddAction;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Batch insert rules for items action';

                trigger OnAction()
                begin
                    InsertRulesForItemSelection;
                end;
            }
        }
    }

    local procedure InsertRulesForItemSelection()
    var
        MCSRecommendationsModel: Record "NPR MCS Recomm. Model";
        MCSAddRecBusinessRules: Report "NPR MCS Add Rec. Bus. Rules";
    begin
        if Rec."Model No." = '' then
            exit;
        Clear(MCSAddRecBusinessRules);
        MCSRecommendationsModel.Reset;
        MCSRecommendationsModel.SetRange(Code, Rec."Model No.");
        MCSAddRecBusinessRules.SetTableView(MCSRecommendationsModel);
        MCSAddRecBusinessRules.RunModal;
    end;
}

