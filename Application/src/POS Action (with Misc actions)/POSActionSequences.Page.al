page 6150726 "NPR POS Action Sequences"
{
    // NPR5.53/VB  /20190917  CASE 362777 Support for workflow sequencing (configuring/registering "before" and "after" workflow sequences that execute before or after another workflow)

    Caption = 'POS Action Sequences';
    PageType = List;
    SourceTable = "NPR POS Action Sequence";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Reference Type"; "Reference Type")
                {
                    ApplicationArea = All;
                    Editable = "Source Type" = "Source Type"::Manual;
                    Style = Subordinate;
                    StyleExpr = "Source Type" = "Source Type"::Discovery;
                }
                field("Reference POS Action Code"; "Reference POS Action Code")
                {
                    ApplicationArea = All;
                    Editable = "Source Type" = "Source Type"::Manual;
                    Style = Subordinate;
                    StyleExpr = "Source Type" = "Source Type"::Discovery;
                }
                field("POS Action Code"; "POS Action Code")
                {
                    ApplicationArea = All;
                    Editable = "Source Type" = "Source Type"::Manual;
                    Style = Subordinate;
                    StyleExpr = "Source Type" = "Source Type"::Discovery;
                }
                field("Source Type"; "Source Type")
                {
                    ApplicationArea = All;
                    Style = Subordinate;
                    StyleExpr = "Source Type" = "Source Type"::Discovery;
                }
                field("Sequence No."; "Sequence No.")
                {
                    ApplicationArea = All;
                    Editable = "Source Type" = "Source Type"::Manual;
                    Style = Subordinate;
                    StyleExpr = "Source Type" = "Source Type"::Discovery;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Editable = "Source Type" = "Source Type"::Manual;
                    Style = Subordinate;
                    StyleExpr = "Source Type" = "Source Type"::Discovery;
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

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

