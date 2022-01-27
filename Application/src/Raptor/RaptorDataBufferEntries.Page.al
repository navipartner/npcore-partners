page 6151492 "NPR Raptor Data Buffer Entries"
{
    Extensible = False;
    // NPR5.53/ALPO/20191125 CASE 377727 Raptor integration enhancements

    UsageCategory = None;
    Caption = 'Raptor Data Entries';
    DataCaptionExpression = GetDataCaptionExpr();
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "NPR Raptor Data Buffer";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Date-Time Created"; Rec."Date-Time Created")
                {

                    Visible = ShowCreatedDateTime;
                    ToolTip = 'Specifies the value of the Date-Time Created field';
                    ApplicationArea = NPRRetail;
                }
                field("Item No."; Rec."Item No.")
                {

                    ToolTip = 'Specifies the value of the Item No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {

                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Description"; Rec."Item Description")
                {

                    ToolTip = 'Specifies the value of the Item Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Priority; Rec.Priority)
                {

                    Visible = ShowPriority;
                    ToolTip = 'Specifies the value of the Priority field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(ShowItem)
            {
                Caption = 'Show Item Card';
                Image = Item;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = Page "Item Card";
                RunPageLink = "No." = FIELD("Item No.");

                ToolTip = 'Executes the Show Item Card action';
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnOpenPage()
    begin
        ShowCreatedDateTime := RaptorAction."Show Date-Time Created";
        ShowPriority := RaptorAction."Show Priority";
    end;

    var
        RaptorAction: Record "NPR Raptor Action";
        ShowCreatedDateTime: Boolean;
        ShowPriority: Boolean;

    procedure SetRaptorAction(_Action: Record "NPR Raptor Action")
    begin
        RaptorAction := _Action;
    end;

    procedure SetRecordSet(var RaptorDataBuffer: Record "NPR Raptor Data Buffer")
    begin
        Rec.Copy(RaptorDataBuffer, true);
    end;

    local procedure GetDataCaptionExpr(): Text
    begin
        exit(RaptorAction."Data Type Description");
    end;

    procedure GetRaptorAction(var _Action: Record "NPR Raptor Action")
    begin
        _Action := RaptorAction;
    end;
}

