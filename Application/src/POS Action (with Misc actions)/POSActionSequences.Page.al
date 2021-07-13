page 6150726 "NPR POS Action Sequences"
{
    Caption = 'POS Action Sequences';
    PageType = List;
    SourceTable = "NPR POS Action Sequence";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Reference Type"; Rec."Reference Type")
                {

                    Editable = Rec."Source Type" = Rec."Source Type"::Manual;
                    Style = Subordinate;
                    StyleExpr = Rec."Source Type" = Rec."Source Type"::Discovery;
                    ToolTip = 'Specifies the value of the Reference Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Reference POS Action Code"; Rec."Reference POS Action Code")
                {

                    Editable = Rec."Source Type" = Rec."Source Type"::Manual;
                    Style = Subordinate;
                    StyleExpr = Rec."Source Type" = Rec."Source Type"::Discovery;
                    ToolTip = 'Specifies the value of the Reference POS Action Code field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Action Code"; Rec."POS Action Code")
                {

                    Editable = Rec."Source Type" = Rec."Source Type"::Manual;
                    Style = Subordinate;
                    StyleExpr = Rec."Source Type" = Rec."Source Type"::Discovery;
                    ToolTip = 'Specifies the value of the POS Action Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Source Type"; Rec."Source Type")
                {

                    Style = Subordinate;
                    StyleExpr = Rec."Source Type" = Rec."Source Type"::Discovery;
                    ToolTip = 'Specifies the value of the Source Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Sequence No."; Rec."Sequence No.")
                {

                    Editable = Rec."Source Type" = Rec."Source Type"::Manual;
                    Style = Subordinate;
                    StyleExpr = Rec."Source Type" = Rec."Source Type"::Discovery;
                    ToolTip = 'Specifies the value of the Sequence No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    Editable = Rec."Source Type" = Rec."Source Type"::Manual;
                    Style = Subordinate;
                    StyleExpr = Rec."Source Type" = Rec."Source Type"::Discovery;
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(DiscoverSequences)
            {
                Caption = 'Discover Sequences';
                Image = CopyBOM;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Discover Sequences action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    RunDiscovery(true);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        RunDiscovery(false);
    end;

    var
        Text001: Label 'Discovery failed. Fix the problem and re-run POS action sequence discovery.\\Error details are: %1';

    local procedure RunDiscovery(Fail: Boolean)
    var
        MsgText: Text;
    begin
        if not CODEUNIT.Run(CODEUNIT::"NPR Discover POSAction Seq.") then begin
            MsgText := StrSubstNo(Text001, GetLastErrorText);
            if Fail then
                Error(MsgText)
            else
                Message(MsgText);
        end;
    end;
}

