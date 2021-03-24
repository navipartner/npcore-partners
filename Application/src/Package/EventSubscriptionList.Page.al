page 6059787 "NPR Event Subscription List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Event Subscription";
    Caption = 'Event Subscription List';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Subscriber Codeunit ID"; Rec."Subscriber Codeunit ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Subscriber Codeunit ID field';
                }
                field("Subscriber Function"; Rec."Subscriber Function")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Subscriber Function field';
                }
                field("Published Function"; Rec."Published Function")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Published Function field';
                }
                field("Publisher Object ID"; Rec."Publisher Object ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Publisher Object ID field';
                }
                field("Publisher Object Type"; Rec."Publisher Object Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Publisher Object Type field';
                }
                field(Active; Rec.Active)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Active field';
                }
                field("Event Type"; Rec."Event Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Event Type field';
                }
                field("Originating App Name"; Rec."Originating App Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Originating App Name field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Set filter to tenant subscribers")
            {
                Caption = 'Set filter to tenant subscribers';
                Image = FilterLines;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                ToolTip = 'Executes the Set filter to tenant subscribers action';

                trigger OnAction()
                var
                    SetFilterQst: Label 'Do you want to set filter to tenant subscribers';
                    ObjFilterTxt: Label '50000..99999';
                begin
                    If not Confirm(SetFilterQst, false) then
                        exit;

                    Rec.SetFilter("Subscriber Codeunit ID", ObjFilterTxt);
                end;
            }
        }
    }
}