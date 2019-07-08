page 6060083 "MCS Rec. Business Rules"
{
    // NPR5.30/BR  /20170220  CASE 252646 Object Created

    Caption = 'MCS Rec. Business Rules';
    PageType = List;
    SourceTable = "MCS Rec. Business Rule";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Model No.";"Model No.")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Rule No.";"Rule No.")
                {
                }
                field(Active;Active)
                {
                }
                field("Rule Type";"Rule Type")
                {
                }
                field(Type;Type)
                {
                }
                field("No.";"No.")
                {
                }
                field("Block Seed Item No.";"Block Seed Item No.")
                {
                }
                field("Last Sent Date Time";"Last Sent Date Time")
                {
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

                trigger OnAction()
                begin
                    InsertRulesForItemSelection;
                end;
            }
        }
    }

    local procedure InsertRulesForItemSelection()
    var
        MCSRecommendationsModel: Record "MCS Recommendations Model";
        MCSAddRecBusinessRules: Report "MCS Add Rec. Business Rules";
    begin
        if "Model No." = '' then
          exit;
        Clear(MCSAddRecBusinessRules);
        MCSRecommendationsModel.Reset;
        MCSRecommendationsModel.SetRange(Code,Rec."Model No.");
        MCSAddRecBusinessRules.SetTableView(MCSRecommendationsModel);
        MCSAddRecBusinessRules.RunModal;
    end;
}

