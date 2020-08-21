page 6151581 "Event Attribute Temp. Filters"
{
    // NPR5.33/TJ  /20170629 CASE 277946 New object created

    Caption = 'Event Attribute Temp. Filters';
    PageType = List;
    SourceTable = "Event Attribute Temp. Filter";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Filter Name"; "Filter Name")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
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
            action(Values)
            {
                Caption = 'Values';
                Image = BulletList;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    EventAttributeMatrix: Page "Event Attribute Matrix";
                begin
                    EventAttributeMatrix.SetAttrTemplate("Template Name");
                    EventAttributeMatrix.SetFilterMode("Filter Name");
                    EventAttributeMatrix.Run;
                end;
            }
            action(ShowEvents)
            {
                Caption = 'Show Events in Attribute Filter';
                Image = ShowList;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if not EventAttrMgt.ShowEventsInAttributesFilter("Template Name", "Filter Name") then
                        Message(NoEventsInFilter);
                end;
            }
        }
    }

    var
        EventAttrMgt: Codeunit "Event Attribute Management";
        NoEventsInFilter: Label 'There are not events with these attribute filters.';
}

