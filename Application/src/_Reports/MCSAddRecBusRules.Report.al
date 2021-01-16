report 6060080 "NPR MCS Add Rec. Bus. Rules"
{
    // NPR5.30/BR  /20170220  CASE 252646 Object Created
    // NPR5.48/TJ  /20180102  CASE 340615 Removed Product Group Code from ReqFilterFields property on dataitem Item

    UsageCategory = None;
    Caption = 'MCS Add Rec. Business Rules';
    ProcessingOnly = true;

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
                    Error(Text002);
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

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPostReport()
    begin
        if GuiAllowed then
            Message(Text001, RulesInserted);
    end;

    trigger OnPreReport()
    begin
        RulesInserted := 0;
    end;

    var
        RuleType: Option Block,WhiteList,Upsale;
        MakeRulesActive: Boolean;
        BlockSeedItemNo: Code[20];
        RulesInserted: Integer;
        Text001: Label '%1 rules inserted.';
        Text002: Label 'Please select one Model to add Business Rules to.';

    local procedure UpdateRule(ItemCode: Code[20])
    var
        MCSRecBusinessRule: Record "NPR MCS Rec. Bus. Rule";
    begin
        with MCSRecBusinessRule do begin
            Reset;
            SetRange(Type, Type::Item);
            SetRange("No.", ItemCode);
            DeleteAll(true);

            Reset;
            Init;
            Validate("Model No.", "MCS Recommendations Model".Code);
            Validate(Active, MakeRulesActive);
            case RuleType of
                RuleType::Block:
                    Validate("Rule Type", "Rule Type"::Block);
                RuleType::Upsale:
                    Validate("Rule Type", "Rule Type"::Upsale);
                RuleType::WhiteList:
                    Validate("Rule Type", "Rule Type"::WhiteList);
            end;
            Validate(Type, Type::Item);
            Validate("No.", ItemCode);
            Validate("Block Seed Item No.", BlockSeedItemNo);
            Insert(true);
            RulesInserted := RulesInserted + 1;
        end;
    end;
}

