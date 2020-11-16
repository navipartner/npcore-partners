page 6060083 "NPR MCS Rec. Business Rules"
{
    // NPR5.30/BR  /20170220  CASE 252646 Object Created

    Caption = 'MCS Rec. Business Rules';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR MCS Rec. Bus. Rule";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Model No."; "Model No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Rule No."; "Rule No.")
                {
                    ApplicationArea = All;
                }
                field(Active; Active)
                {
                    ApplicationArea = All;
                }
                field("Rule Type"; "Rule Type")
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Block Seed Item No."; "Block Seed Item No.")
                {
                    ApplicationArea = All;
                }
                field("Last Sent Date Time"; "Last Sent Date Time")
                {
                    ApplicationArea = All;
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

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
        if "Model No." = '' then
            exit;
        Clear(MCSAddRecBusinessRules);
        MCSRecommendationsModel.Reset;
        MCSRecommendationsModel.SetRange(Code, Rec."Model No.");
        MCSAddRecBusinessRules.SetTableView(MCSRecommendationsModel);
        MCSAddRecBusinessRules.RunModal;
    end;
}

