page 6060083 "NPR MCS Rec. Business Rules"
{
    // NPR5.30/BR  /20170220  CASE 252646 Object Created

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
                field("Model No."; "Model No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Model No. field';
                }
                field("Rule No."; "Rule No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rule No. field';
                }
                field(Active; Active)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Active field';
                }
                field("Rule Type"; "Rule Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rule Type field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Block Seed Item No."; "Block Seed Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Block Seed Item No. field';
                }
                field("Last Sent Date Time"; "Last Sent Date Time")
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
        if "Model No." = '' then
            exit;
        Clear(MCSAddRecBusinessRules);
        MCSRecommendationsModel.Reset;
        MCSRecommendationsModel.SetRange(Code, Rec."Model No.");
        MCSAddRecBusinessRules.SetTableView(MCSRecommendationsModel);
        MCSAddRecBusinessRules.RunModal;
    end;
}

