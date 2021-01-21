page 6151492 "NPR Raptor Data Buffer Entries"
{
    // NPR5.53/ALPO/20191125 CASE 377727 Raptor integration enhancements

    UsageCategory = None;
    Caption = 'Raptor Data Entries';
    DataCaptionExpression = GetDataCaptionExpr;
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
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Date-Time Created"; "Date-Time Created")
                {
                    ApplicationArea = All;
                    Visible = ShowCreatedDateTime;
                    ToolTip = 'Specifies the value of the Date-Time Created field';
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field("Item Description"; "Item Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Description field';
                }
                field(Priority; Priority)
                {
                    ApplicationArea = All;
                    Visible = ShowPriority;
                    ToolTip = 'Specifies the value of the Priority field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Show Item Card action';
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

