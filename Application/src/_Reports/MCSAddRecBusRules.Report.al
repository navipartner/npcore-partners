report 6060080 "NPR MCS Add Rec. Bus. Rules"
{
    Caption = 'MCS Add Rec. Business Rules';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All; 
    dataset
    {
        dataitem("MCS Recommendations Model"; "NPR MCS Recomm. Model")
        {
            DataItemTableView = SORTING(Code) ORDER(Ascending);
            dataitem(Item; Item)
            {
                RequestFilterFields = "No.", Description, "Item Category Code";

                trigger OnAfterGetRecord()
                begin
                    UpdateRule("No.");
                end;
            }

            trigger OnPreDataItem()
            begin
                if Count <> 1 then
                    Error(NoModelErr);
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field(RuleType; RuleType)
                {
                    Caption = 'Rule Type';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rule Type field';
                }
                field(MakeRulesActive; MakeRulesActive)
                {
                    Caption = 'Make Rules Active';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Make Rules Active field';
                }
                field(BlockSeedItemNo; BlockSeedItemNo)
                {
                    Caption = 'Block Seed Item No';
                    TableRelation = Item;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Block Seed Item No field';

                    trigger OnValidate()
                    begin
                        if BlockSeedItemNo <> '' then
                            RuleType := RuleType::Block;
                    end;
                }
            }
        }
    }

    trigger OnPostReport()
    begin
        if GuiAllowed then
            Message(RulesInsertedMsg, RulesInserted);
    end;

    trigger OnPreReport()
    begin
        RulesInserted := 0;
    end;

    var
        MakeRulesActive: Boolean;
        BlockSeedItemNo: Code[20];
        RulesInserted: Integer;
        RulesInsertedMsg: Label '%1 rules inserted.', Comment = '%1 = Number of rules';
        NoModelErr: Label 'Please select one Model to add Business Rules to.';
        RuleType: Option Block,WhiteList,Upsale;

    local procedure UpdateRule(ItemCode: Code[20])
    var
        MCSRecBusinessRule: Record "NPR MCS Rec. Bus. Rule";
    begin
        MCSRecBusinessRule.SetRange(Type, MCSRecBusinessRule.Type::Item);
        MCSRecBusinessRule.SetRange("No.", ItemCode);
        MCSRecBusinessRule.DeleteAll(true);

        MCSRecBusinessRule.Reset();
        MCSRecBusinessRule.Init();
        MCSRecBusinessRule.Validate("Model No.", "MCS Recommendations Model".Code);
        MCSRecBusinessRule.Validate(Active, MakeRulesActive);
        case RuleType of
            RuleType::Block:
                MCSRecBusinessRule.Validate("Rule Type", MCSRecBusinessRule."Rule Type"::Block);
            RuleType::Upsale:
                MCSRecBusinessRule.Validate("Rule Type", MCSRecBusinessRule."Rule Type"::Upsale);
            RuleType::WhiteList:
                MCSRecBusinessRule.Validate("Rule Type", MCSRecBusinessRule."Rule Type"::WhiteList);
        end;
        MCSRecBusinessRule.Validate(Type, MCSRecBusinessRule.Type::Item);
        MCSRecBusinessRule.Validate("No.", ItemCode);
        MCSRecBusinessRule.Validate("Block Seed Item No.", BlockSeedItemNo);
        MCSRecBusinessRule.Insert(true);
        RulesInserted := RulesInserted + 1;
    end;
}

