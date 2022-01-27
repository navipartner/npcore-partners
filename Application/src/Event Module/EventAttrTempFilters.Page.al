page 6151581 "NPR Event Attr. Temp. Filters"
{
    Extensible = False;
    Caption = 'Event Attribute Temp. Filters';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Event Attr. Temp. Filter";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Filter Name"; Rec."Filter Name")
                {

                    ToolTip = 'Specifies the value of the Filter Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

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
            action(Values)
            {
                Caption = 'Values';
                Image = BulletList;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                ToolTip = 'Executes the Values action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    EventAttributeMatrix: Page "NPR Event Attribute Matrix";
                begin
                    EventAttributeMatrix.SetAttrTemplate(Rec."Template Name");
                    EventAttributeMatrix.SetFilterMode(Rec."Filter Name");
                    EventAttributeMatrix.Run();
                end;
            }
            action(ShowEvents)
            {
                Caption = 'Show Events in Attribute Filter';
                Image = ShowList;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Show Events in Attribute Filter action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    if not EventAttrMgt.ShowEventsInAttributesFilter(Rec."Template Name", Rec."Filter Name") then
                        Message(NoEventsInFilter);
                end;
            }
        }
    }

    var
        EventAttrMgt: Codeunit "NPR Event Attribute Mgt.";
        NoEventsInFilter: Label 'There are not events with these attribute filters.';
}

